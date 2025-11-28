# 📱 Mobile API Documentation for Flutter App

##  Base URL
```
Production: https://doctorshero.com/api/v1
```

## 🔐 Mobile Authentication

All API endpoints (except authentication) require authentication using Laravel Sanctum tokens.

### Headers Required:
```http
Authorization: Bearer {your_token}
Content-Type: application/json
Accept: application/json
```

---

## 🔑 Authentication Endpoints

### 1. Mobile Login
```http
POST /api/mobile/auth/login
```

**Request Body:**
```json
{
    "email": "doctor@doctorshero.com",
    "password": "password123",
    "device_name": "iPhone 15 Pro" // Optional
}
```

**Response (Success):**
```json
{
    "success": true,
    "message": "Login successful",
    "user": {
        "id": 1,
        "name": "Dr. John Doe",
        "email": "doctor@doctorshero.com",
        "role": "doctor",
        "phone": "8801234567890",
        "is_staff": false,
        "notification_preferences": {
            "sms_notifications": true,
            "email_notifications": false
        },
        "created_at": "2025-01-01T00:00:00.000000Z",
        "updated_at": "2025-10-26T06:00:00.000000Z"
    },
    "token": "1|abc123def456ghi789...",
    "token_type": "Bearer",
    "expires_at": null
}
```

**Response (Error):**
```json
{
    "success": false,
    "message": "Invalid credentials"
}
```

**Response (Validation Error):**
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": ["The password field is required."]
    }
}
```

**Response (Rate Limited):**
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["Too many login attempts. Please try again in 300 seconds."]
    }
}
```

### 2. Mobile Logout
```http
POST /api/mobile/auth/logout
```

**Headers:**
```http
Authorization: Bearer {your_token}
```

**Response:**
```json
{
    "success": true,
    "message": "Logged out successfully"
}
```

### 3. Logout from All Devices
```http
POST /api/mobile/auth/logout-all
```

**Headers:**
```http
Authorization: Bearer {your_token}
```

**Response:**
```json
{
    "success": true,
    "message": "Logged out from all devices successfully"
}
```

### 4. Get Current User Profile
```http
GET /api/mobile/auth/me
```

**Headers:**
```http
Authorization: Bearer {your_token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Dr. John Doe",
        "email": "doctor@doctorshero.com",
        "role": "doctor",
        "phone": "8801234567890",
        "is_staff": false,
        "notification_preferences": {
            "sms_notifications": true,
            "email_notifications": false
        },
        "created_at": "2025-01-01T00:00:00.000000Z",
        "updated_at": "2025-10-26T06:00:00.000000Z"
    }
}
```

### 5. Refresh Token
```http
POST /api/mobile/auth/refresh
```

**Headers:**
```http
Authorization: Bearer {your_token}
```

**Request Body (Optional):**
```json
{
    "device_name": "iPhone 15 Pro"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Token refreshed successfully",
    "token": "2|new_token_here...",
    "token_type": "Bearer"
}
```

### 6. Check Authentication Status
```http
GET /api/mobile/auth/check
```

**Headers:**
```http
Authorization: Bearer {your_token}
```

**Response (Authenticated):**
```json
{
    "success": true,
    "authenticated": true,
    "user": {
        "id": 1,
        "name": "Dr. John Doe",
        "email": "doctor@doctorshero.com",
        "role": "doctor"
    }
}
```

**Response (Not Authenticated):**
```json
{
    "success": true,
    "authenticated": false,
    "user": null
}
```

---

## 📋 Appointment Management

### 1. Get All Appointments
```http
GET /api/v1/appointments
```

**Query Parameters:**
- `date` (optional): Filter by date (YYYY-MM-DD)
- `status` (optional): Filter by status (Scheduled, Confirmed, Check In, Completed, Cancelled)
- `patient_type` (optional): Filter by type (New, Old, Report)
- `search` (optional): Search by patient name or phone
- `per_page` (optional): Items per page (default: 20)
- `page` (optional): Page number

