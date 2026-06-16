import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safe_signal/core/constants/app_constants.dart';
import 'package:safe_signal/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final user = ref.read(authStateProvider).valueOrNull;
    final settings = Hive.box('app_settings');
    final onboardingCompleted =
        settings.get('onboarding_completed', defaultValue: false) as bool;

    if (!mounted) return;

    if (user == null) {
      if (!onboardingCompleted) {
        context.go('/onboarding');
      } else {
        context.go('/auth/login');
      }
    } else {
      final disclaimerAccepted =
          settings.get('disclaimer_accepted', defaultValue: false) as bool;
      if (!disclaimerAccepted && mounted) {
        await _showDisclaimerDialog();
      }
      if (mounted) context.go('/home');
    }
  }

  Future<void> _showDisclaimerDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Важливо'),
        content: const SingleChildScrollView(
          child: Text(
            'SafeSignal — це допоміжний інструмент для екстрених ситуацій. '
            'Додаток не замінює виклик служб екстреної допомоги (112, 103). '
            'Доставка повідомлень залежить від наявності інтернет-з\'єднання '
            'та працездатності сторонніх сервісів (SMS, Telegram).\n\n'
            'Розробник не несе відповідальності за затримки або невдалу '
            'доставку повідомлень. Завжди тримайте телефон зарядженим '
            'та перевіряйте налаштування контактів перед подорожами.\n\n'
            'Використовуючи додаток, ви погоджуєтесь з цими умовами.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              final settings = Hive.box('app_settings');
              await settings.put('disclaimer_accepted', true);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Приймаю'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield,
              size: 96,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
