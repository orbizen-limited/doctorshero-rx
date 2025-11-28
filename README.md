# DoctorsHero RX - Desktop Application

A modern Flutter desktop application for DoctorsHero prescription management system.

## 🚀 Features

- **Modern Login UI** - Beautiful, responsive login screen with custom design
- **Dashboard** - Clean, intuitive dashboard with sidebar navigation
- **Authentication** - Secure API-based authentication with token management
- **Multi-Platform** - Supports macOS and Windows desktop platforms
- **Modern UI/UX** - Headless UI design with ProductSans font family

## 📋 Prerequisites

- Flutter SDK (3.24.0 or higher)
- Dart SDK
- For macOS: Xcode
- For Windows: Visual Studio 2022 with C++ development tools

## 🛠️ Installation

1. Clone the repository:
```bash
git clone https://github.com/orbizen-limited/doctorshero-rx.git
cd doctorshero-rx
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
# For macOS
flutter run -d macos

# For Windows (on Windows machine)
flutter run -d windows
```

## 🏗️ Building

### macOS Build
```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/doctorshero_rx.app`

### Windows Build
```bash
flutter build windows --release
```
Output: `build/windows/x64/runner/Release/`

**Note:** Windows builds must be created on a Windows machine. Use GitHub Actions for automated builds.

## 🤖 Automated Builds

This project includes GitHub Actions workflow for automated Windows builds:
- Push to `main` branch triggers automatic build
- Download artifacts from the Actions tab
- Builds are retained for 30 days

## 🔑 Login Credentials

**Test Account:**
- Email: `dr.helal.uddin@gmail.com`
- Password: `Helal@2025`

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/
│   └── user_model.dart      # User data model
├── providers/
│   └── auth_provider.dart   # Authentication state management
├── screens/
│   ├── login_screen.dart    # Login UI
│   ├── dashboard_screen.dart # Main dashboard
│   └── profile_screen.dart  # User profile
└── services/
    └── api_service.dart     # API communication layer
```

## 🎨 Design

- **Primary Color:** #FE3001 (Orange)
- **Font Family:** ProductSans
- **Theme:** Light mode with modern, clean aesthetics
- **Layout:** Sidebar + Top bar + Content area

## 🌐 API Integration

Base URL: `https://demo.doctorshero.com`

Endpoints:
- `POST /api/mobile/auth/login` - User authentication
- `GET /api/mobile/auth/me` - Get current user details

## 📦 Dependencies

- `provider` - State management
- `http` - API requests
- `shared_preferences` - Local storage
- `flutter_svg` - SVG support

## 🔒 Security

- Network permissions configured for macOS and Windows
- Token-based authentication
- Secure credential storage

## 👥 Contributors

- Orbizen Limited

## 📄 License

Copyright © 2026 DoctorsHero. All Rights Reserved by Modern Mediks Ltd.

## 🐛 Issues

Report issues at: https://github.com/orbizen-limited/doctorshero-rx/issues
