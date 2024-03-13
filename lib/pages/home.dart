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

  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 一度ダイアログを表示したかチェック
    SharedPreferences.getInstance().then((prefs) {
      _dialogShown = prefs.getBool('dialogShown') ?? false;
    });
    // updatableかチェック
    // GithubのAPIから最新のリリース情報を取得
    http.get(Uri.parse('https://api.github.com/repos/leleleno/viewer_app/releases/latest'))
        .then((response) {
      // 通信成功時
      if (response.statusCode == 200) {
        // json decode
        final Map<String, dynamic> body = jsonDecode(response.body);
        final latestRelease = body['tag_name'];
        // 現在のバージョン・ビルドナンバーを取得
        PackageInfo.fromPlatform().then((packageInfo) {
          String version = packageInfo.version;
          // version: 1.0.0, latestRelease: v1.0.0
          bool updatable = RegExp(version).hasMatch(latestRelease);
          if (!_dialogShown && updatable){
            showDialog(
              context: context,
              builder: (context)=> AlertDialog(
                title: const Text("アップデートがあります", style: TextStyle(fontSize: 18),),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: const Text("キャンセル", style: TextStyle(color: Colors.red),),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: const Text("インストール", style: TextStyle(color: Colors.blue),),
                  ),
                ],
              )
            );
            // どちらにしろいちど起動したことは記録しておく
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('dialogShown', true);
            });
          }
        });
      }
    });
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

