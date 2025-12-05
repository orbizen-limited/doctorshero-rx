import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://doctorshero.com';
  static const String authBaseUrl = '$baseUrl/api/mobile/auth';
  static const String apiV1BaseUrl = '$baseUrl/api/v1';
  
  String? _token;
  
  // Create HTTP client with SSL bypass for development
  static http.Client _createHttpClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow all certificates in development
        // TODO: Remove this in production and use proper SSL certificates
        return true;
      };
    return IOClient(ioClient);
  }
  
  static final http.Client _client = _createHttpClient();

  // Get token from storage
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  // Save token to storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  // Clear token from storage
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  // Login with email, username, or phone
  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$authBaseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'login': login,  // Changed from 'email' to 'login'
          'password': password,
          'device_name': 'Flutter Desktop App',
          'device_type': 'desktop',  // Added device_type
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      // Handle server errors (500, 502, 503, etc.)
      if (response.statusCode >= 500) {
        return {
          'success': false,
          'code': 'NETWORK_ERROR',
          'message': 'Server error. Please try again or use offline mode.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['token']);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'token_type': data['token_type'],
          'active_sessions': data['active_sessions'],
          'max_sessions': data['max_sessions'],
        };
      } else if (response.statusCode == 429) {
        // Handle rate limiting and max sessions
        return {
          'success': false,
          'code': data['code'],
          'message': data['message'],
          'active_sessions': data['active_sessions'],
          'max_sessions': data['max_sessions'],
          'cooldown_until': data['cooldown_until'],
        };
      } else {
        return {
          'success': false,
          'code': data['code'] ?? 'UNKNOWN_ERROR',
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'code': 'NETWORK_ERROR',
        'message': 'Network error: $e',
      };
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _client.get(
        Uri.parse('$authBaseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _client.post(
          Uri.parse('$authBaseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
      await clearToken();
      return true;
    } catch (e) {
      await clearToken();
      return false;
    }
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _client.get(
        Uri.parse('$authBaseUrl/check'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['authenticated'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get active sessions
  Future<Map<String, dynamic>?> getActiveSessions() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _client.get(
        Uri.parse('$authBaseUrl/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching sessions: $e');
      return null;
    }
  }

  // Revoke specific session
  Future<bool> revokeSession(int sessionId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _client.delete(
        Uri.parse('$authBaseUrl/sessions/$sessionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error revoking session: $e');
      return false;
    }
  }

  // Logout from all devices
  Future<bool> logoutAll() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _client.post(
        Uri.parse('$authBaseUrl/logout-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      await clearToken();
      return response.statusCode == 200;
    } catch (e) {
      await clearToken();
      return false;
    }
  }

  // Get patient details by patient ID
  Future<Map<String, dynamic>?> getPatientByPatientId(String patientId) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _client.get(
        Uri.parse('$apiV1BaseUrl/patients?patient_id=$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && (data['data'] as List).isNotEmpty) {
          return (data['data'] as List).first;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching patient: $e');
      return null;
    }
  }

  // Search patients with multiple parameters
  Future<Map<String, dynamic>?> searchPatients({
    String? patientId,
    String? phone,
    String? name,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final queryParams = <String, String>{
        'per_page': perPage.toString(),
        'page': page.toString(),
      };
      
      if (patientId != null) queryParams['patient_id'] = patientId;
      if (phone != null) queryParams['phone'] = phone;
      if (name != null) queryParams['name'] = name;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$apiV1BaseUrl/patients').replace(queryParameters: queryParams);
      
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error searching patients: $e');
      return null;
    }
  }
}
