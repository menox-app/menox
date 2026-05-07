import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core/core/config/app_config.dart';
import 'package:flutter_core/core/storage/local_storage.dart';

class DioFactory {
  static const String _retryKey = '_retry';

  static late DioFactory _instance;
  static DioFactory get instance => _instance;
  static bool _initialized = false;

  final String apiBaseUrl;
  final LocalStorage _localStorage;
  final HttpClientAdapter? _httpClientAdapter;

  static VoidCallback? onAuthFailure;

  late final Dio _refreshDio;
  Future<String>? _refreshTokenFuture;

  DioFactory._({
    required this.apiBaseUrl,
    required LocalStorage localStorage,
    HttpClientAdapter? httpClientAdapter,
  }) : _localStorage = localStorage,
       _httpClientAdapter = httpClientAdapter {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: '$apiBaseUrl/auth',
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      ),
    );
    final httpClientAdapter = _httpClientAdapter;
    if (httpClientAdapter != null) {
      _refreshDio.httpClientAdapter = httpClientAdapter;
    }
    _refreshDio.interceptors.addAll([
      if (kDebugMode) _debugLogInterceptor(),
      _responseInterceptor(),
    ]);
  }

  static void initialize({
    required String apiBaseUrl,
    required LocalStorage localStorage,
    HttpClientAdapter? httpClientAdapter,
  }) {
    if (_initialized) return;
    _instance = DioFactory._(
      apiBaseUrl: apiBaseUrl,
      localStorage: localStorage,
      httpClientAdapter: httpClientAdapter,
    );
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  Dio create(String resource) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '$apiBaseUrl/$resource',
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      ),
    );
    final httpClientAdapter = _httpClientAdapter;
    if (httpClientAdapter != null) {
      dio.httpClientAdapter = httpClientAdapter;
    }

    dio.interceptors.addAll([
      _authInterceptor(dio),
      if (kDebugMode) _debugLogInterceptor(),
      _responseInterceptor(),
    ]);

    return dio;
  }

  LocalStorage get localStorage => _localStorage;

  QueuedInterceptorsWrapper _authInterceptor(Dio dio) {
    return QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _localStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        final requestOptions = error.requestOptions;
        if (requestOptions.extra[_retryKey] == true) {
          return handler.next(error);
        }

        try {
          final currentToken = _localStorage.getToken();
          final requestToken = requestOptions.headers['Authorization'];
          if (currentToken != null && requestToken != 'Bearer $currentToken') {
            final retry = await _retryRequest(
              dio,
              requestOptions,
              currentToken,
            );
            return handler.resolve(retry);
          }

          final newToken = await _refreshAccessToken();
          final retry = await _retryRequest(dio, requestOptions, newToken);
          return handler.resolve(retry);
        } catch (_) {
          await _localStorage.clearAll();
          onAuthFailure?.call();
          return handler.reject(error);
        }
      },
    );
  }

  Future<String> _refreshAccessToken() {
    final inFlight = _refreshTokenFuture;
    if (inFlight != null) return inFlight;

    final future = _performRefreshToken();
    _refreshTokenFuture = future;
    return future.whenComplete(() {
      if (identical(_refreshTokenFuture, future)) {
        _refreshTokenFuture = null;
      }
    });
  }

  Future<String> _performRefreshToken() async {
    final refreshToken = _localStorage.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');

    final res = await _refreshDio.post(
      '/refresh',
      data: {'refresh_token': refreshToken},
    );

    final responseData = _asMap(res.data);
    final data = _asMap(responseData['data']);
    final newToken = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String?;

    if (newToken == null || newRefresh == null) {
      throw StateError('Refresh response missing tokens');
    }

    await _localStorage.saveTokens(
      accessToken: newToken,
      refreshToken: newRefresh,
    );

    return newToken;
  }

  Future<Response<dynamic>> _retryRequest(
    Dio dio,
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final headers = Map<String, dynamic>.from(requestOptions.headers)
      ..['Authorization'] = 'Bearer $accessToken';
    final extra = Map<String, dynamic>.from(requestOptions.extra)
      ..[_retryKey] = true;

    final retryOptions = requestOptions.copyWith(
      data: _cloneDataForRetry(requestOptions.data),
      headers: headers,
      extra: extra,
    );
    final retryDio = Dio(dio.options)
      ..httpClientAdapter = dio.httpClientAdapter;
    retryDio.interceptors.addAll([
      if (kDebugMode) _debugLogInterceptor(),
      _responseInterceptor(),
    ]);

    return retryDio.fetch<dynamic>(retryOptions);
  }

  dynamic _cloneDataForRetry(dynamic data) {
    if (data is FormData) return data.clone();
    return data;
  }

  InterceptorsWrapper _debugLogInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[DIO] --> ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '[DIO] <-- ${response.statusCode} '
          '${response.requestOptions.method} ${response.requestOptions.uri}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
          '[DIO] !! ${error.response?.statusCode ?? error.type} '
          '${error.requestOptions.method} ${error.requestOptions.uri} '
          '${error.message}',
        );
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _responseInterceptor() {
    return InterceptorsWrapper(
      onResponse: (response, handler) {
        final rawData = response.data;

        if (rawData == null) return handler.next(response);

        if (rawData is Map<String, dynamic>) {
          if (!rawData.containsKey('data')) {
            response.data = {'data': rawData};
          }
        } else if (rawData is List) {
          response.data = {'data': rawData};
        } else {
          response.data = {'data': rawData};
        }

        return handler.next(response);
      },
      onError: (DioException error, handler) {
        String message = 'Unknown error';
        if (error.response?.data != null) {
          final errorData = error.response!.data;

          if (errorData is Map) {
            final rawMessage = errorData['message'];

            if (rawMessage is String) {
              message = rawMessage;
            } else if (rawMessage is List) {
              message = rawMessage.join(' ');
            } else if (rawMessage != null) {
              message = rawMessage.toString();
            } else {
              message = error.message ?? 'Unknown error';
            }
          } else {
            message = errorData.toString();
          }
        } else {
          message = error.message ?? 'Unknown error';
        }

        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: message,
            type: error.type,
          ),
        );
      },
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}
