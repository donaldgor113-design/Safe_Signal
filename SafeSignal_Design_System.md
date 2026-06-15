# SafeSignal — Design System

**Версія:** 1.0  
**Дата:** 15 червня 2026  
**Пов'язані документи:** SafeSignal_Technical_Document.md (розділ 5), SafeSignal_Error_Handling.md (розділ 6)

---

## 1. Дизайн-принципи

| Принцип | Пояснення | Приклад |
|---|---|---|
| **Panic-proof** | В момент паніки або нападу користувач бачить тільки головну дію. Нічого зайвого | SOS кнопка займає 60% екрану, один tap target |
| **Elderly-friendly** | Мінімальний розмір тексту 16sp, tap targets ≥ 48dp, контраст ≥ 4.5:1 | Persona «Дмитро», 67 років — повинен розібратись сам |
| **Trust through simplicity** | Застосунок не лякає. Спокійні кольори для загального UI, яскравий червоний тільки для SOS | Головний екран = спокійний фон + одна червона кнопка |
| **Status always visible** | Користувач завжди бачить чи все працює (GPS, мережа, профіль) | Статус-бар з кольоровими індикаторами на Home |
| **Graceful degradation** | Якщо щось недоступне — показуємо що саме і що робити, а не просто помилку | «GPS недоступний. Координати не додаються» замість технічного тексту |

---

## 2. Кольорова палітра

### 2.1 Light Theme (основна)

| Роль | Назва токена | HEX | Використання |
|---|---|---|---|
| **Primary** | `primary` | `#1565C0` | Кнопки, посилання, активні елементи, bottom nav |
| **On Primary** | `onPrimary` | `#FFFFFF` | Текст/іконки на primary-кольорі |
| **Primary Container** | `primaryContainer` | `#D1E4FF` | Фон виділених карток, chips |
| **Secondary** | `secondary` | `#455A64` | Другорядні кнопки, підписи |
| **On Secondary** | `onSecondary` | `#FFFFFF` | Текст на secondary |
| **Surface** | `surface` | `#FFFFFF` | Фон карток, bottom sheet, dialogs |
| **On Surface** | `onSurface` | `#1C1B1F` | Основний текст |
| **Background** | `background` | `#F5F5F5` | Фон екранів |
| **On Background** | `onBackground` | `#1C1B1F` | Текст на фоні |
| **Error** | `error` | `#C62828` | Помилки, деструктивні дії |
| **Tertiary** | `tertiary` | `#F57F17` | Попередження (warning banners) |
| **Outline** | `outline` | `#79747E` | Borders, dividers |
| **Surface Variant** | `surfaceVariant` | `#E7E0EC` | Неактивні поля, disabled стан |

### 2.2 Спеціальні кольори (не Material 3 tokens — custom)

| Роль | Назва | HEX | Використання |
|---|---|---|---|
| **SOS Red** | `sosRed` | `#D50000` | Тільки для кнопки SOS та SOS Flow |
| **SOS Red Pressed** | `sosRedPressed` | `#B71C1C` | Кнопка SOS при утриманні |
| **SOS Glow** | `sosGlow` | `#D50000` (30% opacity) | Пульсуюча анімація навколо SOS |
| **Status Active** | `statusActive` | `#2E7D32` | GPS є, мережа онлайн, профіль заповнено |
| **Status Warning** | `statusWarning` | `#F57F17` | Профіль неповний, офлайн-черга |
| **Status Inactive** | `statusInactive` | `#9E9E9E` | GPS немає, мережа відсутня |
| **Delivery Success** | `deliverySuccess` | `#2E7D32` | Канал доставлено (✓) |
| **Delivery Failed** | `deliveryFailed` | `#C62828` | Канал не доставлено (✗) |

### 2.3 Dark Theme

