abstract class Validators {
  static final _emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
  static final _phoneRegex = RegExp(r'^\+\d{10,15}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Некоректна адреса електронної пошти';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < 6) {
      return 'Пароль має бути мінімум 6 символів';
    }
    return null;
  }

  static String? required(String? value, [String fieldName = 'Поле']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обов\'язкове';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть номер телефону';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Формат: +380XXXXXXXXX';
    }
    return null;
  }
}
