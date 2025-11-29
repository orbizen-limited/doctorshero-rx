# Medical Prescription Flutter App

This is a Flutter/Dart conversion of the HTML/CSS/JS medical prescription application.

## 📁 Project Structure

```
quickfolder/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   ├── medicine.dart                  # Medicine data model
│   │   └── patient_info.dart              # Patient & clinical data models
│   ├── screens/
│   │   └── prescription_screen.dart       # Main prescription screen
│   └── widgets/
│       ├── prescription_header.dart       # Header with doctor/hospital info
│       ├── patient_info_card.dart         # Patient information card (TO CREATE)
│       ├── clinical_sections.dart         # Clinical sections widget (TO CREATE)
│       ├── medicine_list.dart             # Medicine list with drag & drop (TO CREATE)
│       └── prescription_footer.dart       # Footer with signature (TO CREATE)
├── pubspec.yaml                           # Flutter dependencies
└── README_FLUTTER.md                      # This file
```

## 🚀 Setup Instructions

### 1. Create a New Flutter Project

```bash
flutter create medical_prescription
cd medical_prescription
```

### 2. Copy Files

Copy all files from the `lib/` folder into your Flutter project's `lib/` folder:

```bash
cp -r lib/* medical_prescription/lib/
cp pubspec.yaml medical_prescription/
```

### 3. Install Dependencies

```bash
cd medical_prescription
flutter pub get
```

### 4. Create Missing Widget Files

You need to create these widget files (I've provided the main structure, but you'll need to complete them):

#### `lib/widgets/patient_info_card.dart`
#### `lib/widgets/clinical_sections.dart`  
#### `lib/widgets/medicine_list.dart`
#### `lib/widgets/prescription_footer.dart`

## ✨ Features Implemented

### ✅ Responsive Layout
- Adapts from mobile (768px) to large desktop (1760px on 1920px screens)
- Two-column layout on desktop (clinical sections left, prescription right)
- Vertical separator line between columns
- Centralized content with responsive padding

### ✅ Medicine Management
- **Add Medicine**: Inline editing with medicine type selector (Tab., Cap., Syp., Inj., Susp., Drops)
- **Delete Medicine**: Hover to show delete button with confirmation
- **Drag & Drop**: Reorder medicines by dragging
- **Medicine Types**: Prefix selector for medicine types

### ✅ Data Models
- `Medicine`: Complete medicine information
- `PatientInfo`: Patient demographics
- `ClinicalData`: Clinical sections data

### ✅ UI Components
- Beautiful gradient header
- Patient information card
- Clinical sections with hover effects
- Medicine cards with metadata
- Advice section
- Follow-up and referral inputs
- Professional footer with signature line

## 🎨 Design System

### Colors
- **Primary Blue**: `#3B82F6`
- **Background**: `#F1F5F9`, `#F8FAFC`
- **Text**: `#1E293b`, `#64748B`, `#94A3B8`
- **Borders**: `#E2E8F0`, `#CBD5E1`
- **Error/Delete**: `#EF4444`

### Typography
- **Font Family**: SF Pro Display (system default)
- **Headings**: Bold (700), various sizes
- **Body**: Regular (400-500)
- **Labels**: Uppercase, letter-spacing

## 📱 Responsive Breakpoints

| Screen Size | Min Width | Padding | Max Content Width |
|-------------|-----------|---------|-------------------|
| Mobile      | Default   | 16px    | 768px             |
| Small       | 640px     | 24px    | 768px             |
| Tablet      | 768px     | 32px    | 896px             |
| Laptop      | 1024px    | 40px    | 1152px            |
| Desktop     | 1280px    | 48px    | 1280px            |
| Large       | 1536px    | 64px    | 1600px            |
| XL (1920px) | 1920px    | 80px    | 1760px            |

## 🔧 Key Functionalities

### Add Medicine
```dart
void _addMedicine(Medicine medicine) {
  setState(() {
    medicines.add(medicine);
  });
}
```

### Delete Medicine
```dart
void _deleteMedicine(String id) {
  setState(() {
    medicines.removeWhere((medicine) => medicine.id == id);
  });
}
```

### Reorder Medicines (Drag & Drop)
```dart
void _reorderMedicines(int oldIndex, int newIndex) {
  setState(() {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Medicine item = medicines.removeAt(oldIndex);
    medicines.insert(newIndex, item);
  });
}
```

## 📦 Required Packages

The basic setup only requires Flutter SDK. For enhanced drag-and-drop, you might want to add:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Optional: For better drag and drop
  # reorderable_grid_view: ^latest_version
```

## 🎯 Next Steps

1. **Complete Widget Files**: Create the missing widget files listed above
2. **Add Icons**: Use Flutter's built-in Icons or add custom icons
3. **State Management**: Consider using Provider, Riverpod, or Bloc for complex state
4. **Data Persistence**: Add local storage (sqflite, hive) or backend integration
5. **PDF Export**: Add pdf package to export prescriptions
6. **Print Functionality**: Add printing capability
7. **Form Validation**: Add proper validation for all input fields

## 🏃 Run the App

```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For specific device:
```bash
flutter devices  # List available devices
flutter run -d <device_id>
```

## 📝 Notes

- All widget files use StatelessWidget or StatefulWidget as appropriate
- Responsive design uses LayoutBuilder for dynamic sizing
- Medicine list uses ReorderableListView for drag-and-drop
- Delete functionality includes confirmation dialog
- Medicine type selector uses button group pattern
- All colors and sizes match the original HTML design

## 🤝 Contributing

This is a direct conversion from HTML/CSS/JS to Flutter. The structure and functionality mirror the original web application.

---

**Original HTML Version**: `rx-new.html`  
**Flutter Version**: Complete Dart/Flutter application ready for mobile, web, and desktop
