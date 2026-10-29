import 'package:packbuddy/features/budget/domain/country_localization.dart';

/// Status of a country in the user's travel journey (Been & Skratch style)
enum CountryStatus {
  none,
  visited,
  wishlist,
  lived,
}

/// Domain model representing a country on the interactive world travel map
class TravelCountry {
  final String code; // ISO 3166-1 alpha-2 (e.g. TR, FR, US)
  final String nameTr;
  final String nameEn;
  final String flag;
  final String continent; // Europe, Asia, Americas, Africa, Oceania
  final String capital;
  final double latitude;
  final double longitude;
  final CountryStatus status;
  final DateTime? visitedDate;
  final String? notes;

  const TravelCountry({
    required this.code,
    required this.nameTr,
    required this.nameEn,
    required this.flag,
    required this.continent,
    required this.capital,
    required this.latitude,
    required this.longitude,
    this.status = CountryStatus.none,
    this.visitedDate,
    this.notes,
  });

  bool get isVisited => status == CountryStatus.visited;
  bool get isWishlist => status == CountryStatus.wishlist;
  bool get isLived => status == CountryStatus.lived;

  /// Returns all continents this country belongs to, taking into account transcontinental countries
  /// (e.g. Turkey & Russia span Europe and Asia; Egypt spans Africa and Asia, etc.)
  List<String> get continents {
    final c = code.toUpperCase().trim();
    switch (c) {
      case 'TR': // Türkiye / Turkey (Thrace in Europe, Anatolia in Asia)
      case 'RU': // Rusya / Russia (Western Russia in Europe, Siberia in Asia)
      case 'KZ': // Kazakistan / Kazakhstan (West of Ural in Europe, rest in Asia)
      case 'AZ': // Azerbaycan / Azerbaijan (North of Caucasus in Europe, rest in Asia)
      case 'GE': // Gürcistan / Georgia (Northern border in Europe, rest in Asia)
      case 'CY': // Güney Kıbrıs / Cyprus (Geographically Asia, political/cultural Europe)
      case 'NC': // Kuzey Kıbrıs / North Cyprus
        return const ['Europe', 'Asia'];
      case 'EG': // Mısır / Egypt (Sinai peninsula in Asia, mainland in Africa)
        return const ['Africa', 'Asia'];
      default:
        return [continent];
    }
  }

  /// Whether this country is situated in or spans across the specified continent
  bool isInContinent(String targetContinent) {
    return continents.contains(targetContinent);
  }

  String getLocalizedName(String languageCode) {
    final localized = CountryLocalization.getCountryName(code, languageCode);
    if (localized != null && localized.isNotEmpty) return localized;
    if (languageCode.startsWith('tr')) return nameTr;
    return nameEn;
  }

  TravelCountry copyWith({
    CountryStatus? status,
    DateTime? visitedDate,
    String? notes,
  }) {
    return TravelCountry(
      code: code,
      nameTr: nameTr,
      nameEn: nameEn,
      flag: flag,
      continent: continent,
      capital: capital,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      visitedDate: visitedDate ?? this.visitedDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code.toUpperCase().trim(),
        'status': status.name,
        'visitedDate': visitedDate?.millisecondsSinceEpoch,
        'notes': notes,
      };

  static CountryStatus parseStatus(dynamic value) {
    if (value == null) return CountryStatus.none;
    if (value is CountryStatus) return value;
    final str = value.toString().toLowerCase().trim();
    if (str.contains('lived') || str == 'yasayan' || str == 'yasadigim') {
      return CountryStatus.lived;
    }
    if (str.contains('visited') || str == 'gezilen' || str == 'gezi' || str == 'gezdim') {
      return CountryStatus.visited;
    }
    if (str.contains('wishlist') || str.contains('wish') || str == 'hedef' || str == 'istek') {
      return CountryStatus.wishlist;
    }
    return CountryStatus.none;
  }

  factory TravelCountry.fromJson(Map<String, dynamic> json, TravelCountry base) {
    final status = parseStatus(json['status']);
    DateTime? parsedDate;
    final visitedMs = json['visitedDate'];
    if (visitedMs is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(visitedMs);
    } else if (visitedMs is String) {
      parsedDate = DateTime.tryParse(visitedMs);
    }
    return base.copyWith(
      status: status,
      visitedDate: parsedDate,
      notes: (json['notes'] ?? json['note']) as String?,
    );
  }
}
