import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _key = 'vela_dark_mode';
  final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode.value);
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

/// Semantic color helper that returns the correct color for the current theme.
/// Light mode colors are the exact originals — untouched.
/// Dark mode uses a warm espresso/mocha palette to complement the orange accent.
class ThemeColors {
  static bool get _dark => ThemeService().isDarkMode.value;

  // ── Backgrounds ──────────────────────────────────
  static Color get scaffold =>
      _dark ? const Color(0xFF1C1714) : const Color(0xFFF9F9F9);

  static Color get scaffoldAlt =>
      _dark ? const Color(0xFF1C1714) : const Color(0xFFFDFDFD);

  // ── Surfaces / Cards ─────────────────────────────
  static Color get surface =>
      _dark ? const Color(0xFF2A2320) : Colors.white;

  // ── App Bar ──────────────────────────────────────
  static Color get appBar =>
      _dark ? const Color(0xFF332A22) : Colors.white;

  // ── Text ─────────────────────────────────────────
  static Color get text =>
      _dark ? const Color(0xFFEAEAEA) : const Color(0xFF3A3A3A);

  static Color get textSecondary =>
      _dark ? const Color(0xFF9E8E82) : const Color(0xFF999999);

  // ── Borders / Dividers ───────────────────────────
  static Color get border =>
      _dark ? const Color(0xFF4A3F35) : const Color(0xFFEEEEEE);

  // ── Icon tile backgrounds ────────────────────────
  static Color get iconBg =>
      _dark ? const Color(0xFF332A22) : const Color(0xFFF9F9F9);

  // ── Bottom Navigation Bar ────────────────────────
  static Color get navBar =>
      _dark ? const Color(0xFF332A22) : const Color(0xFFC2713A);

  static Color get navBarCenter =>
      _dark ? const Color(0xFF4A3520) : const Color(0xFFD4A574);

  // ── Delivery address card ────────────────────────
  static Color get deliveryCard =>
      _dark ? const Color(0xFF3D2E1E) : const Color(0xFFE8DECF);

  // ── Profile avatar ───────────────────────────────
  static Color get avatarBg =>
      _dark ? const Color(0xFF3D2E1E) : const Color(0xFFE8DECF);

  // ── Input fields ─────────────────────────────────
  static Color get inputText =>
      _dark ? const Color(0xFFEAEAEA) : const Color(0xFF3A3A3A);

  static Color get inputHint =>
      _dark ? const Color(0xFF7A6E64) : const Color(0xFFBBBBBB);

  // ── Shadow ───────────────────────────────────────
  static Color get shadow =>
      _dark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04);

  // ── Accent (unchanged across modes) ──────────────
  static const Color accent = Color(0xFFC2713A);

  // ── Icon path based on mode ──────────────────────
  static String get themeIcon =>
      _dark ? 'assets/images/icon2.png' : 'assets/images/icon.png';

  // ── Category chip ────────────────────────────────
  static Color get chipBg =>
      _dark ? const Color(0xFF2A2320) : Colors.white;

  // ── Status filter chip ───────────────────────────
  static Color get filterChipBg =>
      _dark ? const Color(0xFF2A2320) : Colors.white;

  // ── Payment / dropdown ───────────────────────────
  static Color get dropdownBg =>
      _dark ? const Color(0xFF2A2320) : Colors.white;

  // ── Bottom sheet ─────────────────────────────────
  static Color get bottomSheet =>
      _dark ? const Color(0xFF1C1714) : const Color(0xFFF9F9F9);

  // ── Subtle accent bg (for empty state circles) ──
  static Color get accentSubtle =>
      _dark ? const Color(0xFF3D2E1E) : const Color(0xFFC2713A).withValues(alpha: 0.08);
}
