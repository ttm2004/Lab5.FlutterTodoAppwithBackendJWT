import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  // Android Emulator: 10.0.2.2 | Thiết bị thật: IP máy tính
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String _tokenKey = 'token';

  // ─── Token helpers (SharedPreferences + JwtDecoder) ───────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Kiểm tra token tồn tại và chưa hết hạn (dùng jwt_decoder)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    // JwtDecoder.isExpired trả về true nếu đã hết hạn
    return !JwtDecoder.isExpired(token);
  }

  /// Decode JWT lấy thông tin user (userId, email, username)
  static Future<Map<String, dynamic>> decodeToken() async {
    final token = await getToken();
    if (token == null) return {};
    return JwtDecoder.decode(token);
  }

  // ─── Headers ──────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  // ─── Auth endpoints ───────────────────────────────────────────────────────

  /// POST /api/auth/register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  /// POST /api/auth/login – lưu token vào SharedPreferences
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handleResponse(response);
    if (data['token'] != null) {
      await saveToken(data['token']);
    }
    return data;
  }

  /// Logout – xoá token khỏi SharedPreferences
  static Future<void> logout() async {
    await deleteToken();
  }

  // ─── Todo endpoints ───────────────────────────────────────────────────────

  /// GET /api/todos
  static Future<List<dynamic>> getTodos() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/todos'),
      headers: headers,
    );
    final data = _handleResponse(response);
    return data['todos'] ?? data;
  }

  /// POST /api/todos
  static Future<Map<String, dynamic>> createTodo({
    required String title,
    required String description,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: headers,
      body: jsonEncode({'title': title, 'description': description}),
    );
    return _handleResponse(response);
  }

  /// PUT /api/todos/{id}
  static Future<Map<String, dynamic>> updateTodo({
    required int id,
    required String title,
    required String description,
    required bool isCompleted,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
      body: jsonEncode({
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
      }),
    );
    return _handleResponse(response);
  }

  /// DELETE /api/todos/{id}
  static Future<Map<String, dynamic>> deleteTodo(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  /// PATCH /api/todos/{id}/toggle
  static Future<Map<String, dynamic>> toggleTodo(int id) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/todos/$id/toggle'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // ─── Response handler ─────────────────────────────────────────────────────

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      decoded = {'message': body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List) return {'todos': decoded};
      return decoded as Map<String, dynamic>;
    }

    final message = decoded is Map
        ? (decoded['message'] ?? decoded['title'] ?? 'Lỗi không xác định')
        : 'Lỗi không xác định';
    throw ApiException(message.toString(), response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
