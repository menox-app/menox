import 'package:flutter_core/core/apis/base/client/crud.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';

/// App-level CRUD client.
/// Mỗi client con chỉ cần gọi super(resource: 'auth') — tự tạo Dio riêng.
///
/// Tương đương YaahCrudApiClient trong TypeScript:
/// ```typescript
/// class YaahAuthApiClient extends YaahCrudApiClient {
///   constructor() { super({ resource: 'auth' }); }
/// }
/// ```
abstract class AppCrudApiClient<T extends BaseRecord>
    extends BaseCrudApiClient<T> {
  AppCrudApiClient({required String resource})
    : super(DioFactory.instance.create(resource));
}
