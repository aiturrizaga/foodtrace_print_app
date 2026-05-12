import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/models/printer_config.dart';
import '../config/repositories/config_repository.dart';
import '../config/repositories/config_repository_impl.dart';
import '../core/errors/failures.dart';
import '../core/services/battery_optimization_service.dart';
import '../core/services/foreground_service.dart';
import '../printer/models/print_data.dart';
import '../printer/services/brother_printer_service.dart';
import '../server/lifecycle.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Must be overridden in main.dart'),
);

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ConfigRepositoryImpl(prefs);
});

final batteryOptimizationServiceProvider = Provider<BatteryOptimizationService>(
  (_) => const BatteryOptimizationService(),
);

final batteryOptimizationStatusProvider = FutureProvider<bool>((ref) async {
  return ref.read(batteryOptimizationServiceProvider).isExempted();
});

final brotherPrinterServiceProvider = Provider<BrotherPrinterService>(
  (_) => const BrotherPrinterService(),
);

final foregroundServiceProvider = Provider<ForegroundServerService>(
  (_) => const ForegroundServerService(),
);

final printerConfigProvider =
    AsyncNotifierProvider<PrinterConfigNotifier, PrinterConfig>(
      PrinterConfigNotifier.new,
    );

class PrinterConfigNotifier extends AsyncNotifier<PrinterConfig> {
  @override
  Future<PrinterConfig> build() async {
    return ref.read(configRepositoryProvider).load();
  }

  Future<void> save(PrinterConfig config) async {
    await ref.read(configRepositoryProvider).save(config);
    state = AsyncData(config);
  }
}

final printerStatusProvider =
    AsyncNotifierProvider<PrinterStatusNotifier, bool>(
      PrinterStatusNotifier.new,
    );

class PrinterStatusNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return _check();
  }

  Future<bool> _check() async {
    final config = await ref.read(printerConfigProvider.future);
    if (config.printerIp.isEmpty) return false;

    try {
      return await ref.read(brotherPrinterServiceProvider).isReachable(config);
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    if (state is AsyncLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_check);
  }
}

final serverLifecycleProvider = NotifierProvider<ServerLifecycleNotifier, bool>(
  ServerLifecycleNotifier.new,
);

class ServerLifecycleNotifier extends Notifier<bool> {
  late ServerLifecycle _lifecycle;

  @override
  bool build() {
    _lifecycle = ServerLifecycle(
      getConfig: () => ref.read(printerConfigProvider).valueOrNull,
      checkPrinterReachable: (config) =>
          ref.read(brotherPrinterServiceProvider).isReachable(config),
      executePrint: printLabel,
    );
    return false;
  }

  /// Executes a print job using the current configuration.
  /// This is the single entry point for all print operations.
  Future<void> printLabel(PrintData print) async {
    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config == null) throw PrinterFailure('No printer config available.');
    await ref.read(brotherPrinterServiceProvider).print(print, config);
  }

  Future<void> start(int port) async {
    await _lifecycle.start(port);
    state = true;
  }

  Future<void> stop() async {
    await _lifecycle.stop();
    state = false;
  }

  Future<void> restart(int port) async {
    await _lifecycle.restart(port);
    state = true;
  }

  bool get isRunning => _lifecycle.isRunning;
}

final alwaysOnModeProvider = AsyncNotifierProvider<AlwaysOnModeNotifier, bool>(
  AlwaysOnModeNotifier.new,
);

class AlwaysOnModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(foregroundServiceProvider).isRunning();
  }

  Future<void> enable() async {
    final foregroundService = ref.read(foregroundServiceProvider);
    final lifecycle = ref.read(serverLifecycleProvider.notifier);

    if (lifecycle.isRunning) {
      await lifecycle.stop();
    }

    await foregroundService.start();

    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config != null) {
      await ref
          .read(printerConfigProvider.notifier)
          .save(config.copyWith(alwaysOnMode: true));
    }

    state = const AsyncData(true);
  }

  Future<void> disable() async {
    final foregroundService = ref.read(foregroundServiceProvider);
    await foregroundService.stop();

    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config != null) {
      await ref
          .read(printerConfigProvider.notifier)
          .save(config.copyWith(alwaysOnMode: false));
    }

    state = const AsyncData(false);
  }
}
