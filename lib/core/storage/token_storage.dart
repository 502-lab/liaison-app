import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 액세스 토큰 저장소. 인증 방식이 확정되면 리프레시 토큰 메서드를 추가한다.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<void> writeAccessToken(String token);
  Future<void> clear();
}

/// 기기 보안 저장소(Keychain / Keystore)에 저장한다.
class SecureTokenStorage implements TokenStorage {
  const new(this._storage);

  static const _accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}

/// 테스트와 가짜 모드에서 쓴다.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<void> writeAccessToken(String token) async => _accessToken = token;

  @override
  Future<void> clear() async => _accessToken = null;
}
