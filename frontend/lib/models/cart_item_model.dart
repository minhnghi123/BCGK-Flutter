import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;
  String? cartItemId; // backend cart_items.id — needed for PUT/DELETE

  CartItemModel({required this.food, this.quantity = 1, this.cartItemId});

  double get subtotal => food.price * quantity;

  CartItemModel copyWith({int? quantity, String? cartItemId}) {
    return CartItemModel(
      food: food,
      quantity: quantity ?? this.quantity,
      cartItemId: cartItemId ?? this.cartItemId,
    );
  }

  // Parses the flat row returned by GET /api/cart
  factory CartItemModel.fromJson(Map<String, dynamic> data) {
    final food = FoodModel(
      id: data['food_id']?.toString() ?? '',
      name: data['name'] as String? ?? '',
      category: data['category_name'] as String? ?? '',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
      imageUrl: data['image_url'] as String? ?? '',
    );
    return CartItemModel(
      food: food,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      cartItemId: data['id']?.toString(),
    );
  }
}
