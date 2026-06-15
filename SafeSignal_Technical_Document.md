# SafeSignal — Технічний документ розробки

**Версія:** 2.0  
**Дата:** 15 червня 2026  
**Стек:** Flutter + Firebase + Telegram Bot API  
**Підхід:** GSD (Get Shit Done) — MVP спочатку, ускладнення потім  
**Розробка коду:** Claude AI (Anthropic)  

---

## 0. GSD-принципи цього проекту

Перед будь-якою розробкою — правила, яких дотримуємось завжди:

1. **Ship first, optimize later.** MVP за 8–10 тижнів. Без перфекціонізму.
2. **One feature at a time.** Не починати нову фічу, поки попередня не протестована.
3. **Real users > assumptions.** Після MVP — одразу 10–20 реальних тестових користувачів.
4. **Firebase first.** Не писати власний бекенд поки Firebase справляється — це місяць зекономленого часу.
5. **No feature creep.** Garmin API, AI-аналіз, браслети — після валідації MVP. Не раніше.
6. **Free first.** MVP безкоштовний. Монетизація — після 500+ активних користувачів.
7. **Claude writes code.** Максимально детальні промти → мінімум ітерацій.

---

## 1. Огляд продукту

SafeSignal — мобільний застосунок (iOS + Android) на Flutter, що дозволяє людям з хронічними захворюваннями або тим, хто подорожує в ізольованих місцях, миттєво надіслати екстрене повідомлення (відео + GPS + медпрофіль) близьким людям при настанні небажаного стану.

### Що робить застосунок (одним реченням):
> При натисканні однієї кнопки або автоматичному тригері — записує 30-секундне відео, додає GPS-координати та медичну інформацію і надсилає це SMS + Push + посиланням у вказані контакти.

### Що застосунок НЕ робить (важливо для юристів і Store):
- Не діагностує захворювання
- Не надає медичних рекомендацій
- Не замінює служби 103/112
- Не гарантує доставку повідомлень при відсутності мережі

---

## 2. Цільова аудиторія

### Основна (MVP):
- Люди з епілепсією, діабетом 1 типу, аритмією, астмою
- Люди похилого віку, що живуть самотньо
- Будь-яка людина з хронічним захворюванням, що має ризик раптового нападу

### Розширена (Version 2.0):
- Сольні туристи, альпіністи, велосипедисти
- Люди, що працюють самотньо у віддалених місцях

---

## 3. Технічний стек

| Компонент | Технологія | Причина вибору |
|---|---|---|
| Mobile (iOS + Android) | Flutter 3.x (Dart) | Один кодова база, швидкий MVP |
| UI компоненти | Material 3 + custom widgets | Вбудовано у Flutter |
| State Management | Riverpod 2.x | Найкраще для складного стану в Flutter |
| Локальна БД | Hive (NoSQL) + flutter_secure_storage | Hive для офлайн-черги/налаштувань, flutter_secure_storage для медпрофілю (ADR-004) |
| Авторизація | Firebase Auth | Email/пароль + Google Sign-In + Apple Sign-In |
| Хмарна БД | Cloud Firestore | Real-time, офлайн-підтримка вбудована |
| Зберігання файлів | Firebase Storage | Відео, PDF |
| Push-сповіщення | Firebase Cloud Messaging (FCM) | iOS + Android одночасно |
| SMS | Twilio API | Надійний, дешевий, є Flutter SDK |
| Відеозапис | camera plugin (Flutter) | Офіційний плагін |
| GPS | geolocator plugin | Найпопулярніший для Flutter |
| Фонова робота | flutter_background_service | Моніторинг тригерів у фоні |
| Акселерометр | sensors_plus | Виявлення нерухомості |
| Шифрування | flutter_secure_storage | Зберігання чутливих медданих |
| Home Widget | home_widget | Віджет SOS на домашньому екрані |
| HTTP клієнт | Dio | Запити до API |
| Telegram | Telegram Bot API (HTTP) | Надсилання повідомлень у чат |

---

## 4. Архітектура застосунку

