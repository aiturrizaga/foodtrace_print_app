import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../widgets/api_status_card.dart';
import '../widgets/printer_status_card.dart';
import '../widgets/test_print_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        toolbarHeight: 64,
        title: const Text(
          'FoodTrace Printer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey, size: 26),
            onPressed: () => context.push('/settings'),
          ),
          const Gap(8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          PrinterStatusCard(),
          Gap(18),
          ApiStatusCard(),
          Gap(18),
          TestPrintCard(),
        ],
      ),
    );
  }
}