| Роль | HEX | Зміни відносно Light |
|---|---|---|
| Primary | `#90CAF9` | Світліший відтінок для читабельності на темному фоні |
| On Primary | `#003258` | Темний текст на світлому primary |
| Primary Container | `#004881` | Темніший контейнер |
| Surface | `#1E1E1E` | Темна поверхня |
| On Surface | `#E6E1E5` | Світлий текст |
| Background | `#121212` | Темний фон |
| On Background | `#E6E1E5` | Світлий текст на фоні |
| SOS Red | `#FF1744` | Яскравіший червоний для видимості на темному фоні |
| Status Active | `#69F0AE` | Яскравіший зелений |
| Status Warning | `#FFD54F` | Яскравіший жовтий |

**Правило:** Dark mode підтримуємо з першого дня. `ThemeMode.system` як дефолт, з можливістю вибору в Settings.

---

## 3. Типографіка

### 3.1 Шрифт

**Primary:** `Inter` (Google Fonts — безкоштовний, відмінна читабельність, підтримка кирилиці)  
**Fallback:** System default (Roboto на Android, SF Pro на iOS)

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.0.0
```

### 3.2 Шкала розмірів

| Стиль | Розмір (sp) | Вага | Line Height | Де використовується |
|---|---|---|---|---|
| `displayLarge` | 57 | 400 | 64 | Не використовується в MVP |
| `displayMedium` | 45 | 400 | 52 | Не використовується в MVP |
| `displaySmall` | 36 | 400 | 44 | Не використовується в MVP |
| `headlineLarge` | 32 | 600 | 40 | Заголовок екрану (рідко) |
| `headlineMedium` | 28 | 600 | 36 | Заголовки секцій на головному екрані |
| `headlineSmall` | 24 | 600 | 32 | Підзаголовки |
| `titleLarge` | 22 | 500 | 28 | AppBar title |
| `titleMedium` | 16 | 500 | 24 | Назва картки, назва контакту |
| `titleSmall` | 14 | 500 | 20 | Підзаголовки в картках |
| `bodyLarge` | 16 | 400 | 24 | **Основний текст** (мінімум для accessibility!) |
| `bodyMedium` | 14 | 400 | 20 | Другорядний текст, описи |
| `bodySmall` | 12 | 400 | 16 | Мітки, timestamps, хінти |
| `labelLarge` | 14 | 500 | 20 | Текст кнопок |
| `labelMedium` | 12 | 500 | 16 | Tab labels, chip text |
| `labelSmall` | 11 | 500 | 16 | Дрібні мітки |

### 3.3 Спеціальна типографіка

| Елемент | Стиль |
|---|---|
| SOS Countdown (3..2..1) | 96sp, Bold, `sosRed`, центровано |
| SOS Timer (залишок запису) | 48sp, SemiBold, White on dark overlay |
| Status bar icons label | `bodySmall`, під іконкою |
| Banner text | `bodyLarge`, Bold для заголовка + `bodyMedium` для опису |
| Empty state message | `bodyLarge`, `onSurface` 60% opacity, центровано |

---

## 4. Spacing & Layout

### 4.1 Grid система

**Base unit:** 4dp  
**Standard spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64

| Токен | Значення | Використання |
|---|---|---|
| `spacingXs` | 4dp | Між іконкою і текстом в рядку |
| `spacingSm` | 8dp | Внутрішній padding chips, мінімальний gap |
| `spacingMd` | 12dp | Gap між елементами в списку |
| `spacingLg` | 16dp | Padding екрану по горизонталі, gap між секціями |
| `spacingXl` | 24dp | Великий gap між секціями |
| `spacingXxl` | 32dp | Відступ зверху/знизу контенту |
| `spacingHuge` | 48dp | Відступ навколо SOS кнопки |

### 4.2 Screen padding

```
Горизонтальний padding: 16dp (всі екрани)
Top padding: SafeArea + 16dp
Bottom padding: SafeArea + 16dp (або bottom nav height)
```

### 4.3 Touch targets

| Елемент | Мінімальний розмір | Рекомендований |
|---|---|---|
| Будь-який інтерактивний елемент | 48 × 48 dp | 56 × 48 dp |
| SOS кнопка | — | 200 × 200 dp |
| Bottom Navigation item | 48 × 48 dp | 64 × 56 dp |
| Cancel button (SOS Flow) | 56 × 56 dp | 72 × 56 dp |
| FAB (додати контакт) | 56 × 56 dp | 56 × 56 dp |

---

## 5. Компоненти

### 5.1 Кнопки

| Тип | Коли використовувати | Стиль |
|---|---|---|
| **Filled (primary)** | Головна дія на екрані (Зберегти, Далі) | `FilledButton`, primary color, border-radius 12dp |
| **Filled Tonal** | Другорядна дія (Скасувати, Назад) | `FilledButton.tonal`, primaryContainer |
| **Outlined** | Третя опція, менш важлива | `OutlinedButton`, border 1dp outline color |
| **Text** | Навігаційні дії (Пропустити, Забули пароль?) | `TextButton`, primary color |
| **SOS Button** | Тільки на Home screen | Custom: circular 200dp, `sosRed`, elevation 8 |
| **Danger** | Деструктивні дії (Видалити акаунт) | `FilledButton`, error color |

**Висота всіх кнопок (крім SOS):** 48dp мінімум  
**Border radius:** 12dp  
**Текст кнопок:** `labelLarge`, UPPERCASE не використовуємо

### 5.2 Картки (Cards)

```
Стиль: Material 3 Filled Card
Border radius: 16dp
Elevation: 0 (filled) або 1 (elevated)
Padding: 16dp
Background: surface
Border: немає (filled) або 1dp outline (outlined)
```

**Використання:**
- Контакт у списку → Filled Card
- Сценарій у списку → Filled Card
- Тривога в історії → Outlined Card
- Медпрофіль секція → Filled Card

### 5.3 Input Fields

```
Стиль: OutlinedTextField (Material 3)
Border radius: 12dp
Height: 56dp
Label: float above on focus
Helper text: bodySmall, під полем
Error text: bodySmall, error color, під полем
```

### 5.4 Bottom Navigation Bar

```
5 items: Головна | Профіль | Контакти | Сценарії | Ще
Стиль: Material 3 NavigationBar
Іконки: Material Icons Outlined (inactive) → Filled (active)
Label: завжди видимий (labelMedium)
Height: 80dp
```

**Іконки Bottom Nav:**

| Tab | Іконка (outlined) | Іконка (filled) |
|---|---|---|
| Головна | `home_outlined` | `home` |
| Профіль | `medical_information_outlined` | `medical_information` |
| Контакти | `contacts_outlined` | `contacts` |
| Сценарії | `emergency_outlined` | `emergency` |
| Ще | `more_horiz` | `more_horiz` |

### 5.5 Status Bar (Home screen)

```
Позиція: верхня частина Home screen, під AppBar
Layout: Row, 3 іконки з мітками, evenly spaced
Кожен елемент:
  - Іконка 24dp
  - Мітка bodySmall під іконкою
  - Колір: statusActive / statusWarning / statusInactive
