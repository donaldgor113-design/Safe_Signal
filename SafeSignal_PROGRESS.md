# SafeSignal — Progress Tracker

**Початок розробки:** 2026-06-15  
**Поточна фаза:** Тиждень 7–8 (SMS + Офлайн + Сценарії)

---

## Тиждень 1–2: Фундамент

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Flutter проект (FlutterFire CLI) | DONE | 2026-06-15 | Firebase core + all plugins in pubspec |
| Firebase Auth (email/пароль + Google) | DONE | 2026-06-15 | Email/password done; Google Sign-In — ще не реалізовано |
| GoRouter навігація (всі маршрути, заглушки) | DONE | 2026-06-15 | Всі маршрути + redirect logic |
| Riverpod структура (base providers) | DONE | 2026-06-15 | Manual providers (без codegen) |
| Базова тема (Material 3, кольори, шрифти) | DONE | 2026-06-15 | Light/dark + SafeSignalColors extension |
| Hive ініціалізація (boxes: offline_queue, gps_log, app_settings) | DONE | 2026-06-15 | 3 boxes в main.dart |
| flutter_secure_storage setup | DONE | 2026-06-16 | Used in NotificationService for FCM token storage |
| Splash screen + auth redirect | DONE | 2026-06-15 | Auth + onboarding gate |
| Onboarding (3 slides) | DONE | 2026-06-15 | 3 слайди + completion flow |
| Disclaimer dialog (перший запуск) | DONE | 2026-06-16 | AlertDialog in SplashScreen with Hive persistence |

## Тиждень 3–4: Медпрофіль і контакти

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Medical profile screen (all fields) | DONE | 2026-06-15 | Diagnoses, meds, allergies, blood type, doctor contact |
| Medical profile — Firestore CRUD | DONE | 2026-06-15 | Repository + StreamProvider |
| Medical profile — local encryption (flutter_secure_storage) | - | | Deferred — Firestore offline persistence used for now |
| Contacts list screen | DONE | 2026-06-15 | Cards + swipe-to-delete + empty state |
| Contact add/edit screen | DONE | 2026-06-15 | Full form with validation |
| Contacts — Firestore CRUD | DONE | 2026-06-15 | Repository + StreamProvider |
| Telegram Chat ID — instructions UI | DONE | 2026-06-15 | Dialog with step-by-step instructions |
| Profile completeness banner (home screen) | DONE | 2026-06-15 | Warning banner + status bar icon |

## Тиждень 5–6: SOS Flow

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Home screen з SOS button | DONE | 2026-06-16 | Long press 2s with progress ring, disabled state if no contacts |
| SOS button — long press 2s + countdown 3s | DONE | 2026-06-16 | Hold animation + 3-sec countdown with scale animation |
| SOS cancel during countdown | DONE | 2026-06-16 | Cancel button during countdown + recording |
| Video recording (camera plugin) | DONE | 2026-06-16 | Front camera, VideoService with init/start/stop |
| GPS location (geolocator) | DONE | 2026-06-16 | LocationService with permission handling |
| Reverse geocoding → address | DONE | 2026-06-16 | geocoding plugin in LocationService |
| Video upload → Firebase Storage | DONE | 2026-06-16 | StorageService with Firebase Storage |
| Alert save → Firestore | DONE | 2026-06-16 | AlertRepository + AlertModel with Firestore CRUD |
| Telegram Bot — send message (Cloud Function) | DONE | 2026-06-16 | functions/index.js sendSosAlert with Telegram Bot API |
| Signed URL generation (Cloud Function) | DONE | 2026-06-16 | functions/index.js generateSignedUrl callable |
| SOS confirmation screen + delivery status | DONE | 2026-06-16 | 4-phase UI: countdown → recording → sending → done/offline |
| Self-notification via FCM Push | DONE | 2026-06-16 | NotificationService: token init, refresh, Firestore sync, background handler |

