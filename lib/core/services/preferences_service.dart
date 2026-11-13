import 'dart:convert';
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
  static const String keyWidgetShowContinents = 'packbuddy_widget_show_continents';
  static const String keyWidgetShowWishlist = 'packbuddy_widget_show_wishlist';
  static const String keyWidgetShowLiveRate = 'packbuddy_widget_show_live_rate';
  static const String keyWidgetShowReverseRate = 'packbuddy_widget_show_reverse_rate';
  static const String keyWidgetShowRemainingBudget = 'packbuddy_widget_show_remaining_budget';
  static const String keyWidgetShowLastExpense = 'packbuddy_widget_show_last_expense';
  static const String keyWidgetMode = 'packbuddy_widget_mode';
  static const String keyWidgetTheme = 'packbuddy_widget_theme';
  static const String keyTravelMapIs3D = 'packbuddy_travel_map_is_3d';

  // Per-User Scoped Keys
  static const String keyDefaultCurrency = 'packbuddy_default_currency';
  static const String keyUserSelectedCurrency = 'packbuddy_user_selected_currency';
  static const String keyCountryCode = 'packbuddy_detected_country_code';
  static const String keyCountryName = 'packbuddy_detected_country_name';
  static const String keyLiveCity = 'packbuddy_detected_city';
  static const String keyTotalSessionSeconds = 'packbuddy_total_session_seconds';
  static const String keySessionCount = 'packbuddy_session_count';
  static const String keyLastSessionSeconds = 'packbuddy_last_session_seconds';
  static const String keySessionHistory = 'packbuddy_session_history';
  static const String keyRestrictedFeatures = 'packbuddy_restricted_features';
  static const String keyBanStatus = 'packbuddy_ban_status';
  static const String keyBanExpiresAt = 'packbuddy_ban_expires_at';
  static const String keyBanReason = 'packbuddy_ban_reason';
  static const String keyLegalConsentAccepted = 'packbuddy_legal_consent_accepted_v1';
  static const String keyLegalConsentVersion = 'packbuddy_legal_consent_version';
  static const String keyLegalConsentDate = 'packbuddy_legal_consent_date';
  static const String keyLegalAnalyticsConsent = 'packbuddy_legal_analytics_consent';

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
        return ThemeMode.system;
      default:
        // PackBuddy starts in Light Mode by default on fresh install
        return ThemeMode.light;
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

  // --- Pro Status & Plan (Strictly Scoped Per User with Device Purchase Protection) ---
  bool isProUser({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getBool('${keyIsPro}_$effectiveUid') ?? false;
    }
    // Guaranteed fallback: Check device-level Google Play purchase flag
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


  String _vaultPinKey(String? uid) {
    final effective = _resolveEffectiveUid(uid);
    return effective != null ? '${keyVaultPin}_$effective' : keyVaultPin;
  }

  String _vaultBiometricKey(String? uid) {
    final effective = _resolveEffectiveUid(uid);
    return effective != null ? '${keyVaultBiometricEnabled}_$effective' : keyVaultBiometricEnabled;
  }

  String _vaultLockedKey(String? uid) {
    final effective = _resolveEffectiveUid(uid);
    return effective != null ? '${keyVaultLocked}_$effective' : keyVaultLocked;
  }

  // --- Vault Security & PIN ---
  String? getVaultPin({String? uid}) {
    final key = _vaultPinKey(uid);
    final val = _prefs?.getString(key);
    if (val != null && val.isNotEmpty) return val;
    // Fallback to legacy/guest device-level pin
    final legacy = _prefs?.getString(keyVaultPin);
    if (legacy != null && legacy.isNotEmpty) return legacy;
    return null;
  }

  Future<void> setVaultPin(String? pin, {String? uid}) async {
    final key = _vaultPinKey(uid);
    if (pin == null) {
      await _prefs?.remove(key);
      await _prefs?.remove(keyVaultPin);
    } else {
      await _prefs?.setString(key, pin);
      await _prefs?.setString(keyVaultPin, pin);
    }
  }

  bool isVaultBiometricEnabled({String? uid}) {
    final key = _vaultBiometricKey(uid);
    final val = _prefs?.getBool(key);
    if (val != null) return val;
    return _prefs?.getBool(keyVaultBiometricEnabled) ?? false;
  }

  Future<void> setVaultBiometricEnabled(bool enabled, {String? uid}) async {
    final key = _vaultBiometricKey(uid);
    await _prefs?.setBool(key, enabled);
    await _prefs?.setBool(keyVaultBiometricEnabled, enabled);
  }

  bool isVaultLocked({String? uid}) {
    // PIN is strictly mandatory for Document Vault access.
    // The vault is always locked by default on launch / restart until unlocked in-session.
    return true;
  }

  Future<void> setVaultLocked(bool locked, {String? uid}) async {
    final key = _vaultLockedKey(uid);
    if (locked) {
      await _prefs?.setBool(key, true);
      await _prefs?.setBool(keyVaultLocked, true);
    } else {
      await _prefs?.remove(key);
      await _prefs?.remove(keyVaultLocked);
    }
  }

  // --- Vault PIN Security: 5 Failed Attempts in 10 Minutes Lockout ---
  static const String keyVaultFailedPinAttempts = 'packbuddy_vault_failed_pin_attempts';
  static const int vaultMaxFailedPinAttempts = 5;
  static const int vaultLockoutWindowMs = 10 * 60 * 1000; // 10 minutes in ms

  String _vaultFailedAttemptsKey(String? uid) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return '${keyVaultFailedPinAttempts}_$effectiveUid';
    }
    return keyVaultFailedPinAttempts;
  }

  List<int> getRecentVaultFailedPinAttempts({String? uid}) {
    final key = _vaultFailedAttemptsKey(uid);
    final rawList = _prefs?.getStringList(key) ?? [];
    final now = DateTime.now().millisecondsSinceEpoch;
    final validAttempts = <int>[];

    for (final item in rawList) {
      final ts = int.tryParse(item);
      if (ts != null && (now - ts) < vaultLockoutWindowMs && ts <= now) {
        validAttempts.add(ts);
      }
    }
    return validAttempts;
  }

  Future<void> recordVaultFailedPinAttempt({String? uid}) async {
    final key = _vaultFailedAttemptsKey(uid);
    final attempts = getRecentVaultFailedPinAttempts(uid: uid);
    attempts.add(DateTime.now().millisecondsSinceEpoch);
    await _prefs?.setStringList(key, attempts.map((t) => t.toString()).toList());
  }

  int getRecentVaultFailedPinAttemptsCount({String? uid}) {
    return getRecentVaultFailedPinAttempts(uid: uid).length;
  }

  bool isVaultPinLockedOut({String? uid}) {
    return getRecentVaultFailedPinAttempts(uid: uid).length >= vaultMaxFailedPinAttempts;
  }

  int getVaultPinLockoutRemainingSeconds({String? uid}) {
    final attempts = getRecentVaultFailedPinAttempts(uid: uid);
    if (attempts.length < vaultMaxFailedPinAttempts) {
      return 0;
    }
    attempts.sort();
    final triggerAttempt = attempts[attempts.length - vaultMaxFailedPinAttempts];
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = triggerAttempt + vaultLockoutWindowMs;
    final remainingMs = expiresAt - now;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  Future<void> resetVaultFailedPinAttempts({String? uid}) async {
    final key = _vaultFailedAttemptsKey(uid);
    await _prefs?.remove(key);
  }

  // --- Vault AES-256 At-Rest Encryption ---
  static const String keyVaultAesKey = 'packbuddy_vault_aes_key';

  String? getVaultEncryptionKey() {
    return _prefs?.getString(keyVaultAesKey);
  }

  Future<void> setVaultEncryptionKey(String keyBase64) async {
    await _prefs?.setString(keyVaultAesKey, keyBase64);
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

  // --- Legal Consent & Data Protection Agreement ---
  static const String currentLegalConsentVersion = '1.0.0';

  bool hasAcceptedLegalConsent({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      final userVal = _prefs?.getBool('${keyLegalConsentAccepted}_$effectiveUid');
      if (userVal != null) return userVal;
    }
    return _prefs?.getBool(keyLegalConsentAccepted) ?? false;
  }

  Future<void> setLegalConsentAccepted(
    bool accepted, {
    String? uid,
    String version = currentLegalConsentVersion,
    bool analyticsConsent = true,
  }) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    final now = DateTime.now().toIso8601String();

    await _prefs?.setBool(keyLegalConsentAccepted, accepted);
    await _prefs?.setString(keyLegalConsentVersion, version);
    await _prefs?.setString(keyLegalConsentDate, now);
    await _prefs?.setBool(keyLegalAnalyticsConsent, analyticsConsent);

    if (effectiveUid != null) {
      await _prefs?.setBool('${keyLegalConsentAccepted}_$effectiveUid', accepted);
      await _prefs?.setString('${keyLegalConsentVersion}_$effectiveUid', version);
      await _prefs?.setString('${keyLegalConsentDate}_$effectiveUid', now);
      await _prefs?.setBool('${keyLegalAnalyticsConsent}_$effectiveUid', analyticsConsent);
    }
  }

  String? getLegalConsentDate({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      final val = _prefs?.getString('${keyLegalConsentDate}_$effectiveUid');
      if (val != null) return val;
    }
    return _prefs?.getString(keyLegalConsentDate);
  }

  String getLegalConsentVersion({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      final val = _prefs?.getString('${keyLegalConsentVersion}_$effectiveUid');
      if (val != null) return val;
    }
    return _prefs?.getString(keyLegalConsentVersion) ?? currentLegalConsentVersion;
  }

  bool isAnalyticsConsentGiven({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      final val = _prefs?.getBool('${keyLegalAnalyticsConsent}_$effectiveUid');
      if (val != null) return val;
    }
    return _prefs?.getBool(keyLegalAnalyticsConsent) ?? true;
  }

  // --- Home Screen Widget Preferences ---
  static const String keyDashboardSectionOrder = 'packbuddy_dashboard_section_order_v2';
  static const String keyDashboardHiddenSections = 'packbuddy_dashboard_hidden_sections_v2';

  static const List<String> defaultDashboardSectionOrder = [
    'active_trip',
    'luggage_checklist',
    'currency_converter',
    'mini_travel_map',
    'mini_vault',
    'mini_all_trips',
    'mini_trip_comparison',
  ];

  List<String> getDashboardSectionOrder() {
    final list = _prefs?.getStringList(keyDashboardSectionOrder);
    if (list != null && list.isNotEmpty) {
      final set = list.toSet();
      final merged = List<String>.from(list);
      for (final sec in defaultDashboardSectionOrder) {
        if (!set.contains(sec)) {
          merged.add(sec);
        }
      }
      return merged;
    }
    return List<String>.from(defaultDashboardSectionOrder);
  }

  Future<void> setDashboardSectionOrder(List<String> order) async {
    await _prefs?.setStringList(keyDashboardSectionOrder, order);
  }

  Set<String> getDashboardHiddenSections() {
    final list = _prefs?.getStringList(keyDashboardHiddenSections);
    return list?.toSet() ?? <String>{};
  }

  Future<void> setDashboardHiddenSections(Set<String> hidden) async {
    await _prefs?.setStringList(keyDashboardHiddenSections, hidden.toList());
  }

  Future<void> resetDashboardCustomization() async {
    await _prefs?.remove(keyDashboardSectionOrder);
    await _prefs?.remove(keyDashboardHiddenSections);
  }

  bool isWidgetShowCountdown() => _prefs?.getBool(keyWidgetShowCountdown) ?? true;
  Future<void> setWidgetShowCountdown(bool show) async => _prefs?.setBool(keyWidgetShowCountdown, show);

  bool isWidgetShowPacking() => _prefs?.getBool(keyWidgetShowPacking) ?? true;
  Future<void> setWidgetShowPacking(bool show) async => _prefs?.setBool(keyWidgetShowPacking, show);

  bool isWidgetShowBudget() => _prefs?.getBool(keyWidgetShowBudget) ?? true;
  Future<void> setWidgetShowBudget(bool show) async => _prefs?.setBool(keyWidgetShowBudget, show);

  bool isWidgetShowContinents() => _prefs?.getBool(keyWidgetShowContinents) ?? true;
  Future<void> setWidgetShowContinents(bool show) async => _prefs?.setBool(keyWidgetShowContinents, show);

  bool isWidgetShowWishlist() => _prefs?.getBool(keyWidgetShowWishlist) ?? true;
  Future<void> setWidgetShowWishlist(bool show) async => _prefs?.setBool(keyWidgetShowWishlist, show);

  bool isWidgetShowLiveRate() => _prefs?.getBool(keyWidgetShowLiveRate) ?? true;
  Future<void> setWidgetShowLiveRate(bool show) async => _prefs?.setBool(keyWidgetShowLiveRate, show);

  bool isWidgetShowReverseRate() => _prefs?.getBool(keyWidgetShowReverseRate) ?? false;
  Future<void> setWidgetShowReverseRate(bool show) async => _prefs?.setBool(keyWidgetShowReverseRate, show);

  bool isWidgetShowRemainingBudget() => _prefs?.getBool(keyWidgetShowRemainingBudget) ?? true;
  Future<void> setWidgetShowRemainingBudget(bool show) async => _prefs?.setBool(keyWidgetShowRemainingBudget, show);

  bool isWidgetShowLastExpense() => _prefs?.getBool(keyWidgetShowLastExpense) ?? true;
  Future<void> setWidgetShowLastExpense(bool show) async => _prefs?.setBool(keyWidgetShowLastExpense, show);

  String getWidgetMode() => _prefs?.getString(keyWidgetMode) ?? 'trip';
  Future<void> setWidgetMode(String mode) async => _prefs?.setString(keyWidgetMode, mode);

  String getWidgetTheme() => _prefs?.getString(keyWidgetTheme) ?? 'midnight';
  Future<void> setWidgetTheme(String theme) async => _prefs?.setString(keyWidgetTheme, theme);

  String getWidgetThemeForMode(String mode) {
    final key = 'packbuddy_widget_theme_$mode';
    final saved = _prefs?.getString(key);
    if (saved != null && saved.isNotEmpty) return saved;
    switch (mode) {
      case 'world_map':
        return 'midnight';
      case 'quick_expense':
        return 'matcha';
      case 'currency_converter':
        return 'oceanLight';
      case 'trip':
      default:
        return getWidgetTheme();
    }
  }

  Future<void> setWidgetThemeForMode(String mode, String theme) async {
    await _prefs?.setString('packbuddy_widget_theme_$mode', theme);
    await setWidgetTheme(theme);
  }

  // --- Notifications Center Unread Tracking & History ---
  static const String keyLastReadNotificationsAt = 'notifications_last_read_timestamp';
  int getLastReadNotificationsAt() => _prefs?.getInt(keyLastReadNotificationsAt) ?? 0;
  Future<void> setLastReadNotificationsAt(int timestamp) async => _prefs?.setInt(keyLastReadNotificationsAt, timestamp);

  static const String keyNotificationHistoryList = 'notification_history_json_list';
  List<String> getNotificationHistory() => _prefs?.getStringList(keyNotificationHistoryList) ?? [];
  Future<void> saveNotificationHistory(List<String> items) async => _prefs?.setStringList(keyNotificationHistoryList, items);
  Future<void> clearNotificationHistory() async => _prefs?.remove(keyNotificationHistoryList);

  Future<void> addNotificationHistoryItem(String jsonItem) async {
    final list = List<String>.from(getNotificationHistory());
    list.insert(0, jsonItem);
    if (list.length > 60) list.removeLast();
    await saveNotificationHistory(list);
  }

  // --- Two-Way Cloud Sync Diagnostic History Logs ---
  static const String keySyncHistoryList = 'sync_history_json_list';
  List<String> getSyncHistory() => _prefs?.getStringList(keySyncHistoryList) ?? [];
  Future<void> saveSyncHistory(List<String> items) async => _prefs?.setStringList(keySyncHistoryList, items);
  Future<void> clearSyncHistory() async => _prefs?.remove(keySyncHistoryList);

  Future<void> addSyncHistoryItem(String jsonItem) async {
    final list = List<String>.from(getSyncHistory());
    list.insert(0, jsonItem);
    if (list.length > 30) list.removeLast();
    await saveSyncHistory(list);
  }

  // --- User Profile Offline Cache ---
  static const String keyUserProfileCachePrefix = 'user_profile_cached_';
  String? getCachedUserProfile(String uid) => _prefs?.getString('${keyUserProfileCachePrefix}_$uid');
  Future<void> setCachedUserProfile(String uid, String jsonStr) async =>
      _prefs?.setString('${keyUserProfileCachePrefix}_$uid', jsonStr);

  // --- Recent Searches History ---
  static const String keyRecentSearches = 'packbuddy_recent_searches';
  List<String> getRecentSearches() => _prefs?.getStringList(keyRecentSearches) ?? [];
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final list = List<String>.from(getRecentSearches());
    list.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    list.insert(0, trimmed);
    if (list.length > 10) list.removeLast();
    await _prefs?.setStringList(keyRecentSearches, list);
  }
  Future<void> removeRecentSearch(String query) async {
    final list = List<String>.from(getRecentSearches());
    list.removeWhere((item) => item.toLowerCase() == query.trim().toLowerCase());
    await _prefs?.setStringList(keyRecentSearches, list);
  }
  Future<void> clearRecentSearches() async => _prefs?.remove(keyRecentSearches);

  static const String keyLastSeenAdminWarningAt = 'last_seen_admin_warning_timestamp';
  int getLastSeenAdminWarningAt({String? uid}) {
    final key = uid != null && uid.isNotEmpty ? '${keyLastSeenAdminWarningAt}_$uid' : keyLastSeenAdminWarningAt;
    return _prefs?.getInt(key) ?? 0;
  }
  Future<void> setLastSeenAdminWarningAt(int timestamp, {String? uid}) async {
    final key = uid != null && uid.isNotEmpty ? '${keyLastSeenAdminWarningAt}_$uid' : keyLastSeenAdminWarningAt;
    await _prefs?.setInt(key, timestamp);
  }

  // --- Persistent Notification Delivery & Anti-Spam Deduplication Engine ---
  static const String keyDeliveredNotificationIds = 'delivered_notification_ids';
  final Set<String> _inMemoryDeliveredIds = {};

  List<String> getDeliveredNotificationIds() {
    final list = _prefs?.getStringList(keyDeliveredNotificationIds) ?? [];
    _inMemoryDeliveredIds.addAll(list);
    return list;
  }

  bool hasDeliveredNotification(String notificationId) {
    if (notificationId.isEmpty) return false;
    if (_inMemoryDeliveredIds.contains(notificationId)) return true;
    final list = _prefs?.getStringList(keyDeliveredNotificationIds) ?? [];
    if (list.contains(notificationId)) {
      _inMemoryDeliveredIds.add(notificationId);
      return true;
    }
    return false;
  }

  Future<void> markNotificationDelivered(String notificationId) async {
    if (notificationId.isEmpty) return;
    _inMemoryDeliveredIds.add(notificationId);
    final list = List<String>.from(_prefs?.getStringList(keyDeliveredNotificationIds) ?? []);
    if (!list.contains(notificationId)) {
      list.add(notificationId);
      if (list.length > 200) {
        list.removeRange(0, list.length - 200);
      }
      await _prefs?.setStringList(keyDeliveredNotificationIds, list);
    }
  }

  Future<void> clearDeliveredNotifications() async {
    _inMemoryDeliveredIds.clear();
    await _prefs?.remove(keyDeliveredNotificationIds);
  }

  // --- Checklist First-Time Seeding Tracking ---
  bool hasSeededChecklist({String? uid}) {
    final key = uid != null && uid.isNotEmpty ? 'has_seeded_checklist_$uid' : 'has_seeded_checklist';
    return _prefs?.getBool(key) ?? false;
  }

  Future<void> setSeededChecklist(bool value, {String? uid}) async {
    final key = uid != null && uid.isNotEmpty ? 'has_seeded_checklist_$uid' : 'has_seeded_checklist';
    await _prefs?.setBool(key, value);
  }

  bool hasClearedChecklist({String? uid}) {
    final key = uid != null && uid.isNotEmpty ? 'has_cleared_checklist_$uid' : 'has_cleared_checklist';
    return _prefs?.getBool(key) ?? false;
  }

  Future<void> setClearedChecklist(bool value, {String? uid}) async {
    final key = uid != null && uid.isNotEmpty ? 'has_cleared_checklist_$uid' : 'has_cleared_checklist';
    await _prefs?.setBool(key, value);
  }

  // --- User Feedback Cache ---
  static const String keyFeedbackCache = 'packbuddy_user_feedback_cache';
  String? getFeedbackCache() => _prefs?.getString(keyFeedbackCache);
  Future<void> saveFeedbackCache(String json) async => _prefs?.setString(keyFeedbackCache, json);

  // --- Travel Map Mode (2D flat vs 3D Globe) ---
  bool getTravelMapIs3D() => _prefs?.getBool(keyTravelMapIs3D) ?? false;
  Future<void> setTravelMapIs3D(bool is3D) async => _prefs?.setBool(keyTravelMapIs3D, is3D);

  // --- Live City & Session Tracking (Local Persistence) ---
  String? getLiveCity({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getString('${keyLiveCity}_$effectiveUid');
    }
    return _prefs?.getString(keyLiveCity);
  }

  Future<void> setLiveCity(String city, {String? uid}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      await _prefs?.setString('${keyLiveCity}_$effectiveUid', city);
    } else {
      await _prefs?.setString(keyLiveCity, city);
    }
  }

  int getTotalSessionSeconds({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getInt('${keyTotalSessionSeconds}_$effectiveUid') ?? 0;
    }
    return _prefs?.getInt(keyTotalSessionSeconds) ?? 0;
  }

  int getSessionCount({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getInt('${keySessionCount}_$effectiveUid') ?? 0;
    }
    return _prefs?.getInt(keySessionCount) ?? 0;
  }

  int getLastSessionSeconds({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    if (effectiveUid != null) {
      return _prefs?.getInt('${keyLastSessionSeconds}_$effectiveUid') ?? 0;
    }
    return _prefs?.getInt(keyLastSessionSeconds) ?? 0;
  }

  List<Map<String, dynamic>> getSessionLogs({String? uid}) {
    final effectiveUid = _resolveEffectiveUid(uid);
    final key = effectiveUid != null ? '${keySessionHistory}_$effectiveUid' : keySessionHistory;
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> recordSession(int seconds, {String? uid, DateTime? timestamp}) async {
    final effectiveUid = _resolveEffectiveUid(uid);
    final curTotal = getTotalSessionSeconds(uid: effectiveUid);
    final curCount = getSessionCount(uid: effectiveUid);
    final totalKey = effectiveUid != null ? '${keyTotalSessionSeconds}_$effectiveUid' : keyTotalSessionSeconds;
    final countKey = effectiveUid != null ? '${keySessionCount}_$effectiveUid' : keySessionCount;
    final lastKey = effectiveUid != null ? '${keyLastSessionSeconds}_$effectiveUid' : keyLastSessionSeconds;
    final histKey = effectiveUid != null ? '${keySessionHistory}_$effectiveUid' : keySessionHistory;

    await _prefs?.setInt(totalKey, curTotal + seconds);
    await _prefs?.setInt(countKey, curCount + 1);
    await _prefs?.setInt(lastKey, seconds);

    final logs = getSessionLogs(uid: effectiveUid);
    logs.insert(0, {
      'durationSeconds': seconds,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    });
    if (logs.length > 200) {
      logs.removeRange(200, logs.length);
    }
    await _prefs?.setString(histKey, jsonEncode(logs));
  }

  /// Get user-scoped travel countries raw JSON
  String? getScopedTravelCountriesJson(String uid) {
    if (uid.isEmpty) return null;
    return _prefs?.getString('packbuddy_travel_map_countries_v1_$uid');
  }
}