**Example Request:**
```http
GET /api/v1/appointments?date=2025-10-26&status=Scheduled&per_page=10
```

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "serial_number": 1,
            "appointment_date": "2025-10-26",
            "appointment_time": "09:00:00",
            "patient_name": "John Doe",
            "phone": "8801234567890",
            "patient_type": "New",
            "gender": "Male",
            "age": 35,
            "payment_amount": 500,
            "status": "Scheduled",
            "payment_status": "Pending",
            "doctor_id": 1,
            "created_at": "2025-10-26T05:30:00.000000Z",
            "updated_at": "2025-10-26T05:30:00.000000Z"
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 3,
        "per_page": 20,
        "total": 45,
        "has_more": true
    }
}
```

### 2. Get Single Appointment
```http
GET /api/v1/appointments/{id}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "serial_number": 1,
        "appointment_date": "2025-10-26",
        "appointment_time": "09:00:00",
        "patient_name": "John Doe",
        "phone": "8801234567890",
        "patient_type": "New",
        "gender": "Male",
        "age": 35,
        "payment_amount": 500,
        "status": "Scheduled",
        "payment_status": "Pending",
        "doctor_id": 1
    }
}
```

### 3. Create New Appointment (with duplicate validation)
```http
POST /api/v1/appointments
```

**Request Body:**
```json
{
    "appointment_date": "2025-10-27",
    "appointment_time": "10:00",
    "patient_type": "New",
    "patient_name": "Jane Smith",
    "phone": "8801987654321",
    "payment_amount": 600,
    "gender": "Female",
    "age": 28
}
```

**Response (Success - New Patient):**
```json
{
    "success": true,
    "data": {
        "appointment": {
            "id": 2,
            "serial_number": 2,
            "appointment_date": "2025-10-27",
            "appointment_time": "10:00:00",
            "patient_name": "Jane Smith",
            "phone": "8801987654321",
            "patient_type": "New",
            "gender": "Female",
            "age": 28,
            "payment_amount": 600,
            "status": "Scheduled",
            "payment_status": "Pending",
            "doctor_id": 1
        },
        "patient": {
            "id": 2,
            "name": "Jane Smith",
            "phone": "8801987654321",
            "gender": "Female",
            "age": 28
        },
        "serial_number": 2
    },
    "sms_status": {
        "success": true,
        "message": "SMS sent successfully"
    },
    "message": "Appointment created successfully"
}
```

**Response (Duplicate Found - Requires Confirmation):**
```json
{
    "success": false,
    "requires_confirmation": true,
    "similar_patients": [
        {
            "id": 1,
            "name": "John Doe",
            "phone": "8801234567890",
            "age": 35,
            "gender": "Male",
            "last_visit": "2025-10-25"
        }
    ],
    "message": "Similar patients found. Please confirm if you want to select existing patient or create new one."
}
```

### 4. Create Appointment with Patient Selection
```http
POST /api/v1/appointments/with-patient
```

**Request Body (Existing Patient):**
```json
{
    "appointment_date": "2025-10-27",
    "appointment_time": "11:00",
    "patient_type": "Old",
    "payment_amount": 400,
    "selected_patient_id": "1"
}
```

**Request Body (New Patient):**
```json
{
    "appointment_date": "2025-10-27",
    "appointment_time": "11:00",
    "patient_type": "New",
    "payment_amount": 600,
    "selected_patient_id": "new",
    "patient_name": "Alice Johnson",
    "phone": "8801555666777",
    "gender": "Female",
    "age": 32
}
```

### 5. Update Appointment
```http
PUT /api/v1/appointments/{id}
```

**Request Body (partial update allowed):**
```json
{
    "status": "Completed",
    "payment_status": "Paid"
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "status": "Completed",
        "payment_status": "Paid"
    },
    "message": "Appointment updated successfully"
}
```

### 6. Delete Appointment
```http
DELETE /api/v1/appointments/{id}
```

**Response:**
```json
{
    "success": true,
    "message": "Appointment deleted successfully"
}
```

### 7. Send SMS for Appointment
```http
POST /api/v1/appointments/{id}/send-sms
```

**Response (Success):**
```json
{
    "success": true,
    "message": "SMS sent successfully",
    "sms_status": {
        "success": true,
        "provider": "mimsms",
        "transaction_id": "TXN123456"
    }
}
```

**Response (SMS Disabled):**
```json
{
    "success": true,
    "message": "SMS notification is disabled in settings",
    "sms_status": {
        "success": true,
        "skipped": true
    }
}
```

**Response (SMS Failed):**
```json
{
    "success": false,
    "message": "SMS failed: IP Black List",
    "sms_status": {
        "success": false,
        "message": "IP Black List",
        "provider": "mimsms"
    }
}
```

---

## 👥 Patient Management

### 1. Get Patients List
```http
GET /api/v1/patients
```

**Query Parameters:**
- `search` (optional): Search by name or phone
- `gender` (optional): Filter by gender (Male, Female, Other)
- `per_page` (optional): Items per page (default: 20)
- `page` (optional): Page number

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "John Doe",
            "phone": "8801234567890",
            "gender": "Male",
            "age": 35,
            "last_visit": "2025-10-25T10:30:00.000000Z",
            "created_at": "2025-10-20T08:00:00.000000Z"
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 2,
        "per_page": 20,
        "total": 25,
        "has_more": true
    }
}
```

