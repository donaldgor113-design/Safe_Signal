# SafeSignal — Architecture Decision Records (ADR)

**Версія:** 1.0  
**Дата:** 15 червня 2026  
**Пов'язані документи:** SafeSignal_Technical_Document.md  

Кожен ADR фіксує одне ключове рішення: контекст → варіанти → рішення → наслідки.  
Claude не переглядає ці рішення і не пропонує альтернативи якщо у промті немає явного запиту «переглянь архітектуру».

---

## ADR-001: Мобільний фреймворк — Flutter (Dart)

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Потрібна iOS + Android розробка з мінімальними ресурсами (1 розробник + Claude AI).

**Варіанти:**
- React Native — велика екосистема, JS, але два рендер-шари, більше нативних проблем
- Flutter — один codebase, Dart, власний рендер-рушій, сильна типізація
- Native (Swift/Kotlin) — найкраща продуктивність, але два кодобази = двічі більше роботи

**Рішення:** Flutter 3.x

**Причини:**
- Один кодобаза для iOS і Android → GSD-принцип
- Riverpod, GoRouter, FlutterFire — зрілий стек
- Claude добре знає Flutter і генерує стабільний код
- Dart — строга типізація знижує кількість runtime-помилок

**Наслідки:**
- Dart як основна мова (Назарій вивчає паралельно)
- Garmin SDK може вимагати нативного коду (platform channel) у Version 2.0
- Деякі iOS-специфічні фонові можливості потребують нативного entitlement

---

## ADR-002: State Management — Riverpod 2.x

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** SOS Flow потребує управління складним станом: запис → завантаження → надсилання по кількох каналах → статус доставки. Потрібен надійний, тестований підхід.

**Варіанти:**
- BLoC/Cubit — більше boilerplate, складніше для Claude генерувати
- GetX — магічна залежність, важко тестувати
- Riverpod 2.x — код-генерація (@riverpod), AsyncValue для loading/error/data, легко тестується

**Рішення:** Riverpod 2.x з code generation (`riverpod_generator`)

**Причини:**
- AsyncValue вбудований handling loading/error/success — ідеально для SOS Flow
- Легке тестування через ProviderContainer
- Найкраща підтримка у Claude-генерованому коді

**Наслідки:**
- Потрібен build_runner для генерації (додається в CI)
- Всі провайдери декларуються через `@riverpod` анотацію

---

## ADR-003: Навігація — GoRouter

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Потрібна декларативна навігація з deep linking і redirect-логікою (неавторизований → /auth/login).

**Варіанти:**
- Navigator 2.0 напряму — занадто низькорівнево, багато boilerplate
- AutoRoute — code generation, складніший для Claude
- GoRouter — офіційний, простий, добре інтегрується з Riverpod

**Рішення:** GoRouter

**Причини:**
- Офіційний від Flutter team, добре задокументований
- Redirect guard інтегрується з Firebase Auth state
- Claude генерує GoRouter-код без помилок

**Маршрути зафіксовані в:** `SafeSignal_Technical_Document.md` → розділ 5.1

---

## ADR-004: Локальна БД — Hive + flutter_secure_storage

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Потрібно зберігати локально: офлайн-чергу SOS, GPS-маршрут (Off-Grid), налаштування застосунку. Медичний профіль повинен бути зашифрований.

**Варіанти:**
- SQLite (drift) — добре для структурованих даних, але надмірно для простих налаштувань
- Hive — NoSQL, швидкий, простий для офлайн-черги і налаштувань
- SharedPreferences — не підходить для чутливих даних і складних структур

**Рішення:** Hive для черги і налаштувань + flutter_secure_storage для чутливих медданих

**Причини:**
- Hive: ідеальний для офлайн-черги (FIFO операції) і GPS-маршруту
- flutter_secure_storage: iOS Keychain / Android Keystore → справжнє шифрування

**Наслідки:**
- Hive TypeAdapters потрібно генерувати для кастомних класів
- `offline_queue` та `gps_log` — окремі Hive boxes

**Примітка для Claude:** `SafeSignal_Technical_Document.md` → розділ 4.2 містить повну схему Firestore. Локальна Hive-структура є дзеркалом офлайн-частини, не заміною.

---

## ADR-005: SMS-надсилання — Twilio через Firebase Cloud Functions

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** SMS не можна надсилати напряму з Flutter-застосунку без розкриття API ключа.

**Варіанти:**
- Власний Node.js/Python сервер — додаткова інфраструктура, деплой, підтримка
- Firebase Cloud Functions — вже в стеку, serverless, легко масштабується
- SendBird / другі SaaS — додаткова залежність і ціна

**Рішення:** Twilio API викликається тільки з Firebase Cloud Functions

**Причини:**
- Twilio API ключ у Firebase secrets (зашифровано, не в коді)
- Cloud Function тригериться Firestore onCreate (`alerts/{alertId}`) — надійно
- Нульова серверна інфраструктура для підтримки

**Наслідки:**
- Cold start CF може додавати 1–3 сек до надсилання (прийнятно)
- SMS-ціна Twilio: ~$0.0079/SMS (США) — закладається у план монетизації

---

## ADR-006: Telegram-інтеграція — через Cloud Functions (не напряму)

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Telegram Bot API підтримує надсилання повідомлень через HTTPS POST. Питання — де зберігати токен.

**Варіанти:**
- Telegram токен у Remote Config і дзвінок напряму з телефону — простіше, але ризик розкриття
- Telegram через Cloud Functions — узгоджується з загальним принципом безпеки

**Рішення (MVP):** Telegram Bot токен у Firebase Cloud Functions environment; надсилання через Cloud Function.

