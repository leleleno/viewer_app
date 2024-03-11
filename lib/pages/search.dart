import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/data/favoritedata.dart';
import 'package:first_app/data/historydata.dart';
import 'package:first_app/data/searchdata.dart';
import 'package:first_app/data/searchworddata.dart';
import 'package:first_app/data/settingsdata.dart';
import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text("検索"),
      // ),
      drawer: const MyDrawer(index: 1),
      body: Stack(
        children: [
          Positioned.fill(
            top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 32.0,
            // ignore: prefer_const_constructors
            child: SingleChildScrollView(child: CardListView())
          ),
          // ignore: prefer_const_constructors
          Positioned(
            top: 0,
            left: 0,
            right: 0, // Stack の右端まで広げるために right: 0 を追加します
            // ignore: prefer_const_constructors
            child: Padding(
              padding: EdgeInsets.all(8.0),
              // ignore: prefer_const_constructors
              child: CustomSearchBar(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  // フォーカスの変更を処理するハンドラ
  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  } // TextFieldのfocusNodeをdispose

  @override
  void dispose() {
    _focusNode.dispose(); // disposeを実装
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Darkmodeか確認
        // ignore: unused_local_variable
        final settings = ref.watch(settingsNotifierProvider);
        // 検索履歴を監視
        final searchWords = ref.watch(searchNotifierProvider);
        // 検索ワードを監視
        final searchWord = ref.watch(searchWordNotifierProvider);
        // 検索バーに最初に入れるワード
        TextEditingController controller = TextEditingController(
          text: searchWord,
        );
        // カーソルが一番後ろに合うように
        controller.selection = TextSelection.fromPosition(TextPosition(offset: searchWord.length));
        return Column(
          children: [
            TextField(
              focusNode: _focusNode,
              controller: controller,
              style: const TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.inversePrimary,
                // 先頭のボタン
                prefixIcon: _isFocused
                    // フォーカスあり
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // Focusを外す
                        FocusScope.of(context).unfocus();
                      },
                    )
                    // フォーカスなし
                    : IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        // Focusを外す
                        FocusScope.of(context).unfocus();
                        // Drawer open
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                // 後ろのボタン
                suffixIcon: _isFocused
                // フォーカスあり
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  )
                  // フォーカスなし
                : IconButton(onPressed: (){}, icon: const Icon(Icons.add)),
                hintText: "Search bar",
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                // 検索履歴に追加
                final notifier = ref.read(searchNotifierProvider.notifier);
                notifier.addData(value);
                // 検索ワードを更新
                final searchNotifier = ref.read(searchWordNotifierProvider.notifier);
                searchNotifier.newSearch(value);
                // Focusを外す
                FocusScope.of(context).unfocus();
              },
            ),
            // 検索履歴を表示
            ListView.builder(
                // Columnの中に入れるときのエラー回避
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), //追加
              // 縁取り
              // ListView.builder内のindexingエラーを修正
              itemCount: searchWords.length,
              itemBuilder: (BuildContext context, index) {
                // 逆向きに指定
                var item =
                    List.from(searchWords.reversed)[index]; // indexを正しく指定
                // 空のアイテムをスキップ
                if (item != "") {
                  return ListTile(
                    title: Text(item),
                    // 履歴消去ボタン
                    trailing: IconButton(onPressed: (){
                      final notifier = ref.read(searchNotifierProvider.notifier);
                      notifier.removeData(item);
                      // 検索履歴を削除した後にリビルドされるようにする
                      setState(() {});
                    }, icon: const Icon(Icons.delete)),
                    onTap: () {
                      // そのワードで検索
                      final notifier = ref.read(searchNotifierProvider.notifier);
                      notifier.addData(item);
                      final searchNotifier = ref.read(searchWordNotifierProvider.notifier);
                      searchNotifier.newSearch(item);
                      _focusNode.unfocus();
                    },
                  );
                } else {
                  // 空のアイテムの場合は何も表示しない
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// 検索結果のタイルを並べるWidget
class CardListView extends ConsumerWidget {
  const CardListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchWord = ref.watch(searchWordNotifierProvider);
    if (searchWord != ''){
      return FutureBuilder<Map<String, String>>(
        future: fetchSearchResult(keyword: searchWord),
        builder:
            (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 待機中の処理
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 通信失敗時の処理
            return SelectableText('Network Error: ${snapshot.error}');
          } else {
            // 成功時の処理
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              // 中身が空だった場合
              return const SizedBox();
            } else {
              // 結果を表示
              Map<String, String> data = snapshot.data!;
              return Column(
                children: data.entries.map((entry) {
                  String title = entry.key;
                  String url = entry.value;
                  return CardTile(
                    title: title,
                    url: url,
                  );
                }).toList(),
              );
            }
          }
        },
      );
    } else{
      return const SizedBox();
    }
  }
}

class CardTile extends ConsumerWidget {
  const CardTile({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // お気に入り、履歴を監視
    final favorites = ref.watch(favoriteNotifierProvider);
    final histories = ref.watch(historyNotifierProvider);
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title),
        trailing: favorites.containsKey(title)
            // もしお気に入りなら
            ? IconButton(
                onPressed: () {
                  final notifier =
                      ref.read(favoriteNotifierProvider.notifier);
                  notifier.removeData(title);
                },
                icon: const Icon(Icons.favorite))
            // もしお気に入りじゃなかったら
            : IconButton(
                onPressed: () {
                  final notifier =
                      ref.read(favoriteNotifierProvider.notifier);
                  notifier.addData(title, url);
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
        onLongPress: () {},
      ),
    );
  }
}

Future<Map<String, String>> fetchSearchResult(
    {required String keyword,
    String searchMode = "AND",
    bool cardTarget = true,
    bool articleTarget = false,
    bool deckTarget = false,
    bool commentTarget = false}) async {
  // 1. http通信に必要なデータを準備をする
  Uri url = Uri.parse('https://yugioh-wiki.net/index.php?cmd=search');
  var data = {
    'encode_hint': 'ぷ',
    'word': keyword.replaceAll('　', ' '),
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
  // カード名か判断するための正規表現
  final RegExp isCardTitle = RegExp(r'^《.*》$');
  // デッキ名か判断するための正規表現
  final RegExp isDeckTitle = RegExp(r'^【.*】$');
  // コメントか判断するための正規表現
  final RegExp isCommentTitle = RegExp(r'^コメント');
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

      if (cardTarget && isCardTitle.hasMatch(text)) {
        retList[text] = newUrl;
      } else if (deckTarget && isDeckTitle.hasMatch(text)) {
        retList[text] = newUrl;
      } else if (commentTarget && isCommentTitle.hasMatch(text)) {
        retList[text] = newUrl;
      } else if (articleTarget &&
          !isCardTitle.hasMatch(text) &&
          !isDeckTitle.hasMatch(text) &&
          !isCommentTitle.hasMatch(text)) {
        retList[text] = newUrl;
      }
    }
  }
  return retList;
}
