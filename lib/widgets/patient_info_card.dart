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
                _buildInfoField(context, 'Patient Name', patientInfo.name, 'name'),
                const SizedBox(width: 32),
                _buildInfoField(context, 'Age', patientInfo.age, 'age'),
                const SizedBox(width: 32),
                _buildGenderField(context),
                const SizedBox(width: 32),
                _buildDateField(context),
                const SizedBox(width: 32),
                _buildInfoField(context, 'Phone', patientInfo.phone ?? '', 'phone'),
                const SizedBox(width: 32),
                _buildInfoField(context, 'Patient ID', patientInfo.patientId, 'patientId'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value, String field) {
    return Expanded(
      child: isEditable && onUpdate != null
          ? InkWell(
              onTap: () => _showUnifiedPatientDialog(context),
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
            )
          : Column(
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

  Widget _buildGenderField(BuildContext context) {
    return Expanded(
      child: isEditable && onUpdate != null
          ? InkWell(
              onTap: () => _showUnifiedPatientDialog(context),
              child: Column(
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            )
          : Column(
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

  Widget _buildDateField(BuildContext context) {
    return Expanded(
      child: isEditable && onUpdate != null
          ? InkWell(
              onTap: () => _showUnifiedPatientDialog(context),
              child: Column(
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            )
          : Column(
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
