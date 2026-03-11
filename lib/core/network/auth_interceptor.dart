import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../network/api_endpoints.dart';
import '../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;
  final void Function() _onSessionExpired;

  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  AuthInterceptor({
    required SecureStorage storage,
    required Dio dio,
    required void Function() onSessionExpired,
  })  : _storage = storage,
        _dio = dio,
        _onSessionExpired = onSessionExpired;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestPath = err.requestOptions.path;
    if (requestPath.contains(ApiEndpoints.authRefresh) ||
        requestPath.contains(ApiEndpoints.authGoogle)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(_RetryRequest(
        requestOptions: err.requestOptions,
        completer: completer,
      ));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token');
      }

      final response = await _dio.post(
        '${AppConfig.baseUrl}${ApiEndpoints.authRefresh}',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final newAccessToken = response.data['data']?['accessToken'] as String?;
      final newRefreshToken = response.data['data']?['refreshToken'] as String?;

      if (newAccessToken == null) {
        throw Exception('No access token in refresh response');
      }

      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      // Retry original request
      final retryResponse = await _dio.fetch(
        err.requestOptions..headers['Authorization'] = 'Bearer $newAccessToken',
      );

      // Retry pending requests
      for (final pending in _pendingRequests) {
        try {
          final r = await _dio.fetch(
            pending.requestOptions
              ..headers['Authorization'] = 'Bearer $newAccessToken',
          );
          pending.completer.complete(r);
        } catch (e) {
          pending.completer.completeError(e);
        }
      }

      _pendingRequests.clear();
      _isRefreshing = false;

      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      _pendingRequests.clear();
      _isRefreshing = false;
      await _storage.clearTokens();
      _onSessionExpired();
      return handler.next(err);
    }
  }
}

class _RetryRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _RetryRequest({
    required this.requestOptions,
    required this.completer,
  });
}
