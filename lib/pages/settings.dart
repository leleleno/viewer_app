import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'settings.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class IsDarkNotifier extends _$IsDarkNotifier {
  @override
  bool build() {
    return false;
  }

  void updateState(bool value) {
    state = value;
  }
}

class Settings extends ConsumerWidget {
  const Settings({super.key});

  final String title = "Settings";
  final int _selectedIndex = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // buildの中で状態をwatch
    final isDark = ref.watch(isDarkNotifierProvider);
    return Scaffold(
      appBar: myAppbar(context, title),
      drawer: myDrawer(context, _selectedIndex),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SwitchListTile(
              title: const Text("Dark mode"),
              value: isDark,
              onChanged: (bool value) {
                // イベントに応じて状態をread
                final notifier = ref.read(isDarkNotifierProvider.notifier);
                notifier.updateState(value);
              },
              subtitle: const Text("Change the status if you like dark mode."),
            ),
            const Text(
              'This is Settings page.',
            ),
          ],
        ),
      ),
    );
  }
}