### 2. Search Similar Patients
```http
POST /api/v1/patients/search-similar
```

**Request Body:**
```json
{
    "phone": "8801234567890"
}
```

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "John Doe",
            "phone": "8801234567890",
            "age": 35,
            "gender": "Male",
            "last_visit": "2025-10-25"
        }
    ],
    "count": 1
}
```

---

## 📊 Statistics & Utilities

### 1. Get Appointment Statistics
```http
GET /api/v1/stats/appointments
```

**Query Parameters:**
- `date` (optional): Date for statistics (default: today)

**Response:**
```json
{
    "success": true,
    "data": {
        "today_total": 15,
        "today_completed": 8,
        "today_pending": 5,
        "today_cancelled": 2,
        "total_patients": 150,
        "this_month_appointments": 320
    },
    "date": "2025-10-26"
}
```

### 2. Get Default Price
```http
GET /api/v1/appointment-price/{patientType}
```

**Example:**
```http
GET /api/v1/appointment-price/New
```

**Response:**
```json
{
    "success": true,
    "data": {
        "patient_type": "New",
        "price": 600
    }
}
```

### 3. Get User Profile
```http
GET /api/v1/profile
```

**Response:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Dr. John Doe",
        "email": "doctor@doctorshero.com",
        "role": "doctor",
        "phone": "8801234567890",
        "notification_preferences": {
            "sms_notifications": true,
            "email_notifications": false
        }
    }
}
```

---

## 🔧 Error Handling

### Standard Error Response Format:
```json
{
    "success": false,
    "message": "Error description",
    "errors": {
        "field_name": ["Validation error message"]
    }
}
```

### HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized (Invalid token)
- `403` - Forbidden (Access denied)
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

### Common Error Scenarios:

**1. Unauthorized Access:**
```json
{
    "success": false,
    "message": "Unauthenticated"
}
```

**2. Validation Error:**
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "phone": ["The phone field is required."],
        "appointment_date": ["The appointment date must be a date after or equal to today."]
    }
}
```

**3. Resource Not Found:**
```json
{
    "success": false,
    "message": "Appointment not found"
}
```

---

## 🔄 Flutter Integration Examples

### 1. Setup HTTP Client (Using Dio)

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://yourdomain.com/api';
  static const String authBaseUrl = '$baseUrl/mobile/auth';
  static const String v1BaseUrl = '$baseUrl/v1';
  
  late Dio _dio;
  String? _token;

  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for token and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid, redirect to login
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
    
    // Load saved token
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  void _handleUnauthorized() {
    _clearToken();
    // Navigate to login screen
    // NavigationService.navigateToLogin();
  }
}
```

### 2. Authentication Functions

```dart
// Login function
Future<Map<String, dynamic>> login(String email, String password, {String? deviceName}) async {
  try {
    final response = await _dio.post('$authBaseUrl/login', data: {
      'email': email,
      'password': password,
      'device_name': deviceName ?? 'Flutter App',
    });
    
    if (response.data['success']) {
      await _saveToken(response.data['token']);
      return response.data;
    } else {
      throw Exception(response.data['message']);
    }
  } catch (e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      }
    }
    throw Exception('Login failed: $e');
  }
}

// Logout function
Future<bool> logout() async {
  try {
    await _dio.post('$authBaseUrl/logout');
    await _clearToken();
    return true;
  } catch (e) {
    // Even if logout fails on server, clear local token
    await _clearToken();
    return false;
  }
}

// Logout from all devices
Future<bool> logoutAll() async {
  try {
    await _dio.post('$authBaseUrl/logout-all');
    await _clearToken();
    return true;
  } catch (e) {
    await _clearToken();
    return false;
  }
}

// Get current user
Future<Map<String, dynamic>?> getCurrentUser() async {
  try {
    final response = await _dio.get('$authBaseUrl/me');
    if (response.data['success']) {
      return response.data['data'];
    }
    return null;
  } catch (e) {
    return null;
  }
}

// Check authentication status
Future<bool> isAuthenticated() async {
  try {
    final response = await _dio.get('$authBaseUrl/check');
    return response.data['authenticated'] ?? false;
  } catch (e) {
    return false;
  }
}

// Refresh token
Future<String?> refreshToken({String? deviceName}) async {
  try {
    final response = await _dio.post('$authBaseUrl/refresh', data: {
      'device_name': deviceName ?? 'Flutter App',
    });
    
    if (response.data['success']) {
      await _saveToken(response.data['token']);
      return response.data['token'];
    }
    return null;
  } catch (e) {
    return null;
  }
}
```

### 3. Get Appointments

