import 'dart:convert';
import 'package:flutter/services.dart';

class MedicineData {
  final String dosageForm;
  final String medicineName;
  final String genericName;
  final String powerStrength;
  final String company;
  final String category;

  MedicineData({
    required this.dosageForm,
    required this.medicineName,
    required this.genericName,
    required this.powerStrength,
    required this.company,
    required this.category,
  });

  factory MedicineData.fromJson(Map<String, dynamic> json) {
    return MedicineData(
      dosageForm: json['dosage_form'] ?? '',
      medicineName: json['medicine_name'] ?? '',
      genericName: json['generic_name'] ?? '',
      powerStrength: json['power_strength'] ?? '',
      company: json['company'] ?? '',
      category: json['category'] ?? '',
    );
  }

  String get displayName {
    String name = '';
    if (dosageForm.isNotEmpty) {
      // Show only first 3 letters of dosage form (e.g., "Tab." -> "Tab")
      String shortForm = dosageForm.replaceAll('.', '').trim();
      if (shortForm.length > 3) {
        shortForm = shortForm.substring(0, 3);
      }
      name += '$shortForm ';
    }
    name += medicineName;
    if (powerStrength.isNotEmpty) {
      name += ' $powerStrength';
    }
    return name.trim();
  }
}

class MedicineDatabaseService {
  static List<MedicineData>? _medicines;
  
  static Future<void> loadDatabase() async {
    if (_medicines != null) return; // Already loaded
    
    try {
      final String jsonString = await rootBundle.loadString('medicine_db/medex_comprehensive_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _medicines = [];
      
      // Load from all categories
      if (jsonData.containsKey('generics_allopathic')) {
        final List<dynamic> generics = jsonData['generics_allopathic'];
        _medicines!.addAll(generics.map((item) => MedicineData.fromJson(item)));
      }
      
      // Add other categories if they exist in the JSON
      for (var key in jsonData.keys) {
        if (key != 'generics_allopathic' && jsonData[key] is List) {
          final List<dynamic> items = jsonData[key];
          _medicines!.addAll(items.map((item) => MedicineData.fromJson(item)));
        }
      }
      
      print('Loaded ${_medicines!.length} medicines from database');
    } catch (e) {
      print('Error loading medicine database: $e');
      _medicines = [];
    }
  }
  
  static List<MedicineData> getAllMedicines() {
    return _medicines ?? [];
  }
  
  static List<MedicineData> searchByMedicineName(String query) {
    if (_medicines == null || query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _medicines!.where((medicine) {
      // Only match if medicine name starts with the query
      return medicine.medicineName.toLowerCase().startsWith(lowerQuery);
    }).take(10).toList(); // Limit to 10 results
  }
  
  static List<MedicineData> searchByGenericName(String query) {
    if (_medicines == null || query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    
    // Get all matching medicines
    final matches = _medicines!.where((medicine) {
      // Only match if generic name starts with the query
      return medicine.genericName.toLowerCase().startsWith(lowerQuery);
    }).toList();
    
    // Sort: Renata PLC first, then others
    matches.sort((a, b) {
      final aIsRenata = a.company.toLowerCase().contains('renata');
      final bIsRenata = b.company.toLowerCase().contains('renata');
      
      if (aIsRenata && !bIsRenata) return -1; // a comes first
      if (!aIsRenata && bIsRenata) return 1;  // b comes first
      return 0; // keep original order
    });
    
    return matches.take(10).toList(); // Limit to 10 results
  }
  
  static List<MedicineData> searchUnified(String query) {
    if (_medicines == null || query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    
    // Get all matching medicines (both medicine name and generic name)
    final matches = _medicines!.where((medicine) {
      final medicineName = medicine.medicineName.toLowerCase();
      final genericName = medicine.genericName.toLowerCase();
      
      // Match if either medicine name or generic name contains query
      return medicineName.contains(lowerQuery) || genericName.contains(lowerQuery);
    }).toList();
    
    // Sort by relevance and sponsorship
    matches.sort((a, b) {
      final aIsRenata = a.company.toLowerCase().contains('renata');
      final bIsRenata = b.company.toLowerCase().contains('renata');
      
      final aMedicineStarts = a.medicineName.toLowerCase().startsWith(lowerQuery);
      final bMedicineStarts = b.medicineName.toLowerCase().startsWith(lowerQuery);
      final aGenericStarts = a.genericName.toLowerCase().startsWith(lowerQuery);
      final bGenericStarts = b.genericName.toLowerCase().startsWith(lowerQuery);
      
      // Priority 1: Medicine name starts with query + Renata
      if (aMedicineStarts && aIsRenata && !(bMedicineStarts && bIsRenata)) return -1;
      if (bMedicineStarts && bIsRenata && !(aMedicineStarts && aIsRenata)) return 1;
      
      // Priority 2: Medicine name starts with query
      if (aMedicineStarts && !bMedicineStarts) return -1;
      if (!aMedicineStarts && bMedicineStarts) return 1;
      
      // Priority 3: Generic name starts with query + Renata
      if (aGenericStarts && aIsRenata && !(bGenericStarts && bIsRenata)) return -1;
      if (bGenericStarts && bIsRenata && !(aGenericStarts && bIsRenata)) return 1;
      
      // Priority 4: Generic name starts with query
      if (aGenericStarts && !bGenericStarts) return -1;
      if (!aGenericStarts && bGenericStarts) return 1;
      
      // Priority 5: Renata medicines (contains match)
      if (aIsRenata && !bIsRenata) return -1;
      if (!aIsRenata && bIsRenata) return 1;
      
      return 0; // keep original order
    });
    
    return matches.take(20).toList(); // Limit to 20 results for unified search
  }
}
