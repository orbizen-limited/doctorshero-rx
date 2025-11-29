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
  
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _genericFocusNode = FocusNode();
  final LayerLink _nameLayerLink = LayerLink();
  final LayerLink _genericLayerLink = LayerLink();
  OverlayEntry? _nameOverlayEntry;
  OverlayEntry? _genericOverlayEntry;
  List<MedicineData> _nameSuggestions = [];
  List<MedicineData> _genericSuggestions = [];

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
    
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        _removeNameOverlay();
      }
    });
    
    _genericFocusNode.addListener(() {
      if (!_genericFocusNode.hasFocus) {
        _removeGenericOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeNameOverlay();
    _removeGenericOverlay();
    _nameController.dispose();
    _genericController.dispose();
    _compositionController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _adviceController.dispose();
    _nameFocusNode.dispose();
    _genericFocusNode.dispose();
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

  void _removeNameOverlay() {
    _nameOverlayEntry?.remove();
    _nameOverlayEntry = null;
  }

  void _removeGenericOverlay() {
    _genericOverlayEntry?.remove();
    _genericOverlayEntry = null;
  }

  void _showNameSuggestions(BuildContext context) {
    _removeNameOverlay();
    
    if (_nameSuggestions.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _nameOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _nameLayerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _nameSuggestions.length,
                itemBuilder: (context, index) {
                  final medicine = _nameSuggestions[index];
                  return InkWell(
                    onTap: () {
                      _autoFillFromMedicine(medicine);
                      _removeNameOverlay();
                      _nameFocusNode.unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < _nameSuggestions.length - 1
                                ? const Color(0xFFE2E8F0)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          if (medicine.genericName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              medicine.genericName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_nameOverlayEntry!);
  }

  void _showGenericSuggestions(BuildContext context) {
    _removeGenericOverlay();
    
    if (_genericSuggestions.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _genericOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _genericLayerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _genericSuggestions.length,
                itemBuilder: (context, index) {
                  final medicine = _genericSuggestions[index];
                  return InkWell(
                    onTap: () {
                      _autoFillFromMedicine(medicine);
                      _removeGenericOverlay();
                      _genericFocusNode.unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < _genericSuggestions.length - 1
                                ? const Color(0xFFE2E8F0)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          if (medicine.genericName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              medicine.genericName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_genericOverlayEntry!);
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
                      child: CompositedTransformTarget(
                        link: _nameLayerLink,
                        child: TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
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
                            // Search for medicines - only show after 3 characters
                            if (value.length >= 3) {
                              setState(() {
                                _nameSuggestions = MedicineDatabaseService.searchByMedicineName(value);
                              });
                              if (_nameSuggestions.isNotEmpty) {
                                _showNameSuggestions(context);
                              } else {
                                _removeNameOverlay();
                              }
                            } else {
                              _removeNameOverlay();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Generic Name
                CompositedTransformTarget(
                  link: _genericLayerLink,
                  child: TextField(
                    controller: _genericController,
                    focusNode: _genericFocusNode,
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
                      // Search by generic - only show after 3 characters
                      if (value.length >= 3) {
                        setState(() {
                          _genericSuggestions = MedicineDatabaseService.searchByGenericName(value);
                        });
                        if (_genericSuggestions.isNotEmpty) {
                          _showGenericSuggestions(context);
                        } else {
                          _removeGenericOverlay();
                        }
                      } else {
                        _removeGenericOverlay();
                      }
                    },
                  ),
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

}