```

| Елемент | Іконка | Active | Warning | Inactive |
|---|---|---|---|---|
| GPS | `location_on` | Зелена: «GPS ✓» | — | Сіра: «GPS ✗» |
| Мережа | `wifi` / `signal_cellular_alt` | Зелена: «Онлайн» | Помаранчева: «Черга (N)» | Сіра: «Офлайн» |
| Медпрофіль | `medical_information` | Зелена: «Профіль ✓» | Жовта: «Неповний» | — |

### 5.6 Banners (повідомлення)

| Тип | Фон | Іконка | Border |
|---|---|---|---|
| Info | `primaryContainer` | `info_outline`, primary | — |
| Warning | `#FFF3E0` (amber 50) | `warning_amber`, tertiary | — |
| Error | `#FFEBEE` (red 50) | `error_outline`, error | — |
| Success | `#E8F5E9` (green 50) | `check_circle_outline`, statusActive | — |
| Offline | `#ECEFF1` (blueGrey 50) | `cloud_off`, statusInactive | — |

```
Layout: Row(icon, Expanded(Column(title, subtitle)), closeButton?)
Padding: 12dp
Border radius: 12dp
Margin: 16dp horizontal
```

### 5.7 SOS Button (спеціальний компонент)

```
Форма: Circle
Діаметр: 200dp
Колір фону: sosRed
Колір тексту: white
Текст: «SOS» (headlineLarge, bold)
Підтекст: «Утримуй 2 сек» (bodySmall, white 70%)
Elevation: 8dp
Shadow: sosRed з 25% opacity

Стани:
  - Default: статичний, легке "breathing" animation (scale 1.0 → 1.02, 3 сек цикл)
  - Pressed (утримання): scale зменшується до 0.95, progress ring з'являється навколо
  - Disabled (немає контактів): сірий (#9E9E9E), без анімації, текст «Додай контакт»
  - Countdown active: зникає, замість неї — великий countdown (3...2...1)

Анімація пульсації (default):
  - Два кола навколо кнопки з sosGlow
  - Scale: 1.0 → 1.3, opacity 0.3 → 0.0
  - Duration: 2s, infinite repeat
  - Staggered: друге коло стартує з 1s delay
```

