import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/base/client/client.dart';
import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

/// Base CRUD client — KHÔNG còn resourcePath.
/// Dio.baseUrl đã chứa resource path (vd: /api/v1/auth).
/// Tất cả methods dùng relative path: '', '/{id}', '/slug/{slug}'.
abstract class BaseCrudApiClient<T extends BaseRecord> extends BaseApiClient {
  BaseCrudApiClient(super.client);

  // Bắt buộc lớp con triển khai để parse JSON sang T
  T fromJson(Map<String, dynamic> json);

  Future<BaseResponse<T>> create(BaseCreateRequest<T> request) async {
    final response = await client.post('', data: serialize(request.body));
    return mapToResponse(response);
  }

  Future<BasePaginationResponse<T>> getAll(
    BasePaginationRequest request,
  ) async {
    final response = await client.get('', queryParameters: request.params);

    final List<dynamic> list = response.data['data'];
    return BasePaginationResponse<T>(
      data: list.map((e) => fromJson(e)).toList(),
      status: response.data['status'] ?? 'success',
      statusCode: response.statusCode ?? 200,
      pagination: PaginationInfo.fromJson(response.data['pagination']),
    );
  }

  Future<BaseResponse<T>> getById(BaseGetByIdRequest request) async {
    final response = await client.get('/${request.pathParams?['id']}');
    return mapToResponse(response);
  }

  Future<BaseResponse<T>> getBySlug(BaseGetBySlugRequest request) async {
    final response = await client.get('/slug/${request.pathParams?['slug']}');
    return mapToResponse(response);
  }

  Future<BaseResponse<T>> update(BaseUpdateRequest<T> request) async {
    final response = await client.put(
      '/${request.pathParams?['id']}',
      data: serialize(request.body),
    );
    return mapToResponse(response);
  }

  Future<BaseResponse<void>> delete(BaseDeleteRequest request) async {
    final response = await client.delete('/${request.pathParams?['id']}');
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
    final responseData = response.data;
    final Map<String, dynamic> dataMap = responseData is Map<String, dynamic>
        ? responseData
        : {'data': responseData};

    return BaseResponse<R>(
      data: mapper(dataMap['data'] is Map<String, dynamic>
          ? dataMap['data']
          : (dataMap['data'] ?? {})),
      status: dataMap['status'] ?? 'success',
      message: dataMap['message'],
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
