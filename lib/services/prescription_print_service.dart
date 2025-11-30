import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import '../models/medicine_model.dart';

class PrescriptionPrintService {
  // Get margin settings from SharedPreferences
  static Future<Map<String, double>> getMarginSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'top': prefs.getDouble('print_margin_top') ?? 3.0, // Default 3 cm
      'bottom': prefs.getDouble('print_margin_bottom') ?? 3.0, // Default 3 cm
      'left': prefs.getDouble('print_margin_left') ?? 1.5, // Default 1.5 cm
      'right': prefs.getDouble('print_margin_right') ?? 0.8, // Default 0.8 cm
      'leftColumnWidth': prefs.getDouble('print_left_column_width') ?? 7.0, // Default 7 cm
    };
  }

  // Save margin settings
  static Future<void> saveMarginSettings(
    double top, 
    double bottom, {
    double? left,
    double? right,
    double? leftColumnWidth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('print_margin_top', top);
    await prefs.setDouble('print_margin_bottom', bottom);
    if (left != null) await prefs.setDouble('print_margin_left', left);
    if (right != null) await prefs.setDouble('print_margin_right', right);
    if (leftColumnWidth != null) await prefs.setDouble('print_left_column_width', leftColumnWidth);
  }

  static Future<String> printPrescription({
    required String patientName,
    required String age,
    required String date,
    required String patientId,
    required List<String> chiefComplaints,
    required Map<String, dynamic> examination,
    required List<String> diagnosis,
    required List<String> investigation,
    required List<Medicine> medicines,
    required List<String> advice,
    required String? followUpDate,
    required String? referral,
  }) async {
    final margins = await getMarginSettings();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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
              // Patient Info - Full width at top
              pw.Text('Name: $patientName    Age: $age    Date: $date    ID: $patientId', 
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
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
                        child: pw.Text('• $complaint', style: const pw.TextStyle(fontSize: 9)),
                      )),
                      pw.SizedBox(height: 12),
                    ],

                    // On Examinations
                    if (examination.isNotEmpty) ...[
                      pw.Text('On Examinations', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...examination.entries.map((entry) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text('• ${entry.key}: ${entry.value}', style: const pw.TextStyle(fontSize: 9)),
                      )),
                      pw.SizedBox(height: 12),
                    ],

                    // Diagnosis
                    if (diagnosis.isNotEmpty) ...[
                      pw.Text('Diagnosis', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...diagnosis.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text('• $item', style: const pw.TextStyle(fontSize: 9)),
                      )),
                      pw.SizedBox(height: 12),
                    ],

                    // Investigation
                    if (investigation.isNotEmpty) ...[
                      pw.Text('Investigation', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...investigation.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text('• $item', style: const pw.TextStyle(fontSize: 9)),
                      )),
                    ],
                  ],
                ),
              ),

              // Vertical Divider
              pw.Container(
                width: 1,
                height: double.infinity,
                margin: const pw.EdgeInsets.symmetric(horizontal: 15),
                color: PdfColors.grey400,
              ),

              // Right Column - Rx (Medicines)
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Rx,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),

                    // Medicines List
                    ...medicines.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final medicine = entry.value;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
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
                                  if (medicine.dosage.isNotEmpty)
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.only(top: 2),
                                      child: pw.Text(medicine.dosage, style: const pw.TextStyle(fontSize: 8)),
                                    ),
                                ],
                              ),
                            ),
                            if (medicine.duration.isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 10),
                                child: pw.Text(medicine.duration, style: const pw.TextStyle(fontSize: 8)),
                              ),
                            if (medicine.advice.isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 10),
                                child: pw.Text(medicine.advice, style: const pw.TextStyle(fontSize: 8)),
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
    required List<String> chiefComplaints,
    required Map<String, dynamic> examination,
    required List<String> diagnosis,
    required List<String> investigation,
    required List<Medicine> medicines,
    required List<String> advice,
    required String? followUpDate,
    required String? referral,
  }) async {
    final margins = await getMarginSettings();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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
              // Patient Info - Full width at top
              pw.Text('Name: $patientName    Age: $age    Date: $date    ID: $patientId', 
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
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
                        child: pw.Text('• $complaint', style: const pw.TextStyle(fontSize: 9)),
                      )),
                      pw.SizedBox(height: 12),
                    ],

                    // On Examinations
                    if (examination.isNotEmpty) ...[
                      pw.Text('On Examinations', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...examination.entries.map((entry) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text('• ${entry.key}: ${entry.value}', style: const pw.TextStyle(fontSize: 9)),
                      )),
                      pw.SizedBox(height: 12),
                    ],

                    // Diagnosis
                    if (diagnosis.isNotEmpty) ...[
                      pw.Text('Diagnosis', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...diagnosis.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text('• $item', style: const pw.TextStyle(fontSize: 9)),
                      )),
                      pw.SizedBox(height: 12),
                    ],

                    // Investigation
                    if (investigation.isNotEmpty) ...[
                      pw.Text('Investigation', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...investigation.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text('• $item', style: const pw.TextStyle(fontSize: 9)),
                      )),
                    ],
                  ],
                ),
              ),

              // Vertical Divider
              pw.Container(
                width: 1,
                height: double.infinity,
                margin: const pw.EdgeInsets.symmetric(horizontal: 15),
                color: PdfColors.grey400,
              ),

              // Right Column - Rx (Medicines)
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Rx,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),

                    // Medicines List
                    ...medicines.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final medicine = entry.value;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
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
                                  if (medicine.dosage.isNotEmpty)
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.only(top: 2),
                                      child: pw.Text(medicine.dosage, style: const pw.TextStyle(fontSize: 8)),
                                    ),
                                ],
                              ),
                            ),
                            if (medicine.duration.isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 10),
                                child: pw.Text(medicine.duration, style: const pw.TextStyle(fontSize: 8)),
                              ),
                            if (medicine.advice.isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 10),
                                child: pw.Text(medicine.advice, style: const pw.TextStyle(fontSize: 8)),
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
