# Technical Decisions

Verified and documented on 2026-10-26.

## Toolchain Versions

| Component | Version | Source | Rationale |
|---|---|---|---|
| **Flutter** | 3.47.3 (stable) | Locally installed; https://docs.flutter.dev/ | Latest stable installed on build machine |
| **Dart SDK** | 3.13.3 (stable) | Bundled with Flutter 3.47.3 | Automatically matched by Flutter |
| **Android Gradle Plugin** | 9.1.0 | Flutter 3.47.3 default; https://developer.android.com/build/releases/gradle-plugin | Flutter's verified default for 3.47.x |
| **Gradle** | 9.3.1 | Flutter 3.47.3 default; https://docs.gradle.org/current/userguide/compatibility.html | Minimum required by AGP 9.1.0 |
| **Kotlin** | 2.4.0 | Flutter 3.47.3 default; https://kotlinlang.org/docs/releases.html | Flutter's verified Kotlin version |
| **JDK** | 17 (Temurin 17.0.9) | Locally installed | Required by AGP 9.x; embedded JBR used by Gradle wrapper |
| **compileSdk** | 36 | https://developer.android.com/tools/releases/platforms | Android 16 — latest stable API level |
| **targetSdk** | 36 | https://developer.android.com/distribute/best-practices/develop/target-sdk | Google Play requirement for 2026 |
| **minSdk** | 24 | https://developer.android.com/tools/releases/platforms | Android 7.0 — covers ~95% of active devices; balances API availability with reach |

### Compatibility Verification

- AGP 9.1.0 requires Gradle ≥ 9.3.1 ✓ (using 9.3.1)
- AGP 9.1.0 requires JDK ≥ 17 ✓ (using JDK 17)
- Kotlin 2.4.0 compatible with AGP 9.1.0 ✓
- Flutter 3.47.3 tested with AGP 9.1.0 + Gradle 9.3.1 + Kotlin 2.4.0 ✓
- compileSdk 36 supported by AGP 9.1.0 ✓
- All APIs used available from minSdk 24 ✓ (except POST_NOTIFICATIONS which is API 33+, handled with version checks)

## Architectural Decisions

### 1. Native Kotlin for all Android-specific features

**Decision:** Implement foreground service, notifications, broadcast receivers, widget providers, and volume control entirely in Kotlin. Use Flutter only for the settings UI.

**Rationale:**
- Notification and widget actions must work independently of the Flutter engine.
- A running Flutter engine is expensive and unnecessary for simple volume adjustments.
- Native BroadcastReceivers respond to intents directly without process-level overhead.
- SharedPreferences are accessible from both Flutter (via `shared_preferences` package) and native Kotlin code.

### 2. MethodChannel for Flutter ↔ Native communication

**Decision:** Use a single `MethodChannel("com.volumncontroller/volume")` for all Flutter-to-native calls.

**Rationale:**
- Simple, well-documented, and sufficient for the app's needs.
- No need for EventChannels (no continuous data streams).
- All calls are request-response, fitting the MethodChannel model.

### 3. FOREGROUND_SERVICE_TYPE_SPECIAL_USE

**Decision:** Use `specialUse` foreground service type with a descriptive `PROPERTY_SPECIAL_USE_FGS_SUBTYPE`.

**Rationale:**
- Volume control does not fit other predefined service types (mediaPlayback, location, camera, etc.).
- `specialUse` is the sanctioned type for services that don't match predefined categories.
- A clear subtype description explains the purpose for Google Play review.
- On API < 34, no service type is required in `startForeground()`.

### 4. Shared VolumeHelper singleton

**Decision:** Centralize all volume operations in a `VolumeHelper` object used by the service, receiver, and activity.

**Rationale:**
- Single source of truth for stream type mapping and AudioManager interactions.
- Avoids duplicating volume logic across notification actions, widget actions, and the Flutter UI.
- Stateless design — no risk of stale references across process restarts.

### 5. BroadcastReceiver for notification and widget actions

**Decision:** Use a single `VolumeActionReceiver` for all volume-control intents from both notifications and widgets.

**Rationale:**
- Notification action buttons and widget buttons both fire PendingIntents.
- A BroadcastReceiver is the lightest-weight component for handling these.
- No Flutter engine needed — the receiver reads SharedPreferences and calls AudioManager directly.

### 6. SharedPreferences for settings persistence

**Decision:** Use Android's native `SharedPreferences` ("volumn_controller_prefs") as the single source of truth.

**Rationale:**
- Readable from all components: Activity, Service, BroadcastReceiver, AppWidgetProvider.
- No database setup required for two boolean/string preferences.
- Flutter's `shared_preferences` package also reads from Android SharedPreferences, ensuring consistency.

### 7. START_STICKY service restart policy

**Decision:** Return `START_STICKY` from `onStartCommand()`.

**Rationale:**
- Tells Android to restart the service if it's killed due to memory pressure.
- Combined with the `BootReceiver`, provides best-effort persistence.
- Does not guarantee the service is always running — Android can still force-stop apps.

### 8. No internet permission

**Decision:** The app requests no internet access.

**Rationale:**
- No feature requires network connectivity.
- Reduces attack surface and eliminates a common user concern.
- The `INTERNET` permission is not declared in the manifest.

### 9. Dark theme only

**Decision:** Use Material 3 dark theme with `colorSchemeSeed: Colors.deepPurple`.

**Rationale:**
- Matches the requirement for a minimal, clean, dark-themed settings screen.
- Reduces battery consumption on OLED displays.
- Material 3 provides accessible contrast ratios automatically.

## Known Limitations

1. **Service persistence is best-effort.** Android's Doze mode, battery optimization, and manufacturer-specific power management can stop the foreground service. The app provides a link to battery optimization settings and documents this limitation for users.

2. **`getRunningServices()` is deprecated.** Used to check whether the service is running. While deprecated, it still functions and is the standard approach for first-party service status checks. Android has not provided a replacement API.

3. **Boot restoration may fail on some devices.** Some manufacturers (Xiaomi, Huawei, Samsung) have additional autostart restrictions beyond standard Android behavior. Users must manually allow autostart on these devices.

4. **Widget theme limitations.** Home-screen widgets use `RemoteViews`, which do not support full Material 3 theming. The widget uses a semi-transparent dark background that works reasonably well on most launchers.

5. **Volume panel display from background.** On Android 10+, showing the system volume panel from a BroadcastReceiver (triggered by notification/widget action) may be restricted. The `adjustStreamVolume` with `FLAG_SHOW_UI` approach works from foreground services but may be limited from background-only contexts.

