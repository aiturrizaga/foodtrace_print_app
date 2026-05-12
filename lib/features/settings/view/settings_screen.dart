import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/print_settings_card.dart';
import '../widgets/printer_settings_card.dart';
import '../widgets/server_settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          PrinterSettingsCard(),
          Gap(18),
          PrintSettingsCard(),
          Gap(18),
          ServerSettingsCard(),
        ],
      ),
    );
  }
}
