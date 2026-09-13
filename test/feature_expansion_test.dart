import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';

void main() {
  group('1 & 2: Smooth Animations & App Themes', () {
    test('AppAnimations contains consistent durations and cubic curves', () {
      expect(AppAnimations.fast, const Duration(milliseconds: 200));
      expect(AppAnimations.normal, const Duration(milliseconds: 350));
      expect(AppAnimations.smooth, const Duration(milliseconds: 500));
      expect(AppAnimations.relaxed, const Duration(milliseconds: 750));
      expect(AppAnimations.smoothCurve, Curves.easeOutCubic);
      expect(AppAnimations.gentleCurve, Curves.easeInOutCubic);
      expect(AppAnimations.springCurve, Curves.easeOutBack);
    });

    test('AppTheme defines dark and light themes with smooth page transitions', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);

      // Verify ZoomPageTransitionsBuilder is configured for smooth gliding
      expect(
        lightTheme.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<ZoomPageTransitionsBuilder>(),
      );
      expect(
        darkTheme.pageTransitionsTheme.builders[TargetPlatform.iOS],
        isA<ZoomPageTransitionsBuilder>(),
      );
    });
  });

  group('3: Dark Mode Palette Integrity', () {
    test('Dark theme colors provide proper contrast and containers', () {
      final darkColors = AppTheme.darkTheme.colorScheme;
      expect(darkColors.brightness, Brightness.dark);
      expect(darkColors.surface, AppColors.surfaceDark);
      expect(darkColors.primaryContainer, AppColors.primaryContainerDark);
      expect(darkColors.secondaryContainer, AppColors.secondaryContainerDark);
      expect(darkColors.tertiaryContainer, AppColors.tertiaryContainerDark);
    });
  });

  group('4: Multi-Currency Expansion (30 Currencies)', () {
    test('CurrencyFormatter supports 30 world currencies', () {
      expect(CurrencyFormatter.supportedCurrencies.length, 30);

      // Verify major and regional currencies
      final testCases = {
        'USD': '\$',
        'EUR': '€',
        'TRY': '₺',
        'GBP': '£',
        'JPY': '¥',
        'CHF': 'CHF',
        'CAD': 'CA\$',
        'AUD': 'A\$',
        'CNY': '¥',
        'INR': '₹',
        'BRL': 'R\$',
        'KRW': '₩',
        'AED': 'د.إ',
        'SAR': '﷼',
        'SEK': 'kr',
        'NOK': 'kr',
        'DKK': 'kr',
        'PLN': 'zł',
        'THB': '฿',
        'IDR': 'Rp',
        'MXN': 'MX\$',
        'EGP': 'E£',
        'ZAR': 'R',
        'SGD': 'S\$',
        'NZD': 'NZ\$',
        'CZK': 'Kč',
        'HUF': 'Ft',
        'ILS': '₪',
        'VND': '₫',
        'QAR': 'QR',
      };

      for (final entry in testCases.entries) {
        expect(CurrencyFormatter.getSymbol(entry.key), entry.value);
        final formatted = CurrencyFormatter.format(1250.50, currency: entry.key);
        expect(formatted, contains(entry.value));
        expect(CurrencyFormatter.getCurrencyName(entry.key).isNotEmpty, true);
        expect(CurrencyFormatter.getCurrencyLabel(entry.key), contains(entry.key));
      }
    });

    test('CurrencyFormatter gracefully falls back to code for unknown currency', () {
      expect(CurrencyFormatter.getSymbol('XYZ'), 'XYZ');
      expect(CurrencyFormatter.format(100, currency: 'XYZ'), contains('XYZ'));
    });
  });

  group('5: Country & Destination Directory', () {
    test('Country Directory contains world travel destinations with flags and currencies', () {
      expect(Country.allCountries.length >= 25, true);

      final turkey = Country.findByCode('TR');
      expect(turkey, isNotNull);
      expect(turkey!.name, 'Turkey');
      expect(turkey.localName, 'Türkiye');
      expect(turkey.flag, '🇹🇷');
      expect(turkey.defaultCurrency, 'TRY');
      expect(turkey.popularDestinations, contains('İstanbul'));

      final japan = Country.findByCode('jp');
      expect(japan, isNotNull);
      expect(japan!.flag, '🇯🇵');
      expect(japan.defaultCurrency, 'JPY');
      expect(japan.popularDestinations, contains('Tokyo'));

      final italy = Country.findByCode('IT');
      expect(italy, isNotNull);
      expect(italy!.flag, '🇮🇹');
      expect(italy.defaultCurrency, 'EUR');

      expect(Country.findByCode('UNKNOWN'), isNull);
      expect(Country.findByCode(null), isNull);
    });
  });

  group('6: Extended Trip & Expense Tracking Details', () {
    test('Trip serialization and copyWith support countryCode, transportMode, and notes', () {
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip-test-1',
        title: 'Balkan Turu',
        destination: 'Saraybosna',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        budgetLimit: 1500,
        defaultCurrency: 'EUR',
        countryCode: 'BA',
        transportMode: 'Train',
        notes: 'Pasaport ve tren biletlerini çantada hazırla.',
        createdAt: now,
        updatedAt: now,
      );

      final map = trip.toMap();
      expect(map['country_code'], 'BA');
      expect(map['transport_mode'], 'Train');
      expect(map['notes'], 'Pasaport ve tren biletlerini çantada hazırla.');

      final fromMap = Trip.fromMap(map);
      expect(fromMap.countryCode, 'BA');
      expect(fromMap.transportMode, 'Train');
      expect(fromMap.notes, 'Pasaport ve tren biletlerini çantada hazırla.');

      final json = trip.toJson();
      expect(json['countryCode'], 'BA');
      final fromJson = Trip.fromJson(json);
      expect(fromJson.countryCode, 'BA');
      expect(fromJson.transportMode, 'Train');
      expect(fromJson.notes, 'Pasaport ve tren biletlerini çantada hazırla.');

      final modified = trip.copyWith(transportMode: 'Flight', notes: 'Uçuş aktarmalı');
      expect(modified.transportMode, 'Flight');
      expect(modified.notes, 'Uçuş aktarmalı');
      expect(modified.countryCode, 'BA');
    });

    test('Trip backward compatibility when new fields are null', () {
      final map = {
        'id': 'legacy-id-123',
        'title': 'Eski Gezi',
        'destination': 'İzmir',
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'budgetLimit': 500.0,
        'defaultCurrency': 'TRY',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isDeleted': 0,
      };

      final trip = Trip.fromMap(map);
      expect(trip.countryCode, isNull);
      expect(trip.transportMode, isNull);
      expect(trip.notes, isNull);
    });

    test('Expense serialization and copyWith support paymentMethod and notes', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 'exp-test-1',
        tripId: 'trip-1',
        title: 'Akşam Yemeği',
        amount: 85.50,
        currency: 'EUR',
        category: 'Food',
        date: now,
        paymentMethod: 'Credit Card',
        notes: 'Garson bahşişi dahil.',
        createdAt: now,
        updatedAt: now,
      );

      final map = expense.toMap();
      expect(map['payment_method'], 'Credit Card');
      expect(map['notes'], 'Garson bahşişi dahil.');

      final fromMap = Expense.fromMap(map);
      expect(fromMap.paymentMethod, 'Credit Card');
      expect(fromMap.notes, 'Garson bahşişi dahil.');

      final json = expense.toJson();
      expect(json['paymentMethod'], 'Credit Card');
      final fromJson = Expense.fromJson(json);
      expect(fromJson.paymentMethod, 'Credit Card');
      expect(fromJson.notes, 'Garson bahşişi dahil.');

      final modified = expense.copyWith(paymentMethod: 'Cash');
      expect(modified.paymentMethod, 'Cash');
      expect(modified.notes, 'Garson bahşişi dahil.');
    });

    test('TripsScreen.getTransportIcon resolves correct icons', () {
      expect(TripsScreen.getTransportIcon('Flight'), Icons.flight_rounded);
      expect(TripsScreen.getTransportIcon('Uçak'), Icons.flight_rounded);
      expect(TripsScreen.getTransportIcon('Train'), Icons.train_rounded);
      expect(TripsScreen.getTransportIcon('Car'), Icons.directions_car_rounded);
      expect(TripsScreen.getTransportIcon('Ship'), Icons.directions_boat_rounded);
      expect(TripsScreen.getTransportIcon('Bus'), Icons.directions_bus_rounded);
      expect(TripsScreen.getTransportIcon('Other'), Icons.luggage_outlined);
      expect(TripsScreen.getTransportIcon(null), Icons.luggage_outlined);
    });
  });
}
