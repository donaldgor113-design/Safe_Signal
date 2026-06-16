import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/core/constants/app_constants.dart';
import 'package:safe_signal/features/medical_profile/presentation/providers/medical_profile_provider.dart';
import 'package:safe_signal/features/contacts/presentation/providers/contacts_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ssColors = theme.extension<SafeSignalColors>()!;
    final profileAsync = ref.watch(medicalProfileStreamProvider);
    final contactsAsync = ref.watch(contactsStreamProvider);

    final profileIncomplete = profileAsync.whenOrNull(
          data: (p) => p.diagnoses.isEmpty,
        ) ??
        true;
    final noContacts = contactsAsync.whenOrNull(
          data: (c) => c.isEmpty,
        ) ??
        true;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusBar(
            ssColors: ssColors,
            profileComplete: !profileIncomplete,
          ),
          if (profileIncomplete || noContacts)
            _CompletenessBanner(
              profileIncomplete: profileIncomplete,
              noContacts: noContacts,
            ),
          Expanded(
            child: Center(
              child: _SosButton(ssColors: ssColors, disabled: noContacts),
            ),
          ),
          _ScenarioSwitcher(theme: theme),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _CompletenessBanner extends StatelessWidget {
  final bool profileIncomplete;
  final bool noContacts;
  const _CompletenessBanner({
    required this.profileIncomplete,
    required this.noContacts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ssColors = theme.extension<SafeSignalColors>()!;
    final messages = <String>[];
    if (profileIncomplete) messages.add('медпрофіль');
    if (noContacts) messages.add('контакти');

    return GestureDetector(
      onTap: () {
        if (profileIncomplete) {
          context.go('/profile');
        } else {
          context.go('/contacts');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            ssColors.statusWarning.withAlpha(30),
            theme.colorScheme.surface,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ssColors.statusWarning.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: ssColors.statusWarning, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Заповніть ${messages.join(" та ")} для оповіщення',
                style: theme.textTheme.bodySmall,
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final SafeSignalColors ssColors;
  final bool profileComplete;

  const _StatusBar({
    required this.ssColors,
    required this.profileComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusIcon(
            icon: Icons.location_on,
            label: 'GPS',
            color: ssColors.statusActive,
          ),
          _StatusIcon(
            icon: Icons.wifi,
            label: 'Онлайн',
            color: ssColors.statusActive,
          ),
          _StatusIcon(
            icon: Icons.medical_information,
            label: profileComplete ? 'Профіль' : 'Неповний',
            color: profileComplete
                ? ssColors.statusActive
                : ssColors.statusWarning,
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _SosButton extends StatefulWidget {
  final SafeSignalColors ssColors;
  final bool disabled;

  const _SosButton({required this.ssColors, this.disabled = false});

  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _holdController;
  late final Animation<double> _holdProgress;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.sosHoldDurationMs),
    );
    _holdProgress = Tween<double>(begin: 0.0, end: 1.0).animate(_holdController);
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isHolding) {
        _isHolding = false;
        context.push('/sos-direct');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _onPanDown() {
    if (widget.disabled) return;
    setState(() => _isHolding = true);
    _holdController.forward(from: 0);
  }

  void _onPanUp() {
    if (!_isHolding) return;
    setState(() => _isHolding = false);
    _holdController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled;
    final buttonColor = isDisabled
        ? widget.ssColors.statusInactive
        : widget.ssColors.sosRed;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isDisabled)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.ssColors.sosGlow.withAlpha(
                        (76 * (1.3 - _pulseAnimation.value) / 0.3).round(),
                      ),
                    ),
                  ),
                );
              },
            ),
          GestureDetector(
            onTapDown: (_) => _onPanDown(),
            onTapUp: (_) => _onPanUp(),
            onTapCancel: _onPanUp,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonColor,
                    boxShadow: isDisabled
                        ? null
                        : [
                            BoxShadow(
                              color: widget.ssColors.sosGlow,
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SOS',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDisabled ? 'Додай контакт' : 'Утримуй 2 сек',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withAlpha(179),
                                ),
                      ),
                    ],
                  ),
                ),
                if (!isDisabled)
                  AnimatedBuilder(
                    animation: _holdProgress,
                    builder: (context, _) {
                      if (_holdProgress.value == 0) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: _holdProgress.value,
                          strokeWidth: 4,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioSwitcher extends StatelessWidget {
  final ThemeData theme;

  const _ScenarioSwitcher({required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: show scenario bottom sheet
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Активний: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withAlpha(153),
              ),
            ),
            Text(
              'Основний',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
