import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/core/error/dio_exception_mapper.dart';

DioException _dio(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response<void>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('mapDioException', () {
    test('타임아웃과 연결 실패는 NetworkException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(mapDioException(_dio(type)), isA<NetworkException>());
      }
    });

    test('401 응답은 UnauthorizedException', () {
      final result = mapDioException(
        _dio(DioExceptionType.badResponse, status: 401),
      );
      expect(result, isA<UnauthorizedException>());
    });

    test('그 외 에러 응답은 상태 코드를 담은 ServerException', () {
      final result = mapDioException(
        _dio(DioExceptionType.badResponse, status: 500),
      );
      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 500);
    });

    test('취소·인증서·알 수 없음은 UnknownException', () {
      for (final type in [
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
        DioExceptionType.unknown,
      ]) {
        expect(mapDioException(_dio(type)), isA<UnknownException>());
      }
    });
  });
}