### 4.1 Загальна архітектура (Clean Architecture)

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp, routing
│   ├── router.dart                 # GoRouter - навігація
│   └── theme.dart                  # Кольори, шрифти
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Рядки, числа, ліміти
│   │   └── firebase_constants.dart # Назви колекцій Firestore
│   ├── errors/
│   │   └── exceptions.dart         # Кастомні помилки
│   ├── services/
│   │   ├── notification_service.dart   # FCM push
│   │   ├── sms_service.dart            # Twilio SMS
│   │   ├── telegram_service.dart       # Telegram Bot API
│   │   ├── location_service.dart       # GPS
│   │   ├── video_service.dart          # Відеозапис
│   │   ├── storage_service.dart        # Firebase Storage upload
│   │   └── offline_queue_service.dart  # Черга при відсутності мережі
│   └── utils/
│       ├── validators.dart
│       └── formatters.dart
│
├── features/
│   ├── auth/                       # Авторизація
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── medical_profile/            # Медичний профіль
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── contacts/                   # Екстрені контакти
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── scenarios/                  # Сценарії оповіщення
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── sos/                        # Головна кнопка SOS
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── history/                    # Історія тривог
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── shared/
    ├── widgets/                    # Загальні UI компоненти
    └── providers/                  # Загальні Riverpod провайдери
```

### 4.2 Схема даних (Firestore)

```
users/ {userId}
  ├── email: string
  ├── displayName: string
  ├── createdAt: timestamp
  └── fcmToken: string

medical_profiles/ {userId}
  ├── diagnoses: [string]           # ["Епілепсія", "Діабет 1 типу"]
  ├── medications: [
  │     { name: string, dose: string, frequency: string }
  │   ]
  ├── allergies: [string]
  ├── bloodType: string             # "A(II) Rh+"
  ├── doctorName: string
  ├── doctorPhone: string
  ├── clinicName: string
  ├── clinicPhone: string
  └── updatedAt: timestamp

contacts/ {userId} / items/ {contactId}
  ├── name: string
  ├── phone: string                 # +380XXXXXXXXX
  ├── telegramChatId: string        # якщо є
  ├── email: string
  ├── relationship: string          # "Дружина", "Лікар", "Мама"
  └── notifyChannels: [string]      # MVP: ["sms", "telegram"]. Email/Push для контактів — Version 2.0

scenarios/ {userId} / items/ {scenarioId}
  ├── name: string                  # "Напад епілепсії", "Самотня прогулянка"
  ├── contactIds: [string]          # список contactId
  ├── messageTemplate: string       # Шаблон повідомлення
  ├── recordDuration: int           # 30 або 60 секунд
  ├── autoTrigger: bool             # автоматичний тригер увімкнено
  ├── immobilityTimeout: int        # секунди нерухомості до тригера (0 = вимкнено)
  └── isDefault: bool               # сценарій за замовчуванням

alerts/ {alertId}
  ├── userId: string
  ├── scenarioId: string
  ├── triggeredAt: timestamp
  ├── triggerType: string           # "manual", "immobility", "wearable"
  ├── location: GeoPoint
  ├── locationAddress: string       # Зворотне геокодування
  ├── videoUrl: string              # Firebase Storage URL
  ├── videoThumbnailUrl: string
  ├── sentChannels: [string]        # ["sms", "push", "telegram"]
  ├── deliveryStatus: {
  │     sms: "sent" | "failed",
  │     push: "sent" | "failed",
  │     telegram: "sent" | "failed"
  │   }
  └── cancelledAt: timestamp        # якщо скасовано користувачем

offline_queue/ (локально в Hive)
  ├── alertData: Map                # серіалізовані дані тривоги
  ├── videoLocalPath: string        # шлях до локального відео
  ├── createdAt: timestamp
  └── attempts: int                 # кількість спроб надсилання
```

---

## 5. Екрани застосунку (UI Flow)

### 5.1 Навігація (GoRouter)

```
/splash              → Перевірка авторизації
/onboarding          → Перший запуск (3 слайди)
/auth/login          → Вхід
/auth/register       → Реєстрація
/auth/verify-email   → Підтвердження email

