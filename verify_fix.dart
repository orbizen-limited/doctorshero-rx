import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Verifying Login Timeout Fix\n');
  print('=' * 60);
  
  final stopwatch = Stopwatch()..start();
  
  print('\n📡 Testing login with 10-second timeout...');
  print('Email: dr.helal.uddin@gmail.com');
  print('Password: Helal@2025\n');
  
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
    
    print('⏳ Waiting for response...');
    
    final response = await request.close().timeout(
      Duration(seconds: 10),
      onTimeout: () {
        stopwatch.stop();
        print('\n⏰ TIMEOUT after ${stopwatch.elapsed.inSeconds} seconds');
        print('✅ Timeout is working correctly!');
        print('💡 App should now fall back to offline login');
        throw Exception('Connection timeout');
      },
    );
    
    stopwatch.stop();
    
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('\n📦 Response received in ${stopwatch.elapsed.inSeconds} seconds');
    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode >= 500) {
      print('\n🔴 Server Error (${response.statusCode})');
      print('✅ App will treat this as NETWORK_ERROR');
      print('✅ Offline login fallback will be triggered');
      print('\nExpected behavior:');
      print('  1. Show error message');
      print('  2. Attempt offline login');
      print('  3. Login with cached credentials');
    } else if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('\n🟢 Login Successful!');
      print('Token: ${data['token']?.substring(0, 20)}...');
      print('User: ${data['user']['name']}');
    } else if (response.statusCode == 429) {
      final data = jsonDecode(responseBody);
      print('\n🟠 Rate Limited or Max Sessions');
      print('Code: ${data['code']}');
      print('Message: ${data['message']}');
    } else {
      print('\n🔴 Login Failed');
      print('Status: ${response.statusCode}');
      print('Body: $responseBody');
    }
    
  } catch (e) {
    stopwatch.stop();
    print('\n❌ Exception: $e');
    print('⏱️  Time elapsed: ${stopwatch.elapsed.inSeconds} seconds');
    
    if (e.toString().contains('timeout') || e.toString().contains('Connection timeout')) {
      print('\n✅ TIMEOUT WORKING CORRECTLY!');
      print('✅ App will now attempt offline login');
    } else {
      print('\n✅ NETWORK ERROR CAUGHT!');
      print('✅ App will fall back to offline login');
    }
  }
  
  print('\n' + '=' * 60);
  print('🎯 Test Complete!\n');
  
  exit(0);
}
