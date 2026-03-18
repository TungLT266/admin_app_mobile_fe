import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Kết nối hết thời gian, vui lòng thử lại',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Không thể kết nối đến máy chủ',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        String msg = 'Đã xảy ra lỗi';
        if (data is Map) {
          msg = data['message']?.toString() ??
              data['error']?.toString() ??
              msg;
        }
        return ApiException(
          message: msg,
          statusCode: e.response?.statusCode,
        );
      default:
        return ApiException(message: 'Đã xảy ra lỗi không xác định');
    }
  }

  @override
  String toString() => message;
}