---

## 6. Іконки

### 6.1 Набір іконок

**Primary:** `Material Icons` (вбудовані в Flutter, не потребують додаткових пакетів)  
**Variant:** `Outlined` для неактивних, `Filled` для активних

### 6.2 Кастомні іконки (якщо Material не підходить)

| Елемент | Рекомендація |
|---|---|
| App icon | Кастомний: щит (shield) + серце (heart) + signal wave. Кольори: primary blue + sosRed |
| Splash logo | Те саме що app icon, більший розмір, з текстом «SafeSignal» |
| Onboarding illustrations | Прості vector illustrations (можна згенерувати або використати unDraw) |

### 6.3 Розміри іконок

| Контекст | Розмір |
|---|---|
| Bottom Nav | 24dp |
| AppBar actions | 24dp |
| List item leading | 24dp |
| Status bar (Home) | 24dp |
| Card action | 20dp |
| Input field suffix | 20dp |
| Empty state illustration | 120dp |
| Onboarding illustration | 200dp |
| Home Widget SOS button | 64dp (всередині віджету 2×2) |
| Quick Settings Tile icon | 24dp (monochrome, білий) |
| Notification icon | 24dp (monochrome, білий для status bar) |

---

## 6.5 Quick SOS компоненти

### Home Screen Widget (2×2)

```
Розмір: 110×110 dp (Android 2×2) / Small (iOS)
Фон: surface (white / dark surface)
Border radius: 16dp
Padding: 12dp

Вміст:
  - SOS кнопка (коло): 64dp, sosRed, текст "SOS" (18sp, bold, white)
  - Під кнопкою: назва активного сценарію (11sp, onSurface 60%)
  - Кут: маленький логотип SafeSignal (16dp, onSurface 40%)

Стани:
  - Active: червона кнопка, нормальний фон
  - Service inactive: сіра кнопка (#9E9E9E), текст "Неактивно"
```

### Persistent Notification (Android)

```
Стиль: Foreground Service notification
Importance: IMPORTANCE_LOW (без звуку, постійне)
Small icon: ic_shield (monochrome, 24dp)
Title: "SafeSignal активний"
Body: "Сценарій: {{scenario_name}}"
Action button:
  - Text: "SOS"
  - Color: використовує системний accent (Android обмеження)
  - Icon: ic_sos_action (24dp, monochrome)
```

### Shake Confirmation Notification

