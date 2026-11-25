import 'package:flutter/material.dart';

/// Bảng màu thương hiệu BookVerse – Material 3
/// Primary: Navy xanh tri thức | Secondary: Cam ấm điểm nhấn
class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────
  static const Color primary = Color(0xFF1B3A5C);
  static const Color primaryLight = Color(0xFF2E5A8A);
  static const Color primaryDark = Color(0xFF0F2440);

  // ── Secondary / Accent ────────────────────────────────
  static const Color secondary = Color(0xFFE8804C);
  static const Color secondaryLight = Color(0xFFF4A67A);
  static const Color secondaryDark = Color(0xFFC26030);

  // ── Backgrounds ───────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F6F3);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2A2A2A);

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDarkPrimary = Color(0xFFF0F0F0);
  static const Color textDarkSecondary = Color(0xFFAAAAAA);

  // ── Semantic ──────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Stars & Rating ────────────────────────────────────
  static const Color starFilled = Color(0xFFFBBF24);
  static const Color starEmpty = Color(0xFFD1D5DB);

  // ── Discount badge ────────────────────────────────────
  static const Color discountBadge = Color(0xFFEF4444);

  // ── Shimmer ───────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
