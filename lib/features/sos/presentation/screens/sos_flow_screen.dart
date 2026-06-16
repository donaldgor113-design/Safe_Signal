import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_signal/app/theme.dart';
import 'package:safe_signal/core/services/sos_service.dart';
import 'package:safe_signal/features/sos/presentation/providers/sos_provider.dart';

class SosFlowScreen extends ConsumerStatefulWidget {
  const SosFlowScreen({super.key});

  @override
  ConsumerState<SosFlowScreen> createState() => _SosFlowScreenState();
}

class _SosFlowScreenState extends ConsumerState<SosFlowScreen>
    with TickerProviderStateMixin {
  late final SosService _sosService;
  StreamSubscription<SosProgress>? _subscription;
  SosProgress _progress = const SosProgress(phase: SosPhase.countdown);
  late AnimationController _countdownAnimController;
  late Animation<double> _countdownScaleAnim;

  @override
  void initState() {
    super.initState();
    _countdownAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _countdownScaleAnim = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _countdownAnimController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscription == null) {
      _sosService = ref.read(sosServiceProvider);
      _subscription = _sosService.progressStream.listen((progress) {
        if (!mounted) return;
        final oldCountdown = _progress.countdownValue;
        setState(() => _progress = progress);
        if (progress.phase == SosPhase.countdown &&
            progress.countdownValue != oldCountdown) {
          _countdownAnimController.forward(from: 0);
        }
      });
      _sosService.startSosFlow();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _countdownAnimController.dispose();
    super.dispose();
  }

  void _cancel() {
    _sosService.cancel();
    Navigator.of(context).pop();
  }

  void _stopEarly() {
    _sosService.stopRecordingEarly();
  }

  void _sendWithoutVideo() {
    _sosService.sendWithoutVideo();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop &&
            (_progress.phase == SosPhase.countdown ||
                _progress.phase == SosPhase.recording)) {
          _cancel();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withAlpha(217),
        body: SafeArea(
          child: switch (_progress.phase) {
            SosPhase.countdown => _CountdownView(
                value: _progress.countdownValue,
                scaleAnimation: _countdownScaleAnim,
                onCancel: _cancel,
              ),
            SosPhase.recording => _RecordingView(
                secondsLeft: _progress.recordingSecondsLeft,
                cameraController: ref.read(videoServiceProvider).controller,
                gpsObtained: _progress.gpsObtained,
                onStopEarly: _stopEarly,
                onSendWithoutVideo: _sendWithoutVideo,
                onCancel: _cancel,
              ),
            SosPhase.sending => _SendingView(
                gpsObtained: _progress.gpsObtained,
                videoUploaded: _progress.videoUploaded,
                alertSaved: _progress.alertSaved,
              ),
            SosPhase.done => _DoneView(
                offlineQueued: _progress.offlineQueued,
                onClose: () => Navigator.of(context).pop(),
              ),
            SosPhase.cancelled => const SizedBox.shrink(),
            SosPhase.error => _ErrorView(
                message: _progress.errorMessage ?? 'Невідома помилка',
                onClose: () => Navigator.of(context).pop(),
              ),
          },
        ),
      ),
    );
  }
}

class _CountdownView extends StatelessWidget {
  final int value;
  final Animation<double> scaleAnimation;
  final VoidCallback onCancel;

  const _CountdownView({
    required this.value,
    required this.scaleAnimation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final ssColors = Theme.of(context).extension<SafeSignalColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.bold,
                    color: ssColors.sosRed,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Починаємо запис повідомлення',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: 200,
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: onCancel,
              child: const Text(
                'СКАСУВАТИ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingView extends StatelessWidget {
  final int secondsLeft;
  final CameraController? cameraController;
  final bool gpsObtained;
  final VoidCallback onStopEarly;
  final VoidCallback onSendWithoutVideo;
  final VoidCallback onCancel;

  const _RecordingView({
    required this.secondsLeft,
    required this.cameraController,
    required this.gpsObtained,
    required this.onStopEarly,
    required this.onSendWithoutVideo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final ssColors = Theme.of(context).extension<SafeSignalColors>()!;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (cameraController != null &&
                  cameraController!.value.isInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: CameraPreview(cameraController!),
                  ),
                )
              else
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_off, size: 64, color: Colors.white38),
                      SizedBox(height: 8),
                      Text(
                        'Камера недоступна',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              Positioned(
                top: AppSpacing.xl,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BlinkingDot(color: ssColors.sosRed),
                    const SizedBox(width: 8),
                    const Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      _formatTime(secondsLeft),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: AppSpacing.xl,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (gpsObtained)
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.greenAccent, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'GPS',
                              style: TextStyle(
                                  color: Colors.greenAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ssColors.sosRed,
                  ),
                  onPressed: onStopEarly,
                  child: const Text(
                    'Зупинити і надіслати',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: onSendWithoutVideo,
                  child: const Text(
                    'Надіслати без відео',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _BlinkingDot extends StatefulWidget {
  final Color color;
  const _BlinkingDot({required this.color});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withAlpha(
              (76 + 179 * _controller.value).round(),
            ),
          ),
        );
      },
    );
  }
}

class _SendingView extends StatelessWidget {
  final bool gpsObtained;
  final bool videoUploaded;
  final bool alertSaved;

  const _SendingView({
    required this.gpsObtained,
    required this.videoUploaded,
    required this.alertSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 32),
            const Text(
              'Надсилаю SOS...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            _ProgressStep(
              label: 'GPS отримано',
              isDone: gpsObtained,
            ),
            const SizedBox(height: 12),
            _ProgressStep(
              label: 'Відео завантажено',
              isDone: videoUploaded,
            ),
            const SizedBox(height: 12),
            _ProgressStep(
              label: 'Оповіщення збережено',
              isDone: alertSaved,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool isDone;

  const _ProgressStep({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isDone
              ? const Icon(Icons.check_circle,
                  key: ValueKey('done'), color: Colors.greenAccent, size: 24)
              : const SizedBox(
                  key: ValueKey('pending'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white38,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDone ? Colors.greenAccent : Colors.white54,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _DoneView extends StatelessWidget {
  final bool offlineQueued;
  final VoidCallback onClose;

  const _DoneView({
    required this.offlineQueued,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (offlineQueued) ...[
              const Icon(Icons.wifi_off, color: Colors.orangeAccent, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Немає мережі',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Повідомлення надішлеться автоматично\nпри появі зв\'язку',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ] else ...[
              const Icon(Icons.check_circle_outline,
                  color: Colors.greenAccent, size: 80),
              const SizedBox(height: 24),
              const Text(
                'SOS надіслано!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Контакти отримають повідомлення',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
                onPressed: onClose,
                child: const Text(
                  'Закрити',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ErrorView({
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
                onPressed: onClose,
                child: const Text(
                  'Закрити',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
