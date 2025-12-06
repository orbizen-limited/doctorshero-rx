import 'package:flutter/material.dart';

class ChiefComplaintDrawer extends StatefulWidget {
  final Function(List<Map<String, String>>) onSave;
  final VoidCallback onClose;

  const ChiefComplaintDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ChiefComplaintDrawer> createState() => _ChiefComplaintDrawerState();
}

class _ChiefComplaintDrawerState extends State<ChiefComplaintDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  
  List<Map<String, String>> _selectedComplaints = [];
  
  final List<String> _allComplaints = [
    'Low Back Pain',
    'Headache',
    'Abdominal pain',
    'Dizziness / vertigo',
    'Neck pain',
    'Dry cough',
    'Generalized Bodyache',
    'Fever',
    'Shortness of breath',
    'Abdominal bloating',
    'Chest pain',
    'Weight loss',
    'Nausea',
    'Fatigue',
    'Vomiting',
    'Diarrhea',
    'Constipation',
    'Joint pain',
    'Muscle pain',
    'Sore throat',
    'Runny nose',
    'Sneezing',
    'Cough with phlegm',
    'Difficulty breathing',
    'Palpitations',
    'Sweating',
    'Chills',
    'Loss of appetite',
    'Difficulty swallowing',
    'Heartburn',
    'Indigestion',
    'Bloating',
    'Gas',
    'Stomach cramps',
    'Back pain',
    'Shoulder pain',
    'Knee pain',
    'Hip pain',
    'Ankle pain',
    'Wrist pain',
    'Numbness',
    'Tingling',
    'Weakness',
    'Confusion',
    'Memory problems',
    'Vision problems',
    'Hearing problems',
    'Ringing in ears',
    'Skin rash',
    'Itching',
    'Swelling',
    'Bruising',
    'Bleeding',
  ];
  
  List<String> _getFilteredComplaints() {
    if (_searchController.text.isEmpty) {
      return _allComplaints;
    }
    return _allComplaints
        .where((c) => c.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }
  
  void _addComplaint(String name) {
    if (!_selectedComplaints.any((c) => c['name'] == name)) {
      setState(() {
        _selectedComplaints.add({
          'name': name,
          'value': '',
          'note': '',
        });
      });
      widget.onSave(_selectedComplaints); // Real-time update
    }
  }
  
  void _removeComplaint(int index) {
    setState(() {
      _selectedComplaints.removeAt(index);
    });
    widget.onSave(_selectedComplaints); // Real-time update
  }
  
  void _updateComplaintField(int index, String field, String value) {
    setState(() {
      _selectedComplaints[index][field] = value;
    });
    widget.onSave(_selectedComplaints); // Real-time update
  }

  Widget _buildTable(List<Map<String, String>> complaints, int startIndex) {
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
        ...complaints.asMap().entries.map((entry) {
          final localIndex = entry.key;
          final globalIndex = startIndex + localIndex;
          final complaint = entry.value;
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
                    key: ValueKey('name_${complaint['name']}_$globalIndex'),
                    controller: TextEditingController(text: complaint['name'] ?? ''),
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
                    onChanged: (value) => _updateComplaintField(globalIndex, 'name', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: ValueKey('value_${complaint['name']}_$globalIndex'),
                    controller: TextEditingController(text: complaint['value'] ?? ''),
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
                    onChanged: (value) => _updateComplaintField(globalIndex, 'value', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: ValueKey('note_${complaint['name']}_$globalIndex'),
                    controller: TextEditingController(text: complaint['note'] ?? ''),
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
                    onChanged: (value) => _updateComplaintField(globalIndex, 'note', value),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _removeComplaint(globalIndex),
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
    final filteredComplaints = _getFilteredComplaints();
    
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
                    'Chief Complaint',
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
                          hintText: 'Search complaints...',
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
                        _addComplaint(_customController.text);
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
                  hintText: 'Type custom complaint and press Enter or click Add button...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFE3001)),
                    onPressed: () {
                      if (_customController.text.isNotEmpty) {
                        _addComplaint(_customController.text);
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
                    _addComplaint(value);
                    _customController.clear();
                  }
                },
              ),
            ),
            
            // Complaint Tags
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
                    children: filteredComplaints.map((complaint) {
                      final isSelected = _selectedComplaints.any((c) => c['name'] == complaint);
                      return InkWell(
                        onTap: () => _addComplaint(complaint),
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
                            complaint,
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
            
            // Selected Complaints Table (2 tables side by side)
            if (_selectedComplaints.isNotEmpty) ...[
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
                          _selectedComplaints.take((_selectedComplaints.length / 2).ceil()).toList(),
                          0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Table
                      Expanded(
                        child: _buildTable(
                          _selectedComplaints.skip((_selectedComplaints.length / 2).ceil()).toList(),
                          (_selectedComplaints.length / 2).ceil(),
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
                      'No complaints selected',
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
