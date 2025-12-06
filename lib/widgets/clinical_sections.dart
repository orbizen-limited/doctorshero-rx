import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import 'clinical_drawer.dart';
import 'examination_drawer.dart';
import 'diagnosis_drawer.dart';
import 'chief_complaint_drawer.dart';
import 'investigation_drawer.dart';
import 'history_drawer.dart';

class ClinicalSections extends StatefulWidget {
  final ClinicalData clinicalData;
  final Function(String field, String value)? onUpdate;
  final Function(bool enabled, String? amount)? onDiscountUpdate;

  const ClinicalSections({
    Key? key,
    required this.clinicalData,
    this.onUpdate,
    this.onDiscountUpdate,
  }) : super(key: key);

  @override
  State<ClinicalSections> createState() => _ClinicalSectionsState();
}

class _ClinicalSectionsState extends State<ClinicalSections> {

  bool _discountEnabled = false;
  final TextEditingController _discountController = TextEditingController();

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  // Predefined items for each section
  final Map<String, List<String>> _predefinedItems = const {
    'chiefComplaint': [
      'Low Back Pain', 'Headache', 'Abdominal pain', 'Dizziness / vertigo',
      'Neck pain', 'Dry cough', 'Generalized Bodyache', 'Fever',
      'Shortness of breath', 'Abdominal bloating', 'Chest pain',
      'Weight loss', 'Nausea', 'Fatigue'
    ],
    'examination': [
      'BP 120/80 mmHg', 'Pulse 72/min', 'Temp 98.6 F', 'Chest clear',
      'Heart sounds normal', 'Abdomen soft', 'No tenderness',
      'Respiratory rate normal'
    ],
    'history': [
      'No known allergies', 'No prior surgeries', 'Smokes occasionally',
      'Diabetes', 'Hypertension', 'Asthma', 'Heart disease',
      'Family history of diabetes'
    ],
    'diagnosis': [
      'Viral infection', 'Bacterial infection', 'Hypertension',
      'Diabetes Type 2', 'Gastritis', 'Migraine', 'Common cold',
      'Urinary tract infection'
    ],
    'investigation': [
      'CBC ordered', 'X-ray chest', 'ECG', 'Blood sugar',
      'Lipid profile', 'Liver function test', 'Kidney function test',
      'Urine routine'
    ],
  };