**Причини:**
- Узгоджено з принципом «Жодних API ключів в Flutter коді» (`SafeSignal_Technical_Document.md` → розділ 8)
- Один підхід для всіх зовнішніх API → менше виключень

**Наслідки:**
- Cloud Function `sendTelegramMessage` — окрема функція від `sendSosAlert`
- Структура повідомлення описана в `SafeSignal_Technical_Document.md` → розділ 6.4

---

## ADR-007: Off-Grid без мережі — Офлайн-черга + рекомендація Garmin

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Без GSM/Wi-Fi надіслати будь-яке повідомлення технічно неможливо зі смартфону. Потрібно чесно вирішити що SafeSignal робить в цьому випадку.

**Рішення:**
1. GPS продовжує логуватись локально через `geolocator` (не потребує мережі)
2. Дані SOS зберігаються в `offline_queue` (Hive)
3. При появі будь-якого сигналу (connectivity_plus) — черга автоматично обробляється
4. Застосунок показує підказку в /settings/offgrid про Garmin inReach (Version 2.0)
5. Garmin API інтеграція — **тільки Version 2.0**, після MVP-валідації

**Чого НЕ робимо у Version 1.0:**
- Не обіцяємо надсилання без мережі
- Не інтегруємося з satellite SOS iPhone 14+ у Version 1.0

**Дисклеймер** зафіксований у `SafeSignal_Technical_Document.md` → розділ 10.3

---

## ADR-008: Архітектура — Clean Architecture (features-first)

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Потрібна структура, зрозуміла Claude і масштабована при додаванні нових фіч.

**Рішення:** Clean Architecture з features-first розбивкою  
Повна структура папок: `SafeSignal_Technical_Document.md` → розділ 4.1

**Правила для Claude (обов'язково):**
- Нові фічі завжди йдуть у `features/{feature_name}/data|domain|presentation`
- Спільна інфраструктура (GPS, відео, SMS) — тільки в `core/services/`
- Ніколи не додавай логіку до `core/` якщо вона специфічна для одної фічі
- `shared/widgets/` — тільки UI-компоненти без бізнес-логіки

---

## ADR-009: Безпека — Firebase App Check + Security Rules

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** Медичні дані — чутлива категорія. Витік = юридична відповідальність і репутаційна катастрофа.

**Рішення:**
1. Firebase App Check — захист від несанкціонованого доступу до Firestore/Storage
2. Firestore Security Rules — кожен документ доступний тільки його власнику
3. flutter_secure_storage — локальне шифрування медпрофілю
4. API ключі — виключно у Firebase Cloud Functions environment
5. Відео у Storage — приватне. Доступ контактам через підписані URL (signed URLs) з Cloud Function, термін дії 48 годин

**Повні Security Rules:** `SafeSignal_Technical_Document.md` → розділ 7.2 і 7.3

---

## ADR-010: Монетизація — Freemium, після 500+ DAU

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** GSD-принцип 6: «Free first. Монетизація — після 500+ активних користувачів».

**Рішення:**
- MVP = повністю безкоштовний
- Монетизацію не проектуємо в коді на цьому етапі (Remote Config `feature_premium_v2 = false`)
- Потенційна модель: Freemium (1 сценарій + 2 контакти безкоштовно, більше — платно)

**Наслідки для Claude:**  
Не додавати paywall-логіку, subscription screens або RevenueCat поки не буде окремого ADR.

---

## ADR-011: Quick SOS — 4 способи швидкого доступу

**Статус:** Прийнято | **Дата:** 15.06.2026

**Контекст:** У користувача з епілепсією є 10–30 секунд від аури до втрати свідомості. Розблокування телефону → пошук застосунку → відкриття → натискання SOS — це занадто довго. Потрібні способи активувати SOS за 1–2 дії, навіть не відкриваючи застосунок.

**Рішення (MVP — 4 механізми):**

**1. Home Screen Widget (iOS + Android)**
- Пакет: `home_widget` (Flutter)
- Розмір: 2×2 (Android) / Small (iOS)
- Тап → deep link `safesignal://sos` → застосунок відкривається одразу в SOS Flow
- Вигляд: червона кнопка SOS на білому фоні з логотипом

**2. Persistent Notification (Android)**
- Foreground Service notification (потрібен для детекції нерухомості)
- Action button «SOS» прямо в notification
- Тап на action → PendingIntent → SOS Flow
- Не можна dismiss (persistent)

**3. Shake-to-SOS (iOS + Android)**
- sensors_plus вже підключений для детекції нерухомості
- Розпізнавання: ≥3 різкі зміни напрямку за 2 сек, magnitude > 20 m/s²
- Shake → local notification «Активувати SOS?» з кнопками «Так» / «Ні» (захист від випадкового спрацювання)
- Налаштовується в Settings: увімкнено/вимкнено (дефолт: вимкнено)
- Feature flag: `feature_shake_sos_v1` (дефолт: false)

**4. Quick Settings Tile (Android)**
- Нативний Kotlin код: `TileService` extends `android.service.quicksettings.TileService`
- Platform channel для комунікації з Flutter
- Плитка з іконкою SOS у Quick Settings панелі
- Тап → запуск SOS Flow

**Чого НЕ робимо у MVP:**
- Lock Screen widget (iOS 18+ — мало пристроїв)
- Hardware button override (AccessibilityService — ризик відхилення Google Play)

**Наслідки:**
- `home_widget` додається в pubspec.yaml
- Нативний Kotlin код для Quick Settings Tile → `android/app/src/main/kotlin/`
- Нативний Swift код для iOS widget → Xcode widget extension
- Deep link схема `safesignal://sos` реєструється в GoRouter
- Foreground Service вже потрібен для immobility detection — notification з SOS кнопкою додається без окремого сервісу

