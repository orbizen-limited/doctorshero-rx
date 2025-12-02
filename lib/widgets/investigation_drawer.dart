import 'package:flutter/material.dart';

class InvestigationDrawer extends StatefulWidget {
  final Function(List<Map<String, String>>) onSave;
  final VoidCallback onClose;

  const InvestigationDrawer({
    Key? key,
    required this.onSave,
    required this.onClose,
  }) : super(key: key);

  @override
  State<InvestigationDrawer> createState() => _InvestigationDrawerState();
}

class _InvestigationDrawerState extends State<InvestigationDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  
  List<Map<String, String>> _selectedInvestigations = [];
  
  final Map<String, List<String>> _investigationGroups = {
    'Blood Tests': [
      'CBC (Complete Blood Count)',
      'Hb% TC, DC, ESR, Platelet count, MCV',
      'Comment on peripheral blood film',
      'Hematocrit',
      'Blood Sugar (Fasting)',
      'Blood Sugar (Random)',
      'Blood Sugar (2 hrs after 75g glucose)',
      'HbA1c',
      'Lipid Profile',
      'Serum Cholesterol',
      'Serum Triglyceride (Fasting)',
      'HDL-Cholesterol',
      'LDL-Cholesterol',
      'Liver Function Test (LFT)',
      'Kidney Function Test (KFT)',
      'Serum Creatinine',
      'Blood Urea',
      'Serum Electrolytes',
      'Serum Sodium',
      'Serum Potassium',
      'Thyroid Function Test (TFT)',
      'TSH',
      'T3, T4',
      'Vitamin D',
      'Vitamin B12',
      'Serum Calcium',
      'Serum Uric Acid',
      'ESR',
      'CRP',
      'Serum Amylase',
      'Serum Lipase',
      'Prothrombin Time (PT)',
      'INR',
      'APTT',
      'Creatinine Phosphokinase',
      'CPK-MB',
      'Troponin I',
      'D-Dimer',
      'Ferritin',
      'Iron Studies',
      'PSA (Prostate Specific Antigen)',
      'Blood Group & Rh',
      'Hepatitis B Surface Antigen',
      'Hepatitis C Antibody',
      'HIV Test',
      'VDRL',
      'Dengue NS1 Antigen',
      'Dengue IgG/IgM',
      'Malaria Parasite',
      'MP (on thick & thin films)',
      'Typhoid Test (Widal)',
      'Tuberculin Test',
      'Quantiferon-TB Gold-plus',
    ],
    'Serological': [
      'ICT for filarial Ag',
      'ICT for malaria',
      'VDRL',
      'TPHA',
      'Anti-HIV Ab',
    ],
    'Rheumatological': [
      'C-reactive protein',
      'Rose-Waaler test',
      'RA test',
      'Anti-CCP Ab',
      'Serum uric acid',
      'ANA (screening)',
      'Anti-ds-DNA Ab',
      'Anti-Sm Ab',
      'pANCA',
      'cANCA',
      'Anti-SSA Ab',
      'Anti-SSB Ab',
      'Anti-RNP Ab',
      'Anti-JO-I',
      'Anti-Scl 70',
      'Anti-centromere Ab',
      'HLA B-27',
      'HLA-B51',
      'Lupus Anticoagulant',
      'Anti Phospholipid Ab',
      'Serum C3',
      'Serum C4',
      'Serum IgM',
      'Serum IgG',
      'Serum IgA',
      'Serum Aldolase',
    ],
    'Hepatic Profile': [
      'ALT',
      'AST',
      'Serum bilirubin',
      'LDH',
      'GGT',
      'Alkaline phosphatase',
      'Prothrombin time',
      'Anti-HBs titer',
      'Serum protein',
      'Serum albumin',
      'HBsAg (ELISA)',
      'HBeAg',
      'Anti HBc (total)',
      'Anti-HCV Ab',
      'IgM anti-HEV',
      'Anti-HEV Ab',
      'HBV-DNA',
    ],
    'Endocrinological': [
      'Serum TSH',
      'FT4',
      'Serum cortisol (basal)',
      'Testosterone',
      'iPTH',
      'Prolactin',
      'HbA1C',
      'FNAC of thyroid nodule',
      'S.phosphate',
      '25(OH)-vitD (Total)',
    ],
    'Urine Tests': [
      'Urine R/M/E (Routine/Microscopy/Examination)',
      'Urine Routine & Microscopy',
      'Urine Culture & Sensitivity',
      'Urine for Albumin',
      'Urine for Sugar',
      'Urine for Ketone Bodies',
      'Urine for Pregnancy Test',
      'Urine for Microalbumin',
      '24-hour Urine Protein',
      '24-hour Urinary Protein',
      'CCr (Creatinine Clearance)',
      'Urinary Protein/Creatinine Ratio (PCR)',
    ],
    'Stool Tests': [
      'Stool Routine & Microscopy',
      'Stool for Occult Blood',
      'Stool Culture',
    ],
    'Ultrasonography': [
      'Ultrasound Upper abdomen/hepatobiliary system and pancreas',
      'Ultrasound to exclude CLD/fluid in right/left supradiaphragmatic space',
      'Ultrasound Kidneys, adrenals, bladder',
      'Ultrasound Postvoidal residue',
      'Ultrasound Prostate',
      'Ultrasound Pelvic organs/scrotum',
      'Ultrasound Whole abdomen',
      'Ultrasound Paraaortic lymph nodes',
      'Ultrasound Spleen',
      'Ultrasound to exclude ascites',
      'Duplex study of carotid',
      'Duplex study of lower limb arterial/venous system',
      'Duplex study of upper limb arterial/venous system',
      'MSK USG Rt/Lt shoulder',
      'MSK USG Rt/Lt Knee',
      'MSK USG Rt/Lt Ankle',
      'MSK USG Rt/Lt Hip',
      'MSK USG Rt/Lt Hand',
      'Ultrasound Abdomen',
      'Ultrasound Pelvis',
      'Ultrasound KUB',
      'Ultrasound Whole Abdomen',
    ],
    'Radiology': [
      'X-ray chest P/A & right/left lateral/apical views',
      'X-ray Chest PA',
      'X-ray Chest AP',
      'Plain X-ray KUB',
      'X-ray Abdomen',
      'X-ray cervical spine AP, lateral, right/left oblique views',
      'X-ray right/left shoulder AP view at 40 abduction',
      'X-ray dorsal spine AP & left/right lateral views',
      'X-ray dorsolumbar spine AP & lateral views',
      'X-ray lumbo sacral spine AP (including both SI joints) and lateral views',
      'X-ray pelvis AP view including both Hip Joints',
      'X-ray of both SI joints oblique view',
      'X-ray S.1 joint Modified Ferguson view',
      'X-ray right/left/both knees AP/lateral/skyline views',
      'X-ray right/left ankles AP/Lateral & mortise view',
      'X-ray hand A/P view',
      'X-ray wrist A/P view',
      'X-ray Spine',
      'X-ray Pelvis',
      'X-ray Knee',
      'X-ray Shoulder',
      'X-ray Hand',
      'X-ray Foot',
      'Barium follow through X-ray of small gut',
      'CT scan of brain',
      'CT scan of chest',
      'CT scan of mediastinum',
      'CT scan of upper/lower abdomen',
      'CT Scan Brain',
      'CT Scan Chest',
      'CT Scan Abdomen',
      'HRCT of chest',
      'MRI of Sacroiliac Joint',
      'MRI of brain',
      'MRI of LS/cervical/dorsal spine',
      'MRI of knee/hip joints',
      'MRI of left/right Knee',
      'MRI of hip joint',
      'MRI Brain',
      'MRI Spine',
      'MRI Knee',
      'BMD of Hip & lumbar Spine',
      'Mammography',
      'DEXA Scan',
    ],
    'Cardiac Tests': [
      'ECG',
      'Echocardiography',
      'Echocardiography (to exclude evidence of rheumatic carditis)',
      'Color doppler study of heart including PASP',
      'Stress Test (TMT)',
      'Exercise tolerance test',
      'Holter Monitoring',
      '2D Echo',
      'Color Doppler',
    ],
    'Endoscopy': [
      'Upper GI Endoscopy',
      'Upper GI endoscopy with distal duodenal biopsy',
      'Colonoscopy',
      'Sigmoidoscopy',
      'ERCP',
      'Fiberoptic bronchoscopy with AFB, malignant cells & mycobacterial C/S of BAL',
    ],
    'Pulmonary Tests': [
      'Pulmonary Function Test (PFT)',
      'Spirometry',
      'Chest X-ray',
    ],
    'Hematological': [
      'M/E of bone marrow (including iron staining)',
      'Hemoglobin electrophoresis',
      'Serum protein electrophoresis',
      'S. Iron',
      'TIBC',
      'Serum ferritin',
      'sTfR',
      'Serum vitamin B12',
      'Coombs\' test',
      'Reticulocyte count',
      'Indirect bilirubin',
    ],
    'Microbiological': [
      'Culture and sensitivity of urine',
      'Culture and sensitivity of blood',
      'Culture and sensitivity of stool',
      'Culture and sensitivity of throat swab',
      'M/E of swab from mouth ulcer for candida',
      'Sputum for AFB',
      'Sputum Culture',
      'Blood Culture',
      'Throat Swab Culture',
    ],
    'Body Fluid Analysis': [
      'Study of Pleural fluid - Cell counts',
      'Study of Pleural fluid - Protein, sugar',
      'Study of Pleural fluid - AFB, Gram staining',
      'Study of Pleural fluid - Malignant cells',
      'Study of Pleural fluid - Mycobacterial culture & sensitivity',
      'Study of Pleural fluid - ADA',
      'Study of Ascitic fluid - Cell counts',
      'Study of Ascitic fluid - Protein, sugar',
      'Study of Ascitic fluid - AFB, Gram staining',
      'Study of Ascitic fluid - Malignant cells',
      'Study of Ascitic fluid - Mycobacterial culture & sensitivity',
      'Study of Ascitic fluid - ADA',
      'Study of Cerebrospinal fluid - Cell counts',
      'Study of Cerebrospinal fluid - Protein, sugar',
      'Study of Cerebrospinal fluid - AFB, Gram staining',
      'Study of Cerebrospinal fluid - Malignant cells',
      'Study of Cerebrospinal fluid - Mycobacterial culture & sensitivity',
      'Study of Cerebrospinal fluid - ADA',
      'Study of Sputum - AFB, Gram staining',
      'Study of Sputum - Malignant cells',
      'Study of Sputum - Mycobacterial culture & sensitivity',
      'Study of Pulmonary fluid - Cell counts',
      'Study of Lymph node FN aspirate - Cell counts',
      'Study of Lymph node FN aspirate - AFB, Gram staining',
      'Study of Lymph node FN aspirate - Malignant cells',
    ],
    'Synovial Fluid': [
      'Synovial fluid - Cell counts',
      'Synovial fluid - AFB, gram staining & C/S',
      'Synovial fluid - Genexpert for MTB',
      'Synovial fluid - Crystals',
      'Study of synovial fluid for Crystal',
    ],
    'Biopsy': [
      'Skin Biopsy',
      'Muscle Biopsy',
      'Lymph node Biopsy',
      'Kidney Biopsy',
      'Biopsy',
    ],
    'Other Tests': [
      'Pap Smear',
      'FNAC',
      'Bone Marrow Examination',
      'Mantoux Test',
      'Audiometry',
      'Visual Acuity Test',
      'Fundoscopy',
      'Nerve Conduction Study',
      'EMG',
      'NCS of right/left upper/lower limbs',
      'EEG',
      'Spirometry e\' DLCO',
      'Semen analysis',
      'Serum PSA',
    ],
  };
  
  Map<String, List<String>> _getFilteredInvestigations() {
    if (_searchController.text.isEmpty) {
      return _investigationGroups;
    }
    
    final searchQuery = _searchController.text.toLowerCase();
    final filteredGroups = <String, List<String>>{};
    
    _investigationGroups.forEach((groupName, investigations) {
      final filtered = investigations
          .where((i) => i.toLowerCase().contains(searchQuery))
          .toList();
      if (filtered.isNotEmpty) {
        filteredGroups[groupName] = filtered;
      }
    });
    
    return filteredGroups;
  }
  
  List<String> _getAllInvestigations() {
    return _investigationGroups.values.expand((list) => list).toList();
  }
  
  void _addInvestigation(String name) {
    if (!_selectedInvestigations.any((i) => i['name'] == name)) {
      setState(() {
        _selectedInvestigations.add({
          'name': name,
          'value': '',
          'note': '',
        });
      });
    }
  }
  
  void _removeInvestigation(int index) {
    setState(() {
      _selectedInvestigations.removeAt(index);
    });
  }
  
  void _updateInvestigationField(int index, String field, String value) {
    setState(() {
      _selectedInvestigations[index][field] = value;
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

  Widget _buildTable(List<Map<String, String>> investigations, int startIndex) {
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
        ...investigations.asMap().entries.map((entry) {
          final localIndex = entry.key;
          final globalIndex = startIndex + localIndex;
          final investigation = entry.value;
          
          // Handle migration from old format (instructions + comment) to new format (note)
          String noteValue = investigation['note'] ?? '';
          if (noteValue.isEmpty) {
            final instructions = investigation['instructions'] ?? '';
            final comment = investigation['comment'] ?? '';
            noteValue = [instructions, comment].where((s) => s.isNotEmpty).join(' ');
          }
          
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
                    key: ValueKey('name_${investigation['name']}_$globalIndex'),
                    controller: TextEditingController(text: investigation['name'] ?? ''),
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
                    onChanged: (value) => _updateInvestigationField(globalIndex, 'name', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: ValueKey('value_${investigation['name']}_$globalIndex'),
                    controller: TextEditingController(text: investigation['value'] ?? ''),
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
                    onChanged: (value) => _updateInvestigationField(globalIndex, 'value', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: ValueKey('note_${investigation['name']}_$globalIndex'),
                    controller: TextEditingController(text: noteValue),
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
                    onChanged: (value) => _updateInvestigationField(globalIndex, 'note', value),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _removeInvestigation(globalIndex),
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
    final filteredInvestigations = _getFilteredInvestigations();
    
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
                    'Investigation',
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
                      widget.onSave(_selectedInvestigations);
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
            
            // Search Bar and Custom Input Row
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Search Field - Half Width
                  Expanded(
                    flex: 1,
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
                  const SizedBox(width: 12),
                  // Custom Input with Add Button - Half Width
                  Expanded(
                    flex: 1,
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
                                _addInvestigation(value);
                                _customController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_customController.text.isNotEmpty) {
                              _addInvestigation(_customController.text);
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
                ],
              ),
            ),
            
            // Investigation Tags - Grouped (2 columns)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
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
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final entries = filteredInvestigations.entries.toList();
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
                                      final groupName = entry.key;
                                      final investigations = entry.value;
                                      
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
                                            initiallyExpanded: _searchController.text.isNotEmpty,
                                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                            title: Text(
                                              groupName,
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
                                                children: investigations.map((investigation) {
                                                  final isSelected = _selectedInvestigations.any((i) => i['name'] == investigation);
                                                  final searchQuery = _searchController.text.toLowerCase();
                                                  final isMatch = searchQuery.isNotEmpty && 
                                                      investigation.toLowerCase().contains(searchQuery);
                                                  return InkWell(
                                                    onTap: () => _addInvestigation(investigation),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: isSelected 
                                                            ? const Color(0xFFE8F5E9) 
                                                            : (isMatch ? const Color(0xFFFFF4E6) : const Color(0xFFF1F5F9)),
                                                        border: Border.all(
                                                          color: isSelected 
                                                              ? const Color(0xFF4CAF50) 
                                                              : (isMatch ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0)),
                                                          width: isMatch ? 1.5 : 1,
                                                        ),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: _buildHighlightedText(investigation, _searchController.text),
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
                                      final groupName = entry.key;
                                      final investigations = entry.value;
                                      
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
                                            initiallyExpanded: _searchController.text.isNotEmpty,
                                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                            title: Text(
                                              groupName,
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
                                                children: investigations.map((investigation) {
                                                  final isSelected = _selectedInvestigations.any((i) => i['name'] == investigation);
                                                  final searchQuery = _searchController.text.toLowerCase();
                                                  final isMatch = searchQuery.isNotEmpty && 
                                                      investigation.toLowerCase().contains(searchQuery);
                                                  return InkWell(
                                                    onTap: () => _addInvestigation(investigation),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: isSelected 
                                                            ? const Color(0xFFE8F5E9) 
                                                            : (isMatch ? const Color(0xFFFFF4E6) : const Color(0xFFF1F5F9)),
                                                        border: Border.all(
                                                          color: isSelected 
                                                              ? const Color(0xFF4CAF50) 
                                                              : (isMatch ? const Color(0xFFFE3001) : const Color(0xFFE2E8F0)),
                                                          width: isMatch ? 1.5 : 1,
                                                        ),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: _buildHighlightedText(investigation, _searchController.text),
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
                      ),
                    ),
                    // Scroll indicator at the bottom
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scroll for more investigations',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                              fontFamily: 'ProductSans',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Selected Investigations Table (2 tables side by side)
            Expanded(
              child: Container(
                color: const Color(0xFF1E293B),
                child: _selectedInvestigations.isNotEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Table
                            Expanded(
                              child: _buildTable(
                                _selectedInvestigations.take((_selectedInvestigations.length / 2).ceil()).toList(),
                                0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Right Table
                            Expanded(
                              child: _buildTable(
                                _selectedInvestigations.skip((_selectedInvestigations.length / 2).ceil()).toList(),
                                (_selectedInvestigations.length / 2).ceil(),
                              ),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'No investigations selected',
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
}
