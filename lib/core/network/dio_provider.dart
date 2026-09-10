import 'package:dio/dio.dart';
import 'package:liaison_app/core/config/app_config_provider.dart';
import 'package:liaison_app/core/config/flavor.dart';
import 'package:liaison_app/core/network/auth_interceptor.dart';
import 'package:liaison_app/core/storage/token_storage_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// 앱 전체가 공유하는 HTTP 클라이언트.
@riverpod
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref.watch(tokenStorageProvider)));
  if (config.flavor == Flavor.dev) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  return dio;
}
