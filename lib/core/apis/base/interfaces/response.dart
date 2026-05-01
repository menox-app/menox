/// Tương đương: BaseResponse<T>
class BaseResponse<T> {
  final T data;
  final String status; // 'success' | 'error'
  final String? message;
  final int statusCode;

  BaseResponse({
    required this.data,
    required this.status,
    this.message,
    required this.statusCode,
  });

  bool get isSuccess => status == 'success';
}

/// Tương đương: Pagination Info
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final bool hasMore;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}

/// Tương đương: BasePaginationResponse<T>
class BasePaginationResponse<T> extends BaseResponse<List<T>> {
  final PaginationInfo meta;

  BasePaginationResponse({
    required super.data,
    required super.status,
    super.message,
    required super.statusCode,
    required this.meta,
  });
}

// Các loại response khác bạn chỉ cần dùng BaseResponse<T> là đủ
// Ví dụ: BaseResponse<User> tương đương BaseGetByIdResponse<User>
