import 'dart:convert';
import 'package:http/http.dart' as http;

// Base URL — change for your environment:
//   Android emulator  → http://10.0.2.2:3000
//   iOS simulator     → http://127.0.0.1:3000
//   Physical device   → http://<your-machine-ip>:3000
const String baseUrl = 'http://10.0.2.2:3000';

class ApiClient {
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
  static String? get token => _token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handle(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    dynamic parsed;
    try {
      parsed = jsonDecode(response.body);
    } catch (_) {
      parsed = null;
    }
    final message = parsed is Map ? parsed['message'] : null;
    throw message ?? 'Request failed (${response.statusCode})';
  }
}