/home                → Головний екран (SOS кнопка)
/profile             → Медичний профіль
/contacts            → Список контактів
/contacts/add        → Додати контакт
/contacts/:id        → Редагувати контакт
/scenarios           → Список сценаріїв
/scenarios/add       → Створити сценарій
/scenarios/:id       → Редагувати сценарій
/history             → Історія тривог
/history/:alertId    → Деталі тривоги
/settings            → Налаштування
/settings/offgrid    → Off-Grid режим
```

### 5.2 Опис кожного екрану

---

#### 📱 Splash Screen (`/splash`)
**Що робить:** Перевіряє FirebaseAuth, якщо є сесія → переходить на `/home`, якщо ні → `/onboarding` або `/auth/login`

---

#### 📱 Onboarding (`/onboarding`)
**3 слайди:**
1. «Одна кнопка — і близькі знають де ти і що трапилось»
2. «Заповни медичний профіль один раз»
3. «Налаштуй кому надсилати і по яких каналах»

**Кнопки:** «Далі» / «Пропустити» / «Почати»

---

#### 📱 Головний екран — Home (`/home`)

**Це найважливіший екран. Він повинен бути максимально простим.**

Елементи:
- **Велика кнопка SOS** (центр екрану, діаметр ~200px, червона)
  - Утримання 2 секунди → активація (захист від випадкового натискання)
  - Навколо кнопки: пульсуюча анімація
- **Активний сценарій** (під кнопкою): показує який сценарій зараз активний («Основний», «Прогулянка»)
  - Тап → швидкий перемикач сценаріїв (bottom sheet)
- **Статус-рядок зверху:**
  - Іконка GPS (зелена = є, сіра = немає)
  - Іконка мережі (зелена = онлайн, помаранчева = офлайн/черга)
  - Іконка медпрофілю (зелена = заповнено, жовта = є порожні поля)
- **Bottom Navigation Bar:**
  - Головна | Профіль | Контакти | Сценарії | Ще

**UX деталі:**
- Якщо медпрофіль не заповнений → банер «Заповни медпрофіль для кращого оповіщення»
- Якщо немає жодного контакту → кнопка SOS неактивна з поясненням «Спочатку додай екстрений контакт»

---

#### 📱 SOS Flow (модальний процес після натискання кнопки)

**Крок 1 — Відлік (3 секунди)**
- Великий лічильник: 3... 2... 1...
- Кнопка «Скасувати» (великий, помітний)
- Текст: «Починаємо запис повідомлення»

**Крок 2 — Запис відео (30 або 60 секунд)**
- Фронтальна камера активна
- Великий лічильник часу, що залишився
- Кнопка «Зупинити і надіслати» (не чекати кінця)
- Кнопка «Надіслати без відео» (якщо непритомнів)
- Автоматичне завершення запису після ліміту часу

**Крок 3 — Надсилання**
- Анімація прогресу: «Отримую GPS...» → «Завантажую відео...» → «Надсилаю повідомлення...»
- Список статусів по кожному каналу (SMS ✓, Push ✓, Telegram ✓)
- При офлайн: «Немає мережі. Повідомлення надішлеться автоматично при появі зв'язку»

**Крок 4 — Підтвердження**
- «Повідомлення надіслано X контактам»
- Кнопка «Закрити»
- Кнопка «Переглянути що надіслано»

---

#### 📱 Медичний профіль (`/profile`)

**Секції:**

**Особиста інформація:**
- Ім'я (для звернення в повідомленні)
- Дата народження
- Фото (опціонально)

**Діагнози:**
- Мультиселект з категорій (Серцево-судинні, Неврологічні, Ендокринні, Алергічні, Інші)
- + Вільний текст для кожного діагнозу
- Додати кілька діагнозів

**Ліки:**
- Список: назва ліків + дозування + частота
- + Додати ліки
- Кнопка «Відсканувати упаковку» (OCR через камеру — Version 2.0)

**Алергії:**
- Чіп-теги: Пеніцилін, Аспірин, Йод, Латекс + вільний текст

**Медичні дані:**
- Група крові + Rh-фактор (dropdown)
- Особливі вказівки (вільний текст, напр. «При нападі не тримати, покласти на бік»)

**Контакт лікаря:**
- Ім'я лікаря
- Телефон
- Назва клініки

**Кнопки внизу:**
- «Зберегти»
- «Згенерувати QR-карту» → показує QR-код + PDF для роздруку

---

#### 📱 Контакти (`/contacts`)

**Список контактів** (картки):
- Ім'я + відношення
- Іконки активних каналів (📱SMS, ✈️Telegram)
- Свайп вліво → видалити

**Кнопка «+»** → перехід на `/contacts/add`

**Екран додавання контакту:**
- Ім'я*
- Номер телефону* (з вибором країни)
- Відношення (dropdown: Дружина/Чоловік, Мати/Батько, Дитина, Лікар, Друг, Інше)
- Email (опціонально)
- Telegram Chat ID (опціонально, з поясненням як отримати)
- Канали оповіщення (checkboxes): SMS, Telegram (Email, Push для контактів — Version 2.0)
- Кнопка «Зберегти»

**Як підключити Telegram контакт:**
1. Контакт встановлює SafeSignal або пише нашому Telegram-боту `/start`
2. Бот повертає їх Chat ID
3. Користувач вводить цей ID в полі «Telegram Chat ID»

---

#### 📱 Сценарії (`/scenarios`)

**Що таке сценарій:** набір правил «при якій ситуації → кому надсилати → яким способом»

**Список сценаріїв:**
- Картки з назвою та короткою інформацією
- Перший сценарій (Основний) — завжди є, не можна видалити
- Поточний активний сценарій позначено

**Екран створення сценарію:**

**Назва сценарію*** (напр. «Напад», «Самотня прогулянка», «На роботі»)

**Отримувачі** (вибір з існуючих контактів, множинний):
- Чекбокси з іменами контактів

**Канали оповіщення** (для цього сценарію, MVP):
- SMS — checkbox
- Telegram — checkbox

**Шаблон повідомлення:**
```
Текстове поле (з підстановками):
"{{ім'я}} потребує допомоги. 
Діагноз: {{діагноз}}. 
Місцезнаходження: {{адреса}}.
Координати: {{gps}}
Відеоповідомлення: {{відео_посилання}}"
```
Редаговане + кнопка «Скинути до стандартного»

**Тривалість відеозапису:** 30 сек / 60 сек (radio buttons)

**Автоматичні тригери (опціонально):**
- [ ] Тригер нерухомості: якщо немає руху протягом [30/60/120/300] сек → запитати «Все добре?» → якщо немає відповіді [30] сек → активувати
- [ ] Таймер check-in: кожні [15/30/60] хвилин надсилати запит, якщо не підтверджено → активувати

**Off-Grid режим (toggle):**
- Якщо увімкнено → повідомлення зберігаються в черзі та надсилаються при появі мережі
- GPS фіксується кожні 5 хвилин локально

---

#### 📱 Історія (`/history`)

**Список всіх тривог** у хронологічному порядку:
- Дата/час
- Сценарій що спрацював
- Тип тригера (ручний / автоматичний)
- Статус (надіслано / в черзі / помилка)
- Мініатюра відео

**Екран деталей тривоги:**
- Відеоплеєр
- Карта з GPS-точкою
- Список контактів яким надіслано + статус кожного
- Медінформація що була в повідомленні

---

## 6. Ключові технічні процеси

### 6.1 SOS Flow — покроковий алгоритм

**Два шляхи активації:**
- **Manual (foreground)** — користувач натискає кнопку SOS → повний флоу з відео
- **Auto-trigger (background)** — детекція нерухомості → тільки GPS + медпрофіль (iOS не дозволяє камеру у фоні)

#### 6.1.1 Manual SOS (foreground)

```
1. Користувач утримує кнопку 2 сек
   ↓
