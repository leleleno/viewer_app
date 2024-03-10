import 'package:first_app/data/favoritedata.dart';
import 'package:first_app/data/historydata.dart';
import 'package:first_app/pages/card.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
// @riverpod
// class HistoryNotifier extends _$HistoryNotifier {
//   // {card name: url}
//   @override
//   Map<String, String> build() {
//     return {};
//   }

//   void updateHistory(String title, String url) {
//     if (state.containsKey(title)) {
//       // 一度消して再追加することで最後尾に持っていく
//       state = {...state}..remove(title);
//     }
//     state = {...state, title: url};
//     if (state.length > 100) {
//       state = {...state}..remove(state.keys.first);
//     }
//   }

//   void deleteHistory(String title) {
//     state = {...state}..remove(title);
//   }
// }

class History extends HookConsumerWidget {
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

class HistoryCardTile extends StatelessWidget {
  const HistoryCardTile({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // history control
        final histories = ref.watch(historyNotifierProvider);
        // favorite control
        final favorites = ref.watch(favoriteNotifierProvider);
        return Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  final notifier = ref.read(historyNotifierProvider.notifier);
                  notifier.removeData(title);
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
                        notifier.removeData(title);
                      },
                      icon: const Icon(Icons.favorite))
                  : IconButton(
                      onPressed: () {
                        final notifier =
                            ref.read(favoriteNotifierProvider.notifier);
                        notifier.addData(title, url);
                      },
                      icon: const Icon(Icons.favorite_border)),
              onTap: () {
                // 履歴を更新
                final notifier = ref.read(historyNotifierProvider.notifier);
                notifier.addData(title, url);
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
