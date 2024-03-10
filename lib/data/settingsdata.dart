import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settingsdata.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  final _myBox = Hive.box('mybox');
  SettingsDataBase db = SettingsDataBase();
  @override
  Map build() {
    db.loadData();
    db.updatedData();
    return {...db.settings};
  }

  void changeData(key, value) {
    db.settings[key] = value;
    db.updatedData();
    state = {...db.settings};
  }
}

class SettingsDataBase {
  final _myBox = Hive.box('mybox');
  Map settings = {};

  // load data from database
  // 空なら初期設定を読み込む
  void loadData() {
    settings = _myBox.get('SETTINGS') ?? {'isDark': false};
  }

  // settings updatet
  void updatedData() {
    _myBox.put('SETTINGS', settings);
  }
}
