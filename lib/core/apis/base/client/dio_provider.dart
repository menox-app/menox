import 'package:dio/dio.dart';
import 'package:flutter_core/core/config/app_config.dart';
import 'package:flutter_core/core/config/flavor_config.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final flavorConfig = ref.watch(flavorConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: "${flavorConfig.baseUrl}/api/v1",
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    ),
  );

  final localStorage = ref.watch(localStorageProvider);

  dio.interceptors.addAll([
    // Auth Interceptor
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = localStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
    // Response/Error Interceptor (from previous BaseApiClient)
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final rawData = response.data;
        // Wrap Map if 'data' key is missing
        if (rawData is Map<String, dynamic> && !rawData.containsKey('data')) {
          response.data = {'data': rawData};
        }
        // Wrap List into 'data' key for consistency with BaseResponse
        if (rawData is List) {
          response.data = {'data': rawData};
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        String message = 'Unknown error';
        if (error.response?.data != null) {
          final errorData = error.response!.data;
          final rawMessage = errorData['message'];

          if (rawMessage is String) {
            message = rawMessage;
          } else if (rawMessage is List) {
            message = rawMessage.join(' ');
          } else {
            message = rawMessage.toString();
          }
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
    ),
  ]);

  return dio;
});
