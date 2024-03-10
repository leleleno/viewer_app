import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favoritedata.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class FavoriteNotifier extends _$FavoriteNotifier {
  final _myBox = Hive.box('mybox');
  FavoriteDataBase db = FavoriteDataBase();
  @override
  Map build() {
    db.loadData();
    db.updateData();
    return {...db.favorites};
  }

  void addData(key, value) {
    db.addData(key, value);
    db.updateData();
    state = {...db.favorites};
  }

  void removeData(key) {
    db.favorites.remove(key);
    db.updateData();
    state = {...db.favorites};
  }
}

class FavoriteDataBase {
  Map favorites = {};
  // ref the box
  final _myBox = Hive.box('mybox');

  // load the data from database
  void loadData() {
    favorites = _myBox.get('FAVORITE') ?? {};
  }

  // new histroy adding
  void addData(key, value) {
    if (favorites.containsKey(key)) {
      favorites.remove(key);
    }
    favorites[key] = value;
  }

  void removeData(key) {
    favorites.remove(key);
  }

  // data updated
  void updateData() {
    _myBox.put('FAVORITE', favorites);
  }
}
