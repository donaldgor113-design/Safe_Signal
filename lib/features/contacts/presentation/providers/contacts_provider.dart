import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_signal/features/contacts/data/models/contact_model.dart';
import 'package:safe_signal/features/contacts/data/repositories/contacts_repository.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository();
});

final contactsStreamProvider = StreamProvider<List<ContactModel>>((ref) {
  return ref.watch(contactsRepositoryProvider).watchContacts();
});

final contactProvider =
    FutureProvider.family<ContactModel?, String>((ref, contactId) async {
  return ref.watch(contactsRepositoryProvider).getContact(contactId);
});
