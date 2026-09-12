/// 앱 전체에서 쓰는 예외. 화면은 이 타입만 본다.
///
/// 세분화는 실제 화면이 구분해서 보여줘야 할 때 추가한다.
sealed class AppException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => switch (this) {
    NetworkException() => 'NetworkException: $message',
    UnauthorizedException() => 'UnauthorizedException: $message',
    ServerException() => 'ServerException: $message',
    UnknownException(:final debugMessage) =>
      debugMessage == null
          ? 'UnknownException: $message'
          : 'UnknownException: $message ($debugMessage)',
  };
}

/// 네트워크 연결 실패, 타임아웃.
final class NetworkException extends AppException {
  const new() : super('네트워크에 연결할 수 없습니다');
}

/// 인증 만료 또는 미인증 (HTTP 401).
final class UnauthorizedException extends AppException {
  const new() : super('다시 로그인해 주세요');
}

/// 서버가 에러 상태 코드로 응답.
final class ServerException extends AppException {
  const new({required this.statusCode}) : super('서버 오류가 발생했습니다 ($statusCode)');

  final int statusCode;
}

/// 분류되지 않은 오류. 사용자에게는 고정 문구만 보여주고,
/// 기술적인 원인은 [debugMessage]에 담아 로그에서만 쓴다.
final class UnknownException extends AppException {
  const new({this.debugMessage}) : super('알 수 없는 오류가 발생했습니다');

  final String? debugMessage;
}
