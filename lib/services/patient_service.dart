import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PatientService {
  final ApiService _apiService = ApiService();
  static const String baseUrl = 'https://demo.doctorshero.com';

  /// Search patients by phone number
  /// Returns list of patients matching the phone (partial match)
  Future<List<Map<String, dynamic>>> searchByPhone(String phone) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        print('❌ No token available');
        return [];
      }

      final url = '$baseUrl/api/v1/patients?phone=$phone';
      print('🌐 API Call: GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final patients = List<Map<String, dynamic>>.from(data['data']);
          print('✅ Parsed ${patients.length} patients');
          return patients;
        }
      }
      return [];
    } catch (e) {
      print('❌ Error searching by phone: $e');
      return [];
    }
  }

  /// Search patients by name
  /// Returns list of patients matching the name (partial match)
  Future<List<Map<String, dynamic>>> searchByName(String name) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
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
      if (token == null) {
        print('❌ No token available');
        return [];
      }

      final url = '$baseUrl/api/v1/patients?phone=$phone&name=$name';
      print('🌐 API Call: GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final patients = List<Map<String, dynamic>>.from(data['data']);
          print('✅ Parsed ${patients.length} patients');
          return patients;
        }
      }
      return [];
    } catch (e) {
      print('❌ Error searching by phone and name: $e');
      return [];
    }
  }

  /// Search patients by patient ID (exact match)
  Future<Map<String, dynamic>?> searchByPatientId(String patientId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await http.get(
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

      final response = await http.get(
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

      final response = await http.get(
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
