import 'package:flutter/material.dart';

/// Convenience extensions on BuildContext
extension ContextExtensions on BuildContext {
  /// Access current theme
  ThemeData get theme => Theme.of(this);

  /// Access current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Bottom padding (safe area)
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Top padding (status bar)
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a styled snack bar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : null,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
  }
}