  void _openDrawer(BuildContext context, String title, String field) {
    // Use special chief complaint drawer for chiefComplaint field
    if (field == 'chiefComplaint') {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: ChiefComplaintDrawer(
                initialData: widget.clinicalData.chiefComplaintData,
                onSave: (complaints) {
                  // Store raw data
                  print('ClinicalSections: Storing ${complaints.length} complaints');
                  widget.clinicalData.chiefComplaintData = complaints;
                  print('ClinicalSections: Stored data: ${widget.clinicalData.chiefComplaintData}');
                  if (widget.onUpdate != null) {
                    // Format complaints as bullet list
                    String preview = complaints.map((c) {
                      String line = c['name']!;
                      if (c['value']!.isNotEmpty) {
                        line += ' - ${c['value']}';
                      }
                      if (c['note']!.isNotEmpty) {
                        line += ' (${c['note']})';
                      }
                      return line;
                    }).join('\n• ');
                    if (preview.isNotEmpty) {
                      preview = '• $preview';
                    }
                    widget.onUpdate!(field, preview);
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
      return;
    }
    
    // Use special examination drawer for examination field
    if (field == 'examination') {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: ExaminationDrawer(
                onSave: (data) {
                  if (widget.onUpdate != null) {
                    widget.onUpdate!(field, data['preview'] ?? '');
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
      return;
    }
    
    // Use special diagnosis drawer for diagnosis field
    if (field == 'diagnosis') {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: DiagnosisDrawer(
                initialData: widget.clinicalData.diagnosisData,
                onSave: (diagnoses) {
                  // Store raw data
                  widget.clinicalData.diagnosisData = diagnoses;
                  if (widget.onUpdate != null) {
                    // Format diagnoses as bullet list
                    String preview = diagnoses.map((d) {
                      String line = d['name']!;
                      if (d['value']!.isNotEmpty) {
                        line += ' - ${d['value']}';
                      }
                      if (d['note']!.isNotEmpty) {
                        line += ' (${d['note']})';
                      }
                      return line;
                    }).join('\n• ');
                    if (preview.isNotEmpty) {
                      preview = '• $preview';
                    }
                    widget.onUpdate!(field, preview);
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
      return;
    }
    
    // Use special investigation drawer for investigation field
    if (field == 'investigation') {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: InvestigationDrawer(
                initialData: widget.clinicalData.investigationData,
                onSave: (investigations) {
                  // Store raw data
                  widget.clinicalData.investigationData = investigations;
                  if (widget.onUpdate != null) {
                    // Format investigations as bullet list
                    String preview = investigations.map((i) {
                      String line = i['name']!;
                      if (i['value']!.isNotEmpty) {
                        line += ' - ${i['value']}';
                      }
                      if (i['note']!.isNotEmpty) {
                        line += ' (${i['note']})';
                      }
                      return line;
                    }).join('\n• ');
                    if (preview.isNotEmpty) {
                      preview = '• $preview';
                    }
                    widget.onUpdate!(field, preview);
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
      return;
    }
    
    // Use special history drawer for history field
    if (field == 'history') {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: HistoryDrawer(
                initialData: widget.clinicalData.historyData,
                onSave: (historyItems) {
                  // Store raw data
                  widget.clinicalData.historyData = historyItems;
                  if (widget.onUpdate != null) {
                    // Format history items as bullet list
                    String preview = historyItems.map((h) {
                      String line = h['name']?.toString() ?? '';
                      if ((h['value']?.toString() ?? '').isNotEmpty) {
                        line += ' - ${h['value']}';
                      }
                      if ((h['note']?.toString() ?? '').isNotEmpty) {
                        line += ' (${h['note']})';
                      }
                      return line;
                    }).join('\n• ');
                    if (preview.isNotEmpty) {
                      preview = '• $preview';
                    }
                    widget.onUpdate!(field, preview);
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
      return;
    }
    
    // Use regular drawer for other fields
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: ClinicalDrawer(
              title: title,
              predefinedItems: _predefinedItems[field] ?? [],
              onItemsSelected: (items) {
                final text = items.map((item) => item.toFormattedString()).join('\n');
                if (widget.onUpdate != null) {
                  widget.onUpdate!(field, text);
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          'Chief Complaint',
          widget.clinicalData.chiefComplaint,
          'chiefComplaint',
          Icons.description_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'Examination',
          widget.clinicalData.examination,
          'examination',
          Icons.medical_information_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'History',
          widget.clinicalData.history,
          'history',
          Icons.history,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'Diagnosis',
          widget.clinicalData.diagnosis,
          'diagnosis',
          Icons.analytics_outlined,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          'Investigation',
          widget.clinicalData.investigation,
          'investigation',
          Icons.science_outlined,
        ),
        const SizedBox(height: 20),
        // Discount checkbox and input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _discountEnabled,
                onChanged: (value) {
                  setState(() {
                    _discountEnabled = value ?? false;
                    if (!_discountEnabled) {
                      _discountController.clear();
                      if (widget.onDiscountUpdate != null) {
                        widget.onDiscountUpdate!(false, null);
                      }
                    } else {
                      if (widget.onDiscountUpdate != null) {
                        widget.onDiscountUpdate!(true, _discountController.text);
                      }
                    }
                  });
                },
                activeColor: const Color(0xFFFE3001),
              ),
              if (_discountEnabled) ...[
                const Text(
                  'please give ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
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
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) {
                      if (widget.onDiscountUpdate != null) {
                        widget.onDiscountUpdate!(_discountEnabled, value.isEmpty ? null : value);
                      }
                    },
                  ),
                ),
                const Text(
                  ' % discount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ] else ...[
                const Text(
                  'Discount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, String field, IconData icon) {
    return InkWell(
      onTap: () => _openDrawer(context, title, field),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Icon(icon, size: 18, color: const Color(0xFFFE3001)),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content.isEmpty
                ? const Text(
                    'Enter details...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'ProductSans',
                    ),
                  )
                : (field == 'chiefComplaint' || field == 'examination' || field == 'diagnosis' || field == 'investigation' || field == 'history') && content.contains('\n•')
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: content.split('\n•').where((line) => line.trim().isNotEmpty).map((line) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                                Expanded(
                                  child: Text(
                                    line.trim(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'ProductSans',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    : Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontFamily: 'ProductSans',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
          ],
        ),
      ),
    );
  }
}
