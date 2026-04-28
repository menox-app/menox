import 'package:dio/dio.dart';

/// Base class cho tất cả API clients.
/// Giữ reference tới Dio instance đã được DioFactory config sẵn.
class BaseApiClient {
  final Dio client;

  BaseApiClient(this.client);
}
