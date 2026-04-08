import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingDriverRegistrationScreen extends StatefulWidget {
  const OnboardingDriverRegistrationScreen({super.key});

  @override
  State<OnboardingDriverRegistrationScreen> createState() => _OnboardingDriverRegistrationScreenState();
}

class _OnboardingDriverRegistrationScreenState extends State<OnboardingDriverRegistrationScreen> {
  final _nameController = TextEditingController();
  final _tricycleIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _tricycleIdController.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _nameController.text.trim();
    final tricycleId = _tricycleIdController.text.trim();
    if (name.isEmpty || tricycleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in driver name and tricycle ID.')),
      );
      return;
    }

    context.go(
      '/onboarding/seats',
      extra: {
        'name': name,
        'tricycleId': tricycleId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Driver Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tricycleIdController,
              decoration: const InputDecoration(labelText: 'Tricycle ID / Plate'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _continue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
