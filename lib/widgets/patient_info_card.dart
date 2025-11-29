import 'package:flutter/material.dart';
import '../models/prescription_model.dart';

class PatientInfoCard extends StatelessWidget {
  final PrescriptionPatientInfo patientInfo;
  final VoidCallback? onEdit;

  const PatientInfoCard({
    Key? key,
    required this.patientInfo,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Patient Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 24),
          // Patient Info
          Expanded(
            child: Row(
              children: [
                _buildInfoColumn('Patient Name', patientInfo.name),
                const SizedBox(width: 32),
                _buildInfoColumn('Age', patientInfo.age),
                const SizedBox(width: 32),
                _buildInfoColumn('Gender', patientInfo.gender),
                const SizedBox(width: 32),
                _buildInfoColumn('Date', patientInfo.date),
                const SizedBox(width: 32),
                _buildInfoColumn('Patient ID', patientInfo.patientId),
              ],
            ),
          ),
          // Edit Button
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
              tooltip: 'Edit Patient Info',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
        ],
      ),
    );
  }
}
