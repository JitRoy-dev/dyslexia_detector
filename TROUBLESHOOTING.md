# API Connection Troubleshooting Guide

## Problem: Flutter app not connecting to FastAPI backend

### Step 1: Verify Backend is Running

1. Open terminal in `backend` folder
2. Run: `python main.py`
3. You should see:
   ```
   INFO:     Started server process
   INFO:     Waiting for application startup.
   Model loaded successfully on cpu
   INFO:     Application startup complete.
   INFO:     Uvicorn running on http://0.0.0.0:8000
   ```

### Step 2: Test Backend Locally

Open a browser or new terminal and test:

```bash
# Test root endpoint
curl http://localhost:8000/

# Test health endpoint
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "device": "cpu"
}
```

### Step 3: Configure Correct API URL

Edit `lib/services/api_service.dart` and update `baseUrl`:

#### For Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

#### For iOS Simulator:
```dart
static const String baseUrl = 'http://localhost:8000';
```

#### For Physical Device:

1. Find your computer's IP address:
   - **Windows**: Open CMD and run `ipconfig`, look for "IPv4 Address"
   - **Mac/Linux**: Run `ifconfig` or `ip addr`, look for "inet" address
   - Example: `192.168.1.100`

2. Update the URL:
```dart
static const String baseUrl = 'http://192.168.1.100:8000';
```

3. **IMPORTANT**: Make sure your phone and computer are on the same WiFi network!

### Step 4: Check Firewall Settings

#### Windows:
1. Open "Windows Defender Firewall"
2. Click "Allow an app through firewall"
3. Make sure Python is allowed for both Private and Public networks

#### Mac:
1. System Preferences → Security & Privacy → Firewall
2. Click "Firewall Options"
3. Allow Python to accept incoming connections

### Step 5: Update Android Permissions

Make sure `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

Add this inside `<application>` tag if testing on Android 9+:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### Step 6: Check Flutter Console

Run your Flutter app with:
```bash
flutter run
```

Watch the console for error messages. The updated API service now prints:
- Connection attempts
- Response status codes
- Detailed error messages

### Step 7: Test Connection from Device

You can test if your device can reach the server:

#### Android:
Open Chrome on your Android device and navigate to:
```
http://YOUR_COMPUTER_IP:8000/health
```

#### iOS:
Open Safari on your iOS device and navigate to:
```
http://YOUR_COMPUTER_IP:8000/health
```

If you see the JSON response, the connection works!

### Common Issues and Solutions

#### Issue: "Connection refused"
- **Solution**: Backend is not running. Start it with `python main.py`

#### Issue: "Connection timeout"
- **Solution**: Wrong IP address or firewall blocking. Verify IP and check firewall.

#### Issue: "No route to host"
- **Solution**: Phone and computer not on same WiFi network.

#### Issue: "Certificate verification failed" (HTTPS error)
- **Solution**: Use HTTP (not HTTPS) for local development.

#### Issue: API works in browser but not in app
- **Solution**: Add `android:usesCleartextTraffic="true"` to AndroidManifest.xml

### Quick Test Checklist

- [ ] Backend running (`python main.py`)
- [ ] Can access `http://localhost:8000/health` in browser
- [ ] Correct IP address in `api_service.dart`
- [ ] Phone and computer on same WiFi (for physical device)
- [ ] Firewall allows Python
- [ ] Android manifest has INTERNET permission
- [ ] `usesCleartextTraffic="true"` set (Android 9+)

### Still Not Working?

1. Check Flutter console output for specific error messages
2. Check backend terminal for incoming requests
3. Try pinging your computer from your phone
4. Restart both backend and Flutter app
5. Try using Android emulator instead of physical device

### Debug Mode

The updated `api_service.dart` now includes debug prints. Check your Flutter console for:
```
Checking health at: http://10.0.2.2:8000/health
Health check status: 200
```

This will help identify where the connection is failing.
