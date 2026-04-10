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
  final int totalDocs;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.totalDocs,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      totalDocs: json['totalDocs'] ?? json['total'] ?? 0,
      totalPages: json['totalPages'] ?? json['pages'] ?? 0,
    );
  }
}

/// Tương đương: BasePaginationResponse<T>
class BasePaginationResponse<T> extends BaseResponse<List<T>> {
  final PaginationInfo pagination;

  BasePaginationResponse({
    required super.data,
    required super.status,
    super.message,
    required super.statusCode,
    required this.pagination,
  });
}

// Các loại response khác bạn chỉ cần dùng BaseResponse<T> là đủ 
// Ví dụ: BaseResponse<User> tương đương BaseGetByIdResponse<User>