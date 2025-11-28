# DoctorsHero RX - Login Credentials

## Test Login Credentials

Use these credentials to test the login functionality:

**Email:** `dr.helal.uddin@gmail.com`  
**Password:** `Helal@2025`

## API Endpoints

- **Base URL:** `https://demo.doctorshero.com`
- **Login Endpoint:** `POST /api/mobile/auth/login`
- **Profile Endpoint:** `GET /api/mobile/auth/me`

## Features Implemented

### ✅ Login Screen
- Exact design match with the provided screenshot
- Orange (#FE3001) branded left panel with:
  - Background pattern SVG
  - DoctorsHero logo
  - Doctor image in circular frame
  - Decorative circles
- White login form panel with:
  - Email and password fields
  - ProductSans font family
  - Validation
  - Error handling
  - Loading states

### ✅ Profile Screen
- User information display:
  - Name
  - Email
  - Phone (if available)
  - Role badge
  - User ID
  - Member since date
- Notification preferences display
- Logout functionality

### ✅ API Integration
- HTTP client with proper headers
- Token-based authentication (Laravel Sanctum)
- Secure token storage using SharedPreferences
- Error handling
- State management with Provider

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── user_model.dart      # User data model
├── services/
│   └── api_service.dart     # API client & auth methods
├── providers/
│   └── auth_provider.dart   # State management
└── screens/
    ├── login_screen.dart    # Login UI
    └── profile_screen.dart  # Profile UI
```

## Running the App

### macOS
```bash
flutter run -d macos
```

### Windows
```bash
flutter run -d windows
```

### Build for Production

**macOS:**
```bash
flutter build macos
# Output: build/macos/Build/Products/Release/doctorshero_rx.app
```

**Windows:**
```bash
flutter build windows
# Output: build/windows/runner/Release/
```

## Design Assets Used

- `assets/horizental-logo-white.png` - DoctorsHero logo
- `assets/doctor.svg` - Doctor illustration
- `assets/background-effect.svg` - Medical pattern background
- `font/ProductSans-*.ttf` - Google Product Sans font family

## Color Scheme

- **Primary Orange:** `#FE3001`
- **Background:** `#F5F5F5`
- **White:** `#FFFFFF`
- **Text:** `#000000` (87% opacity)

## Dependencies

- `http: ^1.1.0` - HTTP client
- `shared_preferences: ^2.2.2` - Local storage
- `flutter_svg: ^2.0.9` - SVG rendering
- `provider: ^6.1.1` - State management
