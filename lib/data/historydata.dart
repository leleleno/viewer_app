import 'package:hive_flutter/hive_flutter.dart';

class HistroyData {
  late Box<Map<String, String>> _historyBox;

  // Constructor
  HistroyData() {
    _init();
  }

  // ボックスの初期化
  Future<void> _init() async {
    // ボックスを開く
    _historyBox = await Hive.openBox<Map<String, String>>('history');
  }

  // データの読み込み
  Future<Map<String, String>> loadData() async {
    await _init(); // ボックスがまだ開かれていない場合は開く
    return _historyBox.get('history') ?? {};
  }

  // データの更新
  Future<void> updateData(Map<String, String> newData) async {
    await _init(); // ボックスがまだ開かれていない場合は開く
    await _historyBox.put('history', newData);
  }
}
