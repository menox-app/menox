import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';
import 'package:json_annotation/json_annotation.dart';

typedef BaseBaseKey = String;

/// Tương đương: BaseRecord<KeyType> extends Record<string, unknown>
abstract class BaseRecord<KeyType> extends BaseSerializable {
  final KeyType id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Lưu trữ các field động (Record<string, unknown>)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic> extraData;

  BaseRecord({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.extraData = const {},
  });
}
