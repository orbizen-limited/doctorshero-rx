import 'package:flutter/material.dart';
import '../services/prescription_print_service.dart';

class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  final TextEditingController _topMarginController = TextEditingController();
  final TextEditingController _bottomMarginController = TextEditingController();
  bool _isLoading = true;

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
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final top = double.tryParse(_topMarginController.text) ?? 3.0;
    final bottom = double.tryParse(_bottomMarginController.text) ?? 3.0;

    await PrescriptionPrintService.saveMarginSettings(top, bottom);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Print settings saved successfully!'),
          backgroundColor: Color(0xFFFE3001),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _topMarginController.dispose();
    _bottomMarginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Settings'),
        backgroundColor: const Color(0xFFFE3001),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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

                  // Preview Image
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'A4 Paper Layout',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 200,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF1E293B), width: 2),
                          ),
                          child: Column(
                            children: [
                              // Top Margin
                              Container(
                                height: 40,
                                color: const Color(0xFFFEE2E2),
                                child: const Center(
                                  child: Text(
                                    'Top Margin',
                                    style: TextStyle(fontSize: 10, color: Color(0xFFEF4444)),
                                  ),
                                ),
                              ),
                              // Content Area
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFDCFCE7),
                                  child: const Center(
                                    child: Text(
                                      'Printable Area',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF16A34A)),
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom Margin
                              Container(
                                height: 40,
                                color: const Color(0xFFFEE2E2),
                                child: const Center(
                                  child: Text(
                                    'Bottom Margin',
                                    style: TextStyle(fontSize: 10, color: Color(0xFFEF4444)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFCA8A04)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tip',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFCA8A04),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Measure the header and footer height on your pre-printed prescription paper and enter those values here.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFCA8A04),
                                ),
                              ),
                            ],
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
    );
  }
}
