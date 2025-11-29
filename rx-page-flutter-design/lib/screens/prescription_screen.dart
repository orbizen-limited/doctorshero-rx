import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/patient_info.dart';
import '../widgets/prescription_header.dart';
import '../widgets/patient_info_card.dart';
import '../widgets/clinical_sections.dart';
import '../widgets/medicine_list.dart';
import '../widgets/prescription_footer.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  List<Medicine> medicines = [
    Medicine(
      id: '1',
      type: 'Tab.',
      name: 'Napa',
      genericName: 'Paracetamol',
      composition: 'Composition / Note',
      dosage: '1+0+1',
      duration: '5 Days',
      advice: 'After food, no alcohol',
    ),
    Medicine(
      id: '2',
      type: 'Cap.',
      name: 'Omeprazole',
      genericName: 'Omeprazole',
      composition: 'Composition / Note',
      dosage: '1+0+0',
      duration: '10 Days',
      advice: 'Before breakfast',
    ),
    Medicine(
      id: '3',
      type: 'Syp.',
      name: 'Algin',
      genericName: 'Magaldrate',
      composition: 'Composition / Note',
      dosage: '1+1+1',
      duration: '7 Days',
      advice: 'After meals',
    ),
  ];

  final PatientInfo patientInfo = PatientInfo(
    name: '',
    age: '',
    gender: '',
    date: DateTime.now().toString().split(' ')[0],
    patientId: 'PID-12345',
  );

  final ClinicalData clinicalData = ClinicalData(
    chiefComplaint: 'Fever for 3 days, mild cough.',
    examination: 'BP 120/80 mmHg, Pulse 72/min, Temp 99.5 F, Chest clear.',
    history: 'No known allergies. No prior surgeries. Smokes occasionally.',
    diagnosis: 'Suspected Viral infection (Rule out flu).',
    investigation: 'CBC ordered. Wait for results.',
  );

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
                  const PrescriptionFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
