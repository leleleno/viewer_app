import 'package:first_app/uis.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget{
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const SearchPageView();
  }
}
class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MySearchPageViewState();
  }
}

class _MySearchPageViewState extends State<SearchPageView> {
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
                  icon: Icon(Icons.abc),
                  border: InputBorder.none,
                  hintText: "Enter a search word"
                ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: null,
              child: Text("Press button")
            ),
            ),
        ],
      ),
    );
  }
}
