import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/collaboration_localization.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/day_timeline_card.dart';

void main() {
  final now = DateTime(2026, 6, 1, 12, 0);

  group('Trip.isCollaborative Invariant Tests', () {
    test('Solo trip is NOT collaborative', () {
      final soloTrip = Trip(
        id: 'trip_solo_1',
        title: 'Solo Exploration',
        destination: 'Kyoto',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 7),
        isShared: false,
        collaborators: const [],
        createdAt: now,
        updatedAt: now,
      );

      expect(soloTrip.isCollaborative, isFalse);
    });

    test('Shared trip is collaborative', () {
      final sharedTrip = Trip(
        id: 'trip_shared_1',
        title: 'Shared Trip',
        destination: 'Paris',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 5),
        isShared: true,
        collaborators: const [],
        createdAt: now,
        updatedAt: now,
      );

      expect(sharedTrip.isCollaborative, isTrue);
    });

    test('Trip with collaborators list is collaborative even if isShared was false', () {
      final tripWithCollaborators = Trip(
        id: 'trip_collab_1',
        title: 'Group Adventure',
        destination: 'Rome',
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 8),
        isShared: false,
        collaborators: const ['friend@packbuddy.com'],
        createdAt: now,
        updatedAt: now,
      );

      expect(tripWithCollaborators.isCollaborative, isTrue);
    });
  });

  group('Expense & ItineraryItem Attribution Persistence', () {
    test('Expense preserves createdByName across serialization and copyWith', () {
      final expense = Expense(
        id: 'exp_101',
        tripId: 'trip_1',
        title: 'Dinner at Trattoria',
        amount: 85.50,
        currency: 'EUR',
        category: 'food',
        date: DateTime(2026, 11, 2),
        paymentMethod: 'credit_card',
        userId: 'user_alex',
        createdByName: 'Alex Smith',
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.createdByName, equals('Alex Smith'));

      final map = expense.toMap();
      expect(map['created_by_name'], equals('Alex Smith'));

      final fromMap = Expense.fromMap(map);
      expect(fromMap.createdByName, equals('Alex Smith'));
      expect(fromMap.userId, equals('user_alex'));

      final json = expense.toJson();
      final fromJson = Expense.fromJson(json);
      expect(fromJson.createdByName, equals('Alex Smith'));

      final copied = expense.copyWith(createdByName: 'Maria Rossi');
      expect(copied.createdByName, equals('Maria Rossi'));
      expect(copied.title, equals('Dinner at Trattoria'));
    });

    test('ItineraryItem preserves createdByName across serialization and copyWith', () {
      final item = ItineraryItem(
        id: 'itin_201',
        tripId: 'trip_1',
        dayNumber: 1,
        date: '2026-11-02',
        time: '19:30',
        endTime: '21:00',
        title: 'Vatican Museums Night Tour',
        category: 'sightseeing',
        userId: 'user_maria',
        createdByName: 'Maria Rossi',
        createdAt: now,
        updatedAt: now,
      );

      expect(item.createdByName, equals('Maria Rossi'));

      final map = item.toMap();
      expect(map['created_by_name'], equals('Maria Rossi'));

      final fromMap = ItineraryItem.fromMap(map);
      expect(fromMap.createdByName, equals('Maria Rossi'));
      expect(fromMap.userId, equals('user_maria'));

      final jsonMap = item.toJsonMap();
      expect(jsonMap['created_by_name'], equals('Maria Rossi'));

      final fromJsonMap = ItineraryItem.fromJsonMap(jsonMap);
      expect(fromJsonMap.createdByName, equals('Maria Rossi'));

      final copied = item.copyWith(createdByName: 'Can Demir');
      expect(copied.createdByName, equals('Can Demir'));
      expect(copied.title, equals('Vatican Museums Night Tour'));
    });
  });

  group('20-Language Native Collaboration Localization Tests', () {
    const supportedLanguages = [
      'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru',
      'zh', 'ja', 'ko', 'hi', 'ar', 'nl', 'el', 'sv',
      'pl', 'id', 'th', 'vi',
    ];

    test('All 20 languages return non-empty strings for all labels', () {
      for (final lang in supportedLanguages) {
        final you = CollaborationLocalization.getYou(lang);
        final addedBy = CollaborationLocalization.getAddedBy(lang, 'Alex');
        final addedByYou = CollaborationLocalization.getAddedByYou(lang);
        final liveTrip = CollaborationLocalization.getLiveSharedTrip(lang);
        final collaborator = CollaborationLocalization.getCollaborator(lang);
        final collaboratorsCount = CollaborationLocalization.getCollaboratorsCount(lang, 4);
        final owner = CollaborationLocalization.getOwner(lang);

        expect(you.isNotEmpty, isTrue, reason: 'Failed for getYou in $lang');
        expect(addedBy.contains('Alex'), isTrue, reason: 'Failed for getAddedBy in $lang');
        expect(addedByYou.isNotEmpty, isTrue, reason: 'Failed for getAddedByYou in $lang');
        expect(liveTrip.isNotEmpty, isTrue, reason: 'Failed for getLiveSharedTrip in $lang');
        expect(collaborator.isNotEmpty, isTrue, reason: 'Failed for getCollaborator in $lang');
        expect(collaboratorsCount.contains('4'), isTrue, reason: 'Failed for getCollaboratorsCount in $lang');
        expect(owner.isNotEmpty, isTrue, reason: 'Failed for getOwner in $lang');
      }
    });

    test('formatAddedBy returns "Siz" / "You" when isMe is true', () {
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: true, languageCode: 'tr'), equals('Siz'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: true, languageCode: 'en'), equals('You'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: true, languageCode: 'de'), equals('Du'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: true, languageCode: 'es'), equals('Tú'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: true, languageCode: 'fr'), equals('Vous'));
    });

    test('formatAddedBy returns "Ekleyen: Name" / "By Name" when isMe is false with name', () {
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: false, languageCode: 'tr'), equals('Ekleyen: Alex'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: false, languageCode: 'en'), equals('By Alex'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: false, languageCode: 'de'), equals('Von Alex'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: false, languageCode: 'es'), equals('Por Alex'));
      expect(CollaborationLocalization.formatAddedBy('Alex', isMe: false, languageCode: 'fr'), equals('Par Alex'));
    });

    test('formatAddedBy falls back to Collaborator term when name is null or empty', () {
      expect(CollaborationLocalization.formatAddedBy(null, isMe: false, languageCode: 'tr'), equals('Katılımcı'));
      expect(CollaborationLocalization.formatAddedBy('', isMe: false, languageCode: 'tr'), equals('Katılımcı'));
      expect(CollaborationLocalization.formatAddedBy(null, isMe: false, languageCode: 'en'), equals('Collaborator'));
    });
  });

  group('DayTimelineCard Attribution Widget Tests (Solo vs. Collaborative)', () {
    final testActivity = ItineraryItem(
      id: 'item_1',
      tripId: 'trip_100',
      dayNumber: 1,
      date: '2026-08-10',
      time: '10:00',
      endTime: '12:00',
      title: 'Louvre Museum Visit',
      category: 'sightseeing',
      userId: 'user_author',
      createdByName: 'Zeynep Kaya',
      createdAt: now,
      updatedAt: now,
    );

    testWidgets('Solo trip NEVER displays author tags or attribution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DayTimelineCard(
              item: testActivity,
              languageCode: 'tr',
              isCollaborative: false, // SOLO TRIP!
              currentUserId: 'user_author',
              currentUserName: 'Zeynep Kaya',
              onToggleCompleted: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title is displayed
      expect(find.text('Louvre Museum Visit'), findsOneWidget);

      // Attribution MUST NOT appear on solo trip
      expect(find.text('Siz'), findsNothing);
      expect(find.text('Ekleyen: Zeynep Kaya'), findsNothing);
      expect(find.text('Zeynep Kaya'), findsNothing);
      expect(find.byIcon(Icons.person_rounded), findsNothing);
      expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
    });

    testWidgets('Collaborative trip displays "Siz" when item was created by current user', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DayTimelineCard(
              item: testActivity,
              languageCode: 'tr',
              isCollaborative: true, // COLLABORATIVE TRIP!
              currentUserId: 'user_author', // Matches item.userId
              currentUserName: 'Zeynep Kaya',
              onToggleCompleted: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // "Siz" and person icon must appear
      expect(find.text('Siz'), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('Collaborative trip displays "Ekleyen: Name" when item was created by collaborator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DayTimelineCard(
              item: testActivity,
              languageCode: 'tr',
              isCollaborative: true, // COLLABORATIVE TRIP!
              currentUserId: 'different_user', // Current user is someone else
              currentUserName: 'Ahmet',
              onToggleCompleted: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // "Ekleyen: Zeynep Kaya" and person outline icon must appear
      expect(find.text('Ekleyen: Zeynep Kaya'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text('Siz'), findsNothing);
    });

    testWidgets('English collaborative trip displays "By Zeynep Kaya"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DayTimelineCard(
              item: testActivity,
              languageCode: 'en',
              isCollaborative: true,
              currentUserId: 'other_user',
              currentUserName: 'John',
              onToggleCompleted: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('By Zeynep Kaya'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });
  });

  group('Responsive Layout & Screen Size Overflow Verification', () {
    final activity = ItineraryItem(
      id: 'item_resp_1',
      tripId: 'trip_resp',
      dayNumber: 1,
      date: '2026-08-10',
      time: '10:00',
      endTime: '12:00',
      title: 'Very Long Activity Title That Tests Layout Constraints and Wrapping in Itinerary',
      location: '123 Boulevard Saint-Germain, 75005 Paris, France',
      description: 'Detailed description about the guided tour with long text and notes.',
      cost: 150.0,
      currency: 'EUR',
      category: 'sightseeing',
      userId: 'collab_user',
      createdByName: 'Dr. Christopher Montgomery-Alexander',
      createdAt: now,
      updatedAt: now,
    );

    const screenSizes = [
      Size(320, 568),  // Small/Narrow Mobile (iPhone SE 1st gen)
      Size(360, 640),  // Standard Android
      Size(390, 844),  // iPhone 14
      Size(428, 926),  // iPhone 14 Pro Max
      Size(800, 1280), // Tablet
    ];

    for (final size in screenSizes) {
      testWidgets('Zero RenderFlex overflow on ${size.width}x${size.height} screen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DayTimelineCard(
                item: activity,
                languageCode: 'tr',
                isCollaborative: true,
                currentUserId: 'my_user_id',
                currentUserName: 'Enes',
                onToggleCompleted: () {},
                onDelete: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must render cleanly with zero overflow exception
        expect(tester.takeException(), isNull);
        expect(find.text('Ekleyen: Dr. Christopher Montgomery-Alexander'), findsOneWidget);
      });
    }
  });

  group('All 20 Languages Render Tests in DayTimelineCard', () {
    const supportedLanguages = [
      'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru',
      'zh', 'ja', 'ko', 'hi', 'ar', 'nl', 'el', 'sv',
      'pl', 'id', 'th', 'vi',
    ];

    final sampleItem = ItineraryItem(
      id: 'lang_item',
      tripId: 'lang_trip',
      dayNumber: 1,
      date: '2026-08-10',
      time: '14:00',
      title: 'City Exploration',
      category: 'food',
      userId: 'creator_99',
      createdByName: 'Elena',
      createdAt: now,
      updatedAt: now,
    );

    for (final lang in supportedLanguages) {
      testWidgets('Renders DayTimelineCard cleanly in $lang', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DayTimelineCard(
                item: sampleItem,
                languageCode: lang,
                isCollaborative: true,
                currentUserId: 'other_user',
                currentUserName: 'Alex',
                onToggleCompleted: () {},
                onDelete: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final expectedAttribution = CollaborationLocalization.formatAddedBy(
          'Elena',
          isMe: false,
          languageCode: lang,
        );
        expect(find.text(expectedAttribution), findsOneWidget);
      });
    }
  });
}
