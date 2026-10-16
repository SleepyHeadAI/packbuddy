import 'package:firebase_auth/firebase_auth.dart';
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
  static const String keyOnboardingCompleted = 'packbuddy_onboarding_completed';
  static const String keyWidgetShowCountdown = 'packbuddy_widget_show_countdown';
  static const String keyWidgetShowPacking = 'packbuddy_widget_show_packing';
  static const String keyWidgetShowBudget = 'packbuddy_widget_show_budget';

  // Per-User Scoped Keys
  static const String keyDefaultCurrency = 'packbuddy_default_currency';
  static const String keyUserSelectedCurrency = 'packbuddy_user_selected_currency';
  static const String keyCountryCode = 'packbuddy_detected_country_code';
  static const String keyCountryName = 'packbuddy_detected_country_name';
  static const String keyRestrictedFeatures = 'packbuddy_restricted_features';
  static const String keyBanStatus = 'packbuddy_ban_status';
  static const String keyBanExpiresAt = 'packbuddy_ban_expires_at';
  static const String keyBanReason = 'packbuddy_ban_reason';

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

  String? _resolveEffectiveUid(String? uid) {
    if (uid != null && uid.isNotEmpty) return uid;
    try {
      final current = FirebaseAuth.instance.currentUser?.uid;
      if (current != null && current.isNotEmpty) return current;
    } catch (_) {}
    return null;
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

  // --- Pro Status & Plan (Strictly Scoped Per User) ---
  bool isProUser({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getBool('${keyIsPro}_$effectiveUid') ?? false;
    }
    return _prefs?.getBool(keyIsPro) ?? false;
  }

  Future<void> setProUser(bool isPro, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setBool('${keyIsPro}_$effectiveUid', isPro);
    }
    await _prefs?.setBool(keyIsPro, isPro);
  }

  /// Clears device-level Pro status flag to prevent account contagion
  Future<void> clearDeviceProStatus() async {
    await _prefs?.remove(keyIsPro);
  }

  String getSubscriptionPlan({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keySubscriptionPlan}_$effectiveUid') ??
          _prefs?.getString(keySubscriptionPlan) ??
          'annual';
    }
    return _prefs?.getString(keySubscriptionPlan) ?? 'annual';
  }

  Future<void> setSubscriptionPlan(String plan, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setString('${keySubscriptionPlan}_$effectiveUid', plan);
    } else {
      await _prefs?.setString(keySubscriptionPlan, plan);
    }
  }

  // --- Sync Timestamp (Scoped Per User) ---
  int? getLastSyncedAt({String? uid, String key = 'sync_engine_last_synced_at'}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getInt('${key}_$effectiveUid');
    }
    return _prefs?.getInt(key);
  }

  Future<void> setLastSyncedAt(int timestamp, {String? uid, String key = 'sync_engine_last_synced_at'}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setInt('${key}_$effectiveUid', timestamp);
    } else {
      await _prefs?.setInt(key, timestamp);
    }
  }

  // --- Currency & Country Preferences (Scoped Per User) ---
  String? getDefaultCurrency({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyDefaultCurrency}_$effectiveUid');
    }
    return _prefs?.getString(keyDefaultCurrency);
  }

  Future<void> setDefaultCurrency(String currency, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setString('${keyDefaultCurrency}_$effectiveUid', currency);
    } else {
      await _prefs?.setString(keyDefaultCurrency, currency);
    }
  }

  bool hasUserSelectedCurrency({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getBool('${keyUserSelectedCurrency}_$effectiveUid') ?? false;
    }
    return _prefs?.getBool(keyUserSelectedCurrency) ?? false;
  }

  Future<void> setUserSelectedCurrency(bool value, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setBool('${keyUserSelectedCurrency}_$effectiveUid', value);
    } else {
      await _prefs?.setBool(keyUserSelectedCurrency, value);
    }
  }

  String? getCountryCode({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyCountryCode}_$effectiveUid');
    }
    return _prefs?.getString(keyCountryCode);
  }

  Future<void> setCountryCode(String code, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setString('${keyCountryCode}_$effectiveUid', code);
    } else {
      await _prefs?.setString(keyCountryCode, code);
    }
  }

  String? getCountryName({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyCountryName}_$effectiveUid');
    }
    return _prefs?.getString(keyCountryName);
  }

  Future<void> setCountryName(String name, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setString('${keyCountryName}_$effectiveUid', name);
    } else {
      await _prefs?.setString(keyCountryName, name);
    }
  }

  // --- Feature Restrictions & Moderation (Scoped Per User) ---
  List<String> getRestrictedFeatures({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getStringList('${keyRestrictedFeatures}_$effectiveUid') ?? [];
    }
    return _prefs?.getStringList(keyRestrictedFeatures) ?? [];
  }

  Future<void> setRestrictedFeatures(List<String> features, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setStringList('${keyRestrictedFeatures}_$effectiveUid', features);
    } else {
      await _prefs?.setStringList(keyRestrictedFeatures, features);
    }
  }

  String getBanStatus({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyBanStatus}_$effectiveUid') ?? 'none';
    }
    return _prefs?.getString(keyBanStatus) ?? 'none';
  }

  Future<void> setBanStatus(String status, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setString('${keyBanStatus}_$effectiveUid', status);
    } else {
      await _prefs?.setString(keyBanStatus, status);
    }
  }

  String? getBanExpiresAt({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyBanExpiresAt}_$effectiveUid');
    }
    return _prefs?.getString(keyBanExpiresAt);
  }

  Future<void> setBanExpiresAt(String? expiresAt, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (expiresAt == null) {
      if (effectiveUid != null) {
        await _prefs?.remove('${keyBanExpiresAt}_$effectiveUid');
      } else {
        await _prefs?.remove(keyBanExpiresAt);
      }
    } else {
      if (effectiveUid != null) {
        await _prefs?.setString('${keyBanExpiresAt}_$effectiveUid', expiresAt);
      } else {
        await _prefs?.setString(keyBanExpiresAt, expiresAt);
      }
    }
  }

  String? getBanReason({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyBanReason}_$effectiveUid');
    }
    return _prefs?.getString(keyBanReason);
  }

  Future<void> setBanReason(String? reason, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (reason == null) {
      if (effectiveUid != null) {
        await _prefs?.remove('${keyBanReason}_$effectiveUid');
      } else {
        await _prefs?.remove(keyBanReason);
      }
    } else {
      if (effectiveUid != null) {
        await _prefs?.setString('${keyBanReason}_$effectiveUid', reason);
      } else {
        await _prefs?.setString(keyBanReason, reason);
      }
    }
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

  // --- Onboarding / First-time Tour ---
  bool isOnboardingCompleted() {
    return _prefs?.getBool(keyOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool(keyOnboardingCompleted, completed);
  }

  // --- Home Screen Widget Preferences ---
  bool isWidgetShowCountdown() => _prefs?.getBool(keyWidgetShowCountdown) ?? true;
  Future<void> setWidgetShowCountdown(bool show) async => _prefs?.setBool(keyWidgetShowCountdown, show);

  bool isWidgetShowPacking() => _prefs?.getBool(keyWidgetShowPacking) ?? true;
  Future<void> setWidgetShowPacking(bool show) async => _prefs?.setBool(keyWidgetShowPacking, show);

  bool isWidgetShowBudget() => _prefs?.getBool(keyWidgetShowBudget) ?? true;
  Future<void> setWidgetShowBudget(bool show) async => _prefs?.setBool(keyWidgetShowBudget, show);
}