2. Відлік 3 секунди (можна скасувати)
   ↓
3. Одночасно запускаються:
   a) CameraController.startVideoRecording()
   b) Geolocator.getCurrentPosition()
   c) Читання медпрофілю з локальної БД
   ↓
4. Через recordDuration секунд (або при ручній зупинці):
   CameraController.stopVideoRecording() → повертає XFile
   ↓
5. Перевірка мережі (connectivity_plus):
   ОНЛАЙН → переходимо до кроку 6
   ОФЛАЙН → зберігаємо в Hive offline_queue → показуємо статус → END (надішлеться потім)
   ↓
6. Завантаження відео на Firebase Storage:
   Path: alerts/{userId}/{timestamp}.mp4
   Отримуємо downloadUrl
   ↓
7. Зворотне геокодування координат → адреса (geocoding plugin)
   ↓
8. Формування alertData об'єкту та збереження в Firestore (alerts/)
   ↓
9. Формування повідомлення з шаблону сценарію (підстановка змінних)
   ↓
10. Паралельна розсилка по каналах (MVP):
    - SMS via Twilio (для кожного контакту з SMS-каналом)
    - Telegram Bot API (для контактів з telegramChatId)
    - FCM Push — тільки self-notification власнику (підтвердження доставки)
    - Email — Version 2.0 (Firebase Extension або SMTP)
    ↓
