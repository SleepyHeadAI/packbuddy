import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/add_activity_sheet.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/day_timeline_card.dart';

void main() {
  group('ItineraryItem Model Tests', () {
    test('ItineraryItem serializes and deserializes correctly with dual time', () {
      final now = DateTime(2026, 7, 10, 14, 0);
      final item = ItineraryItem(
        id: 'itin_001',
        userId: 'user_xyz',
        tripId: 'trip_rome',
        dayNumber: 2,
        date: '2026-07-11',
        time: '08:13',
        endTime: '09:37',
        title: 'Colosseum Guided Tour',
        description: 'Meet guide at gate 3 with voucher',
        location: 'Piazza del Colosseo, 1, Roma',
        category: 'sightseeing',
        cost: 45.0,
        currency: 'EUR',
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.formattedTimeRange, equals('08:13 - 09:37'));

      final map = item.toMap();
      final fromMap = ItineraryItem.fromMap(map);

      expect(fromMap.id, equals('itin_001'));
      expect(fromMap.userId, equals('user_xyz'));
      expect(fromMap.tripId, equals('trip_rome'));
      expect(fromMap.dayNumber, equals(2));
      expect(fromMap.date, equals('2026-07-11'));
      expect(fromMap.time, equals('08:13'));
      expect(fromMap.endTime, equals('09:37'));
      expect(fromMap.formattedTimeRange, equals('08:13 - 09:37'));
      expect(fromMap.title, equals('Colosseum Guided Tour'));
      expect(fromMap.location, equals('Piazza del Colosseo, 1, Roma'));
      expect(fromMap.category, equals('sightseeing'));
      expect(fromMap.cost, equals(45.0));
      expect(fromMap.currency, equals('EUR'));
      expect(fromMap.isCompleted, isTrue);

      final jsonStr = item.toJson();
      final fromJson = ItineraryItem.fromJson(jsonStr);
      expect(fromJson.title, equals(item.title));
      expect(fromJson.time, equals('08:13'));
      expect(fromJson.endTime, equals('09:37'));
      expect(fromJson.formattedTimeRange, equals('08:13 - 09:37'));
    });

    test('ItineraryItem formattedTimeRange handles flexible return gracefully', () {
      final item = ItineraryItem(
        id: 'itin_002',
        userId: 'user_xyz',
        tripId: 'trip_rome',
        dayNumber: 1,
        date: '2026-07-10',
        time: '08:13',
        title: 'Flexible Return Trip',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Only start time set -> returns single time (flexible return)
      expect(item.formattedTimeRange, equals('08:13'));

      // With end time set -> returns range
      final withEnd = item.copyWith(endTime: '09:37');
      expect(withEnd.formattedTimeRange, equals('08:13 - 09:37'));

      // Clearing end time
      final cleared = withEnd.copyWith(clearEndTime: true);
      expect(cleared.endTime, isNull);
      expect(cleared.formattedTimeRange, equals('08:13'));
    });
  });

  group('ItineraryLocalization Tests', () {
    test('Returns non-empty strings across all 20 supported languages', () {
      final langs = [
        'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
      ];

      for (final lang in langs) {
        expect(ItineraryLocalization.getItineraryTitle(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getDay(lang, 1).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getAddActivity(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getEditActivity(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getActivityTitle(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getTime(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getStartTime(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getEndTime(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getFlexible(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getOptional(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCost(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getLocation(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategory(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getNotes(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getSave(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getDelete(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getDeleteConfirmTitle(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getDeleteConfirmMessage(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCancel(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getNoActivities(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getNoActivitiesHint(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategoryLabel('food', lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategoryLabel('sightseeing', lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategoryLabel('transit', lang).isNotEmpty, isTrue);
      }
    });
  });

  group('Itinerary UI Widget Tests', () {
    testWidgets('DayTimelineCard renders range, handles completion, edit, and delete', (tester) async {
      bool toggleCalled = false;
      bool editCalled = false;
      bool deleteCalled = false;

      final item = ItineraryItem(
        id: 'itin_003',
        userId: 'u1',
        tripId: 't1',
        dayNumber: 1,
        date: '2026-08-01',
        time: '08:13',
        endTime: '09:37',
        title: 'Disneyland Adventure',
        location: 'lantau island new territories, hongkong',
        category: 'activity',
        cost: 65.0,
        currency: 'USD',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DayTimelineCard(
              item: item,
              languageCode: 'en',
              onToggleCompleted: () {
                toggleCalled = true;
              },
              onEdit: () {
                editCalled = true;
              },
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify title and dual time range rendered
      expect(find.text('Disneyland Adventure'), findsOneWidget);
      expect(find.text('08:13 - 09:37'), findsOneWidget);
      expect(find.text('lantau island new territories, hongkong'), findsOneWidget);
      expect(find.text('65.00 USD'), findsOneWidget);

      // Verify completion toggle
      final checkbox = find.byIcon(Icons.check_box_outline_blank_rounded);
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pump();
      expect(toggleCalled, isTrue);

      // Verify edit button is present and triggers onEdit
      final editBtn = find.byIcon(Icons.edit_outlined);
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pump();
      expect(editCalled, isTrue);

      // Verify delete button is present and triggers onDelete
      final deleteBtn = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pump();
      expect(deleteCalled, isTrue);
    });

    testWidgets('ItineraryScreen renders day tabs, activities and allows editing', (tester) async {
      final trip = Trip(
        id: 'trip_japan_2026',
        title: 'Japan Summer Tour',
        destination: 'Tokyo, Kyoto, Osaka',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 5),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final items = [
        ItineraryItem(
          id: 'itin_j1',
          userId: 'u1',
          tripId: 'trip_japan_2026',
          dayNumber: 1,
          date: '2026-07-01',
          time: '14:00',
          title: 'Check-in at Shinjuku Hotel',
          category: 'lodging',
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ItineraryItem(
          id: 'itin_j2',
          userId: 'u1',
          tripId: 'trip_japan_2026',
          dayNumber: 1,
          date: '2026-07-01',
          time: '18:30',
          endTime: '20:30',
          title: 'Ramen Tasting at Omoide Yokocho',
          category: 'food',
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itineraryControllerFamily('trip_japan_2026').overrideWith((ref) {
              final controller = ItineraryController(ref, 'trip_japan_2026');
              controller.state = ItineraryState(
                tripId: 'trip_japan_2026',
                selectedDay: 1,
                totalDays: 5,
                items: items,
              );
              return controller;
            }),
          ],
          child: MaterialApp(
            home: ItineraryScreen(trip: trip),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Japan Summer Tour'), findsOneWidget);
      expect(find.text('Day 1'), findsWidgets);
      expect(find.text('Day 2'), findsOneWidget);
      expect(find.text('Check-in at Shinjuku Hotel'), findsOneWidget);
      expect(find.text('Ramen Tasting at Omoide Yokocho'), findsOneWidget);
      expect(find.text('18:30 - 20:30'), findsOneWidget);
      expect(find.text('1 / 2 completed'), findsOneWidget);

      // Ensure edit buttons exist on cards
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
    });

    testWidgets('AddActivitySheet opens in edit mode with pre-filled values', (tester) async {
      final existingItem = ItineraryItem(
        id: 'itin_edit_1',
        userId: 'u1',
        tripId: 'trip_japan_2026',
        dayNumber: 1,
        date: '2026-07-01',
        time: '08:13',
        endTime: '09:37',
        title: 'Morning Matcha & Pastry',
        location: 'Ginza Six, Tokyo',
        category: 'food',
        cost: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddActivitySheet(
                tripId: 'trip_japan_2026',
                initialDay: 1,
                totalDays: 3,
                tripStartDate: '2026-07-01',
                languageCode: 'en',
                itemToEdit: existingItem,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header says Edit Activity
      expect(find.text('Edit Activity'), findsOneWidget);

      // Check fields are prefilled
      expect(find.text('Morning Matcha & Pastry'), findsOneWidget);
      expect(find.text('08:13'), findsOneWidget);
      expect(find.text('09:37'), findsOneWidget);
      expect(find.text('Ginza Six, Tokyo'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });
  });
}
