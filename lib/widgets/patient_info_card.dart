import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prescription_model.dart';
import 'unified_patient_dialog.dart';

class PatientInfoCard extends StatelessWidget {
  final PrescriptionPatientInfo patientInfo;
  final Function(String field, String value)? onUpdate;
  final bool isEditable;

  const PatientInfoCard({
    Key? key,
    required this.patientInfo,
    this.onUpdate,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Patient Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              size: 28,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 20),
          // Patient Info Fields
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInfoField(context, 'PATIENT NAME', patientInfo.name, 'name'),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: _buildInfoField(context, 'AGE', patientInfo.age, 'age'),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: _buildGenderField(context),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildDateField(context),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildInfoField(context, 'PHONE', patientInfo.phone ?? '', 'phone'),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildInfoField(context, 'PATIENT ID', patientInfo.patientId, 'patientId'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Make entire card clickable if editable
    if (isEditable && onUpdate != null) {
      return InkWell(
        onTap: () => _showUnifiedPatientDialog(context),
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFE2E8F0).withOpacity(0.5),
        child: cardContent,
      );
    }
    
    return cardContent;
  }

  Widget _buildInfoField(BuildContext context, String label, String value, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'ProductSans',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildGenderField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          patientInfo.gender.isEmpty ? '-' : patientInfo.gender,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'ProductSans',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          patientInfo.date.isEmpty ? '-' : patientInfo.date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'ProductSans',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showUnifiedPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UnifiedPatientDialog(
        initialName: patientInfo.name,
        initialAge: patientInfo.age,
        initialGender: patientInfo.gender,
        initialPhone: patientInfo.phone,
        initialPatientId: patientInfo.patientId,
        initialDate: patientInfo.date,
        onSave: (data) {
          // Update all fields at once
          onUpdate!('name', data['name']!);
          onUpdate!('age', data['age']!);
          onUpdate!('gender', data['gender']!);
          onUpdate!('phone', data['phone']!);
          onUpdate!('patientId', data['patientId']!);
          onUpdate!('date', data['date']!);
        },
      ),
    );
  }
}
