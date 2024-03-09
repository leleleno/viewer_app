import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  // {card name: url}
  @override
  Map<String, String> build() {
    return {};
  }
  void updateHistory(String title, String url){
    if (state.containsKey(title)){
      // 一度消して再追加することで最後尾に持っていく
      state.remove(title);
    }
    state[title]  = url;
    if (state.length > 100){
      state.remove(state.keys.first);
    }
  }
}
class History extends ConsumerWidget {
  const History({super.key});
  final String title = "History";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historyNotifierProvider);
    List<Widget> bodyList = [];
    if (histories.isNotEmpty){
      histories.forEach((key, value) {
        bodyList.insert(0, CardTile(title: key, url: value));
      });} else{
        bodyList.add(const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Text("There is no history data.")),
        ));
      }
    return CommonScaffold(
      title: title,
      index: 3,
      body: Column(
        children: bodyList
      ),
    );
  }
}
