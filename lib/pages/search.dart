import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/favorite.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class SearchWordNotifier extends _$SearchWordNotifier {
  // {card name: url}
  @override
  List<String> build() {
    return [];
  }
  void addSearchWord(String value){
    if (state.contains(value)){
      state.remove(value);
      state.add(value);
    } else{
      state.add(value);
      if (state.length > 15){
        state.removeAt(0);
      }
    }
  }
}

class Search extends ConsumerWidget {
  const Search({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchWords = ref.watch(searchWordNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Search"),
      ),
      drawer: const MyDrawer(index: 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomSearchBar(),
            ),
            if (searchWords[searchWords.length-1] != "")
              const CardListView(),
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends ConsumerWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 検索履歴
    final searchWords = ref.watch(searchWordNotifierProvider);
    List<Widget> listButton = [];
    if (searchWords.isNotEmpty){
      for (String element in searchWords) {
        listButton.insert(0,
          ListTile(
            title: Text(element),
            onTap: (){
              final notifier = ref.read(searchWordNotifierProvider.notifier);
              notifier.addSearchWord(element);
            },
          )
        );
      }
    }
    // 検索バーにあらかじめ表示する内容
    TextEditingController controller = TextEditingController(text: searchWords[searchWords.length-1]);
    // フォーカス判定
    // FocusNode focus = FocusNode();
    // bool isFocus = false;
    return Column(
      children: [
        TextField(
            controller: controller,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Trigger onSubmitted event manually
                  String value = controller.text;
                  final notifier = ref.read(searchWordNotifierProvider.notifier);
                  notifier.addSearchWord(value);
                },
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  // TextFieldのテキストをクリアする
                  controller.clear();
                },
              ),
              hintText: "Search bar",
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              String value = controller.text;
              final notifier = ref.read(searchWordNotifierProvider.notifier);
              notifier.addSearchWord(value);
            },
          ),
          Visibility(
            visible: false,
            child: Column(children: listButton,)
          ),
      ],
    );
  }
}

class CardListView extends HookConsumerWidget {
  const CardListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchWords = ref.watch(searchWordNotifierProvider);
    return FutureBuilder<Map<String, String>>(
      future: fetchSearchResult(keyword: searchWords[searchWords.length-1]),
      builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        // 待機中の処理
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 通信失敗時の処理
          return SelectableText('Network Error: ${snapshot.error}');
        } else {
          // 成功時の処理
          if (snapshot.data!.isEmpty || snapshot.data == null) {
            // 中身が空だった場合
            return const Center(
              child: Text("No search results!"),
            );
          } else {
            // 結果を表示
            List<Widget> retList = [];
            // カード名か判断するための正規表現
            final RegExp iscardTitle = RegExp(r'^《.*》$');
            snapshot.data!.forEach((key, value) {
              if (iscardTitle.hasMatch(key)) {
                // カードだけretListに加える
                Widget listTile = CardTile(title: key, url: value,);
                retList.add(listTile);
              }
            },);
            return Column(children: retList,);
          }
        }
      },
    );
  }
}

class CardTile extends ConsumerWidget {
  const CardTile({super.key,
    required this.title,
    required this.url
  });
  final String title;
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteNotifierProvider);
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title),
        subtitle: Text(url),
        trailing: favorites.containsKey(title)
          ? IconButton(
            onPressed: () {
              final notifier = ref.read(favoriteNotifierProvider.notifier);
              notifier.removeFavorite(title);
            },
            icon: const Icon(Icons.favorite))
          : IconButton(
            onPressed: () {
              final notifier = ref.read(favoriteNotifierProvider.notifier);
              notifier.addFavorite(title, url);
            },
            icon: const Icon(Icons.favorite_border)),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CardView(
              pageUrl: url,
              cardName: title,
            ),
            settings: RouteSettings(name: "/card/$key"),
          ));
        },
      ),
    );
  }
}

Future<Map<String, String>> fetchSearchResult({required String keyword, String searchMode = "AND"}) async {
  // 1. http通信に必要なデータを準備をする
  Uri url = Uri.parse('https://yugioh-wiki.net/index.php?cmd=search');
  var data = {
    'encode_hint': 'ぷ',
    'word': keyword,
    'type': searchMode,
  };

  var response = await http.post(url, body: data);
  // List for return
  Map<String, String> retList = {};
  // 通信の成否に合わせてReturn
  if (response.statusCode != 200) {
    return retList;
  }
  // 成功したらhtml parser
  final decodedBody =
      await CharsetConverter.decode("EUC-JP", response.bodyBytes);
  final document = parse(decodedBody);
  // <li>Tagをすべて取得
  var lists = document.body!.getElementsByTagName('li');
  // 空だったら終わり
  if (lists.isEmpty) {
    return retList;
  }
  for (var li in lists) {
    var aTag = li.querySelector('a');
    if (aTag != null) {
      // <a> Tagから リンクとページ名を取得
      String linkUrl = aTag.attributes['href'] ?? '';
      // urlを正規表現で置換
      String newUrl =
          linkUrl.replaceAll(RegExp(r"(:443|cmd=read&page=|&word=.*$)"), "");
      // card name
      String text = aTag.text;
      retList[text] = newUrl;
      }
    }
  return retList;
}
