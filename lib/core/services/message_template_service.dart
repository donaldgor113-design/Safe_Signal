class MessageTemplateService {
  static String substituteTemplate({
    required String template,
    required String userName,
    required double latitude,
    required double longitude,
    String? address,
    String? diagnosis,
    String? videoUrl,
  }) {
    String result = template;

    result = result.replaceAll('{{userName}}', userName);
    result = result.replaceAll('{{location}}', '$latitude, $longitude');
    result = result.replaceAll(
      '{{address}}',
      address ?? '$latitude, $longitude',
    );
    result = result.replaceAll(
      '{{timestamp}}',
      _formatTimestamp(DateTime.now()),
    );
    result = result.replaceAll(
      '{{diagnoses}}',
      diagnosis != null ? '🏥 Діагноз: $diagnosis' : '',
    );
    result = result.replaceAll(
      '{{videoUrl}}',
      videoUrl != null ? '📹 Відео: $videoUrl' : '',
    );

    result = result.replaceAll(RegExp(r'\n\s*\n'), '\n');

    return result.trim();
  }

  static String _formatTimestamp(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }
}
