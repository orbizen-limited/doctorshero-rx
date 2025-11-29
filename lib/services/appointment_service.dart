import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static const String baseUrl = 'https://demo.doctorshero.com/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getAppointments({
    String? date,
    String? status,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (date != null && date.isNotEmpty) 'date': date,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('$baseUrl/appointments')
          .replace(queryParameters: queryParams);
      
      print('Fetching appointments from: $uri');
      final response = await http.get(uri, headers: headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final appointmentsList = data['data'] as List;
          print('Found ${appointmentsList.length} appointments');
          
          final appointments = appointmentsList
              .map((json) {
                try {
                  return Appointment.fromJson(json);
                } catch (e) {
                  print('Error parsing appointment: $e');
                  print('Problematic JSON: $json');
                  rethrow;
                }
              })
              .toList();
          
          return {
            'appointments': appointments,
            'total': data['total'] ?? 0,
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
          };
        } else {
          throw Exception(data['message'] ?? 'API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Exception in getAppointments: $e');
      throw Exception('Error: $e');
    }
  }

  Future<AppointmentStats> getAppointmentStats({String? date}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        if (date != null && date.isNotEmpty) 'date': date,
      };

      final uri = Uri.parse('$baseUrl/stats/appointments')
          .replace(queryParameters: queryParams);
      
      print('Fetching stats from: $uri');
      final response = await http.get(uri, headers: headers);
      print('Stats response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Stats response: $data');
        if (data['success'] == true) {
          return AppointmentStats.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Exception in getAppointmentStats: $e');
      throw Exception('Error: $e');
    }
  }

  Future<bool> updateAppointmentStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$id'),
        headers: headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> updatePaymentStatus(int id, String paymentStatus) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$id'),
        headers: headers,
        body: json.encode({'payment_status': paymentStatus}),
      );

      print('Update payment status response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteAppointment(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/appointments/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
