import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({super.key, required this.inputText});
  final String inputText;
  @override
  State<StatefulWidget> createState() {
    return _MySearchState();
  }
}

class _MySearchState extends State<Search> {
  // 変数を宣言
  late String _input;
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    // 初期化時にWidgetの引数を渡す
    _input = widget.inputText;
    // 検索バーにあらかじめ表示する内容
    _controller = TextEditingController(text: _input);
  }

  final int _selectedIndex = 1;
  // TextFieldのController作成
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, "Search Page"),
      drawer: myDrawer(context, _selectedIndex),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Trigger onSubmitted event manually
                      String value = _controller.text;
                      setState(() {
                        _input = value;
                      });
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // TextFieldのテキストをクリアする
                      _controller.clear();
                    },
                  ),
                  hintText: "Search bar",
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _input = value;
                  });
                },
              ),
            ),
            CardListView(
              inputText: _input,
            ),
          ],
        ),
      ),
    );
  }
}

class CardListView extends StatefulWidget {
  CardListView({super.key, required this.inputText});
  String inputText;

  @override
  State<CardListView> createState() => _CardListViewState();
}

class _CardListViewState extends State<CardListView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: fetchSearchResult(context, widget.inputText),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return SelectableText('Network Error: ${snapshot.error}');
        } else {
          if (snapshot.data!.isEmpty || snapshot.data == null) {
            return const Center(
              child: Text("No search results!"),
            );
          } else {
            return Column(
              children: snapshot.data!,
            );
          }
        }
      },
    );
  }
}

Future<List<Widget>> fetchSearchResult(
    BuildContext context, String keyword) async {
  // 1. http通信に必要なデータを準備をする
  Uri url = Uri.parse('https://yugioh-wiki.net/index.php?cmd=search');
  var data = {
    'encode_hint': 'ぷ',
    'word': keyword,
    'type': 'AND',
  };

  var response = await http.post(url, body: data);
  // List for return
  List<Widget> retList = [];
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
  // カードかどうか判断する要の正規表現
  final RegExp iscardTitle = RegExp(r'^《.*》$');
  for (var li in lists) {
    var aTag = li.querySelector('a');
    if (aTag != null) {
      // <a> Tagから リンクとページ名を取得
      String linkUrl = aTag.attributes['href'] ?? '';
      String newUrl = linkUrl.replaceAll(RegExp(r"(:443|cmd=read&page=|&word=.*$)"), "");
      String text = aTag.text;
      // String newUrl =
      //     'https://yugioh-wiki.net/index.php?${Uri.encodeFull(text)}';
      // 正規表現でカード名かどうか判断
      if (iscardTitle.hasMatch(text)){
        var liTile = ListTile(
          title: Column(
            children: [Text(text), SelectableText(linkUrl), SelectableText(newUrl)],
          ),
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => CardView(page_url: newUrl),
            //   settings: RouteSettings(name: "/card/$text"),
            // ));
          },
        );
        retList.add(liTile);
      }
    }
  }

  return retList;
}

Future<String> fetchSample(BuildContext context, String keyword) async {
  // 1. http通信に必要なデータを準備をする
  var url = Uri.parse('https://yugioh-wiki.net/index.php?cmd=search');
  var data = {
    'encode_hint': 'ぷ',
    'word': keyword,
    'type': 'AND',
  };

  final response = await http.post(url, body: data);
  final decodedBody =
      await CharsetConverter.decode("EUC-JP", response.bodyBytes);
  final document = parse(decodedBody);
  var lists = document.body!.getElementsByTagName("li");
  List<String> retList = [];

  for (var li in lists) {
    var aTag = li.querySelector('a');
    if (aTag != null) {
      String url = aTag.attributes['href'] ?? '';
      String text = aTag.text;
      var liTile = ListTile(
        title: Text(text),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CardView(page_url: url),
            settings: RouteSettings(name: "/card/$text"),
          ));
        },
      );
      retList.add(text);
    }
  }
  return retList.join("\n");
}
