// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Upload _$UploadFromJson(Map<String, dynamic> json) => Upload(
  id: json['id'] as String? ?? 'unknown',
  url: json['url'] as String? ?? '',
  remoteId: json['remote_id'] as String? ?? '',
  provider: json['provider'] as String? ?? '',
  resourceType: json['resource_type'] as String?,
  width: json['width'] as num?,
  height: json['height'] as num?,
  format: json['format'] as String?,
  mediaId: json['media_id'] as String?,
  publicId: json['public_id'] as String?,
  type: json['type'] as String?,
  mimeType: json['mime_type'] as String?,
  size: json['size'] as num?,
  folder: json['folder'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UploadToJson(Upload instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'remote_id': instance.remoteId,
  'provider': instance.provider,
  'resource_type': instance.resourceType,
  'width': instance.width,
  'height': instance.height,
  'format': instance.format,
  'media_id': instance.mediaId,
  'public_id': instance.publicId,
  'type': instance.type,
  'mime_type': instance.mimeType,
  'size': instance.size,
  'folder': instance.folder,
  'metadata': instance.metadata,
};
