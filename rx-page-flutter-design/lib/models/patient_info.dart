class PatientInfo {
  final String name;
  final String age;
  final String gender;
  final String date;
  final String patientId;

  PatientInfo({
    required this.name,
    required this.age,
    required this.gender,
    required this.date,
    required this.patientId,
  });
}

class ClinicalData {
  final String chiefComplaint;
  final String examination;
  final String history;
  final String diagnosis;
  final String investigation;

  ClinicalData({
    required this.chiefComplaint,
    required this.examination,
    required this.history,
    required this.diagnosis,
    required this.investigation,
  });
}
