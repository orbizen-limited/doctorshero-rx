import 'package:flutter/material.dart';

class DiagnosisDrawer extends StatefulWidget {
  final Function(List<Map<String, String>>) onSave;
  final VoidCallback onClose;

  const DiagnosisDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
  }) : super(key: key);

  @override
  State<DiagnosisDrawer> createState() => _DiagnosisDrawerState();
}

class _DiagnosisDrawerState extends State<DiagnosisDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  
  List<Map<String, String>> _selectedDiagnoses = [];
  String _selectedTab = 'Favourite';
  
  final List<String> _favouriteDiagnoses = [
    'Viral infection',
    'Bacterial infection',
    'Hypertension',
    'Diabetes Type 2',
    'Gastritis',
    'Migraine',
    'Common cold',
    'Urinary tract infection',
  ];
  
  final Map<String, List<String>> _groupedDiagnoses = {
    'A': ['Acute lymphoblastic leukaemia', 'Abdominal aortic aneurysm', 'Allergic rhinitis'],
    'B': ['Bacterial infection', 'Bronchial Asthma', 'Benign prostate enlargement'],
    'C': ['Cervical Spondylosis', 'Chronic kidney disease', 'Chronic pancreatitis', 'Chronic Rhinosinusitis', 'COPD', 'Common cold'],
    'D': ['Diabetes mellitus (DM)', 'Dyslipidaemia'],
    'G': ['Gastritis', 'GAD', 'GERD'],
    'H': ['Hypertension', 'Hypo thyroidism'],
    'I': ['Ischaemic Stroke', 'IHD', 'Iron deficiency anaemia'],
    'M': ['Migraine', 'Myelo-Radiculopathy', 'Motor neuron disease (MND)', 'Mechanical Low Back Pain'],
    'N': ['Non Ulcer Dyspepsia'],
    'O': ['Osteoporosis', 'Osteoarthritis', 'Onychomycosis'],
    'P': ['Peptic Ulcer Disease', 'Peripheral neuropathy', 'PID', 'PLID', 'PMS', 'PVD'],
    'R': ['Rhinosinusitis', 'RTI'],
    'T': ['Tennis Elbow'],
    'U': ['Urinary tract infection'],
    'V': ['Viral infection'],
  };
  
  List<String> _getFilteredDiagnoses() {
    if (_selectedTab == 'Favourite') {
      if (_searchController.text.isEmpty) {
        return _favouriteDiagnoses;
      }
      return _favouriteDiagnoses
          .where((d) => d.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    } else {
      // Group tab
      List<String> allDiagnoses = [];
      _groupedDiagnoses.forEach((key, value) {
        allDiagnoses.addAll(value);
      });
      if (_searchController.text.isEmpty) {
        return allDiagnoses;
      }
      return allDiagnoses
          .where((d) => d.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }
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
    }
  }
  
  void _removeDiagnosis(int index) {
    setState(() {
      _selectedDiagnoses.removeAt(index);
    });
  }
  
  void _updateDiagnosisField(int index, String field, String value) {
    setState(() {
      _selectedDiagnoses[index][field] = value;
    });
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
            // Header
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
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(_selectedDiagnoses);
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFE3001),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
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
                onChanged: (value) => setState(() {}),
              ),
            ),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('Favourite'),
                  const SizedBox(width: 16),
                  _buildTab('Group'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Diagnosis Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            
            const SizedBox(height: 20),
            
            // Custom Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      decoration: InputDecoration(
                        hintText: 'Type custom item...',
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
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _addDiagnosis(value);
                          _customController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_customController.text.isNotEmpty) {
                        _addDiagnosis(_customController.text);
                        _customController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE3001),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selected Diagnoses Table
            if (_selectedDiagnoses.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
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
                      ..._selectedDiagnoses.asMap().entries.map((entry) {
                        final index = entry.key;
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
                                child: Text(
                                  diagnosis['name']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextField(
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
                                  onChanged: (value) => _updateDiagnosisField(index, 'value', value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextField(
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
                                  onChanged: (value) => _updateDiagnosisField(index, 'note', value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () => _removeDiagnosis(index),
                                icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'No diagnosis selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
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
  
  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return InkWell(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFFE3001) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFFFE3001) : const Color(0xFF64748B),
            fontFamily: 'ProductSans',
          ),
        ),
      ),
    );
  }
}
