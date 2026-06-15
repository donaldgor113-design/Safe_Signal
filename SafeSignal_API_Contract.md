# SafeSignal — API Contract

**Версія:** 1.0  
**Дата:** 15 червня 2026  
**Пов'язані документи:** SafeSignal_Technical_Document.md (розділи 4.2, 6.4, 6.5, 7.2)

Цей документ — єдине джерело правди для назв полів, типів і структур.  
**Claude використовує виключно ці назви** при генерації коду, без перейменування.

---

## 1. Firestore — Колекції та Dart-моделі

> Повна схема: `SafeSignal_Technical_Document.md` → розділ 4.2. Нижче — уточнення типів для Dart-коду.

### 1.1 `users/{userId}`

```dart
class UserModel {
  final String uid;           // Firebase Auth UID
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String? fcmToken;     // nullable — оновлюється при кожному запуску
}
```

### 1.2 `medical_profiles/{userId}`

```dart
class MedicalProfileModel {
  final List<String> diagnoses;
  final List<MedicationModel> medications;
  final List<String> allergies;
  final String? bloodType;        // "A(II) Rh+" — nullable
  final String? doctorName;
  final String? doctorPhone;      // формат E.164: +380XXXXXXXXX
  final String? clinicName;
  final String? clinicPhone;
  final DateTime updatedAt;
}

class MedicationModel {
  final String name;
  final String dose;
  final String frequency;
}
```

### 1.3 `contacts/{userId}/items/{contactId}`

```dart
class ContactModel {
  final String id;                          // Firestore auto-ID
  final String name;
  final String phone;                       // E.164: +380XXXXXXXXX
  final String? telegramChatId;             // nullable
  final String? email;                      // nullable
  final String relationship;               // "Дружина", "Лікар", "Мама"
  final List<NotifyChannel> notifyChannels; // MVP: sms, telegram
}

enum NotifyChannel { sms, telegram }
// push — тільки self-notification власнику (не канал контакту в MVP)
// email — Version 2.0
```

### 1.4 `scenarios/{userId}/items/{scenarioId}`

```dart
class ScenarioModel {
  final String id;
  final String name;                    // "Основний", "Прогулянка в горах"
  final List<String> contactIds;
  final String messageTemplate;         // підтримує {{змінні}} — список нижче
  final int recordDurationSeconds;      // 30 або 60
  final bool autoTriggerEnabled;
  final int immobilityTimeoutSeconds;   // 0 = вимкнено
  final bool isDefault;                 // тільки один може бути true
}
```

**Змінні шаблону `messageTemplate`:**

| Змінна | Що підставляється |
|---|---|
| `{{userName}}` | displayName користувача |
| `{{location}}` | `lat, lng` (числа) |
| `{{address}}` | Зворотне геокодування (рядок) |
| `{{timestamp}}` | `dd.MM.yyyy HH:mm` |
| `{{videoUrl}}` | Firebase Storage URL відео (якщо є) |
| `{{diagnoses}}` | Перший діагноз з медпрофілю |

**Дефолтний шаблон:**
```
🆘 ЕКСТРЕНА СИТУАЦІЯ

{{userName}} потребує допомоги!

📍 Місцезнаходження: {{address}}
🗺 Координати: {{location}}
🕐 Час: {{timestamp}}
🏥 Діагноз: {{diagnoses}}

{{videoUrl}}

Надіслано через SafeSignal
```

### 1.5 `alerts/{alertId}`

```dart
class AlertModel {
  final String id;
  final String userId;
  final String scenarioId;
  final DateTime triggeredAt;
  final TriggerType triggerType;
  final GeoPoint location;
  final String? locationAddress;            // null якщо офлайн
  final String? videoUrl;                   // Firebase Storage URL
  final String? videoThumbnailUrl;
  final List<NotifyChannel> sentChannels;
  final Map<String, DeliveryStatus> deliveryStatus; // {"sms": "sent", "telegram": "failed"}
  final DateTime? cancelledAt;              // null = не скасовано
}

enum TriggerType { manual, immobility, wearable }
enum DeliveryStatus { pending, sent, failed }
```

---

## 2. Hive — Локальні структури

### 2.1 Box: `offline_queue`

```dart
@HiveType(typeId: 0)
class OfflineAlertModel {
  @HiveField(0) final String localId;             // UUID генерується локально
  @HiveField(1) final Map<String, dynamic> alertData;
  @HiveField(2) final String? videoLocalPath;
  @HiveField(3) final DateTime createdAt;
  @HiveField(4) int attempts;                     // mutable лічильник
  @HiveField(5) final int maxAttempts;            // = 10
}
```

### 2.2 Box: `gps_log` (Off-Grid режим)

```dart
@HiveType(typeId: 1)
class GpsLogEntryModel {
  @HiveField(0) final double latitude;
  @HiveField(1) final double longitude;
  @HiveField(2) final double? accuracy;
  @HiveField(3) final DateTime recordedAt;
}
```

### 2.3 Box: `app_settings` — ключі (строго ці назви)

