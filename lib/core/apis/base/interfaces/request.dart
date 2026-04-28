/// Tương đương: BaseRequest
abstract class BaseRequest<B> {
  final B? body;
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? pathParams;

  BaseRequest({this.body, this.params, this.pathParams});
}

/// Tương đương: BaseCreateRequest<T>
/// (Bên Dart, bạn truyền trực tiếp DTO không có ID vào T)
class BaseCreateRequest<T> extends BaseRequest<T> {
  BaseCreateRequest({required T super.body, super.params});
}

/// Tương đương: BasePaginationRequest<Params>
class BasePaginationRequest<Params> extends BaseRequest<void> {
  final int? page;
  final int? limit;
  final Params? extraParams;

  BasePaginationRequest({this.page, this.limit, this.extraParams})
    : super(params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (extraParams != null) 'extra': extraParams,
      });
}

/// Tương đương: BaseGetByIdRequest & BaseDeleteRequest
class BaseGetByIdRequest extends BaseRequest<void> {
  BaseGetByIdRequest({required String id}) : super(pathParams: {'id': id});
}

class BaseDeleteRequest extends BaseRequest<void> {
  BaseDeleteRequest({required String id}) : super(pathParams: {'id': id});
}

/// Tương đương: BaseGetBySlugRequest
class BaseGetBySlugRequest extends BaseRequest<void> {
  BaseGetBySlugRequest({required String slug})
    : super(pathParams: {'slug': slug});
}

/// Tương đương: BaseUpdateRequest<T>
class BaseUpdateRequest<T> extends BaseRequest<T> {
  BaseUpdateRequest({
    required String id,
    required T body, // T đóng vai trò là Partial DTO
  }) : super(body: body, pathParams: {'id': id});
}
