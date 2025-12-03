import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cached_credentials.dart';

class OfflineAuthService {
  static const String _boxName = 'cached_credentials';
  static const String _encryptionKeyName = 'hive_encryption_key';
  static const int _bcryptCost = 12; // Same as PHP password_hash default
  static const int _maxOfflineDays = 30; // Auto-logout after 30 days offline
  static const int _maxOfflineLogins = 100; // Max offline logins before requiring online

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Get or create encryption key for Hive
  // Using SharedPreferences instead of FlutterSecureStorage for macOS compatibility
  Future<List<int>> _getEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString(_encryptionKeyName);
    
    if (keyString == null) {
      // Generate new 256-bit encryption key
      final key = Hive.generateSecureKey();
      keyString = base64Encode(key);
      await prefs.setString(_encryptionKeyName, keyString);
      return key;
    }
    
    return base64Decode(keyString);
  }

  // Initialize Hive box with encryption
  Future<Box<CachedCredentials>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<CachedCredentials>(_boxName);
    }

    final encryptionKey = await _getEncryptionKey();
    return await Hive.openBox<CachedCredentials>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  // Cache credentials after successful online login
  Future<void> cacheCredentials({
    required String email,
    required String password,
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final box = await _openBox();
      
      // Hash password using bcrypt (same as PHP password_hash)
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: _bcryptCost));
      
      final now = DateTime.now();
      final credentials = CachedCredentials(
        email: email.toLowerCase().trim(),
        passwordHash: passwordHash,
        token: token,
        userData: userData,
        lastOnlineLogin: now,
        lastOfflineLogin: now,
        offlineLoginCount: 0,
        biometricEnabled: false,
        createdAt: now,
        updatedAt: now,
      );

      // Store with email as key (only one account per device)
      await box.put(email.toLowerCase().trim(), credentials);
      
      print('✅ Credentials cached securely for offline login');
    } catch (e) {
      print('❌ Error caching credentials: $e');
      rethrow;
    }
  }

  // Verify offline login
  Future<Map<String, dynamic>?> verifyOfflineLogin({
    required String email,
    required String password,
  }) async {
    try {
      final box = await _openBox();
      final credentials = box.get(email.toLowerCase().trim());

      if (credentials == null) {
        return {
          'success': false,
          'message': 'No cached credentials found. Please login online first.',
          'requiresOnline': true,
        };
      }

      // Check if credentials are expired
      if (credentials.isExpired(maxOfflineDays: _maxOfflineDays)) {
        return {
          'success': false,
          'message': 'Offline session expired. Please login online to continue.',
          'requiresOnline': true,
        };
      }

      // Check if too many offline logins
      if (credentials.tooManyOfflineLogins(maxAttempts: _maxOfflineLogins)) {
        return {
          'success': false,
          'message': 'Too many offline logins. Please login online to verify your account.',
          'requiresOnline': true,
        };
      }

      // Verify password using bcrypt
      final passwordMatches = BCrypt.checkpw(password, credentials.passwordHash);

      if (!passwordMatches) {
        return {
          'success': false,
          'message': 'Invalid password',
          'requiresOnline': false,
        };
      }

      // Record offline login
      credentials.recordOfflineLogin();

      // Return cached user data
      return {
        'success': true,
        'message': 'Offline login successful',
        'user': credentials.userData,
        'token': credentials.token,
        'isOffline': true,
        'daysSinceOnline': DateTime.now().difference(credentials.lastOnlineLogin).inDays,
        'offlineLoginCount': credentials.offlineLoginCount,
      };
    } catch (e) {
      print('❌ Error verifying offline login: $e');
      return {
        'success': false,
        'message': 'Offline login error: $e',
        'requiresOnline': false,
      };
    }
  }

  // Update cached credentials after online login
  Future<void> updateCachedCredentials({
    required String email,
    String? newPassword,
    String? newToken,
    Map<String, dynamic>? newUserData,
  }) async {
    try {
      final box = await _openBox();
      final credentials = box.get(email.toLowerCase().trim());

      if (credentials == null) return;

      // Update password hash if password changed
      if (newPassword != null) {
        credentials.passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(logRounds: _bcryptCost));
      }

      // Update session data
      credentials.updateSession(
        newToken: newToken,
        newUserData: newUserData,
      );

      // Reset offline counter
      credentials.resetOfflineCounter();

      print('✅ Cached credentials updated');
    } catch (e) {
      print('❌ Error updating cached credentials: $e');
    }
  }

  // Clear cached credentials (logout)
  Future<void> clearCachedCredentials(String email) async {
    try {
      final box = await _openBox();
      await box.delete(email.toLowerCase().trim());
      print('✅ Cached credentials cleared');
    } catch (e) {
      print('❌ Error clearing cached credentials: $e');
    }
  }

  // Check if biometric authentication is available
  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Enable biometric login
  Future<bool> enableBiometric(String email) async {
    try {
      final box = await _openBox();
      final credentials = box.get(email.toLowerCase().trim());

      if (credentials == null) return false;

      // Authenticate with biometric
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric login for DoctorsHero',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        credentials.biometricEnabled = true;
        credentials.updatedAt = DateTime.now();
        await credentials.save();
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error enabling biometric: $e');
      return false;
    }
  }

  // Disable biometric login
  Future<void> disableBiometric(String email) async {
    try {
      final box = await _openBox();
      final credentials = box.get(email.toLowerCase().trim());

      if (credentials != null) {
        credentials.biometricEnabled = false;
        credentials.updatedAt = DateTime.now();
        await credentials.save();
      }
    } catch (e) {
      print('❌ Error disabling biometric: $e');
    }
  }

  // Login with biometric
  Future<Map<String, dynamic>?> loginWithBiometric(String email) async {
    try {
      final box = await _openBox();
      final credentials = box.get(email.toLowerCase().trim());

      if (credentials == null || !credentials.biometricEnabled) {
        return {
          'success': false,
          'message': 'Biometric login not enabled',
        };
      }

      // Authenticate with biometric
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Login to DoctorsHero',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return {
          'success': false,
          'message': 'Biometric authentication failed',
        };
      }

      // Check expiration
      if (credentials.isExpired(maxOfflineDays: _maxOfflineDays)) {
        return {
          'success': false,
          'message': 'Session expired. Please login online.',
          'requiresOnline': true,
        };
      }

      // Record offline login
      credentials.recordOfflineLogin();

      return {
        'success': true,
        'message': 'Biometric login successful',
        'user': credentials.userData,
        'token': credentials.token,
        'isOffline': true,
      };
    } catch (e) {
      print('❌ Error with biometric login: $e');
      return {
        'success': false,
        'message': 'Biometric login error: $e',
      };
    }
  }

  // Get cached credentials info (for UI display)
  Future<Map<String, dynamic>?> getCachedCredentialsInfo(String email) async {
    try {
      final box = await _openBox();
      final credentials = box.get(email.toLowerCase().trim());

      if (credentials == null) return null;

      return {
        'email': credentials.email,
        'lastOnlineLogin': credentials.lastOnlineLogin.toIso8601String(),
        'lastOfflineLogin': credentials.lastOfflineLogin.toIso8601String(),
        'offlineLoginCount': credentials.offlineLoginCount,
        'biometricEnabled': credentials.biometricEnabled,
        'daysSinceOnline': DateTime.now().difference(credentials.lastOnlineLogin).inDays,
        'isExpired': credentials.isExpired(maxOfflineDays: _maxOfflineDays),
      };
    } catch (e) {
      return null;
    }
  }

  // Check if user has cached credentials
  Future<bool> hasCachedCredentials(String email) async {
    try {
      final box = await _openBox();
      return box.containsKey(email.toLowerCase().trim());
    } catch (e) {
      return false;
    }
  }

  // Get last logged in email (for auto-fill)
  Future<String?> getLastLoggedInEmail() async {
    try {
      final box = await _openBox();
      if (box.isEmpty) return null;

      // Find most recently used credentials
      CachedCredentials? latest;
      for (var credentials in box.values) {
        if (latest == null || credentials.lastOfflineLogin.isAfter(latest.lastOfflineLogin)) {
          latest = credentials;
        }
      }

      return latest?.email;
    } catch (e) {
      return null;
    }
  }
}
