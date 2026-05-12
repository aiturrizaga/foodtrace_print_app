import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/responsive.dart';
import '../widgets/api_status_card.dart';
import '../widgets/printer_status_card.dart';
import '../widgets/test_print_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isTablet = Responsive.isTablet(context);

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
      body: isTablet
          ? _TabletLayout(bottomInset: bottomInset)
          : _PhoneLayout(bottomInset: bottomInset),
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset + 16),
      children: const [
        PrinterStatusCard(),
        Gap(18),
        ApiStatusCard(),
        Gap(18),
        TestPrintCard(),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset + 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: const [PrinterStatusCard(), Gap(18), ApiStatusCard()],
            ),
          ),
          const Gap(18),
          const Expanded(child: TestPrintCard()),
        ],
      ),
    );
  }
}
