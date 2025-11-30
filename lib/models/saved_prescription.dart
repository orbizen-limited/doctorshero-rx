import 'package:hive/hive.dart';
import 'saved_medicine.dart';
import 'medicine_model.dart';
import 'prescription_model.dart';

part 'saved_prescription.g.dart';

@HiveType(typeId: 0)
class SavedPrescription extends HiveObject {
  // Unique ID
  @HiveField(0)
  String id;

  // Patient Information
  @HiveField(1)
  String patientName;

  @HiveField(2)
  String patientId;

  @HiveField(3)
  String age;

  @HiveField(4)
  String gender;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  String? bloodGroup;

  @HiveField(7)
  String? address;

  // Timestamps
  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  // Clinical Data
  @HiveField(10)
  String chiefComplaint;

  @HiveField(11)
  String examination;

  @HiveField(12)
  String history;

  @HiveField(13)
  String diagnosis;

  @HiveField(14)
  String investigation;

  // Medicines
  @HiveField(15)
  List<SavedMedicine> medicines;

  // Advice & Follow-up
  @HiveField(16)
  List<String> adviceList;

  @HiveField(17)
  DateTime? followUpDate;

  @HiveField(18)
  String? referralText;

  // Doctor Info
  @HiveField(19)
  String? doctorName;

  @HiveField(20)
  String? doctorRegistration;

  @HiveField(21)
  String? doctorSpecialization;

  @HiveField(22)
  String? doctorQualification;

  SavedPrescription({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.age,
    required this.gender,
    this.phone,
    this.bloodGroup,
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.chiefComplaint = '',
    this.examination = '',
    this.history = '',
    this.diagnosis = '',
    this.investigation = '',
    required this.medicines,
    required this.adviceList,
    this.followUpDate,
    this.referralText,
    this.doctorName,
    this.doctorRegistration,
    this.doctorSpecialization,
    this.doctorQualification,
  });

  // Create from prescription screen data
  factory SavedPrescription.create({
    required String id,
    required PrescriptionPatientInfo patientInfo,
    required ClinicalData clinicalData,
    required List<Medicine> medicines,
    required List<String> adviceList,
    DateTime? followUpDate,
    String? referralText,
    String? doctorName,
    String? doctorRegistration,
    String? doctorSpecialization,
    String? doctorQualification,
  }) {
    return SavedPrescription(
      id: id,
      patientName: patientInfo.name,
      patientId: patientInfo.patientId,
      age: patientInfo.age,
      gender: patientInfo.gender,
      phone: patientInfo.phone,
      bloodGroup: patientInfo.bloodGroup,
      address: patientInfo.address,
      createdAt: DateTime.now(),
      chiefComplaint: clinicalData.chiefComplaint,
      examination: clinicalData.examination,
      history: clinicalData.history,
      diagnosis: clinicalData.diagnosis,
      investigation: clinicalData.investigation,
      medicines: medicines.map((m) => SavedMedicine.fromMedicine(m)).toList(),
      adviceList: adviceList,
      followUpDate: followUpDate,
      referralText: referralText,
      doctorName: doctorName,
      doctorRegistration: doctorRegistration,
      doctorSpecialization: doctorSpecialization,
      doctorQualification: doctorQualification,
    );
  }

  // Convert back to display models
  PrescriptionPatientInfo toPatientInfo() {
    return PrescriptionPatientInfo(
      name: patientName,
      age: age,
      gender: gender,
      date: createdAt.toString().split(' ')[0],
      patientId: patientId,
      phone: phone,
      bloodGroup: bloodGroup,
      address: address,
    );
  }

  ClinicalData toClinicalData() {
    return ClinicalData(
      chiefComplaint: chiefComplaint,
      examination: examination,
      history: history,
      diagnosis: diagnosis,
      investigation: investigation,
    );
  }

  List<Medicine> toMedicineList() {
    return medicines.map((m) => m.toMedicine()).toList();
  }

  // Get formatted date for display
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get formatted time for display
  String get formattedTime {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  // Get medicine count
  int get medicineCount => medicines.length;
}
