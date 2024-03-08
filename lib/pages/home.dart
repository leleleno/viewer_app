import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  final String title = "HOME";

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, widget.title),
      drawer: myDrawer(context, _selectedIndex),
      body: Column(
        children: [
          // ホームページ
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Welcome to Home page!"),
                  Text(DateTime.now().toString())
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
