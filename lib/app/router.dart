import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/view/home_screen.dart';
import '../features/onboarding/view/battery_permission_screen.dart';
import '../features/settings/view/settings_screen.dart';
import 'providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final batteryStatus = ref.watch(batteryOptimizationStatusProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isGranted = batteryStatus.valueOrNull ?? false;
      final onPermissionScreen = state.matchedLocation == '/permission';

      if (!isGranted && !onPermissionScreen) return '/permission';
      if (isGranted && onPermissionScreen) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/permission',
        builder: (context, state) => const BatteryPermissionScreen(),
      ),
    ],
  );
});
