# DoctorsHero Core - Codemagic CI/CD Setup

## 🚀 Automated Windows Build with Codemagic

Codemagic will automatically build, package, and release your Windows application!

## 📋 Setup Steps

### 1. Connect to Codemagic

1. Go to [codemagic.io](https://codemagic.io)
2. Sign in with GitHub
3. Add your repository: `orbizen-limited/doctorshero-rx`

### 2. Configure Workflows

The `codemagic.yaml` file is already configured with 3 workflows:

#### **Workflow 1: Windows Release** (Main Branch)
- Triggers on push to `main` branch
- Builds Windows release
- Creates ZIP package
- Uploads to GitHub Releases
- Generates `version.json` for auto-update

#### **Workflow 2: Windows Installer** (Tags)
- Triggers on version tags (v1.0.0, v1.0.1, etc.)
- Builds Windows release
- Installs Inno Setup
- Compiles professional installer
- Uploads installer to GitHub Releases
- Generates version API response

#### **Workflow 3: Windows Development** (Pull Requests)
- Triggers on pull requests
- Runs tests
- Builds debug version
- Quick feedback for developers

### 3. Enable Workflows in Codemagic

1. In Codemagic dashboard, select your app
2. Go to **Settings** > **Workflow settings**
3. The workflows will be auto-detected from `codemagic.yaml`
4. Enable the workflows you want

### 4. Configure GitHub Releases (Optional)

For automatic GitHub releases:

1. In Codemagic, go to **App settings** > **Integrations**
2. Connect GitHub
3. Enable **GitHub Releases** publishing
4. Codemagic will create releases automatically

### 5. Set Environment Variables (Optional)

In Codemagic dashboard > **Environment variables**:

```
APP_NAME=DoctorsHero Core
PACKAGE_NAME=com.doctorshero.core
```

## 🏷️ Release Process

### Automatic Release (Recommended)

**For ZIP Package:**
```bash
git add .
git commit -m "Release v1.0.1"
git push origin main
```
→ Codemagic builds and creates ZIP automatically

**For Installer:**
```bash
git tag v1.0.1
git push origin v1.0.1
```
→ Codemagic builds installer automatically

### What Happens:

1. **Push to main** or **Create tag**
2. Codemagic detects the change
3. Starts Windows build (takes ~10-15 minutes)
4. Builds application
5. Creates installer (if tag)
6. Uploads to GitHub Releases
7. Generates `version.json`
8. Sends email notification

## 📦 Build Outputs

### After Build Completes:

#### **ZIP Package** (from main branch):
```
DoctorsHero_Core_v1.0.0_build123.zip
├── DoctorsHero_Core.exe
├── flutter_windows.dll
├── data/
└── ... (all dependencies)
```

#### **Installer** (from tag):
```
DoctorsHero_Core_Setup_v1.0.0.exe
```

#### **Version API**:
```json
{
  "version": "1.0.0",
  "build_number": 123,
  "download_url": "https://github.com/.../DoctorsHero_Core_Setup_v1.0.0.exe",
  "release_date": "2025-11-30"
}
```

## 🔄 Auto-Update Setup

### 1. Host version.json

After each release, Codemagic creates `version.json`. Host it at:
```
https://api.doctorshero.com/app/version
```

**Options:**
- **GitHub Pages**: Use the artifact directly
- **Your Server**: Download and upload manually
- **Cloudflare Workers**: Proxy from GitHub Releases
- **Firebase Hosting**: Simple static hosting

### 2. Update Service Configuration

The `lib/services/update_service.dart` is already configured to check:
```dart
static const String updateCheckUrl = 'https://api.doctorshero.com/app/version';
```

Just update this URL to where you host `version.json`.

### 3. Enable in App

Add to your main screen:
```dart
import 'package:doctorshero_rx/services/update_service.dart';

@override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      UpdateService.checkForUpdates(context);
    }
  });
}
```

## 📊 Build Status

### Check Build Status:

1. Go to Codemagic dashboard
2. See all builds and their status
3. Download artifacts
4. View logs

### Build Notifications:

- Email on success/failure
- Slack integration (optional)
- Discord webhooks (optional)

## 🎯 Version Management

### Semantic Versioning:

```
v1.0.0 → Initial release
v1.0.1 → Bug fixes
v1.1.0 → New features
v2.0.0 → Major changes
```

### Update Version:

**In `pubspec.yaml`:**
```yaml
version: 1.0.1+2  # version+build_number
```

**Then tag:**
```bash
git tag v1.0.1
git push origin v1.0.1
```

Codemagic automatically uses the tag version!

## 🛠️ Customization

### Modify Build Script:

Edit `codemagic.yaml` to:
- Change build commands
- Add custom scripts
- Modify artifact patterns
- Update publishing settings

### Add Code Signing (Future):

```yaml
environment:
  groups:
    - windows_signing
  vars:
    CERTIFICATE_PATH: $CM_CERTIFICATE_PATH
```

## 📈 Workflow Comparison

| Feature | Manual Build | Codemagic |
|---------|-------------|-----------|
| Build Time | 15-30 min | 10-15 min |
| Setup | Complex | Automatic |
| Installer | Manual | Automatic |
| GitHub Release | Manual | Automatic |
| Version API | Manual | Automatic |
| Notifications | None | Email/Slack |
| Consistency | Varies | Always same |

## 🎉 Benefits

✅ **Automated**: Push code, get installer
✅ **Consistent**: Same build every time
✅ **Fast**: Parallel builds, cached dependencies
✅ **Professional**: GitHub releases, version API
✅ **Easy**: No local setup needed
✅ **Reliable**: Build logs, artifacts stored

## 🚦 Quick Start

1. **Connect Codemagic** to your GitHub repo
2. **Push to main** → Get ZIP package
3. **Create tag** → Get installer
4. **Download artifacts** from Codemagic or GitHub Releases
5. **Host version.json** for auto-updates
6. **Done!** 🎉

## 📞 Support

- Codemagic Docs: https://docs.codemagic.io
- Flutter Windows: https://docs.flutter.dev/desktop
- Issues: Create GitHub issue

---

**No more manual builds! Just push and Codemagic handles everything!** 🚀
