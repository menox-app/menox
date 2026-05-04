import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Upload extends BaseRecord<String> {
  final String url;
  final String remoteId;
  final String provider;
  final String? resourceType;
  final num? width;
  final num? height;
  final String? format;
  final String? mediaId;
  final String? publicId;
  final String? type;
  final String? mimeType;
  final num? size;
  final String? folder;
  final Map<String, dynamic>? metadata;

  Upload({
    super.id = 'unknown',
    this.url = '',
    this.remoteId = '',
    this.provider = '',
    this.resourceType,
    this.width,
    this.height,
    this.format,
    this.mediaId,
    this.publicId,
    this.type,
    this.mimeType,
    this.size,
    this.folder,
    this.metadata,
  });

  factory Upload.fromJson(Map<String, dynamic> json) {
    return _$UploadFromJson({
      ...json,
      'id': json['id'] ?? json['_id'] ?? 'unknown',
    });
  }

  @override
  Map<String, dynamic> toJson() => _$UploadToJson(this);
}

class IUploadSingleRequest extends BaseRequest<File> {
  IUploadSingleRequest({required File file, String? folder})
    : super(body: file, params: {if (folder != null) 'folder': folder});

  Future<FormData> toFormData() async {
    return FormData.fromMap({'file': await MultipartFile.fromFile(body!.path)});
  }
}

class IUploadMultipleRequest extends BaseRequest<List<File>> {
  IUploadMultipleRequest({required List<File> files, String? folder})
    : super(body: files, params: {if (folder != null) 'folder': folder});

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'files': await Future.wait(
        body!.map((file) => MultipartFile.fromFile(file.path)),
      ),
    });
  }
}
