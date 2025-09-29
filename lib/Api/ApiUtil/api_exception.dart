import 'package:dio/dio.dart';

enum ApiErrorType {
  server,
  client,
  network,
  timeout,
  authentication,
  authorization,
  notFound,
  unknown,
  validation,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final bool isInactiveAccount;
  final ApiErrorType errorType;

  ApiException(
      this.message, {
        this.statusCode,
        this.data,
        this.isInactiveAccount = false,
        this.errorType = ApiErrorType.unknown,
      });

  @override
  String toString() => message;

  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isNetworkError => errorType == ApiErrorType.network;
  bool get isTimeoutError => errorType == ApiErrorType.timeout;
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

    if (data is Map) {
      // Detect validation errors - typical HTTP 422 or 'errors' key in response
      if (statusCode == 422 || data['errors'] != null) {
        if (data['message'] != null) {
          message = data['message']; // General validation message from API
        } else {
          message = 'Validation failed. Please check your input.';
        }
        errorType = ApiErrorType.validation;
      } else if (data['message'] != null) {
        message = data['message'];
      }
    }

    if (statusCode != null) {
      if (statusCode == 401) {
        message = 'Authentication failed. Please login again.';
        errorType = ApiErrorType.authentication;
      } else if (statusCode == 403) {
        message = 'You do not have permission to perform this action.';
        errorType = ApiErrorType.authorization;
      } else if (statusCode == 404) {
        message = 'Requested resource not found.';
        errorType = ApiErrorType.notFound;
      } else if (statusCode >= 500) {
        message = 'Server error occurred. Please try again later.';
        errorType = ApiErrorType.server;
      } else if (statusCode >= 400 && errorType != ApiErrorType.validation) {
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
    '${error.message}',
    errorType: ApiErrorType.unknown,
  );
}
