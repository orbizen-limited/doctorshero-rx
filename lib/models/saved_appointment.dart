import 'package:hive/hive.dart';
import 'appointment_model.dart';

part 'saved_appointment.g.dart';

@HiveType(typeId: 2)
class SavedAppointment extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int serialNumber;

  @HiveField(2)
  String appointmentDate;

  @HiveField(3)
  String appointmentTime;

  @HiveField(4)
  String patientName;

  @HiveField(5)
  String phone;

  @HiveField(6)
  String patientType;

  @HiveField(7)
  String gender;

  @HiveField(8)
  int age;

  @HiveField(9)
  String status;

  @HiveField(10)
  String paymentStatus;

  @HiveField(11)
  int paymentAmount;

  @HiveField(12)
  String? location;

  @HiveField(13)
  int? patientId;

  @HiveField(14)
  String? patientPid;

  @HiveField(15)
  bool hasPatientRecord;

  @HiveField(16)
  DateTime createdAt;

  @HiveField(17)
  DateTime updatedAt;

  @HiveField(18)
  DateTime cachedAt;

  SavedAppointment({
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
    this.patientId,
    this.patientPid,
    required this.hasPatientRecord,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  // Create from API Appointment
  factory SavedAppointment.fromAppointment(Appointment appointment) {
    return SavedAppointment(
      id: appointment.id,
      serialNumber: appointment.serialNumber,
      appointmentDate: appointment.appointmentDate,
      appointmentTime: appointment.appointmentTime,
      patientName: appointment.patientName,
      phone: appointment.phone,
      patientType: appointment.patientType,
      gender: appointment.gender,
      age: appointment.age,
      status: appointment.status,
      paymentStatus: appointment.paymentStatus,
      paymentAmount: appointment.paymentAmount,
      location: appointment.location,
      patientId: appointment.patientId,
      patientPid: appointment.patientPid,
      hasPatientRecord: appointment.hasPatientRecord,
      createdAt: appointment.createdAt,
      updatedAt: appointment.updatedAt,
      cachedAt: DateTime.now(),
    );
  }

  // Convert to Appointment
  Appointment toAppointment() {
    return Appointment(
      id: id,
      serialNumber: serialNumber,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      patientName: patientName,
      phone: phone,
      patientType: patientType,
      gender: gender,
      age: age,
      status: status,
      paymentStatus: paymentStatus,
      paymentAmount: paymentAmount,
      location: location,
      patientId: patientId,
      patientPid: patientPid,
      hasPatientRecord: hasPatientRecord,
      patientInfo: null, // Not cached for simplicity
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@HiveType(typeId: 3)
class SavedAppointmentStats extends HiveObject {
  @HiveField(0)
  int totalAppointments;

  @HiveField(1)
  int pendingTasks;

  @HiveField(2)
  int completedTask;

  @HiveField(3)
  int cancelledTask;

  @HiveField(4)
  DateTime cachedAt;

  SavedAppointmentStats({
    required this.totalAppointments,
    required this.pendingTasks,
    required this.completedTask,
    required this.cancelledTask,
    required this.cachedAt,
  });

  factory SavedAppointmentStats.fromStats(AppointmentStats stats) {
    return SavedAppointmentStats(
      totalAppointments: stats.totalAppointments,
      pendingTasks: stats.pendingTasks,
      completedTask: stats.completedTask,
      cancelledTask: stats.cancelledTask,
      cachedAt: DateTime.now(),
    );
  }

  AppointmentStats toStats() {
    return AppointmentStats(
      totalAppointments: totalAppointments,
      pendingTasks: pendingTasks,
      completedTask: completedTask,
      cancelledTask: cancelledTask,
    );
  }
}
