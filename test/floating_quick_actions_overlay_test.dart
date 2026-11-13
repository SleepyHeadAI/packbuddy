import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  Widget buildTestApp({required Widget home}) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: home,
      ),
    );
  }

  testWidgets('QuickActionsSheet.show opens blurred overlay with floating bubbles and rotating yellow button', (tester) async {
    bool tripTapped = false;
    bool expenseTapped = false;

    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                key: const Key('home_fab'),
                onPressed: () {
                  QuickActionsSheet.show(
                    context,
                    title: 'Hızlı İşlemler',
                    items: [
                      QuickActionItem(
                        icon: Icons.flight_takeoff_rounded,
                        iconColor: Colors.amber,
                        iconBgColor: Colors.amber.withValues(alpha: 0.15),
                        title: 'Seyahat Ekle',
                        onTap: () => tripTapped = true,
                      ),
                      QuickActionItem(
                        icon: Icons.receipt_long_rounded,
                        iconColor: Colors.green,
                        iconBgColor: Colors.green.withValues(alpha: 0.15),
                        title: 'Harcama Ekle',
                        onTap: () => expenseTapped = true,
                      ),
                    ],
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: const Center(child: Text('PackBuddy Test Screen')),
            );
          },
        ),
      ),
    );

    // Initial state: FAB is present, overlay is not present
    expect(find.byKey(const Key('home_fab')), findsOneWidget);
    expect(find.text('Seyahat Ekle'), findsNothing);
    expect(find.byKey(const Key('quick_actions_fab_close')), findsNothing);

    // Tap the FAB to open overlay
    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify BackdropFilter (Gaussian blur) is present
    expect(find.byType(BackdropFilter), findsWidgets);

    // Verify rotating yellow close button is present
    expect(find.byKey(const Key('quick_actions_fab_close')), findsOneWidget);

    // Verify floating action bubbles are rendered with their titles
    expect(find.text('Seyahat Ekle'), findsOneWidget);
    expect(find.text('Harcama Ekle'), findsOneWidget);

    // Tap "Harcama Ekle" bubble
    await tester.tap(find.text('Harcama Ekle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify action was executed and overlay was closed
    expect(expenseTapped, isTrue);
    expect(tripTapped, isFalse);
    expect(find.byKey(const Key('quick_actions_fab_close')), findsNothing);
  });

  testWidgets('Tapping yellow close button dismisses floating actions overlay', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                key: const Key('home_fab'),
                onPressed: () {
                  QuickActionsSheet.show(
                    context,
                    title: 'Hızlı İşlemler',
                    items: [
                      QuickActionItem(
                        icon: Icons.flight_takeoff_rounded,
                        iconColor: Colors.amber,
                        iconBgColor: Colors.amber.withValues(alpha: 0.15),
                        title: 'Seyahat Ekle',
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: const Center(child: Text('Content')),
            );
          },
        ),
      ),
    );

    // Open overlay
    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick_actions_fab_close')), findsOneWidget);
    expect(find.text('Seyahat Ekle'), findsOneWidget);

    // Tap the close button
    await tester.tap(find.byKey(const Key('quick_actions_fab_close')));
    await tester.pumpAndSettle();

    // Verify overlay is dismissed
    expect(find.byKey(const Key('quick_actions_fab_close')), findsNothing);
    expect(find.text('Seyahat Ekle'), findsNothing);
  });

  testWidgets('Tapping blurred background dismisses floating actions overlay', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                key: const Key('home_fab'),
                onPressed: () {
                  QuickActionsSheet.show(
                    context,
                    title: 'Hızlı İşlemler',
                    items: [
                      QuickActionItem(
                        icon: Icons.luggage_rounded,
                        iconColor: Colors.blue,
                        iconBgColor: Colors.blue.withValues(alpha: 0.15),
                        title: 'Eşya Ekle',
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: const Center(child: Text('Content')),
            );
          },
        ),
      ),
    );

    // Open overlay
    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pumpAndSettle();

    expect(find.text('Eşya Ekle'), findsOneWidget);

    // Tap the top-left area (blurred backdrop)
    await tester.tapAt(const Offset(50, 50));
    await tester.pumpAndSettle();

    // Verify overlay is dismissed
    expect(find.text('Eşya Ekle'), findsNothing);
    expect(find.byKey(const Key('quick_actions_fab_close')), findsNothing);
  });

  testWidgets('QuickActionsSheet.showForDashboard displays all 4 action bubbles', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Consumer(
          builder: (context, ref, _) {
            final fabKey = GlobalKey();
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                key: fabKey,
                onPressed: () {
                  QuickActionsSheet.showForDashboard(
                    context,
                    ref: ref,
                    fabKey: fabKey,
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: const Center(child: Text('Dashboard')),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify BackdropFilter blur
    expect(find.byType(BackdropFilter), findsWidgets);
    expect(find.byKey(const Key('quick_actions_fab_close')), findsOneWidget);

    // Verify all 4 floating action bubbles are visible (in Turkish: Seyahat Ekle, Harcama Ekle, Eşya Ekle, Belge Ekle)
    expect(find.text('Seyahat Ekle'), findsOneWidget);
    expect(find.text('Harcama Ekle'), findsOneWidget);
    expect(find.text('Eşya Ekle'), findsOneWidget);
    expect(find.text('Belge Ekle'), findsOneWidget);

    // Tap yellow close button
    await tester.tap(find.byKey(const Key('quick_actions_fab_close')));
    await tester.pumpAndSettle();

    expect(find.text('Seyahat Ekle'), findsNothing);
    expect(find.byKey(const Key('quick_actions_fab_close')), findsNothing);
  });
}
