import 'package:flutter/material.dart';

class AddContactScreen extends StatelessWidget {
  final String? contactId;

  const AddContactScreen({super.key, this.contactId});

  @override
  Widget build(BuildContext context) {
    final isEditing = contactId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати контакт' : 'Додати контакт'),
      ),
      body: Center(
        child: Text(
          isEditing ? 'Редагування: $contactId' : 'Новий контакт — Тиждень 3',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
