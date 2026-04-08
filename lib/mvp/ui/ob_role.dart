import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingRoleScreen extends StatelessWidget {
  const OnboardingRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Current MVP is driver-first. Choose Driver to continue.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/onboarding/driver-registration'),
              child: const Text('Driver'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passenger self-serve onboarding will follow in next phase.')),
                );
              },
              child: const Text('Passenger (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
