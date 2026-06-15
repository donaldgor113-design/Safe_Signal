# SafeSignal — Error Handling Strategy

**Версія:** 1.0  
**Дата:** 15 червня 2026  
**Пов'язані документи:** SafeSignal_Technical_Document.md, SafeSignal_API_Contract.md

Цей документ — угода для всього застосунку.  
**Claude дотримується цих правил у кожному файлі, що генерує.** Без виключень.

---

## 1. Загальний принцип

```
Помилка → Зрозумій → Обробляй → Повідом → Відновися (якщо можливо)
```

Жодна помилка не повинна:
- Крашити застосунок (uncaught exception)  
- Показувати технічний стектрейс користувачу  
- Мовчки ігноруватись (silent fail)  
- Блокувати застосунок назавжди (нескінченний loading)

---

## 2. Ієрархія кастомних помилок

```dart
// core/errors/exceptions.dart

abstract class SafeSignalException implements Exception {
  final String message;
  final String? technicalDetails; // для логів, не для UI
  const SafeSignalException(this.message, {this.technicalDetails});
}

// Мережеві помилки
class NetworkException extends SafeSignalException {
  const NetworkException({String? technicalDetails})
    : super('Немає підключення до мережі', technicalDetails: technicalDetails);
}

class NetworkTimeoutException extends SafeSignalException {
  const NetworkTimeoutException({String? technicalDetails})
    : super('Перевищено час очікування', technicalDetails: technicalDetails);
}

// Firebase помилки
class FirebaseAuthException extends SafeSignalException {
  const FirebaseAuthException(String message, {String? technicalDetails})
    : super(message, technicalDetails: technicalDetails);
}

class FirestoreException extends SafeSignalException {
  const FirestoreException({String? technicalDetails})
    : super('Помилка збереження даних', technicalDetails: technicalDetails);
}

class StorageException extends SafeSignalException {
  const StorageException({String? technicalDetails})
    : super('Помилка завантаження файлу', technicalDetails: technicalDetails);
}

// Пристроєві помилки
class CameraPermissionException extends SafeSignalException {
  const CameraPermissionException()
    : super('Немає доступу до камери. Дозвольте доступ у налаштуваннях');
}

class MicrophonePermissionException extends SafeSignalException {
  const MicrophonePermissionException()
    : super('Немає доступу до мікрофону. Дозвольте доступ у налаштуваннях');
}

class LocationPermissionException extends SafeSignalException {
  const LocationPermissionException()
    : super('Немає доступу до GPS. Дозвольте доступ у налаштуваннях');
}

class LocationUnavailableException extends SafeSignalException {
  const LocationUnavailableException()
    : super('GPS недоступний. Координати не додаються до повідомлення');
}

class CameraUnavailableException extends SafeSignalException {
  const CameraUnavailableException()
    : super('Камера недоступна. SOS надіслано без відео');
}

// SOS-специфічні помилки
class SosNoContactsException extends SafeSignalException {
  const SosNoContactsException()
    : super('Додайте хоча б один екстрений контакт');
}

class SosDeliveryPartialException extends SafeSignalException {
  final List<String> failedChannels;
  const SosDeliveryPartialException(this.failedChannels, {String? technicalDetails})
    : super('Деякі повідомлення не надіслані', technicalDetails: technicalDetails);
}

class SosOfflineQueuedException extends SafeSignalException {
  const SosOfflineQueuedException()
    : super('Немає мережі. SOS збережено та буде надіслано при появі зв\'язку');
}

// Зовнішні сервіси
class TwilioException extends SafeSignalException {
  const TwilioException({String? technicalDetails})
    : super('SMS не надіслано', technicalDetails: technicalDetails);
}

class TelegramException extends SafeSignalException {
  const TelegramException({String? technicalDetails})
    : super('Telegram повідомлення не надіслано', technicalDetails: technicalDetails);
}
```

---

## 3. Таблиця сценаріїв — що відбувається при кожній помилці

### 3.1 Помилки мережі

