import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose your mode to continue.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/passenger'),
                child: const Text(AppStrings.passengerMode),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/driver'),
                child: const Text(AppStrings.driverMode),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.go('/trip'),
                icon: const Icon(Icons.alt_route),
                label: const Text('Trip Simulation (Node-Based)'),
              ),

              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.go('/trip/live'),
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Live Trip Mode (GPS)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
