abstract class AppConstants {
  static const String appName = 'SafeSignal';
  static const String deepLinkScheme = 'safesignal';

  static const int sosHoldDurationMs = 2000;
  static const int sosCountdownSeconds = 3;
  static const int defaultRecordDurationSeconds = 30;
  static const int maxRecordDurationSeconds = 60;

  static const int offlineQueueMaxAttempts = 10;
  static const int retryDelayBaseSeconds = 1;
  static const int maxRetries = 3;

  static const int shakeConfirmationTimeoutSeconds = 10;
  static const int shakeCooldownSeconds = 30;

  static const int gpsLogIntervalMinutes = 5;
  static const int videoAutoDeleteDays = 30;

  static const double immobilityMagnitudeThreshold = 9.3;
  static const double shakeMagnitudeThreshold = 20.0;

  static const String disclaimerText =
      'SafeSignal є допоміжним засобом екстреного зв\'язку і не замінює '
      'служби екстреної медичної допомоги (103, 112). Застосунок не гарантує '
      'доставку повідомлень при відсутності мережі, розряді батареї або '
      'технічних збоях. При загрозі здоров\'ю негайно телефонуйте 103 або 112. '
      'Розробники не несуть відповідальності за наслідки використання або '
      'невикористання застосунку.';
}
