import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_database_service.dart';
import 'medicine_search_dialog.dart';

class MedicineCard extends StatefulWidget {
  final Medicine medicine;
  final int index;
  final Function(String id, Medicine updatedMedicine)? onUpdate;
  final Function(String id) onDelete;
  final List<String> medicineTypes;

  const MedicineCard({
    Key? key,
    required this.medicine,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
    required this.medicineTypes,
  }) : super(key: key);

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  late TextEditingController _nameController;
  late TextEditingController _genericController;
  late TextEditingController _compositionController;
  late TextEditingController _dosageController;
  late TextEditingController _durationController;
  late TextEditingController _adviceController;
  late String _currentType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _genericController = TextEditingController(text: widget.medicine.genericName);
    _compositionController = TextEditingController(text: widget.medicine.composition);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _durationController = TextEditingController(text: widget.medicine.duration);
    _adviceController = TextEditingController(text: widget.medicine.advice);
    _currentType = widget.medicine.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericController.dispose();
    _compositionController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  void _updateMedicine() {
    if (widget.onUpdate != null) {
      final updatedMedicine = Medicine(
        id: widget.medicine.id,
        type: _currentType,
        name: _nameController.text,
        genericName: _genericController.text,
        composition: _compositionController.text,
        dosage: _dosageController.text,
        duration: _durationController.text,
        advice: _adviceController.text,
      );
      widget.onUpdate!(widget.medicine.id, updatedMedicine);
    }
  }

  void _autoFillFromMedicine(MedicineData medicineData) {
    setState(() {
      // Format dosage form to match dropdown
      if (medicineData.dosageForm.isNotEmpty) {
        final form = medicineData.dosageForm.toLowerCase();
        if (form.contains('tab')) _currentType = 'Tab.';
        else if (form.contains('cap')) _currentType = 'Cap.';
        else if (form.contains('syp') || form.contains('syrup')) _currentType = 'Syp.';
        else if (form.contains('inj')) _currentType = 'Inj.';
        else if (form.contains('susp')) _currentType = 'Susp.';
        else if (form.contains('drop')) _currentType = 'Drops';
      }
      
      // Update text controllers
      _nameController.text = '${medicineData.medicineName}${medicineData.powerStrength.isNotEmpty ? " ${medicineData.powerStrength}" : ""}';
      _genericController.text = medicineData.genericName;
      _compositionController.text = medicineData.company;
    });
    
    _updateMedicine();
  }

  void _showMedicineSearchDialog(String searchType) {
    showDialog(
      context: context,
      builder: (context) => MedicineSearchDialog(
        searchType: searchType,
        onMedicineSelected: _autoFillFromMedicine,
      ),
    );
  }

  String _formatDosage(String input) {
    // Remove all non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 4 digits
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }
    
    // Add + between each digit
    if (digitsOnly.isEmpty) return '';
    
    List<String> chars = digitsOnly.split('');
    return chars.join('+');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.medicine.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Type Dropdown
          SizedBox(
            width: 70,
            child: DropdownButton<String>(
              value: _currentType,
              isDense: true,
              isExpanded: true,
              underline: Container(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFE3001),
                fontFamily: 'ProductSans',
              ),
              items: widget.medicineTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentType = value;
                  });
                  _updateMedicine();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // Medicine Name Section (Vertical)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medicine Name - Clickable
                InkWell(
                  onTap: () => _showMedicineSearchDialog('name'),
                  child: Text(
                    _nameController.text.isEmpty 
                        ? 'Medicine Name (e.g., Tab. Napa)' 
                        : _nameController.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _nameController.text.isEmpty 
                          ? const Color(0xFF94A3B8) 
                          : const Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Generic Name - Clickable
                InkWell(
                  onTap: () => _showMedicineSearchDialog('generic'),
                  child: Text(
                    _genericController.text.isEmpty 
                        ? 'Generic Name (e.g., Paracetamol)' 
                        : _genericController.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: _genericController.text.isEmpty 
                          ? const Color(0xFF94A3B8) 
                          : const Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Composition - Editable
                SizedBox(
                  height: 20,
                  child: TextField(
                    controller: _compositionController,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'ProductSans',
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Composition / Note',
                      hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _updateMedicine(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Dosage, Duration, Advice (Horizontal)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Dosage
                Expanded(
                  child: TextField(
                    controller: _dosageController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '1+0+1',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFE3001)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, fontFamily: 'ProductSans'),
                    onChanged: (value) {
                      // Auto-format dosage: add + between numbers, max 4 digits
                      String formatted = _formatDosage(value);
                      if (formatted != value) {
                        _dosageController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                      _updateMedicine();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Duration
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '5 Days',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFE3001)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, fontFamily: 'ProductSans'),
                    onChanged: (value) => _updateMedicine(),
                  ),
                ),
                const SizedBox(width: 8),
                // Advice
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _adviceController,
                    decoration: InputDecoration(
                      hintText: 'After food, no alcohol',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFE3001)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, fontFamily: 'ProductSans'),
                    onChanged: (value) => _updateMedicine(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Delete Button
          Column(
            children: [
              IconButton(
                onPressed: () => widget.onDelete(widget.medicine.id),
                icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.drag_handle, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
