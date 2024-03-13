import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'searchsettingsdata.g.dart';
// Database and Provider for Search history
@riverpod
class SearchSettingsNotifier extends _$SearchSettingsNotifier {
  final _myBox = Hive.box('mybox');
  SearchSettingsDataBase db = SearchSettingsDataBase();
  @override
  Map build() {
    db.loadData();
    return {...db.searchSettings};
  }
  void changeSettings(key, value){
    db.changeSettings(key, value);
    db.updateData();
    state = {...db.searchSettings};
  }
}


class SearchSettingsDataBase {
  Map searchSettings = {};
  // ref the box
  final _myBox = Hive.box('mybox');

  // load the data from database
  void loadData() {
    searchSettings = _myBox.get('SEARCHSETTINGS')
      ?? {
        "mode": "AND",
        "cardTarget": true,
        "deckTarget": false,
        "articleTarget": false,
        "commentTarget": false,
      };
  }

  // new search histroy adding
  void changeSettings(key, value) {
    searchSettings[key] = value;
  }

  // data updated
  void updateData() {
    // データベースをアプデ
    _myBox.put('SEARCHSETTINGS', searchSettings);
  }
}
