import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/contacts/data/models/contact_model.dart';
import 'package:safe_signal/features/contacts/domain/entities/contact_entity.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:safe_signal/features/contacts/presentation/providers/contacts_provider.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Контакти')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts/add'),
        child: const Icon(Icons.add),
      ),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Немає контактів',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Додайте екстрені контакти для оповіщення',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.push('/contacts/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Додати контакт'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _ContactCard(contact: contacts[index]);
            },
          );
        },
      ),
    );
  }
}

class _ContactCard extends ConsumerWidget {
  final ContactModel contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Видалити контакт?'),
            content: Text('${contact.name} буде видалено зі списку'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Скасувати'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Видалити'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(contactsRepositoryProvider).deleteContact(contact.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
          title: Text(contact.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.relationship),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (contact.notifyChannels.contains(NotifyChannel.sms))
                    _ChannelBadge(label: 'SMS', theme: theme),
                  if (contact.notifyChannels.contains(NotifyChannel.telegram))
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: _ChannelBadge(label: 'Telegram', theme: theme),
                    ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 20),
                tooltip: 'Тестове повідомлення',
                onPressed: () => _sendTestNotification(context, contact.id),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => context.push('/contacts/${contact.id}'),
        ),
      ),
    );
  }
}

Future<void> _sendTestNotification(BuildContext context, String contactId) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('Відправляю тестове повідомлення...')),
  );

  try {
    final callable = FirebaseFunctions.instance.httpsCallable('sendTestNotification');
    final result = await callable.call({'contactId': contactId});
    final data = result.data as Map<String, dynamic>;

    final sent = data.entries.where((e) => e.value == 'sent').map((e) => e.key);
    final failed = data.entries.where((e) => e.value == 'failed').map((e) => e.key);

    messenger.hideCurrentSnackBar();
    if (sent.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text('Надіслано: ${sent.join(", ")}')),
      );
    } else if (failed.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text('Помилка: ${failed.join(", ")}')),
      );
    }
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Помилка відправки')),
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _ChannelBadge({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
