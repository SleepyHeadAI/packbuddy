import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/add_document_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('AddDocumentSheet Subcategory Collapsible & Optional Tests', () {
    testWidgets('Subcategory starts collapsed and optional (null by default)', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: AddDocumentSheet(
                initialCategory: 'Ticket',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Main category should be Ticket (Biletler)
      expect(find.text('Biletler'), findsWidgets);

      // Compact header should display the optional title and "Genel / Belirtilmemiş" hint
      expect(find.textContaining('Bilet Türü / Alt Kategori (Opsiyonel)'), findsOneWidget);
      expect(find.text('Genel / Belirtilmemiş'), findsOneWidget);

      // The 5 subcategory ChoiceChips should not be visible when collapsed
      expect(find.widgetWithText(ChoiceChip, 'Uçak Bileti'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Otobüs Bileti'), findsNothing);

      // Tap header to expand downwards
      await tester.tap(find.textContaining('Bilet Türü / Alt Kategori (Opsiyonel)'));
      await tester.pumpAndSettle();

      // Now the choice chips should be visible
      expect(find.widgetWithText(ChoiceChip, 'Uçak Bileti'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Otobüs Bileti'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Tren Bileti'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Gemi / Feribot Bileti'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Diğer Ulaşım'), findsOneWidget);

      // Select 'Uçak Bileti'
      await tester.tap(find.widgetWithText(ChoiceChip, 'Uçak Bileti'));
      await tester.pumpAndSettle();

      // Header should now show the selected badge with close icon
      expect(find.byKey(const Key('clear_subcategory_button')), findsOneWidget);

      // Tap clear/close icon on badge to make it null again
      await tester.tap(find.byKey(const Key('clear_subcategory_button')));
      await tester.pumpAndSettle();

      // General / Unspecified option should now be active again
      final noneChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Genel / Belirtilmemiş'));
      expect(noneChip.selected, isTrue);
    });

    testWidgets('Subcategory works in English locale with optional indicators', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(
              body: AddDocumentSheet(
                initialCategory: 'Ticket',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Ticket Type / Sub-Category (Optional)'), findsOneWidget);
      expect(find.text('General / Unspecified'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.textContaining('Ticket Type / Sub-Category (Optional)'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'Flight Ticket'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Bus Ticket'), findsOneWidget);

      // Select Bus Ticket
      await tester.tap(find.widgetWithText(ChoiceChip, 'Bus Ticket'));
      await tester.pumpAndSettle();

      // Tap General / Unspecified to clear selection
      await tester.tap(find.widgetWithText(ChoiceChip, 'General / Unspecified'));
      await tester.pumpAndSettle();

      final generalChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'General / Unspecified'));
      expect(generalChip.selected, isTrue);
    });
  });
}
