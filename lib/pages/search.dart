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
class Search extends HookConsumerWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchWords = ref.watch(searchNotifierProvider);

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
            if (searchWords.isEmpty)
              const Center(
                child: Text(
                  "Wow. Such an Empty!",
                  style: TextStyle(fontSize: 20),
                ),
              )
            else
              CardListView(input: searchWords.last),
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends HookWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // 検索ワードを監視
        final searchWords = ref.watch(searchNotifierProvider);
        List<Widget> listButton = [];
        if (searchWords.isNotEmpty) {
          for (String element in searchWords) {
            listButton.insert(
              0,
              ListTile(
                title: Text(element),
                onTap: () {
                  final notifier = ref.read(searchNotifierProvider.notifier);
                  notifier.addData(element);
                },
              ),
            );
          }
        }

        TextEditingController controller = TextEditingController(
          text: searchWords.isNotEmpty ? searchWords.last : "",
        );

        return Column(
          children: [
            TextField(
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
              visible: false,
              child: Column(
                children: listButton,
              ),
            ),
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
            subtitle: Text(url),
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
              // 履歴に追加
              final notifier = ref.read(historyNotifierProvider.notifier);
              notifier.addData(title, url);
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
