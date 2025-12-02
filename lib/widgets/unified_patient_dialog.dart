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
  
  /// Generate a unique patient ID (UPID) format: U + timestamp
  String _generateUPID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'U$timestamp';
  }

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
      final matches = await _patientService.searchByPhone(phone);
      setState(() {
        _matchedPatients = matches;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _searchPatientsByPhoneAndName(String phone, String name) async {
    setState(() => _isSearching = true);
    
    try {
      final matches = await _patientService.searchByPhoneAndName(
        phone: phone,
        name: name,
      );

      setState(() {
        _matchedPatients = matches;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
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

  /// Show dialog with similar patients when duplicate is detected
  Future<bool?> _showDuplicateDialog(List<dynamic> similarPatients) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Similar Patients Found'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patients with this phone number already exist:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ...similarPatients.map((patient) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2196F3),
                    child: Text(
                      patient['name']?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    patient['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'PID: ${patient['patient_id']} • Age: ${patient['age']} • ${patient['gender']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Use this existing patient
                      _autoFillFromMatch(patient);
                      Navigator.pop(context, null); // Don't create new
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Use This', style: TextStyle(fontSize: 12)),
                  ),
                ),
              )).toList(),
              const SizedBox(height: 16),
              const Text(
                'Or create a new patient with the same phone number?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE3001),
            ),
            child: const Text('Create New Patient'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    // Validation: Only name is required
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient name is required')),
      );
      return;
    }
    
    // If no patient ID, create new patient or generate UPID
    if (_patientIdController.text.trim().isEmpty) {
      // If no phone provided, generate UPID directly
      if (_phoneController.text.trim().isEmpty) {
        _patientIdController.text = _generateUPID();
        print('✅ Generated UPID (no phone): ${_patientIdController.text}');
        
        final data = {
          'patientId': _patientIdController.text,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'age': _ageController.text.trim(),
          'gender': _selectedGender,
          'date': _dateController.text.trim(),
        };
        
        widget.onSave(data);
        Navigator.pop(context);
        return;
      }
      
      // If phone provided, try to create patient in API
      final response = await _patientService.createPatient(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        age: _ageController.text.trim(),
        gender: _selectedGender,
      );
      
      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create patient. Please try again.')),
        );
        return;
      }
      
      // Check if duplicate found (requires confirmation)
      if (response['requires_confirmation'] == true) {
        final similarPatients = response['similar_patients'] as List?;
        if (similarPatients != null && similarPatients.isNotEmpty) {
          // Show similar patients and ask user to confirm
          final shouldForceCreate = await _showDuplicateDialog(similarPatients);
          if (shouldForceCreate == true) {
            // User wants to create anyway
            final forceResponse = await _patientService.createPatient(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              age: _ageController.text.trim(),
              gender: _selectedGender,
              forceCreate: true,
            );
            
            if (forceResponse != null && forceResponse['success'] == true) {
              _patientIdController.text = forceResponse['data']['patient_id'];
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create patient.')),
              );
              return;
            }
          } else {
            // User cancelled
            return;
          }
        }
      } else if (response['success'] == true && response['data'] != null) {
        // Patient created successfully
        _patientIdController.text = response['data']['patient_id'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create patient.')),
        );
        return;
      }
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
                labelText: 'Phone Number',
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
                      _patientIdController.text.isEmpty
                          ? 'Phone optional. UPID will be generated if no phone or no match found.'
                          : 'Existing patient found - ID: ${_patientIdController.text}',
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
