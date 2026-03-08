import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parafare_application/mvp/ctrl.dart';

class FinalFareScreen extends ConsumerStatefulWidget {
  const FinalFareScreen({
    super.key,
    required this.slotIndex,
  });

  final int slotIndex;

  @override
  ConsumerState<FinalFareScreen> createState() => _FinalFareScreenState();
}

class _FinalFareScreenState extends ConsumerState<FinalFareScreen> {
  double adjustment = 0;

  Future<void> _confirm() async {
    await ref.read(mvpControllerProvider.notifier).finishRide(
          slotIndex: widget.slotIndex,
          manualAdjustment: adjustment,
        );
    if (!mounted) return;
    context.go('/mvp/driver');
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(mvpControllerProvider).data.activeRides[widget.slotIndex];
    if (ride == null) {
      return const Scaffold(body: Center(child: Text('Ride not found.')));
    }

    final preview = ref.read(mvpControllerProvider.notifier).calculatePreview(
          originLat: ride.originLat,
          originLng: ride.originLng,
          destinationLat: ride.destinationLat,
          destinationLng: ride.destinationLng,
        );
    final finalFare = (preview.suggestedFare + adjustment).clamp(10, 100).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Finalize Fare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Base Fare: PHP ${preview.baseFare.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            Text('Manual Adjustment: ${adjustment.toStringAsFixed(0)}'),
            Slider(
              value: adjustment,
              min: -20,
              max: 20,
              divisions: 40,
              label: adjustment.toStringAsFixed(0),
              onChanged: (value) => setState(() => adjustment = value),
            ),
            const SizedBox(height: 12),
            Text(
              'Final Fare: PHP ${finalFare.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Spacer(),
            FilledButton(onPressed: _confirm, child: const Text('Confirm & Save Ride')),
          ],
        ),
      ),
    );
  }
}
