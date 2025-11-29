import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import 'medicine_card.dart';

class MedicineList extends StatefulWidget {
  final List<Medicine> medicines;
  final Function(Medicine) onAdd;
  final Function(String) onDelete;
  final Function(int, int) onReorder;
  final Function(String id, Medicine updatedMedicine)? onUpdate;

  const MedicineList({
    Key? key,
    required this.medicines,
    required this.onAdd,
    required this.onDelete,
    required this.onReorder,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  final List<String> medicineTypes = ['Tab.', 'Cap.', 'Syp.', 'Inj.', 'Susp.', 'Drops'];
  
  void _addEmptyMedicine() {
    final medicine = Medicine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Tab.',
      name: '',
      genericName: '',
      composition: '',
      dosage: '',
      duration: '',
      advice: '',
    );
    widget.onAdd(medicine);
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
            Row(
              children: [
                const Icon(Icons.medical_services, color: Color(0xFFFE3001), size: 20),
                const SizedBox(width: 8),
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
              ],
            ),
            ElevatedButton.icon(
              onPressed: _addEmptyMedicine,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Medicine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE3001),
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
              return MedicineCard(
                key: ValueKey(medicine.id),
                medicine: medicine,
                index: index,
                onUpdate: widget.onUpdate,
                onDelete: widget.onDelete,
                medicineTypes: medicineTypes,
              );
            },
          ),
        
        // Advice Section
        const SizedBox(height: 32),
        Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFFE3001), size: 18),
            const SizedBox(width: 8),
            const Text(
              'ADVICE',
              style: TextStyle(
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Take medicines after meals for better absorption.\nDrink plenty of water (2-3 liters daily).\nAvoid direct sunlight exposure.',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
        ),
        
        // Follow-up and Referral Row
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Follow-up
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FOLLOW UP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Referral
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REFERRAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Refer to specialist...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
