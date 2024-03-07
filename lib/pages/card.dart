import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class CardView extends StatefulWidget {
  const CardView({super.key, required this.page_url});

  final String page_url;
  final String title = "card name";

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  final int _selectedIndex = -1;

  bool _is_favorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, widget.title),
      drawer: myDrawer(context, _selectedIndex),
      body: Column(
        children: [
          // 検索バー
          MySearchBar(),
          // 隙間
          Padding(padding: EdgeInsets.all(10)),
          // ページコンテンツ、非同期処理なのでFuturebuilder
          FutureBuilder(
            future: fetchCardData(context, widget.page_url),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data ?? Container();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _is_favorite = !_is_favorite;
          });
        },
        tooltip: "Add to Favorite",
        child: Icon(
          _is_favorite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }
}

Future<Widget> fetchCardData(BuildContext context, String page_url) async {
  // 取得先のURLを元にして、Uriオブジェクトを生成する。
  final response = await http.get(
    Uri.http(page_url),
  );
  // 成功したらhtml parser
  final decodedBody =
      await CharsetConverter.decode("EUC-JP", response.bodyBytes);
  final document = parse(decodedBody);
  // responseに関する処理
  return Container(
    width: double.infinity,
    color: Colors.amberAccent,
    padding: const EdgeInsets.all(10),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Card effect here"),
        Padding(padding: EdgeInsets.all(10.0)),
        Text("Description here"),
        Padding(padding: EdgeInsets.all(10.0)),
        Text("Tips here"),
        Padding(padding: EdgeInsets.all(10.0)),
        Text("Q & A here"),
      ],
    ),
  );
}
