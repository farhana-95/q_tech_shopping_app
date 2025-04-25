import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class SortOptionsBottomSheet extends ConsumerWidget {
  const SortOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Price- Low to High'),
            onTap: () {
              ref.read(productsProvider.notifier).setSortOption(SortOption.priceLowToHigh);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Price- High to Low'),
            onTap: () {
              ref.read(productsProvider.notifier).setSortOption(SortOption.priceHighToLow);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Rating'),
            onTap: () {
              ref.read(productsProvider.notifier).setSortOption(SortOption.rating);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 15,)
        ],
      ),
    );
  }
}