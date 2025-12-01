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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle notification_preferences which might be Map or List from API
    Map<String, dynamic>? notifPrefs;
    if (json['notification_preferences'] != null) {
      if (json['notification_preferences'] is Map) {
        notifPrefs = json['notification_preferences'] as Map<String, dynamic>;
      } else if (json['notification_preferences'] is List) {
        // If it's a list, convert to empty map or handle as needed
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'is_staff': isStaff,
      'registration_number': registrationNumber,
      'specialization': specialization,
      'qualification': qualification,
      'bio': bio,
      'notification_preferences': notificationPreferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
