import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _shakeSosEnabled;
  late bool _immobilityEnabled;
  late bool _offgridEnabled;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('app_settings');
    _shakeSosEnabled = box.get('shake_sos_enabled', defaultValue: false);
    _immobilityEnabled = box.get('immobility_detection_enabled', defaultValue: false);
    _offgridEnabled = box.get('offgrid_enabled', defaultValue: false);
  }

  Future<void> _updateSetting(String key, bool value) async {
    final box = Hive.box('app_settings');
    await box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування')),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Профіль', theme: theme),
          ListTile(
            leading: const Icon(Icons.medical_information),
            title: const Text('Медичний профіль'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('QR Медична картка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/qr-card'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Контакти'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/contacts'),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_play),
            title: const Text('Сценарії'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/scenarios'),
          ),
          const Divider(),
          _SectionHeader(title: 'SOS', theme: theme),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Shake-to-SOS'),
            subtitle: const Text('Трясти телефон для SOS'),
            value: _shakeSosEnabled,
            onChanged: (v) {
              setState(() => _shakeSosEnabled = v);
              _updateSetting('shake_sos_enabled', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.accessibility_new),
            title: const Text('Нерухомість'),
            subtitle: const Text('SOS якщо немає руху 60 сек'),
            value: _immobilityEnabled,
            onChanged: (v) {
              setState(() => _immobilityEnabled = v);
              _updateSetting('immobility_detection_enabled', v);
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Off-Grid', theme: theme),
          SwitchListTile(
            secondary: const Icon(Icons.satellite_alt),
            title: const Text('Off-Grid режим'),
            subtitle: const Text('GPS логування кожні 5 хв'),
            value: _offgridEnabled,
            onChanged: (v) {
              setState(() => _offgridEnabled = v);
              _updateSetting('offgrid_enabled', v);
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Акаунт', theme: theme),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Історія тривог'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/history'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Вийти',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Вийти з акаунту?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Скасувати'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Вийти'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(authRepositoryProvider).signOut();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              'SafeSignal v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
