import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/core/utils/validators.dart';
import 'package:safe_signal/features/contacts/data/models/contact_model.dart';
import 'package:safe_signal/features/contacts/domain/entities/contact_entity.dart';
import 'package:safe_signal/features/contacts/presentation/providers/contacts_provider.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  final String? contactId;

  const AddContactScreen({super.key, this.contactId});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _loaded = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _telegramChatIdController = TextEditingController();

  String _relationship = ContactEntity.relationshipOptions.first;
  bool _smsEnabled = true;
  bool _telegramEnabled = false;

  bool get _isEditing => widget.contactId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _telegramChatIdController.dispose();
    super.dispose();
  }

  void _populateFromContact(ContactModel contact) {
    if (_loaded) return;
    _loaded = true;
    _nameController.text = contact.name;
    _phoneController.text = contact.phone;
    _emailController.text = contact.email ?? '';
    _telegramChatIdController.text = contact.telegramChatId ?? '';
    _relationship = contact.relationship;
    _smsEnabled = contact.notifyChannels.contains(NotifyChannel.sms);
    _telegramEnabled = contact.notifyChannels.contains(NotifyChannel.telegram);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final channels = <NotifyChannel>[];
    if (_smsEnabled) channels.add(NotifyChannel.sms);
    if (_telegramEnabled) channels.add(NotifyChannel.telegram);

    if (channels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть хоча б один канал оповіщення')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final contact = ContactModel(
        id: widget.contactId ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        telegramChatId: _telegramChatIdController.text.trim().isEmpty
            ? null
            : _telegramChatIdController.text.trim(),
        relationship: _relationship,
        notifyChannels: channels,
      );

      final repo = ref.read(contactsRepositoryProvider);
      if (_isEditing) {
        await repo.updateContact(contact);
      } else {
        await repo.addContact(contact);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showTelegramInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Як отримати Telegram Chat ID'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Контакт відкриває бота SafeSignal в Telegram'),
            SizedBox(height: 8),
            Text('2. Натискає /start'),
            SizedBox(height: 8),
            Text('3. Бот відповідає повідомленням з Chat ID'),
            SizedBox(height: 8),
            Text('4. Контакт надсилає вам цей Chat ID'),
            SizedBox(height: 16),
            Text(
              'Chat ID — це число, наприклад: 123456789',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Зрозуміло'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати контакт' : 'Додати контакт'),
      ),
      body: _isEditing
          ? ref.watch(contactProvider(widget.contactId!)).when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Помилка: $e')),
                data: (contact) {
                  if (contact == null) {
                    return const Center(child: Text('Контакт не знайдено'));
                  }
                  _populateFromContact(contact);
                  return _buildForm(theme);
                },
              )
          : _buildForm(theme),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Ім'я *"),
            validator: (v) => Validators.required(v, "Ім'я"),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Номер телефону *',
              hintText: '+380501234567',
            ),
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _relationship,
            decoration: const InputDecoration(labelText: 'Відношення *'),
            items: ContactEntity.relationshipOptions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _relationship = v);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'contact@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v != null && v.trim().isNotEmpty) {
                return Validators.email(v);
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _telegramChatIdController,
                  decoration: const InputDecoration(
                    labelText: 'Telegram Chat ID',
                    hintText: '123456789',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: _showTelegramInstructions,
                icon: const Icon(Icons.help_outline),
                tooltip: 'Як отримати Chat ID',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Канали оповіщення *',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: _smsEnabled,
            onChanged: (v) => setState(() => _smsEnabled = v ?? false),
            title: const Text('SMS'),
            subtitle: const Text('Повідомлення через Twilio'),
            secondary: const Icon(Icons.sms_outlined),
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          CheckboxListTile(
            value: _telegramEnabled,
            onChanged: (v) => setState(() => _telegramEnabled = v ?? false),
            title: const Text('Telegram'),
            subtitle: const Text('Потрібен Chat ID контакту'),
            secondary: const Icon(Icons.send_outlined),
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => context.pop(),
                  child: const Text('Скасувати'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Зберегти'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
