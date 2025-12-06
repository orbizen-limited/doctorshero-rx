import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryDrawer extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSave;
  final VoidCallback onClose;
  final List<Map<String, dynamic>>? initialData;

  const HistoryDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
    this.initialData,
  }) : super(key: key);

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  // Selected items - using HistoryItem class for Value, For, Duration, Note
  List<HistoryItem> _selectedItems = [];
  
  // Track expanded sections for each item (itemIndex -> sectionKey -> isExpanded)
  final Map<int, Map<String, bool>> _expandedSections = {};
  
  // Track visibility of "Add new description" field for each item (itemIndex -> isVisible)
  final Map<int, bool> _addDescriptionVisible = {};
  
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
  
  // Custom options for each section - loaded from SharedPreferences
  Map<String, List<String>> _customOptions = {
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
    // Custom options for symptom detail sections
    'verbatimTags': [],
    'onsetTags': [],
    'durationTags': [],
    'frequencyTags': [],
  };
  
  // Grouped options for presenting complaint
  final Map<String, Map<String, List<String>>> _groupedPresentingComplaint = {
    'presentingComplaint': {
      'General Symptoms': [
        'Weight loss',
        'Day sweats',
        'Fatigue',
        'Malaise',
        'Lethargy',
        'Sleeping pattern change',
        'Appetite change',
        'Fever',
        'Itch',
        'Rash',
        'Recent trauma',
        'Lumps/Bumps/Masses',
      ],
      'Eye Symptoms': [
        'Visual changes',
        'Eye pain',
        'Double vision',
        'Scotomas (blind spots)',
        'Floaters',
      ],
      'ENT Symptoms': [
        'Runny nose',
        'Epistaxis (nose bleeds)',
        'Sinus pain',
        'Stuffy ears',
        'Ear pain',
        'Tinnitus',
        'Gingival bleeding',
        'Toothache',
        'Sore throat',
        'Odynophagia (pain with swallowing)',
      ],
      'Cardiovascular Symptoms': [
        'Chest Pain',
        'Shortness of Breath on exertion',
        'Paroxysmal Nocturnal Dyspnea (PND)',
        'Orthopnea',
        'Edema',
        'Palpitations',
        'Faintness',
        'Loss of consciousness',
        'Claudication',
      ],
      'Respiratory Symptoms': [
        'Cough',
        'Sputum',
        'Wheeze',
        'Hemoptysis',
        'Shortness of Breath at rest',
      ],
      'Gastrointestinal Symptoms': [
        'Abdominal Pain',
        'Difficulty swallowing',
        'Indigestion',
        'Bloating',
        'Cramping',
        'Loss of appetite',
        'Nausea/Vomiting',
        'Diarrhea',
        'Constipation',
        'Obstipation',
        'Hematemesis',
        'Hematochezia (BRBPR)',
        'Melena',
        'Tenesmus',
        'Incontinence',
      ],
      'Urological Symptoms': [
        'Dysuria',
        'Hematuria',
        'Nocturia',
        'Polyuria',
        'Hesitancy',
        'Terminal dribbling',
        'Decreased force of stream',
      ],
      'Gynecological Symptoms': [
        'Vaginal discharge',
        'Vaginal pain',
        'Menstrual changes',
        'Contraception concern',
        'Libido changes',
        'Erectile dysfunction',
      ],
      'Musculoskeletal Symptoms': [
        'Joint Pain',
        'Back Pain',
        'Stiffness',
        'Joint swelling',
        'Decreased range of motion',
        'Crepitus',
        'Functional deficit',
      ],
      'Dermatological Symptoms': [
        'Pruritus',
        'Rashes',
        'Lesions',
        'Wounds',
        'Acanthosis nigricans',
        'Nodules',
        'Excessive dryness',
        'Discoloration',
      ],
      'Breast Symptoms': [
        'Breast pain',
        'Breast lumps',
        'Breast discharge',
      ],
      'Neurological Symptoms': [
        'Headache',
        'Dizziness',
        'Seizures',
        'Faints',
        'Paraesthesiae (pins and needles)',
        'Numbness',
        'Limb weakness',
        'Poor balance',
        'Speech problems',
        'Sphincter disturbance',
        'Cognitive changes',
      ],
      'Psychiatric Symptoms': [
        'Depression',
        'Anxiety',
        'Difficulty concentrating',
        'Body image concerns',
        'Paranoia',
        'Anhedonia',
        'Lack of energy',
        'Mania episodes',
        'Personality change',
      ],
      'Endocrine Symptoms': [
        'Heat/Cold intolerance',
        'Sweating changes',
        'Mood swings',
        'Tremor',
        'Polydipsia',
        'Polyphagia',
        'Hypoglycemia symptoms',
      ],
      'Hematological Symptoms': [
        'Easy bruising (purpura/petechia)',
        'Prolonged bleeding',
        'History of anemia',
        'Swollen lymph nodes',
      ],
      'Allergic Symptoms': [
        'Anaphylaxis history',
        'Allergic rhinitis symptoms',
        'Known food/drug/environmental allergies',
      ],
    },
  };

  // Predefined options for each history category
  final Map<String, List<String>> _predefinedOptions = {
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
    _loadCustomOptions();
    
    // Load initial data if provided
    if (widget.initialData != null) {
      _selectedItems = widget.initialData!.map((item) {
        return HistoryItem(
          name: item['name']?.toString() ?? '',
          value: item['value']?.toString() ?? '',
          forField: item['forField']?.toString() ?? '',
          duration: item['duration']?.toString() ?? '',
          note: item['note']?.toString() ?? '',
          symptomDetail: null, // TODO: Implement SymptomDetailData.fromJson if needed
        );
      }).toList();
    }
  }
  
  // Load custom options from SharedPreferences
  Future<void> _loadCustomOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var key in _customOptions.keys) {
        final jsonString = prefs.getString('history_custom_$key');
        if (jsonString != null) {
          final List<dynamic> decoded = jsonDecode(jsonString);
          _customOptions[key] = decoded.cast<String>();
        }
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle error silently
      print('Error loading custom options: $e');
    }
  }
  
  // Save custom options to SharedPreferences
  Future<void> _saveCustomOptions(String key, List<String> options) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customOptions[key] = options;
      await prefs.setString('history_custom_$key', jsonEncode(options));
    } catch (e) {
      // Handle error silently
      print('Error saving custom options: $e');
    }
  }
  
  // Add a custom option to a specific key
  Future<void> _addCustomOption(String key, String option) async {
    if (option.trim().isEmpty) return;
    
    final currentOptions = _customOptions[key] ?? [];
    if (!currentOptions.contains(option.trim())) {
      final updatedOptions = [...currentOptions, option.trim()];
      await _saveCustomOptions(key, updatedOptions);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
    
    // Special handling for presenting complaint (grouped)
    if (currentSections.contains('presentingComplaint')) {
      final groupedOptions = _groupedPresentingComplaint['presentingComplaint'] ?? {};
      final customList = _customOptions['presentingComplaint'] ?? [];
      
      for (var groupName in groupedOptions.keys) {
        final groupOptions = groupedOptions[groupName] ?? [];
        
        if (searchQuery.isEmpty) {
          // If no search, show all options in group
          filteredGroups[groupName] = groupOptions;
        } else {
          // Filter by search query
          final filtered = groupOptions
              .where((option) => option.toLowerCase().contains(searchQuery))
              .toList();
          if (filtered.isNotEmpty) {
            filteredGroups[groupName] = filtered;
          }
        }
      }
      
      // Add custom options as a separate group if they exist
      if (customList.isNotEmpty) {
        if (searchQuery.isEmpty) {
          filteredGroups['Custom'] = customList;
        } else {
          final filtered = customList
              .where((option) => option.toLowerCase().contains(searchQuery))
              .toList();
          if (filtered.isNotEmpty) {
            filteredGroups['Custom'] = filtered;
          }
        }
      }
    }
    
    // Handle other sections normally
    for (var sectionKey in currentSections) {
      if (sectionKey == 'presentingComplaint') continue; // Already handled above
      
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
      // Check if this is a presenting complaint item (from grouped structure)
      bool isPresentingComplaint = false;
      final groupedOptions = _groupedPresentingComplaint['presentingComplaint'] ?? {};
      for (var groupOptions in groupedOptions.values) {
        if (groupOptions.contains(name)) {
          isPresentingComplaint = true;
          break;
        }
      }
      // Also check custom options
      if (!isPresentingComplaint) {
        isPresentingComplaint = _customOptions['presentingComplaint']?.contains(name) ?? false;
      }
      
      setState(() {
        _selectedItems.add(HistoryItem(
          name: name,
          value: '',
          forField: '',
          duration: 'Day',
          note: '',
          symptomDetail: isPresentingComplaint ? SymptomDetailData() : null,
        ));
      });
      // Update in real-time
      _updateHistoryInRealTime();
    }
  }

  
  void _showAddCustomItemDialog() {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Item'),
        content: TextField(
          controller: customController,
          decoration: const InputDecoration(
            hintText: 'Type custom item...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addItem(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customController.text.trim().isNotEmpty) {
                _addItem(customController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE3001),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  // Update history in real-time
  void _updateHistoryInRealTime() {
    // Convert selected items to the format expected by onSave
    final List<Map<String, dynamic>> historyItems = _selectedItems.map((item) {
      final Map<String, dynamic> itemMap = {
        'name': item.name,
        'value': item.value,
        'note': item.note,
      };
      
      // Include symptom detail data if present
      if (item.symptomDetail != null) {
        final detail = item.symptomDetail!;
        itemMap['symptomDetail'] = {
          'patientVerbatim': detail.patientVerbatim,
          'verbatimTags': detail.verbatimTags,
          'onset': detail.onset,
          'onsetTags': detail.onsetTags,
          'duration': detail.duration,
          'durationTags': detail.durationTags,
          'severity': detail.severity,
          'frequency': detail.frequency,
          'frequencyTags': detail.frequencyTags,
          'associated': detail.associated,
          'culturalContext': detail.culturalContext,
        };
      }
      
      return itemMap;
    }).toList();
    
    // Call onSave callback in real-time
    widget.onSave(historyItems);
  }


  void _updateItem(int index, HistoryItem item) {
    setState(() {
      _selectedItems[index] = item;
    });
    // Update in real-time
    _updateHistoryInRealTime();
  }

  void _deleteItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
      // Clean up expansion state for removed item
      _expandedSections.remove(index);
      _addDescriptionVisible.remove(index);
      // Shift indices for items after the deleted one
      final keysToUpdate = _expandedSections.keys.where((k) => k > index).toList()..sort();
      for (var key in keysToUpdate.reversed) {
        _expandedSections[key - 1] = _expandedSections.remove(key)!;
      }
      final visibleKeysToUpdate = _addDescriptionVisible.keys.where((k) => k > index).toList()..sort();
      for (var key in visibleKeysToUpdate.reversed) {
        _addDescriptionVisible[key - 1] = _addDescriptionVisible.remove(key)!;
      }
    });
    // Update in real-time
    _updateHistoryInRealTime();
  }
  
  bool _isSectionExpanded(int itemIndex, String sectionKey) {
    return _expandedSections[itemIndex]?[sectionKey] ?? false;
  }
  
  void _toggleSection(int itemIndex, String sectionKey) {
    setState(() {
      _expandedSections.putIfAbsent(itemIndex, () => {});
      _expandedSections[itemIndex]![sectionKey] = !_isSectionExpanded(itemIndex, sectionKey);
    });
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
                children: [
                  // Search Field - Expanded
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'ProductSans',
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'ProductSans',
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button - Red with white text
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddCustomItemDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE3001),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
            
            
            // Tab Content
            Expanded(
              flex: 5,
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
            
            // Selected Items with Table
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: _selectedItems.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                              ),
                            ),
                            child: const Text(
                              'Selected Items',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _selectedItems.length,
                              itemBuilder: (context, index) {
                                final item = _selectedItems[index];
                                return _buildSelectedItemRow(index, item);
                              },
                            ),
                          ),
                        ],
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
                    // For presenting complaint, use group name directly; for others use section title
                    final title = _getCurrentTabSections().contains('presentingComplaint') 
                        ? sectionKey 
                        : (_sectionTitles[sectionKey] ?? sectionKey);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: ValueKey('left_${sectionKey}_${_searchController.text}'),
                          initiallyExpanded: _searchController.text.isNotEmpty || !_getCurrentTabSections().contains('presentingComplaint'),
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
                    // For presenting complaint, use group name directly; for others use section title
                    final title = _getCurrentTabSections().contains('presentingComplaint') 
                        ? sectionKey 
                        : (_sectionTitles[sectionKey] ?? sectionKey);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: ValueKey('right_${sectionKey}_${_searchController.text}'),
                          initiallyExpanded: _searchController.text.isNotEmpty || !_getCurrentTabSections().contains('presentingComplaint'),
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

  Widget _buildSelectedItemRow(int index, HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header with name and delete button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
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
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Content area
          if (item.symptomDetail != null)
            _buildSymptomDetailTable(index, item)
          else
            _buildSimpleItemView(index, item),
        ],
      ),
    );
  }
  
  Widget _buildSymptomDetailTable(int index, HistoryItem item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Row 1: Patient's Verbatim | Core Inquiry
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildExpandableSection(
                    index,
                    item,
                    "Patient's Verbatim",
                    'patientVerbatim',
                    () => _buildPatientVerbatimContent(index, item),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildExpandableSection(
                    index,
                    item,
                    'Core Inquiry',
                    'coreInquiry',
                    () => _buildCoreInquiryContent(index, item),
                  ),
                ),
              ),
            ],
          ),
          // Row 2: Associated | Cultural Context
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildExpandableSection(
                    index,
                    item,
                    'Associated',
                    'associated',
                    () => _buildAssociatedContent(index, item),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildExpandableSection(
                    index,
                    item,
                    'Cultural Context',
                    'culturalContext',
                    () => _buildCulturalContextContent(index, item),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandableSection(
    int index,
    HistoryItem item,
    String title,
    String sectionKey,
    Widget Function() buildContent,
  ) {
    final isExpanded = _isSectionExpanded(index, sectionKey);
    
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isExpanded ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _toggleSection(index, sectionKey),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isExpanded ? const Color(0xFFFE3001) : const Color(0xFF1E293B),
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: isExpanded ? const Color(0xFFFE3001) : const Color(0xFF94A3B8),
                    ),
              ],
            ),
              ),
            ),
            if (isExpanded)
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: buildContent(),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildPatientVerbatimContent(int index, HistoryItem item) {
    final detail = item.symptomDetail ?? SymptomDetailData();
    final verbatimController = TextEditingController(text: detail.patientVerbatim);
    final addDescriptionController = TextEditingController();
    
    // Get predefined tags
    final basePredefinedTags = [
      "'it just started'",
      "'it's been bothering me for a while'",
      "'it comes and goes'",
      "'it's getting worse'",
      "'it's affecting my daily life'",
    ];
    
    // Get custom tags from storage
    final customVerbatimTags = _customOptions['verbatimTags'] ?? [];
    
    // Combine base tags with custom tags from storage, avoiding duplicates
    final allTags = <String>[];
    for (var tag in basePredefinedTags) {
      if (!allTags.contains(tag)) {
        allTags.add(tag);
      }
    }
    for (var tag in customVerbatimTags) {
      if (!allTags.contains(tag)) {
        allTags.add(tag);
      }
    }
    
    final isAddDescriptionVisible = _addDescriptionVisible[index] ?? false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: verbatimController,
            decoration: InputDecoration(
              hintText: "Enter patient's verbatim...",
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
            maxLines: 3,
            onChanged: (value) {
              _updateItem(index, item.copyWith(
                symptomDetail: detail.copyWith(patientVerbatim: value),
              ));
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...allTags.map((tag) {
                final isSelected = detail.verbatimTags.contains(tag);
                return InkWell(
                  onTap: () {
                    final newTags = isSelected
                        ? detail.verbatimTags.where((t) => t != tag).toList()
                        : [...detail.verbatimTags, tag];
                    _updateItem(index, item.copyWith(
                      symptomDetail: detail.copyWith(verbatimTags: newTags),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFE5DD) : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? const Color(0xFFFE3001) : const Color(0xFF64748B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          if (isAddDescriptionVisible)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: addDescriptionController,
                  decoration: InputDecoration(
                    hintText: 'Add new description...',
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
                    autofocus: true,
                    onSubmitted: (value) async {
                      if (value.trim().isNotEmpty) {
                        final trimmedValue = value.trim();
                        // Save to SharedPreferences
                        await _addCustomOption('verbatimTags', trimmedValue);
                        // Add to current item's tags
                        final newTags = [...detail.verbatimTags, trimmedValue];
                        _updateItem(index, item.copyWith(
                          symptomDetail: detail.copyWith(verbatimTags: newTags),
                        ));
                        addDescriptionController.clear();
                        setState(() {
                          _addDescriptionVisible[index] = false;
                        });
                      }
                    },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (addDescriptionController.text.trim().isNotEmpty) {
                    final trimmedValue = addDescriptionController.text.trim();
                    // Save to SharedPreferences
                    await _addCustomOption('verbatimTags', trimmedValue);
                    // Add to current item's tags
                    final newTags = [...detail.verbatimTags, trimmedValue];
                    _updateItem(index, item.copyWith(
                      symptomDetail: detail.copyWith(verbatimTags: newTags),
                    ));
                    addDescriptionController.clear();
                    setState(() {
                      _addDescriptionVisible[index] = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE3001),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _addDescriptionVisible[index] = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE3001),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreInquiryContent(int index, HistoryItem item) {
    final detail = item.symptomDetail ?? SymptomDetailData();
    final onsetController = TextEditingController(text: detail.onset);
    final durationController = TextEditingController(text: detail.duration);
    final severityController = TextEditingController(text: detail.severity);
    final frequencyController = TextEditingController(text: detail.frequency);
    
    // Base predefined tags
    final baseOnsetTags = ['Today', 'Yesterday', 'A few days ago', 'Last week', 'Gradual', 'Sudden'];
    final baseDurationTags = ['Seconds', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Constant'];
    final baseFrequencyTags = ['Constant', 'Intermittent', 'Occasional', 'Daily', 'Weekly', 'Monthly'];
    
    // Merge with custom tags from storage
    final customOnsetTags = _customOptions['onsetTags'] ?? [];
    final customDurationTags = _customOptions['durationTags'] ?? [];
    final customFrequencyTags = _customOptions['frequencyTags'] ?? [];
    
    final onsetTags = <String>[...baseOnsetTags];
    for (var tag in customOnsetTags) {
      if (!onsetTags.contains(tag)) {
        onsetTags.add(tag);
      }
    }
    
    final durationTags = <String>[...baseDurationTags];
    for (var tag in customDurationTags) {
      if (!durationTags.contains(tag)) {
        durationTags.add(tag);
      }
    }
    
    final frequencyTags = <String>[...baseFrequencyTags];
    for (var tag in customFrequencyTags) {
      if (!frequencyTags.contains(tag)) {
        frequencyTags.add(tag);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Onset Section
          _buildTaggedInputSection(
            'Onset',
            onsetController,
            onsetTags,
            detail.onsetTags,
            'onsetTags',
            (value) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(onset: value),
            )),
            (tags) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(onsetTags: tags),
            )),
            (newTag) async {
              // Save to SharedPreferences
              await _addCustomOption('onsetTags', newTag);
              // Add to current item's tags
              final newTags = [...detail.onsetTags, newTag];
              _updateItem(index, item.copyWith(
                symptomDetail: detail.copyWith(onsetTags: newTags),
              ));
            },
          ),
          const SizedBox(height: 24),
          
          // Duration Section
          _buildTaggedInputSection(
            'Duration',
            durationController,
            durationTags,
            detail.durationTags,
            'durationTags',
            (value) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(duration: value),
            )),
            (tags) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(durationTags: tags),
            )),
            (newTag) async {
              // Save to SharedPreferences
              await _addCustomOption('durationTags', newTag);
              // Add to current item's tags
              final newTags = [...detail.durationTags, newTag];
              _updateItem(index, item.copyWith(
                symptomDetail: detail.copyWith(durationTags: newTags),
              ));
            },
          ),
          const SizedBox(height: 24),
          
          // Severity Section
          const Text(
            'Severity (0-10)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: severityController,
            decoration: InputDecoration(
              hintText: 'Enter severity (0-10)',
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
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(severity: value),
            )),
          ),
          const SizedBox(height: 24),
          
          // Frequency Section
          _buildTaggedInputSection(
            'Frequency',
            frequencyController,
            frequencyTags,
            detail.frequencyTags,
            'frequencyTags',
            (value) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(frequency: value),
            )),
            (tags) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(frequencyTags: tags),
            )),
            (newTag) async {
              // Save to SharedPreferences
              await _addCustomOption('frequencyTags', newTag);
              // Add to current item's tags
              final newTags = [...detail.frequencyTags, newTag];
              _updateItem(index, item.copyWith(
                symptomDetail: detail.copyWith(frequencyTags: newTags),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaggedInputSection(
    String label,
    TextEditingController controller,
    List<String> predefinedTags,
    List<String> selectedTags,
    String storageKey,
    Function(String) onTextChanged,
    Function(List<String>) onTagsChanged,
    Function(String) onAddNewTag,
  ) {
    final addOptionController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
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
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...predefinedTags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return InkWell(
                onTap: () {
                  final newTags = isSelected
                      ? selectedTags.where((t) => t != tag).toList()
                      : [...selectedTags, tag];
                  onTagsChanged(newTags);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFE5DD) : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? const Color(0xFFFE3001) : const Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: addOptionController,
                decoration: InputDecoration(
                  hintText: 'Add new option...',
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
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (addOptionController.text.isNotEmpty) {
                  onAddNewTag(addOptionController.text);
                  addOptionController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE3001),
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssociatedContent(int index, HistoryItem item) {
    final detail = item.symptomDetail ?? SymptomDetailData();
    final associatedController = TextEditingController(text: detail.associated);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: associatedController,
            decoration: InputDecoration(
              hintText: 'Enter associated symptoms or conditions...',
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
            maxLines: 5,
            onChanged: (value) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(associated: value),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildCulturalContextContent(int index, HistoryItem item) {
    final detail = item.symptomDetail ?? SymptomDetailData();
    final culturalController = TextEditingController(text: detail.culturalContext);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: culturalController,
            decoration: InputDecoration(
              hintText: 'Enter cultural context or relevant information...',
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
            maxLines: 5,
            onChanged: (value) => _updateItem(index, item.copyWith(
              symptomDetail: detail.copyWith(culturalContext: value),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleItemView(int index, HistoryItem item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _buildItemRow(index, item),
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
                  key: ValueKey('duration_${index}_${item.duration}'),
                  value: ['Day', 'Week', 'Month', 'Year'].contains(item.duration) ? item.duration : null,
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
  
  // Detailed symptom data
  final SymptomDetailData? symptomDetail;

  HistoryItem({
    required this.name,
    required this.value,
    required this.forField,
    required this.duration,
    required this.note,
    this.symptomDetail,
  });

  HistoryItem copyWith({
    String? name,
    String? value,
    String? forField,
    String? duration,
    String? note,
    SymptomDetailData? symptomDetail,
  }) {
    return HistoryItem(
      name: name ?? this.name,
      value: value ?? this.value,
      forField: forField ?? this.forField,
      duration: duration ?? this.duration,
      note: note ?? this.note,
      symptomDetail: symptomDetail ?? this.symptomDetail,
    );
  }
}

class SymptomDetailData {
  // Patient's Verbatim
  final String patientVerbatim;
  final List<String> verbatimTags;
  
  // Core Inquiry
  final String onset;
  final List<String> onsetTags;
  final String duration;
  final List<String> durationTags;
  final String severity; // 0-10
  final String frequency;
  final List<String> frequencyTags;
  
  // Associated
  final String associated;
  
  // Cultural Context
  final String culturalContext;

  SymptomDetailData({
    this.patientVerbatim = '',
    this.verbatimTags = const [],
    this.onset = '',
    this.onsetTags = const [],
    this.duration = '',
    this.durationTags = const [],
    this.severity = '',
    this.frequency = '',
    this.frequencyTags = const [],
    this.associated = '',
    this.culturalContext = '',
  });

  SymptomDetailData copyWith({
    String? patientVerbatim,
    List<String>? verbatimTags,
    String? onset,
    List<String>? onsetTags,
    String? duration,
    List<String>? durationTags,
    String? severity,
    String? frequency,
    List<String>? frequencyTags,
    String? associated,
    String? culturalContext,
  }) {
    return SymptomDetailData(
      patientVerbatim: patientVerbatim ?? this.patientVerbatim,
      verbatimTags: verbatimTags ?? this.verbatimTags,
      onset: onset ?? this.onset,
      onsetTags: onsetTags ?? this.onsetTags,
      duration: duration ?? this.duration,
      durationTags: durationTags ?? this.durationTags,
      severity: severity ?? this.severity,
      frequency: frequency ?? this.frequency,
      frequencyTags: frequencyTags ?? this.frequencyTags,
      associated: associated ?? this.associated,
      culturalContext: culturalContext ?? this.culturalContext,
    );
  }
}
