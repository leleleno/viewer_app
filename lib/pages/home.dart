import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  final String title = "ホーム";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonScaffold(
      title: title,
      index: 0,
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("ここはホームページです"),
            ],
          ),
        ),
      ),
    );
  }
}
