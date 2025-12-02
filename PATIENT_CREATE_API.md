# 👤 Create Patient API with Duplicate Detection

**Date:** December 2, 2025  
**Feature:** Create Patient Endpoint with Smart Duplicate Checking  
**Status:** ✅ IMPLEMENTED

---

## 📋 Overview

A new API endpoint has been added to create patients with intelligent duplicate detection. The system automatically checks for existing patients with the same phone number before creating a new record, preventing accidental duplicates while allowing family members to share phone numbers.

---

## 🎯 Problem Solved

### Before
❌ No API endpoint to create patients from mobile app  
❌ Risk of creating duplicate patient records  
❌ No way to handle family members with shared phones  

### After
✅ Complete patient creation endpoint  
✅ Automatic duplicate detection by phone  
✅ Confirmation workflow for similar patients  
✅ Force create option for family members  
✅ Automatic doctor-patient linking  

---

## 🔧 Technical Implementation

### Files Modified

**1. Controller:**
```
app/Http/Controllers/Api/MobileApiController.php
```
- Added `createPatient()` method (lines 696-802)

**2. Routes:**
```
routes/api.php
```
- Added `POST /api/v1/patients` route

**3. Documentation:**
```
MOBILE_API_DOCUMENTATION.md
```
- Added complete endpoint documentation

---

## 📊 API Endpoint Details

### Endpoint
```http
POST /api/v1/patients
```

### Authentication
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Request Body

**Required Fields:**
```json
{
    "name": "Shahjalal Ahmed",
    "phone": "01312399777",
    "age": 42,
    "gender": "Male"
}
```

**All Fields:**
```json
{
    "name": "Shahjalal Ahmed",
    "phone": "01312399777",
    "age": 42,
    "gender": "Male",
    "address": "Dhaka, Bangladesh",
    "blood_group": "A+",
    "medical_notes": "Diabetic patient, regular checkup needed",
    "force_create": false
}
```

### Field Validation

| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| `name` | string | ✅ Yes | max:255 | "Shahjalal Ahmed" |
| `phone` | string | ✅ Yes | max:20 | "01312399777" |
| `age` | integer | ✅ Yes | 0-150 | 42 |
| `gender` | string | ✅ Yes | Male/Female/Other | "Male" |
| `address` | string | ❌ No | max:500 | "Dhaka, Bangladesh" |
| `blood_group` | string | ❌ No | max:10 | "A+", "O-", "AB+" |
| `medical_notes` | string | ❌ No | - | "Diabetic patient" |
| `force_create` | boolean | ❌ No | true/false | false |

---

## 🔄 Workflow & Responses

### Scenario 1: No Duplicate Found (Success)

**Request:**
```bash
curl -X POST "https://test.doctorshero.com/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Shahjalal Ahmed",
    "phone": "01312399777",
    "age": 42,
    "gender": "Male",
    "blood_group": "A+"
  }'
```

**Response (201 Created):**
```json
{
    "success": true,
    "message": "Patient created successfully",
    "data": {
        "id": 25,
        "patient_id": "P987654321",
        "name": "Shahjalal Ahmed",
        "phone": "01312399777",
        "age": 42,
        "gender": "Male",
        "blood_group": "A+",
        "address": null,
        "medical_notes": null,
        "last_visit": "2025-12-02",
        "created_at": "2025-12-02T08:15:30.000000Z"
    }
}
```

**What Happens:**
1. ✅ Validates input data
2. ✅ Checks for duplicates (none found)
3. ✅ Generates unique patient_id (P + 9 digits)
4. ✅ Creates patient record
5. ✅ Links patient to doctor
6. ✅ Sets last_visit to today
7. ✅ Returns patient data with 201 status

---

### Scenario 2: Duplicate Found (Requires Confirmation)

**Request:**
```bash
curl -X POST "https://test.doctorshero.com/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Shahjalal Ahmed",
    "phone": "01312399777",
    "age": 42,
    "gender": "Male"
  }'
```

**Response (200 OK - Requires Confirmation):**
```json
{
    "success": false,
    "requires_confirmation": true,
    "similar_patients": [
        {
            "id": 10,
            "patient_id": "P123456789",
            "name": "Shahjalal Khan",
            "phone": "01312399777",
            "age": 38,
            "gender": "Male",
            "blood_group": "B+",
            "address": "Chittagong",
            "last_visit": "2025-11-15"
        },
        {
            "id": 15,
            "patient_id": "P555666777",
            "name": "Shahjalal Uddin",
            "phone": "01312399777",
            "age": 45,
            "gender": "Male",
            "blood_group": "O+",
            "address": "Sylhet",
            "last_visit": "2025-10-20"
        }
    ],
    "message": "Similar patients found with this phone number. Please confirm if you want to create a new patient or use an existing one.",
    "hint": "To create anyway, send force_create: true"
}
```

**What Happens:**
1. ✅ Validates input data
2. ⚠️ Finds existing patients with same phone
3. 🛑 Stops creation process
4. 📋 Returns list of similar patients
5. 💬 Asks user to confirm action

