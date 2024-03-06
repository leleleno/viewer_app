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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: myAppbar(context, widget.title),
      drawer: myDrawer(context, _selectedIndex),
      body: Container(
        color: Colors.amber,
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.favorite_border),
        onPressed: (){
          setState(() {
            _is_favorite = !_is_favorite;
          });
        },
        selectedIcon: const Icon(Icons.favorite),
        isSelected: _is_favorite,
        ),
    );
  }
}

