import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

ApiException handleDioError(DioError error) {
  if (error.type == DioErrorType.connectionTimeout ||
      error.type == DioErrorType.receiveTimeout ||
      error.type == DioErrorType.sendTimeout) {
    return ApiException('Connection timed out. Please check your internet.');
  } else if (error.type == DioErrorType.badResponse) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'Something went wrong';
    if (data is Map && data['message'] != null) {
      message = data['message'];
    } else if (statusCode != null) {
      message = 'Server error ($statusCode)';
    }

    return ApiException(message, statusCode: statusCode, data: data);
  } else if (error.type == DioErrorType.unknown) {
    return ApiException('No internet connection.');
  }

  return ApiException('Unexpected error: ${error.message}');
}
