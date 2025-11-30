import 'package:flutter/material.dart';

class DosageDrawer extends StatefulWidget {
  final String medicineType;
  final String currentQuantity;
  final String currentFrequency;
  final String currentRoute;
  final String currentDuration;
  final Function(String quantity, String frequency, String route, String duration) onSave;

  const DosageDrawer({
    Key? key,
    required this.medicineType,
    required this.currentQuantity,
    required this.currentFrequency,
    required this.currentRoute,
    required this.currentDuration,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DosageDrawer> createState() => _DosageDrawerState();
}

class _DosageDrawerState extends State<DosageDrawer> {
  late TextEditingController _quantityController;
  late TextEditingController _frequencyController;
  late TextEditingController _routeController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.currentQuantity);
    _frequencyController = TextEditingController(text: widget.currentFrequency);
    _routeController = TextEditingController(text: widget.currentRoute);
    _durationController = TextEditingController(text: widget.currentDuration);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _frequencyController.dispose();
    _routeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  bool _isInjectionOrSpray() {
    return widget.medicineType.toLowerCase().contains('inj') || 
           widget.medicineType.toLowerCase().contains('spray');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  if (_isInjectionOrSpray()) ...[
                    // Quantity Field
                    const Text(
                      'Quantity (পরিমাণ)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        hintText: 'e.g., 1 Capsule, 1 Ampoule',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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

                    // Frequency Field
                    const Text(
                      'Frequency (কতবার)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _frequencyController,
                      decoration: InputDecoration(
                        hintText: 'e.g., 1 Time, 2 Times',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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

                    // Route Field (only for injections)
                    if (widget.medicineType.toLowerCase().contains('inj')) ...[
                      const Text(
                        'Route (পথ)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _routeController,
                        decoration: InputDecoration(
                          hintText: 'e.g., SC, IM, IV',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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
                    ],
                  ],

                  // Duration Field (in Bangla)
                  const Text(
                    'Duration (সময়কাল)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      hintText: 'e.g., 7 Din Por Por, 1 Bosor Por Por',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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
                    maxLines: 2,
                  ),

                  const SizedBox(height: 32),

                  // Common Bangla Duration Options
                  const Text(
                    'Common Durations (সাধারণ সময়কাল)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDurationChip('7 Din Por Por'),
                      _buildDurationChip('14 Din Por Por'),
                      _buildDurationChip('1 Mas Por Por'),
                      _buildDurationChip('3 Mas Por Por'),
                      _buildDurationChip('6 Mas Por Por'),
                      _buildDurationChip('1 Bosor Por Por'),
                    ],
                  ),
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
                    _quantityController.text,
                    _frequencyController.text,
                    _routeController.text,
                    _durationController.text,
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
    );
  }

  Widget _buildDurationChip(String duration) {
    return InkWell(
      onTap: () {
        setState(() {
          _durationController.text = duration;
        });
      },
      child: Chip(
        label: Text(
          duration,
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
