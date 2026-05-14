class PaginatedList<T> {
  final List<T> items;
  final bool hasNextPage;
  // We store the 'request' for the next page so the Repository knows how to fetch more
  final dynamic nextRequest;

  PaginatedList({
    required this.items,
    required this.hasNextPage,
    this.nextRequest,
  });
}
