import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/data/favoritedata.dart';
import 'package:first_app/data/historydata.dart';
import 'package:first_app/data/searchdata.dart';
import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

// 行ったり来たりしても状態を保持してほしいならHook
class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("検索"),
      ),
      drawer: const MyDrawer(index: 1),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final searchWords = ref.watch(searchNotifierProvider);
          return Stack(
            children: [
              if (searchWords.isEmpty)
                const SizedBox() // Center ウィジェットを SizedBox に置き換えます
              else
                Positioned.fill(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        32.0,
                    left: 10,
                    right: 10,
                    child: SingleChildScrollView(
                        child: CardListView(input: searchWords.last))),
              const Positioned(
                top: 0,
                left: 0,
                right: 0, // Stack の右端まで広げるために right: 0 を追加します
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomSearchBar(),
                ),
              ),
            ],
          );
        },
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
        // 検索ワードを監視
        final searchWords = ref.watch(searchNotifierProvider);
        // 検索バーに最初に入れるワード
        TextEditingController controller = TextEditingController(
          text: searchWords.isNotEmpty ? searchWords.last : "",
        );
        return Column(
          children: [
            TextField(
              focusNode: _focusNode,
              controller: controller,
              style: const TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    String value = controller.text;
                    final notifier = ref.read(searchNotifierProvider.notifier);
                    notifier.addData(value);
                  },
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                ),
                hintText: "Search bar",
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final notifier = ref.read(searchNotifierProvider.notifier);
                notifier.addData(value);
              },
            ),
            Visibility(
                visible: _isFocused,
                child: ListView.builder(
                  // Columnの中に入れるときのエラー回避
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), //追加
                  // ListView.builder内のindexingエラーを修正
                  itemCount: searchWords.length,
                  itemBuilder: (BuildContext context, index) {
                    var item = searchWords[index]; // indexを正しく指定
                    // 空のアイテムをスキップ
                    if (item != "") {
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          setState(() {
                            controller.value =
                                TextEditingValue(text: item); // TextFieldの値を更新
                            _focusNode.unfocus(); // リストアイテムをタップしたらフォーカスを外す
                          });
                        },
                      );
                    } else {
                      return const SizedBox.shrink(); // 空のアイテムの場合は何も表示しない
                    }
                  },
                )),
          ],
        );
      },
    );
  }
}

// 検索結果のタイルを並べたWidget
class CardListView extends HookWidget {
  const CardListView({super.key, required this.input});
  final String input;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: fetchSearchResult(keyword: input),
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
          if (snapshot.data!.isEmpty || snapshot.data == null) {
            // 中身が空だった場合
            return const Center(
              child: Text("No search results!"),
            );
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
  }
}

class CardTile extends StatelessWidget {
  const CardTile({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
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
      },
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
