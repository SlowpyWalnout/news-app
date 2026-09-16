import 'package:dio/dio.dart';
import 'package:news_app/core/resources/failure.dart';

Failure mapDioExceptionToFailure(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure(exception.message ?? 'Network error');
    case DioExceptionType.badResponse:
      return ServerFailure(
        exception.response?.statusMessage ??
            exception.message ??
            'Server error',
      );
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
    default:
      return ServerFailure(exception.message ?? 'Unknown error');
  }
}
