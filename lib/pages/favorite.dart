import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Favorite extends ConsumerWidget {
  const Favorite({super.key});

  final String title = "Favorite";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const int selectedIndex = 2;

    final favorites = ref.watch(favoriteNotifierProvider);
    return CommonScaffold(
      title: title,
      index: selectedIndex,
      body: Center(
          // child: Builder(builder: (BuildContext context) {
          //   List<Widget> favList = [];
          //   favorites.forEach(
          //     (key, value) {
          //       favList.add(ListTile(
          //         title: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [Text(key)],
          //         ),
          //       ));
          //     },
          //   );
          //   return ListView(
          //     children: favList,
          //   );
          // }),
          ),
    );
  }
}