11. Оновлення deliveryStatus в Firestore
    ↓
12. Показати екран підтвердження
```

#### 6.1.2 Auto-trigger SOS (background — нерухомість)

```
1. Фоновий сервіс виявляє нерухомість → local notification «Все добре?»
   ↓
2. Якщо користувач відповів «Допоможіть» або не відповів за 30 сек:
   ↓
3. Збираються ТІЛЬКИ:
   a) Geolocator.getCurrentPosition() (GPS працює у фоні)
   b) Читання медпрофілю з локальної БД
   c) Відео НЕ записується (iOS обмеження фонового режиму)
   ↓
4. Далі стандартний флоу з кроку 5 (6.1.1) — перевірка мережі → надсилання
   videoUrl = null (повідомлення надсилається без відео)
```

### 6.2 Офлайн-черга (Offline Queue)

```dart
// Структура запису в Hive
class OfflineAlertItem {
  final String id;
  final Map<String, dynamic> alertData;
  final String videoLocalPath;
  final DateTime createdAt;
  int attempts;
}

// Логіка:
// При появі мережі (connectivity_plus stream):
// 1. Читаємо всі записи з Hive offline_queue
// 2. Для кожного запису виконуємо повний SOS Flow починаючи з кроку 6
// 3. При успіху — видаляємо з черги
// 4. При помилці — збільшуємо attempts, пробуємо знову через 30 сек
// 5. Після 10 невдалих спроб — позначаємо як failed, сповіщаємо користувача
```

### 6.3 Детекція нерухомості (Immobility Detection)

```
Фоновий сервіс (flutter_background_service):

1. Якщо сценарій має immobilityTimeout > 0 AND застосунок у фоні:
   - Читаємо accelerometer дані кожні 5 секунд
   - Обраховуємо magnitude: sqrt(x² + y² + z²)
   - Якщо magnitude < threshold (≈9.8 ± 0.5 m/s²) протягом immobilityTimeout секунд
     → Показуємо local notification: «Все добре? Натисніть щоб підтвердити»
   - Якщо протягом 30 секунд немає відповіді → активуємо SOS Flow автоматично
   - Запис відео без участі користувача (тільки GPS + медпрофіль якщо камера недоступна у фоні)
```

### 6.4 Quick SOS — швидкий доступ без відкриття застосунку

#### 6.4.1 Deep Link схема

```
URI: safesignal://sos
Дія: відкрити застосунок → пропустити Home → одразу SOS Flow (крок 1 — countdown)
GoRouter: GoRoute(path: '/sos-direct', ...)
Реєстрація:
  Android: AndroidManifest.xml → intent-filter з scheme "safesignal"
  iOS: Info.plist → CFBundleURLSchemes → "safesignal"
```

Всі механізми Quick SOS використовують цей deep link як єдину точку входу.

#### 6.4.2 Home Screen Widget

```
Пакет: home_widget (Flutter)
Нативні файли:
  Android: android/app/src/main/res/layout/sos_widget.xml
           android/app/src/main/kotlin/.../SosWidgetProvider.kt
  iOS:     ios/SosWidget/ (Widget Extension target в Xcode)

Дизайн (Android 2×2 / iOS Small):
┌─────────────┐
│  ┌───────┐  │
│  │  SOS  │  │  ← Червоне коло на білому фоні
│  └───────┘  │
│  SafeSignal │  ← Текст під кнопкою (bodySmall)
└─────────────┘

Тап → Intent/URL scheme → safesignal://sos → SOS Flow
Оновлення: при кожному зміні активного сценарію показує його назву
```

#### 6.4.3 Persistent Notification (Android)

```
Реалізується через Foreground Service (flutter_background_service)
Foreground Service вже потрібен для:
  - Детекції нерухомості (immobility detection)
  - GPS-логування в Off-Grid режимі

