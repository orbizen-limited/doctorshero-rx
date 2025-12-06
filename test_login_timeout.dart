import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing Login Timeout and Offline Behavior\n');
  
  // Test 1: Check if API is reachable
  print('📡 Test 1: Checking API connectivity...');
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    final request = await client.getUrl(Uri.parse('https://doctorshero.com'))
        .timeout(Duration(seconds: 5));
    final response = await request.close().timeout(Duration(seconds: 5));
    
    print('✅ API is reachable (Status: ${response.statusCode})');
  } catch (e) {
    print('❌ API not reachable: $e');
  }
  
  print('\n📡 Test 2: Testing login endpoint with timeout...');
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
    
    print('⏳ Waiting for response (10 second timeout)...');
    final response = await request.close().timeout(
      Duration(seconds: 10),
      onTimeout: () {
        print('⏰ Request timed out after 10 seconds');
        throw Exception('Connection timeout');
      },
    );
    
    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);
    
    print('✅ Response received (Status: ${response.statusCode})');
    print('📦 Response: ${jsonEncode(data)}');
    
    if (response.statusCode == 200) {
      print('✅ Login successful!');
    } else if (response.statusCode == 429) {
      print('⚠️  Rate limited or max sessions: ${data['message']}');
    } else {
      print('❌ Login failed: ${data['message']}');
    }
    
  } catch (e) {
    print('❌ Login request failed: $e');
    print('\n💡 This means offline login should be triggered');
  }
  
  print('\n✅ Test complete!');
  exit(0);
}
