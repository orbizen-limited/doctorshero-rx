import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class MedicineList extends StatefulWidget {
  final List<Medicine> medicines;
  final Function(Medicine) onAdd;
  final Function(String) onDelete;
  final Function(int, int) onReorder;

  const MedicineList({
    Key? key,
    required this.medicines,
    required this.onAdd,
    required this.onDelete,
    required this.onReorder,
  }) : super(key: key);

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  final List<String> medicineTypes = ['Tab.', 'Cap.', 'Syp.', 'Inj.', 'Susp.', 'Drops'];
  
  void _showAddMedicineDialog() {
    String selectedType = 'Tab.';
    final nameController = TextEditingController();
    final genericController = TextEditingController();
    final compositionController = TextEditingController();
    final dosageController = TextEditingController();
    final durationController = TextEditingController();
    final adviceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medicine', style: TextStyle(fontFamily: 'ProductSans')),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medicine Type Selector
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: medicineTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genericController,
                  decoration: const InputDecoration(
                    labelText: 'Generic Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: compositionController,
                  decoration: const InputDecoration(
                    labelText: 'Composition / Note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 1+0+1)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (e.g., 5 Days)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adviceController,
                  decoration: const InputDecoration(
                    labelText: 'Advice',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final medicine = Medicine(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: selectedType,
                  name: nameController.text,
                  genericName: genericController.text,
                  composition: compositionController.text,
                  dosage: dosageController.text,
                  duration: durationController.text,
                  advice: adviceController.text,
                );
                widget.onAdd(medicine);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PRESCRIPTION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5,
                fontFamily: 'ProductSans',
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddMedicineDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Medicine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Medicine List
        if (widget.medicines.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No medicines added yet. Click "Add Medicine" to start.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.medicines.length,
            onReorder: widget.onReorder,
            itemBuilder: (context, index) {
              final medicine = widget.medicines[index];
              return _buildMedicineCard(medicine, index, key: ValueKey(medicine.id));
            },
          ),
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine, int index, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          const Icon(Icons.drag_indicator, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          // Serial Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B82F6),
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Medicine Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        medicine.type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ],
                ),
                if (medicine.genericName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    medicine.genericName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
                if (medicine.composition.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    medicine.composition,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetadata(Icons.medication, medicine.dosage),
                    const SizedBox(width: 16),
                    _buildMetadata(Icons.calendar_today, medicine.duration),
                  ],
                ),
                if (medicine.advice.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          medicine.advice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontFamily: 'ProductSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Delete Button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Medicine'),
                  content: Text('Are you sure you want to delete ${medicine.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onDelete(medicine.id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            fontFamily: 'ProductSans',
          ),
        ),
      ],
    );
  }
}
