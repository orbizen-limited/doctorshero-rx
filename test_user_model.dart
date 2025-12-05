import 'dart:convert';

// Simulate UserModel
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isStaff;
  final String? registrationNumber;
  final String? specialization;
  final String? qualification;
  final String? bio;
  final Map<String, dynamic>? notificationPreferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? username;
  final bool? isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isStaff,
    this.registrationNumber,
    this.specialization,
    this.qualification,
    this.bio,
    this.notificationPreferences,
    this.createdAt,
    this.updatedAt,
    this.username,
    this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? notifPrefs;
    if (json['notification_preferences'] != null) {
      if (json['notification_preferences'] is Map) {
        notifPrefs = json['notification_preferences'] as Map<String, dynamic>;
      } else if (json['notification_preferences'] is List) {
        notifPrefs = {};
      }
    }
    
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      isStaff: json['is_staff'] ?? false,
      registrationNumber: json['registration_number'],
      specialization: json['specialization'],
      qualification: json['qualification'],
      bio: json['bio'],
      notificationPreferences: notifPrefs,
      username: json['username'],
      isActive: json['is_active'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

void main() {
  print('🧪 Testing UserModel with New API Response\n');
  
  // Simulate actual API response
  final apiResponse = {
    "id": 10,
    "name": "Dr. AFM Helal Uddin",
    "email": "dr.helal.uddin@gmail.com",
    "username": "afmhelaluddin",
    "phone": "01718572634",
    "role": "doctor",
    "is_active": true
  };
  
  print('📦 API Response:');
  print(JsonEncoder.withIndent('  ').convert(apiResponse));
  
  try {
    print('\n🔄 Parsing with UserModel.fromJson()...');
    final user = UserModel.fromJson(apiResponse);
    
    print('✅ SUCCESS! User parsed correctly:');
    print('  ID: ${user.id}');
    print('  Name: ${user.name}');
    print('  Email: ${user.email}');
    print('  Username: ${user.username}');
    print('  Phone: ${user.phone}');
    print('  Role: ${user.role}');
    print('  Is Active: ${user.isActive}');
    print('  Created At: ${user.createdAt ?? "null (OK)"}');
    print('  Updated At: ${user.updatedAt ?? "null (OK)"}');
    
    print('\n✅ UserModel is now compatible with new API!');
    
  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace: $stackTrace');
  }
}
