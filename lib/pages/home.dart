import 'dart:convert';

import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<void> _checkDialogShown() async {
    // 一度ダイアログを表示したかチェック
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dialogShown = prefs.getBool('dialogShown') ?? false;
    // updatableかチェック
    // GithubのAPIから最新のリリース情報を取得
    final response = await http.get(Uri.parse('https://api.github.com/repos/leleleno/viewer_app/releases/latest'));
    // 通信成功時
    if (response.statusCode == 200){
      // json decode
      final Map body = jsonDecode(response.body).map();
      final latestRelease = body['tag_name'];
      // 現在のバージョン・ビルドナンバーを取得
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      // version: 1.0.0, latestRelease: v1.0.0
      bool updatable = RegExp(version).hasMatch(latestRelease);
      if (!dialogShown && updatable) {
        // 非同期処理の完了を待機
        await _checkUpdatable();
      }
    }
    // どちらにしろいちど起動したことは記録しておく
    prefs.setBool('dialogShown', true);
  }

  Future<void> _checkUpdatable() async {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("アップデートがあります"),
        actions: [
          GestureDetector(
            child: const Text("キャンセル"),
            onTap: (){
              Navigator.of(context).pop();
            },
          ),
          GestureDetector(
            child: const Text('アップデート'),
            onTap: (){
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
  }
  @override
  void initState() {
    super.initState();
    _checkDialogShown();
  }

  @override
  Widget build(BuildContext context) {
    return const CommonScaffold(
      title: 'ホーム',
      index: 0,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("ここはホームページです"),
            ],
          ),
        ),
      ),
    );
  }
}
