import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../models/prescription_model.dart';
import '../models/saved_prescription.dart';
import '../widgets/patient_info_card.dart';
import '../widgets/clinical_sections.dart';
import '../widgets/medicine_list.dart';
import '../widgets/prescription_footer.dart';
import '../services/prescription_print_service.dart';
import '../services/prescription_database_service.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;
  final String? patientAge;
  final String? patientGender;
  final String? patientPhone;
  final SavedPrescription? savedPrescription;
  final Future<bool> Function()? onWillPop;

  const CreatePrescriptionScreen({
    Key? key,
    this.patientId,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.patientPhone,
    this.savedPrescription,
    this.onWillPop,
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
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Load from saved prescription if provided
    if (widget.savedPrescription != null) {
      final saved = widget.savedPrescription!;
      patientInfo = saved.toPatientInfo();
      clinicalData = saved.toClinicalData();
      medicines = saved.toMedicineList();
      adviceList = saved.adviceList;
      followUpDate = saved.followUpDate;
      referralText = saved.referralText;
    } else {
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
  }

  bool _hasChanges() {
    // Check if any data has been entered
    return patientInfo.name.isNotEmpty ||
           medicines.isNotEmpty ||
           clinicalData.chiefComplaint.isNotEmpty ||
           clinicalData.examination.isNotEmpty ||
           clinicalData.history.isNotEmpty ||
           clinicalData.diagnosis.isNotEmpty ||
           clinicalData.investigation.isNotEmpty ||
           adviceList.isNotEmpty ||
           followUpDate != null ||
           (referralText != null && referralText!.isNotEmpty);
  }

  Future<bool> _showExitConfirmation() async {
    if (!_hasChanges()) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE3001),
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _lookupPatient(String patientId) async {
    if (patientId.isEmpty) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFE3001)),
      ),
    );

    try {
      final apiService = ApiService();
      final patientData = await apiService.getPatientByPatientId(patientId);

      // Close loading
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (patientData != null) {
        // Patient found - auto-fill details
        setState(() {
          patientInfo = PrescriptionPatientInfo(
            name: patientData['name'] ?? '',
            age: patientData['age']?.toString() ?? '',
            gender: patientData['gender'] ?? '',
            date: DateTime.now().toString().split(' ')[0],
            patientId: patientId,
            phone: patientData['phone'] ?? patientData['mobile'],
            bloodGroup: patientData['blood_group'],
            address: patientData['address'],
          );
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Patient found: ${patientData['name']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Patient not found - keep the ID but don't auto-fill
        setState(() {
          patientInfo = PrescriptionPatientInfo(
            name: patientInfo.name,
            age: patientInfo.age,
            gender: patientInfo.gender,
            date: patientInfo.date,
            patientId: patientId,
            phone: patientInfo.phone,
            bloodGroup: patientInfo.bloodGroup,
            address: patientInfo.address,
          );
        });

        // Show info message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient ID not found in database. Using as unknown patient.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error looking up patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addMedicine(Medicine medicine) {
    setState(() {
      medicines.add(medicine);
      _hasUnsavedChanges = true;
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
    // Validate
    if (patientInfo.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name')),
      );
      return;
    }

    if (medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      // Create saved prescription
      final uuid = const Uuid();
      final savedPrescription = SavedPrescription.create(
        id: uuid.v4(),
        patientInfo: patientInfo,
        clinicalData: clinicalData,
        medicines: medicines,
        adviceList: adviceList,
        followUpDate: followUpDate,
        referralText: referralText,
        doctorName: user?.name,
        doctorRegistration: user?.registrationNumber,
        doctorSpecialization: user?.specialization,
        doctorQualification: user?.qualification,
      );

      // Save to database
      final dbService = PrescriptionDatabaseService();
      await dbService.savePrescription(savedPrescription);

      // Clear unsaved changes flag
      setState(() {
        _hasUnsavedChanges = false;
      });

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Prescription saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving prescription: $e'),
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
        phone: patientInfo.phone,
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
    return WillPopScope(
      onWillPop: _showExitConfirmation,
      child: Scaffold(
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
                    PatientInfoCard(
                      patientInfo: patientInfo,
                      isEditable: widget.savedPrescription == null,
                      onUpdate: (field, value) {
                        setState(() {
                          switch (field) {
                            case 'name':
                              patientInfo = PrescriptionPatientInfo(
                                name: value,
                                age: patientInfo.age,
                                gender: patientInfo.gender,
                                date: patientInfo.date,
                                patientId: patientInfo.patientId,
                                phone: patientInfo.phone,
                                bloodGroup: patientInfo.bloodGroup,
                                address: patientInfo.address,
                              );
                              break;
                            case 'age':
                              patientInfo = PrescriptionPatientInfo(
                                name: patientInfo.name,
                                age: value,
                                gender: patientInfo.gender,
                                date: patientInfo.date,
                                patientId: patientInfo.patientId,
                                phone: patientInfo.phone,
                                bloodGroup: patientInfo.bloodGroup,
                                address: patientInfo.address,
                              );
                              break;
                            case 'gender':
                              patientInfo = PrescriptionPatientInfo(
                                name: patientInfo.name,
                                age: patientInfo.age,
                                gender: value,
                                date: patientInfo.date,
                                patientId: patientInfo.patientId,
                                phone: patientInfo.phone,
                                bloodGroup: patientInfo.bloodGroup,
                                address: patientInfo.address,
                              );
                              break;
                            case 'date':
                              patientInfo = PrescriptionPatientInfo(
                                name: patientInfo.name,
                                age: patientInfo.age,
                                gender: patientInfo.gender,
                                date: value,
                                patientId: patientInfo.patientId,
                                phone: patientInfo.phone,
                                bloodGroup: patientInfo.bloodGroup,
                                address: patientInfo.address,
                              );
                              break;
                            case 'patientId':
                              // Try to fetch patient details from API
                              _lookupPatient(value);
                              break;
                            case 'phone':
                              // Auto-generate UPID + full phone number
                              String newPatientId = patientInfo.patientId;
                              if (value.isNotEmpty && patientInfo.patientId.isEmpty) {
                                newPatientId = 'UPID$value';
                              }
                              patientInfo = PrescriptionPatientInfo(
                                name: patientInfo.name,
                                age: patientInfo.age,
                                gender: patientInfo.gender,
                                date: patientInfo.date,
                                patientId: newPatientId,
                                phone: value,
                                bloodGroup: patientInfo.bloodGroup,
                                address: patientInfo.address,
                              );
                              break;
                          }
                        });
                      },
                    ),
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
      ),
    );
  }
}
