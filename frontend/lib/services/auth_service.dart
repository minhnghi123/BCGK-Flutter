import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  // Returns (UserModel, JWT token) on success, throws String message on failure
  static Future<(UserModel, String)> signIn(
      String email, String password) async {
    final data = await ApiClient.post('/api/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, token);
  }

  static Future<(UserModel, String)> register(
      String email, String password, String fullName) async {
    final data = await ApiClient.post('/api/auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
    }) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, token);
  }

  // Backend resets password directly when given email + newPassword
  static Future<void> forgotPassword(String email, String newPassword) async {
    await ApiClient.post('/api/auth/forgot-password', {
      'email': email,
      'newPassword': newPassword,
    });
  }

  // Local-only — just clears the stored token
  static void signOut() => ApiClient.clearToken();
}
