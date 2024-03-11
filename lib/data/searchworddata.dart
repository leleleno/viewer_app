import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'searchworddata.g.dart';

//flutter pub run build_runner build --delete-conflicting-outputs
@riverpod
class SearchWordNotifier extends _$SearchWordNotifier{
  @override
  String build() {
    return '';
  }
  void newSearch(String value){
    state = value;
  }
}