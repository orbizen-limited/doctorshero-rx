import 'package:hive/hive.dart';
import '../models/saved_appointment.dart';
import '../models/appointment_model.dart';

class AppointmentDatabaseService {
  static const String _appointmentsBoxName = 'appointments';
  static const String _statsBoxName = 'appointment_stats';

  // Initialize Hive boxes and register adapters
  static Future<void> init() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SavedAppointmentAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SavedAppointmentStatsAdapter());
    }

    // Open boxes
    await Hive.openBox<SavedAppointment>(_appointmentsBoxName);
    await Hive.openBox<SavedAppointmentStats>(_statsBoxName);
  }

  // Get appointments box
  Box<SavedAppointment> _getAppointmentsBox() {
    return Hive.box<SavedAppointment>(_appointmentsBoxName);
  }

  // Get stats box
  Box<SavedAppointmentStats> _getStatsBox() {
    return Hive.box<SavedAppointmentStats>(_statsBoxName);
  }

  // Save appointments (replace all)
  Future<void> saveAppointments(List<Appointment> appointments) async {
    final box = _getAppointmentsBox();
    await box.clear();
    
    for (final appointment in appointments) {
      final saved = SavedAppointment.fromAppointment(appointment);
      await box.put(appointment.id, saved);
    }
  }

  // Get all appointments
  List<Appointment> getAllAppointments() {
    final box = _getAppointmentsBox();
    return box.values.map((saved) => saved.toAppointment()).toList();
  }

  // Get appointments by date
  List<Appointment> getAppointmentsByDate(String date) {
    final box = _getAppointmentsBox();
    return box.values
        .where((saved) => saved.appointmentDate == date)
        .map((saved) => saved.toAppointment())
        .toList();
  }

  // Save stats
  Future<void> saveStats(AppointmentStats stats) async {
    final box = _getStatsBox();
    final saved = SavedAppointmentStats.fromStats(stats);
    await box.put('current', saved);
  }

  // Get stats
  AppointmentStats? getStats() {
    final box = _getStatsBox();
    final saved = box.get('current');
    return saved?.toStats();
  }

  // Check if cache is fresh (less than 5 minutes old)
  bool isCacheFresh() {
    final box = _getStatsBox();
    final saved = box.get('current');
    if (saved == null) return false;
    
    final age = DateTime.now().difference(saved.cachedAt);
    return age.inMinutes < 5;
  }

  // Get cache age in minutes
  int? getCacheAgeMinutes() {
    final box = _getStatsBox();
    final saved = box.get('current');
    if (saved == null) return null;
    
    return DateTime.now().difference(saved.cachedAt).inMinutes;
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _getAppointmentsBox().clear();
    await _getStatsBox().clear();
  }

  // Update appointment status locally
  Future<void> updateAppointmentStatus(int id, String status) async {
    final box = _getAppointmentsBox();
    final appointment = box.get(id);
    if (appointment != null) {
      appointment.status = status;
      await appointment.save();
    }
  }

  // Update payment status locally
  Future<void> updatePaymentStatus(int id, String paymentStatus) async {
    final box = _getAppointmentsBox();
    final appointment = box.get(id);
    if (appointment != null) {
      appointment.paymentStatus = paymentStatus;
      await appointment.save();
    }
  }
}
