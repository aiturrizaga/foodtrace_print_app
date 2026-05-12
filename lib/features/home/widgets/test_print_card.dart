import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../app/providers.dart';
import '../../../core/errors/failures.dart';
import '../../../printer/labels/registry.dart';
import '../../../printer/models/print_data.dart';

class TestPrintCard extends ConsumerStatefulWidget {
  const TestPrintCard({super.key});

  @override
  ConsumerState<TestPrintCard> createState() => _TestPrintCardState();
}

class _TestPrintCardState extends ConsumerState<TestPrintCard> {
  late String _selectedTemplate;
  int _copies = 1;
  bool _isPrinting = false;
  Uint8List? _previewBytes;

  static const _sampleData = {
    'empresa': 'EMPRESA ALIMENTOS S.A.C.',
    'lote': 'LOT-2026-0000000007',
    'produccion': '22/04/2026',
    'produccion_iso': '2026-04-22',
    'producto': 'Pure de camote - Bolsa x5 porciones',
    'producto_nombre': 'Pure de camote',
    'producto_presentacion': 'Bolsa x5 porciones',
    'cantidad': '5',
    'peso': '5',
    'operador': 'Demo Pruebas Sistemas',
  };

  @override
  void initState() {
    super.initState();
    _selectedTemplate = TemplateRegistry.all.first.name;
    _generatePreview();
  }

  Future<void> _generatePreview() async {
    final template = TemplateRegistry.get(_selectedTemplate);
    if (template == null) return;

    final bytes = await template.build(_sampleData);
    if (mounted) {
      setState(() => _previewBytes = bytes);
    }
  }

  void _onTemplateSelected(String name) {
    if (name == _selectedTemplate) return;
    setState(() {
      _selectedTemplate = name;
      _previewBytes = null;
    });
    _generatePreview();
  }

  Future<void> _print() async {
    setState(() => _isPrinting = true);
    try {
      final job = PrintData(
        templateName: _selectedTemplate,
        data: _sampleData,
        copies: _copies,
      );

      await ref.read(serverLifecycleProvider.notifier).printLabel(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print job sent successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e is PrinterFailure ? e.message : e.toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $message')));
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = TemplateRegistry.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEST PRINT',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 1.2,
          ),
        ),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: templates.map((t) {
                    final selected = t.name == _selectedTemplate;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(t.displayName),
                        selected: selected,
                        onSelected: (_) => _onTemplateSelected(t.name),
                        selectedColor: const Color(0xFF185FA5),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.grey.shade700,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFF185FA5)
                              : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Gap(20),

              // Real label preview
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: _previewBytes == null
                      ? const SizedBox(
                          width: 220,
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Image.memory(
                          _previewBytes!,
                          width: 220,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const Gap(20),

              // Copies row
              Divider(height: 1, color: Colors.grey.shade100),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Copies',
                    style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
                  ),
                  Row(
                    children: [
                      _CopiesButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_copies > 1) setState(() => _copies--);
                        },
                      ),
                      const Gap(16),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '$_copies',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Gap(16),
                      _CopiesButton(
                        icon: Icons.add,
                        onTap: () {
                          if (_copies < 10) setState(() => _copies++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(18),

              // Print button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isPrinting ? null : _print,
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print, size: 20),
                  label: Text(
                    _isPrinting ? 'Printing...' : 'Print test',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CopiesButton extends StatelessWidget {
  const _CopiesButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: const Color(0xFF333333)),
        ),
      ),
    );
  }
}
