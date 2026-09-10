import 'package:dio/dio.dart';
import 'package:liaison_app/core/error/app_exception.dart';

/// dio 예외를 [AppException]으로 바꾼다. Repository 구현체에서 호출한다.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      if (status == 401) return const UnauthorizedException();
      return ServerException(statusCode: status ?? -1);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return UnknownException(e.message);
  }
}
