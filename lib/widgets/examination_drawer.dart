import 'package:flutter/material.dart';

class ExaminationDrawer extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onClose;

  const ExaminationDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ExaminationDrawer> createState() => _ExaminationDrawerState();
}

class _ExaminationDrawerState extends State<ExaminationDrawer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // General Examination - General Survey
  String? _selectedConsciousness;
  List<String> _consciousnessTags = [];
  String? _selectedBodyHabitus;
  List<String> _bodyHabitusTags = [];
  String? _selectedPosture;
  List<String> _postureTags = [];
  String? _selectedDistress;
  List<String> _distressTags = [];
  String? _selectedHygiene;
  List<String> _hygieneTags = [];
  String? _selectedGrooming;
  List<String> _groomingTags = [];
  
  // Vital Signs
  final TextEditingController _temperatureController = TextEditingController();
  String _temperatureUnit = 'C';
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _respiratoryRateController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  String _bpPosition = 'Sitting';
  String _bpArm = 'Right';
  final TextEditingController _oxygenSaturationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _bmi = '';

  final List<String> _consciousnessOptions = [
    'Alert', 'Drowsy', 'Confused', 'Unresponsive', 'Oriented x3'
  ];
  
  final List<String> _bodyHabitusOptions = [
    'Normal', 'Obese', 'Thin', 'Muscular', 'Cachectic'
  ];
  
  final List<String> _postureOptions = [
    'Normal', 'Stooped', 'Antalgic', 'Ataxic', 'Steady'
  ];
  
  final List<String> _distressOptions = [
    'No distress', 'Mild distress', 'Moderate distress', 'Severe distress'
  ];
  
  final List<String> _hygieneOptions = [
    'Good', 'Fair', 'Poor', 'Well-groomed', 'Unkempt'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _respiratoryRateController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _oxygenSaturationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addCustomTag(List<String> tagList, String value) {
    if (value.isNotEmpty && !tagList.contains(value)) {
      setState(() {
        tagList.add(value);
      });
    }
  }

  void _removeTag(List<String> tagList, String value) {
    setState(() {
      tagList.remove(value);
    });
  }

  Widget _buildTagSelector({
    required String label,
    required List<String> options,
    required List<String> selectedTags,
    required Function(String) onAdd,
  }) {
    final TextEditingController customController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        // Predefined options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedTags.contains(option);
            return InkWell(
              onTap: () {
                if (isSelected) {
                  _removeTag(selectedTags, option);
                } else {
                  onAdd(option);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFE3001) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Custom input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: customController,
                decoration: InputDecoration(
                  hintText: 'Type custom item...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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
                style: const TextStyle(fontSize: 12),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    onAdd(value);
                    customController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (customController.text.isNotEmpty) {
                  onAdd(customController.text);
                  customController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE3001),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    
    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100;
      final bmiValue = weight / (heightInMeters * heightInMeters);
      setState(() {
        _bmi = bmiValue.toStringAsFixed(1);
      });
    } else {
      setState(() {
        _bmi = '';
      });
    }
  }

  Color _getBMIColor() {
    if (_bmi.isEmpty) return const Color(0xFF64748B);
    final bmiValue = double.tryParse(_bmi);
    if (bmiValue == null) return const Color(0xFF64748B);
    
    if (bmiValue < 18.5) {
      return const Color(0xFF3B82F6); // Blue - Underweight
    } else if (bmiValue < 25) {
      return const Color(0xFF10B981); // Green - Normal
    } else if (bmiValue < 30) {
      return const Color(0xFFF59E0B); // Orange - Overweight
    } else {
      return const Color(0xFFEF4444); // Red - Obese
    }
  }

  Widget _buildGeneralExaminationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. General Survey
          const Text(
            'A. General Survey',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTagSelector(
            label: 'Level of Consciousness/Sensorium',
            options: _consciousnessOptions,
            selectedTags: _consciousnessTags,
            onAdd: (value) => _addCustomTag(_consciousnessTags, value),
          ),
          const SizedBox(height: 16),
          
          _buildTagSelector(
            label: 'Body Habitus & Build',
            options: _bodyHabitusOptions,
            selectedTags: _bodyHabitusTags,
            onAdd: (value) => _addCustomTag(_bodyHabitusTags, value),
          ),
          const SizedBox(height: 16),
          
          _buildTagSelector(
            label: 'Posture & Gait',
            options: _postureOptions,
            selectedTags: _postureTags,
            onAdd: (value) => _addCustomTag(_postureTags, value),
          ),
          const SizedBox(height: 16),
          
          _buildTagSelector(
            label: 'Signs of Distress',
            options: _distressOptions,
            selectedTags: _distressTags,
            onAdd: (value) => _addCustomTag(_distressTags, value),
          ),
          const SizedBox(height: 16),
          
          _buildTagSelector(
            label: 'Hygiene, Grooming & Odors',
            options: _hygieneOptions,
            selectedTags: _hygieneTags,
            onAdd: (value) => _addCustomTag(_hygieneTags, value),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // B. Vital Signs
          const Text(
            'B. Vital Signs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          // Temperature, Pulse, Respiratory Rate
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temperature',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _temperatureController,
                            decoration: InputDecoration(
                              hintText: '98.6',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _temperatureUnit,
                          items: ['C', 'F'].map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text('°$unit'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _temperatureUnit = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pulse',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pulseController,
                      decoration: InputDecoration(
                        hintText: 'bpm',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Respiratory Rate',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _respiratoryRateController,
                      decoration: InputDecoration(
                        hintText: 'breaths/min',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Blood Pressure
          const Text(
            'Blood Pressure',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Systolic', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _bpSystolicController,
                      decoration: InputDecoration(
                        hintText: '120',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diastolic', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _bpDiastolicController,
                      decoration: InputDecoration(
                        hintText: '80',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Position', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _bpPosition,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      items: ['Sitting', 'Standing', 'Lying'].map((pos) {
                        return DropdownMenuItem(value: pos, child: Text(pos, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _bpPosition = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Arm', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _bpArm,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      items: ['Right', 'Left'].map((arm) {
                        return DropdownMenuItem(value: arm, child: Text(arm, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _bpArm = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Oxygen Saturation
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Oxygen Saturation (SpO₂)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _oxygenSaturationController,
                      decoration: InputDecoration(
                        hintText: '%',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Height, Weight, BMI
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height (cm)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        hintText: '170',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateBMI(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight (kg)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        hintText: '70',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateBMI(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _bmi.isEmpty ? '-' : _bmi,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getBMIColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab(String title) {
    return Center(
      child: Text(
        '$title - Coming Soon',
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  String _generatePreview() {
    List<String> preview = [];
    
    // General Survey
    if (_consciousnessTags.isNotEmpty) {
      preview.add('Consciousness: ${_consciousnessTags.join(", ")}');
    }
    if (_bodyHabitusTags.isNotEmpty) {
      preview.add('Body Habitus: ${_bodyHabitusTags.join(", ")}');
    }
    if (_postureTags.isNotEmpty) {
      preview.add('Posture & Gait: ${_postureTags.join(", ")}');
    }
    if (_distressTags.isNotEmpty) {
      preview.add('Distress: ${_distressTags.join(", ")}');
    }
    if (_hygieneTags.isNotEmpty) {
      preview.add('Hygiene: ${_hygieneTags.join(", ")}');
    }
    
    // Vital Signs
    if (_temperatureController.text.isNotEmpty) {
      preview.add('Temperature: ${_temperatureController.text}°$_temperatureUnit');
    }
    if (_pulseController.text.isNotEmpty) {
      preview.add('Pulse: ${_pulseController.text} bpm');
    }
    if (_respiratoryRateController.text.isNotEmpty) {
      preview.add('Respiratory Rate: ${_respiratoryRateController.text} breaths/min');
    }
    if (_bpSystolicController.text.isNotEmpty && _bpDiastolicController.text.isNotEmpty) {
      preview.add('BP: ${_bpSystolicController.text}/${_bpDiastolicController.text} mmHg ($_bpPosition, $_bpArm arm)');
    }
    if (_oxygenSaturationController.text.isNotEmpty) {
      preview.add('SpO₂: ${_oxygenSaturationController.text}%');
    }
    if (_heightController.text.isNotEmpty) {
      preview.add('Height: ${_heightController.text} cm');
    }
    if (_weightController.text.isNotEmpty) {
      preview.add('Weight: ${_weightController.text} kg');
    }
    if (_bmi.isNotEmpty) {
      preview.add('BMI: $_bmi');
    }
    
    return preview.join('\n• ');
  }

  @override
  Widget build(BuildContext context) {
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
                    'Examination',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave({
                        'preview': _generatePreview(),
                        'data': {
                          'consciousness': _consciousnessTags,
                          'bodyHabitus': _bodyHabitusTags,
                          'posture': _postureTags,
                          'distress': _distressTags,
                          'hygiene': _hygieneTags,
                          'temperature': _temperatureController.text,
                          'temperatureUnit': _temperatureUnit,
                          'pulse': _pulseController.text,
                          'respiratoryRate': _respiratoryRateController.text,
                          'bpSystolic': _bpSystolicController.text,
                          'bpDiastolic': _bpDiastolicController.text,
                          'bpPosition': _bpPosition,
                          'bpArm': _bpArm,
                          'oxygenSaturation': _oxygenSaturationController.text,
                          'height': _heightController.text,
                          'weight': _weightController.text,
                          'bmi': _bmi,
                        },
                      });
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
                    child: const Text('Done'),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Tabs
            Container(
              color: const Color(0xFFF8F9FA),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: const Color(0xFFFE3001),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFFFE3001),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ProductSans',
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'General Examination'),
                  Tab(text: 'Integumentary'),
                  Tab(text: 'Cardiovascular'),
                  Tab(text: 'Respiratory'),
                  Tab(text: 'Gastrointestinal'),
                  Tab(text: 'Neurological'),
                  Tab(text: 'Musculoskeletal'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralExaminationTab(),
                  _buildComingSoonTab('Integumentary'),
                  _buildComingSoonTab('Cardiovascular'),
                  _buildComingSoonTab('Respiratory'),
                  _buildComingSoonTab('Gastrointestinal'),
                  _buildComingSoonTab('Neurological'),
                  _buildComingSoonTab('Musculoskeletal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
