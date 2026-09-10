import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/network/auth_interceptor.dart';
import 'package:liaison_app/core/storage/token_storage.dart';

void main() {
  group('AuthInterceptor', () {
    test('토큰이 있으면 Authorization 헤더를 붙인다', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeAccessToken('abc123');
      final interceptor = AuthInterceptor(storage);
      final options = RequestOptions(path: '/me');

      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer abc123');
    });

    test('토큰이 없으면 헤더를 붙이지 않는다', () async {
      final interceptor = AuthInterceptor(InMemoryTokenStorage());
      final options = RequestOptions(path: '/me');

      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('InMemoryTokenStorage', () {
    test('clear 후에는 null을 돌려준다', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeAccessToken('t');
      await storage.clear();

      expect(await storage.readAccessToken(), isNull);
    });
  });
}
