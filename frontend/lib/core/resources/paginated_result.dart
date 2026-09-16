class PaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;

  const PaginatedResult({required this.items, this.nextCursor});

  bool get hasMore => nextCursor != null;
}
