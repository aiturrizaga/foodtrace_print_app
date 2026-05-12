import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../app/providers.dart';

class BatteryPermissionScreen extends ConsumerStatefulWidget {
  const BatteryPermissionScreen({super.key});

  @override
  ConsumerState<BatteryPermissionScreen> createState() =>
      _BatteryPermissionScreenState();
}

class _BatteryPermissionScreenState
    extends ConsumerState<BatteryPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _request() async {
    setState(() => _isRequesting = true);
    try {
      await ref.read(batteryOptimizationServiceProvider).requestExemption();
      ref.invalidate(batteryOptimizationStatusProvider);
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.battery_charging_full,
                  size: 32,
                  color: Color(0xFFB45309),
                ),
              ),
              const Gap(24),
              const Text(
                'Permission required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const Gap(12),
              Text(
                'To allow the print server to send jobs to the printer at any '
                'time, the app needs to be excluded from battery optimization.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const Gap(24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF185FA5),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'Without this permission Android may block network '
                        'connections to the printer when the app runs in the '
                        'background.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isRequesting ? null : _request,
                  icon: _isRequesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(
                    _isRequesting ? 'Requesting...' : 'Grant permission',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
