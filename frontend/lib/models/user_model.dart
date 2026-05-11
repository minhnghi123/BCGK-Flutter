class UserModel {
  final String id;
  final String email;
  final String fullName;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: (data['id'] ?? data['_id'])?.toString() ?? '',
      email: data['email'] as String? ?? '',
      // backend returns fullName; fall back to full_name or legacy username key
      fullName: data['fullName'] as String? ??
          data['full_name'] as String? ??
          data['username'] as String? ??
          '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'fullName': fullName,
      };
}
