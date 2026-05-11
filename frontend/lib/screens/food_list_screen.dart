import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../store/index.dart';
import '../widgets/cart_badge_icon.dart';
import '../widgets/food_card.dart';

class FoodListScreen extends StatelessWidget {
  final String category;

  const FoodListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: const [CartBadgeIcon()],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final foods = provider.foods
              .where((f) => f.category == category)
              .toList();

          // Find category image for the banner
          final categoryModel = provider.categories
              .where((c) => c.name == category)
              .firstOrNull;

          return CustomScrollView(
            slivers: [
              // Banner image + restaurant info header
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (categoryModel != null &&
                        categoryModel.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: categoryModel.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, e) => Container(
                          height: 160,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Text(
                            'Restaurant App',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const Text(
                            'Menu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Food list
              foods.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No items in this category')),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FoodCard(food: foods[index]),
                        childCount: foods.length,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
