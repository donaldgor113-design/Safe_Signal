import 'package:flutter/material.dart';

class SosFlowScreen extends StatelessWidget {
  const SosFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '3',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.redAccent,
                      fontSize: 96,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'Починаємо запис...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 64),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Скасувати',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