Notification:
  Channel: "safesignal_sos" (High importance)
  Title: "SafeSignal активний"
  Body: "Сценарій: {{active_scenario_name}}"
  Actions:
    - "SOS" (червона) → PendingIntent → safesignal://sos
  Ongoing: true (не можна dismiss)
  Small icon: щит SafeSignal (monochrome)
  
Показується тільки коли застосунок активний (foreground service running)
```

#### 6.4.4 Shake-to-SOS

```
Використовує: sensors_plus (вже підключений для immobility detection)
Працює: у фоні через flutter_background_service

Алгоритм:
1. Читаємо accelerometer кожні 100ms
2. Обраховуємо delta між поточним і попереднім magnitude
3. Якщо |delta| > 20 m/s² → count++
4. Якщо count >= 3 за останні 2 секунди → shake detected
5. Reset count кожні 2 секунди

При shake detected:
  → Local notification: «Активувати SOS?»
  → Кнопки: «Так, SOS» / «Ні, все добре»
  → «Так» → safesignal://sos
  → «Ні» або ігнор 10 сек → нічого

Налаштування:
  Settings → «Shake-to-SOS» toggle (дефолт: вимкнено)
  Hive key: shake_sos_enabled (bool, default false)
  Remote Config: feature_shake_sos_v1 (bool, default false)

Захист від хибних спрацювань:
  - Завжди запитує підтвердження (ніколи не активує SOS напряму)
  - Cooldown: після відхилення ігнорує shake 30 секунд
  - Вимкнено за замовчуванням — користувач має свідомо увімкнути
```

#### 6.4.5 Quick Settings Tile (Android)

```
Нативний код: android/app/src/main/kotlin/.../SosQsTileService.kt

class SosQsTileService : TileService() {
  // onClick → PendingIntent → safesignal://sos
  // updateTile → label "SOS", icon = щит, state = active/inactive
}

AndroidManifest.xml:
  <service android:name=".SosQsTileService"
    android:icon="@drawable/ic_sos_tile"
    android:label="SOS"
    android:permission="android.permission.BIND_QUICK_SETTINGS_TILE">
    <intent-filter>
      <action android:name="android.service.quicksettings.action.QS_TILE"/>
    </intent-filter>
  </service>

Комунікація з Flutter: MethodChannel("safesignal/sos_tile")
Стан плитки: оновлюється при зміні foreground service (active/inactive)
```

### 6.5 Telegram Bot інтеграція (раніше 6.4)

**Бот виконує дві функції:**

**Функція 1 — Отримання Chat ID контактом:**
```
Контакт пише /start боту
Бот відповідає: «Ваш Telegram Chat ID: 123456789. Передайте це число тому хто налаштовує SafeSignal»
```

**Функція 2 — Надсилання екстреного повідомлення:**
```
POST https://api.telegram.org/bot{TOKEN}/sendMessage
{
  "chat_id": "{telegramChatId}",
  "text": "{messageText}",
  "parse_mode": "HTML"
}

Потім окремим запитом (якщо є відео):
POST https://api.telegram.org/bot{TOKEN}/sendVideo
{
  "chat_id": "{telegramChatId}",
  "video": "{firebaseStorageUrl}",
  "caption": "📍 Координати: {lat}, {lng}\n🗺 Адреса: {address}"
}
```

### 6.6 Twilio SMS інтеграція

**SMS надсилається через Firebase Cloud Functions** (не напряму з телефону — щоб захистити API ключ):

```javascript
// Firebase Cloud Function: sendSosAlert
exports.sendSosAlert = functions.firestore
  .document('alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alert = snap.data();
    const scenario = await getScenario(alert.scenarioId);
    const contacts = await getContacts(alert.userId, scenario.contactIds);
    
    for (const contact of contacts) {
      if (contact.notifyChannels.includes('sms')) {
        await twilioClient.messages.create({
          body: formatMessage(alert, scenario.messageTemplate),
          from: TWILIO_PHONE_NUMBER,
          to: contact.phone
        });
      }
    }
  });
```

### 6.7 QR-медкарта

```
При натисканні "Згенерувати QR-карту":