**User Options:**
- **Option A:** Select existing patient from `similar_patients` list
- **Option B:** Create new patient anyway (send `force_create: true`)

---

### Scenario 3: Force Create (Bypass Duplicate Check)

**Request:**
```bash
curl -X POST "https://test.doctorshero.com/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Shahjalal Ahmed",
    "phone": "01312399777",
    "age": 42,
    "gender": "Male",
    "force_create": true
  }'
```

**Response (201 Created):**
```json
{
    "success": true,
    "message": "Patient created successfully",
    "data": {
        "id": 26,
        "patient_id": "P888999000",
        "name": "Shahjalal Ahmed",
        "phone": "01312399777",
        "age": 42,
        "gender": "Male",
        "blood_group": null,
        "address": null,
        "medical_notes": null,
        "last_visit": "2025-12-02",
        "created_at": "2025-12-02T08:20:45.000000Z"
    }
}
```

**What Happens:**
1. ✅ Validates input data
2. ⏭️ Skips duplicate check (force_create = true)
3. ✅ Creates new patient record
4. ✅ Links to doctor
5. ✅ Returns patient data

**Use Case:** Family members sharing the same phone number (father, mother, children).

---

### Scenario 4: Validation Error

**Request:**
```bash
curl -X POST "https://test.doctorshero.com/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Shahjalal",
    "age": 42
  }'
```

**Response (422 Unprocessable Entity):**
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "phone": ["The phone field is required."],
        "gender": ["The gender field is required."]
    }
}
```

---

## 💻 Implementation Examples

### Flutter/Dart Example

```dart
class PatientService {
  final String baseUrl;
  final String token;

  PatientService(this.baseUrl, this.token);

  // Create patient with duplicate handling
  Future<CreatePatientResult> createPatient({
    required String name,
    required String phone,
    required int age,
    required String gender,
    String? address,
    String? bloodGroup,
    String? medicalNotes,
    bool forceCreate = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender,
        'address': address,
        'blood_group': bloodGroup,
        'medical_notes': medicalNotes,
        'force_create': forceCreate,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      // Patient created successfully
      return CreatePatientResult.success(
        Patient.fromJson(data['data']),
      );
    } else if (data['requires_confirmation'] == true) {
      // Duplicates found
      final similarPatients = (data['similar_patients'] as List)
          .map((p) => Patient.fromJson(p))
          .toList();
      return CreatePatientResult.duplicatesFound(similarPatients);
    } else {
      // Error
      return CreatePatientResult.error(data['message']);
    }
  }
}

// Result class
class CreatePatientResult {
  final Patient? patient;
  final List<Patient>? similarPatients;
  final String? error;
  final bool isSuccess;
  final bool hasDuplicates;

  CreatePatientResult.success(this.patient)
      : similarPatients = null,
        error = null,
        isSuccess = true,
        hasDuplicates = false;

  CreatePatientResult.duplicatesFound(this.similarPatients)
      : patient = null,
        error = null,
        isSuccess = false,
        hasDuplicates = true;

  CreatePatientResult.error(this.error)
      : patient = null,
        similarPatients = null,
        isSuccess = false,
        hasDuplicates = false;
}

// Usage in UI
class CreatePatientScreen extends StatefulWidget {
  @override
  _CreatePatientScreenState createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Male';

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await PatientService(baseUrl, token).createPatient(
      name: _nameController.text,
      phone: _phoneController.text,
      age: int.parse(_ageController.text),
      gender: _selectedGender,
    );

