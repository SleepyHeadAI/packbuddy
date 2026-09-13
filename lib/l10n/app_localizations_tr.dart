// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'PackBuddy';

  @override
  String get welcome => 'PackBuddy\'ye Hoş Geldiniz';

  @override
  String get welcomeSubtitle =>
      'Minimalist, offline-first seyahat asistanı ve bütçe yöneticisi';

  @override
  String get budget => 'Bütçe';

  @override
  String get budgetDescription => 'Çoklu para birimli seyahat harcama takibi';

  @override
  String get vault => 'Belge Kasası';

  @override
  String get vaultDescription => 'Pasaport, bilet ve rezervasyon belgeleri';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsDescription =>
      'Tercihler, yedekleme ve senkronizasyon ayarları';

  @override
  String get offlineReady => 'Çevrimdışı Hazır';

  @override
  String get syncReady => 'Çift Yönlü Bulut Senkronizasyonu';

  @override
  String get multiCurrency => 'Çoklu Para Birimi';

  @override
  String get architecturePhase => 'Faz 1: Mimari ve İzin Altyapısı Hazır';
}
