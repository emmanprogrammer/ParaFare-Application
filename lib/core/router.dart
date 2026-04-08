import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parafare_application/mvp/ui/add_ride.dart';
import 'package:parafare_application/mvp/ui/dash.dart';
import 'package:parafare_application/mvp/ui/fare_final.dart';
import 'package:parafare_application/mvp/ui/gate.dart';
import 'package:parafare_application/mvp/ui/history.dart';
import 'package:parafare_application/mvp/ui/ob_driver.dart';
import 'package:parafare_application/mvp/ui/ob_role.dart';
import 'package:parafare_application/mvp/ui/ob_seats.dart';
import 'package:parafare_application/mvp/ui/ob_welcome.dart';
import 'package:parafare_application/mvp/ui/ride_manage.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/launch',
    routes: [
      GoRoute(path: '/launch', builder: (context, state) => const LaunchGateScreen()),
      GoRoute(path: '/onboarding/welcome', builder: (context, state) => const OnboardingWelcomeScreen()),
      GoRoute(path: '/onboarding/role', builder: (context, state) => const OnboardingRoleScreen()),
      GoRoute(path: '/onboarding/driver-registration', builder: (context, state) => const OnboardingDriverRegistrationScreen()),
      GoRoute(
        path: '/onboarding/seats',
        builder: (context, state) {
          final extra = Map<String, dynamic>.from(state.extra as Map? ?? {});
          return OnboardingSeatConfigScreen(
            name: (extra['name'] as String?) ?? '',
            tricycleId: (extra['tricycleId'] as String?) ?? '',
          );
        },
      ),
      GoRoute(path: '/mvp/driver', builder: (context, state) => const DriverDashboardScreen()),
      GoRoute(
        path: '/mvp/ride/new/:slot',
        builder: (context, state) => AddRideScreen(
          slotIndex: int.tryParse(state.pathParameters['slot'] ?? '') ?? 1,
        ),
      ),
      GoRoute(
        path: '/mvp/ride/manage/:slot',
        builder: (context, state) => RideManageScreen(
          slotIndex: int.tryParse(state.pathParameters['slot'] ?? '') ?? 1,
        ),
      ),
      GoRoute(
        path: '/mvp/ride/finalize/:slot',
        builder: (context, state) => FinalFareScreen(
          slotIndex: int.tryParse(state.pathParameters['slot'] ?? '') ?? 1,
        ),
      ),
      GoRoute(path: '/mvp/history', builder: (context, state) => const EarningsHistoryScreen()),
    ],
  );
});
