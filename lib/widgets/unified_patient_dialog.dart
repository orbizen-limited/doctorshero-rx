import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/patient_service.dart';

class UnifiedPatientDialog extends StatefulWidget {
  final String? initialName;
  final String? initialAge;
  final String? initialGender;
  final String? initialPhone;
  final String? initialPatientId;
  final String? initialDate;
  final Function(Map<String, String>) onSave;

  const UnifiedPatientDialog({
    Key? key,
    this.initialName,
    this.initialAge,
    this.initialGender,
    this.initialPhone,
    this.initialPatientId,
    this.initialDate,
    required this.onSave,
  }) : super(key: key);

  @override
  State<UnifiedPatientDialog> createState() => _UnifiedPatientDialogState();
}

class _UnifiedPatientDialogState extends State<UnifiedPatientDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  String _selectedGender = 'Male';
  bool _isSearching = false;
  List<Map<String, dynamic>> _matchedPatients = [];
  final PatientService _patientService = PatientService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _ageController.text = widget.initialAge ?? '';
    
    // Ensure gender is valid (Male, Female, or Other)
    final validGenders = ['Male', 'Female', 'Other'];
    if (widget.initialGender != null && validGenders.contains(widget.initialGender)) {
      _selectedGender = widget.initialGender!;
    } else {
      _selectedGender = 'Male'; // Default
    }
    
    _phoneController.text = widget.initialPhone ?? '';
    _patientIdController.text = widget.initialPatientId ?? '';
    _dateController.text = widget.initialDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Add listeners for smart matching
    _phoneController.addListener(_onPhoneChanged);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _patientIdController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    
    if (phone.length >= 8) {
      // If name is also entered, do combined search
      if (name.length >= 2) {
        _searchPatientsByPhoneAndName(phone, name);
      } else {
        // Just phone search
        _searchPatientsByPhone(phone);
      }
    }
  }

  void _onNameChanged() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    
    // Only search if phone is entered (8+ digits) and name has 2+ chars
    if (phone.length >= 8 && name.length >= 2) {
      _searchPatientsByPhoneAndName(phone, name);
    }
  }

  Future<void> _searchPatientsByPhone(String phone) async {
    setState(() => _isSearching = true);
    
    try {
      print('🔍 Searching by phone: $phone');
      final matches = await _patientService.searchByPhone(phone);
      print('✅ Found ${matches.length} matches: $matches');
      setState(() {
        _matchedPatients = matches;
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Error searching by phone: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _searchPatientsByPhoneAndName(String phone, String name) async {
    setState(() => _isSearching = true);
    
    try {
      print('🔍 Searching by phone: $phone and name: $name');
      final matches = await _patientService.searchByPhoneAndName(
        phone: phone,
        name: name,
      );
      print('✅ Found ${matches.length} matches: $matches');

      if (matches.isNotEmpty) {
        // Auto-fill with the best match
        final bestMatch = matches.first;
        print('📝 Auto-filling with: ${bestMatch['name']}');
        setState(() {
          _nameController.text = bestMatch['name'] ?? '';
          _ageController.text = (bestMatch['age'] ?? '').toString();
          
          // Validate and set gender
          final gender = bestMatch['gender'];
          if (gender != null && ['Male', 'Female', 'Other'].contains(gender)) {
            _selectedGender = gender;
          }
          
          _patientIdController.text = bestMatch['patient_id'] ?? '';
          _matchedPatients = matches;
          _isSearching = false;
        });
      } else {
        print('⚠️ No matches found');
        setState(() {
          _matchedPatients = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('❌ Error searching by phone and name: $e');
      setState(() => _isSearching = false);
    }
  }

  String _generateUPID() {
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      // UPID format: UPID-{phone}
      return 'UPID-$phone';
    }
    // Fallback: UPID-{timestamp}
    return 'UPID-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _autoFillFromMatch(Map<String, dynamic> patient) {
    setState(() {
      _nameController.text = patient['name'] ?? '';
      _ageController.text = (patient['age'] ?? '').toString();
      
      // Validate and set gender
      final gender = patient['gender'];
      if (gender != null && ['Male', 'Female', 'Other'].contains(gender)) {
        _selectedGender = gender;
      }
      
      _phoneController.text = patient['phone'] ?? '';
      _patientIdController.text = patient['patient_id'] ?? '';
    });
  }

  void _handleSave() {
    // Validation: Name and Phone are required
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient name is required')),
      );
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required')),
      );
      return;
    }
    
    // If no patient ID, generate UPID
    if (_patientIdController.text.trim().isEmpty) {
      _patientIdController.text = _generateUPID();
    }
    
    // If age is empty, set default
    if (_ageController.text.trim().isEmpty) {
      _ageController.text = '0';
    }

    final data = {
      'name': _nameController.text.trim(),
      'age': _ageController.text.trim(),
      'gender': _selectedGender,
      'phone': _phoneController.text.trim(),
      'patientId': _patientIdController.text.trim(),
      'date': _dateController.text.trim(),
    };

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Phone Number Field
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Show matched patients
            if (_matchedPatients.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Found existing patients:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_matchedPatients.take(3).map((apt) {
                      return InkWell(
                        onTap: () => _autoFillFromMatch(apt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${apt['name']} - ${apt['phone']}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Patient Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Patient Name *',
                hintText: 'Enter patient name',
                prefixIcon: const Icon(Icons.person, color: Color(0xFF3B82F6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // Age and Gender Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      hintText: 'Enter age',
                      prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF3B82F6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.wc, color: Color(0xFF3B82F6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Patient ID Field (read-only, auto-generated)
            TextField(
              controller: _patientIdController,
              decoration: InputDecoration(
                labelText: 'Patient ID',
                hintText: 'Auto-generated',
                prefixIcon: const Icon(Icons.badge, color: Color(0xFF3B82F6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Date Field
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(Icons.event, color: Color(0xFF3B82F6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _patientIdController.text.isEmpty || _patientIdController.text.startsWith('UPID-')
                          ? 'Patient ID will be auto-generated as UPID (Unknown Patient ID)'
                          : 'Existing patient found - using registered ID',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE3001),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Patient Info',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
