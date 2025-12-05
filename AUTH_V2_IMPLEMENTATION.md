# 🔐 Authentication v2 Implementation Guide

**Version:** 2.0  
**Last Updated:** December 5, 2025  
**Status:** ✅ IMPLEMENTED

---

## 📋 Overview

The new Authentication v2 system provides enhanced security and flexibility with:

- ✅ **Multi-Method Login**: Email, Username, or Phone
- ✅ **OTP Verification**: SMS-based two-factor authentication
- ✅ **Session Management**: Max 4 active sessions per doctor
- ✅ **Rate Limiting**: 5 failed attempts = 10 minute cooldown
- ✅ **Device Management**: View and revoke sessions from any device

---

## 🌐 API Changes

### Base URL Update
```
OLD: https://demo.doctorshero.com
NEW: https://doctorshero.com
```

### Endpoints

#### v2 Authentication (Recommended)
```
POST   /api/mobile/auth/v2/login           - Login with email/username/phone
POST   /api/mobile/auth/v2/request-otp     - Request OTP for verification
POST   /api/mobile/auth/v2/verify-otp      - Verify OTP and complete login
GET    /api/mobile/auth/v2/sessions        - Get all active sessions
DELETE /api/mobile/auth/v2/sessions/{id}   - Revoke specific session
POST   /api/mobile/auth/v2/logout          - Logout from current device
POST   /api/mobile/auth/v2/logout-all      - Logout from all devices
```

#### v1 Authentication (Legacy - Still Supported)
```
POST   /api/mobile/auth/login              - Login with email only
POST   /api/mobile/auth/logout             - Logout
POST   /api/mobile/auth/logout-all         - Logout all devices
GET    /api/mobile/auth/me                 - Get current user
GET    /api/mobile/auth/check              - Check auth status
```

---

## 📁 New Files Created

### 1. Services
- **`lib/services/auth_v2_service.dart`** - Complete v2 authentication service
  - `loginV2()` - Multi-method login
  - `requestOTP()` - Request SMS OTP
  - `verifyOTP()` - Verify OTP code
  - `getActiveSessions()` - Fetch all sessions
  - `revokeSession()` - Revoke specific session
  - `logout()` - Logout current device
  - `logoutAll()` - Logout all devices

### 2. Models
- **`lib/models/session_model.dart`** - Session data model
  - Properties: id, device, lastUsed, createdAt, isCurrent
  - Helpers: formattedLastUsed, deviceIcon

### 3. Screens
- **`lib/screens/session_management_screen.dart`** - Manage active sessions
  - View all active sessions
  - Revoke individual sessions
  - Logout from all devices
  - Session count indicator

### 4. Widgets
- **`lib/widgets/max_sessions_dialog.dart`** - Handle max sessions error
  - Shows when 4 sessions are active
  - Allows user to select which session to revoke
  - Auto-retries login after revocation

---

## 🔄 Login Flow

### Standard Login Flow
```
1. User enters email/username/phone + password
2. App calls loginV2()
3. API validates credentials
4. Response scenarios:
   
   ✅ Success (No OTP):
   {
     "success": true,
     "user": {...},
     "token": "...",
     "active_sessions": 1,
     "max_sessions": 4
   }
   → Save token → Navigate to dashboard
   
   📱 OTP Required:
   {
     "success": true,
     "code": "OTP_REQUIRED",
     "user_id": 10,
     "otp_expires_at": "2025-12-05T13:05:00Z"
   }
   → Show OTP input screen
   → User enters OTP
   → Call verifyOTP()
   → Save token → Navigate to dashboard
   
   🚫 Max Sessions:
   {
     "success": false,
     "code": "MAX_SESSIONS_REACHED",
     "active_sessions": 4,
     "max_sessions": 4
   }
   → Show MaxSessionsDialog
   → User selects session to revoke
   → Call revokeSession()
   → Retry login
   
   ⏱️ Rate Limited:
   {
     "success": false,
     "code": "LOGIN_COOLDOWN",
     "cooldown_until": "2025-12-05T13:15:00Z"
   }
   → Show countdown timer
   → Disable login button until cooldown expires
```

---

## 🎨 UI Components

