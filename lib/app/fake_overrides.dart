import 'package:riverpod_annotation/riverpod_annotation.dart';

/// 서버 없이 앱을 띄울 때 적용하는 override 목록.
///
/// 각 feature는 `<feature>_di.dart`에 자기 가짜 override 목록을 두고,
/// 여기서 그것들을 모은다. 새 feature를 만들면 이 목록에 추가한다.
List<Override> fakeOverrides() {
  return [];
}
