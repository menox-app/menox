import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Mixin cho các AsyncNotifier action — tự động wrap:
///   1. Set AsyncLoading (giữ previous data)
///   2. Chạy action
///   3. Re-throw error nếu có (để UI catch được)
///
/// Sử dụng:
/// ```dart
/// @riverpod
/// class AuthAction extends _$AuthAction with AsyncAction<void> {
///   @override
///   FutureOr<void> build() {}
///
///   Future<void> signIn(ISignInRequest req) => execute(() async {
///     final res = await ref.read(appApiProvider).auth.signIn(req);
///     await ref.read(authProvider.notifier).login(res.data.token, ...);
///   });
/// }
/// ```
mixin AsyncAction<T> on AutoDisposeAsyncNotifier<T> {
  /// Wrap một async action với auto loading → result → error handling.
  ///
  /// [action] — callback chứa logic thực thi.
  /// Loading state được set trước khi chạy, giữ lại previous data nếu có.
  /// Nếu action throw, error sẽ được re-throw để caller (UI) catch được.
  Future<void> execute(Future<void> Function() action) async {
    state = AsyncLoading<T>().copyWithPrevious(state);
    try {
      await action();
      state = AsyncData<T>(null as T);
    } catch (e, st) {
      state = AsyncError<T>(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }
}
