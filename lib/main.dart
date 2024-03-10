import 'package:first_app/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import 'pages/settings.dart';

Future<void> main() async {
  // Hiveの初期化
  await Hive.initFlutter();
  // open the box
  // ignore: unused_local_variable
  var historyBox = await Hive.openBox('history');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkNotifierProvider);
    return MaterialApp(
      title: 'My first app',
      theme: isDark
          // dark mode on
          ? ThemeData.dark()
          // dark mode off
          : ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
              useMaterial3: true,
            ),
      // Homeにあるホーム画面を呼び出す
      home: const Home(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const Home(),
      },
    );
  }
}
