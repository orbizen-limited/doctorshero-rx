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
  String? _errorCode;
  bool _isOfflineMode = false;
  int? _daysSinceOnline;
  int? _activeSessions;
  int? _maxSessions;
  String? _cooldownUntil;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get isAuthenticated => _user != null;
  bool get isOfflineMode => _isOfflineMode;
  int? get daysSinceOnline => _daysSinceOnline;
  int? get activeSessions => _activeSessions;
  int? get maxSessions => _maxSessions;
  String? get cooldownUntil => _cooldownUntil;

  // Login - Hybrid online/offline
  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    _isOfflineMode = false;
    _daysSinceOnline = null;
    _activeSessions = null;
    _maxSessions = null;
    _cooldownUntil = null;
    notifyListeners();

    // Try online login first
    final response = await _apiService.login(login, password);
    
    if (response['success'] == true) {
      // Online login successful
      _user = UserModel.fromJson(response['user']);
      _activeSessions = response['active_sessions'];
      _maxSessions = response['max_sessions'];
      
      // Cache credentials for offline use
      await _offlineAuthService.cacheCredentials(
        email: _user!.email,
        password: password,
        token: response['token'],
        userData: response['user'],
      );
      
      _isLoading = false;
      _isOfflineMode = false;
      notifyListeners();
      return true;
    } else {
      // Online login failed - check error code
      _errorCode = response['code'];
      _errorMessage = response['message'];
      _activeSessions = response['active_sessions'];
      _maxSessions = response['max_sessions'];
      _cooldownUntil = response['cooldown_until'];
      
      // If network error, try offline login
      if (_errorCode == 'NETWORK_ERROR') {
        print('⚠️ Network error, attempting offline login...');
        
        final offlineResult = await _offlineAuthService.verifyOfflineLogin(
          email: login,
          password: password,
        );
        
        if (offlineResult != null && offlineResult['success'] == true) {
          // Offline login successful
          _user = UserModel.fromJson(offlineResult['user']);
          _isOfflineMode = true;
          _daysSinceOnline = offlineResult['daysSinceOnline'];
          _errorMessage = null;
          _errorCode = null;
          _isLoading = false;
          notifyListeners();
          
          print('✅ Offline login successful (${_daysSinceOnline} days since online)');
          return true;
        }
      }
      
      // Login failed
      _isLoading = false;
      notifyListeners();
      return false;
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
    await _apiService.logout();
    
    // DON'T clear cached credentials - keep them for offline login
    // User can still login offline after logout
    
    _user = null;
    _errorMessage = null;
    _errorCode = null;
    _isOfflineMode = false;
    _daysSinceOnline = null;
    _activeSessions = null;
    _maxSessions = null;
    _cooldownUntil = null;
    notifyListeners();
  }
  
  // Logout from all devices
  Future<void> logoutAll() async {
    await _apiService.logoutAll();
    
    _user = null;
    _errorMessage = null;
    _errorCode = null;
    _isOfflineMode = false;
    _daysSinceOnline = null;
    _activeSessions = null;
    _maxSessions = null;
    _cooldownUntil = null;
    notifyListeners();
  }
  
  // Force clear credentials (for security/privacy)
  Future<void> logoutAndClearCache() async {
    final email = _user?.email;
    
    await _apiService.logout();
    
    // Clear cached credentials completely
    if (email != null) {
      await _offlineAuthService.clearCachedCredentials(email);
    }
    
    _user = null;
    _errorMessage = null;
    _errorCode = null;
    _isOfflineMode = false;
    _daysSinceOnline = null;
    _activeSessions = null;
    _maxSessions = null;
    _cooldownUntil = null;
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

  // Get active sessions
  Future<Map<String, dynamic>?> getActiveSessions() async {
    return await _apiService.getActiveSessions();
  }
  
  // Revoke specific session
  Future<bool> revokeSession(int sessionId) async {
    return await _apiService.revokeSession(sessionId);
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    _cooldownUntil = null;
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
