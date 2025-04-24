import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/repositories/product_repo_impl.dart';
import '../../domain/models/products.dart';
import '../../domain/usecases/get_product_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../data/datasources/product_remote_datasource.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return ProductRemoteDataSourceImpl(client: client);
});

final productRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(dataSource: dataSource);
});

final getProductsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository);
});

final searchProductsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProductsUseCase(repository);
});

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final bool hasReachedEnd;
  final int currentPage;
  final String? searchQuery;
  final SortOption sortOption;

  ProductsState({
    required this.products,
    required this.isLoading,
    this.errorMessage,
    required this.hasReachedEnd,
    required this.currentPage,
    this.searchQuery,
    required this.sortOption,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
    bool? hasReachedEnd,
    int? currentPage,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

enum SortOption { none, priceLowToHigh, priceHighToLow, rating }

class ProductsNotifier extends StateNotifier<ProductsState> {
  final GetProductsUseCase _getProductsUseCase;
  final SearchProductsUseCase _searchProductsUseCase;
  static const int _limit = 10;

  ProductsNotifier(this._getProductsUseCase, this._searchProductsUseCase)
      : super(ProductsState(
    products: [],
    isLoading: false,
    hasReachedEnd: false,
    currentPage: 0,
    sortOption: SortOption.none,
  )) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    if (state.isLoading || state.hasReachedEnd) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final skip = state.currentPage * _limit;
      final newProducts = state.searchQuery?.isNotEmpty == true
          ? await _searchProductsUseCase.execute(state.searchQuery!)
          : await _getProductsUseCase.execute(skip: skip, limit: _limit);

      final allProducts = [...state.products, ...newProducts];
      final sortedProducts = _sortProducts(allProducts);

      state = state.copyWith(
        products: sortedProducts,
        isLoading: false,
        hasReachedEnd: newProducts.length < _limit,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load products: ${e.toString()}',
      );
    }
  }

  Future<void> refreshProducts() async {
    state = state.copyWith(
      products: [],
      isLoading: false,
      hasReachedEnd: false,
      currentPage: 0,
      errorMessage: null,
    );
    await fetchProducts();
  }

  Future<void> searchProducts(String query) async {
    if (query == state.searchQuery) return;

    state = state.copyWith(
      products: [],
      isLoading: false,
      hasReachedEnd: false,
      currentPage: 0,
      searchQuery: query,
      errorMessage: null,
    );
    await fetchProducts();
  }

  void setSortOption(SortOption option) {
    if (option == state.sortOption) return;

    final sortedProducts = _sortProductsByOption(state.products, option);
    state = state.copyWith(
      products: sortedProducts,
      sortOption: option,
    );
  }

  List<Product> _sortProducts(List<Product> products) {
    return _sortProductsByOption(products, state.sortOption);
  }

  List<Product> _sortProductsByOption(List<Product> products, SortOption option) {
    final List<Product> sortedProducts = List.from(products);

    switch (option) {
      case SortOption.priceLowToHigh:
        sortedProducts.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case SortOption.priceHighToLow:
        sortedProducts.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case SortOption.rating:
        sortedProducts.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.none:
      break;
    }

    return sortedProducts;
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final getProductsUseCase = ref.watch(getProductsUseCaseProvider);
  final searchProductsUseCase = ref.watch(searchProductsUseCaseProvider);
  return ProductsNotifier(getProductsUseCase, searchProductsUseCase);
});