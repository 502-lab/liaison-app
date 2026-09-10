import 'package:dio/dio.dart';
import 'package:liaison_app/core/storage/token_storage.dart';

/// 저장된 액세스 토큰을 모든 요청의 Authorization 헤더에 붙인다.
class AuthInterceptor extends Interceptor {
  new(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
