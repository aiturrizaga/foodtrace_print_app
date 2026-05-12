import 'package:flutter/widgets.dart';

/// Breakpoints for responsive layouts following Material Design guidelines.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1200;

  /// Returns true if the current screen is tablet-sized or larger.
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Returns true if the current screen is desktop-sized.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
}