### 1. Login Screen Updates (Pending)
```dart
// Support for email/username/phone in single field
TextField(
  decoration: InputDecoration(
    labelText: 'Email, Username, or Phone',
    hintText: 'dr.helal@gmail.com or drhelal or +8801712345678',
  ),
)
```

### 2. OTP Verification Screen (Pending)
```dart
// 6-digit OTP input
// Countdown timer for expiration
// Resend OTP button
```

### 3. Session Management Screen (✅ Complete)
```dart
// Navigate from Profile or Settings
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SessionManagementScreen(),
  ),
);
```

### 4. Max Sessions Dialog (✅ Complete)
```dart
// Automatically shown when MAX_SESSIONS_REACHED
final revoked = await showMaxSessionsDialog(context);
if (revoked) {
  // Retry login
}
```

---

## 🔧 Integration Guide

### Step 1: Update Existing Login

**Before (v1):**
```dart
final response = await _apiService.login(email, password);
```

**After (v2):**
```dart
final authV2 = AuthV2Service();
final response = await authV2.loginV2(
  login: emailOrUsernameOrPhone,
  password: password,
  deviceName: 'Flutter Desktop App',
  deviceType: 'desktop',
);

if (response['success'] == true) {
  if (response['code'] == 'OTP_REQUIRED') {
    // Show OTP screen
    _showOTPVerification(response['user_id']);
  } else {
    // Login successful
    _handleLoginSuccess(response);
  }
} else if (response['code'] == 'MAX_SESSIONS_REACHED') {
  // Show max sessions dialog
  final revoked = await showMaxSessionsDialog(context);
  if (revoked) {
    // Retry login
    _retryLogin();
  }
} else if (response['code'] == 'LOGIN_COOLDOWN') {
  // Show cooldown message
  _showCooldownMessage(response['cooldown_until']);
}
```

### Step 2: Add Session Management to Profile

```dart
ListTile(
  leading: Icon(Icons.devices),
  title: Text('Active Sessions'),
  subtitle: Text('Manage your logged-in devices'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionManagementScreen(),
      ),
    );
  },
)
```

### Step 3: Handle OTP Verification

```dart
Future<void> _verifyOTP(int userId, String otp) async {
  final authV2 = AuthV2Service();
  final response = await authV2.verifyOTP(
    userId: userId,
    otp: otp,
    deviceName: 'Flutter Desktop App',
    deviceType: 'desktop',
  );
  
  if (response['success'] == true) {
    // OTP verified, login successful
    _handleLoginSuccess(response);
  } else {
    // Show error
    _showError(response['message']);
  }
}
```

---

## 🔒 Security Features

### 1. Rate Limiting
- **Trigger**: 5 failed login attempts
- **Cooldown**: 10 minutes
- **Response**: `LOGIN_COOLDOWN` with `cooldown_until` timestamp
- **UI**: Show countdown timer, disable login button

### 2. Session Limits
- **Max Sessions**: 4 per doctor
- **Enforcement**: Server-side validation
- **Handling**: Show device selection dialog
- **Revocation**: User chooses which session to logout

### 3. OTP Verification
- **Trigger**: Configurable per user (optional)
- **Delivery**: SMS to registered phone number
- **Expiration**: 5 minutes (configurable)
- **Attempts**: 3 verification attempts
- **Resend**: Available after 60 seconds

### 4. Token Management
- **Type**: Laravel Sanctum tokens
- **Storage**: SharedPreferences (encrypted)
- **Expiration**: Session-based (no fixed expiry)
- **Revocation**: Per-device or all devices

---

## 📊 Session Management

### View Active Sessions
```dart
final authV2 = AuthV2Service();
final result = await authV2.getActiveSessions();

if (result['success'] == true) {
  final sessions = result['sessions']; // List of SessionModel
  final total = result['total'];       // Total count
  final maxAllowed = result['max_allowed']; // 4
}
```

### Revoke Specific Session
```dart
final authV2 = AuthV2Service();
final result = await authV2.revokeSession(sessionId);

if (result['success'] == true) {
  // Session revoked successfully
}
```

### Logout All Devices
```dart
final authV2 = AuthV2Service();
final success = await authV2.logoutAll();

if (success) {
  // Logged out from all devices
  // Navigate to login screen
}
```

