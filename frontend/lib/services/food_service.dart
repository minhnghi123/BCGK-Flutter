import '../models/food_model.dart';
import '../models/category_model.dart';
import 'api_client.dart';

class FoodService {
  static Future<List<CategoryModel>> fetchCategories() async {
    final data = await ApiClient.get('/api/categories') as List;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<FoodModel>> fetchFoods() async {
    final data = await ApiClient.get('/api/foods') as List;
    return data
        .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<FoodModel>> fetchFoodsByCategory(String category) async {
    final data = await ApiClient.get(
      '/api/foods?category=${Uri.encodeComponent(category)}',
    ) as List;
    return data
        .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
