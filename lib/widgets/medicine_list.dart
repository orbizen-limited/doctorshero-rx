import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_database_service.dart';
import 'medicine_autocomplete_field.dart';

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
              return _buildMedicineCard(medicine, index, key: ValueKey(medicine.id));
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

  Widget _buildMedicineCard(Medicine medicine, int index, {required Key key}) {
    final compositionController = TextEditingController(text: medicine.composition);
    final dosageController = TextEditingController(text: medicine.dosage);
    final durationController = TextEditingController(text: medicine.duration);
    final adviceController = TextEditingController(text: medicine.advice);

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Medicine Name Section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type + Medicine Name
                Row(
                  children: [
                    // Type Dropdown
                    DropdownButton<String>(
                      value: medicine.type,
                      isDense: true,
                      underline: Container(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFE3001),
                        fontFamily: 'ProductSans',
                      ),
                      items: medicineTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && widget.onUpdate != null) {
                          final updatedMedicine = Medicine(
                            id: medicine.id,
                            type: value,
                            name: medicine.name,
                            genericName: medicine.genericName,
                            composition: medicine.composition,
                            dosage: medicine.dosage,
                            duration: medicine.duration,
                            advice: medicine.advice,
                          );
                          widget.onUpdate!(medicine.id, updatedMedicine);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    // Medicine Name with Autocomplete
                    Expanded(
                      child: MedicineAutocompleteField(
                        label: 'Medicine Name (e.g., Tab. Napa)',
                        initialValue: medicine.name,
                        searchByGeneric: false,
                        onMedicineSelected: (medicineData) {
                          // Auto-fill all fields when medicine is selected
                          // Format dosage form to match dropdown (e.g., "Tablet" -> "Tab.")
                          String formattedType = medicine.type;
                          if (medicineData.dosageForm.isNotEmpty) {
                            final form = medicineData.dosageForm.toLowerCase();
                            if (form.contains('tab')) formattedType = 'Tab.';
                            else if (form.contains('cap')) formattedType = 'Cap.';
                            else if (form.contains('syp') || form.contains('syrup')) formattedType = 'Syp.';
                            else if (form.contains('inj')) formattedType = 'Inj.';
                            else if (form.contains('susp')) formattedType = 'Susp.';
                            else if (form.contains('drop')) formattedType = 'Drops';
                          }
                          
                          final updatedMedicine = Medicine(
                            id: medicine.id,
                            type: formattedType,
                            name: '${medicineData.medicineName}${medicineData.powerStrength.isNotEmpty ? " ${medicineData.powerStrength}" : ""}',
                            genericName: medicineData.genericName,
                            composition: medicineData.company,
                            dosage: medicine.dosage,
                            duration: medicine.duration,
                            advice: medicine.advice,
                          );
                          if (widget.onUpdate != null) {
                            widget.onUpdate!(medicine.id, updatedMedicine);
                          }
                        },
                        onTextChanged: (value) {
                          // Don't update medicine object on every keystroke
                          // Just let the user type freely
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Generic Name with Autocomplete
                MedicineAutocompleteField(
                  label: 'Generic Name (e.g., Paracetamol)',
                  initialValue: medicine.genericName,
                  searchByGeneric: true,
                  onMedicineSelected: (medicineData) {
                    // Auto-fill all fields when medicine is selected by generic
                    // Format dosage form to match dropdown
                    String formattedType = medicine.type;
                    if (medicineData.dosageForm.isNotEmpty) {
                      final form = medicineData.dosageForm.toLowerCase();
                      if (form.contains('tab')) formattedType = 'Tab.';
                      else if (form.contains('cap')) formattedType = 'Cap.';
                      else if (form.contains('syp') || form.contains('syrup')) formattedType = 'Syp.';
                      else if (form.contains('inj')) formattedType = 'Inj.';
                      else if (form.contains('susp')) formattedType = 'Susp.';
                      else if (form.contains('drop')) formattedType = 'Drops';
                    }
                    
                    final updatedMedicine = Medicine(
                      id: medicine.id,
                      type: formattedType,
                      name: '${medicineData.medicineName}${medicineData.powerStrength.isNotEmpty ? " ${medicineData.powerStrength}" : ""}',
                      genericName: medicineData.genericName,
                      composition: medicineData.company,
                      dosage: medicine.dosage,
                      duration: medicine.duration,
                      advice: medicine.advice,
                    );
                    if (widget.onUpdate != null) {
                      widget.onUpdate!(medicine.id, updatedMedicine);
                    }
                  },
                  onTextChanged: (value) {
                    // Don't update medicine object on every keystroke
                    // Just let the user type freely
                  },
                ),
                const SizedBox(height: 4),
                // Composition
                TextField(
                  controller: compositionController,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'ProductSans',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Composition / Note',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right: Dosage, Duration, Advice
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Dosage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOSAGE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: dosageController,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          fontFamily: 'ProductSans',
                        ),
                        decoration: const InputDecoration(
                          hintText: '1+0+1',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DURATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: durationController,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          fontFamily: 'ProductSans',
                        ),
                        decoration: const InputDecoration(
                          hintText: '5 Days',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Advice
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ADVICE (E.G., AFTER MEAL)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: adviceController,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          fontFamily: 'ProductSans',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'After food, no alcohol',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Delete Button
          IconButton(
            onPressed: () {
              widget.onDelete(medicine.id);
            },
            icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

}
