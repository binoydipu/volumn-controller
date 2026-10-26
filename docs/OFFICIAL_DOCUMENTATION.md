# Official Documentation References

This document lists the official documentation sources relevant to the Volumn Controller application, along with what each governs and important version-specific requirements.

## Flutter & Dart

| Resource | URL | Governs |
|---|---|---|
| Flutter documentation | https://docs.flutter.dev/ | Framework APIs, widget catalog, platform integration |
| Flutter stable releases | https://docs.flutter.dev/release/release-notes | Release notes, breaking changes, migration guides |
| Dart SDK | https://dart.dev/ | Language features, SDK compatibility, null safety |
| Flutter MethodChannel | https://docs.flutter.dev/platform-integration/platform-channels | Platform channel communication between Dart and native code |

**Version-specific:** Flutter 3.47.3 ships with Dart 3.13.3. The `^3.13.3` SDK constraint in `pubspec.yaml` ensures compatibility.

## Android Platform

| Resource | URL | Governs |
|---|---|---|
| Android developer docs | https://developer.android.com/ | Platform APIs, best practices, design guidelines |
| Android SDK platforms | https://developer.android.com/tools/releases/platforms | API level features, behavior changes per version |
| AudioManager reference | https://developer.android.com/reference/android/media/AudioManager | Volume control APIs: `adjustStreamVolume()`, `getStreamVolume()`, `getStreamMaxVolume()`, `getStreamMinVolume()`, stream constants |
| Foreground services | https://developer.android.com/develop/background-work/services/fgs | Service types, permissions, start restrictions, API 34+ type requirements, `FOREGROUND_SERVICE_TYPE_SPECIAL_USE` |
| Foreground service types | https://developer.android.com/about/versions/14/changes/fgs-types-required | API 34+ requirement to declare and specify foreground service types |
| Notifications | https://developer.android.com/develop/ui/views/notifications | Notification channels, importance levels, ongoing notifications |
| Notification permission | https://developer.android.com/develop/ui/views/notifications/notification-permission | `POST_NOTIFICATIONS` runtime permission (API 33+) |
| App widgets | https://developer.android.com/develop/ui/views/appwidgets | Widget providers, RemoteViews, metadata XML, PendingIntents |
| App widget overview | https://developer.android.com/develop/ui/views/appwidgets/overview | Widget lifecycle, `onUpdate()`, `AppWidgetProvider`, responsive layouts |
| BOOT_COMPLETED | https://developer.android.com/reference/android/content/Intent#ACTION_BOOT_COMPLETED | Restoring services after reboot; requires `RECEIVE_BOOT_COMPLETED` permission |
| Battery optimization | https://developer.android.com/topic/performance/power/power-details | Doze mode, app standby, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` |

**Version-specific requirements:**
- **API 33 (Android 13):** `POST_NOTIFICATIONS` runtime permission required for notifications.
- **API 34 (Android 14):** Foreground service type must be declared in manifest AND specified in `startForeground()` call. `FOREGROUND_SERVICE_TYPE_SPECIAL_USE` requires the `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` property.
- **API 35 (Android 15):** Additional restrictions on `BOOT_COMPLETED` receivers and foreground service starts from background. `startForegroundService()` from a boot receiver remains permitted.
- **API 36 (Android 16):** Current target. No additional restrictions on the APIs used by this app beyond API 35.

## Build Toolchain

| Resource | URL | Governs |
|---|---|---|
| Android Gradle Plugin releases | https://developer.android.com/build/releases/gradle-plugin | AGP version features, minimum Gradle requirements |
| AGP–Gradle compatibility | https://developer.android.com/build/releases/gradle-plugin#updating-gradle | Version compatibility matrix |
| Gradle compatibility | https://docs.gradle.org/current/userguide/compatibility.html | JDK and Gradle version compatibility |
| Kotlin releases | https://kotlinlang.org/docs/releases.html | KGP version history, compatibility notes |

**Compatibility chain:** AGP 9.1.0 → requires Gradle ≥ 9.3.1 → requires JDK ≥ 17. Kotlin 2.4.0 is compatible with AGP 9.1.0.

## Third-Party Packages

| Package | URL | Purpose |
|---|---|---|
| shared_preferences | https://pub.dev/packages/shared_preferences | Local key-value storage for user preferences |

**Note:** `shared_preferences` is used only on the Flutter side for convenience. Native Android components (services, receivers, widgets) use `SharedPreferences` directly via `Context.getSharedPreferences()` to avoid requiring a Flutter engine.

