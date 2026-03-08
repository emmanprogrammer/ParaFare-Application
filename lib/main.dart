import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/firebase_service.dart';
import 'core/utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseResult = await FirebaseService.initializeSafely();

  runApp(
    ProviderScope(
      child: ParaFareApp(firebaseResult: firebaseResult),
    ),
  );
}

class ParaFareApp extends ConsumerWidget {
  const ParaFareApp({
    super.key,
    required this.firebaseResult,
  });

  final FirebaseInitResult firebaseResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ParaFare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) {
        final body = child ?? const SizedBox.shrink();
        if (firebaseResult.isReady) {
          return body;
        }

        return Stack(
          children: [
            body,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    firebaseResult.errorMessage ??
                        'Firebase is not configured. Core UI is still available for local testing.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
