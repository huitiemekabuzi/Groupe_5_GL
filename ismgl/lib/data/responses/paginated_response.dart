/// Modèle générique pour les réponses paginées de l'API.
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    final rawItems   = json['items']      as List<dynamic>?         ?? [];

    return PaginatedResponse<T>(
      items:       rawItems.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: pagination['current_page'] as int? ?? 1,
      pageSize:    pagination['page_size']    as int? ?? 20,
      totalItems:  pagination['total_items']  as int? ?? 0,
      totalPages:  pagination['total_pages']  as int? ?? 1,
      hasNext:     pagination['has_next']     as bool? ??
                   (pagination['has_next']    == 1),
      hasPrevious: pagination['has_previous'] as bool? ??
                   (pagination['has_previous'] == 1),
    );
  }

  bool get isEmpty   => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
