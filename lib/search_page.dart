import 'package:first_app/uis.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MySearchPageState();
    // TODO: implement createState
  }
}

class _MySearchPageState extends State<SearchPage> {
  final int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, "Search Page"),
      drawer: myDrawer(context, _selectedIndex),
      body: const Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: "Enter a search word"),
            ),
          ),
          Center(
            child: Text("Test"),
          )
        ],
      ),
    );
  }
}
