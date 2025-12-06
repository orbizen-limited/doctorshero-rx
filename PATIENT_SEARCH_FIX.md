# 🔧 Patient Search & Creation Fix

**Date:** December 6, 2025, 10:18 PM (UTC+6)  
**Issue:** Phone number search not showing similar patients, patient creation failing

---

## 🐛 **Issues Identified:**

### 1. **Phone Search Not Working**
- User types phone number `01312399777`
- No similar patients shown
- Loading indicator appears but no results

### 2. **Patient Creation Failing**
- User fills in patient info
- Clicks "Save Patient Info"
- Shows error: "Failed to create patient. Please try again."

---

## 🔍 **Root Cause Analysis:**

### Current Implementation:
```dart
// PatientService.searchByPhone()
final url = 'https://doctorshero.com/api/v1/patients?phone=$phone';
```

### Possible Issues:
1. **API Endpoint** - May need different endpoint
2. **Authentication** - Token may be invalid/expired
3. **Response Format** - API may return different structure
4. **Network Error** - Connection issues

---

## ✅ **Fixes Applied:**

### 1. **Added Debug Logging**

#### UnifiedPatientDialog:
```dart
Future<void> _searchPatientsByPhone(String phone) async {
  print('🔍 Searching patients by phone: $phone');
  // ... search logic ...
  print('✅ Found ${matches.length} patients');
}

Future<void> _handleSave() async {
  print('💾 Attempting to save patient...');
  print('   Name: ${_nameController.text.trim()}');
  print('   Phone: ${_phoneController.text.trim()}');
  // ... save logic ...
}
```

#### PatientService:
```dart
Future<List<Map<String, dynamic>>> searchByPhone(String phone) async {
  print('📡 GET $url');
  print('📦 Response status: ${response.statusCode}');
  print('📦 Response body: ${response.body}');
  // ... logic ...
}

Future<Map<String, dynamic>?> createPatient(...) async {
  print('📡 POST $baseUrl/api/v1/patients');
  print('📦 Request body: ${jsonEncode(body)}');
  print('📦 Response status: ${response.statusCode}');
  print('📦 Response body: ${response.body}');
  // ... logic ...
}
```

---

## 🧪 **Testing Instructions:**

### Step 1: Run the App
```bash
flutter run -d macos
```

### Step 2: Open Patient Dialog
1. Go to Create Prescription screen
2. Click any patient field edit icon
3. Patient Information dialog opens

### Step 3: Test Phone Search
1. Type phone number: `01312399777`
2. Watch console for logs:
   ```
   🔍 Searching patients by phone: 01312399777
   📡 GET https://doctorshero.com/api/v1/patients?phone=01312399777
   📦 Response status: 200
   📦 Response body: {...}
   ✅ Found X patients
   ```

### Step 4: Test Patient Creation
1. Fill in:
   - Phone: `01312399777`
   - Name: `Test Patient`
   - Age: `25`
   - Gender: `Male`
2. Click "Save Patient Info"
3. Watch console for logs:
   ```
   💾 Attempting to save patient...
      Name: Test Patient
      Phone: 01312399777
      Age: 25
      Gender: Male
   📡 Creating patient via API...
   📡 POST https://doctorshero.com/api/v1/patients
   📦 Request body: {"name":"Test Patient","phone":"01312399777",...}
   📦 Response status: 200/201
   📦 Response body: {...}
   ✅ Patient creation response received
   ```

---

## 📊 **Expected Console Output:**

### Successful Phone Search:
```
🔍 Searching patients by phone: 01312399777
📡 GET https://doctorshero.com/api/v1/patients?phone=01312399777
📦 Response status: 200
📦 Response body: {"success":true,"data":[{"id":14,"patient_id":"P584376812","name":"Md Siyam","phone":"01312399777","age":16,"gender":"Male"}]}
✅ Found 1 patients
   Patients: Md Siyam
```

### Successful Patient Creation:
```
💾 Attempting to save patient...
   Name: Test Patient
   Phone: 01312399777
   Age: 25
   Gender: Male
   Patient ID: 
📡 Creating patient via API...
📡 POST https://doctorshero.com/api/v1/patients
📦 Request body: {"name":"Test Patient","phone":"01312399777","age":"25","gender":"Male","force_create":false}
📦 Response status: 200
📦 Response body: {"success":true,"data":{"patient_id":"P123456789","name":"Test Patient","phone":"01312399777","age":25,"gender":"Male"}}
✅ Patient creation response received
```

### Duplicate Detection:
```
📦 Response body: {"success":false,"requires_confirmation":true,"similar_patients":[...]}
```

---

## 🔧 **Troubleshooting:**

### If Phone Search Returns Empty:

#### Check 1: Authentication
```
❌ No auth token available
```
**Fix:** Login again to get fresh token

#### Check 2: API Response
```
📦 Response status: 401
📦 Response body: {"message":"Unauthenticated."}
```
**Fix:** Token expired, login again

#### Check 3: No Patients Found
```
📦 Response status: 200
📦 Response body: {"success":true,"data":[]}
⚠️  No patients found or API error
```
**Fix:** Normal - no patients with that phone number

### If Patient Creation Fails:

#### Check 1: Validation Error
```
❌ Validation failed: Name is required
```
**Fix:** Ensure name field is filled

#### Check 2: API Error
```
📦 Response status: 422
📦 Response body: {"message":"Validation failed","errors":{...}}
```
**Fix:** Check required fields

#### Check 3: Network Error
```
❌ Error in createPatient: SocketException: Failed host lookup
```
**Fix:** Check internet connection

---

## 📝 **API Endpoints Used:**

### Search Patients:
```
GET https://doctorshero.com/api/v1/patients?phone={phone}
GET https://doctorshero.com/api/v1/patients?name={name}
GET https://doctorshero.com/api/v1/patients?patient_id={pid}
GET https://doctorshero.com/api/v1/patients?search={query}
```

### Create Patient:
```
POST https://doctorshero.com/api/v1/patients
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json
  Accept: application/json
Body:
  {
    "name": "Patient Name",
    "phone": "01234567890",
    "age": "25",
    "gender": "Male",
    "force_create": false
  }
```

### Response Formats:

#### Success:
```json
{
  "success": true,
  "data": {
    "patient_id": "P123456789",
    "name": "Patient Name",
    "phone": "01234567890",
    "age": 25,
    "gender": "Male"
  }
}
```

#### Duplicate Found:
```json
{
  "success": false,
  "requires_confirmation": true,
  "similar_patients": [
    {
      "id": 14,
      "patient_id": "P584376812",
      "name": "Md Siyam",
      "phone": "01312399777",
      "age": 16,
      "gender": "Male"
    }
  ],
  "message": "Similar patients found with this phone number"
}
```

---

## 🎯 **Next Steps:**

1. **Run the app** with new logging
2. **Test phone search** - Check console logs
3. **Test patient creation** - Check console logs
4. **Report findings:**
   - What status codes are returned?
   - What response bodies are received?
   - Are there any errors?

---

## 📋 **Files Modified:**

1. `lib/widgets/unified_patient_dialog.dart`
   - Added logging to `_searchPatientsByPhone()`
   - Added logging to `_handleSave()`

2. `lib/services/patient_service.dart`
   - Added logging to `searchByPhone()`
   - Added logging to `createPatient()`

---

**Status:** 🟡 **Debugging Mode Enabled**

Run the app and check console logs to identify the exact issue!
