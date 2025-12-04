import 'package:flutter/material.dart';

class AdviceDrawer extends StatefulWidget {
  final List<String> selectedAdvice;
  final Function(List<String>) onAdviceSelected;

  const AdviceDrawer({
    Key? key,
    required this.selectedAdvice,
    required this.onAdviceSelected,
  }) : super(key: key);

  @override
  State<AdviceDrawer> createState() => _AdviceDrawerState();
}

class _AdviceDrawerState extends State<AdviceDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  List<String> _filteredItems = [];
  List<String> _selectedAdvice = [];
  Map<String, DateTime> _lastTapTime = {};
  Map<String, bool> _previousState = {};

  final List<String> _predefinedAdvice = [
    'Take medicines after meals for better absorption',
    'Take medicines before meals',
    'Take medicines with meals',
    'Take on empty stomach',
    'Drink plenty of water (2-3 liters daily)',
    'Avoid direct sunlight exposure',
    'No alcohol consumption',
    'Take with milk',
    'Do not crush or chew',
    'Dissolve in water before taking',
    'Take at bedtime',
    'Take in the morning',
    'Avoid driving or operating machinery',
    'Complete the full course',
    'Do not stop suddenly',
    'Store in cool dry place',
    'Keep away from children',
    'Avoid spicy and oily food',
    'Take rest',
    'Light exercise recommended',
    'Avoid heavy exercise',
    'Regular follow-up required',
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _predefinedAdvice;
    _selectedAdvice = List.from(widget.selectedAdvice);
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _predefinedAdvice;
      } else {
        _filteredItems = _predefinedAdvice
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleAdvice(String advice) {
    final now = DateTime.now();
    final lastTap = _lastTapTime[advice];
    final wasSelected = _selectedAdvice.contains(advice);
    
    // Check for double-click (within 300ms)
    if (lastTap != null && now.difference(lastTap).inMilliseconds < 300) {
      // Double-click: undo the previous state
      setState(() {
        final previousWasSelected = _previousState[advice] ?? false;
        if (previousWasSelected && !_selectedAdvice.contains(advice)) {
          // Was selected before first click, now deselected, so undo by selecting
          _selectedAdvice.add(advice);
        } else if (!previousWasSelected && _selectedAdvice.contains(advice)) {
          // Was not selected before first click, now selected, so undo by deselecting
          _selectedAdvice.remove(advice);
        }
      });
      _lastTapTime.remove(advice);
      _previousState.remove(advice);
      // Update in real-time
      widget.onAdviceSelected(_selectedAdvice);
    } else {
      // Single click: toggle normally
      // Store previous state before toggling
      _previousState[advice] = wasSelected;
      setState(() {
        if (wasSelected) {
          _selectedAdvice.remove(advice);
        } else {
          _selectedAdvice.add(advice);
        }
      });
      _lastTapTime[advice] = now;
      // Update in real-time
      widget.onAdviceSelected(_selectedAdvice);
    }
  }

  void _addCustomAdvice() {
    if (_customController.text.isNotEmpty) {
      setState(() {
        _selectedAdvice.add(_customController.text);
      });
      _customController.clear();
      // Update in real-time
      widget.onAdviceSelected(_selectedAdvice);
    }
  }

  void _removeAdvice(String advice) {
    setState(() {
      _selectedAdvice.remove(advice);
    });
    // Update in real-time
    widget.onAdviceSelected(_selectedAdvice);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADVICE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Search Bar and Custom Input Row
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Search Bar - Half width
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search advice...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFFE3001)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'),
                      onChanged: _filterItems,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Custom Input - Half width
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      decoration: InputDecoration(
                        hintText: 'Add custom advice...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'),
                      onSubmitted: (_) => _addCustomAdvice(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button
                  ElevatedButton(
                    onPressed: _addCustomAdvice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE3001),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),

            // Predefined Advice Tags
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filteredItems.map((advice) {
                    final isSelected = _selectedAdvice.contains(advice);
                    return InkWell(
                      onTap: () => _toggleAdvice(advice),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFE3001) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          advice,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                            fontFamily: 'ProductSans',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),


            // Selected Advice List
            if (_selectedAdvice.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Advice:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._selectedAdvice.map((advice) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                advice,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeAdvice(advice),
                              icon: const Icon(Icons.close, size: 18),
                              color: const Color(0xFFEF4444),
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
          ],
        ),
      ),
    );
  }
}
