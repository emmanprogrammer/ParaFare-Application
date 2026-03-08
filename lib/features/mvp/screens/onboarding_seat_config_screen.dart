import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/mvp_models.dart';
import '../mvp_controller.dart';

class OnboardingSeatConfigScreen extends ConsumerStatefulWidget {
  const OnboardingSeatConfigScreen({
    super.key,
    required this.name,
    required this.tricycleId,
  });

  final String name;
  final String tricycleId;

  @override
  ConsumerState<OnboardingSeatConfigScreen> createState() => _OnboardingSeatConfigScreenState();
}

class _OnboardingSeatConfigScreenState extends ConsumerState<OnboardingSeatConfigScreen> {
  int seats = 6;

  Future<void> _finishSetup() async {
    await ref.read(mvpControllerProvider.notifier).completeOnboarding(
          DriverProfile(
            name: widget.name,
            tricycleId: widget.tricycleId,
            seatCount: seats,
          ),
        );
    if (!mounted) return;
    context.go('/mvp/driver');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Seats')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Configure available passenger slots for ${widget.tricycleId}'),
            const SizedBox(height: 20),
            Text(
              '$seats seats',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Slider(
              min: 1,
              max: 12,
              divisions: 11,
              value: seats.toDouble(),
              onChanged: (value) => setState(() => seats = value.round()),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _finishSetup,
              child: const Text('Finish Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
