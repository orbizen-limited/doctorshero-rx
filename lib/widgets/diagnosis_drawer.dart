import 'package:flutter/material.dart';

class DiagnosisDrawer extends StatefulWidget {
  final Function(List<Map<String, String>>) onSave;
  final VoidCallback onClose;
  final List<Map<String, String>>? initialData;

  const DiagnosisDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
    this.initialData,
  }) : super(key: key);

  @override
  State<DiagnosisDrawer> createState() => _DiagnosisDrawerState();
}

class _DiagnosisDrawerState extends State<DiagnosisDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  
  List<Map<String, String>> _selectedDiagnoses = [];

  @override
  void initState() {
    super.initState();
    // Load initial data if provided
    if (widget.initialData != null) {
      _selectedDiagnoses = List<Map<String, String>>.from(
        widget.initialData!.map((item) => Map<String, String>.from(item)),
      );
    }
  }
  
  final List<String> _allDiagnoses = [
    'Viral infection',
    'Bacterial infection',
    'Hypertension',
    'Diabetes Type 2',
    'Gastritis',
    'Migraine',
    'Common cold',
    'Urinary tract infection',
    'Acute lymphoblastic leukaemia',
    'Abdominal aortic aneurysm',
    'Allergic rhinitis',
    'Bronchial Asthma',
    'Benign prostate enlargement',
    'Cervical Spondylosis',
    'Chronic kidney disease',
    'Chronic pancreatitis',
    'Chronic Rhinosinusitis',
    'COPD',
    'Diabetes mellitus (DM)',
    'Dyslipidaemia',
    'GAD',
    'GERD',
    'Hypo thyroidism',
    'Ischaemic Stroke',
    'IHD',
    'Iron deficiency anaemia',
    'Myelo-Radiculopathy',
    'Motor neuron disease (MND)',
    'Mechanical Low Back Pain',
    'Non Ulcer Dyspepsia',
    'Osteoporosis',
    'Osteoarthritis',
    'Onychomycosis',
    'Peptic Ulcer Disease',
    'Peripheral neuropathy',
    'PID',
    'PLID',
    'PMS',
    'PVD',
    'Rhinosinusitis',
    'RTI',
    'Tennis Elbow',
  ];
  
  List<String> _getFilteredDiagnoses() {
    if (_searchController.text.isEmpty) {
      return _allDiagnoses;
    }
    return _allDiagnoses
        .where((d) => d.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }
  
  void _addDiagnosis(String name) {
    if (!_selectedDiagnoses.any((d) => d['name'] == name)) {
      setState(() {
        _selectedDiagnoses.add({
          'name': name,
          'value': '',
          'note': '',
        });
      });
      widget.onSave(_selectedDiagnoses); // Real-time update
    }
  }
  
  void _removeDiagnosis(int index) {
    setState(() {
      _selectedDiagnoses.removeAt(index);
    });
    widget.onSave(_selectedDiagnoses); // Real-time update
  }
  
  void _updateDiagnosisField(int index, String field, String value) {
    setState(() {
      _selectedDiagnoses[index][field] = value;
    });
    widget.onSave(_selectedDiagnoses); // Real-time update
  }

  Widget _buildTable(List<Map<String, String>> diagnoses, int startIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  'Value',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Table Rows
        ...diagnoses.asMap().entries.map((entry) {
          final localIndex = entry.key;
          final globalIndex = startIndex + localIndex;
          final diagnosis = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: ValueKey('name_${diagnosis['name']}_$globalIndex'),
                    controller: TextEditingController(text: diagnosis['name'] ?? ''),
                    decoration: InputDecoration(
                      hintText: 'Name',
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
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) => _updateDiagnosisField(globalIndex, 'name', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: ValueKey('value_${diagnosis['name']}_$globalIndex'),
                    controller: TextEditingController(text: diagnosis['value'] ?? ''),
                    decoration: InputDecoration(
                      hintText: 'Value',
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
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) => _updateDiagnosisField(globalIndex, 'value', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: ValueKey('note_${diagnosis['name']}_$globalIndex'),
                    controller: TextEditingController(text: diagnosis['note'] ?? ''),
                    decoration: InputDecoration(
                      hintText: 'Note',
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
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) => _updateDiagnosisField(globalIndex, 'note', value),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _removeDiagnosis(globalIndex),
                  icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDiagnoses = _getFilteredDiagnoses();
    
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 900,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Search and Add Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFE3001),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Diagnosis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Search Field in Header
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search diagnoses...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button in Header
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_customController.text.isNotEmpty) {
                        _addDiagnosis(_customController.text);
                        _customController.clear();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFE3001),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Custom Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: 'Type custom diagnosis and press Enter or click Add button...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFE3001)),
                    onPressed: () {
                      if (_customController.text.isNotEmpty) {
                        _addDiagnosis(_customController.text);
                        _customController.clear();
                      }
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFE3001)),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _addDiagnosis(value);
                    _customController.clear();
                  }
                },
              ),
            ),
            
            // Diagnosis Tags
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredDiagnoses.map((diagnosis) {
                      final isSelected = _selectedDiagnoses.any((d) => d['name'] == diagnosis);
                      return InkWell(
                        onTap: () => _addDiagnosis(diagnosis),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            diagnosis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selected Diagnoses Table (2 tables side by side)
            if (_selectedDiagnoses.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Table
                      Expanded(
                        child: _buildTable(
                          _selectedDiagnoses.take((_selectedDiagnoses.length / 2).ceil()).toList(),
                          0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Table
                      Expanded(
                        child: _buildTable(
                          _selectedDiagnoses.skip((_selectedDiagnoses.length / 2).ceil()).toList(),
                          (_selectedDiagnoses.length / 2).ceil(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'No diagnosis selected',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
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
}
