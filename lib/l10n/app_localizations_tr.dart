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
  String get syncInProgress => 'Eşitleniyor...';

  @override
  String get syncUpToDate => 'Güncel';

  @override
  String get syncFailed => 'Eşitleme Hatası';

  @override
  String get multiCurrency => 'Çoklu Para Birimi';

  @override
  String get trips => 'Seyahatler';

  @override
  String get addTrip => 'Seyahat Ekle';

  @override
  String get tripName => 'Seyahat Adı';

  @override
  String get destination => 'Hedef';

  @override
  String get remaining => 'Kalan';

  @override
  String get spent => 'Harcanan';

  @override
  String get addExpense => 'Harcama Ekle';

  @override
  String get amount => 'Tutar';

  @override
  String get category => 'Kategori';

  @override
  String get food => 'Yemek';

  @override
  String get transport => 'Ulaşım';

  @override
  String get accommodation => 'Konaklama';

  @override
  String get entertainment => 'Eğlence';

  @override
  String get other => 'Diğer';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get date => 'Tarih';

  @override
  String get startDate => 'Başlangıç Tarihi';

  @override
  String get endDate => 'Bitiş Tarihi';

  @override
  String get noTripsYet => 'Henüz planlanmış seyahat yok';

  @override
  String get noTripsSubtitle =>
      'İlk seyahatinizi eklemek için aşağıdaki butona dokunun';

  @override
  String get noExpensesYet => 'Henüz harcama kaydedilmedi';

  @override
  String get noExpensesSubtitle =>
      'Harcama ekleyerek bütçenizi takip etmeye başlayın';

  @override
  String get deleteTrip => 'Seyahati Sil';

  @override
  String get deleteTripConfirm =>
      'Bu seyahati silmek istediğinizden emin misiniz?';

  @override
  String get deleteExpense => 'Harcamayı Sil';

  @override
  String get architecturePhase =>
      'Faz 3: Bütçe, Seyahat ve Harcama Yönetimi Hazır';
}
