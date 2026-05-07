import 'package:flutter/material.dart';

final _textColorCache = <int, Color>{};

extension ColorUtils on Color {
  /// Softens the color for light mode by increasing lightness.
  /// Returns the original color in dark mode.
  Color themeDependentColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return this;
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 0.95)).toColor();
  }

  /// Calculates the appropriate text color (black or white) based on the background color's luminance.
  /// Uses a cache to avoid redundant calculations.
  Color get contrastColor {
    return _textColorCache.putIfAbsent(toARGB32(), () {
      return computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    });
  }
}
