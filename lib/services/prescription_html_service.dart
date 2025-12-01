import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/medicine_model.dart';

class PrescriptionHtmlService {
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
    
    // Generate HTML content
    final html = _generateHtmlContent(
      patientName: patientName,
      age: age,
      date: date,
      patientId: patientId,
      phone: phone,
      chiefComplaints: chiefComplaints,
      examination: examination,
      diagnosis: diagnosis,
      investigation: investigation,
      medicines: medicines,
      advice: advice,
      followUpDate: followUpDate,
      referral: referral,
      margins: margins,
    );

    // Save HTML to temp file and open it
    // The browser will render with perfect Bangla, then user can print to PDF from browser
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final htmlPath = '${directory.path}/prescription_$timestamp.html';
    final htmlFile = File(htmlPath);
    await htmlFile.writeAsString(html);

    // Open HTML in browser - user can print to PDF from there with perfect Bangla
    await OpenFile.open(htmlPath);
    
    return htmlPath;
  }

  static String _generateHtmlContent({
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
    required Map<String, double> margins,
  }) {
    // Build medicines HTML
    final medicinesHtml = StringBuffer();
    for (int i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
      final index = i + 1;
      
      medicinesHtml.write('<div class="medicine-item">');
      medicinesHtml.write('<div class="medicine-left">');
      medicinesHtml.write('<div class="medicine-name">$index. ${medicine.type} ${medicine.name}</div>');
      
      // Dosage
      if (medicine.dosage.isNotEmpty) {
        medicinesHtml.write('<div class="medicine-dosage">${medicine.dosage}</div>');
      }
      
      medicinesHtml.write('</div>');
      
      // Duration on the right
      medicinesHtml.write('<div class="medicine-right">');
      if (medicine.duration.isNotEmpty) {
        String durationText = medicine.duration;
        if (medicine.interval.isNotEmpty) {
          durationText += ' (${medicine.interval})';
        }
        if (medicine.tillNumber == 'চলবে' || medicine.tillNumber == 'Continues') {
          durationText += ' - চলবে';
        } else if (medicine.tillNumber.isNotEmpty) {
          durationText += ' - ${medicine.tillNumber} ${medicine.tillUnit}';
        }
        medicinesHtml.write('<div class="medicine-duration">$durationText</div>');
      }
      medicinesHtml.write('</div>');
      medicinesHtml.write('</div>');
    }

    // Build advice HTML
    final adviceHtml = StringBuffer();
    for (int i = 0; i < advice.length; i++) {
      adviceHtml.write('<div class="advice-item">${i + 1}. ${advice[i]}</div>');
    }

    return '''
<!DOCTYPE html>
<html lang="bn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prescription - $patientName</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;500;600&family=Open+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Open Sans', 'Noto Sans Bengali', sans-serif;
            font-size: 11pt;
            line-height: 1.4;
            color: #000;
            padding: ${margins['top']}cm ${margins['right']}cm ${margins['bottom']}cm ${margins['left']}cm;
        }
        
        @media print {
            @page {
                size: ${margins['pageWidth']}cm ${margins['pageHeight']}cm;
                margin: ${margins['top']}cm ${margins['right']}cm ${margins['bottom']}cm ${margins['left']}cm;
            }
            body {
                padding: 0;
            }
            .no-print {
                display: none;
            }
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #ddd;
        }
        
        .header-item {
            font-size: 10pt;
        }
        
        .header-item strong {
            font-weight: 600;
        }
        
        .section {
            margin-bottom: 15px;
        }
        
        .section-title {
            font-weight: 600;
            font-size: 11pt;
            margin-bottom: 8px;
        }
        
        .two-column {
            display: flex;
            gap: 30px;
        }
        
        .left-column {
            flex: 0 0 ${margins['leftColumnWidth']}cm;
            padding-right: 15px;
            border-right: 1px solid #ddd;
        }
        
        .right-column {
            flex: 1;
        }
        
        .list-item {
            margin-bottom: 3px;
            padding-left: 15px;
            position: relative;
        }
        
        .list-item:before {
            content: "•";
            position: absolute;
            left: 0;
        }
        
        .medicine-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 5px 0;
        }
        
        .medicine-left {
            flex: 1;
        }
        
        .medicine-right {
            flex: 0 0 auto;
            text-align: right;
            padding-left: 20px;
        }
        
        .medicine-name {
            font-weight: 500;
            margin-bottom: 3px;
        }
        
        .medicine-dosage {
            font-size: 9pt;
            color: #333;
            margin-left: 20px;
        }
        
        .medicine-duration {
            font-size: 9pt;
            color: #333;
            white-space: nowrap;
        }
        
        .advice-item {
            margin-bottom: 5px;
        }
        
        .rx-header {
            font-size: 14pt;
            font-weight: 600;
            margin-bottom: 15px;
        }
        
        .print-button {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 24px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14pt;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        
        .print-button:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <button class="print-button no-print" onclick="window.print()">🖨️ Print</button>
    
    <div class="header">
        <div class="header-item"><strong>Name:</strong> $patientName</div>
        <div class="header-item"><strong>Age:</strong> $age</div>
        ${phone != null && phone.isNotEmpty ? '<div class="header-item"><strong>Phone:</strong> $phone</div>' : ''}
        <div class="header-item"><strong>Date:</strong> $date</div>
        <div class="header-item"><strong>ID:</strong> $patientId</div>
    </div>
    
    <div class="two-column">
        <div class="left-column">
            ${chiefComplaints.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">Chief Complaint</div>
                ${chiefComplaints.map((c) => '<div class="list-item">$c</div>').join('')}
            </div>
            ''' : ''}
            
            ${examination.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">On Examinations</div>
                ${examination.entries.map((e) => '<div class="list-item">${e.key}: ${e.value}</div>').join('')}
            </div>
            ''' : ''}
            
            ${diagnosis.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">Diagnosis</div>
                ${diagnosis.map((d) => '<div class="list-item">$d</div>').join('')}
            </div>
            ''' : ''}
            
            ${investigation.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">Investigation</div>
                ${investigation.map((inv) => '<div class="list-item">$inv</div>').join('')}
            </div>
            ''' : ''}
        </div>
        
        <div class="right-column">
            <div class="rx-header">Rx,</div>
            
            ${medicines.isNotEmpty ? '''
            <div class="section">
                $medicinesHtml
            </div>
            ''' : ''}
            
            ${advice.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">Advices</div>
                $adviceHtml
            </div>
            ''' : ''}
            
            ${followUpDate != null && followUpDate.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">Follow-up: $followUpDate</div>
            </div>
            ''' : ''}
            
            ${referral != null && referral.isNotEmpty ? '''
            <div class="section">
                <div class="section-title">Referral</div>
                <div>$referral</div>
            </div>
            ''' : ''}
        </div>
    </div>
</body>
</html>
''';
  }
}
