import 'package:hive/hive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/saved_prescription.dart';
import '../models/saved_medicine.dart';

class PrescriptionDatabaseService {
  static const String _boxName = 'prescriptions';
  
  // Get the Hive box
  Box<SavedPrescription> get _box => Hive.box<SavedPrescription>(_boxName);

  // Initialize the database (call this in main.dart)
  static Future<void> init() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SavedPrescriptionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SavedMedicineAdapter());
    }
    
    // Check if box is already open
    if (Hive.isBoxOpen(_boxName)) {
      return;
    }
    
    // Open the box with error handling for lock files
    try {
      await Hive.openBox<SavedPrescription>(_boxName);
    } on PathAccessException catch (e) {
      // Handle lock file issues - try to delete stale lock file
      if (e.message.contains('lock')) {
        try {
          final documentsDir = await getApplicationDocumentsDirectory();
          final lockFile = File('${documentsDir.path}/$_boxName.lock');
          if (await lockFile.exists()) {
            await lockFile.delete();
            // Retry opening the box
            await Hive.openBox<SavedPrescription>(_boxName);
          }
        } catch (_) {
          // If box is already open, that's fine - ignore the error
          if (!Hive.isBoxOpen(_boxName)) {
            // If we still can't open it, just log and continue
            // The app can still run, but database operations will fail
            print('Warning: Could not open prescriptions box due to lock file');
          }
        }
      } else {
        // For other PathAccessException, just log and continue
        print('Warning: Could not open prescriptions box: ${e.message}');
      }
    } catch (e) {
      // For any other exception, log and continue
      print('Warning: Could not open prescriptions box: $e');
    }
  }

  // Save a prescription
  Future<void> savePrescription(SavedPrescription prescription) async {
    await _box.put(prescription.id, prescription);
  }

  // Get all prescriptions (sorted by date, newest first)
  List<SavedPrescription> getAllPrescriptions() {
    final prescriptions = _box.values.toList();
    prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return prescriptions;
  }

  // Get a prescription by ID
  SavedPrescription? getPrescriptionById(String id) {
    return _box.get(id);
  }

  // Update a prescription
  Future<void> updatePrescription(SavedPrescription prescription) async {
    prescription.updatedAt = DateTime.now();
    await _box.put(prescription.id, prescription);
  }

  // Delete a prescription
  Future<void> deletePrescription(String id) async {
    await _box.delete(id);
  }

  // Search prescriptions by patient name
  List<SavedPrescription> searchByPatientName(String query) {
    if (query.isEmpty) return getAllPrescriptions();
    
    final lowerQuery = query.toLowerCase();
    final prescriptions = _box.values.where((prescription) {
      return prescription.patientName.toLowerCase().contains(lowerQuery) ||
             prescription.patientId.toLowerCase().contains(lowerQuery);
    }).toList();
    
    prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return prescriptions;
  }

  // Get prescriptions by date range
  List<SavedPrescription> getPrescriptionsByDateRange(DateTime start, DateTime end) {
    final prescriptions = _box.values.where((prescription) {
      return prescription.createdAt.isAfter(start) && 
             prescription.createdAt.isBefore(end);
    }).toList();
    
    prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return prescriptions;
  }

  // Get prescriptions count
  int getPrescriptionCount() {
    return _box.length;
  }

  // Get today's prescriptions
  List<SavedPrescription> getTodaysPrescriptions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return getPrescriptionsByDateRange(today, tomorrow);
  }

  // Get this week's prescriptions
  List<SavedPrescription> getWeeklyPrescriptions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return getPrescriptionsByDateRange(weekStartDate, now);
  }

  // Get this month's prescriptions
  List<SavedPrescription> getMonthlyPrescriptions() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    return getPrescriptionsByDateRange(monthStart, now);
  }

  // Clear all prescriptions (use with caution!)
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Export prescription data (for backup)
  Map<String, dynamic> exportPrescription(String id) {
    final prescription = getPrescriptionById(id);
    if (prescription == null) return {};
    
    return {
      'id': prescription.id,
      'patient_name': prescription.patientName,
      'patient_id': prescription.patientId,
      'age': prescription.age,
      'gender': prescription.gender,
      'phone': prescription.phone,
      'blood_group': prescription.bloodGroup,
      'address': prescription.address,
      'created_at': prescription.createdAt.toIso8601String(),
      'updated_at': prescription.updatedAt?.toIso8601String(),
      'chief_complaint': prescription.chiefComplaint,
      'examination': prescription.examination,
      'history': prescription.history,
      'diagnosis': prescription.diagnosis,
      'investigation': prescription.investigation,
      'medicines': prescription.medicines.map((m) => {
        'id': m.id,
        'type': m.type,
        'name': m.name,
        'generic_name': m.genericName,
        'composition': m.composition,
        'dosage': m.dosage,
        'duration': m.duration,
        'advice': m.advice,
        'route': m.route,
        'special_instructions': m.specialInstructions,
        'quantity': m.quantity,
        'frequency': m.frequency,
        'interval': m.interval,
        'till_number': m.tillNumber,
        'till_unit': m.tillUnit,
      }).toList(),
      'advice_list': prescription.adviceList,
      'follow_up_date': prescription.followUpDate?.toIso8601String(),
      'referral_text': prescription.referralText,
      'doctor_name': prescription.doctorName,
      'doctor_registration': prescription.doctorRegistration,
      'doctor_specialization': prescription.doctorSpecialization,
      'doctor_qualification': prescription.doctorQualification,
    };
  }
}
