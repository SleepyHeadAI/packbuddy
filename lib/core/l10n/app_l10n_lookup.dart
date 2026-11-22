import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../services/preferences_service.dart';

/// Resolves [AppLocalizations] outside the widget tree (services, background
/// sync, notification channels, outgoing emails).
///
/// Uses [languageCode] when given, otherwise the user's saved app language.
/// Unsupported or missing languages fall back to English.
AppLocalizations appL10nFor([String? languageCode]) {
  final code = (languageCode ?? PreferencesService.instance.getLocale()?.languageCode ?? 'en')
      .toLowerCase()
      .split('_')
      .first
      .split('-')
      .first;
  final supported = AppLocalizations.supportedLocales.any((l) => l.languageCode == code);
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}

/// Maps internal error codes stored in controller/service state to a
/// localized, user-friendly message. Raw exception text is never shown.
String localizeUserError(AppLocalizations l10n, String? code) {
  switch (code) {
    case 'store_unavailable':
    case 'products_not_configured':
      return l10n.storeUnavailableMessage;
    case 'purchase_failed':
    case 'billing_error':
      return l10n.errorPurchaseFailed;
    case 'no_active_subscription':
      return l10n.restoreNoPurchasesFound;
    case 'pro_trip_limit_reached':
      return l10n.proTripLimitSubtitle;
    case 'restricted_trip_create':
    case 'restricted_expense_add':
      return l10n.adminFeatureRestrictedNotice;
    case 'checklist_load_failed':
      return l10n.errorChecklistLoadFailed;
    case 'activity_save_failed':
      return l10n.activitySaveFailed;
    default:
      return l10n.errorGenericRetry;
  }
}
