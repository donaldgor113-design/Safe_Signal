# SafeSignal — Progress Tracker

**Початок розробки:** TBD  
**Поточна фаза:** Тиждень 1–2 (Фундамент)

---

## Тиждень 1–2: Фундамент

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Flutter проект (FlutterFire CLI) | - | | |
| Firebase Auth (email/пароль + Google) | - | | |
| GoRouter навігація (всі маршрути, заглушки) | - | | |
| Riverpod структура (base providers) | - | | |
| Базова тема (Material 3, кольори, шрифти) | - | | |
| Hive ініціалізація (boxes: offline_queue, gps_log, app_settings) | - | | |
| flutter_secure_storage setup | - | | |
| Splash screen + auth redirect | - | | |
| Onboarding (3 slides) | - | | |
| Disclaimer dialog (перший запуск) | - | | |

## Тиждень 3–4: Медпрофіль і контакти

| Задача | Статус | Дата | Примітки |
|---|---|---|---|
| Medical profile screen (all fields) | - | | |
| Medical profile — Firestore CRUD | - | | |
| Medical profile — local encryption (flutter_secure_storage) | - | | |
| Contacts list screen | - | | |
| Contact add/edit screen | - | | |
| Contacts — Firestore CRUD | - | | |
| Telegram Chat ID — instructions UI | - | | |
| Profile completeness banner (home screen) | - | | |

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