```
Стиль: Heads-up notification (high importance)
Sound: системний notification sound
Title: "Активувати SOS?"
Body: "Телефон зафіксував різкий рух"
Actions:
  - "Так, SOS" → safesignal://sos
  - "Ні, все добре" → dismiss + cooldown
Auto-dismiss: 10 секунд
```

## 7. Анімації та переходи

### 7.1 Навігаційні переходи

| Перехід | Анімація | Duration |
|---|---|---|
| Push (вперед) | Slide from right | 300ms |
| Pop (назад) | Slide to right | 250ms |
| Bottom sheet | Slide from bottom | 250ms |
| Dialog | Fade + scale (0.9→1.0) | 200ms |
| Tab switch (bottom nav) | Fade crossfade | 200ms |

### 7.2 SOS Flow анімації

| Елемент | Анімація | Duration |
|---|---|---|
| SOS Pulsation (home) | Scale 1.0→1.3 + fade out | 2s loop |
| Countdown (3..2..1) | Scale 1.5→1.0 + fade in per number | 1s per number |
| Recording indicator | Blinking red dot (opacity 1.0↔0.3) | 1s loop |
| Progress steps | Slide up + fade in (sequentially) | 300ms per step |
| Delivery status check | Scale 0→1 + color fill | 200ms per channel |
| Success screen | Check mark draw animation | 500ms |

### 7.3 Micro-interactions

| Елемент | Анімація |
|---|---|
| Button press | Scale 0.95 + slight darken | 100ms |
| Card tap | Elevation 0→2 | 100ms |
| Toggle switch | Slide + color change | 200ms |
| Snackbar | Slide from bottom | 250ms + auto dismiss 3s |
| Pull to refresh | Standard Material refresh indicator |

### 7.4 Easing curves

```dart
// Всі анімації
const defaultCurve = Curves.easeInOutCubic;
const entranceCurve = Curves.easeOutCubic;
const exitCurve = Curves.easeInCubic;
// SOS pulsation — specially smooth
const pulseCurve = Curves.easeInOut;
```

---

## 8. Accessibility

### 8.1 Обов'язкові вимоги

| Вимога | Значення | Перевірка |
|---|---|---|
| Мінімальний контраст тексту | 4.5:1 (AA) | Всі text/background комбінації |
| Мінімальний контраст великого тексту | 3:1 (AA) | headlineLarge і більше |
| Мінімальний touch target | 48 × 48 dp | Всі інтерактивні елементи |
| Semantics labels | Всі іконки та кнопки | `Semantics(label: ...)` |
| Screen reader | Підтримка TalkBack/VoiceOver | SOS кнопка описана як «Кнопка екстреного виклику. Утримуйте 2 секунди для активації» |

### 8.2 Перевірка контрастів (наші основні комбінації)

| Текст | Фон | Контраст | Результат |
|---|---|---|---|
| `#1C1B1F` on `#FFFFFF` | Surface | 16.5:1 | AA ✓ |
| `#1C1B1F` on `#F5F5F5` | Background | 14.7:1 | AA ✓ |
| `#FFFFFF` on `#1565C0` | Primary button | 6.4:1 | AA ✓ |
| `#FFFFFF` on `#D50000` | SOS button | 5.7:1 | AA ✓ |
| `#FFFFFF` on `#C62828` | Error | 6.5:1 | AA ✓ |
| `#2E7D32` on `#E8F5E9` | Success banner | 4.9:1 | AA ✓ |

### 8.3 Розмір тексту

```
Мінімум для будь-якого тексту в застосунку: 12sp (bodySmall)
Основний робочий текст: 16sp (bodyLarge) — НЕ менше для Persona «Дмитро»
Застосунок підтримує system font scaling (MediaQuery.textScaleFactor)
При scale > 1.3 — layout адаптується (горизонтальні списки стають вертикальними)
```

---

## 9. Екрани — Layout Guidelines

