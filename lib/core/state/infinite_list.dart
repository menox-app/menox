typedef ItemMatcher<T> = bool Function(T existing, T incoming);

class InfiniteList<T> {
  final List<T> items;
  final int page;
  final int limit;
  final bool hasNextPage;
  final bool isFetchingNextPage;

  const InfiniteList({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasNextPage,
    this.isFetchingNextPage = false,
  });

  factory InfiniteList.empty({int limit = 10}) {
    return InfiniteList<T>(
      items: const [],
      page: 0,
      limit: limit,
      hasNextPage: true,
    );
  }

  InfiniteList<T> copyWith({
    List<T>? items,
    int? page,
    int? limit,
    bool? hasNextPage,
    bool? isFetchingNextPage,
  }) {
    return InfiniteList<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
    );
  }

  InfiniteList<T> appendPage(List<T> pageItems) {
    final nextPage = page + 1;
    return copyWith(
      items: [...items, ...pageItems],
      page: nextPage,
      hasNextPage: pageItems.length >= limit,
      isFetchingNextPage: false,
    );
  }

  InfiniteList<T> replaceWithFirstPage(List<T> pageItems) {
    return copyWith(
      items: pageItems,
      page: 1,
      hasNextPage: pageItems.length >= limit,
      isFetchingNextPage: false,
    );
  }

  InfiniteList<T> prependUnique(T item, {required ItemMatcher<T> matches}) {
    return copyWith(
      items: [item, ...items.where((existing) => !matches(existing, item))],
    );
  }

  InfiniteList<T> replaceWhere(bool Function(T item) test, T item) {
    return copyWith(
      items: items.map((existing) => test(existing) ? item : existing).toList(),
    );
  }

  InfiniteList<T> removeWhere(bool Function(T item) test) {
    return copyWith(items: items.where((item) => !test(item)).toList());
  }
}

Future<R> optimisticInfiniteUpdate<T, R>({
  required InfiniteList<T> previous,
  required void Function(InfiniteList<T> next) apply,
  required InfiniteList<T> Function(InfiniteList<T> current) update,
  required Future<R> Function() action,
  required void Function(
    InfiniteList<T> previous,
    Object error,
    StackTrace stackTrace,
  )
  rollback,
  void Function(R result)? onSuccess,
}) async {
  apply(update(previous));

  try {
    final result = await action();
    onSuccess?.call(result);
    return result;
  } catch (error, stackTrace) {
    rollback(previous, error, stackTrace);
    rethrow;
  }
}
