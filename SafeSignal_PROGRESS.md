# SafeSignal — Progress Tracker

**Початок розробки:** 2026-06-15  
**Поточна фаза:** Тиждень 3–4 (Медпрофіль і контакти)

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
| flutter_secure_storage setup | WIP | 2026-06-15 | Залежність додана, використання — ні |
| Splash screen + auth redirect | DONE | 2026-06-15 | Auth + onboarding gate |
| Onboarding (3 slides) | DONE | 2026-06-15 | 3 слайди + completion flow |
| Disclaimer dialog (перший запуск) | WIP | 2026-06-15 | Текст є, UI dialog — ні |

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
| Home screen з SOS button | - | | |
| SOS button — long press 2s + countdown 3s | - | | |
| SOS cancel during countdown | - | | |
| Video recording (camera plugin) | - | | |
| GPS location (geolocator) | - | | |
| Reverse geocoding → address | - | | |
| Video upload → Firebase Storage | - | | |
| Alert save → Firestore | - | | |
| Telegram Bot — send message (Cloud Function) | - | | |
| Signed URL generation (Cloud Function) | - | | |
| SOS confirmation screen + delivery status | - | | |
| Self-notification via FCM Push | - | | |

## Тиждень 7–8: SMS + Офлайн + Сценарії

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Twilio SMS via Cloud Function | - | | |
| Offline queue (Hive + connectivity_plus) | - | | |
| Offline queue auto-retry on network restore | - | | |
| Scenarios list screen | - | | |
| Scenario create/edit screen | - | | |
| Default scenario auto-create on registration | - | | |
| Message template with variable substitution | - | | |
| Active scenario switcher (bottom sheet on home) | - | | |

## Тиждень 9–10: Полірування MVP

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Alert history screen | - | | |
| Alert detail screen (video player, map, contacts) | - | | |
| QR medical card (basic) | - | | |
| Status bar on home (GPS, network, profile icons) | - | | |
| Test notification button for contacts | - | | |
| Immobility detection (background service) | - | | |
| Auto-trigger SOS (background, no video) | - | | |
| Off-Grid mode settings screen | - | | |

## Тиждень 9–10 (продовження): Quick SOS

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Deep link safesignal://sos (GoRouter) | - | | |
| Home Screen Widget (home_widget, Android) | - | | |
| Home Screen Widget (iOS widget extension) | - | | |
| Persistent Notification з SOS кнопкою (Android) | - | | Foreground Service |
| Shake-to-SOS detection | - | | sensors_plus |
| Shake confirmation notification | - | | |
| Shake settings toggle (Settings screen) | - | | |
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
