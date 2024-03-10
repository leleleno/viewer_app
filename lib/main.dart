import 'package:first_app/data/settingsdata.dart';
import 'package:first_app/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // import追加

Future<void> main() async {
  // Hiveの初期化
  await Hive.initFlutter();
  // open the box
  // ignore: unused_local_variable
  var _myBox = await Hive.openBox('mybox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    bool isDark = settings['isDark'];
    return MaterialApp(
      title: 'My first app',
      theme: isDark
          // dark mode on
          ? ThemeData(
              colorScheme: const ColorScheme.dark(),
              fontFamily: 'Noto Sans Japanese')
          // dark mode off
          : ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
              useMaterial3: true,
              fontFamily: 'Noto Sans Japanese'),
      // ローカライズ　日本語フォント
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ja", "JP"),
      ],
      // Homeにあるホーム画面を呼び出す
      home: const Home(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const Home(),
      },
    );
  }
}
