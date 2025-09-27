import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final bool isInactiveAccount;
  final ApiErrorType errorType;

  ApiException(this.message, {this.statusCode, this.data, this.isInactiveAccount = false, this.errorType = ApiErrorType.unknown});

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';

  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isNetworkError => errorType == ApiErrorType.network;
  bool get isTimeoutError => errorType == ApiErrorType.timeout;
}

enum ApiErrorType {
  server,
  client,
  network,
  timeout,
  unknown,
}

ApiException handleDioError(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return ApiException(
      'Connection timed out. Please check your internet connection.',
      errorType: ApiErrorType.timeout,
    );
  } else if (error.type == DioExceptionType.badResponse) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'Something went wrong';
    ApiErrorType errorType = ApiErrorType.unknown;

    if (data is Map && data['message'] != null) {
      message = data['message'];
    } else if (statusCode != null) {
      if (statusCode >= 500) {
        message = '$message.Please try again later.';
        errorType = ApiErrorType.server;
      } else if (statusCode >= 400) {
        message = 'Request failed. Please check your input.';
        errorType = ApiErrorType.client;
      }
    }

    return ApiException(
      message,
      statusCode: statusCode,
      data: data,
      errorType: errorType,
    );
  } else if (error.type == DioExceptionType.unknown) {
    return ApiException(
      'No internet connection. Please check your network.',
      errorType: ApiErrorType.network,
    );
  }

  return ApiException(
    'Unexpected error: ${error.message}',
    errorType: ApiErrorType.unknown,
  );
}
