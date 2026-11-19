import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/app_widget_localization.dart';
import 'package:packbuddy/core/services/legal_consent_localization.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/features/budget/domain/budget_localization.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_localization.dart';
import 'package:packbuddy/features/help/data/faq_data.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/vault/domain/vault_localization.dart';

void main() {
  const allLanguages = [
    'tr', 'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
  ];

  group('20-Language Localization Comprehensive Audit', () {
    test('BudgetLocalization covers all 20 languages without leaks', () {
      for (final lang in allLanguages) {
        expect(BudgetLocalization.timelineDays(lang, 2), isNotEmpty);
        expect(BudgetLocalization.peakLabel(lang, 'R\$700'), isNotEmpty);
        expect(BudgetLocalization.deepStatsCollapse(lang), isNotEmpty);
        expect(BudgetLocalization.deepStatsExplore(lang), isNotEmpty);
        expect(BudgetLocalization.formatRatioPercent(lang, 92, 8), isNotEmpty);
        expect(BudgetLocalization.cardVsCashSubtitle(lang), isNotEmpty);
        expect(BudgetLocalization.formatCategoryCount(lang, 2), isNotEmpty);
        expect(BudgetLocalization.formatTopCategory(lang, 'Food'), isNotEmpty);
        expect(BudgetLocalization.perRemainingDay(lang), isNotEmpty);
        expect(BudgetLocalization.dailyAverage(lang), isNotEmpty);
        expect(BudgetLocalization.countriesCovered(lang, 3), isNotEmpty);
        expect(BudgetLocalization.allTripDestinations(lang, 3), isNotEmpty);

        if (lang == 'pt') {
          expect(BudgetLocalization.timelineDays(lang, 2), equals('(2 dias)'));
          expect(BudgetLocalization.peakLabel(lang, 'R\$700'), equals('Pico: R\$700'));
          expect(BudgetLocalization.formatRatioPercent(lang, 92, 8), equals('92% / 8%'));
          expect(BudgetLocalization.cardVsCashSubtitle(lang), equals('Cartão / Dinheiro'));
          expect(BudgetLocalization.formatCategoryCount(lang, 2), equals('2 categorias'));
          expect(BudgetLocalization.perRemainingDay(lang), equals('Por dia restante'));
          expect(BudgetLocalization.dailyAverage(lang), equals('Média diária'));
          expect(BudgetLocalization.countriesCovered(lang, 2), equals('2 países cobertos'));
          expect(BudgetLocalization.allTripDestinations(lang, 2), equals('Todos os destinos da viagem (2)'));
        }

        if (lang != 'tr') {
          // Verify no Turkish text leaks in other languages
          expect(BudgetLocalization.timelineDays(lang, 2).contains('gün'), isFalse);
          expect(BudgetLocalization.peakLabel(lang, '100').startsWith('Zirve:'), isFalse);
          expect(BudgetLocalization.cardVsCashSubtitle(lang).contains('Nakit'), isFalse);
          expect(BudgetLocalization.perRemainingDay(lang).contains('Kalan'), isFalse);
          expect(BudgetLocalization.dailyAverage(lang).contains('Günlük'), isFalse);
        }
      }
    });

    test('ItineraryLocalization covers all 20 languages without leaks', () {
      const categories = ['food', 'transit', 'activity', 'lodging', 'shopping', 'sightseeing'];
      for (final lang in allLanguages) {
        for (final cat in categories) {
          expect(ItineraryLocalization.getCategoryLabel(lang, cat), isNotEmpty);
        }
        expect(ItineraryLocalization.getActivityTitleHint(lang), isNotEmpty);
        expect(ItineraryLocalization.getLocationHint(lang), isNotEmpty);
        expect(ItineraryLocalization.getCostHint(lang), isNotEmpty);
        expect(ItineraryLocalization.getNotesHint(lang), isNotEmpty);
        expect(ItineraryLocalization.completedBadge(lang, 3, 5), isNotEmpty);
        expect(ItineraryLocalization.itinerarySubtitle(lang, 5, 3), isNotEmpty);

        if (lang == 'pt') {
          expect(ItineraryLocalization.completedBadge(lang, 3, 5), equals('3 / 5 concluídos'));
          expect(ItineraryLocalization.itinerarySubtitle(lang, 5, 3), equals('5 atividades planejadas (3 concluídas)'));
        }

        if (lang != 'tr') {
          expect(ItineraryLocalization.completedBadge(lang, 3, 5).contains('tamamlandı'), isFalse);
          expect(ItineraryLocalization.itinerarySubtitle(lang, 5, 3).contains('planlandı'), isFalse);
        }
      }
    });

    test('ConnectivityLocalization covers all 20 languages without leaks', () {
      for (final lang in allLanguages) {
        expect(ConnectivityLocalization.getPendingChangesSummary(lang, 4), isNotEmpty);
        expect(ConnectivityLocalization.tripsCountLabel(lang, 2), isNotEmpty);
        expect(ConnectivityLocalization.itemsCountLabel(lang, 5), isNotEmpty);
        expect(ConnectivityLocalization.expensesCountLabel(lang, 3), isNotEmpty);
        expect(ConnectivityLocalization.documentsCountLabel(lang, 1), isNotEmpty);
        expect(ConnectivityLocalization.itemsSyncedSuccess(lang, 3), isNotEmpty);
        expect(ConnectivityLocalization.neverSynced(lang), isNotEmpty);

        for (final status in ['synced', 'syncing', 'offline', 'error', 'pending']) {
          expect(ConnectivityLocalization.syncStatusTitle(lang, status), isNotEmpty);
        }

        if (lang == 'pt') {
          expect(ConnectivityLocalization.neverSynced(lang), equals('Nunca sincronizado'));
          expect(ConnectivityLocalization.syncStatusTitle(lang, 'upToDate'), equals('Sincronização bem-sucedida'));
        }

        if (lang != 'tr') {
          expect(ConnectivityLocalization.neverSynced(lang).contains('Henüz yapılmadı'), isFalse);
        }
      }
    });

    test('HelpLocalization FAQ covers all 20 languages without leaks', () {
      for (final lang in allLanguages) {
        expect(FaqData.allItems.length, equals(14));
        for (final item in FaqData.allItems) {
          final q = HelpLocalization.getQuestion(item.id, lang);
          final a = HelpLocalization.getAnswer(item.id, lang);
          expect(q, isNotEmpty);
          expect(a, isNotEmpty);
          if (lang != 'tr') {
            // Verify no Turkish words leak in FAQ questions for foreign languages
            expect(q.contains('Nasıl'), isFalse, reason: 'Failed for lang: $lang, id: ${item.id}');
            expect(q.contains('Nedir'), isFalse, reason: 'Failed for lang: $lang, id: ${item.id}');
            expect(q.contains('mıyım'), isFalse, reason: 'Failed for lang: $lang, id: ${item.id}');
          }
        }
      }
    });

    test('AirlineFarePackage & AirlineBaggageRule covers all 20 languages', () {
      const pkg = AirlineFarePackage(
        id: 'test_pkg',
        name: 'Saver',
        cabinLimitKg: 8,
        cabinDimensions: '55x40x23 cm',
        personalItemLimitKg: 4,
        personalItemDimensions: '40x30x15 cm',
        checkedLimitKg: 20,
        description: 'Standart ekonomi paketi',
      );

      for (final lang in allLanguages) {
        final desc = pkg.getLocalizedDescription(lang);
        expect(desc, isNotEmpty);
        if (lang == 'pt') {
          expect(desc.contains('Pessoal'), isTrue);
          expect(desc.contains('Cabine'), isTrue);
          expect(desc.contains('Porão'), isTrue);
        } else if (lang == 'es') {
          expect(desc.contains('Personal'), isTrue);
          expect(desc.contains('Cabina'), isTrue);
          expect(desc.contains('Facturado'), isTrue);
        } else if (lang == 'de') {
          expect(desc.contains('Handgepäck'), isTrue);
          expect(desc.contains('Aufgabegepäck'), isTrue);
        } else if (lang == 'fr') {
          expect(desc.contains('Cabine'), isTrue);
          expect(desc.contains('En soute'), isTrue);
        }
      }
    });

    test('DashboardLocalization covers notification badges across all 20 languages', () {
      for (final lang in allLanguages) {
        expect(DashboardLocalization.adminBadge(lang), isNotEmpty);
        expect(DashboardLocalization.discountBadge(lang, 20), isNotEmpty);
        expect(DashboardLocalization.dealBadge(lang), isNotEmpty);
        expect(DashboardLocalization.noticeBadge(lang), isNotEmpty);
        expect(DashboardLocalization.viewOffer(lang), isNotEmpty);

        if (lang == 'pt') {
          expect(DashboardLocalization.adminBadge(lang), equals('Admin'));
          expect(DashboardLocalization.discountBadge(lang, 20), equals('20% DESCONTO'));
          expect(DashboardLocalization.dealBadge(lang), equals('Oferta'));
          expect(DashboardLocalization.noticeBadge(lang), equals('Aviso'));
          expect(DashboardLocalization.viewOffer(lang), equals('Ver oferta →'));
        }

        if (lang != 'tr') {
          expect(DashboardLocalization.viewOffer(lang).contains('Fırsatı İncele'), isFalse);
          expect(DashboardLocalization.noticeBadge(lang).contains('Duyuru'), isFalse);
        }
      }
    });

    test('VaultLocalization covers all 20 languages without leaks', () {
      for (final lang in allLanguages) {
        expect(VaultLocalization.reloadFromCloud(lang), isNotEmpty);
        expect(VaultLocalization.imageLoadFailed(lang), isNotEmpty);
        expect(VaultLocalization.reloadCloud(lang), isNotEmpty);

        if (lang == 'pt') {
          expect(VaultLocalization.reloadFromCloud(lang), equals('Recarregar da nuvem'));
          expect(VaultLocalization.imageLoadFailed(lang), equals('Não foi possível carregar a imagem'));
          expect(VaultLocalization.reloadCloud(lang), equals('Baixar da nuvem'));
        }

        if (lang != 'tr') {
          expect(VaultLocalization.reloadFromCloud(lang).contains('Buluttan'), isFalse);
          expect(VaultLocalization.imageLoadFailed(lang).contains('yüklenemedi'), isFalse);
        }
      }
    });

    test('LegalConsentLocalization covers all 20 languages', () {
      for (final lang in allLanguages) {
        expect(LegalConsentLocalization.getAcceptedStatus(lang, '1.4', null), isNotEmpty);
        expect(LegalConsentLocalization.getCloseButton(lang), isNotEmpty);

        if (lang == 'pt') {
          expect(LegalConsentLocalization.getAcceptedStatus(lang, '1.4', null), equals('Termo aceito: Versão 1.4'));
          expect(LegalConsentLocalization.getCloseButton(lang), equals('Fechar'));
        }

        if (lang != 'tr') {
          expect(LegalConsentLocalization.getAcceptedStatus(lang, '1.4', null).contains('Sözleşme Onaylandı'), isFalse);
        }
      }
    });

    test('AppDateFormatter.formatRelativeTime covers all 20 languages', () {
      final now = DateTime.now();
      for (final lang in allLanguages) {
        expect(AppDateFormatter.formatRelativeTime(now.subtract(const Duration(minutes: 5)), locale: lang), isNotEmpty);
        expect(AppDateFormatter.formatRelativeTime(now.subtract(const Duration(hours: 3)), locale: lang), isNotEmpty);
        expect(AppDateFormatter.formatRelativeTime(now.subtract(const Duration(days: 4)), locale: lang), isNotEmpty);

        if (lang != 'tr' && lang != 'en') {
          final res = AppDateFormatter.formatRelativeTime(now.subtract(const Duration(minutes: 5)), locale: lang);
          expect(res.contains('önce'), isFalse);
        }
      }
    });

    test('PackingTagHelper covers all 20 languages', () {
      for (final lang in allLanguages) {
        expect(PackingTagHelper.getLocalizedTag('CARRY_ON', lang), isNotEmpty);
        expect(PackingTagHelper.getLocalizedTag('CHECK_IN', lang), isNotEmpty);
        expect(PackingTagHelper.getLocalizedTag('ESSENTIAL', lang), isNotEmpty);

        if (lang == 'pt') {
          expect(PackingTagHelper.getLocalizedTag('CARRY_ON', lang), equals('Bagagem de Mão'));
          expect(PackingTagHelper.getLocalizedTag('CHECK_IN', lang), equals('Bagagem de Porão'));
          expect(PackingTagHelper.getLocalizedTag('ESSENTIAL', lang), equals('Essencial / Sempre comigo'));
        }

        if (lang != 'tr') {
          expect(PackingTagHelper.getLocalizedTag('CARRY_ON', lang).contains('Kabin Bagajı'), isFalse);
          expect(PackingTagHelper.getLocalizedTag('CHECK_IN', lang).contains('Uçak Altı'), isFalse);
        }
      }
    });

    test('AppWidgetLocalization covers all 20 languages', () {
      for (final lang in allLanguages) {
        expect(AppWidgetLocalization.getDefaultTripTitle(lang), isNotEmpty);
        expect(AppWidgetLocalization.getAddAction(lang), isNotEmpty);

        if (lang == 'pt') {
          expect(AppWidgetLocalization.getDefaultTripTitle(lang), equals('Viagem a Roma'));
          expect(AppWidgetLocalization.getAddAction(lang), equals('+ Adicionar'));
        }

        if (lang != 'tr') {
          expect(AppWidgetLocalization.getDefaultTripTitle(lang).contains('Roma Tatili'), isFalse);
          expect(AppWidgetLocalization.getAddAction(lang).contains('Ekle'), isFalse);
        }
      }
    });
  });
}
