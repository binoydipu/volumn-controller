# Volumn Controller

A lightweight Android volume controller built with Flutter (UI) and native Kotlin (services, widgets, notifications). Provides persistent notification controls and home-screen widgets for quick volume adjustment — all without internet access.

## Features

- **Persistent Notification** — Silent, ongoing notification with Vol −, Vol +, and Panel buttons
- **Home-Screen Widgets** — Three native widgets (1×1, 1×2, 1×3) that work without the app open
- **Volume Type Selection** — Control Media, Ringtone, Alarm, or System volume
- **Boot Persistence** — Notification auto-restarts after reboot (when enabled)
- **No Internet** — Zero network permissions; everything runs locally

## Requirements

- Android 7.0+ (API 24)
- Flutter 3.47.3+ with Dart 3.13.3+
- JDK 17

## Build & Run

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

The built APK is at `build/app/outputs/flutter-apk/app-debug.apk` (debug) or `app-release.apk` (release).

## Install APK

```bash
# Install via ADB
adb install build/app/outputs/flutter-apk/app-debug.apk
```

Or transfer the APK file to your device and install it from a file manager.

## Testing Checklist

These tests require a physical Android device or emulator:

| Test | Steps | Expected |
|------|-------|----------|
| **Notification toggle** | Enable notification in settings | Persistent notification appears with Vol −, Vol +, Panel |
| **Notification Vol +/−** | Tap Vol + or Vol − on notification | Volume changes AND native volume panel appears |
| **Notification Panel** | Tap Panel on notification | Native volume panel appears |
| **Widget 1×1** | Add Vol Panel widget to home screen, tap it | Native volume panel appears |
| **Widget 1×2** | Add Vol +/− widget, tap buttons | Volume adjusts, volume panel appears |
| **Widget 1×3** | Add Vol Controls widget, tap buttons | All three buttons work independently |
| **Volume type** | Change to Ringtone/Alarm/System in settings | Volume controls affect the selected stream |
| **Permission denied** | Deny notification permission | Dialog explains and links to settings |
| **App closed** | Close app from recents, use notification/widget | Controls still work |
| **Reboot** | Reboot device with notification enabled | Notification reappears automatically |
| **Rapid taps** | Tap Vol+ rapidly multiple times | Volume increases step by step without crashes |
| **Volume boundaries** | Hold Vol+ at max or Vol− at min | No crash, volume stays at boundary |
| **Battery optimization** | Open battery settings from app | Settings page opens correctly |

## Android Settings Required

1. **Notification Permission** — Required on Android 13+ for the persistent notification
2. **Battery Optimization** — Recommend disabling for this app to prevent the system from stopping the notification service
3. **Autostart** (manufacturer-specific) — On Xiaomi, Huawei, Samsung: allow the app to autostart for reliable boot restoration

## Known Limitations

- Android may force-stop background services to save battery; persistence is best-effort
- Some manufacturers restrict autostart beyond standard Android behavior
- Home-screen widgets use RemoteViews, which cannot fully match Material 3 theming
- `getRunningServices()` is deprecated but still functional; no replacement API exists

## Project Structure

```
lib/
  main.dart                     # Flutter UI (settings screen)
android/app/src/main/
  kotlin/.../
    MainActivity.kt             # MethodChannel bridge to native
    VolumeHelper.kt             # Shared volume control logic
    VolumeNotificationService.kt # Foreground service
    VolumeActionReceiver.kt     # BroadcastReceiver for actions
    BootReceiver.kt             # BOOT_COMPLETED handler
    VolumeWidget1x1.kt          # 1×1 widget provider
    VolumeWidget1x2.kt          # 1×2 widget provider
    VolumeWidget1x3.kt          # 1×3 widget provider
  res/
    layout/widget_*.xml         # Widget layouts
    xml/widget_*_info.xml       # Widget metadata
    drawable/widget_background.xml
    values/strings.xml
  AndroidManifest.xml           # Permissions, services, receivers, widgets
docs/
  OFFICIAL_DOCUMENTATION.md     # Referenced official documentation
  TECHNICAL_DECISIONS.md        # Version choices and architectural rationale
```

## Documentation

- [Official Documentation References](docs/OFFICIAL_DOCUMENTATION.md)
- [Technical Decisions](docs/TECHNICAL_DECISIONS.md)