    if (result.isSuccess) {
      // Success - navigate back or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient created successfully!')),
      );
      Navigator.pop(context, result.patient);
    } else if (result.hasDuplicates) {
      // Show duplicate confirmation dialog
      _showDuplicateDialog(result.similarPatients!);
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to create patient')),
      );
    }
  }

  void _showDuplicateDialog(List<Patient> similarPatients) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Similar Patients Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Patients with this phone number already exist:'),
            SizedBox(height: 16),
            ...similarPatients.map((patient) => ListTile(
              title: Text(patient.name),
              subtitle: Text('Age: ${patient.age}, PID: ${patient.patientId}'),
              trailing: ElevatedButton(
                child: Text('Use This'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, patient);
                },
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Create New Anyway'),
            onPressed: () async {
              Navigator.pop(context);
              // Retry with force_create = true
              final result = await PatientService(baseUrl, token).createPatient(
                name: _nameController.text,
                phone: _phoneController.text,
                age: int.parse(_ageController.text),
                gender: _selectedGender,
                forceCreate: true,
              );
              if (result.isSuccess) {
                Navigator.pop(context, result.patient);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Patient')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name *'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone *'),
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age *'),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(labelText: 'Gender *'),
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Create Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### JavaScript/React Example

```javascript
// API Service
class PatientAPI {
  constructor(baseUrl, token) {
    this.baseUrl = baseUrl;
    this.token = token;
  }

  async createPatient(patientData) {
    const response = await fetch(`${this.baseUrl}/patients`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify(patientData),
    });

    const data = await response.json();

    return {
      status: response.status,
      data,
      isSuccess: response.status === 201,
      hasDuplicates: data.requires_confirmation === true,
    };
  }
}

// React Component
function CreatePatientForm() {
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    age: '',
    gender: 'Male',
    address: '',
    blood_group: '',
    medical_notes: '',
  });
  const [similarPatients, setSimilarPatients] = useState([]);
  const [showDuplicateModal, setShowDuplicateModal] = useState(false);

  const handleSubmit = async (e, forceCreate = false) => {
    e.preventDefault();

    const api = new PatientAPI(API_BASE_URL, authToken);
    const result = await api.createPatient({
      ...formData,
      age: parseInt(formData.age),
      force_create: forceCreate,
    });

    if (result.isSuccess) {
      alert('Patient created successfully!');
      // Reset form or navigate
      setFormData({ name: '', phone: '', age: '', gender: 'Male' });
    } else if (result.hasDuplicates) {
      setSimilarPatients(result.data.similar_patients);
      setShowDuplicateModal(true);
    } else {
      alert(result.data.message || 'Failed to create patient');
    }
  };

  const handleForceCreate = (e) => {
    setShowDuplicateModal(false);
    handleSubmit(e, true);
  };

  return (
    <>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Name *"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          required
        />
        <input
          type="tel"
          placeholder="Phone *"
          value={formData.phone}
          onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
          required
        />
        <input
          type="number"
          placeholder="Age *"
          value={formData.age}
          onChange={(e) => setFormData({ ...formData, age: e.target.value })}
          required
        />
        <select
          value={formData.gender}
          onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
          required
        >
          <option value="Male">Male</option>
          <option value="Female">Female</option>
          <option value="Other">Other</option>
        </select>
        <button type="submit">Create Patient</button>
      </form>

      {showDuplicateModal && (
        <div className="modal">
          <h3>Similar Patients Found</h3>
          <p>Patients with this phone number already exist:</p>
          <ul>
            {similarPatients.map((patient) => (
              <li key={patient.id}>
                <strong>{patient.name}</strong> - Age: {patient.age}, PID: {patient.patient_id}
                <button onClick={() => useExistingPatient(patient)}>
                  Use This Patient
                </button>
              </li>
            ))}
          </ul>
          <button onClick={() => setShowDuplicateModal(false)}>Cancel</button>
          <button onClick={handleForceCreate}>Create New Anyway</button>
        </div>
      )}
    </>
  );
}
```

---

## 🧪 Testing Guide

### Test Case 1: Create New Patient (No Duplicates)
```bash
curl -X POST "http://127.0.0.1:8000/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Patient",
    "phone": "01999999999",
    "age": 30,
    "gender": "Male"
  }'
```
**Expected:** 201 Created with patient data

### Test Case 2: Create Duplicate (Should Warn)
```bash
# First create a patient
curl -X POST "http://127.0.0.1:8000/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "01312399777",
    "age": 35,
    "gender": "Male"
  }'

# Try to create another with same phone
curl -X POST "http://127.0.0.1:8000/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "phone": "01312399777",
    "age": 32,
    "gender": "Female"
  }'
```
**Expected:** 200 OK with `requires_confirmation: true`

### Test Case 3: Force Create
```bash
curl -X POST "http://127.0.0.1:8000/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "phone": "01312399777",
    "age": 32,
    "gender": "Female",
    "force_create": true
  }'
```
**Expected:** 201 Created (bypasses duplicate check)

### Test Case 4: Validation Error
```bash
curl -X POST "http://127.0.0.1:8000/api/v1/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test"
  }'
```
**Expected:** 422 Unprocessable Entity with validation errors

---

## ✅ Benefits

### For Developers
- ✅ Simple, intuitive API
- ✅ Clear duplicate handling workflow
- ✅ Comprehensive validation
- ✅ Automatic patient-doctor linking

### For Users
- ✅ Prevents accidental duplicates
- ✅ Allows family members to share phones
- ✅ Clear confirmation prompts
- ✅ Fast patient creation

### For System
- ✅ Data integrity maintained
- ✅ Flexible duplicate handling
- ✅ Automatic PID generation
- ✅ Proper relationship management

---

## 📚 Related Documentation

- **Main API Docs:** `MOBILE_API_DOCUMENTATION.md`
- **Patient Search:** `PATIENT_SEARCH_ENHANCEMENT.md`
- **Patient Model:** `app/Models/Patient.php`
- **Controller:** `app/Http/Controllers/Api/MobileApiController.php`

---

## ✅ Summary

| Feature | Status |
|---------|--------|
| Create patient endpoint | ✅ Implemented |
| Duplicate detection | ✅ Implemented |
| Force create option | ✅ Implemented |
| Validation | ✅ Complete |
| Doctor linking | ✅ Automatic |
| Documentation | ✅ Complete |
| Testing examples | ✅ Provided |

---

**Last Updated:** December 2, 2025  
**Version:** 1.0.0  
**Status:** Production Ready ✅