1. Формуємо JSON з медпрофілю
2. Шифруємо (AES-256)
3. Зберігаємо на Firebase Storage: medical_cards/{userId}/card.json
4. Отримуємо публічне посилання (з терміном дії 1 рік)
5. Генеруємо QR-код з цим посиланням (qr_flutter plugin)
6. Формуємо PDF картку (printing plugin):
   - Логотип SafeSignal
   - QR-код
   - Ім'я користувача
   - Група крові
   - Основні діагнози
   - Ліки
   - Алергії (виділити червоним)
   - Контакт лікаря
   - Дисклеймер
7. Показуємо QR на екрані + кнопка "Зберегти PDF"
```

---

## 7. Firebase структура проекту

### 7.1 Firebase сервіси що використовуємо:
- **Firebase Auth** — авторизація
- **Cloud Firestore** — база даних
- **Firebase Storage** — відео файли та медкарти
- **Firebase Cloud Messaging** — push сповіщення
- **Firebase Cloud Functions** — Twilio SMS, захист API ключів
- **Firebase App Check** — захист від несанкціонованого доступу

### 7.2 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Медичний профіль — тільки власник
    match /medical_profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Контакти — тільки власник
    match /contacts/{userId}/items/{contactId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Сценарії — тільки власник
    match /scenarios/{userId}/items/{scenarioId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Тривоги — власник може створювати і читати
    match /alerts/{alertId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

### 7.3 Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Відео тривог — тільки власник може завантажувати і читати
    match /alerts/{userId}/{allPaths=**} {
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && request.auth.uid == userId;
    }
    
    // Медкарти — тільки власник
    match /medical_cards/{userId}/{allPaths=**} {
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

> **Примітка:** Контакти отримують доступ до відео та медкарт через **підписані URL (signed URLs)**, які генерує Cloud Function з терміном дії 48 годин. Це захищає медичне відео від публічного доступу. Cloud Function `generateSignedUrl` створює тимчасове посилання при надсиланні SOS.

---

## 8. Зовнішні API та ключі

| Сервіс | Де зберігати ключ | Як використовувати |
|---|---|---|
| Firebase | `google-services.json` / `GoogleService-Info.plist` | Вбудовано в проект |
| Twilio | Firebase Cloud Functions environment | Через CF, не в застосунку |
| Telegram Bot Token | Firebase Cloud Functions environment | Через CF, не в застосунку |
| Google Maps (геокодування) | Firebase Remote Config | Завантажується при старті |

**Важливо:** Жодних API ключів напряму в Flutter коді. Всі чутливі ключі тільки у Firebase Cloud Functions environment variables.

---

## 9. Off-Grid режим (детально)

### 9.1 Що відбувається без мережі

```
Без GSM / Wi-Fi:
  ✅ GPS продовжує працювати (через супутники навігаційних систем)
  ✅ Відеозапис працює (локально)
  ✅ Запис повідомлення в офлайн-чергу
  ✅ GPS-маршрут логується кожні 5 хвилин (Hive)
  ❌ Надсилання SMS, Push, Telegram — неможливо
  
При появі будь-якого сигналу (GSM, Wi-Fi):
  ✅ Офлайн-черга автоматично обробляється
  ✅ Відео завантажується, повідомлення надсилаються
  ✅ Контакти отримують координати + відео
