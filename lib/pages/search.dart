import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
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
  void initState(){
    super.initState();
    // 初期化時にWidgetの引数を渡す
    _input = widget.inputText;
    _controller = TextEditingController(text: _input);
  }
  final int _selectedIndex = 1;
  // TextFieldのController作成
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, "Search Page"),
      drawer: myDrawer(context, _selectedIndex),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black
              ),
              decoration:  InputDecoration(
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
                  onPressed: (){
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
          CardListView(inputText: _input,),
        ],
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
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CardView(page_url: 'https://yugioh-wiki.net/index.php?%A1%D4%A5%C8%A1%BC%A5%C6%A5%E0%A5%DD%A1%BC%A5%EB%A1%D5',),
                settings: const RouteSettings(name: "/card/%A1%D4%A5%C8%A1%BC%A5%C6%A5%E0%A5%DD%A1%BC%A5%EB%A1%D5")
              )
              );
        },
        child: const Text("Press button to show cards")
      ),
      );
  }
}

Future<List> searchWiki(String keyword) async{
  // 1. http通信に必要なデータを準備をする
  final response = await Uri.parse('https://yugioh-wiki.net/?cmd=list');
  List retList = [];
  for (int i = 0; i <10; i++){
    retList.add(
      const Card(
        child: ListTile(
          title: Text("name"),
          subtitle: Text("description"),
        ),
      )
    );
  }
  // 2. Qiita APIにリクエストを送る
  // 3. 戻り値をArticleクラスの配列に変換
  // 4. 変換したArticleクラスの配列を返す(returnする)
  return retList;
}