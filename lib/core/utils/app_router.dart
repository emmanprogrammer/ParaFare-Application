import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/driver/driver_home_screen.dart';
import '../../features/mode/mode_selection_screen.dart';
import '../../features/passenger/passenger_home_screen.dart';
import '../../features/dispatch/trip_screen.dart';
import '../../features/dispatch/live_trip_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/mode',
    routes: [
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
