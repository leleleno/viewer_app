import 'package:first_app/data/settingsdata.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
// @riverpod
// class IsDarkNotifier extends _$IsDarkNotifier {
//   @override
//   bool build() {
//     return false;
//   }

//   // 状態変更関数
//   void updateState(bool value) {
//     state = value;
//   }
// }

class Settings extends ConsumerWidget {
  const Settings({super.key});

  final String title = "設定";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // // ref box
    // final _myBox = Hive.box('mybox');
    // // settings 開く
    // SettingsDataBase db = SettingsDataBase();
    // db.loadData();
    final settings = ref.watch(settingsNotifierProvider);
    const int selectedIndex = 4;
    return CommonScaffold(
      title: title,
      index: selectedIndex,
      body: Column(
        children: <Widget>[
          Card(
            child: SwitchListTile(
              title: const Text("ダークモード"),
              value: settings['isDark'],
              onChanged: (bool value) {
                final notifier = ref.read(settingsNotifierProvider.notifier);
                notifier.changeData('isDark', value);
              },
              subtitle: const Text("この設定いる？"),
            ),
          ),
        ],
      ),
    );
  }
}
