import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/upload.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

class UploadApiClient extends AppCrudApiClient<Upload> {
  UploadApiClient() : super(resource: "upload");

  @override
  Upload fromJson(Map<String, dynamic> json) => Upload.fromJson(json);

  Future<BaseResponse<Upload>> single(IUploadSingleRequest request) async {
    final response = await client.post(
      "/single",
      data: await request.toFormData(),
      queryParameters: request.params,
    );

    return mapToResponse(response);
  }

  Future<BaseResponse<List<Upload>>> multiple(
    IUploadMultipleRequest request,
  ) async {
    final response = await client.post(
      "/multiple",
      data: await request.toFormData(),
      queryParameters: request.params,
    );

    return _mapToUploadListResponse(response);
  }

  BaseResponse<List<Upload>> _mapToUploadListResponse(Response response) {
    final responseData = response.data;
    final dataMap = _asMap(responseData);
    final data = responseData is List ? responseData : dataMap['data'];
    final list = data is List ? data : [];

    return BaseResponse<List<Upload>>(
      data: list.map(_asMap).map(Upload.fromJson).toList(),
      status:
          dataMap['status'] ??
          (dataMap['success'] == true ? 'success' : 'error'),
      message: dataMap['message'],
      statusCode: response.statusCode ?? 200,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}
