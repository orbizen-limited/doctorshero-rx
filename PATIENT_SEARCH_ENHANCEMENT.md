# 🔍 Patient Search API Enhancement

**Date:** December 2, 2025  
**Feature:** Enhanced Patient Search with Multiple Parameters  
**Status:** ✅ IMPLEMENTED

---

## 📋 Overview

The Patient Search API has been enhanced to support multiple search parameters, allowing flexible and precise patient lookups by patient ID, phone number, name, or any combination of these fields.

---

## 🎯 Problem Solved

### Before (Old Limitation)
❌ Could only search by patient_id  
❌ No way to search by phone number alone  
❌ No way to search by name alone  
❌ No combined search capability  

### After (New Capability)
✅ Search by patient_id (exact match)  
✅ Search by phone (partial match)  
✅ Search by name (partial match)  
✅ Combined search (phone + name)  
✅ Generic search (backward compatible)  

---

## 🔧 Technical Implementation

### File Modified
```
app/Http/Controllers/Api/MobileApiController.php
```

### Method Enhanced
```php
public function getPatients(Request $request)
```

### New Search Parameters

| Parameter | Type | Match Type | Example | Description |
|-----------|------|------------|---------|-------------|
| `patient_id` | string | Exact | `P123456789` | Search by exact patient ID |
| `phone` | string | Partial | `01312399777` | Search by phone (partial match) |
| `name` | string | Partial | `Shahjalal` | Search by name (partial match) |
| `search` | string | Partial | `John` | Generic search (name/phone/ID) |
| `gender` | string | Exact | `Male` | Filter by gender |
| `per_page` | integer | - | `20` | Items per page |
| `page` | integer | - | `1` | Page number |

---

## 📊 API Usage Examples

### 1. Search by Patient ID (Exact Match)
```http
GET /api/v1/patients?patient_id=P123456789
Authorization: Bearer {token}
```

**Use Case:** When you have the exact patient ID and want to retrieve that specific patient.

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 5,
            "patient_id": "P123456789",
            "name": "John Doe",
            "phone": "8801234567890",
            "gender": "Male",
            "age": 35
        }
    ],
    "search_params": {
        "patient_id": "P123456789",
        "phone": null,
        "name": null
    }
}
```

---

### 2. Search by Phone Number
```http
GET /api/v1/patients?phone=01312399777
Authorization: Bearer {token}
```

**Use Case:** When you have a phone number and want to find all patients with that number.

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 10,
            "patient_id": "P987654321",
            "name": "Shahjalal Ahmed",
            "phone": "01312399777",
            "gender": "Male",
            "age": 42
        }
    ],
    "search_params": {
        "patient_id": null,
        "phone": "01312399777",
        "name": null
    }
}
```

**Partial Phone Search:**
```http
GET /api/v1/patients?phone=01312
```
This will return all patients whose phone contains "01312".

---

### 3. Search by Name
```http
GET /api/v1/patients?name=Shahjalal
Authorization: Bearer {token}
```

**Use Case:** When you remember the patient's name but not their ID or phone.

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 10,
            "patient_id": "P987654321",
            "name": "Shahjalal Ahmed",
            "phone": "01312399777",
            "gender": "Male",
            "age": 42
        },
        {
            "id": 15,
            "patient_id": "P111222333",
            "name": "Shahjalal Khan",
            "phone": "01712345678",
            "gender": "Male",
            "age": 38
        }
    ],
    "search_params": {
        "patient_id": null,
        "phone": null,
        "name": "Shahjalal"
    }
}
```

---

### 4. Combined Search (Phone + Name)
```http
GET /api/v1/patients?phone=01312&name=Shah
Authorization: Bearer {token}
```

**Use Case:** When you want to narrow down results by combining multiple criteria.

**Logic:** Returns patients where phone contains "01312" AND name contains "Shah".

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 10,
            "patient_id": "P987654321",
            "name": "Shahjalal Ahmed",
            "phone": "01312399777",
            "gender": "Male",
            "age": 42
        }
    ],
    "search_params": {
        "patient_id": null,
        "phone": "01312",
        "name": "Shah"
    }
}
```

---

