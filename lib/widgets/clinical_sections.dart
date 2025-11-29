import 'package:flutter/material.dart';
import '../models/prescription_model.dart';

class ClinicalSections extends StatelessWidget {
  final ClinicalData clinicalData;
  final Function(String field, String value)? onUpdate;

  const ClinicalSections({
    Key? key,
    required this.clinicalData,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Chief Complaint',
          clinicalData.chiefComplaint,
          'chiefComplaint',
          Icons.description_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Examination',
          clinicalData.examination,
          'examination',
          Icons.medical_information_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          'History',
          clinicalData.history,
          'history',
          Icons.history,
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Diagnosis',
          clinicalData.diagnosis,
          'diagnosis',
          Icons.analytics_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Investigation',
          clinicalData.investigation,
          'investigation',
          Icons.science_outlined,
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, String field, IconData icon) {
    return Container(
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
              Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
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
          TextFormField(
            initialValue: content,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter details...',
              hintStyle: TextStyle(color: Color(0xFF94A3B8)),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (onUpdate != null) {
                onUpdate!(field, value);
              }
            },
          ),
        ],
      ),
    );
  }
}
