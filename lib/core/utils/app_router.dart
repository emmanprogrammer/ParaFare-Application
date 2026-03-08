import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parafare_application/features/dispatch/live_trip_screen.dart';
import 'package:parafare_application/features/dispatch/trip_screen.dart';
import 'package:parafare_application/features/driver/driver_home_screen.dart';
import 'package:parafare_application/features/mode/mode_selection_screen.dart';
import 'package:parafare_application/features/mvp/screens/add_ride_screen.dart';
import 'package:parafare_application/features/mvp/screens/driver_dashboard_screen.dart';
import 'package:parafare_application/features/mvp/screens/earnings_history_screen.dart';
import 'package:parafare_application/features/mvp/screens/final_fare_screen.dart';
import 'package:parafare_application/features/mvp/screens/launch_gate_screen.dart';
import 'package:parafare_application/features/mvp/screens/onboarding_driver_registration_screen.dart';
import 'package:parafare_application/features/mvp/screens/onboarding_role_screen.dart';
import 'package:parafare_application/features/mvp/screens/onboarding_seat_config_screen.dart';
import 'package:parafare_application/features/mvp/screens/onboarding_welcome_screen.dart';
import 'package:parafare_application/features/mvp/screens/ride_manage_screen.dart';
import 'package:parafare_application/features/passenger/passenger_home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/launch',
    routes: [
      GoRoute(
        path: '/launch',
        builder: (context, state) => const LaunchGateScreen(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/role',
        builder: (context, state) => const OnboardingRoleScreen(),
      ),
      GoRoute(
        path: '/onboarding/driver-registration',
        builder: (context, state) => const OnboardingDriverRegistrationScreen(),
      ),
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
      GoRoute(
        path: '/mvp/driver',
        builder: (context, state) => const DriverDashboardScreen(),
      ),
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
      GoRoute(
        path: '/mvp/history',
        builder: (context, state) => const EarningsHistoryScreen(),
      ),

      // Existing routes retained for current/legacy scaffolding.
      GoRoute(
        path: '/mode',
        builder: (context, state) => const ModeSelectionScreen(),
      ),
      GoRoute(
        path: '/driver',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/passenger',
        builder: (context, state) => const PassengerHomeScreen(),
      ),
      GoRoute(
        path: '/trip',
        builder: (context, state) => const TripScreen(),
      ),
      GoRoute(
        path: '/trip/live',
        builder: (context, state) => const LiveTripScreen(),
      ),
    ],
  );
});
