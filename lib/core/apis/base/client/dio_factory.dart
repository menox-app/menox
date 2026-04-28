import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_core/core/config/app_config.dart';
import 'package:flutter_core/core/storage/local_storage.dart';

/// Factory tạo Dio instance cho từng resource.
/// Khởi tạo 1 lần trong main.dart, dùng toàn app qua [DioFactory.instance].
///
/// Tương đương YaahCrudApiClient constructor trong TypeScript:
/// - Mỗi resource nhận Dio riêng với baseUrl đã chứa resource path
/// - Interceptors: Auth (+ refresh token), Response unwrap, Error format
class DioFactory {
  static late DioFactory _instance;
  static DioFactory get instance => _instance;
  static bool _initialized = false;

  final String apiBaseUrl;
  final LocalStorage _localStorage;

  /// Callback khi auth thất bại (refresh token fail) → UI redirect login.
  /// AuthNotifier tự đăng ký callback này khi được tạo.
  static VoidCallback? onAuthFailure;

  /// Dio riêng chỉ để gọi refresh token — KHÔNG gắn auth interceptor (tránh loop)
  late final Dio _refreshDio;

  DioFactory._({
    required this.apiBaseUrl,
    required LocalStorage localStorage,
  }) : _localStorage = localStorage {
    _refreshDio = Dio(BaseOptions(
      baseUrl: '$apiBaseUrl/auth',
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    ));
    // Response interceptor cho refresh Dio
    _refreshDio.interceptors.add(_responseInterceptor());
  }

  /// Gọi 1 lần duy nhất khi app khởi động
  static void initialize({
    required String apiBaseUrl,
    required LocalStorage localStorage,
  }) {
    _instance = DioFactory._(
      apiBaseUrl: apiBaseUrl,
      localStorage: localStorage,
    );
    _initialized = true;
  }

  /// Kiểm tra đã khởi tạo chưa
  static bool get isInitialized => _initialized;

  /// Tạo Dio instance cho 1 resource — đã gắn đầy đủ interceptors
  Dio create(String resource) {
    final dio = Dio(BaseOptions(
      baseUrl: '$apiBaseUrl/$resource',
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    ));

    dio.interceptors.addAll([
      _authInterceptor(dio),
      _responseInterceptor(),
    ]);

    return dio;
  }

  /// Getter để các client có thể truy cập localStorage khi cần
  LocalStorage get localStorage => _localStorage;

  // ─────────────────────────────────────────────────────────────
  // Auth Interceptor + Refresh Token (QueuedInterceptor)
  // ─────────────────────────────────────────────────────────────
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
        // Chỉ xử lý 401 Unauthorized
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        // --- Refresh Token Flow ---
        try {
          final refreshToken = _localStorage.getRefreshToken();
          if (refreshToken == null) throw Exception('No refresh token');

          final res = await _refreshDio.post(
            '/refresh',
            data: {'refresh_token': refreshToken},
          );

          final data = res.data['data'];
          final newToken = data['access_token'] as String;
          final newRefresh = data['refresh_token'] as String;

          // Lưu tokens mới
          await _localStorage.saveTokens(
            accessToken: newToken,
            refreshToken: newRefresh,
          );

          // Retry request gốc với token mới
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retry = await dio.fetch(error.requestOptions);
          return handler.resolve(retry);
        } catch (_) {
          // Refresh thất bại → clear tokens + thông báo UI
          await _localStorage.clearAll();
          onAuthFailure?.call();
          return handler.reject(error);
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Response Interceptor: Unwrap & Error Format
  // ─────────────────────────────────────────────────────────────
  InterceptorsWrapper _responseInterceptor() {
    return InterceptorsWrapper(
      onResponse: (response, handler) {
        final rawData = response.data;

        // Null thì skip
        if (rawData == null) return handler.next(response);

        // Wrap Map nếu thiếu key 'data'
        if (rawData is Map<String, dynamic>) {
          if (!rawData.containsKey('data')) {
            response.data = {'data': rawData};
          }
        }
        // Wrap List vào 'data' key
        else if (rawData is List) {
          response.data = {'data': rawData};
        }
        // Wrap các kiểu khác (String, etc.)
        else {
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
}
