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
  
  // Raw structured data for drawers
  List<Map<String, String>>? chiefComplaintData;
  Map<String, dynamic>? examinationData;
  List<Map<String, dynamic>>? historyData;
  List<Map<String, String>>? diagnosisData;
  List<Map<String, String>>? investigationData;

  ClinicalData({
    this.chiefComplaint = '',
    this.examination = '',
    this.history = '',
    this.diagnosis = '',
    this.investigation = '',
    this.chiefComplaintData,
    this.examinationData,
    this.historyData,
    this.diagnosisData,
    this.investigationData,
  });

  factory ClinicalData.fromJson(Map<String, dynamic> json) {
    return ClinicalData(
      chiefComplaint: json['chief_complaint'] ?? '',
      examination: json['examination'] ?? '',
      history: json['history'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      investigation: json['investigation'] ?? '',
      chiefComplaintData: json['chief_complaint_data'] != null 
          ? List<Map<String, String>>.from((json['chief_complaint_data'] as List).map((e) => Map<String, String>.from(e)))
          : null,
      examinationData: json['examination_data'],
      historyData: json['history_data'] != null
          ? List<Map<String, dynamic>>.from(json['history_data'])
          : null,
      diagnosisData: json['diagnosis_data'] != null
          ? List<Map<String, String>>.from((json['diagnosis_data'] as List).map((e) => Map<String, String>.from(e)))
          : null,
      investigationData: json['investigation_data'] != null
          ? List<Map<String, String>>.from((json['investigation_data'] as List).map((e) => Map<String, String>.from(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chief_complaint': chiefComplaint,
      'examination': examination,
      'history': history,
      'diagnosis': diagnosis,
      'investigation': investigation,
      'chief_complaint_data': chiefComplaintData,
      'examination_data': examinationData,
      'history_data': historyData,
      'diagnosis_data': diagnosisData,
      'investigation_data': investigationData,
    };
  }
}
