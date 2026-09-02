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
  bool _sessionExpired = false;
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

  /// Reset the expired flag when a new session starts (e.g. after login).
  void resetSessionState() {
    _sessionExpired = false;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // If session is already marked expired, reject immediately — don't retry
    if (_sessionExpired) {
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

    // ── Step 1: Refresh the token ──
    String newAccessToken;
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

      final accessToken = response.data['data']?['accessToken'] as String?;
      final newRefreshToken =
          response.data['data']?['refreshToken'] as String?;

      if (accessToken == null) {
        throw Exception('No access token in refresh response');
      }

      newAccessToken = accessToken;
      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      _pendingRequests.clear();
      _isRefreshing = false;
      _sessionExpired = true;
      await _storage.clearTokens();
      _onSessionExpired();
      return handler.next(err);
    }

    // ── Step 2: Retry queued requests (refresh succeeded) ──
    // Failures here must NOT expire the session — the tokens are valid.
    for (final pending in _pendingRequests) {
      try {
        final r = await _retryRequest(pending.requestOptions, newAccessToken);
        pending.completer.complete(r);
      } catch (e) {
        pending.completer.completeError(e);
      }
    }
    _pendingRequests.clear();
    _isRefreshing = false;

    // Retry the original request
    try {
      final retryResponse =
          await _retryRequest(err.requestOptions, newAccessToken);
      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('Retry after refresh failed (token is still valid): $e');
      return handler.next(err);
    }
  }

  /// Retry a request with a new access token.
  /// FormData is single-use (stream-based), so requests that carried FormData
  /// cannot be transparently retried — throw so callers surface the original
  /// error instead of crashing with "FormData already finalized".
  Future<Response> _retryRequest(
    RequestOptions options,
    String accessToken,
  ) {
    if (options.data is FormData) {
      return Future.error(
        DioException(
          requestOptions: options,
          message:
              'Cannot retry a FormData request after token refresh. '
              'Please retry the upload.',
        ),
      );
    }
    options.headers['Authorization'] = 'Bearer $accessToken';
    return _dio.fetch(options);
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
