import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/medicine_model.dart';

class PrescriptionHtmlService {
  // Cache for the loaded font
  static pw.Font? _cachedFont;
  
  // Load font that supports Bangla and special characters
  static Future<pw.Font> _loadBanglaFont() async {
    if (_cachedFont != null) return _cachedFont!;
    
    try {
      // Load Open Sans Regular as requested by user
      final fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
      _cachedFont = pw.Font.ttf(fontData);
      print('Loaded Open Sans Regular font successfully');
      return _cachedFont!;
    } catch (e) {
      print('Error loading Open Sans: $e');
      // Fallback to Noto Sans Bengali
      final fontData = await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf');
      _cachedFont = pw.Font.ttf(fontData);
      return _cachedFont!;
    }
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
    // Get margin settings
    final margins = await getMarginSettings();
    final banglaFont = await _loadBanglaFont();
    
    // Generate PDF instead of HTML
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: banglaFont,
        bold: banglaFont,
        italic: banglaFont,
        boldItalic: banglaFont,
      ),
    );

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
                  pw.Text('Name: $patientName', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Age: $age', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  if (phone != null && phone.isNotEmpty)
                    pw.Text('Phone: $phone', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: $date', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('ID: $patientId', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
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
                            pw.Text('Chief Complaint', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            ...chiefComplaints.map((complaint) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: pw.Text('- $complaint', style: const pw.TextStyle(fontSize: 9)),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // On Examinations
                          if (examination.isNotEmpty) ...[
                            pw.Text('On Examinations', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            ...examination.entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: pw.Text('- ${entry.key}: ${entry.value}', style: const pw.TextStyle(fontSize: 9)),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // Diagnosis
                          if (diagnosis.isNotEmpty) ...[
                            pw.Text('Diagnosis', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            ...diagnosis.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: pw.Text('- $item', style: const pw.TextStyle(fontSize: 9)),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // Investigation
                          if (investigation.isNotEmpty) ...[
                            pw.Text('Investigation', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            ...investigation.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: pw.Text('- $item', style: const pw.TextStyle(fontSize: 9)),
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
                          pw.Text('Rx,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
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
                                  pw.Text('$index. ', style: const pw.TextStyle(fontSize: 9)),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          '${medicine.type} ${medicine.name}',
                                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                        ),
                                        // Show quantity x frequency (Route) for Inj/Spray, or dosage for others
                                        if ((isInj || isSpray) && medicine.quantity.isNotEmpty && medicine.frequency.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: pw.Text(
                                              isInj && medicine.route.isNotEmpty
                                                  ? '${medicine.quantity} x ${medicine.frequency} (Route: ${medicine.route})'
                                                  : '${medicine.quantity} x ${medicine.frequency}',
                                              style: const pw.TextStyle(fontSize: 8),
                                            ),
                                          )
                                        else if (medicine.dosage.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: pw.Text(medicine.dosage, style: const pw.TextStyle(fontSize: 8)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (medicine.duration.isNotEmpty)
                                    pw.Container(
                                      width: 80,
                                      alignment: pw.Alignment.center,
                                      padding: const pw.EdgeInsets.only(left: 10),
                                      child: pw.Text(
                                        '${medicine.duration}${medicine.interval.isNotEmpty ? " (${medicine.interval})" : ""}${medicine.tillNumber == "চলবে" || medicine.tillNumber == "Continues" ? " - চলবে" : medicine.tillNumber.isNotEmpty ? " - ${medicine.tillNumber} ${medicine.tillUnit}" : ""}',
                                        style: const pw.TextStyle(fontSize: 8),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                  if (medicine.advice.isNotEmpty)
                                    pw.Container(
                                      width: 60,
                                      padding: const pw.EdgeInsets.only(left: 10),
                                      child: pw.Text(
                                        medicine.advice,
                                        style: const pw.TextStyle(fontSize: 8),
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
                            pw.Text('Advices', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            ...advice.asMap().entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Text('${entry.key + 1}. ${entry.value}', style: const pw.TextStyle(fontSize: 8)),
                            )),
                            pw.SizedBox(height: 10),
                          ],

                          // Follow-up and Referral
                          if (followUpDate != null || referral != null) ...[
                            pw.Row(
                              children: [
                                if (followUpDate != null) ...[
                                  pw.Text('Follow-up: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                  pw.Text(followUpDate, style: const pw.TextStyle(fontSize: 9)),
                                ],
                                if (followUpDate != null && referral != null) pw.SizedBox(width: 20),
                                if (referral != null) ...[
                                  pw.Text('Referral: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(child: pw.Text(referral, style: const pw.TextStyle(fontSize: 9))),
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
