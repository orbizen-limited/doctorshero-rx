import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'api_service.dart';

class PatientService {
  final ApiService _apiService = ApiService();
  static const String baseUrl = 'https://doctorshero.com';
  
  // Create HTTP client with SSL bypass (same as other services)
  static http.Client _createHttpClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }
  
  static final http.Client _client = _createHttpClient();

  /// Search patients by phone number
  /// Returns list of patients matching the phone (partial match)
  Future<List<Map<String, dynamic>>> searchByPhone(String phone) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        print('❌ No auth token available');
        return [];
      }

      final url = '$baseUrl/api/v1/patients?phone=$phone';
      print('📡 GET $url');
      
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final patients = List<Map<String, dynamic>>.from(data['data']);
          print('✅ Found ${patients.length} patients');
          return patients;
        }
      }
      print('⚠️  No patients found or API error');
      return [];
    } catch (e) {
      print('❌ Error in searchByPhone: $e');
      return [];
    }
  }

  /// Search patients by name
  /// Returns list of patients matching the name (partial match)
  Future<List<Map<String, dynamic>>> searchByName(String name) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/patients?name=$name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching by name: $e');
      return [];
    }
  }

  /// Combined search by phone and name
  /// Returns patients matching BOTH criteria
  Future<List<Map<String, dynamic>>> searchByPhoneAndName({
    required String phone,
    required String name,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/patients?phone=$phone&name=$name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Search patients by patient ID (exact match)
  Future<Map<String, dynamic>?> searchByPatientId(String patientId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/patients?patient_id=$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0];
        }
      }
      return null;
    } catch (e) {
      print('Error searching by patient ID: $e');
      return null;
    }
  }

  /// Generic search (searches across name, phone, and patient_id)
  Future<List<Map<String, dynamic>>> genericSearch(String query) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/patients?search=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error in generic search: $e');
      return [];
    }
  }

  /// Create a new patient
  /// Returns full response including similar patients if duplicates found
  Future<Map<String, dynamic>?> createPatient({
    required String name,
    required String phone,
    String? age,
    String? gender,
    bool forceCreate = false,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        print('❌ No auth token available');
        return null;
      }

      final body = {
        'name': name,
        'phone': phone,
        if (age != null && age.isNotEmpty) 'age': age,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        'force_create': forceCreate,
      };

      print('📡 POST $baseUrl/api/v1/patients');
      print('📦 Request body: ${jsonEncode(body)}');

      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/patients'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Patient creation response received');
        // Return full response (includes success, data, requires_confirmation, similar_patients)
        return data;
      }
      print('❌ Failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error in createPatient: $e');
      return null;
    }
  }

  /// Flexible search with multiple optional parameters
  Future<List<Map<String, dynamic>>> searchPatients({
    String? patientId,
    String? phone,
    String? name,
    String? gender,
    int perPage = 20,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      // Build query parameters
      final params = <String, String>{};
      if (patientId != null && patientId.isNotEmpty) params['patient_id'] = patientId;
      if (phone != null && phone.isNotEmpty) params['phone'] = phone;
      if (name != null && name.isNotEmpty) params['name'] = name;
      if (gender != null && gender.isNotEmpty) params['gender'] = gender;
      params['per_page'] = perPage.toString();

      final uri = Uri.parse('$baseUrl/api/v1/patients').replace(
        queryParameters: params.isNotEmpty ? params : null,
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching patients: $e');
      return [];
    }
  }
}
