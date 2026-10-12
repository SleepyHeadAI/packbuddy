/// Airline Baggage rule entity
class AirlineBaggageRule {
  final String airlineName;
  final String iataCode;
  final String countryFlag;
  final double cabinLimitKg;
  final String cabinDimensions;
  final double checkedLimitKg;
  final String notes;

  const AirlineBaggageRule({
    required this.airlineName,
    required this.iataCode,
    required this.countryFlag,
    required this.cabinLimitKg,
    required this.cabinDimensions,
    required this.checkedLimitKg,
    required this.notes,
  });
}

/// Directory of major international and regional airlines baggage allowances
class AirlineBaggageRepository {
  AirlineBaggageRepository._();

  static const List<AirlineBaggageRule> airlines = [
    AirlineBaggageRule(
      airlineName: 'Türk Hava Yolları',
      iataCode: 'TK',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 8 kg kabin bagajı + 1 kişisel eşya (40x30x15 cm). Ekonomi kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Pegasus Airlines',
      iataCode: 'PC',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 20 cm',
      checkedLimitKg: 20.0,
      notes: 'Süper Eko pakette 1 koltuk altı çantası (40x30x15 cm 3 kg). Avantaj ve üzeri paketlerde 8 kg kabin bagajı + 20 kg kayıtlı bagaj.',
    ),
    AirlineBaggageRule(
      airlineName: 'AJet (AnadoluJet)',
      iataCode: 'VF',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin bagajı + 1 el çantası (40x30x15 cm, 4 kg). Yurt içi 15-20 kg kayıtlı bagaj hakkı.',
    ),
    AirlineBaggageRule(
      airlineName: 'SunExpress',
      iataCode: 'XQ',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin bagajı. Yurt içi 15-20 kg, uluslararası uçuşlarda 20-30 kg paketli bagaj.',
    ),
    AirlineBaggageRule(
      airlineName: 'Corendon Airlines',
      iataCode: 'XC',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 25 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin el bagajı dahildir. Kayıtlı bagaj pakete göre 20-32 kg arası değişir.',
    ),
    AirlineBaggageRule(
      airlineName: 'Lufthansa',
      iataCode: 'LH',
      countryFlag: '🇩🇪',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      checkedLimitKg: 23.0,
      notes: 'Ekonomi sınıfı için 1 adet 8 kg kabin bagajı + 1 küçük kişisel çanta (30x40x10 cm).',
    ),
    AirlineBaggageRule(
      airlineName: 'Emirates',
      iataCode: 'EK',
      countryFlag: '🇦🇪',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 38 x 22 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj hakkı bulunur.',
    ),
    AirlineBaggageRule(
      airlineName: 'Qatar Airways',
      iataCode: 'QR',
      countryFlag: '🇶🇦',
      cabinLimitKg: 7.0,
      cabinDimensions: '50 x 37 x 25 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi yolcuları için 1 parça 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj.',
    ),
    AirlineBaggageRule(
      airlineName: 'Ryanair',
      iataCode: 'FR',
      countryFlag: '🇮🇪',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 20 cm',
      checkedLimitKg: 20.0,
      notes: 'Standart bilette sadece koltuk altı küçük çanta (40x20x25 cm). Priority ile 10 kg baş üstü kabin hakkı.',
    ),
    AirlineBaggageRule(
      airlineName: 'Wizz Air',
      iataCode: 'W6',
      countryFlag: '🇭🇺',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 23 cm',
      checkedLimitKg: 20.0,
      notes: 'Ücretsiz 1 adet koltuk altı çantası (40x30x20 cm). WIZZ Priority ile 10 kg tekerlekli kabin bagajı.',
    ),
    AirlineBaggageRule(
      airlineName: 'easyJet',
      iataCode: 'U2',
      countryFlag: '🇬🇧',
      cabinLimitKg: 15.0,
      cabinDimensions: '45 x 36 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'Standart bilet koltuk altı çantası (maks 15 kg). Büyük kabin çantası için Speedy Boarding veya ekstra koltuk gerekir.',
    ),
    AirlineBaggageRule(
      airlineName: 'British Airways',
      iataCode: 'BA',
      countryFlag: '🇬🇧',
      cabinLimitKg: 23.0,
      cabinDimensions: '56 x 45 x 25 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 23 kg kabin çantası + 1 adet 23 kg dizüstü / el çantası (40x30x15 cm) cömert hak tanır.',
    ),
    AirlineBaggageRule(
      airlineName: 'Air France / KLM',
      iataCode: 'AF/KL',
      countryFlag: '🇫🇷',
      cabinLimitKg: 12.0,
      cabinDimensions: '55 x 35 x 25 cm',
      checkedLimitKg: 23.0,
      notes: '1 kabin çantası + 1 aksesuarın toplam kombine ağırlığı en fazla 12 kg olmalıdır. Kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Delta Air Lines',
      iataCode: 'DL',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 35 x 23 cm',
      checkedLimitKg: 23.0,
      notes: '1 kabin çantası + 1 kişisel eşya. Çoğu güzergahta kabin ağırlık sınırı olmasa da taşınabilir 10 kg önerilir.',
    ),
    AirlineBaggageRule(
      airlineName: 'United Airlines',
      iataCode: 'UA',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 35 x 22 cm',
      checkedLimitKg: 23.0,
      notes: 'Basic Economy hariç 1 kabin bagajı (56x35x22 cm) + 1 kişisel eşya (43x25x22 cm).',
    ),
    AirlineBaggageRule(
      airlineName: 'Singapore Airlines',
      iataCode: 'SQ',
      countryFlag: '🇸🇬',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 40 x 20 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 1 kişisel eşya (40x30x10 cm). Kayıtlı bagaj 25-30 kg.',
    ),
  ];

  /// Resolves default airline (Turkish Airlines)
  static AirlineBaggageRule get defaultAirline => airlines.first;

  /// Looks up airline by name or code
  static AirlineBaggageRule? findByQuery(String query) {
    final q = query.trim().toLowerCase();
    for (final a in airlines) {
      if (a.airlineName.toLowerCase().contains(q) ||
          a.iataCode.toLowerCase() == q) {
        return a;
      }
    }
    return null;
  }
}
