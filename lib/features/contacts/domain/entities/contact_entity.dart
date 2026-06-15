enum NotifyChannel { sms, telegram }

class ContactEntity {
  final String id;
  final String name;
  final String phone;
  final String? telegramChatId;
  final String? email;
  final String relationship;
  final List<NotifyChannel> notifyChannels;

  const ContactEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.telegramChatId,
    this.email,
    required this.relationship,
    required this.notifyChannels,
  });

  static const List<String> relationshipOptions = [
    'Дружина',
    'Чоловік',
    'Мати',
    'Батько',
    'Дитина',
    'Лікар',
    'Друг',
    'Інше',
  ];
}