### 5. Generic Search (Backward Compatible)
```http
GET /api/v1/patients?search=John
Authorization: Bearer {token}
```

**Use Case:** Quick search across all fields (name, phone, patient_id).

**Logic:** Returns patients where name OR phone OR patient_id contains "John".

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 5,
            "patient_id": "P123456789",
            "name": "John Doe",
            "phone": "8801234567890",
            "gender": "Male",
            "age": 35
        },
        {
            "id": 8,
            "patient_id": "P555666777",
            "name": "Johnson Smith",
            "phone": "8801555666777",
            "gender": "Male",
            "age": 45
        }
    ],
    "search_params": {
        "patient_id": null,
        "phone": null,
        "name": null,
        "search": "John"
    }
}
```

---

### 6. Filter by Gender
```http
GET /api/v1/patients?name=Shah&gender=Male
Authorization: Bearer {token}
```

**Use Case:** Search with additional filtering.

---

## 🔍 Search Logic Details

### Match Types

#### 1. Exact Match (patient_id)
```sql
WHERE patient_id = 'P123456789'
```
- Must match exactly
- Case-sensitive
- Returns 0 or 1 result

#### 2. Partial Match (phone, name)
```sql
WHERE phone LIKE '%01312%'
WHERE name LIKE '%Shah%'
```
- Matches anywhere in the string
- Case-insensitive
- Can return multiple results

#### 3. OR Logic (search parameter)
```sql
WHERE name LIKE '%John%' 
   OR phone LIKE '%John%' 
   OR patient_id LIKE '%John%'
```
- Searches across multiple fields
- Returns any match

#### 4. AND Logic (multiple parameters)
```sql
WHERE phone LIKE '%01312%' 
  AND name LIKE '%Shah%'
