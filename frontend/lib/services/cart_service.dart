import '../models/cart_item_model.dart';
import 'api_client.dart';

class CartService {
  static Future<List<CartItemModel>> getCart() async {
    final data = await ApiClient.get('/api/cart') as List;
    return data
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Returns the raw cart_items row (includes id, food_id, quantity)
  static Future<Map<String, dynamic>> addItem(String foodId, int quantity) async {
    return await ApiClient.post('/api/cart', {
          'foodId': int.tryParse(foodId) ?? foodId,
          'quantity': quantity,
        }) as Map<String, dynamic>;
  }

  static Future<void> updateItem(String cartItemId, int quantity) async {
    await ApiClient.put('/api/cart/$cartItemId', {'quantity': quantity});
  }

  static Future<void> removeItem(String cartItemId) async {
    await ApiClient.delete('/api/cart/$cartItemId');
  }
}
