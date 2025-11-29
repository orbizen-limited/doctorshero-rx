class PrescriptionPatientInfo {
  final String name;
  final String age;
  final String gender;
  final String date;
  final String patientId;
  final String? phone;
  final String? bloodGroup;
  final String? address;

  PrescriptionPatientInfo({
    required this.name,
    required this.age,
    required this.gender,
    required this.date,
    required this.patientId,
    this.phone,
    this.bloodGroup,
    this.address,
  });

  factory PrescriptionPatientInfo.fromJson(Map<String, dynamic> json) {
    return PrescriptionPatientInfo(
      name: json['name'] ?? '',
      age: json['age']?.toString() ?? '',
      gender: json['gender'] ?? '',
      date: json['date'] ?? DateTime.now().toString().split(' ')[0],
      patientId: json['patient_id'] ?? '',
      phone: json['phone'],
      bloodGroup: json['blood_group'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'date': date,
      'patient_id': patientId,
      if (phone != null) 'phone': phone,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (address != null) 'address': address,
    };
  }
}

class ClinicalData {
  String chiefComplaint;
  String examination;
  String history;
  String diagnosis;
  String investigation;

  ClinicalData({
    this.chiefComplaint = '',
    this.examination = '',
    this.history = '',
    this.diagnosis = '',
    this.investigation = '',
  });

  factory ClinicalData.fromJson(Map<String, dynamic> json) {
    return ClinicalData(
      chiefComplaint: json['chief_complaint'] ?? '',
      examination: json['examination'] ?? '',
      history: json['history'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      investigation: json['investigation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chief_complaint': chiefComplaint,
      'examination': examination,
      'history': history,
      'diagnosis': diagnosis,
      'investigation': investigation,
    };
  }
}
