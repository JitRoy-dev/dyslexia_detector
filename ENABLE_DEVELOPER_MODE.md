# Enable Developer Mode for Flutter Build

## Issue

Flutter requires Developer Mode to be enabled on Windows to create symbolic links during the build process.

## Solution 1: Enable Developer Mode (Recommended)

### Method A: Using Settings UI

1. Press `Win + I` to open Settings
2. Go to **Privacy & Security** → **For developers**
3. Toggle **Developer Mode** to **ON**
4. Restart your terminal/command prompt

### Method B: Using Command

Run this command in PowerShell as Administrator:

```powershell
start ms-settings:developers
```

Then toggle Developer Mode ON.

### Method C: Using Registry (Advanced)

Run PowerShell as Administrator:

```powershell
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

## Solution 2: Build Without Symlinks (Alternative)

If you cannot enable Developer Mode, use this workaround:

```bash
cd d:\DYS_app\dyslexia_detector
flutter clean
flutter pub get --no-symlinks
flutter build apk --release
```

## After Enabling Developer Mode

Once Developer Mode is enabled, run:

```bash
cd d:\DYS_app\dyslexia_detector
flutter clean
flutter pub get
flutter build apk --release
```

## Verify Developer Mode is Enabled

Run in PowerShell:

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowDevelopmentWithoutDevLicense
```

Should return: `AllowDevelopmentWithoutDevLicense : 1`

## Build Commands After Setup

### Standard Release APK
```bash
flutter build apk --release
```

### Split APKs (Smaller size)
```bash
flutter build apk --split-per-abi --release
```

### App Bundle (For Play Store)
```bash
flutter build appbundle --release
```

## Output Location

After successful build, your APK will be at:
```
d:\DYS_app\dyslexia_detector\build\app\outputs\flutter-apk\app-release.apk
```

## Troubleshooting

### Still getting symlink error after enabling Developer Mode

1. Restart your computer
2. Open a new terminal/command prompt
3. Try the build again

### Cannot enable Developer Mode (Corporate/Restricted PC)

Use the `--no-symlinks` flag:
```bash
flutter pub get --no-symlinks
flutter build apk --release --no-symlinks
```

Note: This may cause some plugins to not work correctly.

### Permission denied errors

Run Command Prompt or PowerShell as Administrator:
1. Right-click on Command Prompt/PowerShell
2. Select "Run as administrator"
3. Navigate to project folder
4. Run build commands
