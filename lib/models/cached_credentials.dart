import 'package:hive/hive.dart';

part 'cached_credentials.g.dart';

@HiveType(typeId: 4) // Unique typeId for Hive
class CachedCredentials extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String passwordHash; // bcrypt hash

  @HiveField(2)
  String? token; // Auth token for offline sessions

  @HiveField(3)
  Map<String, dynamic>? userData; // Cached user profile

  @HiveField(4)
  DateTime lastOnlineLogin; // Last successful online login

  @HiveField(5)
  DateTime lastOfflineLogin; // Last offline login attempt

  @HiveField(6)
  int offlineLoginCount; // Track offline login attempts

  @HiveField(7)
  bool biometricEnabled; // Whether biometric is enabled

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  CachedCredentials({
    required this.email,
    required this.passwordHash,
    this.token,
    this.userData,
    required this.lastOnlineLogin,
    required this.lastOfflineLogin,
    this.offlineLoginCount = 0,
    this.biometricEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if credentials are expired (e.g., 30 days offline)
  bool isExpired({int maxOfflineDays = 30}) {
    final daysSinceOnline = DateTime.now().difference(lastOnlineLogin).inDays;
    return daysSinceOnline > maxOfflineDays;
  }

  // Check if too many offline logins (security measure)
  bool tooManyOfflineLogins({int maxAttempts = 100}) {
    return offlineLoginCount > maxAttempts;
  }

  // Update last offline login
  void recordOfflineLogin() {
    lastOfflineLogin = DateTime.now();
    offlineLoginCount++;
    updatedAt = DateTime.now();
    save(); // Save to Hive
  }

  // Reset offline counter after successful online login
  void resetOfflineCounter() {
    lastOnlineLogin = DateTime.now();
    offlineLoginCount = 0;
    updatedAt = DateTime.now();
    save();
  }

  // Update token and user data
  void updateSession({String? newToken, Map<String, dynamic>? newUserData}) {
    if (newToken != null) token = newToken;
    if (newUserData != null) userData = newUserData;
    updatedAt = DateTime.now();
    save();
  }
}
