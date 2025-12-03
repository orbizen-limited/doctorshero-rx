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
                  BanglaText('Name: ${patientName.fix}', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  BanglaText('Age: ${age.fix}', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  if (phone != null && phone.isNotEmpty)
                    BanglaText('Phone: ${phone.fix}', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  BanglaText('Date: ${date.fix}', fontSize: 9, fontWeight: pw.FontWeight.bold),
                  BanglaText('ID: ${patientId.fix}', fontSize: 9, fontWeight: pw.FontWeight.bold),
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
                            BanglaText('Chief Complaint', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...chiefComplaints.map((complaint) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: BanglaText('- ${complaint.fix}', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // On Examinations
                          if (examination.isNotEmpty) ...[
                            BanglaText('On Examinations', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...examination.entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: BanglaText('- ${entry.key.fix}: ${entry.value.fix}', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // Diagnosis
                          if (diagnosis.isNotEmpty) ...[
                            BanglaText('Diagnosis', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...diagnosis.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: BanglaText('- ${item.fix}', fontSize: 9),
                            )),
                            pw.SizedBox(height: 12),
                          ],

                          // Investigation
                          if (investigation.isNotEmpty) ...[
                            BanglaText('Investigation', fontSize: 11, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...investigation.map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                              child: BanglaText('- ${item.fix}', fontSize: 9),
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
                          BanglaText('Rx,', fontSize: 12, fontWeight: pw.FontWeight.bold),
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
                                  BanglaText('$index. ', fontSize: 9),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        BanglaText(
                                          '${medicine.type.fix} ${medicine.name.fix}',
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        // Show quantity x frequency (Route) for Inj/Spray, or dosage for others
                                        if ((isInj || isSpray) && medicine.quantity.isNotEmpty && medicine.frequency.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: BanglaText(
                                              isInj && medicine.route.isNotEmpty
                                                  ? '${medicine.quantity.fix} x ${medicine.frequency.fix} (Route: ${medicine.route.fix})'
                                                  : '${medicine.quantity.fix} x ${medicine.frequency.fix}',
                                              fontSize: 8,
                                            ),
                                          )
                                        else if (medicine.dosage.isNotEmpty)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(top: 2),
                                            child: BanglaText(medicine.dosage.fix, fontSize: 8),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (medicine.duration.isNotEmpty)
                                    pw.Container(
                                      width: 80,
                                      alignment: pw.Alignment.center,
                                      padding: const pw.EdgeInsets.only(left: 10),
                                      child: BanglaText(
                                        '${medicine.duration.fix}${medicine.interval.isNotEmpty ? " (${medicine.interval.fix})" : ""}${medicine.tillNumber == "চলবে" || medicine.tillNumber == "Continues" ? " - চলবে" : medicine.tillNumber.isNotEmpty ? " - ${medicine.tillNumber.fix} ${medicine.tillUnit.fix}" : ""}',
                                        fontSize: 8,
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                  if (medicine.advice.isNotEmpty)
                                    pw.Container(
                                      width: 60,
                                      padding: const pw.EdgeInsets.only(left: 10),
                                      child: BanglaText(
                                        medicine.advice.fix,
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
                            BanglaText('Advices', fontSize: 10, fontWeight: pw.FontWeight.bold),
                            pw.SizedBox(height: 5),
                            ...advice.asMap().entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: BanglaText('${entry.key + 1}. ${entry.value.fix}', fontSize: 8),
                            )),
                            pw.SizedBox(height: 10),
                          ],

                          // Follow-up and Referral
                          if (followUpDate != null || referral != null) ...[
                            pw.Row(
                              children: [
                                if (followUpDate != null) ...[
                                  BanglaText('Follow-up: ', fontSize: 9, fontWeight: pw.FontWeight.bold),
                                  BanglaText(followUpDate.fix, fontSize: 9),
                                ],
                                if (followUpDate != null && referral != null) pw.SizedBox(width: 20),
                                if (referral != null) ...[
                                  BanglaText('Referral: ', fontSize: 9, fontWeight: pw.FontWeight.bold),
                                  pw.Expanded(child: BanglaText(referral.fix, fontSize: 9)),
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
