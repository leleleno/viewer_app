import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  final String title = "HOME";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = 0;
    return CommonScaffold(
      title: title,
      index: selectedIndex,
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
    );
  }
}
