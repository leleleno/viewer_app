import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'searchdata.g.dart';

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

  void addData(String value) {
    db.addData(value);
    db.updateData();
    state = List.from(db.searchwords);
  }

  void removeData(value) {
    db.searchwords.remove(value);
    db.updateData();
    state = List.from(db.searchwords);
  }
}

class SearchDataBase {
  List searchwords = [];
  // ref the box
  final _myBox = Hive.box('mybox');

  // load the data from database
  void loadData() {
    searchwords = _myBox.get('SEARCH') ?? [];
  }

  // new histroy adding
  void addData(String value) {
    if (searchwords.contains(value)) {
      searchwords.remove(value);
    }
    searchwords.add(value);
    if (searchwords.length > 20) {
      searchwords.removeAt(0);
    }
  }

  // data updated
  void updateData() {
    _myBox.put('SEARCH', searchwords);
  }
}
