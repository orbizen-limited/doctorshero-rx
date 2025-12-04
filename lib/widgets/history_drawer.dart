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

class _HistoryDrawerState extends State<HistoryDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  
  // Predefined option controllers for each section
  final Map<String, TextEditingController> _predefinedControllers = {};
  
  // Custom option controllers for each section
  final Map<String, TextEditingController> _sectionCustomControllers = {};
  
  // Selected items - using HistoryItem class for Value, For, Duration, Note
  List<HistoryItem> _selectedItems = [];
  
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
    // Initialize controllers for all sections
    for (var sectionKey in _predefinedOptions.keys) {
      _predefinedControllers[sectionKey] = TextEditingController();
      _sectionCustomControllers[sectionKey] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    for (var controller in _predefinedControllers.values) {
      controller.dispose();
    }
    for (var controller in _sectionCustomControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _getAllOptions() {
    final allOptions = <String>[];
    for (var options in _predefinedOptions.values) {
      allOptions.addAll(options);
    }
    for (var customOptions in _customOptions.values) {
      allOptions.addAll(customOptions);
    }
    return allOptions.toSet().toList(); // Remove duplicates
  }

  List<String> _getFilteredOptions() {
    final allOptions = _getAllOptions();
    
    if (_searchController.text.isEmpty) {
      return allOptions;
    }
    
    final query = _searchController.text.toLowerCase();
    return allOptions.where((option) => option.toLowerCase().contains(query)).toList();
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

  void _addCustomOption(String sectionKey) {
    final controller = _sectionCustomControllers[sectionKey];
    if (controller != null && controller.text.isNotEmpty) {
      setState(() {
        final customList = _customOptions[sectionKey] ?? [];
        if (!customList.contains(controller.text)) {
          customList.add(controller.text);
        }
        _addItem(controller.text);
        controller.clear();
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

  @override
  Widget build(BuildContext context) {
    final filteredOptions = _getFilteredOptions();
    
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
            
            // Predefined Items (Tags)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredOptions.map((item) {
                  final isSelected = _selectedItems.any((selected) => selected.name == item);
                  return InkWell(
                    onTap: () => _addItem(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFE5DD) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0),
                        ),
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
                          Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? const Color(0xFFFE3001) : const Color(0xFF475569),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            
            // History Sections with Custom Options
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: _predefinedOptions.keys.map((sectionKey) {
                    return _buildHistorySection(sectionKey);
                  }).toList(),
                ),
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

  Widget _buildHistorySection(String sectionKey) {
    final title = _sectionTitles[sectionKey] ?? sectionKey;
    final customList = _customOptions[sectionKey] ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    final options = _predefinedOptions[sectionKey] ?? [];
                    if (textEditingValue.text.isEmpty) {
                      return options;
                    }
                    return options.where((option) =>
                      option.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    ).toList();
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    _predefinedControllers[sectionKey] = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _addItem(value);
                          controller.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Type or select from predefined options...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                    );
                  },
                  onSelected: (String option) {
                    _addItem(option);
                    _predefinedControllers[sectionKey]?.clear();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final controller = _predefinedControllers[sectionKey];
                  if (controller != null && controller.text.isNotEmpty) {
                    _addItem(controller.text);
                    controller.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sectionCustomControllers[sectionKey],
                  decoration: InputDecoration(
                    hintText: 'Add new custom option...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _addCustomOption(sectionKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Add New', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showCustomOptions(sectionKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBBF24),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Show Custom', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _clearCustomOptions(sectionKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Clear Custom', style: TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              if (customList.isNotEmpty)
                Text(
                  'Custom options: ${customList.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                ),
            ],
          ),
        ],
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
