import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

/// Dark, high-contrast, arcade-inspired color scheme for a retro pixel-game aesthetic.
final pixelColors = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: SystemUiOverlayStyle.light,
  barrier: const Color(0xCC000000),
  background: const Color(0xFF0D0D1A),
  foreground: const Color(0xFFE0FFE0),
  primary: const Color(0xFF00FF88),
  primaryForeground: const Color(0xFF0A0A0A),
  secondary: const Color(0xFF1A1A3E),
  secondaryForeground: const Color(0xFFE0E0FF),
  muted: const Color(0xFF1A1A2E),
  mutedForeground: const Color(0xFF666688),
  destructive: const Color(0xFFFF4444),
  destructiveForeground: Colors.white,
  error: const Color(0xFFFF4444),
  errorForeground: Colors.white,
  card: const Color(0xFF141428),
  border: const Color(0xFF2A2A4A),
);

/// Departure Mono pixel font typeface with touch-optimized sizes.
final _pixelTypeface = FTypeface.inherit(
  colors: pixelColors,
  touch: true,
  fontFamily: 'DepartureMono',
);

/// Typography using Departure Mono for both display and body text.
final pixelTypography = FTypography(
  display: _pixelTypeface,
  body: _pixelTypeface,
);

/// Sharp, minimal style with pixel-art corner radii and thin borders.
final pixelStyle =
    FStyle.inherit(
      colors: pixelColors,
      typography: pixelTypography,
      touch: true,
    ).copyWith(
      borderRadius: const FBorderRadius(
        xs2: BorderRadius.all(Radius.circular(1)),
        xs: BorderRadius.all(Radius.circular(1)),
        sm: BorderRadius.all(Radius.circular(2)),
        md: BorderRadius.all(Radius.circular(4)),
        lg: BorderRadius.all(Radius.circular(6)),
        xl: BorderRadius.all(Radius.circular(8)),
        xl2: BorderRadius.all(Radius.circular(10)),
        xl3: BorderRadius.all(Radius.circular(12)),
        pill: BorderRadius.all(Radius.circular(100)),
      ),
      borderWidth: 1,
    );

/// The complete dark pixel-game theme.
final pixelTheme = FThemeData(
  colors: pixelColors,
  typography: pixelTypography,
  style: pixelStyle,
  touch: true,
);
