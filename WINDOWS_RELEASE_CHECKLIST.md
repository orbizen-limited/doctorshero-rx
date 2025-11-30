# DoctorsHero Core - Windows Release Checklist

## ✅ Pre-Build Setup (Done)

- [x] Application name changed to "DoctorsHero Core"
- [x] Window title updated
- [x] Binary name set to "DoctorsHero_Core.exe"
- [x] Auto-update service created
- [x] Inno Setup installer script configured
- [x] Version management system ready

## 📋 Build Process

### On Your Windows PC:

#### 1. Install Prerequisites

```bash
# Install Flutter
# Download from: https://flutter.dev/docs/get-started/install/windows

# Install Visual Studio 2022 Community Edition
# Download from: https://visualstudio.microsoft.com/downloads/
# Select: "Desktop development with C++"

# Install Inno Setup 6
# Download from: https://jrsoftware.org/isdl.php
```

#### 2. Clone and Setup

```bash
git clone https://github.com/orbizen-limited/doctorshero-rx.git
cd doctorshero-rx
flutter pub get
```

#### 3. Build Application

**Option A: Use Build Script (Recommended)**
```bash
build_windows.bat
```

**Option B: Manual Build**
```bash
flutter clean
flutter pub get
flutter build windows --release
```

#### 4. Test the Application

```bash
# Run the built executable
build\windows\x64\runner\Release\DoctorsHero_Core.exe
```

**Test Checklist:**
- [ ] Application opens without errors
- [ ] Window title shows "DoctorsHero Core"
- [ ] All features work correctly
- [ ] PDF generation works
- [ ] Medicine database loads
- [ ] Settings are saved

#### 5. Create Installer Images (Optional but Recommended)

See: `windows/INSTALLER_IMAGES_GUIDE.md`

Create these files:
- `windows/installer_banner.bmp` (164 x 314 pixels)
- `windows/installer_icon.bmp` (55 x 58 pixels)

**Quick Tip:** Use Canva or Figma with your brand colors (#FE3001)

#### 6. Build Installer

1. Open **Inno Setup Compiler**
2. File > Open: `windows/installer.iss`
3. Build > Compile
4. Installer created in: `build/windows/installer/`

**Output File:**
```
DoctorsHero_Core_Setup_v1.0.0.exe
```

#### 7. Test Installer

- [ ] Run installer on clean Windows machine
- [ ] Verify installation completes
- [ ] Check desktop shortcut created
- [ ] Launch application from Start Menu
- [ ] Uninstall and verify clean removal

#### 8. Test Upgrade Flow

1. Install version 1.0.0
2. Update version to 1.0.1 in:
   - `pubspec.yaml`
   - `windows/installer.iss`
3. Build new installer
4. Run new installer
5. Verify upgrade detection works
6. Verify settings preserved

## 🚀 Distribution

### 1. Upload Installer

Upload to your server:
```
https://doctorshero.com/downloads/DoctorsHero_Core_Setup_v1.0.0.exe
```

### 2. Setup Version API

Create endpoint: `https://api.doctorshero.com/app/version`

Use the example from: `version_api_example.json`

```json
{
  "version": "1.0.0",
  "download_url": "https://doctorshero.com/downloads/DoctorsHero_Core_Setup_v1.0.0.exe"
}
```

### 3. Enable Auto-Update

Add to your main screen (`lib/screens/home_screen.dart` or similar):

```dart
import 'package:doctorshero_rx/services/update_service.dart';

@override
void initState() {
  super.initState();
  // Check for updates after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      UpdateService.checkForUpdates(context);
    }
  });
}
```

### 4. Distribute

- [ ] Share installer link with users
- [ ] Create download page on website
- [ ] Send email to existing users
- [ ] Post on social media

## 🔄 Future Updates

### When Releasing New Version:

1. **Update Version Numbers:**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2
   ```
   
   ```iss
   # windows/installer.iss
   #define MyAppVersion "1.0.1"
   ```

2. **Build:**
   ```bash
   flutter build windows --release --build-name=1.0.1 --build-number=2
   ```

3. **Create Installer:**
   - Compile with Inno Setup
   - New file: `DoctorsHero_Core_Setup_v1.0.1.exe`

4. **Upload:**
   - Upload new installer
   - Update version API

5. **Users Get Notified:**
   - Auto-update dialog appears
   - One-click download
   - Automatic upgrade

## 📊 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-30 | Initial release |
| 1.0.1 | TBD | Bug fixes and improvements |

## 🆘 Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter build windows --release
```

### Installer Won't Compile
- Check all paths in `installer.iss`
- Verify Release build exists
- Ensure Inno Setup installed correctly

### Auto-Update Not Working
- Check API endpoint is accessible
- Verify JSON format matches example
- Test with Postman/browser first

## 📞 Support

- Documentation: `WINDOWS_BUILD_GUIDE.md`
- Installer Images: `windows/INSTALLER_IMAGES_GUIDE.md`
- Version API: `version_api_example.json`

## ✨ What You Get

✅ **Professional Installer**
- Modern UI matching your brand
- Automatic upgrade detection
- Desktop shortcuts
- Start menu integration

✅ **Auto-Update System**
- Checks for updates on launch
- Beautiful update dialog
- One-click download
- Version comparison

✅ **Easy Distribution**
- Single .exe file
- No dependencies
- Works on Windows 10/11
- Professional appearance

---

**Ready to build? Run `build_windows.bat` on your Windows PC!** 🚀
