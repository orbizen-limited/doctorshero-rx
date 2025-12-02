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
    'Imaging': [
      'X-ray Chest PA',
      'X-ray Chest AP',
      'X-ray Abdomen',
      'X-ray Spine',
      'X-ray Pelvis',
      'X-ray Knee',
      'X-ray Shoulder',
      'X-ray Hand',
      'X-ray Foot',
      'CT Scan Brain',
      'CT Scan Chest',
      'CT Scan Abdomen',
      'MRI Brain',
      'MRI Spine',
      'MRI Knee',
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
      'Colonoscopy',
      'Sigmoidoscopy',
      'ERCP',
    ],
    'Pulmonary Tests': [
      'Pulmonary Function Test (PFT)',
      'Spirometry',
      'Chest X-ray',
    ],
    'Other Tests': [
      'Pap Smear',
      'Biopsy',
      'FNAC',
      'Bone Marrow Examination',
      'Sputum for AFB',
      'Sputum Culture',
      'Blood Culture',
      'Throat Swab Culture',
      'Mantoux Test',
      'Audiometry',
      'Visual Acuity Test',
      'Fundoscopy',
      'Nerve Conduction Study',
      'EMG',
      'EEG',
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
            
            // Investigation Tags - Grouped
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: filteredInvestigations.entries.map((entry) {
                    final groupName = entry.key;
                    final investigations = entry.value;
                    
                    return Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: _searchController.text.isNotEmpty,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        childrenPadding: const EdgeInsets.only(bottom: 12),
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
                              return InkWell(
                                onTap: () => _addInvestigation(investigation),
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
                                    investigation,
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
                        ],
                      ),
                    );
                  }).toList(),
                ),
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
            
            const SizedBox(height: 24),
            
            // Selected Investigations Table
            if (_selectedInvestigations.isNotEmpty) ...[
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
                      ..._selectedInvestigations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final investigation = entry.value;
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
                                  investigation['name']!,
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
                                  onChanged: (value) => _updateInvestigationField(index, 'value', value),
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
                                  onChanged: (value) => _updateInvestigationField(index, 'note', value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () => _removeInvestigation(index),
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
                    'No investigations selected',
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
