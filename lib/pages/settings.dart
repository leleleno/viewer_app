import 'package:first_app/data/settingsdata.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
              title: const Text("外部リンク確認"),
              subtitle: const Text("外部リンクを開く前に警告します"),
              value: settings['checkLink'],
              onChanged: (bool value) {
                final notifier = ref.read(settingsNotifierProvider.notifier);
                notifier.changeData('checkLink', value);
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text("アップデート"),
              subtitle: const Text("起動時に自動でアップデートを確認"),
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text("ダークモード"),
              subtitle: const Text("ダークモードがお好きなら"),
              value: settings['isDark'],
              onChanged: (bool value) {
                final notifier = ref.read(settingsNotifierProvider.notifier);
                notifier.changeData('isDark', value);
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('アップデートを確認'),
              subtitle: const Text(''),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
