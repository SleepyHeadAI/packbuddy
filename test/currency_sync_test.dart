import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/currency_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CurrencyService.resetToDefaults();
  });

  group('CurrencyService Offline-First & Online Auto-Sync Suite', () {
    test('1. Default rates are loaded offline with 30 currencies', () {
      expect(CurrencyService.supportedCurrencies.length, 30);
      expect(CurrencyService.isUsingLiveRates, isFalse);
      expect(CurrencyService.lastUpdatedAt, isNull);

      expect(CurrencyService.ratesAgainstUsd['USD'], 1.0);
      expect(CurrencyService.ratesAgainstUsd['GBP'], 0.77);
      expect(CurrencyService.ratesAgainstUsd['VND'], 25300.0);
    });

    test('2. Vietnam (VND) to UK (GBP) cross-currency conversion is accurate', () {
      // 253,000 VND should convert to exactly £7.70 GBP
      // (253,000 / 25,300 USD = 10 USD -> 10 * 0.77 GBP = 7.70 GBP)
      final gbpAmount = CurrencyService.convert(
        amount: 253000,
        fromCurrency: 'VND',
        toCurrency: 'GBP',
      );
      expect(gbpAmount, closeTo(7.70, 0.01));

      // Inverse: 7.70 GBP should convert back to 253,000 VND
      final vndAmount = CurrencyService.convert(
        amount: 7.70,
        fromCurrency: 'GBP',
        toCurrency: 'VND',
      );
      expect(vndAmount, closeTo(253000.0, 10.0));
    });

    test('3. Dynamic rates apply and mark isUsingLiveRates', () {
      CurrencyService.applyRates({
        'GBP': 0.80,
        'TRY': 36.50,
      });

      expect(CurrencyService.isUsingLiveRates, isTrue);
      expect(CurrencyService.lastUpdatedAt, isNotNull);
      expect(CurrencyService.ratesAgainstUsd['GBP'], 0.80);
      expect(CurrencyService.ratesAgainstUsd['TRY'], 36.50);

      // Reset works
      CurrencyService.resetToDefaults();
      expect(CurrencyService.isUsingLiveRates, isFalse);
      expect(CurrencyService.ratesAgainstUsd['GBP'], 0.77);
    });

    test('4. init() loads cached rates from SharedPreferences', () async {
      final cachedRates = {
        'GBP': 0.75,
        'EUR': 0.90,
      };
      final updateTime = DateTime(2026, 10, 1, 12, 0);

      SharedPreferences.setMockInitialValues({
        'packbuddy_cached_currency_rates': jsonEncode(cachedRates),
        'packbuddy_currency_rates_last_updated': updateTime.millisecondsSinceEpoch,
      });

      await CurrencyService.init();

      expect(CurrencyService.isUsingLiveRates, isTrue);
      expect(CurrencyService.ratesAgainstUsd['GBP'], 0.75);
      expect(CurrencyService.ratesAgainstUsd['EUR'], 0.90);
      expect(CurrencyService.lastUpdatedAt?.millisecondsSinceEpoch, updateTime.millisecondsSinceEpoch);
    });

    test('5. syncRates handles offline / unreachable network gracefully without throwing', () async {
      // Trying to sync to an unreachable loopback port should quietly return false
      final result = await CurrencyService.syncRates(
        force: true,
        overrideUrl: 'http://127.0.0.1:54321/offline_endpoint',
      );

      expect(result, isFalse);
      // Rates remain intact with resilient offline fallback
      expect(CurrencyService.ratesAgainstUsd['USD'], 1.0);
      expect(CurrencyService.ratesAgainstUsd['GBP'], 0.77);
    });

    test('6. syncRates respects throttling maxAge', () async {
      CurrencyService.applyRates({'GBP': 0.77}, updatedAt: DateTime.now());

      // Since last update is right now, syncRates without force should skip immediately
      final skipped = await CurrencyService.syncRates(force: false);
      expect(skipped, isFalse);
    });
  });
}
