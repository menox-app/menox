import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/base/client/client.dart';
import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

abstract class BaseCrudApiClient<T extends BaseRecord> extends BaseApiClient {
  BaseCrudApiClient(super.client);

  // Hàm này bắt buộc lớp con phải triển khai để parse JSON sang T
  T fromJson(Map<String, dynamic> json);

  // Đường dẫn resource (ví dụ: '/users', '/products')
  String get resourcePath;

  Future<BaseResponse<T>> create(BaseCreateRequest<T> request) async {
    final response = await client.post(resourcePath, data: serialize(request.body));
    return mapToResponse(response);
  }

  Future<BasePaginationResponse<T>> getAll(
    BasePaginationRequest request,
  ) async {
    final response = await client.get(resourcePath, queryParameters: request.params);

    final List<dynamic> list = response.data['data'];
    return BasePaginationResponse<T>(
      data: list.map((e) => fromJson(e)).toList(),
      status: response.data['status'] ?? 'success',
      statusCode: response.statusCode ?? 200,
      pagination: PaginationInfo.fromJson(response.data['pagination']),
    );
  }

  Future<BaseResponse<T>> getById(BaseGetByIdRequest request) async {
    final response = await client.get('$resourcePath/${request.pathParams?['id']}');
    return mapToResponse(response);
  }

  Future<BaseResponse<T>> getBySlug(BaseGetBySlugRequest request) async {
    final response = await client.get('$resourcePath/${request.pathParams?['slug']}');
    return mapToResponse(response);
  }

  Future<BaseResponse<T>> update(BaseUpdateRequest<T> request) async {
    final response = await client.put(
      '$resourcePath/${request.pathParams?['id']}',
      data: serialize(request.body),
    );
    return mapToResponse(response);
  }

  Future<BaseResponse<void>> delete(BaseDeleteRequest request) async {
    final response = await client.delete('$resourcePath/${request.pathParams?['id']}');
    return BaseResponse(
      data: null,
      status: response.data['status'] ?? 'success',
      statusCode: response.statusCode ?? 200,
    );
  }

  // Helper để map dữ liệu trả về từ Dio sang BaseResponse
  BaseResponse<T> mapToResponse(Response response) {
    return mapToCustomResponse<T>(response, fromJson);
  }

  // Helper cho các Custom Method trả về kiểu dữ liệu khác T
  BaseResponse<R> mapToCustomResponse<R>(
    Response response,
    R Function(Map<String, dynamic>) mapper,
  ) {
    return BaseResponse<R>(
      data: mapper(response.data['data']),
      status: response.data['status'] ?? 'success',
      message: response.data['message'],
      statusCode: response.statusCode ?? 200,
    );
  }

  // Helper xử lý body trước khi gửi - Nay đã có BaseSerializable
  dynamic serialize(dynamic body) {
    if (body == null) return null;
    if (body is BaseSerializable) return body.toJson();
    return body;
  }
}