```dart
Future<List<Appointment>> getAppointments({
  String? date,
  String? status,
  int page = 1,
}) async {
  try {
    final response = await _dio.get('$v1BaseUrl/appointments', queryParameters: {
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      'page': page,
    });

    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } else {
      throw Exception(response.data['message']);
    }
  } catch (e) {
    throw Exception('Failed to fetch appointments: $e');
  }
}
```

### 4. Create Appointment

```dart
Future<Map<String, dynamic>> createAppointment({
  required String appointmentDate,
  required String appointmentTime,
  required String patientType,
  required String patientName,
  required String phone,
  required double paymentAmount,
  required String gender,
  required int age,
}) async {
  try {
    final response = await _dio.post('$v1BaseUrl/appointments', data: {
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'patient_type': patientType,
      'patient_name': patientName,
      'phone': phone,
      'payment_amount': paymentAmount,
      'gender': gender,
      'age': age,
    });

    return response.data;
  } catch (e) {
    throw Exception('Failed to create appointment: $e');
  }
}
```

### 5. Send SMS

```dart
Future<bool> sendAppointmentSms(int appointmentId) async {
  try {
    final response = await _dio.post('$v1BaseUrl/appointments/$appointmentId/send-sms');
    return response.data['success'] ?? false;
  } catch (e) {
    throw Exception('Failed to send SMS: $e');
  }
}
```

---

## 📱 Data Models for Flutter

### Appointment Model

```dart
class Appointment {
  final int id;
  final int serialNumber;
  final String appointmentDate;
  final String appointmentTime;
  final String patientName;
  final String phone;
  final String patientType;
  final String gender;
  final int age;
  final double paymentAmount;
  final String status;
  final String paymentStatus;
  final int doctorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.serialNumber,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.patientName,
    required this.phone,
    required this.patientType,
    required this.gender,
    required this.age,
    required this.paymentAmount,
    required this.status,
    required this.paymentStatus,
    required this.doctorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      serialNumber: json['serial_number'],
      appointmentDate: json['appointment_date'],
      appointmentTime: json['appointment_time'],
      patientName: json['patient_name'],
      phone: json['phone'],
      patientType: json['patient_type'],
      gender: json['gender'],
      age: json['age'],
      paymentAmount: double.parse(json['payment_amount'].toString()),
      status: json['status'],
      paymentStatus: json['payment_status'],
      doctorId: json['doctor_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'patient_name': patientName,
      'phone': phone,
      'patient_type': patientType,
      'gender': gender,
      'age': age,
      'payment_amount': paymentAmount,
      'status': status,
      'payment_status': paymentStatus,
      'doctor_id': doctorId,
    };
  }
}
```

### Patient Model

```dart
class Patient {
  final int id;
  final String name;
  final String phone;
  final String gender;
  final int age;
  final DateTime? lastVisit;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    this.lastVisit,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'],
      age: json['age'],
      lastVisit: json['last_visit'] != null 
          ? DateTime.parse(json['last_visit']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

---

## 🧪 Testing the API

### Using Postman/Thunder Client:

1. **Set Base URL:** `https://yourdomain.com/api`
2. **Login first:** `POST /login` to get token
3. **Set Authorization:** Bearer token for all v1 endpoints
4. **Test endpoints:** Start with `/v1/appointments` and `/v1/patients`

### Sample cURL Commands:

```bash
# Login
curl -X POST https://yourdomain.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"doctor@doctorshero.com","password":"password123"}'

# Get appointments (replace TOKEN with actual token)
curl -X GET https://yourdomain.com/api/v1/appointments \
  -H "Authorization: Bearer TOKEN" \
  -H "Accept: application/json"

# Create appointment
curl -X POST https://yourdomain.com/api/v1/appointments \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "appointment_date": "2025-10-27",
    "appointment_time": "10:00",
    "patient_type": "New",
    "patient_name": "Test Patient",
    "phone": "8801234567890",
    "payment_amount": 600,
    "gender": "Male",
    "age": 30
  }'
```

---

## 🔒 Security Features

1. **Laravel Sanctum Authentication** - Token-based auth
2. **Authorization Checks** - Only appointment owner can access/modify
3. **Input Validation** - Comprehensive validation rules
4. **Rate Limiting** - Prevents API abuse
5. **CORS Support** - Configured for mobile apps
6. **Error Handling** - Consistent error responses

---

## 📈 Performance Considerations

1. **Pagination** - All list endpoints support pagination
2. **Filtering** - Reduce data transfer with query parameters
3. **Caching** - Consider caching frequently accessed data
4. **Lazy Loading** - Load appointment details on demand
5. **Background Sync** - Sync data in background for offline support

---

This comprehensive API documentation provides everything you need to integrate your Flutter mobile app with the Doctors Hero backend! 
