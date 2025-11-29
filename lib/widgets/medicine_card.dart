import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_database_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.medicine.id),
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
                      value: _currentType,
                      isDense: true,
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
                    const SizedBox(width: 8),
                    // Medicine Name with Autocomplete
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontFamily: 'ProductSans',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Medicine Name (e.g., Tab. Napa)',
                          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (value) {
                          // Search for medicines
                          if (value.length >= 2) {
                            final suggestions = MedicineDatabaseService.searchByMedicineName(value);
                            if (suggestions.isNotEmpty) {
                              // Show suggestions in overlay
                              _showMedicineSuggestions(context, suggestions);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Generic Name
                TextField(
                  controller: _genericController,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Generic Name (e.g., Paracetamol)',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    if (value.length >= 2) {
                      final suggestions = MedicineDatabaseService.searchByGenericName(value);
                      if (suggestions.isNotEmpty) {
                        _showMedicineSuggestions(context, suggestions);
                      }
                    }
                  },
                ),
                const SizedBox(height: 4),
                // Composition
                TextField(
                  controller: _compositionController,
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
                  onChanged: (value) => _updateMedicine(),
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
                  child: TextField(
                    controller: _dosageController,
                    decoration: InputDecoration(
                      labelText: 'Dosage',
                      hintText: '1+0+1',
                      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                const SizedBox(width: 12),
                // Duration
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Duration',
                      hintText: '7 Days',
                      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                const SizedBox(width: 12),
                // Advice
                Expanded(
                  child: TextField(
                    controller: _adviceController,
                    decoration: InputDecoration(
                      labelText: 'Advice',
                      hintText: 'After food',
                      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _showMedicineSuggestions(BuildContext context, List<MedicineData> suggestions) {
    // This is a simplified version - we'll show a dialog with suggestions
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Medicine'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final medicine = suggestions[index];
              return ListTile(
                title: Text(medicine.displayName),
                subtitle: medicine.genericName.isNotEmpty ? Text(medicine.genericName) : null,
                onTap: () {
                  _autoFillFromMedicine(medicine);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
