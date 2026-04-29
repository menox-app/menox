import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/base/client/client.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';
import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';

abstract class BaseCrudApiClient<T extends BaseRecord> extends BaseApiClient {
  BaseCrudApiClient(super.client);

  T fromJson(Map<String, dynamic> json);

  Future<BaseResponse<T>> create(BaseCreateRequest<T> request) async {
    final response = await client.post('', data: serialize(request.body));
    return mapToResponse(response);
  }

  Future<BasePaginationResponse<T>> getAll(
    BasePaginationRequest request,
  ) async {
    final response = await client.get('', queryParameters: request.params);
    return mapToPaginationResponse(response);
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

  BaseResponse<T> mapToResponse(Response response) {
    return mapToCustomResponse<T>(response, fromJson);
  }

  BasePaginationResponse<T> mapToPaginationResponse(Response response) {
    return mapToCustomPaginationResponse<T>(response, fromJson);
  }

  BaseResponse<R> mapToCustomResponse<R>(
    Response response,
    R Function(Map<String, dynamic>) mapper,
  ) {
    final dataMap = _responseDataMap(response.data);

    return BaseResponse<R>(
      data: mapper(
        dataMap['data'] is Map<String, dynamic>
            ? dataMap['data']
            : (dataMap['data'] ?? {}),
      ),
      status: dataMap['status'] ?? 'success',
      message: dataMap['message'],
      statusCode: response.statusCode ?? 200,
    );
  }

  BasePaginationResponse<R> mapToCustomPaginationResponse<R>(
    Response response,
    R Function(Map<String, dynamic>) mapper,
  ) {
    final dataMap = _responseDataMap(response.data);
    final list = dataMap['data'] is List ? dataMap['data'] as List : [];

    return BasePaginationResponse<R>(
      data: list
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(mapper)
          .toList(),
      status: _responseStatus(dataMap),
      message: dataMap['message'],
      statusCode: response.statusCode ?? 200,
      meta: PaginationInfo.fromJson(_asMap(dataMap['meta']) ?? {}),
    );
  }

  dynamic serialize(dynamic body) {
    if (body == null) return null;
    if (body is BaseSerializable) return body.toJson();
    return body;
  }

  Map<String, dynamic> _responseDataMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) return responseData;
    if (responseData is Map) return Map<String, dynamic>.from(responseData);
    return {'data': responseData};
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _responseStatus(Map<String, dynamic> dataMap) {
    return dataMap['status'] ??
        (dataMap['success'] == true ? 'success' : 'error');
  }
}
