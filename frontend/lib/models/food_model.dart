class FoodModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  const FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  factory FoodModel.fromJson(Map<String, dynamic> data) {
    return FoodModel(
      id: (data['id'] ?? data['_id'])?.toString() ?? '',
      name: data['name'] as String? ?? '',
      // backend returns category_name from the JOIN
      category: data['category_name'] as String? ?? data['category'] as String? ?? '',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
      // backend returns image_url (snake_case)
      imageUrl: data['image_url'] as String? ?? data['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'imageUrl': imageUrl,
      };
}
