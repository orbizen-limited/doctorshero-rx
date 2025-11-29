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
    }
  }
  
  void _removeComplaint(int index) {
    setState(() {
      _selectedComplaints.removeAt(index);
    });
  }
  
  void _updateComplaintField(int index, String field, String value) {
    setState(() {
      _selectedComplaints[index][field] = value;
    });
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
                    'Chief Complaint',
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
                      widget.onSave(_selectedComplaints);
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
            
            // Complaint Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          _addComplaint(value);
                          _customController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_customController.text.isNotEmpty) {
                        _addComplaint(_customController.text);
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
            
            // Selected Complaints Table
            if (_selectedComplaints.isNotEmpty) ...[
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
                      ..._selectedComplaints.asMap().entries.map((entry) {
                        final index = entry.key;
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
                                child: Text(
                                  complaint['name']!,
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
                                  onChanged: (value) => _updateComplaintField(index, 'value', value),
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
                                  onChanged: (value) => _updateComplaintField(index, 'note', value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () => _removeComplaint(index),
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
                    'No complaints selected',
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
}
