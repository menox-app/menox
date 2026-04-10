import 'package:flutter_core/core/apis/base/interfaces/record.dart';

class Organizer extends BaseRecord {
  // Thêm các field riêng của Organizer vào đây (ví dụ name, email...)
  final String? name;

  Organizer({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.extraData,
    this.name,
  });

  // ĐÂY LÀ THỨ BẠN ĐANG THIẾU
  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      name: json['name'],
      extraData:
          json, // Lưu toàn bộ JSON vào extraData nếu muốn giống Record<string, unknown>
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      ...extraData,
    };
  }
}
