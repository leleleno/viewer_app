import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/data/favoritedata.dart';
import 'package:first_app/data/historydata.dart';
import 'package:first_app/data/searchdata.dart';
import 'package:first_app/data/searchworddata.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("検索"),
      ),
      drawer: const MyDrawer(index: 1),
      body: Stack(
        children: [
          Positioned.fill(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  16.0,
              // ignore: prefer_const_constructors
              child: SingleChildScrollView(child: CardListView())),
          // ignore: prefer_const_constructors
          Positioned(
            top: 0,
            left: 0,
            right: 0, // Stack の右端まで広げるために right: 0 を追加します
            // ignore: prefer_const_constructors
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // ignore: prefer_const_constructors
              // child: CustomSearchBar(),
              child: const CustomSearchBar(),
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
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
      // 検索履歴を監視
      final searchWords = ref.watch(searchNotifierProvider);
      // 検索ワードを監視
      final searchWord = ref.watch(searchWordNotifierProvider);
      TextEditingController _controller = TextEditingController(text: searchWords.last ?? searchWord);
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
        return SearchAnchor(
          isFullScreen: false,
          builder: (BuildContext context, SearchController _controller) {
            return SearchBar(
              controller: _controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              // 先頭に検索ボタン
              leading: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  String value = _controller.text;
                  // 検索履歴に追加
                  final notifier = ref.read(searchNotifierProvider.notifier);
                  notifier.addData(value);
                  // 検索ワードを更新
                  final searchNotifier =
                      ref.read(searchWordNotifierProvider.notifier);
                  searchNotifier.newSearch(value);
                },
              ),
              // 後方にオプション開くボタン
              trailing: [IconButton(icon: const Icon(Icons.add),onPressed: (){},)],
              // Tapで開く
              onTap: () {
                _controller.openView();
              },
              // barの中身が変わったら
              onChanged: (value) {},
              // ワードで検索
              onSubmitted: (value) {
                // 検索履歴に追加
                final notifier = ref.read(searchNotifierProvider.notifier);
                notifier.addData(value);
                // 検索ワードを更新
                final searchNotifier =
                    ref.read(searchWordNotifierProvider.notifier);
                searchNotifier.newSearch(value);
                // Focusを外す
                FocusScope.of(context).unfocus();
              },
            );
          },
          // サジェスト：検索履歴
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            return List<Widget>.from(searchWords.reversed.map((item) {
              // 新しいものから順に取り出したいのでreversed
              if (item.isNotEmpty) {
                return ListTile(
                  title: Text(item),
                  // ReRenderingできないから履歴削除ボタンはなし
                  onTap: () {
                    controller.closeView(item);
                    // 検索履歴を更新
                    final notifier = ref.read(searchNotifierProvider.notifier);
                    notifier.addData(item);
                    // 検索ワードを更新
                    final searchNotifier =
                        ref.read(searchWordNotifierProvider.notifier);
                    searchNotifier.newSearch(item);
                    // Focusを外す
                    FocusScope.of(context).unfocus();
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            }));
          },
        );
      }
    );
  }
}

// 検索結果のタイルを並べるWidget
class CardListView extends ConsumerWidget {
  const CardListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 検索ワードの変化を追う
    final searchWord = ref.watch(searchWordNotifierProvider);
    if (searchWord.isNotEmpty) {
      return FutureBuilder<Map<String, String>>(
        future: fetchSearchResult(keyword: searchWord),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, String>> snapshot) {
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
    } else {
      return const SizedBox.shrink();
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
                  final notifier = ref.read(favoriteNotifierProvider.notifier);
                  notifier.removeData(title);
                },
                icon: const Icon(Icons.favorite))
            // もしお気に入りじゃなかったら
            : IconButton(
                onPressed: () {
                  final notifier = ref.read(favoriteNotifierProvider.notifier);
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
