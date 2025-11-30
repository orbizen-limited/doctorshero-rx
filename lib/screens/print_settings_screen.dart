import 'package:flutter/material.dart';
import '../services/prescription_print_service.dart';

// Hospital presets
class HospitalPreset {
  final String name;
  final double topMargin;
  final double bottomMargin;

  HospitalPreset({
    required this.name,
    required this.topMargin,
    required this.bottomMargin,
  });
}

class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  final TextEditingController _topMarginController = TextEditingController();
  final TextEditingController _bottomMarginController = TextEditingController();
  final TextEditingController _leftMarginController = TextEditingController();
  final TextEditingController _rightMarginController = TextEditingController();
  final TextEditingController _leftColumnWidthController = TextEditingController();
  bool _isLoading = true;
  String? _selectedPreset;

  // Pre-defined hospital presets
  final List<HospitalPreset> _hospitalPresets = [
    HospitalPreset(name: 'Custom', topMargin: 3.0, bottomMargin: 3.0),
    HospitalPreset(name: 'Green Life Hospital', topMargin: 5.0, bottomMargin: 3.0),
    HospitalPreset(name: 'Square Hospital', topMargin: 4.5, bottomMargin: 3.5),
    HospitalPreset(name: 'Apollo Hospital', topMargin: 4.0, bottomMargin: 3.0),
    HospitalPreset(name: 'United Hospital', topMargin: 5.5, bottomMargin: 4.0),
    HospitalPreset(name: 'Labaid Hospital', topMargin: 4.0, bottomMargin: 2.5),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final margins = await PrescriptionPrintService.getMarginSettings();
    setState(() {
      _topMarginController.text = margins['top']!.toStringAsFixed(1);
      _bottomMarginController.text = margins['bottom']!.toStringAsFixed(1);
      _leftMarginController.text = (margins['left'] ?? 1.5).toStringAsFixed(1);
      _rightMarginController.text = (margins['right'] ?? 0.8).toStringAsFixed(1);
      _leftColumnWidthController.text = (margins['leftColumnWidth'] ?? 7.0).toStringAsFixed(1);
      _selectedPreset = 'Custom';
      _isLoading = false;
    });
  }

  void _applyPreset(String? presetName) {
    if (presetName == null) return;
    
    final preset = _hospitalPresets.firstWhere(
      (p) => p.name == presetName,
      orElse: () => _hospitalPresets[0],
    );

    setState(() {
      _selectedPreset = presetName;
      _topMarginController.text = preset.topMargin.toStringAsFixed(1);
      _bottomMarginController.text = preset.bottomMargin.toStringAsFixed(1);
    });
  }

  Future<void> _saveSettings() async {
    final top = double.tryParse(_topMarginController.text) ?? 3.0;
    final bottom = double.tryParse(_bottomMarginController.text) ?? 3.0;
    final left = double.tryParse(_leftMarginController.text) ?? 1.5;
    final right = double.tryParse(_rightMarginController.text) ?? 0.8;
    final leftColumnWidth = double.tryParse(_leftColumnWidthController.text) ?? 7.0;

    await PrescriptionPrintService.saveMarginSettings(
      top, 
      bottom, 
      left: left,
      right: right,
      leftColumnWidth: leftColumnWidth,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Print settings saved successfully!'),
          backgroundColor: Color(0xFFFE3001),
        ),
      );
    }
  }

  @override
  void dispose() {
    _topMarginController.dispose();
    _bottomMarginController.dispose();
    _leftMarginController.dispose();
    _rightMarginController.dispose();
    _leftColumnWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final topMargin = double.tryParse(_topMarginController.text) ?? 3.0;
    final bottomMargin = double.tryParse(_bottomMarginController.text) ?? 3.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Controls
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Prescription Print Margins',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adjust margins to fit your pre-printed prescription paper',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Hospital Preset Selector
                  const Text(
                    'Hospital Paper Layout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPreset,
                        isExpanded: true,
                        items: _hospitalPresets.map((preset) {
                          return DropdownMenuItem(
                            value: preset.name,
                            child: Text(
                              preset.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _applyPreset,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top Margin Input
                  const Text(
                    'Top Margin (cm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _topMarginController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      setState(() {
                        _selectedPreset = 'Custom';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g., 5.0',
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Margin Input
                  const Text(
                    'Bottom Margin (cm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bottomMarginController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      setState(() {
                        _selectedPreset = 'Custom';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g., 3.0',
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
                  ),

                  const SizedBox(height: 24),

                  // Left Margin Input
                  const Text(
                    'Left Margin (cm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _leftMarginController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      setState(() {
                        _selectedPreset = 'Custom';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g., 1.5',
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
                  ),

                  const SizedBox(height: 24),

                  // Right Margin Input
                  const Text(
                    'Right Margin (cm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _rightMarginController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      setState(() {
                        _selectedPreset = 'Custom';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g., 0.8',
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
                  ),

                  const SizedBox(height: 24),

                  // Left Column Width Input
                  const Text(
                    'Left Column Width (cm)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _leftColumnWidthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      setState(() {
                        _selectedPreset = 'Custom';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g., 7.0',
                      suffixText: 'cm',
                      helperText: 'Width for Chief Complaint, Examination, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans'),
                  ),

                  const SizedBox(height: 32),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE047)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xFFCA8A04)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Measure the header and footer height on your pre-printed prescription paper and enter those values here.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCA8A04),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE3001),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 48),

          // Right Panel - Large A4 Preview
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Text(
                    'A4 Paper Layout Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // A4 ratio: 210mm x 297mm (1:1.414)
                        final maxWidth = constraints.maxWidth;
                        final maxHeight = constraints.maxHeight;
                        final a4Ratio = 297 / 210;
                        
                        double width, height;
                        if (maxHeight / maxWidth > a4Ratio) {
                          width = maxWidth;
                          height = width * a4Ratio;
                        } else {
                          height = maxHeight;
                          width = height / a4Ratio;
                        }

                        // Calculate margin heights in pixels
                        final totalHeight = height;
                        final topMarginHeight = (topMargin / 29.7) * totalHeight;
                        final bottomMarginHeight = (bottomMargin / 29.7) * totalHeight;
                        final printableHeight = totalHeight - topMarginHeight - bottomMarginHeight;

                        return Center(
                          child: Container(
                            width: width,
                            height: height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF1E293B), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Top Margin
                                Container(
                                  height: topMarginHeight,
                                  color: const Color(0xFFFEE2E2),
                                  child: Center(
                                    child: Text(
                                      'Top Margin: ${topMargin.toStringAsFixed(1)} cm',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ),
                                // Printable Area
                                Container(
                                  height: printableHeight,
                                  color: const Color(0xFFDCFCE7),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.description, size: 48, color: Color(0xFF16A34A)),
                                        SizedBox(height: 8),
                                        Text(
                                          'Printable Area',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Prescription content will print here',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bottom Margin
                                Container(
                                  height: bottomMarginHeight,
                                  color: const Color(0xFFFEE2E2),
                                  child: Center(
                                    child: Text(
                                      'Bottom Margin: ${bottomMargin.toStringAsFixed(1)} cm',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
