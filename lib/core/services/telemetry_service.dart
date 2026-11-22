import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Representation of an analytics event recorded in-memory for testing and debugging
class TelemetryEventRecord {
  final String name;
  final Map<String, Object>? properties;
  final DateTime timestamp;

  const TelemetryEventRecord({
    required this.name,
    this.properties,
    required this.timestamp,
  });

  @override
  String toString() => 'TelemetryEventRecord($name, $properties, $timestamp)';
}

/// Centralized, resilient Telemetry & Analytics Service wrapping PostHog (EU Cloud).
///
/// Wraps all native platform calls in try/catch guards so unit/widget tests and
/// offline mode never encounter unhandled PlatformExceptions or crashes.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  static const String posthogApiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: '',
  );
  static const int posthogProjectId = int.fromEnvironment(
    'POSTHOG_PROJECT_ID',
    defaultValue: 0,
  );
  static const String posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://eu.i.posthog.com',
  );

  /// In-memory history of events for verification in unit/widget test environments
  final List<TelemetryEventRecord> testHistory = [];
  bool recordHistory = true;

  /// Clears in-memory test history
  void clearTestHistory() => testHistory.clear();

  /// Initializes PostHog SDK programmatically with EU Cloud, Session Replay & PII text masking
  Future<void> init() async {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    final effectiveApiKey = posthogApiKey.isNotEmpty
        ? posthogApiKey
        : 'phc_zJWTksx4JFN95rKAsfPxR9fUeQLFyM9ArCb9ZUkVjLeK';

    if (effectiveApiKey.isEmpty) {
      debugPrint('[TelemetryService] POSTHOG_API_KEY is not configured. Running in secure offline mode.');
      return;
    }
    try {
      final config = PostHogConfig(effectiveApiKey);
      config.host = posthogHost;
      config.captureApplicationLifecycleEvents = true;
      // F3: privacy by default — no session replay / touch capture, and nothing is sent
      // until the user explicitly grants analytics consent (see applyConsent).
      config.sessionReplay = false;
      config.sessionReplayConfig.maskAllTexts = true;
      config.sessionReplayConfig.maskAllImages = true;
      config.sessionReplayConfig.captureTouches = false;
      config.optOut = true;
      await Posthog().setup(config);
    } catch (e) {
      debugPrint('[TelemetryService] Initialization notice: $e');
    }
  }

  /// Whether the user has explicitly granted analytics consent in this session.
  bool _consentGranted = false;
  bool get isConsentGranted => _consentGranted;

  /// Opts PostHog in only after explicit analytics consent; opts out otherwise.
  /// The consent flag is applied immediately; the native SDK call runs in the background
  /// so UI flows (e.g. the consent screen) never block on the platform channel.
  Future<void> applyConsent(bool granted) async {
    _consentGranted = granted;
    _record(granted ? '\$opt_in' : '\$opt_out', null);
    unawaited(_applyNativeConsent(granted));
  }

  Future<void> _applyNativeConsent(bool granted) async {
    try {
      if (granted) {
        await Posthog().optIn();
      } else {
        await Posthog().optOut();
      }
    } catch (e) {
      debugPrint('[TelemetryService] applyConsent notice: $e');
    }
  }

  void _record(String name, Map<String, Object>? properties) {
    if (recordHistory) {
      testHistory.add(
        TelemetryEventRecord(
          name: name,
          properties: properties != null ? Map.unmodifiable(properties) : null,
          timestamp: DateTime.now(),
        ),
      );
      if (testHistory.length > 200) {
        testHistory.removeAt(0);
      }
    }
  }

  /// Identifies the user in PostHog by uid only. No PII (e-mail, name) is ever sent (F3).
  Future<void> identifyUser({
    required String uid,
    required bool isPro,
    int? totalStorageBytes,
    String? locale,
  }) async {
    final userProps = <String, Object>{
      'is_pro': isPro,
      'project_id': posthogProjectId,
      'total_storage_bytes': totalStorageBytes ?? 0,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
    };

    _record('\$identify', {'user_id': uid, ...userProps});

    try {
      await Posthog().identify(
        userId: uid,
        userProperties: userProps,
      );
    } catch (e) {
      debugPrint('[TelemetryService] identifyUser error: $e');
    }
  }

  /// Resets user identity on logout to ensure sessions and events are isolated
  Future<void> resetUser() async {
    _record('\$reset', null);
    try {
      await Posthog().reset();
    } catch (e) {
      debugPrint('[TelemetryService] resetUser error: $e');
    }
  }

  /// Logs a manual screen view event
  Future<void> logScreen(
    String screenName, {
    Map<String, Object>? properties,
  }) async {
    _record('\$screen', {'screen_name': screenName, ...?properties});
    try {
      await Posthog().screen(
        screenName: screenName,
        properties: properties,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logScreen error: $e');
    }
  }

  /// Captures when a user creates a new trip
  Future<void> logTripCreated({
    required String destination,
    required String transportMode,
    required double budget,
    required String currency,
  }) async {
    final props = <String, Object>{
      'destination': destination,
      'transport_mode': transportMode,
      'budget': budget,
      'currency': currency,
    };
    _record('trip_created', props);

    try {
      await Posthog().capture(
        eventName: 'trip_created',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logTripCreated error: $e');
    }
  }

  /// Captures when a user records a trip expense
  Future<void> logExpenseLogged({
    required String category,
    required double amount,
    required String currency,
  }) async {
    final props = <String, Object>{
      'category': category,
      'amount': amount,
      'currency': currency,
    };
    _record('expense_logged', props);

    try {
      await Posthog().capture(
        eventName: 'expense_logged',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logExpenseLogged error: $e');
    }
  }

  /// Captures packing checklist actions (add, toggle, bulk pack, template import)
  Future<void> logChecklistAction({
    required String action,
    String? category,
    int? itemCount,
  }) async {
    final props = <String, Object>{
      'action': action,
      if (category != null && category.isNotEmpty) 'category': category,
      if (itemCount != null && itemCount >= 0) 'item_count': itemCount,
    };
    _record('checklist_action', props);

    try {
      await Posthog().capture(
        eventName: 'checklist_action',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logChecklistAction error: $e');
    }
  }

  /// Captures document uploads to the Vault with metering properties
  Future<void> logDocumentUploaded({
    required String category,
    required int fileSizeBytes,
    required String fileExtension,
  }) async {
    final props = <String, Object>{
      'category': category,
      'file_size_bytes': fileSizeBytes,
      'file_extension': fileExtension,
    };
    _record('document_uploaded', props);

    try {
      await Posthog().capture(
        eventName: 'document_uploaded',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logDocumentUploaded error: $e');
    }
  }

  /// Captures paywall impression events with optional contextual highlight
  Future<void> logPaywallViewed({
    required String triggerSource,
    String? highlightFeature,
  }) async {
    final props = <String, Object>{
      'trigger_source': triggerSource,
      'highlight_feature': ?highlightFeature,
    };
    _record('paywall_viewed', props);

    try {
      await Posthog().capture(
        eventName: 'paywall_viewed',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logPaywallViewed error: $e');
    }
  }

  /// Captures when a user hits a Pro feature limit or locked capability
  Future<void> logProGateHit({
    required String featureKey,
    String? context,
  }) async {
    final props = <String, Object>{
      'feature_key': featureKey,
      'context': ?context,
    };
    _record('pro_gate_hit', props);

    try {
      await Posthog().capture(
        eventName: 'pro_gate_hit',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logProGateHit error: $e');
    }
  }

  /// Captures when user starts checkout / purchase flow
  Future<void> logPurchaseStarted({
    required String productId,
    required String plan,
  }) async {
    final props = <String, Object>{
      'product_id': productId,
      'plan': plan,
    };
    _record('purchase_started', props);

    try {
      await Posthog().capture(
        eventName: 'purchase_started',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logPurchaseStarted error: $e');
    }
  }

  /// Captures successful subscription completion
  Future<void> logPurchaseCompleted({
    required String productId,
    required String plan,
    String? purchaseId,
  }) async {
    final props = <String, Object>{
      'product_id': productId,
      'plan': plan,
      'purchase_id': ?purchaseId,
    };
    _record('purchase_completed', props);

    try {
      await Posthog().capture(
        eventName: 'purchase_completed',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logPurchaseCompleted error: $e');
    }
  }

  /// Captures restored subscription
  Future<void> logPurchaseRestored({
    required String source,
  }) async {
    final props = <String, Object>{
      'source': source,
    };
    _record('purchase_restored', props);

    try {
      await Posthog().capture(
        eventName: 'purchase_restored',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logPurchaseRestored error: $e');
    }
  }

  /// Captures Pro subscription status transitions
  Future<void> logProStatusChanged({
    required bool isPro,
    required String source,
  }) async {
    final props = <String, Object>{
      'is_pro': isPro,
      'source': source,
    };
    _record('pro_status_changed', props);

    try {
      await Posthog().capture(
        eventName: 'pro_status_changed',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logProStatusChanged error: $e');
    }
  }

  /// Captures when user starts the onboarding experience
  Future<void> logOnboardingStarted() async {
    _record('onboarding_started', null);
    try {
      await Posthog().capture(eventName: 'onboarding_started');
    } catch (e) {
      debugPrint('[TelemetryService] logOnboardingStarted error: $e');
    }
  }

  /// Captures each individual step viewed in the onboarding walkthrough
  Future<void> logOnboardingStepViewed({
    required int stepIndex,
    required String stepTitle,
  }) async {
    final props = <String, Object>{
      'step_index': stepIndex,
      'step_title': stepTitle,
    };
    _record('onboarding_step_viewed', props);
    try {
      await Posthog().capture(
        eventName: 'onboarding_step_viewed',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logOnboardingStepViewed error: $e');
    }
  }

  /// Captures when user completes the onboarding tour
  Future<void> logOnboardingCompleted() async {
    _record('onboarding_completed', null);
    try {
      await Posthog().capture(eventName: 'onboarding_completed');
    } catch (e) {
      debugPrint('[TelemetryService] logOnboardingCompleted error: $e');
    }
  }

  /// Captures user preference changes (theme, language, currency)
  Future<void> logPreferenceChanged({
    required String setting,
    required String value,
  }) async {
    final props = <String, Object>{
      'setting': setting,
      'value': value,
    };
    _record('preference_changed', props);

    try {
      await Posthog().capture(
        eventName: 'preference_changed',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logPreferenceChanged error: $e');
    }
  }

  /// Captures executive administrative actions (pro grants/revocations, document moderations, deletions)
  Future<void> logAdminAction({
    required String action,
    required String targetUid,
    Map<String, Object>? details,
  }) async {
    final props = <String, Object>{
      'action': action,
      'target_uid': targetUid,
      ...?details,
    };
    _record('admin_action', props);

    try {
      await Posthog().capture(
        eventName: 'admin_action',
        properties: props,
      );
    } catch (e) {
      debugPrint('[TelemetryService] logAdminAction error: $e');
    }
  }
}

/// Riverpod Provider exposing the TelemetryService
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService.instance;
});
