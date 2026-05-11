import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  // Returns (UserModel, JWT token) on success, throws String message on failure
  static Future<(UserModel, String)> signIn(
      String username, String password) async {
    final data = await ApiClient.post('/api/auth/login', {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, token);
  }

  static Future<(UserModel, String)> register(
      String username, String password) async {
    final data = await ApiClient.post('/api/auth/register', {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, token);
  }

  static Future<void> forgotPassword(String username) async {
    await ApiClient.post('/api/auth/forgot-password', {'username': username});
  }

  // Local-only — just clears the stored token
  static void signOut() => ApiClient.clearToken();
}
