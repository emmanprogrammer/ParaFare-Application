import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../mvp_controller.dart';

class LaunchGateScreen extends ConsumerStatefulWidget {
  const LaunchGateScreen({super.key});

  @override
  ConsumerState<LaunchGateScreen> createState() => _LaunchGateScreenState();
}

class _LaunchGateScreenState extends ConsumerState<LaunchGateScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mvpControllerProvider);

    if (!_navigated && !state.loading) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (state.data.onboardingComplete) {
          context.go('/mvp/driver');
        } else {
          context.go('/onboarding/welcome');
        }
      });
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