| Помилка | Де виникає | Дія | UI для користувача |
|---|---|---|---|
| Немає інтернету (offline) | SOS Flow | Зберегти в `offline_queue` | Зелений банер: «Збережено. Надішлемо при появі мережі» |
| Timeout (> 10 сек) | SOS надсилання | Retry 3 рази з exp. backoff, потім → queue | Показати стан «Надсилаємо...» → «Збережено в черзі» |
| 5xx від Cloud Functions | Twilio / Telegram | Оновити `deliveryStatus.{channel} = "failed"`, спробувати решту каналів | Жовте попередження на екрані підтвердження |
| 4xx від Cloud Functions | Будь-де | Log + показати технічне повідомлення для розробника (тільки debug mode) | «Щось пішло не так. Спробуйте ще раз» |

### 3.2 Помилки дозволів (permissions)

| Дозвіл | Якщо відмовлено | Fallback | UI |
|---|---|---|---|
| Камера | Записати SOS без відео | `CameraUnavailableException` | Жовте попередження: «Відео недоступне. Надіслати тільки GPS + медпрофіль?» → кнопка «Так, надіслати» |
| Мікрофон | Аналогічно | Аналогічно | Аналогічно |
| GPS | Надіслати SOS без координат | `LocationUnavailableException` | Жовте попередження: «GPS недоступний. Координати не додаються» |
| Push-сповіщення | SOS надсилається, push не доступний | Вимкнути push у сценарії | Банер у налаштуваннях: «Дозвольте push для надійнішого оповіщення» |

**Правило для всіх permission-помилок:**  
SOS надсилається в будь-якому випадку з тим що є. Ніколи не блокуємо SOS через відсутність дозволу.

### 3.3 SOS Flow — специфічні помилки

| Стан | Що відбувається | Резервний план |
|---|---|---|
| Немає контактів | Кнопка SOS неактивна (сірого кольору) | Банер «Додай контакт щоб активувати SOS» |
| Медпрофіль порожній | SOS активний, але надсилається без медінфо | Жовтий статус на іконці медпрофілю на home |
| Відео не завантажилось на Storage | Надіслати SOS без URL відео | Зберегти відео локально, спробувати завантажити при мережі |
| Усі канали провалились | SOS у `offline_queue` повністю | Червоний банер: «Не вдалось надіслати. Є у черзі — спробуємо ще раз» |
| Частина каналів провалилась | Відзначити провалені у `deliveryStatus` | Жовте попередження з переліком: «SMS не надіслано. Telegram — ✓» |

### 3.4 Firebase / Firestore помилки

| Помилка | Де | Дія | UI |
|---|---|---|---|
| permission-denied | Читання/запис Firestore | Вийти з сесії (можливо застаріла Auth) → redirect /auth/login | Тихо, без технічних деталей |
| unavailable | Firestore offline | Firestore сам кешує і синхронізує при відновленні | Показати offline-банер |
| not-found | Читання документу | Показати empty state для цього екрану | Empty state з кнопкою «Спробувати ще раз» |
| quota-exceeded | Будь-де | Log в Crashlytics, показати повідомлення | «Технічні проблеми. Ми вже знаємо і виправляємо» |

### 3.5 Firebase Auth помилки

| Firebase код | Повідомлення для користувача |
|---|---|
| `email-already-in-use` | «Ця пошта вже використовується» |
| `wrong-password` | «Неправильний пароль» |
| `user-not-found` | «Акаунт з такою поштою не знайдено» |
| `too-many-requests` | «Забагато спроб. Спробуйте через кілька хвилин» |
| `network-request-failed` | «Немає підключення до мережі» |
| `invalid-email` | «Некоректна адреса електронної пошти» |
| Будь-яка інша | «Помилка входу. Спробуйте ще раз» |

---

## 4. Retry-стратегія

```dart
// Єдина стратегія для всіх мережевих операцій
// core/utils/retry_helper.dart

const int kMaxRetries = 3;

// Exponential backoff: 1с → 2с → 4с
Future<T> withRetry<T>(Future<T> Function() operation) async {
  int attempt = 0;
  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= kMaxRetries) rethrow;
      if (e is NetworkException || e is NetworkTimeoutException) {
        await Future.delayed(Duration(seconds: pow(2, attempt - 1).toInt()));
        continue;
      }
      rethrow; // не-мережеві помилки → не ретраїти
    }
  }
}
```

