import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/packing_item_tile.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/checklist/domain/packing_templates.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController([VaultState? state]) : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PackingItem Domain Tests (Weight-Free Architecture)', () {
    test('Serializes toMap and deserializes fromMap accurately without weight fields', () {
      final item = PackingItem(
        id: 'test-item-1',
        name: 'Noise-Cancelling Headphones',
        category: 'Elektronik',
        quantity: 2,
        isPacked: true,
        tag: 'CABIN ONLY',
        compartment: 'Sırt Çantası',
        createdAt: DateTime(2026, 9, 14, 12, 0),
        updatedAt: DateTime(2026, 9, 14, 12, 30),
      );

      final map = item.toMap();
      expect(map['id'], 'test-item-1');
      expect(map['quantity'], 2);
      expect(map['is_packed'], 1);
      expect(map['tag'], 'CABIN ONLY');
      expect(map.containsKey('weight_kg'), isFalse);

      final reconstructed = PackingItem.fromMap(map);
      expect(reconstructed, equals(item));
      expect(reconstructed.quantity, 2);
      expect(reconstructed.isPacked, isTrue);
    });

    test('copyWith properly preserves or updates fields', () {
      final original = PackingItem(
        id: 'item-2',
        name: 'Rain Jacket',
        category: 'Kıyafet',
        quantity: 1,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(quantity: 3, isPacked: true);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.quantity, 3);
      expect(updated.isPacked, true);
    });
  });

  group('ChecklistState & Reactive Item Completion Calculations', () {
    test('Calculates item completion counts and ratio without weight dependencies', () {
      final item1 = PackingItem(
        id: '1',
        name: 'Universal Adapter',
        category: 'Elektronik',
        quantity: 2,
        isPacked: true,
        compartment: 'Sırt Çantası',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final item2 = PackingItem(
        id: '2',
        name: 'Heavy Boots',
        category: 'Kıyafet',
        quantity: 1,
        isPacked: false,
        compartment: 'Ana Bölme',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = ChecklistState(
        items: [item1, item2],
      );

      expect(state.packedCount, 1);
      expect(state.totalCount, 2);
      expect(state.completionRatio, 0.5);
    });

    test('Calculates 100% completion ratio when all items are packed', () {
      final item1 = PackingItem(
        id: '1',
        name: 'Passport',
        category: 'Belgeler',
        isPacked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final item2 = PackingItem(
        id: '2',
        name: 'Wallet',
        category: 'Belgeler',
        isPacked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = ChecklistState(items: [item1, item2]);
      expect(state.packedCount, 2);
      expect(state.totalCount, 2);
      expect(state.completionRatio, 1.0);
    });

    test('Search query matches item name, tag, or category correctly', () {
      final item1 = PackingItem(
        id: '1',
        name: 'Noise-Cancelling Headphones',
        category: 'Elektronik',
        tag: 'CABIN ONLY',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final item2 = PackingItem(
        id: '2',
        name: 'Raincoat',
        category: 'Kıyafet',
        tag: 'CARRY-ON',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = ChecklistState(items: [item1, item2], searchQuery: 'headphones');
      expect(state.filteredItems.length, 1);
      expect(state.filteredItems.first.name, contains('Headphones'));

      final tagSearch = ChecklistState(items: [item1, item2], searchQuery: 'carry');
      expect(tagSearch.filteredItems.length, 1);
      expect(tagSearch.filteredItems.first.tag, 'CARRY-ON');
    });

    test('importTemplate retains packed items while clearing unselected/unpacked items from previous templates', () async {
      final packedItem = PackingItem(
        id: 'p1',
        name: 'Güneş Gözlüğü',
        category: 'Aksesuar',
        quantity: 1,
        isPacked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final unpackedItem = PackingItem(
        id: 'u1',
        name: 'Mayo',
        category: 'Kıyafet',
        quantity: 1,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final notifier = ChecklistNotifier(
        null,
        ChecklistState(items: [packedItem, unpackedItem]),
      );

      final winterTemplate = const PackingTemplate(
        id: 'winter',
        title: 'Kış Tatili',
        description: 'Soğuk hava tatili',
        emoji: '❄️',
        items: [
          PackingItemTemplate(name: 'Termal Mont', category: 'Kıyafet', quantity: 1),
          PackingItemTemplate(name: 'Yün Bere', category: 'Aksesuar', quantity: 1),
        ],
      );

      await notifier.importTemplate(winterTemplate);

      final itemNames = notifier.state.items.map((i) => i.name).toList();

      // Packed item must be preserved
      expect(itemNames, contains('Güneş Gözlüğü'));
      expect(notifier.state.items.firstWhere((i) => i.name == 'Güneş Gözlüğü').isPacked, isTrue);

      // Unpacked item from previous template must be cleared
      expect(itemNames, isNot(contains('Mayo')));

      // New template items must be added
      expect(itemNames, contains('Termal Mont'));
      expect(itemNames, contains('Yün Bere'));
    });
  });

  group('Widget & Accessibility Tests', () {
    testWidgets('PackingItemTile stepper buttons satisfy minimum 44x44 dp accessibility touch target', (tester) async {
      final item = PackingItem(
        id: 'test-stepper',
        name: 'Noise-Cancelling Headphones with Long Product Title That Wraps Nicely',
        category: 'Elektronik',
        quantity: 1,
        isPacked: false,
        tag: 'CABIN ONLY',
        compartment: 'Sırt Çantası',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: PackingItemTile(
              item: item,
              onTogglePacked: () {},
              onUpdateQuantity: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find decrement and increment buttons
      final removeIcon = find.byIcon(Icons.remove_rounded);
      final addIcon = find.byIcon(Icons.add_rounded);

      expect(removeIcon, findsOneWidget);
      expect(addIcon, findsOneWidget);

      // Check size of touch targets
      final removeBox = tester.getSize(find.ancestor(
        of: removeIcon,
        matching: find.byType(ConstrainedBox),
      ).first);

      final addBox = tester.getSize(find.ancestor(
        of: addIcon,
        matching: find.byType(ConstrainedBox),
      ).first);

      expect(removeBox.width, greaterThanOrEqualTo(44.0));
      expect(removeBox.height, greaterThanOrEqualTo(44.0));
      expect(addBox.width, greaterThanOrEqualTo(44.0));
      expect(addBox.height, greaterThanOrEqualTo(44.0));

      // Verify category is displayed as subtitle while carry tags and compartments are absent
      expect(find.text('Elektronik'), findsOneWidget);
      expect(find.text('CABIN ONLY'), findsNothing);
      expect(find.text('Sırt Çantası'), findsNothing);
    });

    testWidgets('ChecklistScreen renders Packing Progress and search bar without overflow', (tester) async {
      final sampleItem = PackingItem(
        id: 'c1',
        name: 'Noise-Cancelling Headphones',
        category: 'Elektronik',
        quantity: 1,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checklistControllerProvider.overrideWith(
              (ref) => ChecklistNotifier(
                null,
                ChecklistState(
                  isLoading: false,
                  items: [sampleItem],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: ChecklistScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify header, dynamic luggage guide, and item are present
      expect(find.text('Bavul & Kontrol Listesi'), findsWidgets);
      expect(find.text('Bavul Hazırlığı & Bagaj Rehberi'), findsOneWidget);
      expect(find.text('Noise-Cancelling Headphones'), findsOneWidget);

      // Verify top-right add button is removed while bottom-right FAB remains
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify compartment breakdown bar is completely removed
      expect(find.textContaining('Bölme Dağılımı'), findsNothing);
    });

    testWidgets('DashboardScreen renders live luggage card and profile top bar without overflow', (tester) async {
      final sampleItem = PackingItem(
        id: 'd1',
        name: 'Passports & Flight Tickets',
        category: 'Belgeler',
        quantity: 1,
        isPacked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checklistControllerProvider.overrideWith(
              (ref) => ChecklistNotifier(
                null,
                ChecklistState(
                  isLoading: false,
                  items: [sampleItem],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify aligned top bar elements
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify luggage bento card renders
      expect(find.text('Bavul & Kontrol Listesi'), findsWidgets);
    });

    testWidgets('VaultScreen renders and displays Native Wallet hooks for tickets', (tester) async {
      final ticketDoc = Document(
        id: 'ticket-1',
        title: 'Istanbul - Paris Flight Pass',
        category: 'Ticket',
        localImagePath: '/dummy/ticket.pdf',
        fileType: 'pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(VaultState(isLoading: false, documents: [ticketDoc])),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify Vault screen and Wallet hook icon are present on the ticket card
      expect(find.byType(VaultScreen), findsOneWidget);
      expect(find.byIcon(Icons.wallet_rounded), findsWidgets);
    });
  });
}
