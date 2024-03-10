import 'package:first_app/data/favoritedata.dart';
import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Favorite extends ConsumerWidget {
  const Favorite({super.key});

  final String title = "お気に入り";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteNotifierProvider);
    List<Widget> bodyList = [];
    if (favorites.isNotEmpty) {
      favorites.forEach((key, value) {
        bodyList.insert(0, CardTile(title: key, url: value));
      });
    } else {
      bodyList.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text("お気に入りはありません")),
      ));
    }
    return CommonScaffold(
      title: title,
      index: 2,
      body: Column(
        children: bodyList,
      ),
    );
  }
}