## Тиждень 7–8: SMS + Офлайн + Сценарії

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Twilio SMS via Cloud Function | DONE | 2026-06-16 | Cloud Functions sendSosAlert with SMS (Week 5-6) |
| Offline queue (Hive + connectivity_plus) | DONE | 2026-06-16 | OfflineQueueService with Hive box persistence |
| Offline queue auto-retry on network restore | DONE | 2026-06-16 | Connectivity listener + exponential backoff retry |
| Scenarios list screen | DONE | 2026-06-16 | ScenariosScreen with list, delete, preview |
| Scenario create/edit screen | DONE | 2026-06-16 | AddScenarioScreen with contact selection |
| Default scenario auto-create on registration | DONE | 2026-06-16 | Integrated in RegisterScreen after signUp |
| Message template with variable substitution | DONE | 2026-06-16 | MessageTemplateService with {{variable}} substitution |
| Active scenario switcher (bottom sheet on home) | DONE | 2026-06-16 | Bottom sheet with scenario list + activeScenarioProvider |

## Тиждень 9–10: Полірування MVP

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Alert history screen | DONE | 2026-06-16 | AlertsStreamProvider + list with status badges |
| Alert detail screen (video player, map, contacts) | DONE | 2026-06-16 | Video player + location + delivery status |
| QR medical card (basic) | DONE | 2026-06-16 | qr_flutter with medical profile data |
| Status bar on home (GPS, network, profile icons) | DONE | 2026-06-15 | Already in home_screen.dart Week 3-4 |
| Test notification button for contacts | DONE | 2026-06-16 | Cloud Function sendTestNotification + UI button on contacts |
| Immobility detection (background service) | DONE | 2026-06-16 | ImmobilityDetectionService with sensors_plus + settings toggle |
| Auto-trigger SOS (background, no video) | DONE | 2026-06-16 | SosService.startAutoTriggerSos() — GPS only, no video |
| Off-Grid mode settings screen | DONE | 2026-06-16 | Settings screen with Hive toggle |

## Тиждень 9–10 (продовження): Quick SOS

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Deep link safesignal://sos (GoRouter) | DONE | 2026-06-16 | /sos route redirects to /sos-direct |
| Home Screen Widget (home_widget, Android) | WIP | 2026-06-16 | Dart service done, needs native XML layout after flutter create |
| Home Screen Widget (iOS widget extension) | WIP | 2026-06-16 | Dart service done, needs native Swift widget after flutter create |
| Persistent Notification з SOS кнопкою (Android) | WIP | 2026-06-16 | Dart service done, needs Android channel config after flutter create |
| Shake-to-SOS detection | DONE | 2026-06-16 | ShakeDetectionService with sensors_plus, 3 shakes in 1s |
| Shake confirmation notification | DONE | 2026-06-16 | AlertDialog confirmation before triggering SOS |
| Shake settings toggle (Settings screen) | DONE | 2026-06-16 | Already in settings_screen.dart (Hive toggle) |
| Quick Settings Tile (Android, Kotlin) | - | | Нативний код |
| Real device testing (iOS + Android) | - | | |
| App Store / Google Play preparation | - | | |

---

## Legend

| Symbol | Meaning |
|---|---|
| - | Not started |
| WIP | In progress |
| DONE | Completed |
| SKIP | Skipped / deferred |
| BUG | Has known bug |

---

## Week 7–8 Verification (Bug Fixes)

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Offline queue — index mutation bug | DONE | 2026-06-16 | Fixed: key-based iteration instead of index-based, safe type casts |
| Offline queue — Riverpod provider init | DONE | 2026-06-16 | offlineQueueServiceProvider + ref.watch in HomeScreen |
| ScenarioModel — createdAt overwrite on update | DONE | 2026-06-16 | Added toUpdateMap() that only sets updatedAt |
| AddScenarioScreen — validation fixes | DONE | 2026-06-16 | Empty template check, int.tryParse with defaults |

---

## Known Issues

_None yet._

---

## Version 2.0 Backlog

- Email channel for contacts
- FCM Push for contacts (requires contact to install app)
- Garmin inReach integration
- OCR medication scanning
- iPhone 14+ Satellite SOS
- AI-based trigger analysis
- Wearable integrations
