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

  String getLocalizedNotes(String langCode) {
    final code = langCode.toLowerCase();
    final isTr = code.startsWith('tr');
    final isDe = code.startsWith('de');
    final isFr = code.startsWith('fr');
    final isEs = code.startsWith('es');
    final isRu = code.startsWith('ru');

    switch (iataCode) {
      case 'TK':
        if (isTr) return '1 adet 8 kg kabin bagajı + 1 kişisel eşya (40x30x15 cm). Ekonomi kayıtlı bagaj 23 kg.';
        if (isDe) return '1 Handgepäck (8 kg) + 1 persönlicher Gegenstand (40x30x15 cm). Economy Aufgabegepäck 23 kg.';
        if (isFr) return '1 bagage cabine (8 kg) + 1 accessoire (40x30x15 cm). Bagage en soute Economy 23 kg.';
        if (isEs) return '1 equipaje de mano (8 kg) + 1 artículo personal (40x30x15 cm). Equipaje facturado Economy 23 kg.';
        if (isRu) return '1 место ручной клади (8 кг) + 1 личная вещь (40x30x15 см). Багаж эконом-класса 23 кг.';
        return '1 cabin bag (8 kg) + 1 personal item (40x30x15 cm). Economy checked bag 23 kg.';
      case 'PC':
        if (isTr) return 'Süper Eko pakette 1 koltuk altı çantası (40x30x15 cm 3 kg). Avantaj ve üzeri paketlerde 8 kg kabin bagajı + 20 kg kayıtlı bagaj.';
        if (isDe) return 'Super Eco: 1 Unter-Sitz-Tasche (40x30x15 cm, 3 kg). Ab Vorteil: 8 kg Handgepäck + 20 kg Aufgabegepäck.';
        if (isFr) return 'Super Eco: 1 bagage sous siège (40x30x15 cm, 3 kg). À partir d\'Avantage: 8 kg cabine + 20 kg en soute.';
        if (isEs) return 'Super Eco: 1 bolso bajo el asiento (40x30x15 cm, 3 kg). Advantage y superior: 8 kg cabina + 20 kg facturado.';
        if (isRu) return 'Супер Эко: 1 сумка под сиденье (40x30x15 см, 3 кг). От Advantage: 8 кг ручная кладь + 20 кг багаж.';
        return 'Super Eco: 1 underseat bag (40x30x15 cm, 3 kg). Advantage & above: 8 kg cabin bag + 20 kg checked bag.';
      case 'VF':
        if (isTr) return '1 adet 8 kg kabin bagajı + 1 el çantası (40x30x15 cm, 4 kg). Yurt içi 15-20 kg kayıtlı bagaj hakkı.';
        if (isDe) return '1 Handgepäck (8 kg) + 1 Handtasche (40x30x15 cm, 4 kg). Inländisch 15-20 kg Aufgabegepäck.';
        if (isFr) return '1 bagage cabine (8 kg) + 1 sac à main (40x30x15 cm, 4 kg). Vols intérieurs 15-20 kg en soute.';
        if (isEs) return '1 equipaje de mano (8 kg) + 1 bolso de mano (40x30x15 cm, 4 kg). Facturado nacional 15-20 kg.';
        if (isRu) return '1 место ручной клади (8 кг) + 1 сумочка (40x30x15 см, 4 кг). Внутренние рейсы 15-20 кг багаж.';
        return '1 cabin bag (8 kg) + 1 handbag (40x30x15 cm, 4 kg). Domestic 15-20 kg checked bag.';
      case 'XQ':
        if (isTr) return '1 adet 8 kg kabin bagajı. Yurt içi 15-20 kg, uluslararası uçuşlarda 20-30 kg paketli bagaj.';
        if (isDe) return '1 Handgepäck (8 kg). Inlandsflüge 15-20 kg, internationale Flüge 20-30 kg.';
        if (isFr) return '1 bagage cabine (8 kg). Vols intérieurs 15-20 kg, vols internationaux 20-30 kg.';
        if (isEs) return '1 equipaje de mano (8 kg). Nacional 15-20 kg, vuelos internacionales 20-30 kg.';
        if (isRu) return '1 место ручной клади (8 кг). Внутренние рейсы 15-20 кг, международные 20-30 кг.';
        return '1 cabin bag (8 kg). Domestic 15-20 kg, international 20-30 kg checked baggage.';
      case 'XC':
        if (isTr) return '1 adet 8 kg kabin el bagajı dahildir. Kayıtlı bagaj pakete göre 20-32 kg arası değişir.';
        if (isDe) return '1 Handgepäck (8 kg) inklusive. Aufgabegepäck je nach Tarif 20-32 kg.';
        if (isFr) return '1 bagage cabine (8 kg) inclus. Bagage en soute selon tarif 20-32 kg.';
        if (isEs) return '1 equipaje de cabina (8 kg) incluido. Equipaje facturado según tarifa 20-32 kg.';
        if (isRu) return '1 место ручной клади (8 кг) включено. Багаж от 20 до 32 кг в зависимости от тарифа.';
        return '1 cabin bag (8 kg) included. Checked baggage varies between 20-32 kg depending on fare.';
      case 'LH':
        if (isTr) return 'Ekonomi sınıfı için 1 adet 8 kg kabin bagajı + 1 küçük kişisel çanta (30x40x10 cm).';
        if (isDe) return 'Economy Class: 1 Handgepäck (8 kg) + 1 persönlicher Gegenstand (30x40x10 cm).';
        if (isFr) return 'Classe Éco: 1 bagage cabine (8 kg) + 1 petit accessoire personnel (30x40x10 cm).';
        if (isEs) return 'Clase Turista: 1 equipaje de cabina (8 kg) + 1 artículo personal (30x40x10 cm).';
        if (isRu) return 'Эконом-класс: 1 место ручной клади (8 кг) + 1 личная вещь (30x40x10 см).';
        return 'Economy: 1 cabin bag (8 kg) + 1 small personal item (30x40x10 cm).';
      case 'EK':
        if (isTr) return 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj hakkı bulunur.';
        if (isDe) return 'Economy Class: 1 Handgepäck (7 kg) + 25-30 kg Freigepäck.';
        if (isFr) return 'Classe Éco: 1 bagage cabine (7 kg) + 25-30 kg de bagages en soute.';
        if (isEs) return 'Clase Turista: 1 equipaje de cabina (7 kg) + 25-30 kg de equipaje facturado.';
        if (isRu) return 'Эконом-класс: 1 место ручной клади (7 кг) + 25-30 кг регистрируемый багаж.';
        return 'Economy: 1 cabin bag (7 kg) + 25-30 kg checked baggage allowance.';
      case 'QR':
        if (isTr) return 'Ekonomi yolcuları için 1 parça 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj.';
        if (isDe) return 'Economy Class: 1 Handgepäckstück (7 kg) + 25-30 kg Aufgabegepäck.';
        if (isFr) return 'Classe Éco: 1 bagage cabine (7 kg) + 25-30 kg en soute.';
        if (isEs) return 'Clase Turista: 1 pieza de equipaje de mano (7 kg) + 25-30 kg facturado.';
        if (isRu) return 'Эконом-класс: 1 место ручной клади (7 кг) + 25-30 кг сдаваемый багаж.';
        return 'Economy: 1 piece of 7 kg cabin baggage + 25-30 kg checked baggage.';
      case 'FR':
        if (isTr) return 'Standart bilette sadece koltuk altı küçük çanta (40x20x25 cm). Priority ile 10 kg baş üstü kabin hakkı.';
        if (isDe) return 'Standard: nur 1 kleine Unter-Sitz-Tasche (40x20x25 cm). Mit Priority zusätzlich 10 kg Handgepäck.';
        if (isFr) return 'Tarif standard: 1 petit sac sous le siège (40x20x25 cm). Priority ajoute 10 kg en cabine.';
        if (isEs) return 'Billete estándar: 1 bolso bajo el asiento (40x20x25 cm). Con Priority se añade maleta de 10 kg.';
        if (isRu) return 'Стандарт: 1 сумка под сиденье (40x20x25 см). Приоритет добавляет 10 кг на багажную полку.';
        return 'Standard ticket: 1 small underseat bag (40x20x25 cm). Priority adds 10 kg overhead locker bag.';
      case 'W6':
        if (isTr) return 'Ücretsiz 1 adet koltuk altı çantası (40x30x20 cm). WIZZ Priority ile 10 kg tekerlekli kabin bagajı.';
        if (isDe) return 'Kostenlos 1 Unter-Sitz-Tasche (40x30x20 cm). Mit WIZZ Priority 10 kg Trolley-Handgepäck.';
        if (isFr) return 'Gratuit: 1 sac sous le siège (40x30x20 cm). Avec WIZZ Priority: 1 bagage trolley de 10 kg.';
        if (isEs) return 'Gratis: 1 bolso bajo el asiento (40x30x20 cm). WIZZ Priority añade maleta con ruedas de 10 kg.';
        if (isRu) return 'Бесплатно: 1 сумка под сиденье (40x30x20 см). WIZZ Priority добавляет 10 кг сумку на колесах.';
        return 'Free 1 underseat bag (40x30x20 cm). WIZZ Priority adds 10 kg trolley cabin bag.';
      case 'U2':
        if (isTr) return 'Standart bilet koltuk altı çantası (maks 15 kg). Büyük kabin çantası için Speedy Boarding veya ekstra koltuk gerekir.';
        if (isDe) return 'Standard: 1 Unter-Sitz-Tasche (max. 15 kg). Großes Handgepäck erfordert Speedy Boarding.';
        if (isFr) return 'Tarif standard: 1 sac sous le siège (max 15 kg). Grand bagage cabine avec Speedy Boarding.';
        if (isEs) return 'Estándar: 1 bolso bajo el asiento (máx 15 kg). Equipaje de cabina grande con Speedy Boarding.';
        if (isRu) return 'Стандарт: сумка под сиденье (до 15 кг). Большой багаж требует Speedy Boarding.';
        return 'Standard ticket: 1 underseat bag (max 15 kg). Large cabin bag requires Speedy Boarding or extra legroom.';
      case 'BA':
        if (isTr) return '1 adet 23 kg kabin çantası + 1 adet 23 kg dizüstü / el çantası (40x30x15 cm) cömert hak tanır.';
        if (isDe) return '1 Handgepäck (23 kg) + 1 Hand-/Laptoptasche (40x30x15 cm, 23 kg).';
        if (isFr) return '1 bagage cabine (23 kg) + 1 sac à main/ordinateur (40x30x15 cm, 23 kg).';
        if (isEs) return '1 maleta de cabina (23 kg) + 1 bolso para portátil (40x30x15 cm, 23 kg).';
        if (isRu) return '1 место ручной клади (23 кг) + 1 ноутбук/сумка (40x30x15 см, 23 кг).';
        return 'Generous allowance: 1 cabin bag (23 kg) + 1 handbag/laptop bag (40x30x15 cm, 23 kg).';
      case 'AF/KL':
        if (isTr) return '1 kabin çantası + 1 aksesuarın toplam kombine ağırlığı en fazla 12 kg olmalıdır. Kayıtlı bagaj 23 kg.';
        if (isDe) return '1 Handgepäck + 1 Zubehör mit Gesamtgewicht bis 12 kg. Aufgabegepäck 23 kg.';
        if (isFr) return '1 bagage cabine + 1 accessoire d\'un poids combiné max de 12 kg. Soute 23 kg.';
        if (isEs) return '1 equipaje de cabina + 1 accesorio con peso combinado de hasta 12 kg. Facturado 23 kg.';
        if (isRu) return '1 сумка + 1 аксессуар общим весом до 12 кг. Сдаваемый багаж 23 кг.';
        return '1 cabin bag + 1 personal accessory with combined weight up to 12 kg. Checked bag 23 kg.';
      case 'DL':
        if (isTr) return '1 kabin çantası + 1 kişisel eşya. Çoğu güzergahta kabin ağırlık sınırı olmasa da taşınabilir 10 kg önerilir.';
        if (isDe) return '1 Handgepäck + 1 persönlicher Gegenstand. Meist ohne Gewichtslimit, 10 kg empfohlen.';
        if (isFr) return '1 bagage cabine + 1 accessoire. Sans limite de poids sur la plupart des lignes, 10 kg conseillé.';
        if (isEs) return '1 equipaje de mano + 1 artículo personal. Sin límite en la mayoría de rutas, 10 kg sugerido.';
        if (isRu) return '1 ручная кладь + 1 личная вещь. Без весового лимита на большинстве маршрутов, рекомендуется 10 кг.';
        return '1 carry-on bag + 1 personal item. No weight limit on most routes, 10 kg carry-on recommended.';
      case 'UA':
        if (isTr) return 'Basic Economy hariç 1 kabin bagajı (56x35x22 cm) + 1 kişisel eşya (43x25x22 cm).';
        if (isDe) return 'Außer Basic Economy: 1 Handgepäck (56x35x22 cm) + 1 persönlicher Gegenstand (43x25x22 cm).';
        if (isFr) return 'Sauf Basic Economy: 1 bagage cabine (56x35x22 cm) + 1 accessoire (43x25x22 cm).';
        if (isEs) return 'Excepto Basic Economy: 1 equipaje de mano (56x35x22 cm) + 1 artículo personal (43x25x22 cm).';
        if (isRu) return 'Кроме Basic Economy: 1 ручная кладь (56x35x22 см) + 1 личная вещь (43x25x22 см).';
        return 'Except Basic Economy: 1 carry-on bag (56x35x22 cm) + 1 personal item (43x25x22 cm).';
      case 'SQ':
        if (isTr) return 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 1 kişisel eşya (40x30x10 cm). Kayıtlı bagaj 25-30 kg.';
        if (isDe) return 'Economy: 1 Handgepäck (7 kg) + 1 persönlicher Gegenstand (40x30x10 cm). Freigepäck 25-30 kg.';
        if (isFr) return 'Éco: 1 bagage cabine (7 kg) + 1 accessoire (40x30x10 cm). En soute 25-30 kg.';
        if (isEs) return 'Turista: 1 equipaje de cabina (7 kg) + 1 artículo personal (40x30x10 cm). Facturado 25-30 kg.';
        if (isRu) return 'Эконом: 1 ручная кладь (7 кг) + 1 личная вещь (40x30x10 см). Багаж 25-30 кг.';
        return 'Economy: 1 cabin bag (7 kg) + 1 personal item (40x30x10 cm). Checked bag 25-30 kg.';
      default:
        return notes;
    }
  }
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