**Правила retry:**
- Мережеві помилки (timeout, network unavailable) → ретраї з backoff
- 4xx помилки → НЕ ретраїти (проблема в запиті, не в мережі)
- 5xx помилки → ретраї (тимчасова проблема сервера)
- Permission помилки → НЕ ретраїти (потрібна дія користувача)

---

## 5. Offline Queue — обробка помилок

```
Стан offline_queue елемента:

pending  → надсилання у процесі / очікує мережі
failed   → всі спроби вичерпано (attempts >= maxAttempts)
sent     → успішно надіслано → видалити з черги

Правила:
- maxAttempts = 10 (значення з Remote Config: offline_queue_max_attempts)
- Після кожної невдалої спроби: attempts++
- При attempts >= maxAttempts: статус = "failed", сповістити користувача
- При появі мережі (connectivity_plus): обробити всі pending елементи
- Успішно надіслано → видалити з Hive box
- Failed елементи зберігаються 7 днів, потім автоматично видаляються
```

---

## 6. UI-компоненти для помилок

### Що показуємо коли

| Тип | Компонент | Коли використовувати |
|---|---|---|
| Inline validation | Червоний текст під полем | Помилки форм (пошта, телефон) |
| Snackbar (3 сек) | `ScaffoldMessenger.showSnackBar` | Не критичні: «Збережено», «Скасовано» |
| Warning banner | Жовтий банер угорі екрану | SOS надіслано частково, GPS недоступний |
| Error banner | Червоний банер угорі | SOS не надіслано, критична помилка |
| Bottom sheet | Модальний з поясненням + кнопками | Запит дозволу, підтвердження дії |
| Full-screen error | Окремий стан екрану | Мережа повністю відсутня, невдала завантаження |
| Alert dialog | `showDialog` | Деструктивні дії (видалення), важливі рішення |

### Стилізація (узгоджено з Material 3)

```dart
// Не придумувати нові кольори — використовувати тему
// Success: Theme.of(context).colorScheme.primary
// Warning: Theme.of(context).colorScheme.tertiary  
// Error:   Theme.of(context).colorScheme.error
// Info:    Theme.of(context).colorScheme.secondary
```

---

## 7. Логування помилок

```dart
// Що логувати (Firebase Crashlytics)
// core/services/logger_service.dart

// ✅ Логувати завжди:
// - SosDeliveryPartialException (який канал провалився і чому)
// - StorageException (завантаження відео провалилось)
// - TwilioException (SMS не надіслано)
// - TelegramException (Telegram не надіслано)
// - Будь-яка неочікувана помилка (catch unknown)

// ❌ НЕ логувати (чутливі дані):
// - Медичні дані користувача
// - GPS координати
// - Вміст повідомлень
// - Email, телефон, Chat ID

FirebaseCrashlytics.instance.recordError(
  exception,
  stackTrace,
  reason: 'SOS delivery failed: ${exception.runtimeType}',
  fatal: false,
);
```

---

## 8. Правила для Claude при генерації коду

1. **Кожен repository-метод** обгорнутий у try/catch і кидає кастомний SafeSignalException.
2. **Провайдери (Riverpod)** повертають `AsyncValue<T>` — ніколи не повертають nullable і не кидають виключення напряму в UI.
3. **Перевірки дозволів** завжди виконуються до початку запису/GPS, але ніколи не блокують SOS-надсилання.
4. **SOS-надсилання** ніколи не зупиняється через помилку одного каналу — намагатися надіслати по всіх інших каналах.
5. **Fallback завжди існує**: немає відео → надіслати без відео; немає GPS → надіслати без координат; немає мережі → в офлайн-чергу.
6. **Технічні деталі помилок** (`technicalDetails`) ніколи не показуються в UI. Тільки в debug-логах.

