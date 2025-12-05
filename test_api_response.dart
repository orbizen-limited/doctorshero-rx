import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking API Response Structure\n');
  
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    final request = await client.postUrl(
      Uri.parse('https://doctorshero.com/api/mobile/auth/login')
    ).timeout(Duration(seconds: 10));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final body = jsonEncode({
      'login': 'dr.helal.uddin@gmail.com',
      'password': 'Helal@2025',
      'device_name': 'Test Script',
      'device_type': 'desktop',
    });
    
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);
    
    print('📦 Full API Response:');
    print(JsonEncoder.withIndent('  ').convert(data));
    
    if (data['user'] != null) {
      print('\n👤 User Object:');
      print(JsonEncoder.withIndent('  ').convert(data['user']));
      
      print('\n🔍 Checking for null values:');
      data['user'].forEach((key, value) {
        if (value == null) {
          print('  ⚠️  $key: null');
        } else {
          print('  ✅ $key: ${value.runtimeType}');
        }
      });
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  exit(0);
}
