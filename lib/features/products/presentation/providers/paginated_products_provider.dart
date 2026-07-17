import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_products_repository.dart';
import 'products_provider.dart';

class PaginatedProductsState {
  final List<ProductEntity> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PaginatedProductsState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedProductsState copyWith({
    List<ProductEntity>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedProductsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

class PaginatedProductsNotifier extends StateNotifier<PaginatedProductsState> {
  final IProductsRepository _repository;
  final String? _categoryId;
  final String? _searchQuery;
  String? _cursorId;

  PaginatedProductsNotifier(this._repository, {String? categoryId, String? searchQuery})
      : _categoryId = categoryId,
        _searchQuery = searchQuery,
        super(const PaginatedProductsState()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await fetchNextPage(reset: true);
  }

  Future<void> fetchNextPage({bool reset = false}) async {
    if (!reset && (state.isLoadingMore || !state.hasMore)) return;

    if (reset) {
      _cursorId = null;
      state = state.copyWith(isLoading: true, isLoadingMore: false, items: [], hasMore: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      // Fetch enough to fill at least one screen + 1 for hasMore probe
      const pageSize = 12;
      const fetchCount = pageSize + 1;

      List<ProductEntity> results;
      if (_searchQuery != null) {
        results = await _repository.searchProducts(_searchQuery, limit: 50);
        state = PaginatedProductsState(
          items: reset ? results : [...state.items, ...results],
          isLoading: false,
          isLoadingMore: false,
          hasMore: false,
        );
        return;
      } else if (_categoryId != null) {
        results = await _repository.getProductsByCategory(_categoryId, startAfterId: _cursorId, limit: fetchCount);
      } else {
        results = await _repository.getProducts(startAfterId: _cursorId, limit: fetchCount);
      }

      final hasMore = results.length > pageSize;
      final items = hasMore ? results.sublist(0, pageSize) : results;

      if (hasMore) {
        _cursorId = results[pageSize].id;
      } else {
        _cursorId = results.isNotEmpty ? results.last.id : null;
      }

      state = PaginatedProductsState(
        items: reset ? items : [...state.items, ...items],
        isLoading: false,
        isLoadingMore: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchNextPage(reset: true);
  }
}

final paginatedAllProductsProvider =
    StateNotifierProvider<PaginatedProductsNotifier, PaginatedProductsState>((ref) {
  return PaginatedProductsNotifier(ref.read(productsRepositoryProvider));
});

final paginatedCategoryProductsProvider =
    StateNotifierProvider.family<PaginatedProductsNotifier, PaginatedProductsState, String>(
        (ref, categoryId) {
  return PaginatedProductsNotifier(ref.read(productsRepositoryProvider), categoryId: categoryId);
});

final paginatedSearchProductsProvider =
    StateNotifierProvider.family<PaginatedProductsNotifier, PaginatedProductsState, String>(
        (ref, query) {
  return PaginatedProductsNotifier(ref.read(productsRepositoryProvider), searchQuery: query);
});

class FilterParams {
  final String filterType; // 'all', 'offers', 'rating', 'bestSeller'
  final String? categoryId; // sub-category ID

  const FilterParams({required this.filterType, this.categoryId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterParams &&
          runtimeType == other.runtimeType &&
          filterType == other.filterType &&
          categoryId == other.categoryId;

  @override
  int get hashCode => filterType.hashCode ^ categoryId.hashCode;
}

class PaginatedFilteredProductsNotifier extends StateNotifier<PaginatedProductsState> {
  final IProductsRepository _repository;
  final FilterParams _params;
  String? _cursorId;
  bool _isFetching = false;

  PaginatedFilteredProductsNotifier(this._repository, this._params)
      : super(const PaginatedProductsState()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await fetchNextPage(reset: true);
  }

  Future<void> fetchNextPage({bool reset = false}) async {
    if (_isFetching) return;
    if (!reset && (state.isLoadingMore || !state.hasMore)) return;

    _isFetching = true;
    // Fetch enough to fill at least one screen + 1 for hasMore probe
    const pageSize = 12;
    const fetchCount = pageSize + 1;

    if (reset) {
      _cursorId = null;
      state = state.copyWith(isLoading: true, isLoadingMore: false, items: [], hasMore: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      List<ProductEntity> results;
      if (_params.categoryId != null) {
        results = await _repository.getProductsByCategory(
          _params.categoryId!,
          startAfterId: _cursorId,
          limit: fetchCount,
        );
      } else {
        results = await _repository.getProducts(
          startAfterId: _cursorId,
          limit: fetchCount,
        );
      }

      final hasMore = results.length > pageSize;
      final page = hasMore ? results.sublist(0, pageSize) : results;
      _cursorId = page.isNotEmpty ? page.last.id : null;

      final filtered = page.where((product) {
        switch (_params.filterType) {
          case 'offers':
            return (product.discountPercent != null && product.discountPercent! > 0) ||
                (product.originalPrice != null && product.originalPrice! > product.price);
          case 'rating':
            return product.rating >= 4.8 || product.rating == 5.0;
          case 'bestSeller':
            return product.isBestSeller;
          case 'all':
          default:
            return true;
        }
      }).toList();

      state = PaginatedProductsState(
        items: reset ? filtered : [...state.items, ...filtered],
        isLoading: false,
        isLoadingMore: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e.toString());
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    await fetchNextPage(reset: true);
  }
}

final paginatedFilteredProductsProvider =
    StateNotifierProvider.family<PaginatedFilteredProductsNotifier, PaginatedProductsState, FilterParams>(
        (ref, params) {
  return PaginatedFilteredProductsNotifier(ref.read(productsRepositoryProvider), params);
});
