import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../models/prescription_model.dart';
import '../widgets/prescription_header.dart';
import '../widgets/patient_info_card.dart';
import '../widgets/clinical_sections.dart';
import '../widgets/medicine_list.dart';
import '../widgets/prescription_footer.dart';

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

  void _savePrescription() {
    // TODO: Implement save to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription saved successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _printPrescription() {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
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
                children: [
                  const PrescriptionHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
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
    );
  }
}