---

## 🐛 Error Handling

### Error Codes

| Code | Description | Action |
|------|-------------|--------|
| `INVALID_CREDENTIALS` | Wrong email/password | Show error message |
| `OTP_REQUIRED` | OTP verification needed | Show OTP screen |
| `MAX_SESSIONS_REACHED` | 4 sessions active | Show device selection |
| `LOGIN_COOLDOWN` | Too many failed attempts | Show countdown timer |
| `NETWORK_ERROR` | Connection failed | Retry or offline mode |

### Example Error Handling

```dart
switch (response['code']) {
  case 'INVALID_CREDENTIALS':
    _showError('Invalid email/username/phone or password');
    break;
    
  case 'OTP_REQUIRED':
    _showOTPScreen(response['user_id']);
    break;
    
  case 'MAX_SESSIONS_REACHED':
    final revoked = await showMaxSessionsDialog(context);
    if (revoked) _retryLogin();
    break;
    
  case 'LOGIN_COOLDOWN':
    final cooldownUntil = DateTime.parse(response['cooldown_until']);
    _showCooldownTimer(cooldownUntil);
    break;
    
  case 'NETWORK_ERROR':
    _tryOfflineLogin();
    break;
    
  default:
    _showError(response['message'] ?? 'Login failed');
}
```

---

## 🧪 Testing Checklist

### Login Tests
- [ ] Login with email
- [ ] Login with username
- [ ] Login with phone number
- [ ] Login with invalid credentials
- [ ] Login with OTP verification
- [ ] Login when max sessions reached
- [ ] Login during cooldown period

### Session Management Tests
- [ ] View all active sessions
- [ ] Revoke specific session
- [ ] Logout from all devices
- [ ] Session count updates correctly
- [ ] Current device indicator shows

### Error Handling Tests
- [ ] Invalid credentials error
- [ ] Network error fallback
- [ ] OTP expiration handling
- [ ] Max sessions dialog flow
- [ ] Cooldown timer display

---

## 📝 Migration Notes

### For Existing Users
1. **No data migration required** - v1 endpoints still work
2. **Gradual rollout** - Can switch to v2 per-user
3. **Backward compatible** - Old tokens remain valid
4. **Session cleanup** - Old sessions auto-expire after 30 days

### For Developers
1. **Update base URL** - Remove 'demo' subdomain
2. **Add v2 service** - Use `AuthV2Service` for new features
3. **Keep v1 fallback** - Offline login still uses v1
4. **Test thoroughly** - All login scenarios

---

## 🚀 Next Steps

### Immediate (Required)
1. ✅ Update API base URLs
2. ✅ Create v2 authentication service
3. ✅ Implement session management screen
4. ✅ Create max sessions dialog
5. ⏳ Update AuthProvider to use v2
6. ⏳ Update login screen UI
7. ⏳ Create OTP verification screen

### Future Enhancements
- [ ] Biometric authentication with v2
- [ ] Push notifications for new logins
- [ ] Suspicious activity alerts
- [ ] Session location tracking
- [ ] Device fingerprinting

---

## 📚 Related Documentation

- **API Documentation**: `MOBILE_API_DOCUMENTATION.md`
- **Offline Login**: `OFFLINE_LOGIN.md`
- **Memory Recovery**: `memory_recovery.sh`
- **Patient API**: `PATIENT_CREATE_API.md`

---

## 🆘 Troubleshooting

### Issue: "MAX_SESSIONS_REACHED" on every login
**Cause**: Old sessions not being revoked  
**Solution**: Use session management screen to revoke old sessions

### Issue: OTP not received
**Cause**: Phone number not verified or SMS service down  
**Solution**: Check phone number format, contact admin

### Issue: Login cooldown too long
**Cause**: Multiple failed attempts  
**Solution**: Wait for cooldown period or contact admin to reset

### Issue: Session shows as active but can't access
**Cause**: Token expired or revoked  
**Solution**: Logout and login again

---

**Last Updated:** December 5, 2025  
**Implemented By:** Cascade AI  
**Status:** ✅ Core features complete, UI updates pending
