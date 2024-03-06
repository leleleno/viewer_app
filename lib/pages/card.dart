import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';

class CardView extends StatefulWidget {
  const CardView({super.key, required this.page_url});

  // 取得先のURLを元にして、Uriオブジェクトを生成する。
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
      body: fetchCardData(context, widget.page_url),
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

Widget fetchCardData(BuildContext context, String page_url) {
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
