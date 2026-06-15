import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_signal/features/contacts/domain/entities/contact_entity.dart';

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String? telegramChatId;
  final String? email;
  final String relationship;
  final List<NotifyChannel> notifyChannels;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.telegramChatId,
    this.email,
    required this.relationship,
    required this.notifyChannels,
  });

  factory ContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ContactModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      telegramChatId: data['telegramChatId'] as String?,
      email: data['email'] as String?,
      relationship: data['relationship'] as String? ?? 'Інше',
      notifyChannels: (data['notifyChannels'] as List<dynamic>?)
              ?.map((e) => NotifyChannel.values.firstWhere(
                    (v) => v.name == e,
                    orElse: () => NotifyChannel.sms,
                  ))
              .toList() ??
          [NotifyChannel.sms],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'telegramChatId': telegramChatId,
        'email': email,
        'relationship': relationship,
        'notifyChannels': notifyChannels.map((c) => c.name).toList(),
      };

  ContactEntity toEntity() => ContactEntity(
        id: id,
        name: name,
        phone: phone,
        telegramChatId: telegramChatId,
        email: email,
        relationship: relationship,
        notifyChannels: notifyChannels,
      );

  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      telegramChatId: entity.telegramChatId,
      email: entity.email,
      relationship: entity.relationship,
      notifyChannels: entity.notifyChannels,
    );
  }
}
