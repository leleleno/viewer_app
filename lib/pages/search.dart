import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MySearchState();
  }
}

class _MySearchState extends State<Search> {
  final int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, "Search Page"),
      drawer: myDrawer(context, _selectedIndex),
      body: Column(
        children: [
          const SizedBox(
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
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CardView(page_url: '1',),
                      settings: const RouteSettings(name: "/page_url")
                    )
                    );
              },
              child: const Text("Press button to show cards")
            ),
            ),
        ],
      ),
    );
  }
}
