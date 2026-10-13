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

  static const String posthogApiKey = 'phc_zJWTksx4JFN95rKAsfPxR9fUeQLFyM9ArCb9ZUkVjLeK';
  static const int posthogProjectId = 305038;
  static const String posthogHost = 'https://eu.i.posthog.com';

  /// In-memory history of events for verification in unit/widget test environments
  final List<TelemetryEventRecord> testHistory = [];
  bool recordHistory = true;

  /// Clears in-memory test history
  void clearTestHistory() => testHistory.clear();

  /// Initializes PostHog SDK programmatically with EU Cloud, Session Replay & PII text masking
  Future<void> init() async {
    try {
      final config = PostHogConfig(posthogApiKey);
      config.host = posthogHost;
      config.captureApplicationLifecycleEvents = true;
      config.sessionReplay = true;
      config.sessionReplayConfig.maskAllTexts = true;
      config.sessionReplayConfig.maskAllImages = true;
      config.sessionReplayConfig.captureTouches = true;
      await Posthog().setup(config);
    } catch (e) {
      debugPrint('[TelemetryService] Initialization notice: $e');
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

  /// Identifies the user in PostHog and attaches user properties
  Future<void> identifyUser({
    required String uid,
    String? email,
    String? displayName,
    required bool isPro,
    int? totalStorageBytes,
    String? locale,
  }) async {
    final userProps = <String, Object>{
      'is_pro': isPro,
      'project_id': posthogProjectId,
      'total_storage_bytes': totalStorageBytes ?? 0,
      if (email != null && email.isNotEmpty) 'email': email,
      if (displayName != null && displayName.isNotEmpty) 'name': displayName,
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

  /// Captures paywall impression events
  Future<void> logPaywallViewed({
    required String triggerSource,
  }) async {
    final props = <String, Object>{
      'trigger_source': triggerSource,
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

  /// Captures executive administrative actions (pro grants/revocations)
  Future<void> logAdminAction({
    required String action,
    required String targetUid,
  }) async {
    final props = <String, Object>{
      'action': action,
      'target_uid': targetUid,
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
