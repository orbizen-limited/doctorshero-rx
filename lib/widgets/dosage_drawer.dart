import 'package:flutter/material.dart';

class DosageDrawer extends StatefulWidget {
  final String medicineType;
  final String currentDosage;
  final String currentQuantity;
  final String currentFrequency;
  final String currentRoute;
  final String currentDurationNumber;
  final String currentDurationUnit;
  final String currentInterval;
  final String currentTillNumber;
  final String currentTillUnit;
  final Function(String dosage, String quantity, String frequency, String route, String durationNumber, String durationUnit, String interval, String tillNumber, String tillUnit) onSave;

  const DosageDrawer({
    Key? key,
    required this.medicineType,
    required this.currentDosage,
    required this.currentQuantity,
    required this.currentFrequency,
    required this.currentRoute,
    required this.currentDurationNumber,
    required this.currentDurationUnit,
    required this.currentInterval,
    required this.currentTillNumber,
    required this.currentTillUnit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DosageDrawer> createState() => _DosageDrawerState();
}

class _DosageDrawerState extends State<DosageDrawer> {
  late TextEditingController _dosageController;
  late TextEditingController _quantityController;
  late TextEditingController _frequencyController;
  late TextEditingController _routeController;
  late TextEditingController _durationNumberController;
  late TextEditingController _intervalController;
  late TextEditingController _tillNumberController;
  String _durationUnit = 'দিন';
  String _tillUnit = 'দিন';
  bool _isContinues = false;
  bool _isDurationContinues = false;

  // Convert English units to Bangla for backward compatibility
  String _convertToBangla(String unit) {
    switch (unit) {
      case 'Days':
        return 'দিন';
      case 'Weeks':
        return 'সপ্তাহ';
      case 'Months':
        return 'মাস';
      case 'Years':
        return 'বছর';
      default:
        return unit; // Already in Bangla or empty
    }
  }

  // Convert Continues to Bangla
  String _convertContinuesToBangla(String value) {
    return value == 'Continues' ? 'চলবে' : value;
  }

  @override
  void initState() {
    super.initState();
    _dosageController = TextEditingController(text: widget.currentDosage);
    _quantityController = TextEditingController(text: widget.currentQuantity);
    _frequencyController = TextEditingController(text: widget.currentFrequency);
    _routeController = TextEditingController(text: widget.currentRoute);
    _durationNumberController = TextEditingController(text: widget.currentDurationNumber);
    _intervalController = TextEditingController(text: widget.currentInterval);
    _tillNumberController = TextEditingController(text: widget.currentTillNumber);
    _durationUnit = widget.currentDurationUnit.isEmpty ? 'দিন' : _convertToBangla(widget.currentDurationUnit);
    _tillUnit = widget.currentTillUnit.isEmpty ? 'দিন' : _convertToBangla(widget.currentTillUnit);
    _isContinues = widget.currentTillNumber == 'Continues' || widget.currentTillNumber == 'চলবে';
    _isDurationContinues = widget.currentDurationNumber == 'Continues' || widget.currentDurationNumber == 'চলবে';
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _quantityController.dispose();
    _frequencyController.dispose();
    _routeController.dispose();
    _durationNumberController.dispose();
    _intervalController.dispose();
    _tillNumberController.dispose();
    super.dispose();
  }

  bool _isInjectionOrSpray() {
    return widget.medicineType.toLowerCase().contains('inj') || 
           widget.medicineType.toLowerCase().contains('spray');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFE3001),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Dosage Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DOSAGE SECTION
                    const Text(
                      'Dosage (ডোজ)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isInjectionOrSpray()) ...[
                      // For Injections/Sprays: Quantity x Frequency
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quantity',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _quantityController,
                                  decoration: InputDecoration(
                                    hintText: '1 Injection',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Frequency',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _frequencyController,
                                  decoration: InputDecoration(
                                    hintText: '1 time',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      if (widget.medicineType.toLowerCase().contains('inj')) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Route',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _routeController,
                          decoration: InputDecoration(
                            hintText: 'SC, IM, IV',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ] else ...[
                      // For regular medicines: 1+0+1 format
                      TextField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 1+0+1',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // DURATION SECTION
                    const Text(
                      'Duration (সময়কাল)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Number',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _durationNumberController,
                                keyboardType: TextInputType.number,
                                enabled: !_isDurationContinues,
                                decoration: InputDecoration(
                                  hintText: '7',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.all(12),
                                  filled: _isDurationContinues,
                                  fillColor: _isDurationContinues ? const Color(0xFFF1F5F9) : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unit',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _durationUnit,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  filled: _isDurationContinues,
                                  fillColor: _isDurationContinues ? const Color(0xFFF1F5F9) : null,
                                ),
                                items: ['দিন', 'সপ্তাহ', 'মাস', 'বছর'].map((unit) {
                                  return DropdownMenuItem(value: unit, child: Text(unit));
                                }).toList(),
                                onChanged: _isDurationContinues ? null : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _durationUnit = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // চলবে checkbox for Duration
                    CheckboxListTile(
                      value: _isDurationContinues,
                      onChanged: (value) {
                        setState(() {
                          _isDurationContinues = value ?? false;
                          if (_isDurationContinues) {
                            _durationNumberController.text = '';
                          }
                        });
                      },
                      title: const Text(
                        'চলবে (No specific duration)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),

                    const SizedBox(height: 24),

                    // INTERVAL SECTION (Optional)
                    const Text(
                      'Interval (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _intervalController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Por Por (interval), Daily',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild to show/hide Till section
                      },
                    ),

                    const SizedBox(height: 24),

                    // Quick Interval Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIntervalChip('পর পর'),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // TILL SECTION (Only show if interval has input)
                    if (_intervalController.text.isNotEmpty) ...[
                      const Text(
                        'Till / Until (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'When should the medicine be stopped?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Continues Checkbox
                    CheckboxListTile(
                      value: _isContinues,
                      onChanged: (value) {
                        setState(() {
                          _isContinues = value ?? false;
                          if (_isContinues) {
                            _tillNumberController.clear();
                          }
                        });
                      },
                      title: const Text(
                        'চলবে (No end date)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Number',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _tillNumberController,
                                keyboardType: TextInputType.number,
                                enabled: !_isContinues,
                                decoration: InputDecoration(
                                  hintText: '7',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.all(12),
                                  filled: _isContinues,
                                  fillColor: _isContinues ? const Color(0xFFF1F5F9) : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unit',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _tillUnit,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  filled: _isContinues,
                                  fillColor: _isContinues ? const Color(0xFFF1F5F9) : null,
                                ),
                                items: ['দিন', 'সপ্তাহ', 'মাস', 'বছর'].map((unit) {
                                  return DropdownMenuItem(value: unit, child: Text(unit));
                                }).toList(),
                                onChanged: _isContinues ? null : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _tillUnit = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ], // End of Till section conditional
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _dosageController.text,
                      _quantityController.text,
                      _frequencyController.text,
                      _routeController.text,
                      _isDurationContinues ? 'চলবে' : _durationNumberController.text,
                      _durationUnit,
                      _intervalController.text,
                      _isContinues ? 'চলবে' : _tillNumberController.text,
                      _tillUnit,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE3001),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalChip(String interval) {
    return InkWell(
      onTap: () {
        setState(() {
          _intervalController.text = interval;
        });
      },
      child: Chip(
        label: Text(
          interval,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'ProductSans',
          ),
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
