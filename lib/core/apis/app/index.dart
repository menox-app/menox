import 'package:flutter_core/core/apis/app/client/auth.dart';
import 'package:flutter_core/core/apis/app/client/post.dart';
import 'package:flutter_core/core/apis/app/client/upload.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
export 'package:flutter_core/core/apis/app/client/post.dart';
export 'package:flutter_core/core/apis/app/client/auth.dart';
export 'package:flutter_core/core/apis/app/client/upload.dart';

/// Sử dụng qua Riverpod:
/// ```dart
/// final api = ref.read(appApiProvider);
/// final me = await api.auth.getMe();
/// ```
class AppApi {
  static late final AppApi _instance;
  static AppApi get instance => _instance;

  final AuthApiClient auth;
  final PostApiClient posts;
  final UploadApiClient upload;

  AppApi._()
    : auth = AuthApiClient(),
      posts = PostApiClient(),
      upload = UploadApiClient();

  /// Gọi 1 lần trong main.dart — khởi tạo DioFactory + AppApi
  static void initialize({
    required String baseUrl,
    required LocalStorage localStorage,
  }) {
    DioFactory.initialize(
      apiBaseUrl: '$baseUrl/api/v1',
      localStorage: localStorage,
    );
    _instance = AppApi._();
  }
}

