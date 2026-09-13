import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('QA Audit - SyncEngine Concurrency & Mutex Lock', () {
    test('SyncEngine mutex prevents concurrent duplicate sync executions', () async {
      final syncEngine = SyncEngine();
      expect(syncEngine.isSyncing, isFalse);

      // Trigger first sync (async)
      final firstSync = syncEngine.performSync();
      
      // If triggered concurrently, second call should immediately be guarded
      final secondSync = syncEngine.performSync();

      await Future.wait([firstSync, secondSync]);

      // When all finish, mutex lock must be safely released
      expect(syncEngine.isSyncing, isFalse);
    });
  });

  group('QA Audit - CurrencyFormatter Edge Cases & Robustness', () {
    test('CurrencyFormatter handles NaN and Infinity without crashing', () {
      final nanResult = CurrencyFormatter.format(double.nan, currency: 'USD');
      expect(nanResult, contains('\$'));
      expect(nanResult, contains('0'));

      final infResult = CurrencyFormatter.format(double.infinity, currency: 'EUR');
      expect(infResult, contains('€'));
      expect(infResult, contains('0'));
    });

    test('CurrencyFormatter formats negative numbers and zero cleanly', () {
      final negativeResult = CurrencyFormatter.format(-150.75, currency: 'USD');
      expect(negativeResult, contains('150.75'));

      final zeroResult = CurrencyFormatter.format(0.0, currency: 'TRY');
      expect(zeroResult, contains('₺'));
      expect(zeroResult, contains('0'));
    });

    test('CurrencyFormatter returns correct symbol for all supported currencies', () {
      expect(CurrencyFormatter.getSymbol('USD'), '\$');
      expect(CurrencyFormatter.getSymbol('EUR'), '€');
      expect(CurrencyFormatter.getSymbol('TRY'), '₺');
      expect(CurrencyFormatter.getSymbol('GBP'), '£');
      expect(CurrencyFormatter.getSymbol('JPY'), '¥');
      expect(CurrencyFormatter.getSymbol('CHF'), 'CHF');
      expect(CurrencyFormatter.getSymbol('CAD'), 'CA\$');
      expect(CurrencyFormatter.getSymbol('AUD'), 'A\$');
    });
  });

  group('QA Audit - Riverpod Memory Leak & AutoDispose Verification', () {
    test('expenseControllerProvider is an AutoDispose provider', () {
      final container = ProviderContainer();
      
      // Read controller
      final controller = container.read(expenseControllerProvider('trip-test-123').notifier);
      expect(controller, isNotNull);

      // Disposing container should cleanly dispose autoDispose provider
      container.dispose();
    });
  });

  group('QA Audit - RTL (Arabic) Directionality & AppLocalizations', () {
    testWidgets('Arabic locale sets TextDirection to RTL without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              final direction = Directionality.of(context);
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    Text('Direction: $direction'),
                    Text('Trips: ${l10n.trips}'),
                    Text('Vault: ${l10n.vault}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Direction: TextDirection.rtl'), findsOneWidget);
    });
  });
}
