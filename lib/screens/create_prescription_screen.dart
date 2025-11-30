import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine_model.dart';
import '../models/prescription_model.dart';
import '../widgets/patient_info_card.dart';
import '../widgets/clinical_sections.dart';
import '../widgets/medicine_list.dart';
import '../widgets/prescription_footer.dart';
import '../services/prescription_print_service.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;
  final String? patientAge;
  final String? patientGender;
  final String? patientPhone;

  const CreatePrescriptionScreen({
    Key? key,
    this.patientId,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.patientPhone,
  }) : super(key: key);

  @override
  State<CreatePrescriptionScreen> createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  List<Medicine> medicines = [];
  late PrescriptionPatientInfo patientInfo;
  late ClinicalData clinicalData;
  List<String> adviceList = [];
  DateTime? followUpDate;
  String? referralText;

  @override
  void initState() {
    super.initState();
    
    // Initialize patient info
    patientInfo = PrescriptionPatientInfo(
      name: widget.patientName ?? '',
      age: widget.patientAge ?? '',
      gender: widget.patientGender ?? '',
      date: DateTime.now().toString().split(' ')[0],
      patientId: widget.patientId ?? '',
      phone: widget.patientPhone,
    );

    // Initialize clinical data
    clinicalData = ClinicalData();
  }

  void _addMedicine(Medicine medicine) {
    setState(() {
      medicines.add(medicine);
    });
  }

  void _deleteMedicine(String id) {
    setState(() {
      medicines.removeWhere((medicine) => medicine.id == id);
    });
  }

  void _updateMedicine(String id, Medicine updatedMedicine) {
    setState(() {
      final index = medicines.indexWhere((medicine) => medicine.id == id);
      if (index != -1) {
        medicines[index] = updatedMedicine;
      }
    });
  }

  void _reorderMedicines(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Medicine item = medicines.removeAt(oldIndex);
      medicines.insert(newIndex, item);
    });
  }

  void _updateClinicalData(String field, String value) {
    setState(() {
      switch (field) {
        case 'chiefComplaint':
          clinicalData.chiefComplaint = value;
          break;
        case 'examination':
          clinicalData.examination = value;
          break;
        case 'history':
          clinicalData.history = value;
          break;
        case 'diagnosis':
          clinicalData.diagnosis = value;
          break;
        case 'investigation':
          clinicalData.investigation = value;
          break;
      }
    });
  }

  void _updateAdvice(List<String> advice) {
    setState(() {
      adviceList = advice;
    });
  }

  void _updateFollowUpDate(DateTime? date) {
    setState(() {
      followUpDate = date;
    });
  }

  void _updateReferral(String? referral) {
    setState(() {
      referralText = referral;
    });
  }

  Future<void> _savePrescription() async {
    // Show loading indicator
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFE3001)),
      ),
    );

    try {
      // Parse clinical data
      final chiefComplaints = clinicalData.chiefComplaint
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();
      
      final diagnosisList = clinicalData.diagnosis
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();
      
      final investigationList = clinicalData.investigation
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();

      final examinationMap = <String, dynamic>{};
      clinicalData.examination.split('\n').where((s) => s.trim().isNotEmpty).forEach((line) {
        final parts = line.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), '').split(':');
        if (parts.length >= 2) {
          examinationMap[parts[0].trim()] = parts.sublist(1).join(':').trim();
        }
      });

      final filePath = await PrescriptionPrintService.savePrescription(
        patientName: patientInfo.name.isEmpty ? 'Patient Name' : patientInfo.name,
        age: patientInfo.age.isEmpty ? 'N/A' : patientInfo.age,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        patientId: patientInfo.patientId.isEmpty ? 'N/A' : patientInfo.patientId,
        chiefComplaints: chiefComplaints,
        examination: examinationMap,
        diagnosis: diagnosisList,
        investigation: investigationList,
        medicines: medicines,
        advice: adviceList,
        followUpDate: followUpDate != null ? DateFormat('dd/MM/yyyy').format(followUpDate!) : null,
        referral: referralText,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prescription saved to:\n$filePath'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _printPrescription() async {
    // Show loading indicator
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFE3001)),
      ),
    );

    try {
      // Parse clinical data into lists
      final chiefComplaints = clinicalData.chiefComplaint
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();
      
      final diagnosisList = clinicalData.diagnosis
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();
      
      final investigationList = clinicalData.investigation
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();

      // Parse examination into map
      final examinationMap = <String, dynamic>{};
      clinicalData.examination.split('\n').where((s) => s.trim().isNotEmpty).forEach((line) {
        final parts = line.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), '').split(':');
        if (parts.length >= 2) {
          examinationMap[parts[0].trim()] = parts.sublist(1).join(':').trim();
        }
      });

      await PrescriptionPrintService.printPrescription(
        patientName: patientInfo.name.isEmpty ? 'Patient Name' : patientInfo.name,
        age: patientInfo.age.isEmpty ? 'N/A' : patientInfo.age,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        patientId: patientInfo.patientId.isEmpty ? 'N/A' : patientInfo.patientId,
        chiefComplaints: chiefComplaints,
        examination: examinationMap,
        diagnosis: diagnosisList,
        investigation: investigationList,
        medicines: medicines,
        advice: adviceList,
        followUpDate: followUpDate != null ? DateFormat('dd/MM/yyyy').format(followUpDate!) : null,
        referral: referralText,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive padding based on screen width
            double horizontalPadding = 16;
            double maxWidth = 768;

            if (constraints.maxWidth >= 640) {
              horizontalPadding = 24;
            }
            if (constraints.maxWidth >= 768) {
              horizontalPadding = 32;
              maxWidth = 896;
            }
            if (constraints.maxWidth >= 1024) {
              horizontalPadding = 40;
              maxWidth = 1152;
            }
            if (constraints.maxWidth >= 1280) {
              horizontalPadding = 48;
              maxWidth = 1280;
            }
            if (constraints.maxWidth >= 1536) {
              horizontalPadding = 64;
              maxWidth = 1600;
            }
            if (constraints.maxWidth >= 1920) {
              horizontalPadding = 80;
              maxWidth = 1760;
            }

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PatientInfoCard(patientInfo: patientInfo),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: constraints.maxWidth >= 1024
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column - Clinical Sections
                                SizedBox(
                                  width: 380,
                                  child: ClinicalSections(
                                    clinicalData: clinicalData,
                                    onUpdate: _updateClinicalData,
                                  ),
                                ),
                                const SizedBox(width: 48),
                                // Vertical Separator
                                Container(
                                  width: 1,
                                  height: 600,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                const SizedBox(width: 48),
                                // Right Column - Prescription
                                Expanded(
                                  child: MedicineList(
                                    medicines: medicines,
                                    onAdd: _addMedicine,
                                    onDelete: _deleteMedicine,
                                    onReorder: _reorderMedicines,
                                    onUpdate: _updateMedicine,
                                    onAdviceUpdate: _updateAdvice,
                                    onFollowUpUpdate: _updateFollowUpDate,
                                    onReferralUpdate: _updateReferral,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                ClinicalSections(
                                  clinicalData: clinicalData,
                                  onUpdate: _updateClinicalData,
                                ),
                                const SizedBox(height: 32),
                                MedicineList(
                                  medicines: medicines,
                                  onAdd: _addMedicine,
                                  onDelete: _deleteMedicine,
                                  onReorder: _reorderMedicines,
                                  onUpdate: _updateMedicine,
                                  onAdviceUpdate: _updateAdvice,
                                  onFollowUpUpdate: _updateFollowUpDate,
                                  onReferralUpdate: _updateReferral,
                                ),
                              ],
                            ),
                    ),
                    PrescriptionFooter(
                      onSave: _savePrescription,
                      onPrint: _printPrescription,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
