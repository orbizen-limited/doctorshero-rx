import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import 'clinical_drawer.dart';

class ClinicalSections extends StatelessWidget {
  final ClinicalData clinicalData;
  final Function(String field, String value)? onUpdate;

  const ClinicalSections({
    Key? key,
    required this.clinicalData,
    this.onUpdate,
  }) : super(key: key);

  // Predefined items for each section
  final Map<String, List<String>> _predefinedItems = const {
    'chiefComplaint': [
      'Low Back Pain', 'Headache', 'Abdominal pain', 'Dizziness / vertigo',
      'Neck pain', 'Dry cough', 'Generalized Bodyache', 'Fever',
      'Shortness of breath', 'Abdominal bloating', 'Chest pain',
      'Weight loss', 'Nausea', 'Fatigue'
    ],
    'examination': [
      'BP 120/80 mmHg', 'Pulse 72/min', 'Temp 98.6 F', 'Chest clear',
      'Heart sounds normal', 'Abdomen soft', 'No tenderness',
      'Respiratory rate normal'
    ],
    'history': [
      'No known allergies', 'No prior surgeries', 'Smokes occasionally',
      'Diabetes', 'Hypertension', 'Asthma', 'Heart disease',
      'Family history of diabetes'
    ],
    'diagnosis': [
      'Viral infection', 'Bacterial infection', 'Hypertension',
      'Diabetes Type 2', 'Gastritis', 'Migraine', 'Common cold',
      'Urinary tract infection'
    ],
    'investigation': [
      'CBC ordered', 'X-ray chest', 'ECG', 'Blood sugar',
      'Lipid profile', 'Liver function test', 'Kidney function test',
      'Urine routine'
    ],
  };

  void _openDrawer(BuildContext context, String title, String field) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: ClinicalDrawer(
              title: title,
              predefinedItems: _predefinedItems[field] ?? [],
              onItemsSelected: (items) {
                final text = items.map((item) => item.toFormattedString()).join('\n');
                if (onUpdate != null) {
                  onUpdate!(field, text);
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          'Chief Complaint',
          clinicalData.chiefComplaint,
          'chiefComplaint',
          Icons.description_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'Examination',
          clinicalData.examination,
          'examination',
          Icons.medical_information_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'History',
          clinicalData.history,
          'history',
          Icons.history,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'Diagnosis',
          clinicalData.diagnosis,
          'diagnosis',
          Icons.analytics_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'Investigation',
          clinicalData.investigation,
          'investigation',
          Icons.science_outlined,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, String field, IconData icon) {
    return InkWell(
      onTap: () => _openDrawer(context, title, field),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFFFE3001)),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content.isEmpty ? 'Enter details...' : content,
              style: TextStyle(
                fontSize: 14,
                color: content.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                fontFamily: 'ProductSans',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
