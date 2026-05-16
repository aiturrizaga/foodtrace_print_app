import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-start the server when the app opens, after the battery permission
    // has been granted. This handles two cases:
    //   1. Always-on mode is the user's preference but the foreground service
    //      was killed by the OS (typical on Honor/Huawei MagicOS after reboot).
    //   2. Regular auto-start: the user wants the server to start with the app.
    ref.listen(printerConfigProvider, (_, next) {
      next.whenData((config) async {
        // Wait for the battery permission status to be available — auto-starting
        // before the permission is granted is pointless.
        final isPermissionGranted =
            ref.read(batteryOptimizationStatusProvider).valueOrNull ?? false;
        if (!isPermissionGranted) return;

        // Case 1: Always-on mode is preferred but the foreground service died.
        if (config.alwaysOnMode) {
          final foregroundService = ref.read(foregroundServiceProvider);
          final isRunning = await foregroundService.isRunning();
          if (!isRunning) {
            await ref.read(alwaysOnModeProvider.notifier).enable();
          }
          return;
        }

        // Case 2: Auto-start the regular (non-foreground) server.
        if (config.autoStartServer) {
          final notifier = ref.read(serverLifecycleProvider.notifier);
          if (!notifier.isRunning) {
            await notifier.start(config.serverPort);
          }
        }
      });
    });

    // Also listen for battery permission becoming granted — auto-start the
    // server right after the user accepts the permission for the first time.
    ref.listen(batteryOptimizationStatusProvider, (_, next) {
      next.whenData((isGranted) async {
        if (!isGranted) return;
        final config = ref.read(printerConfigProvider).valueOrNull;
        if (config == null) return;

        if (config.alwaysOnMode) {
          final foregroundService = ref.read(foregroundServiceProvider);
          final isRunning = await foregroundService.isRunning();
          if (!isRunning) {
            await ref.read(alwaysOnModeProvider.notifier).enable();
          }
          return;
        }

        if (config.autoStartServer) {
          final notifier = ref.read(serverLifecycleProvider.notifier);
          if (!notifier.isRunning) {
            await notifier.start(config.serverPort);
          }
        }
      });
    });

    return WithForegroundTask(
      child: MaterialApp.router(
        title: 'FoodTrace Printer',
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(appRouterProvider),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF185FA5),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
      ),
    );
  }
}
