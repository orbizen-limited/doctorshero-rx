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

class _ExaminationDrawerState extends State<ExaminationDrawer> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _generalExamSubTabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
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

  // Cardiovascular Examination
  String _cvInspection = '';
  final TextEditingController _cvInspectionNotesController = TextEditingController();
  final Map<String, String> _peripheralPulses = {
    'carotid_right': '', 'carotid_left': '',
    'radial_right': '', 'radial_left': '',
    'brachial_right': '', 'brachial_left': '',
    'femoral_right': '', 'femoral_left': '',
    'popliteal_right': '', 'popliteal_left': '',
    'posterior_tibial_right': '', 'posterior_tibial_left': '',
    'dorsalis_pedis_right': '', 'dorsalis_pedis_left': '',
  };
  String _jvp = '';
  final TextEditingController _jvpHeightController = TextEditingController();
  String _precordialPalpation = '';
  List<String> _thrills = [];
  String _heartSounds = '';
  final TextEditingController _heartSoundsNotesController = TextEditingController();
  String _murmurTiming = '';
  String _murmurGrade = '';
  String _murmurLocation = '';
  String _murmurRadiation = '';
  String _murmurQuality = '';

  // Integumentary System
  String _skinColorLesions = '';
  final TextEditingController _skinColorLesionsNotesController = TextEditingController();
  String _skinPalpation = '';
  final TextEditingController _skinPalpationNotesController = TextEditingController();
  String _pressureAreasEdema = '';
  final TextEditingController _pressureAreasEdemaNotesController = TextEditingController();
  String _hair = '';
  final TextEditingController _hairNotesController = TextEditingController();
  String _nails = '';
  final TextEditingController _nailsNotesController = TextEditingController();

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
    _generalExamSubTabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _generalExamSubTabController.dispose();
    _searchController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _respiratoryRateController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _oxygenSaturationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _cvInspectionNotesController.dispose();
    _jvpHeightController.dispose();
    _heartSoundsNotesController.dispose();
    _skinColorLesionsNotesController.dispose();
    _skinPalpationNotesController.dispose();
    _pressureAreasEdemaNotesController.dispose();
    _hairNotesController.dispose();
    _nailsNotesController.dispose();
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
    
    // Filter based on search query
    if (_searchQuery.isNotEmpty && !label.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }
    
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
    return Column(
      children: [
        // Sub-tabs for General Survey and Vital Signs
        Container(
          color: const Color(0xFFF8F9FA),
          child: TabBar(
            controller: _generalExamSubTabController,
            labelColor: const Color(0xFFFE3001),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFFFE3001),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
            tabs: const [
              Tab(text: 'General Survey'),
              Tab(text: 'Vital Signs'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _generalExamSubTabController,
            children: [
              _buildGeneralSurveyContent(),
              _buildVitalSignsContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSurveyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

  Widget _buildVitalSignsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temperature and Pulse (Row 1)
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
                            onChanged: (value) => _saveExaminationData(),
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
                            _saveExaminationData();
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
                      onChanged: (value) => _saveExaminationData(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Respiratory Rate (Row 2)
          Row(
            children: [
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
                      onChanged: (value) => _saveExaminationData(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()), // Empty space for 2-column layout
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

  Widget _buildIntegumentaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Clinical Examination Procedures
          const Text(
            'A. Clinical Examination Procedures',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          
          // Skin - Color & Lesions
          const Text(
            'Skin - Color & Lesions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _skinColorLesions.isEmpty ? null : _skinColorLesions,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'Normal color',
              'Pallor',
              'Cyanosis',
              'Jaundice',
              'Erythema',
              'Hyperpigmentation',
              'Hypopigmentation',
              'No lesions',
              'Macule/Patch',
              'Papule/Plaque',
              'Nodule/Tumor',
              'Vesicle/Bulla',
              'Pustule',
              'Wheal',
              'Cyst',
              'Crust',
              'Scale',
              'Excoriation',
              'Fissure',
              'Ulcer',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _skinColorLesions = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skinColorLesionsNotesController,
            decoration: InputDecoration(
              hintText: 'Describe lesion shape, size, distribution (ABCDE)...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          // Skin - Palpation
          const Text(
            'Skin - Palpation',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _skinPalpation.isEmpty ? null : _skinPalpation,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'Normal temperature',
              'Warm',
              'Cool',
              'Normal moisture',
              'Diaphoretic',
              'Dry (xerosis)',
              'Normal texture',
              'Rough/scaly',
              'Normal turgor',
              'Tenting (dehydration)',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _skinPalpation = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skinPalpationNotesController,
            decoration: InputDecoration(
              hintText: 'Describe localized temp changes, etc.',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          // Pressure Areas & Edema
          const Text(
            'Pressure Areas & Edema',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _pressureAreasEdema.isEmpty ? null : _pressureAreasEdema,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'No pressure area erythema',
              'Blanchable erythema',
              'Non-blanchable erythema (Stage 1)',
              'No edema',
              'Pitting edema',
              'Non-pitting edema',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _pressureAreasEdema = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pressureAreasEdemaNotesController,
            decoration: InputDecoration(
              hintText: 'Grade pitting edema (1-4+), note location...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          // Hair
          const Text(
            'Hair',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _hair.isEmpty ? null : _hair,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'Normal distribution & texture',
              'Alopecia (diffuse/patchy)',
              'Hirsutism',
              'Brittle/coarse hair',
              'Scalp scaling/lesions',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _hair = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _hairNotesController,
            decoration: InputDecoration(
              hintText: 'Describe findings...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          // Nails
          const Text(
            'Nails',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _nails.isEmpty ? null : _nails,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'Normal color & shape',
              'Cyanosis',
              'Pallor',
              'Splinter hemorrhages',
              'Clubbing',
              'Koilonychia (spooning)',
              'Pitting',
              'Beau\'s lines',
              'Onycholysis',
              'Normal capillary refill (<3s)',
              'Delayed capillary refill',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _nails = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nailsNotesController,
            decoration: InputDecoration(
              hintText: 'Describe specific nail changes...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCardiovascularTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Clinical Examination Procedures
          const Text(
            'A. Clinical Examination Procedures',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          
          // Inspection
          const Text(
            'Inspection',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _cvInspection.isEmpty ? null : _cvInspection,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'Normal',
              'Central cyanosis',
              'Peripheral cyanosis',
              'Pallor',
              'Pedal edema',
              'Generalized edema',
              'Jugular venous distension',
              'Chest wall deformity',
              'Visible pulsations',
              'Scars (sternotomy/thoracotomy)',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _cvInspection = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cvInspectionNotesController,
            decoration: InputDecoration(
              hintText: 'Describe other findings (e.g., venous distension)...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          // Peripheral Pulses
          const Text(
            'Peripheral Pulses',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildPeripheralPulsesTable(),
          
          const SizedBox(height: 16),
          
          // JVP
          const Text(
            'Jugular Venous Pressure (JVP)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _jvp.isEmpty ? null : _jvp,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: ['Normal', 'Elevated', 'Not visible'].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _jvp = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _jvpHeightController,
            decoration: InputDecoration(
              hintText: 'Enter measured height in cm H2O...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          // Precordial Palpation
          const Text(
            'Precordial Palpation',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _precordialPalpation.isEmpty ? null : _precordialPalpation,
            decoration: InputDecoration(
              hintText: 'Select General Finding...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'Normal apex beat',
              'Displaced apex beat (lateral)',
              'Heaving apex beat',
              'Tapping apex beat',
              'Parasternal heave (RV)',
              'Left parasternal lift',
              'Impalpable apex',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _precordialPalpation = value ?? ''),
          ),
          
          const SizedBox(height: 16),
          
          // Thrills
          const Text(
            'Thrills',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_thrills.length), // Reset dropdown when items change
                  value: null,
                  decoration: InputDecoration(
                    hintText: 'Select thrill location...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  items: [
                    'Absent',
                    'Systolic thrill at apex',
                    'Systolic thrill at base',
                    'Diastolic thrill at apex',
                    'Parasternal thrill',
                    'Suprasternal thrill',
                  ].map((item) {
                    return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && !_thrills.contains(value)) {
                      setState(() => _thrills.add(value));
                    }
                  },
                ),
              ),
            ],
          ),
          if (_thrills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _thrills.map((thrill) {
                return Chip(
                  label: Text(thrill, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => setState(() => _thrills.remove(thrill)),
                  deleteIconColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFF1F5F9),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Auscultation - Heart Sounds
          const Text(
            'Auscultation - Heart Sounds',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _heartSounds.isEmpty ? null : _heartSounds,
            decoration: InputDecoration(
              hintText: '-- Select --',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: [
              'S1 S2 Normal',
              'S1 Loud',
              'S1 Soft',
              'S2 Loud (P2 accentuated)',
              'S2 Soft',
              'S2 Split (physiological)',
              'S2 Fixed split',
              'S2 Paradoxical split',
              'S3 Gallop present',
              'S4 Gallop present',
              'Summation gallop',
              'Muffled heart sounds',
              'Distant heart sounds',
              'Metallic click',
              'Opening snap',
            ].map((item) {
              return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) => setState(() => _heartSounds = value ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _heartSoundsNotesController,
            decoration: InputDecoration(
              hintText: 'Note location and timing...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          // Auscultation - Murmurs
          const Text(
            'Auscultation - Murmurs',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Timing', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _murmurTiming.isEmpty ? null : _murmurTiming,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        hintText: '— Select —',
                      ),
                      items: ['Systolic ejection', 'Pansystolic', 'Diastolic', 'Continuous'].map((item) {
                        return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (value) => setState(() => _murmurTiming = value ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grade', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _murmurGrade.isEmpty ? null : _murmurGrade,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        hintText: '— Select —',
                      ),
                      items: ['1/6', '2/6', '3/6', '4/6', '5/6', '6/6'].map((item) {
                        return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (value) => setState(() => _murmurGrade = value ?? ''),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _murmurLocation.isEmpty ? null : _murmurLocation,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        hintText: '— Select —',
                      ),
                      items: ['Aortic', 'Pulmonic', 'Tricuspid', 'Mitral', 'Erb\'s point'].map((item) {
                        return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (value) => setState(() => _murmurLocation = value ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Radiation', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _murmurRadiation.isEmpty ? null : _murmurRadiation,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        hintText: '— Select —',
                      ),
                      items: ['None', 'Carotids', 'Axilla', 'Back'].map((item) {
                        return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (value) => setState(() => _murmurRadiation = value ?? ''),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quality', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _murmurQuality.isEmpty ? null : _murmurQuality,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  hintText: '— Select —',
                ),
                items: ['Harsh', 'Blowing', 'Musical', 'Rumbling'].map((item) {
                  return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)));
                }).toList(),
                onChanged: (value) => setState(() => _murmurQuality = value ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeripheralPulsesTable() {
    final pulses = [
      {'name': 'Carotid', 'right': 'carotid_right', 'left': 'carotid_left'},
      {'name': 'Radial', 'right': 'radial_right', 'left': 'radial_left'},
      {'name': 'Brachial', 'right': 'brachial_right', 'left': 'brachial_left'},
      {'name': 'Femoral', 'right': 'femoral_right', 'left': 'femoral_left'},
      {'name': 'Popliteal', 'right': 'popliteal_right', 'left': 'popliteal_left'},
      {'name': 'Posterior Tibial', 'right': 'posterior_tibial_right', 'left': 'posterior_tibial_left'},
      {'name': 'Dorsalis Pedis', 'right': 'dorsalis_pedis_right', 'left': 'dorsalis_pedis_left'},
    ];
    
    return Column(
      children: [
        // Header
        Row(
          children: [
            const Expanded(flex: 2, child: Text('Pulse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            const Expanded(child: Text('Right', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            const Expanded(child: Text('Left', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
        const Divider(),
        // Rows
        ...pulses.map((pulse) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(pulse['name']!, style: const TextStyle(fontSize: 13)),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _peripheralPulses[pulse['right']]!.isEmpty ? null : _peripheralPulses[pulse['right']],
                    decoration: InputDecoration(
                      hintText: '--',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      isDense: true,
                    ),
                    items: ['Normal', 'Weak', 'Bounding', 'Absent'].map((item) {
                      return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (value) => setState(() => _peripheralPulses[pulse['right']!] = value ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _peripheralPulses[pulse['left']]!.isEmpty ? null : _peripheralPulses[pulse['left']],
                    decoration: InputDecoration(
                      hintText: '--',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      isDense: true,
                    ),
                    items: ['Normal', 'Weak', 'Bounding', 'Absent'].map((item) {
                      return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (value) => setState(() => _peripheralPulses[pulse['left']!] = value ?? ''),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
    List<String> sections = [];
    
    // General Examination
    List<String> generalItems = [];
    if (_consciousnessTags.isNotEmpty) {
      generalItems.add('Consciousness: ${_consciousnessTags.join(", ")}');
    }
    if (_bodyHabitusTags.isNotEmpty) {
      generalItems.add('Body Habitus: ${_bodyHabitusTags.join(", ")}');
    }
    if (_postureTags.isNotEmpty) {
      generalItems.add('Posture & Gait: ${_postureTags.join(", ")}');
    }
    if (_distressTags.isNotEmpty) {
      generalItems.add('Distress: ${_distressTags.join(", ")}');
    }
    if (_hygieneTags.isNotEmpty) {
      generalItems.add('Hygiene: ${_hygieneTags.join(", ")}');
    }
    if (_temperatureController.text.isNotEmpty) {
      generalItems.add('Temperature: ${_temperatureController.text}°$_temperatureUnit');
    }
    if (_pulseController.text.isNotEmpty) {
      generalItems.add('Pulse: ${_pulseController.text} bpm');
    }
    if (_respiratoryRateController.text.isNotEmpty) {
      generalItems.add('Respiratory Rate: ${_respiratoryRateController.text} breaths/min');
    }
    if (_bpSystolicController.text.isNotEmpty && _bpDiastolicController.text.isNotEmpty) {
      generalItems.add('BP: ${_bpSystolicController.text}/${_bpDiastolicController.text} mmHg ($_bpPosition, $_bpArm arm)');
    }
    if (_oxygenSaturationController.text.isNotEmpty) {
      generalItems.add('SpO₂: ${_oxygenSaturationController.text}%');
    }
    if (_heightController.text.isNotEmpty) {
      generalItems.add('Height: ${_heightController.text} cm');
    }
    if (_weightController.text.isNotEmpty) {
      generalItems.add('Weight: ${_weightController.text} kg');
    }
    if (_bmi.isNotEmpty) {
      generalItems.add('BMI: $_bmi');
    }
    
    if (generalItems.isNotEmpty) {
      sections.add('Examination:\n• ${generalItems.join('\n• ')}');
    }
    
    // Cardiovascular
    List<String> cvItems = [];
    
    // Inspection
    if (_cvInspection.isNotEmpty) {
      cvItems.add('Inspection: $_cvInspection');
      if (_cvInspectionNotesController.text.isNotEmpty) {
        cvItems.add('  Notes: ${_cvInspectionNotesController.text}');
      }
    }
    
    // Peripheral Pulses - organized by pulse type
    Map<String, Map<String, String>> pulsesByType = {
      'Carotid': {},
      'Radial': {},
      'Brachial': {},
      'Femoral': {},
      'Popliteal': {},
      'Posterior Tibial': {},
      'Dorsalis Pedis': {},
    };
    
    _peripheralPulses.forEach((key, value) {
      if (value.isNotEmpty && value != '—') {
        if (key.startsWith('carotid')) {
          pulsesByType['Carotid']![key.contains('right') ? 'R' : 'L'] = value;
        } else if (key.startsWith('radial')) {
          pulsesByType['Radial']![key.contains('right') ? 'R' : 'L'] = value;
        } else if (key.startsWith('brachial')) {
          pulsesByType['Brachial']![key.contains('right') ? 'R' : 'L'] = value;
        } else if (key.startsWith('femoral')) {
          pulsesByType['Femoral']![key.contains('right') ? 'R' : 'L'] = value;
        } else if (key.startsWith('popliteal')) {
          pulsesByType['Popliteal']![key.contains('right') ? 'R' : 'L'] = value;
        } else if (key.startsWith('posterior')) {
          pulsesByType['Posterior Tibial']![key.contains('right') ? 'R' : 'L'] = value;
        } else if (key.startsWith('dorsalis')) {
          pulsesByType['Dorsalis Pedis']![key.contains('right') ? 'R' : 'L'] = value;
        }
      }
    });
    
    List<String> pulseLines = [];
    pulsesByType.forEach((pulseName, sides) {
      if (sides.isNotEmpty) {
        List<String> sideValues = [];
        if (sides.containsKey('R')) sideValues.add('R-${sides['R']}');
        if (sides.containsKey('L')) sideValues.add('L-${sides['L']}');
        pulseLines.add('  - $pulseName: ${sideValues.join(', ')}');
      }
    });
    
    if (pulseLines.isNotEmpty) {
      cvItems.add('Peripheral Pulses:\n${pulseLines.join('\n')}');
    }
    
    // JVP
    if (_jvp.isNotEmpty) {
      String jvpText = 'JVP: $_jvp';
      if (_jvpHeightController.text.isNotEmpty) {
        jvpText += ' (${_jvpHeightController.text} cm H2O)';
      }
      cvItems.add(jvpText);
    }
    
    // Precordial Palpation
    if (_precordialPalpation.isNotEmpty) {
      cvItems.add('Precordial Palpation: $_precordialPalpation');
    }
    
    // Thrills
    if (_thrills.isNotEmpty) {
      cvItems.add('Thrills: ${_thrills.join(', ')}');
    }
    
    // Heart Sounds
    if (_heartSounds.isNotEmpty) {
      cvItems.add('Heart Sounds: $_heartSounds');
      if (_heartSoundsNotesController.text.isNotEmpty) {
        cvItems.add('  Notes: ${_heartSoundsNotesController.text}');
      }
    }
    
    // Murmur - only show if grade is actually selected (not empty)
    if (_murmurGrade.isNotEmpty) {
      List<String> murmurDetails = [];
      if (_murmurTiming.isNotEmpty) murmurDetails.add(_murmurTiming);
      murmurDetails.add('Grade $_murmurGrade');
      if (_murmurLocation.isNotEmpty) murmurDetails.add(_murmurLocation);
      if (_murmurRadiation.isNotEmpty && _murmurRadiation != 'None') {
        murmurDetails.add('Radiates to $_murmurRadiation');
      }
      if (_murmurQuality.isNotEmpty) murmurDetails.add(_murmurQuality);
      cvItems.add('Murmur: ${murmurDetails.join(', ')}');
    }
    
    if (cvItems.isNotEmpty) {
      sections.add('Cardiovascular:\n• ${cvItems.join('\n• ')}');
    }
    
    // Integumentary System
    List<String> integumentaryItems = [];
    
    if (_skinColorLesions.isNotEmpty) {
      integumentaryItems.add('Skin - Color & Lesions: $_skinColorLesions');
      if (_skinColorLesionsNotesController.text.isNotEmpty) {
        integumentaryItems.add('  Notes: ${_skinColorLesionsNotesController.text}');
      }
    }
    
    if (_skinPalpation.isNotEmpty) {
      integumentaryItems.add('Skin - Palpation: $_skinPalpation');
      if (_skinPalpationNotesController.text.isNotEmpty) {
        integumentaryItems.add('  Notes: ${_skinPalpationNotesController.text}');
      }
    }
    
    if (_pressureAreasEdema.isNotEmpty) {
      integumentaryItems.add('Pressure Areas & Edema: $_pressureAreasEdema');
      if (_pressureAreasEdemaNotesController.text.isNotEmpty) {
        integumentaryItems.add('  Notes: ${_pressureAreasEdemaNotesController.text}');
      }
    }
    
    if (_hair.isNotEmpty) {
      integumentaryItems.add('Hair: $_hair');
      if (_hairNotesController.text.isNotEmpty) {
        integumentaryItems.add('  Notes: ${_hairNotesController.text}');
      }
    }
    
    if (_nails.isNotEmpty) {
      integumentaryItems.add('Nails: $_nails');
      if (_nailsNotesController.text.isNotEmpty) {
        integumentaryItems.add('  Notes: ${_nailsNotesController.text}');
      }
    }
    
    if (integumentaryItems.isNotEmpty) {
      sections.add('Integumentary System:\n• ${integumentaryItems.join('\n• ')}');
    }
    
    return sections.join('\n\n');
  }

  void _saveExaminationData() {
    widget.onSave({
      'examination': {
        // General Survey
        'consciousness': _consciousnessTags,
        'bodyHabitus': _bodyHabitusTags,
        'posture': _postureTags,
        'distress': _distressTags,
        'hygiene': _hygieneTags,
        // Vital Signs
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
        // Cardiovascular
        'cvInspection': _cvInspection,
        'cvInspectionNotes': _cvInspectionNotesController.text,
        'peripheralPulses': _peripheralPulses,
        'jvp': _jvp,
        'jvpHeight': _jvpHeightController.text,
        'precordialPalpation': _precordialPalpation,
        'thrills': _thrills,
        'heartSounds': _heartSounds,
        'heartSoundsNotes': _heartSoundsNotesController.text,
        'murmurTiming': _murmurTiming,
        'murmurGrade': _murmurGrade,
        'murmurLocation': _murmurLocation,
        'murmurRadiation': _murmurRadiation,
        'murmurQuality': _murmurQuality,
        // Integumentary System
        'skinColorLesions': _skinColorLesions,
        'skinColorLesionsNotes': _skinColorLesionsNotesController.text,
        'skinPalpation': _skinPalpation,
        'skinPalpationNotes': _skinPalpationNotesController.text,
        'pressureAreasEdema': _pressureAreasEdema,
        'pressureAreasEdemaNotes': _pressureAreasEdemaNotesController.text,
        'hair': _hair,
        'hairNotes': _hairNotesController.text,
        'nails': _nails,
        'nailsNotes': _nailsNotesController.text,
      },
    });
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
            // Header with Search
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
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Search Field
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
                  _buildIntegumentaryTab(),
                  _buildCardiovascularTab(),
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
