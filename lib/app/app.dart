import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(printerConfigProvider, (_, next) {
      next.whenData((config) {
        if (config.autoStartServer && !config.alwaysOnMode) {
          ref.read(serverLifecycleProvider.notifier).start(config.serverPort);
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
        ),
      ),
    );
  }
}
