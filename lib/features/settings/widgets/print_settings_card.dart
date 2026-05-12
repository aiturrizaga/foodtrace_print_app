import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

import 'settings_widgets.dart';

class PrintSettingsCard extends ConsumerWidget {
  const PrintSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(printerConfigProvider).valueOrNull;
    if (config == null) return const SizedBox.shrink();

    return SettingsCard(
      label: 'PRINT',
      children: [
        ToggleRow(
          label: 'Auto cut',
          value: config.autoCut,
          onChanged: (value) async {
            await ref
                .read(printerConfigProvider.notifier)
                .save(config.copyWith(autoCut: value));
          },
        ),
      ],
    );
  }
}
