import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart' as app_exceptions;
import 'auth_interceptor.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorage _storage;
  final Connectivity _connectivity;
  final void Function() _onSessionExpired;

  Dio get dio => _dio;

  DioClient({
    required SecureStorage storage,
    required Connectivity connectivity,
    required void Function() onSessionExpired,
  })  : _storage = storage,
        _connectivity = connectivity,
        _onSessionExpired = onSessionExpired {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        storage: _storage,
        dio: Dio(BaseOptions(
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        )),
        onSessionExpired: _onSessionExpired,
      ),
      _SnakeToCamelInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      throw const app_exceptions.NoInternetException();
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.put<T>(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  app_exceptions.ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const app_exceptions.TimeoutException();
      case DioExceptionType.connectionError:
        return const app_exceptions.NoInternetException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = data is Map ? data['message'] as String? : null;

        switch (statusCode) {
          case 401:
            return const app_exceptions.UnauthorizedException();
          case 404:
            return app_exceptions.NotFoundException(message: message);
          case 422:
            return app_exceptions.ValidationException(
              message: message,
              errors: data is Map
                  ? data['errors'] as Map<String, dynamic>?
                  : null,
            );
          default:
            return app_exceptions.ApiException(
              message: message ?? 'Something went wrong',
              statusCode: statusCode,
              data: data,
            );
        }
      default:
        return app_exceptions.ApiException(
          message: e.message ?? 'An unexpected error occurred',
        );
    }
  }
}

class _SnakeToCamelInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null) {
      response.data = _convertKeys(response.data);
    }
    handler.next(response);
  }

  static dynamic _convertKeys(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(_snakeToCamel(key), _convertKeys(value)));
    } else if (data is List) {
      return data.map(_convertKeys).toList();
    }
    return data;
  }

  static String _snakeToCamel(String s) {
    if (!s.contains('_')) return s;
    final parts = s.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return s;
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now();
    options.extra['_startTime'] = timestamp.millisecondsSinceEpoch;
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['_startTime'] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;
    debugPrint(
      '← ${response.statusCode} ${response.requestOptions.uri} (${duration}ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✕ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.uri}: ${err.message}',
    );
    if (err.response?.data != null) {
      debugPrint('  ↳ body: ${err.response?.data}');
    }
    if (err.requestOptions.data != null) {
      debugPrint('  ↳ sent: ${err.requestOptions.data}');
    }
    handler.next(err);
  }
}
