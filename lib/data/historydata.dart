import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'historydata.g.dart';

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  final _myBox = Hive.box('mybox');
  HistoryDataBase db = HistoryDataBase();
  @override
  Map build() {
    db.loadData();
    db.updateData();
    return {...db.histories};
  }

  void addData(key, value) {
    db.addData(key, value);
    db.updateData();
    state = {...db.histories};
  }

  void removeData(key) {
    db.histories.remove(key);
    db.updateData();
    state = {...db.histories};
  }
}

class HistoryDataBase {
  Map histories = {};
  // ref the box
  final _myBox = Hive.box('mybox');

  // load the data from database
  void loadData() {
    histories = _myBox.get('HISTORY') ?? {};
  }

  // new histroy adding
  void addData(key, value) {
    if (histories.containsKey(key)) {
      histories.remove(key);
    }
    histories[key] = value;
    if (histories.length > 150) {
      histories.remove(histories.keys.first);
    }
  }

  // data updated
  void updateData() {
    _myBox.put('HISTORY', histories);
  }
}