### 9.1 Home Screen

```
┌──────────────────────────────┐
│  SafeSignal            [⚙️]  │ ← AppBar (flat, no elevation)
├──────────────────────────────┤
│  [📍GPS ✓] [📶Online] [🏥✓]  │ ← Status bar (3 indicators)
│                              │
│         ┌────────┐           │
│         │ Пульс  │           │
│         │  ація  │           │
│         │        │           │
│         │  SOS   │           │ ← SOS Button (center, 200dp)
│         │        │           │
│         │Утримуй │           │
│         │ 2 сек  │           │
│         └────────┘           │
│                              │
│    Активний: «Основний» ▾    │ ← Scenario switcher
│                              │
│  ⚠️ Заповни медпрофіль       │ ← Warning banner (if needed)
│                              │
├──────────────────────────────┤
│ 🏠  👤  📞  🚨  •••         │ ← Bottom Navigation
└──────────────────────────────┘
```

### 9.2 SOS Flow — Countdown

```
┌──────────────────────────────┐
│                              │
│                              │
│                              │
│            ╔══╗              │
│            ║ 3║              │ ← Big countdown number (96sp)
│            ╚══╝              │
│                              │
│    Починаємо запис...        │ ← bodyLarge, white
│                              │
│                              │
│    ┌──────────────────┐      │
│    │    СКАСУВАТИ      │      │ ← Large cancel button
│    └──────────────────┘      │
│                              │
└──────────────────────────────┘
Background: semi-transparent black overlay (85% opacity)
```

### 9.3 SOS Flow — Recording

```
┌──────────────────────────────┐
│  🔴 REC                0:24  │ ← Recording indicator + timer
├──────────────────────────────┤
│                              │
│     ┌──────────────────┐     │
│     │                  │     │
│     │   Camera Preview │     │ ← Front camera feed
│     │                  │     │
│     │                  │     │
│     └──────────────────┘     │
│                              │
│  ┌────────────┐ ┌──────────┐ │
│  │ Зупинити і │ │ Без      │ │ ← Two action buttons
│  │ надіслати  │ │ відео    │ │
│  └────────────┘ └──────────┘ │
│                              │
└──────────────────────────────┘
Background: dark (camera UI)
```

### 9.4 SOS Flow — Sending & Confirmation

```
┌──────────────────────────────┐
│                              │
│     ✓ GPS отримано           │ ← Step 1 (green check)
│     ✓ Відео завантажено      │ ← Step 2 (green check)
│     ⏳ Надсилаю...            │ ← Step 3 (loading spinner)
│                              │
│     SMS: Мама        ✓       │ ← Delivery status per contact
│     SMS: Подруга     ✓       │
│     Telegram: Лікар  ⏳       │
│                              │
│                              │
│    Надіслано 2 з 3 контактів │
│                              │
│    ┌──────────────────┐      │
│    │     Закрити       │      │
│    └──────────────────┘      │
│    Переглянути що надіслано → │
└──────────────────────────────┘
```

### 9.5 Medical Profile

```
┌──────────────────────────────┐
│  ← Медичний профіль         │ ← AppBar with back
├──────────────────────────────┤
│                              │
│  Особиста інформація    ──── │ ← Section header
│  ┌──────────────────────┐    │
│  │ Ім'я                 │    │ ← TextFields
│  │ Дата народження      │    │
│  └──────────────────────┘    │
│                              │
│  Діагнози               ──── │
│  ┌──────────────────────┐    │
│  │ [Епілепсія ×] [+]    │    │ ← Chips + add
│  └──────────────────────┘    │
│                              │
│  Ліки                   ──── │
│  ┌──────────────────────┐    │
│  │ Карведилол 12.5мг    │    │ ← Expandable cards
│  │ 2 рази на день       │    │
│  │            [Видалити] │    │
│  └──────────────────────┘    │
│  [+ Додати ліки]             │
│                              │
│  ┌──────────────────────┐    │
│  │     💾 Зберегти       │    │ ← Primary filled button
│  └──────────────────────┘    │
│  Згенерувати QR-карту →      │ ← Text button
│                              │
├──────────────────────────────┤
│ 🏠  👤  📞  🚨  •••         │
└──────────────────────────────┘
```

