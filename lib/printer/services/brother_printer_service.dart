import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:another_brother/printer_info.dart' as brother;
import 'package:another_brother/label_info.dart';

import '../../config/models/printer_config.dart';
import '../../core/errors/failures.dart';
import '../models/print_data.dart';
import '../labels/registry.dart';

/// Service responsible for rendering label templates and sending
/// print jobs to a Brother QL printer over the network.
class BrotherPrinterService {
  const BrotherPrinterService();

  /// Prints [print] using the given [config].
  ///
  /// Throws [TemplateFailure] if the template is not registered.
  /// Throws [PrinterFailure] if the printer rejects the job.
  Future<void> print(PrintData print, PrinterConfig config) async {
    final template = TemplateRegistry.get(print.templateName);
    if (template == null) {
      throw TemplateFailure(
        'Template "${print.templateName}" is not registered.',
      );
    }

    try {
      final imageBytes = await template.build(print.data);
      final uiImage = await _bytesToUiImage(imageBytes);

      final printer = brother.Printer();
      final printInfo = brother.PrinterInfo();

      printInfo.printerModel = _resolveModel(config.printerModel);
      printInfo.port = brother.Port.NET;
      printInfo.ipAddress = config.printerIp;
      printInfo.labelNameIndex = QL700.ordinalFromID(QL700.W62RB.getId());
      printInfo.isAutoCut = config.autoCut;
      printInfo.isCutAtEnd = config.autoCut;
      printInfo.numberOfCopies = print.copies;
      printInfo.printMode = brother.PrintMode.FIT_TO_PAGE;
      printInfo.align = brother.Align.CENTER;

      await printer.setPrinterInfo(printInfo);
      final status = await printer.printImage(uiImage);

      if (status.errorCode != brother.ErrorCode.ERROR_NONE) {
        throw PrinterFailure('Printer error: ${status.errorCode.getName()}');
      }
    } catch (e) {
      if (e is TemplateFailure || e is PrinterFailure) rethrow;
      throw PrinterFailure('Failed to print: $e');
    }
  }

  /// Checks whether the printer is reachable and ready.
  Future<bool> isReachable(PrinterConfig config) async {
    try {
      final printer = brother.Printer();
      final printInfo = brother.PrinterInfo();

      printInfo.printerModel = _resolveModel(config.printerModel);
      printInfo.port = brother.Port.NET;
      printInfo.ipAddress = config.printerIp;

      await printer.setPrinterInfo(printInfo);
      final status = await printer.getPrinterStatus();
      return status.errorCode == brother.ErrorCode.ERROR_NONE;
    } catch (_) {
      return false;
    }
  }

  /// Converts PNG bytes to a [ui.Image] required by the Brother SDK.
  Future<ui.Image> _bytesToUiImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  brother.Model _resolveModel(String modelName) {
    return switch (modelName) {
      'QL-810W' => brother.Model.QL_810W,
      'QL-820NWB' => brother.Model.QL_820NWB,
      'QL-800' => brother.Model.QL_800,
      _ => brother.Model.QL_810W,
    };
  }
}
