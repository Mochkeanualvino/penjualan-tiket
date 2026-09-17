import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service untuk menangani semua request REST API ke Backend Laravel.
/// Memiliki penanganan fallback otomatis jika backend tidak aktif (offline-first mode).
class ApiService {
  // Base URL untuk Laravel API backend
  static String baseUrl = kIsWeb
      ? 'http://localhost:8000/api/v1'
      : 'http://10.0.2.2:8000/api/v1'; // Default emulator android / localhost web

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET request
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService GET $endpoint error/offline: $e');
    }
    return null;
  }

  /// POST request
  static Future<Map<String, dynamic>?> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      debugPrint('ApiService POST $endpoint returned invalid JSON');
    } catch (e) {
      debugPrint('ApiService POST $endpoint error/offline: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> loginWithGoogle(String idToken) {
    return post('/auth/google', {'id_token': idToken});
  }

  /// PUT request
  static Future<Map<String, dynamic>?> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService PUT $endpoint error/offline: $e');
    }
    return null;
  }

  /// DELETE request
  static Future<bool> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService DELETE $endpoint error/offline: $e');
      return false;
    }
  }

  /// Auto-save draft input endpoint
  static Future<bool> saveInputDraft(
      String formKey, Map<String, dynamic> draftData) async {
    final result = await post('/drafts/auto-save', {
      'form_key': formKey,
      'draft_data': draftData,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return result != null && result['status'] == 'success';
  }
}
