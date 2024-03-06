import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  final String title = "History";

  @override
  State<History> createState() => _History();
}

class _History extends State<History> {
  final int _selectedIndex = 3;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, widget.title),
      drawer: myDrawer(context, _selectedIndex),
      body: const Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is history page.',
            ),
          ],
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.favorite),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
