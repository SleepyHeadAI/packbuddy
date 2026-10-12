import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Preferences Service for persisting App Settings, Theme, Locale, and State
class PreferencesService {
  static const String keyThemeMode = 'packbuddy_theme_mode';
  static const String keyLocale = 'packbuddy_app_locale';
  static const String keyIsPro = 'packbuddy_is_pro_member';
  static const String keySubscriptionPlan = 'packbuddy_subscription_plan';
  static const String keyVaultPin = 'packbuddy_vault_pin';
  static const String keyVaultLocked = 'packbuddy_vault_locked';
  static const String keyVaultBiometricEnabled = 'packbuddy_vault_biometric_enabled';
  static const String keyPackingRemindersEnabled = 'packbuddy_packing_reminders_enabled';

  static PreferencesService? _instance;
  final SharedPreferences? _prefs;

  PreferencesService._(this._prefs);

  static PreferencesService get instance {
    _instance ??= PreferencesService._(null);
    return _instance!;
  }

  static void setInstance(PreferencesService service) {
    _instance = service;
  }

  static Future<PreferencesService> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _instance = PreferencesService._(prefs);
      return _instance!;
    } catch (_) {
      _instance = PreferencesService._(null);
      return _instance!;
    }
  }

  // --- Theme Mode ---
  ThemeMode getThemeMode() {
    final raw = _prefs?.getString(keyThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final val = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs?.setString(keyThemeMode, val);
  }

  // --- Locale ---
  Locale? getLocale() {
    final code = _prefs?.getString(keyLocale);
    if (code != null && code.isNotEmpty) {
      return Locale(code);
    }
    return null;
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs?.setString(keyLocale, locale.languageCode);
  }

  // --- Pro Status & Plan ---
  bool isProUser() {
    return _prefs?.getBool(keyIsPro) ?? false;
  }

  Future<void> setProUser(bool isPro) async {
    await _prefs?.setBool(keyIsPro, isPro);
  }

  String getSubscriptionPlan() {
    return _prefs?.getString(keySubscriptionPlan) ?? 'annual';
  }

  Future<void> setSubscriptionPlan(String plan) async {
    await _prefs?.setString(keySubscriptionPlan, plan);
  }

  // --- Vault Security & PIN ---
  String? getVaultPin() {
    return _prefs?.getString(keyVaultPin);
  }

  Future<void> setVaultPin(String? pin) async {
    if (pin == null) {
      await _prefs?.remove(keyVaultPin);
    } else {
      await _prefs?.setString(keyVaultPin, pin);
    }
  }

  bool isVaultBiometricEnabled() {
    return _prefs?.getBool(keyVaultBiometricEnabled) ?? false;
  }

  Future<void> setVaultBiometricEnabled(bool enabled) async {
    await _prefs?.setBool(keyVaultBiometricEnabled, enabled);
  }

  bool isVaultLocked() {
    // If PIN is set, vault is locked by default on launch
    final hasPin = getVaultPin() != null;
    return _prefs?.getBool(keyVaultLocked) ?? hasPin;
  }

  Future<void> setVaultLocked(bool locked) async {
    await _prefs?.setBool(keyVaultLocked, locked);
  }

  // --- Smart Notifications & Packing Reminders ---
  bool isPackingRemindersEnabled() {
    return _prefs?.getBool(keyPackingRemindersEnabled) ?? true;
  }

  Future<void> setPackingRemindersEnabled(bool enabled) async {
    await _prefs?.setBool(keyPackingRemindersEnabled, enabled);
  }
}
