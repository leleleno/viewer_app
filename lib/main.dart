import 'package:first_app/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My first app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
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
