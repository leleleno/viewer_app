import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/favorite.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  void updateHistory(String title, String url) {
    if (state.containsKey(title)) {
      // 一度消して再追加することで最後尾に持っていく
      state = {...state}..remove(title);
    }
    state = {...state, title: url};
    if (state.length > 100) {
      state = {...state}..remove(state.keys.first);
    }
  }

  void deleteHistory(String title) {
    state = {...state}..remove(title);
  }
}

class History extends ConsumerWidget {
  const History({super.key});
  final String title = "History";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historyNotifierProvider);
    List<Widget> bodyList = [];
    if (histories.isNotEmpty) {
      histories.forEach((key, value) {
        bodyList.insert(0, HistoryCardTile(title: key, url: value));
      });
    } else {
      bodyList.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text("There is no history data.")),
      ));
    }
    return CommonScaffold(
      title: title,
      index: 3,
      body: Column(children: bodyList),
    );
  }
}

class HistoryCardTile extends HookWidget {
  const HistoryCardTile({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // リンクを開いた時点で履歴を管理できるよう監視
        // ignore: unused_local_variable
        final histories = ref.watch(historyNotifierProvider);
        final favorites = ref.watch(favoriteNotifierProvider);
        return Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  final notifier = ref.watch(historyNotifierProvider.notifier);
                  notifier.deleteHistory(title);
                },
                icon: Icons.delete,
                label: "Delete",
              )
            ],
          ),
          child: Card(
            elevation: 2,
            child: ListTile(
              title: Text(title),
              subtitle: Text(url),
              trailing: favorites.containsKey(title)
                  ? IconButton(
                      onPressed: () {
                        final notifier =
                            ref.read(favoriteNotifierProvider.notifier);
                        notifier.removeFavorite(title);
                      },
                      icon: const Icon(Icons.favorite))
                  : IconButton(
                      onPressed: () {
                        final notifier =
                            ref.read(favoriteNotifierProvider.notifier);
                        notifier.addFavorite(title, url);
                      },
                      icon: const Icon(Icons.favorite_border)),
              onTap: () {
                final notifier = ref.read(historyNotifierProvider.notifier);
                notifier.updateHistory(title, url);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CardView(
                    pageUrl: url,
                    cardName: title,
                  ),
                  settings: RouteSettings(name: "/card/$key"),
                ));
              },
            ),
          ),
        );
      },
    );
  }
}
