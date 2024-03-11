import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'searchdata.g.dart';
// Database and Provider for Search history
@riverpod
class SearchNotifier extends _$SearchNotifier {
  final _myBox = Hive.box('mybox');
  SearchDataBase db = SearchDataBase();
  @override
  List build() {
    db.loadData();
    db.updateData();
    return List.from(db.searchwords);
  }

  void addData(value) {
    db.addData(value);
    db.updateData();
    state = List.from(db.searchwords);
  }

  void removeData(value) {
    db.searchwords.remove(value);
    db.updateData();
    state = db.searchwords;
  }
}


class SearchDataBase {
  List searchwords = [];
  // ref the box
  final _myBox = Hive.box('mybox');

  // load the data from database
  void loadData() {
    searchwords = _myBox.get('SEARCH') ?? [''];
  }

  // new search histroy adding
  void addData(value) {
    // ダブりは消す
    if (searchwords.contains(value)) {
      searchwords.remove(value);
    }
    // 追加
    searchwords.add(value);
    // 長くなったら消す
    if (searchwords.length > 10) {
      searchwords.removeAt(0);
    }
  }

  // data updated
  void updateData() {
    // データベースをアプデ
    _myBox.put('SEARCH', searchwords);
  }
}
