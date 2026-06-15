abstract class SafeSignalException implements Exception {
  final String message;
  final String? technicalDetails;
  const SafeSignalException(this.message, {this.technicalDetails});

  @override
  String toString() => message;
}

class NetworkException extends SafeSignalException {
  const NetworkException({String? technicalDetails})
      : super('Немає підключення до мережі',
            technicalDetails: technicalDetails);
}

class NetworkTimeoutException extends SafeSignalException {
  const NetworkTimeoutException({String? technicalDetails})
      : super('Перевищено час очікування',
            technicalDetails: technicalDetails);
}

class FirebaseAuthException extends SafeSignalException {
  const FirebaseAuthException(super.message, {String? technicalDetails})
      : super(technicalDetails: technicalDetails);
}

class FirestoreException extends SafeSignalException {
  const FirestoreException({String? technicalDetails})
      : super('Помилка збереження даних',
            technicalDetails: technicalDetails);
}

class StorageException extends SafeSignalException {
  const StorageException({String? technicalDetails})
      : super('Помилка завантаження файлу',
            technicalDetails: technicalDetails);
}

class CameraPermissionException extends SafeSignalException {
  const CameraPermissionException()
      : super('Немає доступу до камери. Дозвольте доступ у налаштуваннях');
}

class MicrophonePermissionException extends SafeSignalException {
  const MicrophonePermissionException()
      : super(
            'Немає доступу до мікрофону. Дозвольте доступ у налаштуваннях');
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

class SosNoContactsException extends SafeSignalException {
  const SosNoContactsException()
      : super('Додайте хоча б один екстрений контакт');
}

class SosDeliveryPartialException extends SafeSignalException {
  final List<String> failedChannels;
  const SosDeliveryPartialException(this.failedChannels,
      {String? technicalDetails})
      : super('Деякі повідомлення не надіслані',
            technicalDetails: technicalDetails);
}

class SosOfflineQueuedException extends SafeSignalException {
  const SosOfflineQueuedException()
      : super(
            'Немає мережі. SOS збережено та буде надіслано при появі зв\'язку');
}

class TwilioException extends SafeSignalException {
  const TwilioException({String? technicalDetails})
      : super('SMS не надіслано', technicalDetails: technicalDetails);
}

class TelegramException extends SafeSignalException {
  const TelegramException({String? technicalDetails})
      : super('Telegram повідомлення не надіслано',
            technicalDetails: technicalDetails);
}
