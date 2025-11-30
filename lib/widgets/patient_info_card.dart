import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prescription_model.dart';

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
          Row(
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              if (isEditable && onUpdate != null)
                InkWell(
                  onTap: () => _showEditDialog(context, label, value, field),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField(BuildContext context) {
    return Expanded(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  patientInfo.gender.isEmpty ? '-' : patientInfo.gender,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              if (isEditable && onUpdate != null)
                InkWell(
                  onTap: () => _showGenderPicker(context),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Expanded(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  patientInfo.date.isEmpty ? '-' : patientInfo.date,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              if (isEditable && onUpdate != null)
                InkWell(
                  onTap: () => _showDatePicker(context),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String label, String currentValue, String field) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onUpdate!(field, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE3001),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Male'),
              onTap: () {
                onUpdate!('gender', 'Male');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Female'),
              onTap: () {
                onUpdate!('gender', 'Female');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () {
                onUpdate!('gender', 'Other');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      onUpdate!('date', formattedDate);
    }
  }
}
