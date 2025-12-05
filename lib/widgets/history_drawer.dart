import 'package:flutter/material.dart';

class HistoryDrawer extends StatefulWidget {
  final Function(List<Map<String, String>>) onSave;
  final VoidCallback onClose;

  const HistoryDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
  }) : super(key: key);

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  late TabController _tabController;
  
  // Selected items - using HistoryItem class for Value, For, Duration, Note
  List<HistoryItem> _selectedItems = [];
  
  // Tab configuration
  final List<Map<String, dynamic>> _tabs = [
    {
      'key': 'presentingComplaint',
      'title': 'History of Presenting Complaint',
      'sections': ['presentingComplaint'],
    },
    {
      'key': 'pastMedical',
      'title': 'Past Medical History',
      'sections': ['pastMedical'],
    },
    {
      'key': 'drugHistory',
      'title': 'Drug History',
      'sections': ['drugHistory'],
    },
    {
      'key': 'familyHistory',
      'title': 'Family History',
      'sections': ['familyHistory'],
    },
    {
      'key': 'menstrualObstetric',
      'title': 'Menstrual & Obstetric',
      'sections': ['menstrualHistory', 'obstetricHistory'],
    },
    {
      'key': 'personalSocial',
      'title': 'Personal & Social',
      'sections': ['personalHistory', 'socioeconomicHistory', 'occupationalHistory'],
    },
    {
      'key': 'immunization',
      'title': 'Immunization History',
      'sections': ['immunizationHistory'],
    },
  ];
  
  // Custom options for each section
  final Map<String, List<String>> _customOptions = {
    'presentingComplaint': [],
    'pastMedical': [],
    'drugHistory': [],
    'familyHistory': [],
    'menstrualHistory': [],
    'obstetricHistory': [],
    'personalHistory': [],
    'socioeconomicHistory': [],
    'occupationalHistory': [],
    'immunizationHistory': [],
  };
  
  // Predefined options for each history category
  final Map<String, List<String>> _predefinedOptions = {
    'presentingComplaint': [
      'Fever',
      'Cough',
      'Headache',
      'Abdominal pain',
      'Chest pain',
      'Shortness of breath',
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Constipation',
      'Fatigue',
      'Weight loss',
      'Dizziness',
      'Joint pain',
      'Back pain',
    ],
    'pastMedical': [
      'No known allergies',
      'No prior surgeries',
      'Diabetes',
      'Hypertension',
      'Asthma',
      'Heart disease',
      'Kidney disease',
      'Liver disease',
      'Thyroid disorder',
      'Epilepsy',
      'Tuberculosis',
      'Stroke',
      'Cancer',
      'Arthritis',
      'No known medical history',
    ],
    'drugHistory': [
      'Antihypertensive',
      'Antidiabetic',
      'Anticoagulant',
      'Aspirin',
      'Steroids',
      'Antibiotics',
      'No current medications',
      'Allergy to penicillin',
      'Allergy to sulfa drugs',
      'Allergy to NSAIDs',
    ],
    'familyHistory': [
      'Diabetes',
      'Hypertension',
      'Heart disease',
      'Cancer',
      'Stroke',
      'Kidney disease',
      'Asthma',
      'Mental illness',
      'Family history of diabetes',
      'No significant family history',
    ],
    'menstrualHistory': [
      'Regular cycles',
      'Irregular cycles',
      'Menorrhagia',
      'Amenorrhea',
      'Dysmenorrhea',
      'Menopause',
      'Not applicable',
    ],
    'obstetricHistory': [
      'Gravida',
      'Para',
      'Abortions',
      'Live births',
      'Cesarean section',
      'Not applicable',
    ],
    'personalHistory': [
      'Smoking',
      'Smokes occasionally',
      'Alcohol consumption',
      'Tobacco chewing',
      'Betel nut',
      'No habits',
      'Exercise',
      'Sedentary lifestyle',
    ],
    'socioeconomicHistory': [
      'Low income',
      'Middle income',
      'High income',
      'Unemployed',
      'Employed',
      'Student',
      'Retired',
    ],
    'occupationalHistory': [
      'Office work',
      'Manual labor',
      'Healthcare worker',
      'Teacher',
      'Farmer',
      'Driver',
      'Housewife',
      'Student',
      'Retired',
    ],
    'immunizationHistory': [
      'BCG',
      'DPT',
      'Polio',
      'Hepatitis B',
      'MMR',
      'Tetanus',
      'COVID-19',
      'Incomplete',
      'Not vaccinated',
    ],
  };
  
  // Section titles
  final Map<String, String> _sectionTitles = {
    'presentingComplaint': 'History of Presenting Complaint',
    'pastMedical': 'Past Medical History',
    'drugHistory': 'Drug History',
    'familyHistory': 'Family History',
    'menstrualHistory': 'Menstrual History',
    'obstetricHistory': 'Obstetric & Gynecological History',
    'personalHistory': 'Personal History',
    'socioeconomicHistory': 'Socioeconomic History',
    'occupationalHistory': 'Occupational History',
    'immunizationHistory': 'Immunization History',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }
  
  // Get sections for current tab
  List<String> _getCurrentTabSections() {
    final currentTab = _tabs[_tabController.index];
    return currentTab['sections'] as List<String>;
  }
  
  // Get filtered options for current tab
  Map<String, List<String>> _getFilteredOptionsForTab() {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredGroups = <String, List<String>>{};
    final currentSections = _getCurrentTabSections();
    
    // Combine predefined and custom options for each section in current tab
    for (var sectionKey in currentSections) {
      final predefinedList = _predefinedOptions[sectionKey] ?? [];
      final customList = _customOptions[sectionKey] ?? [];
      final allOptions = [...predefinedList, ...customList];
      
      if (searchQuery.isEmpty) {
        // If no search, show all options
        filteredGroups[sectionKey] = allOptions;
      } else {
        // Filter by search query
        final filtered = allOptions
            .where((option) => option.toLowerCase().contains(searchQuery))
            .toList();
        if (filtered.isNotEmpty) {
          filteredGroups[sectionKey] = filtered;
        }
      }
    }
    
    return filteredGroups;
  }



  void _addItem(String name) {
    // Check if item already exists
    final exists = _selectedItems.any((item) => item.name == name);
    if (!exists) {
      setState(() {
        _selectedItems.add(HistoryItem(
          name: name,
          value: '',
          forField: '',
          duration: 'Day',
          note: '',
        ));
      });
    }
  }

  void _addCustomItem() {
    if (_customController.text.isNotEmpty) {
      _addItem(_customController.text);
      _customController.clear();
    }
  }

  void _updateItem(int index, HistoryItem item) {
    setState(() {
      _selectedItems[index] = item;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _showCustomOptions(String sectionKey) {
    final customList = _customOptions[sectionKey] ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Options - ${_sectionTitles[sectionKey]}'),
        content: customList.isEmpty
            ? const Text('No custom options')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: customList.map((option) => ListTile(
                  title: Text(option),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        customList.remove(option);
                      });
                      Navigator.pop(context);
                      _showCustomOptions(sectionKey);
                    },
                  ),
                )).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addCustomOption(String sectionKey, String customText) {
    if (customText.isNotEmpty) {
      setState(() {
        final customList = _customOptions[sectionKey] ?? [];
        if (!customList.contains(customText)) {
          customList.add(customText);
        }
        _addItem(customText);
      });
    }
  }

  void _clearCustomOptions(String sectionKey) {
    setState(() {
      final customList = _customOptions[sectionKey] ?? [];
      // Remove custom items from selected items
      _selectedItems.removeWhere((item) => customList.contains(item.name));
      customList.clear();
    });
  }

  void _save() {
    // Convert selected items to the format expected by onSave
    final List<Map<String, String>> historyItems = _selectedItems.map((item) {
      return {
        'name': item.name,
        'value': item.value,
        'note': item.note,
      };
    }).toList();
    
    widget.onSave(historyItems);
    Navigator.pop(context);
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontFamily: 'ProductSans',
        ),
      );
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final index = textLower.indexOf(queryLower);

    if (index == -1) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontFamily: 'ProductSans',
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontFamily: 'ProductSans',
        ),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFFE3001),
              backgroundColor: Color(0xFFFFE5E5),
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
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
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFE3001),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Done'),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs
            Container(
              color: const Color(0xFFFE3001),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'ProductSans',
                ),
                tabs: _tabs.map((tab) => Tab(text: tab['title'] as String)).toList(),
                onTap: (index) => setState(() {}),
              ),
            ),
            
            // Search Bar and Custom Input on same row
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Search field - half width
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Custom input field - half width
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _addCustomItem();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Type custom item...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addCustomItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE3001),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  // Search Bar and Custom Input
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Search field - half width
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Custom input field - half width
                        Expanded(
                          child: TextField(
                            controller: _customController,
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _addCustomItem();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Type custom item...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addCustomItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFE3001),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab View Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                        ),
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: _tabs.map((tab) {
                          return _buildTabContent(tab['sections'] as List<String>);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Selected Items Table (2 columns side by side)
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                child: _selectedItems.isNotEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Items',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column
                                Expanded(
                                  child: _buildTable(
                                    _selectedItems.take((_selectedItems.length / 2).ceil()).toList(),
                                    0,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Right Column
                                Expanded(
                                  child: _buildTable(
                                    _selectedItems.skip((_selectedItems.length / 2).ceil()).toList(),
                                    (_selectedItems.length / 2).ceil(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'No items selected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                              fontFamily: 'ProductSans',
                            ),
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


  Widget _buildTabContent(List<String> sectionKeys) {
    final filteredOptions = _getFilteredOptionsForTab();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final entries = filteredOptions.entries.toList();
          final leftColumnEntries = <MapEntry<String, List<String>>>[];
          final rightColumnEntries = <MapEntry<String, List<String>>>[];
          
          // Split entries into two columns
          for (int i = 0; i < entries.length; i++) {
            if (i % 2 == 0) {
              leftColumnEntries.add(entries[i]);
            } else {
              rightColumnEntries.add(entries[i]);
            }
          }
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  children: leftColumnEntries.map((entry) {
                    final sectionKey = entry.key;
                    final options = entry.value;
                    final title = _sectionTitles[sectionKey] ?? sectionKey;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: ValueKey('left_${sectionKey}_${_searchController.text}'),
                          initiallyExpanded: _searchController.text.isNotEmpty,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.map((option) {
                                final isSelected = _selectedItems.any((item) => item.name == option);
                                final searchQuery = _searchController.text.toLowerCase();
                                final isMatch = searchQuery.isNotEmpty && 
                                    option.toLowerCase().contains(searchQuery);
                                return InkWell(
                                  onTap: () => _addItem(option),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFFFFE5DD) 
                                          : (isMatch ? const Color(0xFFFFF4E6) : const Color(0xFFF1F5F9)),
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFFFE3001) 
                                            : (isMatch ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0)),
                                        width: isMatch ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Color(0xFFFE3001),
                                            ),
                                          ),
                                        _buildHighlightedText(option, _searchController.text),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              // Right Column
              Expanded(
                child: Column(
                  children: rightColumnEntries.map((entry) {
                    final sectionKey = entry.key;
                    final options = entry.value;
                    final title = _sectionTitles[sectionKey] ?? sectionKey;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: ValueKey('right_${sectionKey}_${_searchController.text}'),
                          initiallyExpanded: _searchController.text.isNotEmpty,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.map((option) {
                                final isSelected = _selectedItems.any((item) => item.name == option);
                                final searchQuery = _searchController.text.toLowerCase();
                                final isMatch = searchQuery.isNotEmpty && 
                                    option.toLowerCase().contains(searchQuery);
                                return InkWell(
                                  onTap: () => _addItem(option),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFFFFE5DD) 
                                          : (isMatch ? const Color(0xFFFFF4E6) : const Color(0xFFF1F5F9)),
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFFFE3001) 
                                            : (isMatch ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0)),
                                        width: isMatch ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Color(0xFFFE3001),
                                            ),
                                          ),
                                        _buildHighlightedText(option, _searchController.text),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTable(List<HistoryItem> items, int startIndex) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final localIndex = entry.key;
        final globalIndex = startIndex + localIndex;
        final item = entry.value;
        
        return _buildItemRow(globalIndex, item);
      }).toList(),
    );
  }

  Widget _buildItemRow(int index, HistoryItem item) {
    return Container(
      key: ValueKey('history_item_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _deleteItem(index),
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('value_$index'),
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  controller: TextEditingController(text: item.value)..selection = TextSelection.collapsed(offset: item.value.length),
                  onChanged: (value) {
                    _updateItem(index, item.copyWith(value: value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: ValueKey('for_$index'),
                  decoration: const InputDecoration(
                    labelText: 'For',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  controller: TextEditingController(text: item.forField)..selection = TextSelection.collapsed(offset: item.forField.length),
                  onChanged: (value) {
                    _updateItem(index, item.copyWith(forField: value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: item.duration,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  items: ['Day', 'Week', 'Month', 'Year'].map((duration) {
                    return DropdownMenuItem(value: duration, child: Text(duration));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _updateItem(index, item.copyWith(duration: value));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: ValueKey('note_$index'),
            decoration: const InputDecoration(
              labelText: 'Note',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            controller: TextEditingController(text: item.note)..selection = TextSelection.collapsed(offset: item.note.length),
            maxLines: 2,
            onChanged: (value) {
              _updateItem(index, item.copyWith(note: value));
            },
          ),
        ],
      ),
    );
  }
}

class HistoryItem {
  final String name;
  final String value;
  final String forField;
  final String duration;
  final String note;

  HistoryItem({
    required this.name,
    required this.value,
    required this.forField,
    required this.duration,
    required this.note,
  });

  HistoryItem copyWith({
    String? name,
    String? value,
    String? forField,
    String? duration,
    String? note,
  }) {
    return HistoryItem(
      name: name ?? this.name,
      value: value ?? this.value,
      forField: forField ?? this.forField,
      duration: duration ?? this.duration,
      note: note ?? this.note,
    );
  }
}
