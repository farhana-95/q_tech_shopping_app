import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';
import 'filter_bar.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerStatefulWidget {
  const ProductGrid({super.key});

  @override
  ConsumerState<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends ConsumerState<ProductGrid> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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
    if (query.isEmpty) {
      ref.read(productsProvider.notifier).refreshProducts();
    } else {
      ref.read(productsProvider.notifier).searchProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70,
          title: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Anything...',
                        hintStyle: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            "assets/images/search-normal.png",
                            height: 18,
                            width: 18,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => const SortOptionsBottomSheet(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, bottom: 5),
                    child: Image.asset(
                      "assets/images/sort.png",
                      // Replace with your actual image path
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(productsProvider.notifier).refreshProducts(),
          child: productsState.products.isEmpty && !productsState.isLoading
              ? const Center(child: Text('No products found'))
              : _buildProductGrid(productsState),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Anything...',
                hintStyle: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    "assets/images/search-normal.png",
                    height: 18,
                    width: 18,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _onSearchChanged,
              autofocus: true,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              // shape: const RoundedRectangleBorder(
              //   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              // ),
              builder: (context) => const SortOptionsBottomSheet(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Image.asset(
              "assets/images/sort.png",
              height: 40,
              width: 40,
            ),
          ),
        ),
      ],
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
