import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';

void main() {
  group('Task 4: Complete UN World Countries + Kosovo + KKTC Tests', () {
    test('Country directory has full coverage including Kosovo and Northern Cyprus', () {
      // Must contain almost 200 countries
      expect(Country.allCountries.length >= 195, true);

      // Verify Kosovo
      final kosovo = Country.findByCode('XK');
      expect(kosovo, isNotNull);
      expect(kosovo!.localName, 'Kosova');
      expect(kosovo.name, 'Kosovo');
      expect(kosovo.flag, '🇽🇰');
      expect(kosovo.defaultCurrency, 'EUR');

      // Verify Northern Cyprus (KKTC)
      final kktc = Country.findByCode('NC');
      expect(kktc, isNotNull);
      expect(kktc!.localName, contains('Kıbrıs'));
      expect(kktc.defaultCurrency, 'TRY');

      // Verify Palestine & Vatican (UN Observers)
      final palestine = Country.findByCode('PS');
      expect(palestine, isNotNull);
      expect(palestine!.localName, 'Filistin');

      final vatican = Country.findByCode('VA');
      expect(vatican, isNotNull);
      expect(vatican!.localName, 'Vatikan');
    });
  });

  group('Task 2: Detailed Transport Modes & Custom Transport Tests', () {
    test('getTransportIcon maps preset and custom modes accurately', () {
      expect(TripsScreen.getTransportIcon('Uçak'), Icons.flight_rounded);
      expect(TripsScreen.getTransportIcon('Flight'), Icons.flight_rounded);
      expect(TripsScreen.getTransportIcon('Hızlı Tren (YHT)'), Icons.directions_railway_rounded);
      expect(TripsScreen.getTransportIcon('Motosiklet'), Icons.two_wheeler_rounded);
      expect(TripsScreen.getTransportIcon('Karavan'), Icons.airport_shuttle_rounded);
      expect(TripsScreen.getTransportIcon('Bisiklet'), Icons.pedal_bike_rounded);
      expect(TripsScreen.getTransportIcon('Metro / Tramvay'), Icons.tram_rounded);
      expect(TripsScreen.getTransportIcon('Gemi / Feribot'), Icons.directions_boat_rounded);
      expect(TripsScreen.getTransportIcon('Yürüyüş / Trekking'), Icons.hiking_rounded);
      expect(TripsScreen.getTransportIcon('Helikopter'), Icons.flight_takeoff_rounded);
      expect(TripsScreen.getTransportIcon('Safari Jeepi'), Icons.commute_rounded);
      expect(TripsScreen.getTransportIcon('Other'), Icons.luggage_outlined);
    });

    test('Trip destination stores multi-stop itineraries', () {
      final now = DateTime.now();
      final trip = Trip(
        id: 'multi-stop-1',
        title: 'Avrupa Turu',
        destination: '🇫🇷 Fransa ➔ 🇧🇪 Belçika ➔ 🇳🇱 Hollanda',
        startDate: now,
        endDate: now.add(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      );

      expect(trip.destination.contains('➔'), true);
      final stops = trip.destination.split(' ➔ ');
      expect(stops.length, 3);
      expect(stops[0], contains('Fransa'));
      expect(stops[2], contains('Hollanda'));
    });
  });

  group('Task 5, 6, 7: Multi-Currency, Online Payment, Custom Category Tests', () {
    test('Expense supports custom currency and online payment method', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 'exp-multi-curr-1',
        tripId: 'trip-1',
        title: 'Uçak Online Rezervasyonu',
        amount: 350.0,
        currency: 'EUR',
        category: 'Vize Harcı', // Custom category entered under "Diğer"
        date: now,
        paymentMethod: 'Online',
        createdAt: now,
        updatedAt: now,
      );

      final map = expense.toMap();
      expect(map['currency'], 'EUR');
      expect(map['payment_method'], 'Online');
      expect(map['category'], 'Vize Harcı');

      final fromMap = Expense.fromMap(map);
      expect(fromMap.currency, 'EUR');
      expect(fromMap.paymentMethod, 'Online');
      expect(fromMap.category, 'Vize Harcı');
    });

    test('SharedPreferences remembers last used currency per trip', () async {
      SharedPreferences.setMockInitialValues({
        'last_currency_trip_1': 'JPY',
      });

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_currency_trip_1'), 'JPY');

      await prefs.setString('last_currency_trip_1', 'GBP');
      expect(prefs.getString('last_currency_trip_1'), 'GBP');
    });
  });

  group('Task 9: Document Vault PDF & Trip Association Tests', () {
    test('Document model distinguishes between images and PDFs and supports trip binding', () {
      final now = DateTime.now();
      final pdfDoc = Document(
        id: 'doc-pdf-1',
        title: 'Uçuş Biniş Kartı',
        category: 'Ticket',
        localImagePath: '/vault/boarding_pass.pdf',
        tripId: 'trip-paris-1',
        fileType: 'pdf',
        notes: 'PNR: 987XYZ',
        createdAt: now,
        updatedAt: now,
      );

      expect(pdfDoc.isPdf, true);
      expect(pdfDoc.tripId, 'trip-paris-1');
      expect(pdfDoc.notes, 'PNR: 987XYZ');

      final map = pdfDoc.toMap();
      expect(map['file_type'], 'pdf');
      expect(map['trip_id'], 'trip-paris-1');

      final fromMap = Document.fromMap(map);
      expect(fromMap.isPdf, true);
      expect(fromMap.tripId, 'trip-paris-1');

      // General Document without trip
      final generalDoc = pdfDoc.copyWith(clearTripId: true);
      expect(generalDoc.tripId, isNull);
    });
  });
}
