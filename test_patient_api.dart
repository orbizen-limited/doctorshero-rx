import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing Patient API\n');
  print('=' * 60);
  
  // Test phone number from screenshot
  final testPhone = '01312399777';
  
  print('\n📞 Test 1: Search by Phone');
  print('Phone: $testPhone');
  print('─' * 60);
  
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    // Get token first (you'll need to login)
    print('Note: You need a valid token to test this.');
    print('Testing endpoint structure...\n');
    
    // Test different endpoint formats
    final endpoints = [
      'https://doctorshero.com/api/v1/patients?phone=$testPhone',
      'https://doctorshero.com/api/v1/patients/search?phone=$testPhone',
      'https://doctorshero.com/api/mobile/patients?phone=$testPhone',
    ];
    
    for (final endpoint in endpoints) {
      print('Testing: $endpoint');
      print('Expected: GET request with Authorization header');
      print('');
    }
    
    print('─' * 60);
    print('\n📝 Test 2: Create Patient');
    print('Endpoint: POST https://doctorshero.com/api/v1/patients');
    print('Body:');
    print(JsonEncoder.withIndent('  ').convert({
      'name': 'Test Patient',
      'phone': testPhone,
      'age': '25',
      'gender': 'Male',
      'force_create': false,
    }));
    
    print('\n─' * 60);
    print('\n✅ API Structure Analysis:');
    print('');
    print('Search Patients:');
    print('  GET /api/v1/patients?phone={phone}');
    print('  GET /api/v1/patients?name={name}');
    print('  GET /api/v1/patients?patient_id={pid}');
    print('  GET /api/v1/patients?search={query}');
    print('');
    print('Create Patient:');
    print('  POST /api/v1/patients');
    print('  Body: { name, phone, age, gender, force_create }');
    print('');
    print('Response on duplicate:');
    print('  {');
    print('    "success": false,');
    print('    "requires_confirmation": true,');
    print('    "similar_patients": [...]');
    print('  }');
    print('');
    print('Response on success:');
    print('  {');
    print('    "success": true,');
    print('    "data": { patient_id, name, phone, age, gender }');
    print('  }');
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  exit(0);
}
