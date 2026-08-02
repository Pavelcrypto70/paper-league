import 'package:flutter/material.dart';

/// Terminal ink — institutional dark, cool accent, zero neon spam.
abstract final class PlColors {
  static const bg = Color(0xFF03050A);
  static const bgElevated = Color(0xFF070B12);
  static const surface = Color(0xFF0C121C);
  static const surface2 = Color(0xFF121A27);
  static const surface3 = Color(0xFF182233);
  static const line = Color(0xFF2B364A);
  static const lineSoft = Color(0xFF1A2332);

  static const text = Color(0xFFF4F7FB);
  static const muted = Color(0xFF95A3B8);
  static const faint = Color(0xFF5E6D84);

  static const accent = Color(0xFF5AE2FF);
  static const accentSoft = Color(0xFF123845);
  static const accentDim = Color(0xFF0B2430);

  static const bull = Color(0xFF2AD49A);
  static const bullSoft = Color(0xFF0F2F26);
  static const bear = Color(0xFFFF5566);
  static const bearSoft = Color(0xFF3A141C);

  static const warn = Color(0xFFFFB020);
  static const onAccent = Color(0xFF021018);
  static const onBull = Color(0xFF03140F);
  static const onBear = Color(0xFF1A0508);

  /// Chart tape
  static const wick = Color(0xFF7A8BA3);
  static const grid = Color(0xFF141C28);
  static const crosshair = Color(0xFF8FA3BD);
}

abstract final class PlSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class PlRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const sheet = 20.0;
}

abstract final class PlMotion {
  static const micro = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 260);
  static const emphasis = Duration(milliseconds: 400);
  static const curveIn = Curves.easeOutCubic;
  static const curveOut = Curves.easeInCubic;
  static const curveToggle = Curves.easeInOutCubic;
}
