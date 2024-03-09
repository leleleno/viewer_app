import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class FavoriteNotifier extends _$FavoriteNotifier {
  // {card name: url}
  @override
  Map<String, String> build() {
    return {};
  }

  void addFavorite(String name, String url) {
    state[name] = url;
  }

  void removeFavorite(String name) {
    state.remove(name);
  }
}
class Favorite extends ConsumerWidget {
  const Favorite({super.key});

  final String title = "Favorite";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteNotifierProvider);
    List<Widget> bodyList = [];
    if (favorites.isNotEmpty){
      favorites.forEach((key, value) {
        bodyList.insert(0,CardTile(title: key, url: value));
      });} else {
        bodyList.add(const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Text("There is no favorite data.")),
        ));
      }
    return CommonScaffold(
      title: title,
      index: 2,
      body: Column(children: bodyList,),
    );
  }
}
