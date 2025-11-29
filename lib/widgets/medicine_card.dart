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
  late TextEditingController _durationNumberController;
  late TextEditingController _adviceController;
  late String _currentType;
  String _durationUnit = 'Days';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _genericController = TextEditingController(text: widget.medicine.genericName);
    _compositionController = TextEditingController(text: widget.medicine.composition);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _adviceController = TextEditingController(text: widget.medicine.advice);
    _currentType = widget.medicine.type;
    
    // Parse duration into number and unit
    final durationParts = _parseDuration(widget.medicine.duration);
    _durationNumberController = TextEditingController(text: durationParts['number'] ?? '');
    _durationUnit = durationParts['unit'] ?? 'Days';
  }

  Map<String, String?> _parseDuration(String duration) {
    if (duration.isEmpty) {
      return {'number': '', 'unit': 'Days'};
    }
    
    final regex = RegExp(r'(\d+)\s*(Hour|Day|Week|Month|Year)s?', caseSensitive: false);
    final match = regex.firstMatch(duration);
    if (match != null) {
      String unit = match.group(2)!;
      // Capitalize first letter and add 's' if not present
      unit = '${unit[0].toUpperCase()}${unit.substring(1).toLowerCase()}';
      if (!unit.endsWith('s')) unit += 's';
      
      return {
        'number': match.group(1),
        'unit': unit,
      };
    }
    return {'number': '', 'unit': 'Days'};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericController.dispose();
    _compositionController.dispose();
    _dosageController.dispose();
    _durationNumberController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  void _updateMedicine() {
    if (widget.onUpdate != null) {
      final duration = _durationNumberController.text.isEmpty 
          ? '' 
          : '${_durationNumberController.text} $_durationUnit';
      
      final updatedMedicine = Medicine(
        id: widget.medicine.id,
        type: _currentType,
        name: _nameController.text,
        genericName: _genericController.text,
        composition: _compositionController.text,
        dosage: _dosageController.text,
        duration: duration,
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

  void _showAdviceDrawer() {
    final adviceOptions = [
      'After food',
      'Before food',
      'With food',
      'Empty stomach',
      'After meal',
      'Before meal',
      'At bedtime',
      'In the morning',
      'No alcohol',
      'Drink plenty of water',
      'Avoid direct sunlight',
      'Take with milk',
      'Do not crush or chew',
      'Dissolve in water',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Advice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: adviceOptions.length,
                itemBuilder: (context, index) {
                  final advice = adviceOptions[index];
                  return ListTile(
                    title: Text(
                      advice,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _adviceController.text = advice;
                      });
                      _updateMedicine();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          // Left: Medicine Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type + Name
                Row(
                  children: [
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
                    Expanded(
                      child: InkWell(
                        onTap: () => _showMedicineSearchDialog('name'),
                        child: Text(
                          _nameController.text.isEmpty 
                              ? 'napa' 
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
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Generic Name
                InkWell(
                  onTap: () => _showMedicineSearchDialog('generic'),
                  child: Text(
                    _genericController.text.isEmpty 
                        ? 'Generic Name (e.g., Paracetamol)' 
                        : _genericController.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: _genericController.text.isEmpty 
                          ? const Color(0xFF94A3B8) 
                          : const Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Composition
                Text(
                  _compositionController.text.isEmpty 
                      ? 'Composition / Note' 
                      : _compositionController.text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'ProductSans',
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
                Expanded(
                  child: TextField(
                    controller: _dosageController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'DOSAGE',
                      hintText: '1+0+1',
                      labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, fontFamily: 'ProductSans'),
                    onChanged: (value) {
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
                const SizedBox(width: 12),
                // Duration - Split into number and unit
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _durationNumberController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'DURATION',
                            hintText: '5',
                            labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13, fontFamily: 'ProductSans'),
                          onChanged: (value) => _updateMedicine(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _durationUnit,
                          isDense: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13, fontFamily: 'ProductSans', color: Color(0xFF1E293B)),
                          items: ['Hours', 'Days', 'Weeks', 'Months', 'Years'].map((unit) {
                            return DropdownMenuItem(value: unit, child: Text(unit));
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _durationUnit = value;
                              });
                              _updateMedicine();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Advice - Clickable
                Expanded(
                  child: InkWell(
                    onTap: () => _showAdviceDrawer(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _adviceController.text.isEmpty 
                                  ? 'After food, no alcohol' 
                                  : _adviceController.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: _adviceController.text.isEmpty 
                                    ? const Color(0xFF94A3B8) 
                                    : const Color(0xFF1E293B),
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Delete & Drag
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
