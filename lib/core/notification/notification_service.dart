/// 푸시 알림 초기화 지점.
///
/// Firebase 설정 파일과 firebase_messaging 패키지가 들어오면
/// FCM 토큰 등록, 포그라운드 알림 표시를 담당하는 구현체로 교체한다.
abstract interface class NotificationService {
  Future<void> initialize();
}

/// Firebase 연동 전까지 쓰는 빈 구현.
class NoopNotificationService implements NotificationService {
  const new();

  @override
  Future<void> initialize() async {}
}
