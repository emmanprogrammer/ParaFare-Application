import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to ParaFare')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Text(
              'Driver-first tricycle dispatch and fare app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Set up your profile once, then manage passenger rides from your dashboard.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/onboarding/role'),
              child: const Text('Start Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
