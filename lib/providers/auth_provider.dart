import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/offline_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final OfflineAuthService _offlineAuthService = OfflineAuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;
  int? _daysSinceOnline;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isOfflineMode => _isOfflineMode;
  int? get daysSinceOnline => _daysSinceOnline;

  // Login - Hybrid online/offline
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isOfflineMode = false;
    _daysSinceOnline = null;
    notifyListeners();

    try {
      // Try online login first
      final response = await _apiService.login(email, password);
      _user = UserModel.fromJson(response['user']);
      
      // Cache credentials for offline use
      await _offlineAuthService.cacheCredentials(
        email: email,
        password: password,
        token: response['token'],
        userData: response['user'],
      );
      
      _isLoading = false;
      _isOfflineMode = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Online login failed - try offline login
      print('⚠️ Online login failed, attempting offline login...');
      
      final offlineResult = await _offlineAuthService.verifyOfflineLogin(
        email: email,
        password: password,
      );
      
      if (offlineResult != null && offlineResult['success'] == true) {
        // Offline login successful
        _user = UserModel.fromJson(offlineResult['user']);
        _isOfflineMode = true;
        _daysSinceOnline = offlineResult['daysSinceOnline'];
        _isLoading = false;
        notifyListeners();
        
        print('✅ Offline login successful (${_daysSinceOnline} days since online)');
        return true;
      } else {
        // Both online and offline login failed
        _errorMessage = offlineResult?['message'] ?? e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }
  }

  // Load user profile
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final email = _user?.email;
    
    await _apiService.logout();
    
    // Clear cached credentials
    if (email != null) {
      await _offlineAuthService.clearCachedCredentials(email);
    }
    
    _user = null;
    _errorMessage = null;
    _isOfflineMode = false;
    _daysSinceOnline = null;
    notifyListeners();
  }

  // Check if authenticated
  Future<bool> checkAuth() async {
    return await _apiService.isAuthenticated();
  }

  // Initialize - check for existing session
  Future<bool> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if token exists and is valid
      final token = await _apiService.getToken();
      if (token != null && token.isNotEmpty) {
        // Try to load user profile with existing token
        _user = await _apiService.getCurrentUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Token invalid or expired, clear it
      await _apiService.clearToken();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Biometric authentication methods
  Future<bool> canUseBiometric() async {
    return await _offlineAuthService.canUseBiometric();
  }

  Future<bool> enableBiometric() async {
    if (_user?.email == null) return false;
    return await _offlineAuthService.enableBiometric(_user!.email!);
  }

  Future<void> disableBiometric() async {
    if (_user?.email != null) {
      await _offlineAuthService.disableBiometric(_user!.email!);
    }
  }

  Future<bool> loginWithBiometric(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _offlineAuthService.loginWithBiometric(email);

    if (result != null && result['success'] == true) {
      _user = UserModel.fromJson(result['user']);
      _isOfflineMode = result['isOffline'] ?? false;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result?['message'] ?? 'Biometric login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get offline credentials info
  Future<Map<String, dynamic>?> getOfflineCredentialsInfo() async {
    if (_user?.email == null) return null;
    return await _offlineAuthService.getCachedCredentialsInfo(_user!.email!);
  }

  // Check if user has cached credentials
  Future<bool> hasCachedCredentials(String email) async {
    return await _offlineAuthService.hasCachedCredentials(email);
  }

  // Get last logged in email
  Future<String?> getLastLoggedInEmail() async {
    return await _offlineAuthService.getLastLoggedInEmail();
  }
}
