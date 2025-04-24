import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerStatefulWidget {
  const ProductGrid({super.key});

  @override
  ConsumerState<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends ConsumerState<ProductGrid> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      ref.read(productsProvider.notifier).fetchProducts();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    ref.read(productsProvider.notifier).searchProducts(query);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(productsProvider.notifier).refreshProducts(),
        child: productsState.products.isEmpty && !productsState.isLoading
            ? const Center(child: Text('No products found'))
            : _buildProductGrid(productsState),
      ),
    );
  }

  Widget _buildProductGrid(ProductsState state) {
    return Column(
      children: [
        Center(
          child: Text("${state.products.length}"),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 17,
              mainAxisSpacing: 17,
            ),
            itemCount: state.products.length + (state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final product = state.products[index];
              return ProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}
