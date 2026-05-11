class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> data) {
    return CategoryModel(
      id: (data['id'] ?? data['_id'])?.toString() ?? '',
      name: data['name'] as String? ?? '',
      // backend returns image_url (snake_case from PostgreSQL)
      imageUrl: data['image_url'] as String? ?? data['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
      };
}
