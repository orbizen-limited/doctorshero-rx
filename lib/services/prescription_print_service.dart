import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import '../models/medicine_model.dart';

class PrescriptionPrintService {
  // Initialize Bangla font manager
  static bool _isInitialized = false;
  
  static Future<void> _initializeBanglaFonts() async {
    if (!_isInitialized) {
      await BanglaFontManager().initialize();
      _isInitialized = true;
      print('Bangla font manager initialized successfully');
    }
  }

  // Check if string contains Bangla characters (Unicode range: U+0980 to U+09FF)
  static bool _containsBangla(String text) {
    return text.runes.any((rune) => rune >= 0x0980 && rune <= 0x09FF);
  }

  // Get text widget that wraps properly for constrained width
  static pw.Widget _getWrappedTextWidget(String text, double maxWidth, {double? fontSize, pw.FontWeight? fontWeight, pw.TextAlign? textAlign}) {
    final hasBangla = _containsBangla(text);
    
    if (!hasBangla) {
      return pw.SizedBox(
        width: maxWidth,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: fontSize ?? 9,
            fontWeight: fontWeight,
          ),
          textAlign: textAlign,
        ),
      );
    }
    
    final parenMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(text);
    if (parenMatch != null) {
      final banglaPart = parenMatch.group(1)!.trim();
      final englishPart = parenMatch.group(2)!.trim();
      
      // Render as Column to allow wrapping
      return pw.SizedBox(
        width: maxWidth,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            BanglaText(
              banglaPart,
              fontSize: fontSize ?? 9,
              fontWeight: fontWeight ?? pw.FontWeight.normal,
              textAlign: pw.TextAlign.left,
            ),
            pw.Text(
              '($englishPart)',
              style: pw.TextStyle(
                fontSize: fontSize ?? 9,
                fontWeight: fontWeight,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ],
        ),
      );
    }
    
    return pw.SizedBox(
      width: maxWidth,
      child: BanglaText(
        text,
        fontSize: fontSize ?? 9,
        fontWeight: fontWeight ?? pw.FontWeight.normal,
        textAlign: textAlign ?? pw.TextAlign.left,
      ),
    );
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
      'top': prefs.getDouble('print_margin_top') ?? 3.0, // Default 3 cm
      'bottom': prefs.getDouble('print_margin_bottom') ?? 3.0, // Default 3 cm
      'left': prefs.getDouble('print_margin_left') ?? 1.5, // Default 1.5 cm
      'right': prefs.getDouble('print_margin_right') ?? 0.8, // Default 0.8 cm
      'leftColumnWidth': prefs.getDouble('print_left_column_width') ?? 7.0, // Default 7 cm
      'pageWidth': prefs.getDouble('print_page_width') ?? 21.0, // Default A4 width (21 cm)
      'pageHeight': prefs.getDouble('print_page_height') ?? 29.7, // Default A4 height (29.7 cm)
    };
  }

  // Save margin settings
  static Future<void> saveMarginSettings(
    double top, 
    double bottom, {
    double? left,
    double? right,
    double? leftColumnWidth,
    double? pageWidth,
    double? pageHeight,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('print_margin_top', top);
    await prefs.setDouble('print_margin_bottom', bottom);
    if (left != null) await prefs.setDouble('print_margin_left', left);
    if (right != null) await prefs.setDouble('print_margin_right', right);
    if (leftColumnWidth != null) await prefs.setDouble('print_left_column_width', leftColumnWidth);
    if (pageWidth != null) await prefs.setDouble('print_page_width', pageWidth);
    if (pageHeight != null) await prefs.setDouble('print_page_height', pageHeight);
  }

  // Direct print - Opens native system print dialog immediately
  static Future<void> directPrint({
    required String patientName,
    required String age,
    required String date,
    required String patientId,
    String? phone,
    String? doctorName,
    String? registrationNumber,
    required List<String> chiefComplaints,
    required Map<String, dynamic> examination,
    required List<String> diagnosis,
    required List<String> investigation,
    required List<Medicine> medicines,
    required List<String> advice,
    required String? followUpDate,
    required String? referral,
    String? discountAmount,
  }) async {
    try {
      print('🖨️ Opening native print dialog...');
      print(' Generating PDF for direct print...');
      
      // Generate PDF bytes without opening file
      final pdfBytes = await generatePdfBytes(
        patientName: patientName,
        age: age,
        date: date,
        patientId: patientId,
        phone: phone,
        doctorName: doctorName,
        registrationNumber: registrationNumber,
        chiefComplaints: chiefComplaints,
        examination: examination,
        diagnosis: diagnosis,
        investigation: investigation,
        medicines: medicines,
        advice: advice,
        followUpDate: followUpDate,
        referral: referral,
        discountAmount: discountAmount,
      );
      
      // Open native print dialog directly (Windows/Mac/Linux)
      await Printing.layoutPdf(
        name: 'Prescription_${patientName.replaceAll(' ', '_')}_$date.pdf',
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
      
      print('✅ Native print dialog opened successfully');
    } catch (e) {
      print('❌ Error opening print dialog: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Generate PDF bytes in memory without saving file (for direct printing)
  static Future<Uint8List> generatePdfBytes({
    required String patientName,
    required String age,
    required String date,
    required String patientId,
    String? phone,
    String? doctorName,
    String? registrationNumber,
    required List<String> chiefComplaints,
    required Map<String, dynamic> examination,
    required List<String> diagnosis,
    required List<String> investigation,
    required List<Medicine> medicines,
    required List<String> advice,
    required String? followUpDate,
    required String? referral,
    String? discountAmount,
  }) async {
    // Initialize Bangla fonts
    await _initializeBanglaFonts();
    
    final margins = await getMarginSettings();
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
              // Patient Info
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
              // Two-column layout
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    pw.SizedBox(
                      width: margins['leftColumnWidth']! * PdfPageFormat.cm,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (chiefComplaints.isNotEmpty) ...[
                            _getTextWidget('Chief Complaint', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...chiefComplaints.map((complaint) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- $complaint', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],
                          if (examination.isNotEmpty) ...[
                            _getTextWidget('On Examinations', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...examination.entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- ${entry.key}: ${entry.value}', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],
                          if (diagnosis.isNotEmpty) ...[
                            _getTextWidget('Diagnosis', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...diagnosis.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- $item', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],
                          if (investigation.isNotEmpty) ...[
                            _getTextWidget('Investigation', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...investigation.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: _getTextWidget('- $item', fontSize: 9),
                            )),
                          ],
                          if (discountAmount != null && discountAmount.isNotEmpty) ...[
                            pw.SizedBox(height: 8),
                            _getTextWidget('Please give $discountAmount% discount', fontSize: 9),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Container(width: 1, height: double.infinity, color: PdfColors.grey800),
                    pw.SizedBox(width: 8),
                    // Right Column - Medicines
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _getTextWidget('Rx,', fontSize: 12, fontWeight: pw.FontWeight.bold),
                          pw.SizedBox(height: 10),
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
                                        _getTextWidget('${medicine.type} ${medicine.name}', fontSize: 9, fontWeight: pw.FontWeight.bold),
                                        if ((isInj || isSpray) && medicine.quantity.isNotEmpty && medicine.frequency.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: _getTextWidget(
                                              isInj && medicine.route.isNotEmpty ? '${medicine.quantity} x ${medicine.frequency} (Route: ${medicine.route})' : '${medicine.quantity} x ${medicine.frequency}',
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
                                  // Duration column - always present with fixed width
                                  pw.Container(
                                    width: 80,
                                    alignment: pw.Alignment.center,
                                    padding: const pw.EdgeInsets.only(left: 10),
                                    child: medicine.duration.isNotEmpty
                                        ? _getTextWidget(
                                            '${medicine.duration}${medicine.interval.isNotEmpty ? " (${medicine.interval})" : ""}${medicine.tillNumber == "চলবে" || medicine.tillNumber == "Continues" ? " - চলবে" : medicine.tillNumber.isNotEmpty ? " - ${medicine.tillNumber} ${medicine.tillUnit}" : ""}',
                                            fontSize: 8,
                                            textAlign: pw.TextAlign.center,
                                          )
                                        : pw.SizedBox.shrink(),
                                  ),
                                  // Advice column - always present with fixed width
                                  pw.Container(
                                    width: 60,
                                    padding: const pw.EdgeInsets.only(left: 10),
                                    child: medicine.advice.isNotEmpty
                                        ? _getWrappedTextWidget(medicine.advice, 60, fontSize: 8, textAlign: pw.TextAlign.left)
                                        : pw.SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 15),
                          if (advice.isNotEmpty) ...[
                            _getTextWidget('Advices', fontSize: 10, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...advice.asMap().entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: _getTextWidget('${entry.key + 1}. ${entry.value}', fontSize: 8),
                            )),
                            pw.SizedBox(height: 10),
                          ],
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
    
    // Return PDF bytes (in memory, no file saved)
    return pdf.save();
  }

  static Future<String> printPrescription({
    required String patientName,
    required String age,
    required String date,
    required String patientId,
    String? phone,
    String? doctorName,
    String? registrationNumber,
    required List<String> chiefComplaints,
    required Map<String, dynamic> examination,
    required List<String> diagnosis,
    required List<String> investigation,
    required List<Medicine> medicines,
    required List<String> advice,
    required String? followUpDate,
    required String? referral,
    String? discountAmount,
  }) async {
    // Initialize Bangla fonts
    await _initializeBanglaFonts();
    
    final margins = await getMarginSettings();
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
                    if (discountAmount != null && discountAmount.isNotEmpty) ...[
                      pw.SizedBox(height: 8),
                      _getTextWidget('Please give $discountAmount% discount', fontSize: 9),
                    ],
                  ],
                ),
              ),

              // Spacing before separator
              pw.SizedBox(width: 8),

              // Vertical Divider
              pw.Container(
                width: 1,
                height: double.infinity,
                color: PdfColors.grey800,
              ),

              // Spacing after separator
              pw.SizedBox(width: 8),

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
                            // Duration column - always present with fixed width
                            pw.Container(
                              width: 80,
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.only(left: 10),
                              child: medicine.duration.isNotEmpty
                                  ? _getTextWidget(
                                      '${medicine.duration}${medicine.interval.isNotEmpty ? " (${medicine.interval})" : ""}${medicine.tillNumber == "চলবে" || medicine.tillNumber == "Continues" ? " - চলবে" : medicine.tillNumber.isNotEmpty ? " - ${medicine.tillNumber} ${medicine.tillUnit}" : ""}',
                                      fontSize: 8,
                                      textAlign: pw.TextAlign.center,
                                    )
                                  : pw.SizedBox.shrink(),
                            ),
                            // Advice column - always present with fixed width
                            pw.Container(
                              width: 60,
                              padding: const pw.EdgeInsets.only(left: 10),
                              child: medicine.advice.isNotEmpty
                                  ? _getWrappedTextWidget(
                                      medicine.advice,
                                      60,
                                      fontSize: 8,
                                      textAlign: pw.TextAlign.left,
                                    )
                                  : pw.SizedBox.shrink(),
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

    // Save PDF to bytes
    final pdfBytes = await pdf.save();

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/prescription_$timestamp.pdf');
    await tempFile.writeAsBytes(pdfBytes);

    // Open with system default PDF viewer (which has print option)
    await OpenFile.open(tempFile.path);
    
    return tempFile.path;
  }

  // Save prescription permanently
  static Future<String?> savePrescription({
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
    String? discountAmount,
  }) async {
    // Initialize Bangla fonts
    await _initializeBanglaFonts();
    
    final margins = await getMarginSettings();
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
                    if (discountAmount != null && discountAmount.isNotEmpty) ...[
                      pw.SizedBox(height: 8),
                      _getTextWidget('Please give $discountAmount% discount', fontSize: 9),
                    ],
                  ],
                ),
              ),

              // Spacing before separator
              pw.SizedBox(width: 8),

              // Vertical Divider
              pw.Container(
                width: 1,
                height: double.infinity,
                color: PdfColors.grey800,
              ),

              // Spacing after separator
              pw.SizedBox(width: 8),

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
                            // Duration column - always present with fixed width
                            pw.Container(
                              width: 80,
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.only(left: 10),
                              child: medicine.duration.isNotEmpty
                                  ? _getTextWidget(
                                      '${medicine.duration}${medicine.interval.isNotEmpty ? " (${medicine.interval})" : ""}${medicine.tillNumber == "চলবে" || medicine.tillNumber == "Continues" ? " - চলবে" : medicine.tillNumber.isNotEmpty ? " - ${medicine.tillNumber} ${medicine.tillUnit}" : ""}',
                                      fontSize: 8,
                                      textAlign: pw.TextAlign.center,
                                    )
                                  : pw.SizedBox.shrink(),
                            ),
                            // Advice column - always present with fixed width
                            pw.Container(
                              width: 60,
                              padding: const pw.EdgeInsets.only(left: 10),
                              child: medicine.advice.isNotEmpty
                                  ? _getWrappedTextWidget(
                                      medicine.advice,
                                      60,
                                      fontSize: 8,
                                      textAlign: pw.TextAlign.left,
                                    )
                                  : pw.SizedBox.shrink(),
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

    // Save PDF to bytes
    final pdfBytes = await pdf.save();

    // Get documents directory
    final documentsDir = await getApplicationDocumentsDirectory();
    final prescriptionsDir = Directory('${documentsDir.path}/Prescriptions');
    
    // Create directory if it doesn't exist
    if (!await prescriptionsDir.exists()) {
      await prescriptionsDir.create(recursive: true);
    }

    // Save file with patient name and date
    final fileName = '${patientName.replaceAll(' ', '_')}_${date.replaceAll('/', '-')}.pdf';
    final file = File('${prescriptionsDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    return file.path;
  }
}
