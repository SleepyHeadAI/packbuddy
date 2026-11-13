import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/day_timeline_card.dart';

void main() {
  group('ItineraryItem Model Tests', () {
    test('ItineraryItem serializes and deserializes correctly', () {
      final now = DateTime(2026, 7, 10, 14, 0);
      final item = ItineraryItem(
        id: 'itin_001',
        userId: 'user_xyz',
        tripId: 'trip_rome',
        dayNumber: 2,
        date: '2026-07-11',
        time: '10:30',
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

      final map = item.toMap();
      final fromMap = ItineraryItem.fromMap(map);

      expect(fromMap.id, equals('itin_001'));
      expect(fromMap.userId, equals('user_xyz'));
      expect(fromMap.tripId, equals('trip_rome'));
      expect(fromMap.dayNumber, equals(2));
      expect(fromMap.date, equals('2026-07-11'));
      expect(fromMap.time, equals('10:30'));
      expect(fromMap.title, equals('Colosseum Guided Tour'));
      expect(fromMap.location, equals('Piazza del Colosseo, 1, Roma'));
      expect(fromMap.category, equals('sightseeing'));
      expect(fromMap.cost, equals(45.0));
      expect(fromMap.currency, equals('EUR'));
      expect(fromMap.isCompleted, isTrue);

      final jsonStr = item.toJson();
      final fromJson = ItineraryItem.fromJson(jsonStr);
      expect(fromJson.title, equals(item.title));
      expect(fromJson.time, equals(item.time));
    });

    test('ItineraryItem copyWith works as expected', () {
      final item = ItineraryItem(
        id: 'itin_002',
        userId: 'user_xyz',
        tripId: 'trip_rome',
        dayNumber: 1,
        date: '2026-07-10',
        title: 'Dinner at Trastevere',
        category: 'food',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = item.copyWith(
        isCompleted: true,
        time: '20:00',
        cost: 60.0,
      );

      expect(updated.id, equals('itin_002'));
      expect(updated.isCompleted, isTrue);
      expect(updated.time, equals('20:00'));
      expect(updated.cost, equals(60.0));
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
        expect(ItineraryLocalization.getLocation(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategory(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getNotes(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getSave(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getDelete(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getNoActivities(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getNoActivitiesHint(lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategoryLabel('food', lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategoryLabel('sightseeing', lang).isNotEmpty, isTrue);
        expect(ItineraryLocalization.getCategoryLabel('transit', lang).isNotEmpty, isTrue);
      }
    });
  });

  group('Itinerary UI Widget Tests', () {
    testWidgets('DayTimelineCard renders details and handles completion toggle', (tester) async {
      bool toggleCalled = false;
      bool deleteCalled = false;

      final item = ItineraryItem(
        id: 'itin_003',
        userId: 'u1',
        tripId: 't1',
        dayNumber: 1,
        date: '2026-08-01',
        time: '09:00',
        title: 'Morning Espresso & Croissant',
        location: 'Caffè Sant’Eustachio',
        category: 'food',
        cost: 6.50,
        currency: 'EUR',
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
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Morning Espresso & Croissant'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('Caffè Sant’Eustachio'), findsOneWidget);
      expect(find.text('6.50 EUR'), findsOneWidget);

      final checkbox = find.byIcon(Icons.check_box_outline_blank_rounded);
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pump();
      expect(toggleCalled, isTrue);

      final deleteBtn = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pump();
      expect(deleteCalled, isTrue);
    });

    testWidgets('ItineraryScreen renders day tabs and day activities', (tester) async {
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
      expect(find.text('1 / 2 completed'), findsOneWidget);
    });
  });
}

