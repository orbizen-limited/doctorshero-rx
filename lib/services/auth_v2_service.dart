import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Authentication Service v2
/// Supports: Email/Username/Phone login, OTP, Session Management
class AuthV2Service {
  static const String baseUrl = 'https://doctorshero.com';
  static const String authV2BaseUrl = '$baseUrl/api/mobile/auth/v2';
  
  String? _token;
  
  // Create HTTP client with SSL bypass for development
  static http.Client _createHttpClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true; // Allow all certificates in development
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

  /// Login with Email/Username/Phone (v2)
  /// 
  /// Returns:
  /// - Success with token: { success: true, user: {...}, token: "...", active_sessions: 1 }
  /// - OTP Required: { success: true, code: "OTP_REQUIRED", user_id: 10, otp_expires_at: "..." }
  /// - Max Sessions: { success: false, code: "MAX_SESSIONS_REACHED", active_sessions: 4 }
  /// - Login Cooldown: { success: false, code: "LOGIN_COOLDOWN", cooldown_until: "..." }
  Future<Map<String, dynamic>> loginV2({
    required String login, // email, username, or phone
    required String password,
    String deviceName = 'Flutter Desktop App',
    String deviceType = 'desktop',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$authV2BaseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'login': login,
          'password': password,
          'device_name': deviceName,
          'device_type': deviceType,
        }),
      );

      final data = jsonDecode(response.body);

      // Handle different response codes
      if (response.statusCode == 200 && data['success'] == true) {
        // Check if OTP is required
        if (data['code'] == 'OTP_REQUIRED') {
          return {
            'success': true,
            'code': 'OTP_REQUIRED',
            'user_id': data['user_id'],
            'otp_expires_at': data['otp_expires_at'],
            'attempts_remaining': data['attempts_remaining'],
            'message': data['message'],
          };
        }
        
        // Normal login success
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'token_type': data['token_type'],
          'active_sessions': data['active_sessions'],
          'max_sessions': data['max_sessions'],
        };
      } else if (response.statusCode == 429) {
        // Rate limited or max sessions
        return {
          'success': false,
          'code': data['code'],
          'message': data['message'],
          'cooldown_until': data['cooldown_until'],
          'active_sessions': data['active_sessions'],
          'max_sessions': data['max_sessions'],
        };
      } else {
        // Invalid credentials or other error
        return {
          'success': false,
          'code': data['code'] ?? 'LOGIN_FAILED',
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

  /// Request OTP for phone verification
  Future<Map<String, dynamic>> requestOTP(String phone) async {
    try {
      final response = await _client.post(
        Uri.parse('$authV2BaseUrl/request-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user_id': data['user_id'],
          'otp_expires_at': data['otp_expires_at'],
          'attempts_remaining': data['attempts_remaining'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Verify OTP and complete login
  Future<Map<String, dynamic>> verifyOTP({
    required int userId,
    required String otp,
    String deviceName = 'Flutter Desktop App',
    String deviceType = 'desktop',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$authV2BaseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'otp': otp,
          'device_name': deviceName,
          'device_type': deviceType,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'token_type': data['token_type'],
          'active_sessions': data['active_sessions'],
          'max_sessions': data['max_sessions'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get all active sessions
  Future<Map<String, dynamic>> getActiveSessions() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await _client.get(
        Uri.parse('$authV2BaseUrl/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'sessions': data['sessions'],
          'total': data['total'],
          'max_allowed': data['max_allowed'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch sessions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Revoke a specific session
  Future<Map<String, dynamic>> revokeSession(int tokenId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await _client.delete(
        Uri.parse('$authV2BaseUrl/sessions/$tokenId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Session revoked successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to revoke session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Logout from current device
  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _client.post(
          Uri.parse('$authV2BaseUrl/logout'),
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

  /// Logout from all devices
  Future<bool> logoutAll() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _client.post(
          Uri.parse('$authV2BaseUrl/logout-all'),
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

  /// Get current user profile (uses v1 endpoint)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _client.get(
        Uri.parse('$baseUrl/api/mobile/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check authentication status
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _client.get(
        Uri.parse('$baseUrl/api/mobile/auth/check'),
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
}