```

### 9.2 Рекомендована конфігурація для туристів

Застосунок показує підказку при активації Off-Grid режиму:

> «Для надійного зв'язку в горах або пустелі без мобільної мережі рекомендуємо:
> - Garmin inReach Mini 2 (супутниковий месенджер, ~$350)
> - SPOT Gen4 (~$150 + підписка)
> - iPhone 14+ з Emergency SOS via Satellite (вбудовано)
> SafeSignal надішле повідомлення автоматично як тільки з'явиться будь-який сигнал»

### 9.3 Garmin inReach інтеграція (Version 2.0)

```
Garmin Messenger App API:
- Користувач прив'язує свій inReach пристрій через OAuth
- При натисканні SOS в SafeSignal → застосунок викликає Garmin API
- Garmin надсилає супутниковий SOS до GEOS International Emergency Response
- SafeSignal одночасно зберігає повідомлення в офлайн-чергу
```

---

## 10. Безпека та конфіденційність

### 10.1 Шифрування

| Дані | Де зберігаються | Шифрування |
|---|---|---|
| Медичний профіль (локально) | flutter_secure_storage | AES-256 (iOS Keychain / Android Keystore) |
| Медичний профіль (хмара) | Firestore | Firestore at-rest encryption |
| Відео (хмара) | Firebase Storage | Firebase at-rest encryption + HTTPS |
| API ключі | Cloud Functions env | Firebase secrets |
| Офлайн черга | Hive + encrypt | AES-256 |

### 10.2 GDPR відповідність (мінімальні вимоги)

- При реєстрації: явна згода (explicit consent) на обробку медичних даних
- Privacy Policy: пояснює що зберігається, де, скільки
- Право на видалення: кнопка «Видалити акаунт і всі дані» в налаштуваннях
- Мінімізація даних: не збираємо нічого зайвого
- Зберігання відео: автоматичне видалення через 30 днів (налаштовується)

### 10.3 Дисклеймер (обов'язковий в застосунку)

Показується при першому запуску та в розділі «Про застосунок»:

> «SafeSignal є допоміжним засобом екстреного зв'язку і **не замінює** служби екстреної медичної допомоги (103, 112). Застосунок не гарантує доставку повідомлень при відсутності мережі, розряді батареї або технічних збоях. При загрозі здоров'ю негайно телефонуйте 103 або 112. Розробники не несуть відповідальності за наслідки використання або невикористання застосунку.»

---

## 11. MVP Roadmap (GSD — конкретні кроки)

### Тиждень 1–2: Фундамент
- [ ] Налаштування Flutter проекту (FlutterFire CLI)
- [ ] Firebase Auth (email/пароль)
- [ ] GoRouter навігація (всі маршрути, порожні екрани)
- [ ] Riverpod структура (providers)
- [ ] Базова тема (кольори, шрифти)
- [ ] Hive ініціалізація

### Тиждень 3–4: Медпрофіль і контакти
- [ ] Екран медичного профілю (всі поля)
- [ ] CRUD контактів
- [ ] Збереження в Firestore
- [ ] Локальне шифрування (flutter_secure_storage)

### Тиждень 5–6: SOS Flow
- [ ] Головний екран з кнопкою SOS
- [ ] Відеозапис (camera plugin)
- [ ] GPS отримання (geolocator)
- [ ] Завантаження відео на Firebase Storage
- [ ] Збереження alert в Firestore
- [ ] Telegram Bot надсилання (перший канал)

### Тиждень 7–8: SMS + Офлайн + Сценарії
- [ ] Twilio SMS через Firebase Cloud Functions
- [ ] Офлайн черга (Hive + connectivity_plus)
- [ ] Екран сценаріїв (мінімум 1 дефолтний)
- [ ] Шаблон повідомлення з підстановками
- [ ] Екран підтвердження надсилання

### Тиждень 9–10: Полірування MVP
- [ ] Онбординг (3 слайди)
- [ ] Екран історії тривог
- [ ] QR-медкарта (базова)
- [ ] Push-сповіщення (FCM)
- [ ] Дисклеймер при першому запуску
- [ ] Тестування на реальних пристроях (iOS + Android)
- [ ] Підготовка до публікації в App Store / Google Play

---

## 12. Промти для Claude (шаблони)

При генерації коду для кожного модуля використовувати такий формат промту:

```
Ти senior Flutter розробник. Пишеш production-ready Dart код.
Стек: Flutter 3.x, Riverpod 2.x, GoRouter, Firebase (Firestore + Auth + Storage), Hive.
Архітектура: Clean Architecture (features/[назва]/data|domain|presentation).

Завдання: [опис конкретного модуля/екрану/функції]

Вимоги:
- Null safety
- Обробка всіх помилок (try/catch з кастомними exceptions)
- Loading / Error / Success стани через AsyncValue (Riverpod)
- Коментарі на ключових місцях
- [специфічні вимоги модуля]

Поверни:
1. Структуру файлів
2. Код кожного файлу повністю
3. Pubspec.yaml залежності що додати
```

---

*Документ оновлювати при кожній значній зміні архітектури або функціоналу.*
