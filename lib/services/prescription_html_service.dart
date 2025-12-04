import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import '../models/medicine_model.dart';

class PrescriptionHtmlService {
  // Initialize Bangla font manager
  static bool _isInitialized = false;
  
  static Future<void> _initializeBanglaFonts() async {
    if (!_isInitialized) {
      await BanglaFontManager().initialize();
      _isInitialized = true;
      print(' Bangla font manager initialized successfully');
    }
  }

  // Check if string contains Bangla characters (Unicode range: U+0980 to U+09FF)
  static bool _containsBangla(String text) {
    return text.runes.any((rune) => rune >= 0x0980 && rune <= 0x09FF);
  }

  // Get appropriate text widget - BanglaText for Bangla, pw.Text for English
  // Handles mixed Bangla/English text by splitting and rendering separately
  static pw.Widget _getTextWidget(String text, {double? fontSize, pw.FontWeight? fontWeight, pw.TextAlign? textAlign}) {
    // Check if text contains both Bangla and English (e.g., "খাওয়ার পরে (After meal)")
    final hasBangla = _containsBangla(text);
    
    if (!hasBangla) {
      // Pure English text
      return pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize ?? 9,
          fontWeight: fontWeight,
        ),
        textAlign: textAlign,
      );
    }
    
    // Check if text has English in parentheses (e.g., "খাওয়ার পরে (After meal)")
    final parenMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(text);
    if (parenMatch != null) {
      final banglaPart = parenMatch.group(1)!.trim();
      final englishPart = parenMatch.group(2)!.trim();
      
      // Render as Row with Bangla and English parts
      return pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          BanglaText(
            banglaPart,
            fontSize: fontSize ?? 9,
            fontWeight: fontWeight ?? pw.FontWeight.normal,
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(width: 4),
          pw.Text(
            '($englishPart)',
            style: pw.TextStyle(
              fontSize: fontSize ?? 9,
              fontWeight: fontWeight,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ],
      );
    }
    
    // Pure Bangla text or mixed without parentheses pattern
    return BanglaText(
      text,
      fontSize: fontSize ?? 9,
      fontWeight: fontWeight ?? pw.FontWeight.normal,
      textAlign: textAlign ?? pw.TextAlign.left,
    );
  }

  // Get margin settings from SharedPreferences
  static Future<Map<String, double>> getMarginSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'top': prefs.getDouble('print_margin_top') ?? 3.0,
      'bottom': prefs.getDouble('print_margin_bottom') ?? 3.0,
      'left': prefs.getDouble('print_margin_left') ?? 1.5,
      'right': prefs.getDouble('print_margin_right') ?? 0.8,
      'leftColumnWidth': prefs.getDouble('print_left_column_width') ?? 7.0,
      'pageWidth': prefs.getDouble('print_page_width') ?? 21.0,
      'pageHeight': prefs.getDouble('print_page_height') ?? 29.7,
    };
  }

  static Future<String> generateAndOpenHtml({
    required String patientName,
    required String age,
    required String date,
    required String patientId,
    String? phone,
    required List<String> chiefComplaints,
    required Map<String, dynamic> examination,
    required List<String> diagnosis,
    required List<String> investigation,
    required List<Medicine> medicines,
    required List<String> advice,
    required String? followUpDate,
    required String? referral,
  }) async {
    // Initialize Bangla fonts
    await _initializeBanglaFonts();
    
    // Get margin settings
    final margins = await getMarginSettings();
    
    // Generate PDF instead of HTML
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          margins['pageWidth']! * PdfPageFormat.cm,
          margins['pageHeight']! * PdfPageFormat.cm,
        ),
        margin: pw.EdgeInsets.only(
          top: margins['top']! * PdfPageFormat.cm,
          bottom: margins['bottom']! * PdfPageFormat.cm,
          left: margins['left']! * PdfPageFormat.cm,
          right: margins['right']! * PdfPageFormat.cm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Patient Info - Full width at top with proper spacing
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _getTextWidget('Name: $patientName', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  _getTextWidget('Age: $age', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  if (phone != null && phone.isNotEmpty)
                    _getTextWidget('Phone: $phone', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  _getTextWidget('Date: $date', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  _getTextWidget('ID: $patientId', fontSize: 9, fontWeight: pw.FontWeight.bold),
                ],
              ),
              pw.SizedBox(height: 15),

              // Two-column layout below patient info
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column - Chief Complaint, Examination, Diagnosis, Investigation
                    pw.SizedBox(
                      width: margins['leftColumnWidth']! * PdfPageFormat.cm,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Chief Complaint
                          if (chiefComplaints.isNotEmpty) ...[
                            _getTextWidget('Chief Complaint', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...chiefComplaints.map((complaint) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- $complaint', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // On Examinations
                          if (examination.isNotEmpty) ...[
                            _getTextWidget('On Examinations', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...examination.entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- ${entry.key}: ${entry.value}', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // Diagnosis
                          if (diagnosis.isNotEmpty) ...[
                            _getTextWidget('Diagnosis', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...diagnosis.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- $item', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // Investigation
                          if (investigation.isNotEmpty) ...[
                            _getTextWidget('Investigation', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...investigation.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- $item', fontSize: 9),
                            )),
                          ],
                        ],
                      ),
                    ),

                    // Spacing before separator
                    pw.SizedBox(width: 10),

                    // Vertical Divider
                    pw.Container(
                      width: 0.5,
                      height: double.infinity,
                      color: PdfColors.grey400,
                    ),

                    // Spacing after separator
                    pw.SizedBox(width: 10),

                    // Right Column - Rx (Medicines)
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _getTextWidget('Rx,', fontSize: 12, fontWeight: pw.FontWeight.bold),
                          pw.SizedBox(height: 10),

                          // Medicines List
                          ...medicines.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final medicine = entry.value;
                            final isInj = medicine.type.toLowerCase().contains('inj');
                            final isSpray = medicine.type.toLowerCase().contains('spray');
                            
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _getTextWidget('$index. ', fontSize: 9),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _getTextWidget(
                                          '${medicine.type} ${medicine.name}',
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        // Show quantity x frequency (Route) for Inj/Spray, or dosage for others
                                        if ((isInj || isSpray) && medicine.quantity.isNotEmpty && medicine.frequency.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: _getTextWidget(
                                              isInj && medicine.route.isNotEmpty
                                                  ? '${medicine.quantity} x ${medicine.frequency} (Route: ${medicine.route})'
                                                  : '${medicine.quantity} x ${medicine.frequency}',
                                              fontSize: 8,
                                            ),
                                          )
                                        else if (medicine.dosage.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: _getTextWidget(medicine.dosage, fontSize: 8),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (medicine.duration.isNotEmpty)
                                    pw.Container(
                                      width: 80,
                                      alignment: pw.Alignment.center,
                                      padding: const pw.EdgeInsets.only(left: 10),
                                      child: _getTextWidget(
                                        '${medicine.duration}${medicine.interval.isNotEmpty ? " (${medicine.interval})" : ""}${medicine.tillNumber == "চলবে" || medicine.tillNumber == "Continues" ? " - চলবে" : medicine.tillNumber.isNotEmpty ? " - ${medicine.tillNumber} ${medicine.tillUnit}" : ""}',
                                        fontSize: 8,
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                  if (medicine.advice.isNotEmpty)
                                    pw.Container(
                                      width: 60,
                                      padding: const pw.EdgeInsets.only(left: 10),
                                      child: _getTextWidget(
                                        medicine.advice,
                                        fontSize: 8,
                                        textAlign: pw.TextAlign.left,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),

                          pw.SizedBox(height: 15),

                          // Advice
                          if (advice.isNotEmpty) ...[
                            _getTextWidget('Advices', fontSize: 10, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...advice.asMap().entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: _getTextWidget('${entry.key + 1}. ${entry.value}', fontSize: 8),
                            )),
                            pw.SizedBox(height: 10),
                          ],

                          // Follow-up and Referral
                          if (followUpDate != null || referral != null) ...[
                            pw.Row(
                              children: [
                                if (followUpDate != null) ...[
                                  _getTextWidget('Follow-up: ', fontSize: 9, fontWeight: pw.FontWeight.bold),
                                  _getTextWidget(followUpDate, fontSize: 9),
                                ],
                                if (followUpDate != null && referral != null) pw.SizedBox(width: 20),
                                if (referral != null) ...[
                                  _getTextWidget('Referral: ', fontSize: 9, fontWeight: pw.FontWeight.bold),
                                  pw.Expanded(child: _getTextWidget(referral, fontSize: 9)),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Generate PDF bytes
    final pdfBytes = await pdf.save();
    
    print('✅ PDF prescription generated');
    print('🖨️ Opening native Windows print dialog...');
    
    // Open native Windows print dialog directly
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
    
    // Return empty string since we're not saving a file
    return '';
  }
}