### 9.6 Contacts List

```
┌──────────────────────────────┐
│  Контакти                [+] │ ← AppBar + FAB
├──────────────────────────────┤
│                              │
│  ┌──────────────────────┐    │
│  │ 👩 Мама               │    │
│  │ Мати  📱SMS ✈️Telegram│    │ ← Card with channels
│  │         [Перевірити →]│    │
│  └──────────────────────┘    │
│                              │
│  ┌──────────────────────┐    │
│  │ 👩 Оксана             │    │
│  │ Подруга       📱SMS   │    │
│  │         [Перевірити →]│    │
│  └──────────────────────┘    │
│                              │
│  ┌──────────────────────┐    │
│  │ 👨‍⚕️ Др. Петренко       │    │
│  │ Лікар    ✈️Telegram   │    │
│  │         [Перевірити →]│    │
│  └──────────────────────┘    │
│                              │
├──────────────────────────────┤
│ 🏠  👤  📞  🚨  •••         │
└──────────────────────────────┘
```

---

## 10. App Icon та Branding

### 10.1 App Icon

**Концепція:** Щит (shield) як символ захисту + signal wave (дуги) як символ зв'язку  
**Кольори:** Білий щит на gradient від `#1565C0` до `#0D47A1`, червона signal wave  
**Форма:** Adaptive icon (Android) + стандартний квадрат з rounded corners (iOS)

### 10.2 Splash Screen

```
Фон: primary (#1565C0)
Центр: App icon (білий, 96dp) + «SafeSignal» (headlineMedium, white)
Перехід: fade out → Home або Auth
Duration: 1.5s max (менше якщо Firebase Auth відповів швидше)
```

### 10.3 Onboarding Illustrations

Стиль: flat vector, м'які кольори (primary + primaryContainer), прості форми  
Розмір: 200dp × 200dp  
Джерело: SVG assets у `assets/illustrations/`

| Слайд | Ілюстрація | Текст |
|---|---|---|
| 1 | Рука натискає велику кнопку → signal waves розходяться | «Одна кнопка — і близькі знають» |
| 2 | Медична картка з серцем | «Заповни профіль один раз» |
| 3 | Телефони з'єднані лініями (контакти) | «Обери кому надсилати» |

---

## 11. Dart Theme Implementation Reference

```dart
// app/theme.dart — орієнтовна структура

// Light Theme ColorScheme
ColorScheme.fromSeed(
  seedColor: Color(0xFF1565C0),
  primary: Color(0xFF1565C0),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD1E4FF),
  secondary: Color(0xFF455A64),
  error: Color(0xFFC62828),
  tertiary: Color(0xFFF57F17),
  surface: Color(0xFFFFFFFF),
  background: Color(0xFFF5F5F5),
  brightness: Brightness.light,
)

// Dark Theme ColorScheme
ColorScheme.fromSeed(
  seedColor: Color(0xFF1565C0),
  primary: Color(0xFF90CAF9),
  onPrimary: Color(0xFF003258),
  surface: Color(0xFF1E1E1E),
  background: Color(0xFF121212),
  brightness: Brightness.dark,
)

// Custom extension for SOS colors
@immutable
class SafeSignalColors extends ThemeExtension<SafeSignalColors> {
  final Color sosRed;
  final Color sosRedPressed;
  final Color sosGlow;
  final Color statusActive;
  final Color statusWarning;
  final Color statusInactive;
  final Color deliverySuccess;
  final Color deliveryFailed;
}
```

---

*Документ оновлюється при зміні візуального стилю або додаванні нових компонентів.*
