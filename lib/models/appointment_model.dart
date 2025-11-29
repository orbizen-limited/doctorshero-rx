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
  final String status;
  final String paymentStatus;
  final int paymentAmount;
  final String? location;
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
    required this.status,
    required this.paymentStatus,
    required this.paymentAmount,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: _parseInt(json['id']),
      serialNumber: _parseInt(json['serial_number']),
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      patientName: json['patient_name'] ?? '',
      phone: json['phone'] ?? '',
      patientType: json['patient_type'] ?? '',
      gender: json['gender'] ?? '',
      age: _parseInt(json['age']),
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentAmount: _parseInt(json['payment_amount']),
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Try parsing as double first, then convert to int
      final doubleValue = double.tryParse(value);
      if (doubleValue != null) return doubleValue.toInt();
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
      'status': status,
      'payment_status': paymentStatus,
      'payment_amount': paymentAmount,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AppointmentStats {
  final int totalAppointments;
  final int pendingTasks;
  final int completedTask;
  final int cancelledTask;

  AppointmentStats({
    required this.totalAppointments,
    required this.pendingTasks,
    required this.completedTask,
    required this.cancelledTask,
  });

  factory AppointmentStats.fromJson(Map<String, dynamic> json) {
    return AppointmentStats(
      totalAppointments: json['total_appointments'] ?? 0,
      pendingTasks: json['today_pending'] ?? 0,
      completedTask: json['today_completed'] ?? 0,
      cancelledTask: json['today_cancelled'] ?? 0,
    );
  }
}
