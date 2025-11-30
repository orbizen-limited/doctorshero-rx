# DoctorsHero Core - Windows Build Guide

## Prerequisites

1. **Flutter SDK** (latest stable version)
2. **Visual Studio 2022** with "Desktop development with C++" workload
3. **Inno Setup 6** for creating the installer (download from https://jrsoftware.org/isdl.php)

## Building the Application

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Build Windows Release

```bash
flutter build windows --release
```

The built application will be in: `build/windows/x64/runner/Release/`

### Step 3: Create Installer

1. Open **Inno Setup Compiler**
2. Open the file: `windows/installer.iss`
3. Click **Build** > **Compile**
4. The installer will be created in: `build/windows/installer/`

## Installer Features

✅ **Professional Windows Installer**
- Modern UI matching app theme
- Automatic upgrade detection
- Preserves user settings during upgrades
- Desktop shortcut option
- Start menu integration

✅ **Auto-Update System**
- Checks for updates on app launch
- Beautiful update dialog
- One-click download and install
- Version comparison

## Customizing the Installer

### Update Branding

Edit `windows/installer.iss`:

```iss
#define MyAppName "DoctorsHero Core"
#define MyAppVersion "1.0.0"  ; Update this for each release
#define MyAppPublisher "DoctorsHero"
#define MyAppURL "https://doctorshero.com"
```

### Custom Images

Create these images for the installer:

1. **installer_banner.bmp** (164 x 314 pixels)
   - Left sidebar image shown during installation
   - Use your app's branding colors (#FE3001)

2. **installer_icon.bmp** (55 x 58 pixels)
   - Small icon shown in the top-right corner
   - Use your app logo

Place these files in the `windows/` directory.

## Auto-Update Configuration

### Server-Side Setup

Create an API endpoint at: `https://api.doctorshero.com/app/version`

Response format:
```json
{
  "version": "1.0.1",
  "download_url": "https://doctorshero.com/downloads/DoctorsHero_Core_Setup_v1.0.1.exe",
  "release_notes": "Bug fixes and improvements"
}
```

### Client-Side Integration

The update check is already integrated in `lib/services/update_service.dart`.

To trigger update check on app launch, add to your main screen:

```dart
import 'package:doctorshero_rx/services/update_service.dart';

@override
void initState() {
  super.initState();
  // Check for updates after a short delay
  Future.delayed(const Duration(seconds: 2), () {
    UpdateService.checkForUpdates(context);
  });
}
```

## Version Management

### Updating Version Number

Update in **3 places**:

1. **pubspec.yaml**
   ```yaml
   version: 1.0.1+2  # version+build_number
   ```

2. **windows/installer.iss**
   ```iss
   #define MyAppVersion "1.0.1"
   ```

3. **Build and release**
   ```bash
   flutter build windows --release --build-name=1.0.1 --build-number=2
   ```

## Distribution

### First Release

1. Build the installer
2. Upload to your server
3. Create version API endpoint
4. Distribute installer to users

### Updates

1. Increment version number in all 3 places
2. Build new installer
3. Upload to server
4. Update version API
5. Users will be notified automatically

## Testing the Installer

### Test Upgrade Flow

1. Install version 1.0.0
2. Build version 1.0.1
3. Run the new installer
4. Verify upgrade detection works
5. Verify settings are preserved

### Test Auto-Update

1. Set up a test API endpoint
2. Return a higher version number
3. Launch the app
4. Verify update dialog appears
5. Test "Update Now" button

## Troubleshooting

### Build Fails

```bash
# Clean build
flutter clean
flutter pub get
flutter build windows --release
```

### Installer Issues

- Ensure all paths in `installer.iss` are correct
- Check that the Release build exists
- Verify Inno Setup is installed correctly

### Update Check Fails

- Check API endpoint is accessible
- Verify JSON response format
- Check network connectivity
- Review logs in debug mode

## File Structure

```
doctorshero_rx/
├── windows/
│   ├── installer.iss          # Inno Setup script
│   ├── installer_banner.bmp   # Installer sidebar image
│   ├── installer_icon.bmp     # Installer icon
│   └── runner/
│       └── resources/
│           └── app_icon.ico   # Application icon
├── lib/
│   └── services/
│       └── update_service.dart # Auto-update logic
└── build/
    └── windows/
        ├── x64/runner/Release/ # Built application
        └── installer/          # Generated installer
```

## Support

For issues or questions:
- Email: support@doctorshero.com
- Documentation: https://docs.doctorshero.com