| Ключ | Тип | Дефолт | Опис |
|---|---|---|---|
| `offgrid_enabled` | bool | false | Off-Grid режим |
| `offgrid_gps_interval_minutes` | int | 5 | Інтервал GPS логування |
| `active_scenario_id` | String? | null | ID активного сценарію |
| `onboarding_completed` | bool | false | Онбординг пройдено |
| `disclaimer_accepted` | bool | false | Дисклеймер прийнято |
| `shake_sos_enabled` | bool | false | Shake-to-SOS увімкнено |

---

## 3. Firebase Cloud Functions — Контракти

### 3.1 `sendSosAlert`

**Тригер:** Firestore onCreate → `alerts/{alertId}`  
**Вхід:** Документ AlertModel  
**Дія:**
1. Завантажити сценарій з `scenarios/{userId}/items/{scenarioId}`
2. Завантажити контакти з `contactIds` сценарію
3. Для кожного контакту: SMS (якщо `sms` в `notifyChannels`) + Telegram (якщо `telegram`)
4. Оновити `alerts/{alertId}.deliveryStatus`

**Формат SMS (Twilio):**
```
SafeSignal: {{userName}} потребує допомоги!
{{address}}
Координати: https://maps.google.com/?q={{lat}},{{lng}}
{{videoUrl}}
```

**Формат Telegram (HTML):**
```html
🆘 <b>ЕКСТРЕНА СИТУАЦІЯ</b>

<b>{{userName}}</b> потребує допомоги!
📍 <a href="https://maps.google.com/?q={{lat}},{{lng}}">{{address}}</a>
🕐 {{timestamp}}
🏥 {{diagnoses}}
```

### 3.2 `generateSignedUrl` (HTTP callable)

**Вхід:** `{ userId: string, filePath: string }`  
**Дія:** Генерує підписаний URL для файлу в Firebase Storage з терміном дії 48 годин  
**Вихід:** `{ url: string, expiresAt: string }`  
**Безпека:** Тільки власник файлу може запитувати URL (перевірка userId == auth.uid)  
**Використання:** Викликається з `sendSosAlert` при формуванні повідомлень контактам

### 3.4 `cleanupOldAlerts`

**Тригер:** Cloud Scheduler, щодня опівночі  
**Дія:** Видалення `alerts` і Storage-файлів старших за `video_auto_delete_days` днів

### 3.5 `updateFcmToken` (HTTP callable)

**Вхід:** `{ userId: string, token: string }`  
**Дія:** Оновлює `users/{userId}.fcmToken`  
**Вихід:** `{ success: boolean }`

---

## 4. Telegram Bot API

**Base URL:** `https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}`

### Надсилання тексту
```
POST /sendMessage
{ "chat_id": "{telegramChatId}", "text": "{текст}", "parse_mode": "HTML" }
```

### Надсилання відео
```
POST /sendVideo
{ "chat_id": "{telegramChatId}", "video": "{firebaseStorageUrl}",
  "caption": "📍 {{lat}}, {{lng}}\n🗺 {{address}}", "parse_mode": "HTML" }
```

### Отримання Chat ID контактом
```
Контакт → /start → Бот відповідає:
"Ваш Telegram Chat ID: {chat.id}
Передайте це число власнику SafeSignal при додаванні вас як контакту."
```

---

## 5. API ключі — де зберігати

> ⚠️ Жодних ключів в Flutter коді. Деталі: `SafeSignal_Technical_Document.md` → розділ 8.

| Ключ | Де | Назва змінної |
|---|---|---|
| Twilio Account SID | CF Environment | `TWILIO_ACCOUNT_SID` |
| Twilio Auth Token | CF Environment | `TWILIO_AUTH_TOKEN` |
| Twilio Phone Number | CF Environment | `TWILIO_PHONE_NUMBER` |
| Telegram Bot Token | CF Environment | `TELEGRAM_BOT_TOKEN` |
| Google Maps Geocoding Key | Firebase Remote Config | `google_maps_api_key` |

---

## 6. Firebase Remote Config — повний перелік

| Параметр | Тип | Дефолт |
|---|---|---|
| `feature_auto_trigger_v1` | Boolean | false |
| `feature_offgrid_mode_v1` | Boolean | true |
| `feature_qr_medical_card_v1` | Boolean | false |
| `feature_telegram_v1` | Boolean | true |
| `feature_garmin_integration_v2` | Boolean | false |
| `feature_shake_sos_v1` | Boolean | false |
| `feature_quick_settings_tile_v1` | Boolean | true |
| `feature_home_widget_v1` | Boolean | true |
| `sos_record_duration_seconds` | Number | 30 |
| `shake_magnitude_threshold` | Number | 20 |
| `shake_cooldown_seconds` | Number | 30 |
| `immobility_timeout_seconds` | Number | 60 |
| `immobility_magnitude_threshold` | Number | 9.3 |
| `offline_queue_max_attempts` | Number | 10 |
| `video_auto_delete_days` | Number | 30 |
| `google_maps_api_key` | String | "" |

