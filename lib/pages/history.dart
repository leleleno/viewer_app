import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _History();
}

class _History extends State<History> {
  @override
  Widget build(BuildContext context) {
    const String title = "History";
    const int selectedIndex = 3;
    return const CommonScaffold(
      title: title,
      index: selectedIndex,
      body: Center(
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
    );
  }
}
