import 'package:flutter/material.dart';
import '../services/medicine_database_service.dart';

class MedicineAutocompleteField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool searchByGeneric;
  final Function(MedicineData) onMedicineSelected;
  final Function(String) onTextChanged;

  const MedicineAutocompleteField({
    Key? key,
    required this.label,
    this.initialValue = '',
    this.searchByGeneric = false,
    required this.onMedicineSelected,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  State<MedicineAutocompleteField> createState() => _MedicineAutocompleteFieldState();
}

class _MedicineAutocompleteFieldState extends State<MedicineAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<MedicineData> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(MedicineAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if not focused (user is not typing)
    if (!_focusNode.hasFocus && widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged(String value) {
    widget.onTextChanged(value);
    
    if (value.isEmpty) {
      _removeOverlay();
      return;
    }

    // Search medicines
    if (widget.searchByGeneric) {
      _suggestions = MedicineDatabaseService.searchByGenericName(value);
    } else {
      _suggestions = MedicineDatabaseService.searchByMedicineName(value);
    }

    if (_suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _getTextFieldHeight() + 4),
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
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final medicine = _suggestions[index];
                  return InkWell(
                    onTap: () {
                      _controller.text = medicine.displayName;
                      widget.onMedicineSelected(medicine);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < _suggestions.length - 1
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

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  double _getTextFieldHeight() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 40;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          isDense: true,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontFamily: 'ProductSans',
        ),
        onChanged: _onTextChanged,
      ),
    );
  }
}
