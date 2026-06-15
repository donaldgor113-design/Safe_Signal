import 'dart:math';

import 'package:safe_signal/core/constants/app_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';

Future<T> withRetry<T>(Future<T> Function() operation) async {
  int attempt = 0;
  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= AppConstants.maxRetries) rethrow;
      if (e is NetworkException || e is NetworkTimeoutException) {
        await Future.delayed(
          Duration(
            seconds: pow(2, attempt - 1).toInt() *
                AppConstants.retryDelayBaseSeconds,
          ),
        );
        continue;
      }
      rethrow;
    }
  }
}
