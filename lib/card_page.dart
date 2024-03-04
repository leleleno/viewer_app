import 'package:first_app/uis.dart';
import 'package:flutter/material.dart';
// import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;




class MyCard extends StatelessWidget {
  const MyCard(String s, {super.key, required this.url});

  // 取得先のURLを元にして、Uriオブジェクトを生成する。
  final String url;

  final int _selectedIndex = -1;

  @override
  Widget build(BuildContext context){
    return MyCardView(selectedIndex: _selectedIndex, url: url);
  }
}

class MyCardView extends StatelessWidget {
  const MyCardView({
    super.key,
    required int selectedIndex,
    required this.url,
  }) : _selectedIndex = selectedIndex;

  final int _selectedIndex;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, "Card"),
      drawer: myDrawer(context, _selectedIndex),
      body: FutureBuilder(
        future: fetchHtmlFromUrl(url),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();  // ロード中はスピナーを表示
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');  // エラー時はエラーメッセージを表示
        } else {
          return Text(snapshot.data ?? '');  // データがあれば表示
        }
      },
      )
    );
  }
}

Future<String> fetchHtmlFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // リクエストが成功した場合、HTMLを返します。
    // 取得したHTMLのボディをパースする。
    // final document = parse(response.body);
    // final document_body = document.body;
    return response.body;
  } else {
    // リクエストが失敗した場合、エラーをスローします。
    throw Exception('Failed to load HTML from $url');
  }
}