```
- All conditions must be true
- Narrows down results

---

## 💻 Code Implementation

### Controller Method
```php
public function getPatients(Request $request)
{
    $doctor = Auth::user();
    $query = $doctor->patients();

    // Search by patient_id (exact match)
    if ($request->has('patient_id') && $request->patient_id) {
        $query->where('patient_id', $request->patient_id);
    }

    // Search by phone (partial match)
    if ($request->has('phone') && $request->phone) {
        $query->where('phone', 'LIKE', "%{$request->phone}%");
    }

    // Search by name (partial match)
    if ($request->has('name') && $request->name) {
        $query->where('name', 'LIKE', "%{$request->name}%");
    }

    // Generic search (backward compatible)
    if ($request->has('search') && $request->search) {
        $search = $request->search;
        $query->where(function($q) use ($search) {
            $q->where('name', 'LIKE', "%{$search}%")
              ->orWhere('phone', 'LIKE', "%{$search}%")
              ->orWhere('patient_id', 'LIKE', "%{$search}%");
        });
    }

    // Filter by gender
    if ($request->has('gender') && $request->gender) {
        $query->where('gender', $request->gender);
    }

    // Order and paginate
    $query->orderBy('last_visit', 'desc');
    $patients = $query->paginate($request->get('per_page', 20));

    return response()->json([
        'success' => true,
        'data' => $patients->items(),
        'pagination' => [...],
        'search_params' => [
            'patient_id' => $request->patient_id,
            'phone' => $request->phone,
            'name' => $request->name,
            'search' => $request->search,
            'gender' => $request->gender
        ]
    ]);
}
```

---

## 🎨 UI Implementation Examples

### Flutter Example

```dart
// Search by phone
Future<List<Patient>> searchByPhone(String phone) async {
  final response = await http.get(
    Uri.parse('$baseUrl/patients?phone=$phone'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((p) => Patient.fromJson(p))
        .toList();
  }
  throw Exception('Failed to search patients');
}

// Search by name
Future<List<Patient>> searchByName(String name) async {
  final response = await http.get(
    Uri.parse('$baseUrl/patients?name=$name'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  return parsePatients(response);
}

// Combined search
Future<List<Patient>> searchPatients({
  String? patientId,
  String? phone,
  String? name,
}) async {
  final params = <String, String>{};
  if (patientId != null) params['patient_id'] = patientId;
  if (phone != null) params['phone'] = phone;
  if (name != null) params['name'] = name;
  
  final uri = Uri.parse('$baseUrl/patients').replace(
    queryParameters: params,
  );
  
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  
  return parsePatients(response);
}
```

### JavaScript/React Example

```javascript
// Search by phone
const searchByPhone = async (phone) => {
  const response = await fetch(
    `${API_URL}/patients?phone=${phone}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
      }
    }
  );
  
  const data = await response.json();
  return data.data;
};

// Search by name
const searchByName = async (name) => {
  const response = await fetch(
    `${API_URL}/patients?name=${name}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
      }
    }
  );
  
  const data = await response.json();
  return data.data;
};

// Combined search
const searchPatients = async ({ patientId, phone, name, gender }) => {
  const params = new URLSearchParams();
  if (patientId) params.append('patient_id', patientId);
  if (phone) params.append('phone', phone);
  if (name) params.append('name', name);
  if (gender) params.append('gender', gender);
  
  const response = await fetch(
    `${API_URL}/patients?${params.toString()}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
      }
    }
  );
  
  const data = await response.json();
  return data.data;
};
```

---

## 🧪 Testing Examples

### Test Case 1: Search by Patient ID
```bash
curl -X GET "https://test.doctorshero.com/api/v1/patients?patient_id=P123456789" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Test Case 2: Search by Phone
```bash
curl -X GET "https://test.doctorshero.com/api/v1/patients?phone=01312399777" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Test Case 3: Search by Name
```bash
curl -X GET "https://test.doctorshero.com/api/v1/patients?name=Shahjalal" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Test Case 4: Combined Search
```bash
curl -X GET "https://test.doctorshero.com/api/v1/patients?phone=01312&name=Shah" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Test Case 5: Generic Search
```bash
curl -X GET "https://test.doctorshero.com/api/v1/patients?search=John" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

## ✅ Benefits

### For Developers
- ✅ Flexible search options
- ✅ Backward compatible (old `search` parameter still works)
- ✅ Clear parameter naming
- ✅ Response includes search params for debugging

### For Users
- ✅ Find patients by any known information
- ✅ Faster patient lookup
- ✅ More accurate search results
- ✅ Combined filters for precision

### For System
- ✅ Efficient database queries
- ✅ Indexed fields (patient_id, phone)
- ✅ Pagination support
- ✅ No breaking changes

---

## 📊 Comparison Table

| Search Type | Old API | New API |
|-------------|---------|---------|
| By Patient ID | ❌ Not available | ✅ `?patient_id=P123456789` |
| By Phone | ❌ Not available | ✅ `?phone=01312399777` |
| By Name | ❌ Not available | ✅ `?name=Shahjalal` |
| Combined | ❌ Not available | ✅ `?phone=xxx&name=yyy` |
| Generic | ✅ `?search=xxx` | ✅ `?search=xxx` (still works) |

---

## 🔄 Migration Guide

### If You're Using Old API

**Before:**
```javascript
// Only generic search was available
const patients = await searchPatients('01312399777');
```

**After:**
```javascript
// Now you can be specific
const patients = await searchPatients({ phone: '01312399777' });

// Or search by name
const patients = await searchPatients({ name: 'Shahjalal' });

// Or combine
const patients = await searchPatients({ 
  phone: '01312', 
  name: 'Shah' 
});

// Old way still works!
const patients = await searchPatients({ search: '01312399777' });
```

---

## 📚 Related Documentation

- **Main API Docs:** `MOBILE_API_DOCUMENTATION.md`
- **Patient Model:** `app/Models/Patient.php`
- **Controller:** `app/Http/Controllers/Api/MobileApiController.php`
- **Routes:** `routes/api.php`

---

## ✅ Summary

| Feature | Status |
|---------|--------|
| Search by patient_id | ✅ Implemented |
| Search by phone | ✅ Implemented |
| Search by name | ✅ Implemented |
| Combined search | ✅ Implemented |
| Generic search | ✅ Maintained |
| Documentation updated | ✅ Complete |
| Backward compatible | ✅ Yes |
| Testing examples | ✅ Provided |

---

**Last Updated:** December 2, 2025  
**Version:** 2.0.0  
**Status:** Production Ready ✅
