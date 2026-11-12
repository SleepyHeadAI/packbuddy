/// Airline Fare Package (e.g. EcoFly, ExtraFly, PrimeFly, Süper Eko, Avantaj, Saver, Flexi, etc.)
class AirlineFarePackage {
  final String id;
  final String name;
  final double cabinLimitKg;
  final String cabinDimensions;
  final double personalItemLimitKg;
  final String personalItemDimensions;
  final double checkedLimitKg;
  final int cabinPieces;
  final int checkedPieces;
  final String description;

  const AirlineFarePackage({
    required this.id,
    required this.name,
    required this.cabinLimitKg,
    required this.cabinDimensions,
    this.personalItemLimitKg = 4.0,
    this.personalItemDimensions = '40 x 30 x 15 cm',
    required this.checkedLimitKg,
    this.cabinPieces = 1,
    this.checkedPieces = 1,
    required this.description,
  });

  String getLocalizedDescription(String langCode) {
    final code = langCode.toLowerCase();
    final isTr = code.startsWith('tr');
    if (isTr) return description;
    final cabinKg = cabinLimitKg > 0 ? '${cabinLimitKg.toInt()} kg' : '0 kg';
    final checkedKg = checkedLimitKg > 0 ? '${checkedLimitKg.toInt()} kg' : '0 kg';
    final personalKg = personalItemLimitKg > 0 ? '${personalItemLimitKg.toInt()} kg' : 'underseat';
    return '$name: Personal ($personalKg) • Cabin ($cabinKg) • Checked ($checkedKg)';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cabinLimitKg': cabinLimitKg,
    'cabinDimensions': cabinDimensions,
    'personalItemLimitKg': personalItemLimitKg,
    'personalItemDimensions': personalItemDimensions,
    'checkedLimitKg': checkedLimitKg,
    'cabinPieces': cabinPieces,
    'checkedPieces': checkedPieces,
    'description': description,
  };

  factory AirlineFarePackage.fromJson(Map<String, dynamic> json) => AirlineFarePackage(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    cabinLimitKg: (json['cabinLimitKg'] as num?)?.toDouble() ?? 8.0,
    cabinDimensions: json['cabinDimensions'] as String? ?? '55 x 40 x 23 cm',
    personalItemLimitKg: (json['personalItemLimitKg'] as num?)?.toDouble() ?? 4.0,
    personalItemDimensions: json['personalItemDimensions'] as String? ?? '40 x 30 x 15 cm',
    checkedLimitKg: (json['checkedLimitKg'] as num?)?.toDouble() ?? 20.0,
    cabinPieces: (json['cabinPieces'] as num?)?.toInt() ?? 1,
    checkedPieces: (json['checkedPieces'] as num?)?.toInt() ?? 1,
    description: json['description'] as String? ?? '',
  );
}

/// Airline Baggage rule entity
class AirlineBaggageRule {
  final String airlineName;
  final String iataCode;
  final String countryFlag;
  final double cabinLimitKg;
  final String cabinDimensions;
  final double personalItemLimitKg;
  final String personalItemDimensions;
  final double checkedLimitKg;
  final String notes;
  final List<AirlineFarePackage> packages;
  final String? selectedPackageId;

  const AirlineBaggageRule({
    required this.airlineName,
    required this.iataCode,
    required this.countryFlag,
    required this.cabinLimitKg,
    required this.cabinDimensions,
    this.personalItemLimitKg = 4.0,
    this.personalItemDimensions = '40 x 30 x 15 cm',
    required this.checkedLimitKg,
    required this.notes,
    this.packages = const [],
    this.selectedPackageId,
  });

  /// Dynamically resolves the currently active fare package
  AirlineFarePackage get activePackage {
    if (selectedPackageId != null && packages.isNotEmpty) {
      final found = packages.where((p) => p.id == selectedPackageId);
      if (found.isNotEmpty) return found.first;
    }
    if (packages.isNotEmpty) return packages.first;
    return AirlineFarePackage(
      id: '${iataCode}_DEFAULT',
      name: 'Standart',
      cabinLimitKg: cabinLimitKg,
      cabinDimensions: cabinDimensions,
      personalItemLimitKg: personalItemLimitKg,
      personalItemDimensions: personalItemDimensions,
      checkedLimitKg: checkedLimitKg,
      description: notes,
    );
  }

  /// Effective limits based on active package
  double get effectiveCabinLimitKg => activePackage.cabinLimitKg;
  String get effectiveCabinDimensions => activePackage.cabinDimensions;
  double get effectivePersonalItemLimitKg => activePackage.personalItemLimitKg;
  String get effectivePersonalItemDimensions => activePackage.personalItemDimensions;
  double get effectiveCheckedLimitKg => activePackage.checkedLimitKg;

  AirlineBaggageRule copyWith({
    String? airlineName,
    String? iataCode,
    String? countryFlag,
    double? cabinLimitKg,
    String? cabinDimensions,
    double? personalItemLimitKg,
    String? personalItemDimensions,
    double? checkedLimitKg,
    String? notes,
    List<AirlineFarePackage>? packages,
    String? selectedPackageId,
  }) {
    return AirlineBaggageRule(
      airlineName: airlineName ?? this.airlineName,
      iataCode: iataCode ?? this.iataCode,
      countryFlag: countryFlag ?? this.countryFlag,
      cabinLimitKg: cabinLimitKg ?? this.cabinLimitKg,
      cabinDimensions: cabinDimensions ?? this.cabinDimensions,
      personalItemLimitKg: personalItemLimitKg ?? this.personalItemLimitKg,
      personalItemDimensions: personalItemDimensions ?? this.personalItemDimensions,
      checkedLimitKg: checkedLimitKg ?? this.checkedLimitKg,
      notes: notes ?? this.notes,
      packages: packages ?? this.packages,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
    );
  }

  Map<String, dynamic> toJson() => {
    'airlineName': airlineName,
    'iataCode': iataCode,
    'countryFlag': countryFlag,
    'cabinLimitKg': cabinLimitKg,
    'cabinDimensions': cabinDimensions,
    'personalItemLimitKg': personalItemLimitKg,
    'personalItemDimensions': personalItemDimensions,
    'checkedLimitKg': checkedLimitKg,
    'notes': notes,
    'packages': packages.map((p) => p.toJson()).toList(),
    'selectedPackageId': selectedPackageId,
  };

  factory AirlineBaggageRule.fromJson(Map<String, dynamic> json) => AirlineBaggageRule(
    airlineName: json['airlineName'] as String? ?? '',
    iataCode: json['iataCode'] as String? ?? '',
    countryFlag: json['countryFlag'] as String? ?? '',
    cabinLimitKg: (json['cabinLimitKg'] as num?)?.toDouble() ?? 8.0,
    cabinDimensions: json['cabinDimensions'] as String? ?? '55 x 40 x 23 cm',
    personalItemLimitKg: (json['personalItemLimitKg'] as num?)?.toDouble() ?? 4.0,
    personalItemDimensions: json['personalItemDimensions'] as String? ?? '40 x 30 x 15 cm',
    checkedLimitKg: (json['checkedLimitKg'] as num?)?.toDouble() ?? 20.0,
    notes: json['notes'] as String? ?? '',
    packages: (json['packages'] as List<dynamic>?)
            ?.map((p) => AirlineFarePackage.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const [],
    selectedPackageId: json['selectedPackageId'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirlineBaggageRule &&
          runtimeType == other.runtimeType &&
          iataCode == other.iataCode &&
          selectedPackageId == other.selectedPackageId;

  @override
  int get hashCode => iataCode.hashCode ^ (selectedPackageId?.hashCode ?? 0);

  /// Dynamically localizes notes across 20 languages with custom tier explanations
  String getLocalizedNotes(String langCode) {
    final code = langCode.toLowerCase();
    final isTr = code.startsWith('tr');
    final isDe = code.startsWith('de');
    final isFr = code.startsWith('fr');
    final isEs = code.startsWith('es');
    final isRu = code.startsWith('ru');
    final isIt = code.startsWith('it');
    final isPt = code.startsWith('pt');
    final isNl = code.startsWith('nl');
    final isZh = code.startsWith('zh');
    final isJa = code.startsWith('ja');
    final isKo = code.startsWith('ko');
    final isAr = code.startsWith('ar');

    // Custom tiered rules for ultra-low-cost & specific carriers
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

      case 'FR':
        if (isTr) return 'Standart bilette sadece koltuk altı küçük çanta (40x25x20 cm). Priority ile 10 kg baş üstü kabin hakkı.';
        if (isDe) return 'Standard: nur 1 kleine Unter-Sitz-Tasche (40x25x20 cm). Mit Priority zusätzlich 10 kg Handgepäck.';
        if (isFr) return 'Tarif standard: 1 petit sac sous le siège (40x25x20 cm). Priority ajoute 10 kg en cabine.';
        if (isEs) return 'Billete estándar: 1 bolso bajo el asiento (40x25x20 cm). Con Priority se añade maleta de 10 kg.';
        if (isRu) return 'Стандарт: 1 сумка под сиденье (40x25x20 см). Приоритет добавляет 10 кг на багажную полку.';
        return 'Standard ticket: 1 small underseat bag (40x25x20 cm). Priority adds 10 kg overhead locker bag.';

      case 'W6':
        if (isTr) return 'Ücretsiz 1 adet koltuk altı çantası (40x30x20 cm, 10 kg). WIZZ Priority ile 10 kg tekerlekli kabin bagajı.';
        if (isDe) return 'Kostenlos 1 Unter-Sitz-Tasche (40x30x20 cm, 10 kg). Mit WIZZ Priority 10 kg Trolley-Handgepäck.';
        if (isFr) return 'Gratuit: 1 sac sous le siège (40x30x20 cm, 10 kg). Avec WIZZ Priority: 1 bagage trolley de 10 kg.';
        if (isEs) return 'Gratis: 1 bolso bajo el asiento (40x30x20 cm, 10 kg). WIZZ Priority añade maleta con ruedas de 10 kg.';
        if (isRu) return 'Бесплатно: 1 сумка под сиденье (40x30x20 см, 10 кг). WIZZ Priority добавляет 10 кг сумку на колесах.';
        return 'Free 1 underseat bag (40x30x20 cm, 10 kg). WIZZ Priority adds 10 kg trolley cabin bag.';

      case 'U2':
        if (isTr) return 'Standart bilet koltuk altı çantası (maks 15 kg). Büyük kabin çantası için Speedy Boarding veya ekstra bacak alanı gerekir.';
        if (isDe) return 'Standard: 1 Unter-Sitz-Tasche (max. 15 kg). Großes Handgepäck erfordert Speedy Boarding.';
        if (isFr) return 'Tarif standard: 1 sac sous le siège (max 15 kg). Grand bagage cabine avec Speedy Boarding.';
        if (isEs) return 'Estándar: 1 bolso bajo el asiento (máx 15 kg). Equipaje de cabina grande con Speedy Boarding.';
        if (isRu) return 'Стандарт: сумка под сиденье (до 15 кг). Большой багаж требует Speedy Boarding.';
        return 'Standard ticket: 1 underseat bag (max 15 kg). Large cabin bag requires Speedy Boarding or extra legroom.';

      case 'WN':
        if (isTr) return '1 kabin bagajı (61x40x25 cm) + 1 kişisel eşya. Eşsiz avantaj: Tüm yolculara 2 adet ücretsiz 23 kg kayıtlı bagaj!';
        if (isDe) return '1 Handgepäck (61x40x25 cm) + 1 persönlicher Gegenstand. 2 kostenlose Aufgabegepäckstücke bis je 23 kg!';
        if (isFr) return '1 bagage cabine (61x40x25 cm) + 1 accessoire. Avantage unique: 2 bagages en soute gratuits de 23 kg!';
        if (isEs) return '1 equipaje de mano (61x40x25 cm) + 1 artículo personal. ¡2 maletas facturadas gratis de hasta 23 kg cada una!';
        if (isRu) return '1 ручная кладь (61x40x25 см) + 1 личная вещь. 2 бесплатных места багажа до 23 кг каждое!';
        return '1 carry-on bag (61x40x25 cm) + 1 personal item. Unique benefit: 2 free checked bags up to 23 kg (50 lbs) each!';

      case 'NK':
        if (isTr) return 'Ücretsiz: 1 koltuk altı kişisel eşya (45x35x20 cm). Baş üstü kabin ve kayıtlı bagaj ücrete tabidir (maks 18 kg).';
        if (isDe) return 'Inklusive: 1 persönlicher Gegenstand (45x35x20 cm). Handgepäck und Aufgabegepäck (18 kg) gebührenpflichtig.';
        if (isFr) return 'Inclus: 1 accessoire personnel (45x35x20 cm). Bagage cabine et soute (18 kg) payants.';
        if (isEs) return 'Incluido: 1 artículo personal (45x35x20 cm). Equipaje de mano y facturado (18 kg) de pago.';
        if (isRu) return 'Включено: 1 личная вещь (45x35x20 см). Ручная кладь и багаж (18 кг) оплачиваются отдельно.';
        return 'Included: 1 personal item (45x35x20 cm). Overhead carry-on and checked bags (18 kg / 40 lbs) require fee.';

      case 'B6':
        if (isTr) return 'Blue tarifelerinde 1 adet 10 kg kabin bagajı (56x35x23 cm) + 1 kişisel eşya (43x33x20 cm). Kayıtlı bagaj 23 kg. Blue Basic sadece kişisel eşya içerir.';
        if (isDe) return 'Blue-Tarife: 1 Handgepäck (10 kg) + 1 persönlicher Gegenstand. 23 kg Aufgabegepäck. Blue Basic nur persönlicher Gegenstand.';
        if (isFr) return 'Tarifs Blue: 1 bagage cabine (10 kg) + 1 accessoire. Soute 23 kg. Blue Basic uniquement accessoire.';
        if (isEs) return 'Tarifas Blue: 1 equipaje de mano (10 kg) + 1 artículo personal. Facturado 23 kg. Blue Basic solo artículo personal.';
        return 'Blue fares include 1 carry-on (10 kg, 56x35x23 cm) + 1 personal item. Checked bag 23 kg. Blue Basic includes personal item only.';

      case 'BA':
        if (isTr) return '1 adet 23 kg kabin çantası (56x45x25 cm) + 1 adet 23 kg dizüstü / el çantası (40x30x15 cm). Kayıtlı 23 kg.';
        if (isDe) return '1 Handgepäck (23 kg) + 1 Hand-/Laptoptasche (40x30x15 cm, 23 kg). Aufgabegepäck 23 kg.';
        if (isFr) return '1 bagage cabine (23 kg) + 1 sac à main/ordinateur (40x30x15 cm, 23 kg). Soute 23 kg.';
        if (isEs) return '1 maleta de cabina (23 kg) + 1 bolso para portátil (40x30x15 cm, 23 kg). Facturado 23 kg.';
        if (isRu) return '1 место ручной клади (23 кг) + 1 ноутбук/сумка (40x30x15 см, 23 кг). Багаж 23 кг.';
        return 'Generous allowance: 1 cabin bag (23 kg) + 1 handbag/laptop bag (40x30x15 cm, 23 kg). Checked bag 23 kg.';

      case 'AF':
      case 'KL':
      case 'AF/KL':
        if (isTr) return '1 kabin çantası (55x35x25 cm) + 1 aksesuarın toplam kombine ağırlığı en fazla 12 kg olmalıdır. Kayıtlı bagaj 23 kg.';
        if (isDe) return '1 Handgepäck + 1 Zubehör mit Gesamtgewicht bis 12 kg. Aufgabegepäck 23 kg.';
        if (isFr) return '1 bagage cabine + 1 accessoire d\'un poids combiné max de 12 kg. Soute 23 kg.';
        if (isEs) return '1 equipaje de cabina + 1 accesorio con peso combinado de hasta 12 kg. Facturado 23 kg.';
        if (isRu) return '1 сумка + 1 аксессуар общим весом до 12 кг. Сдаваемый багаж 23 кг.';
        return '1 cabin bag + 1 personal accessory with combined weight up to 12 kg. Checked bag 23 kg.';

      case 'SK':
        if (isTr) return 'SAS Go: 8 kg kabin bagajı (55x40x23 cm) + 1 kişisel eşya + 23 kg kayıtlı bagaj. SAS Go Light sadece koltuk altı çantası.';
        if (isDe) return 'SAS Go: 8 kg Handgepäck + 1 persönlicher Gegenstand + 23 kg Aufgabegepäck. Go Light nur Unter-Sitz-Tasche.';
        return 'SAS Go: 8 kg cabin bag + 1 personal item + 23 kg checked bag. SAS Go Light includes underseat bag only.';

      case 'AY':
        if (isTr) return 'Superlight: 1 koltuk altı çantası (40x30x15 cm). Light ve Classic: 1 kabin bagajı + kişisel eşya (kombine 8 kg) + 23 kg kayıtlı.';
        if (isDe) return 'Superlight: 1 Unter-Sitz-Tasche. Light/Classic: Handgepäck + Zubehör (kombiniert 8 kg) + 23 kg Aufgabe.';
        return 'Superlight: 1 underseat bag. Light & Classic: 1 cabin bag + personal item (combined 8 kg) + 23 kg checked.';

      case 'VY':
        if (isTr) return 'Temel bilet: 1 koltuk altı çantası (40x30x20 cm). TimeFlex veya ilave hak ile 10 kg kabin bagajı (55x40x20 cm).';
        if (isDe) return 'Basic: 1 Unter-Sitz-Tasche (40x30x20 cm). TimeFlex: + 10 kg Handgepäck (55x40x20 cm).';
        return 'Basic: 1 underseat bag (40x30x20 cm). TimeFlex: + 10 kg cabin bag (55x40x20 cm).';

      case 'DY':
        if (isTr) return 'LowFare: 1 koltuk altı çantası (38x30x20 cm, 10 kg). LowFare+: 1 baş üstü kabin çantası (55x40x23 cm, 10 kg) + 23 kg kayıtlı.';
        if (isDe) return 'LowFare: 1 Unter-Sitz-Tasche (10 kg). LowFare+: + 1 Handgepäck (55x40x23 cm, 10 kg) + 23 kg Aufgabe.';
        return 'LowFare: 1 underseat bag (10 kg). LowFare+: + 1 overhead cabin bag (55x40x23 cm, 10 kg) + 23 kg checked.';

      case 'NH':
      case 'JL':
        if (isTr) return '1 kabin bagajı ($cabinDimensions, 10 kg kombine) + 1 kişisel eşya. Uluslararası ekonomide 2 x 23 kg ücretsiz kayıtlı bagaj!';
        if (isDe) return '1 Handgepäck ($cabinDimensions, max. 10 kg kombiniert) + 1 Zubehör. 2 x 23 kg Freigepäck in Economy!';
        if (isFr) return '1 bagage cabine ($cabinDimensions, 10 kg combiné) + 1 accessoire. 2 x 23 kg en soute gratuits en classe Éco!';
        if (isEs) return '1 equipaje de mano ($cabinDimensions, 10 kg combinado) + 1 accesorio. ¡2 x 23 kg facturados gratis en turista!';
        if (isRu) return '1 место ручной клади ($cabinDimensions, 10 кг вместе с личной вещью). 2 x 23 кг бесплатного багажа!';
        return '1 carry-on ($cabinDimensions, 10 kg combined) + 1 personal item. Generous 2 x 23 kg free checked bags in Economy!';

      case 'ET':
        if (isTr) return '1 adet 7 kg kabin bagajı + 1 kişisel eşya. Uluslararası rotalarda ekonomi sınıfı için 2 x 23 kg kayıtlı bagaj.';
        if (isDe) return '1 Handgepäck (7 kg) + 1 Zubehör. 2 x 23 kg Aufgabegepäck auf internationalen Flügen in Economy.';
        return '1 cabin bag (7 kg) + 1 personal item. 2 x 23 kg checked baggage allowance on international economy routes.';

      case 'TG':
        if (isTr) return '1 adet 7 kg kabin bagajı (56x45x25 cm) + 1 kişisel eşya (37.5x25x12.5 cm, 3 kg). Saver 20 kg, Standard 30 kg, Flexi 35 kg kayıtlı bagaj.';
        if (isDe) return '1 Handgepäck (7 kg) + 1 persönlicher Gegenstand (3 kg). Saver 20 kg, Standard 30 kg, Flexi 35 kg.';
        if (isFr) return '1 bagage cabine (7 kg) + 1 accessoire (3 kg). Saver 20 kg, Standard 30 kg, Flexi 35 kg en soute.';
        if (isEs) return '1 equipaje de cabina (7 kg) + 1 artículo personal (3 kg). Saver 20 kg, Standard 30 kg, Flexi 35 kg facturado.';
        if (isRu) return '1 место ручной клади (7 кг) + 1 личная вещь (3 кг). Saver 20 кг, Standard 30 кг, Flexi 35 кг багаж.';
        return '1 cabin bag (7 kg, 56x45x25 cm) + 1 personal item (37.5x25x12.5 cm, 3 kg). Saver 20 kg, Standard 30 kg, Flexi 35 kg checked bag.';

      case 'MH':
        if (isTr) return '1 adet 7 kg kabin bagajı (56x36x23 cm) + 1 kişisel eşya (4 kg). Lite: 0 kg, Basic: 20 kg, Flex: 35 kg kayıtlı bagaj.';
        if (isDe) return '1 Handgepäck (7 kg) + 1 persönlicher Gegenstand (4 kg). Lite 0 kg, Basic 20 kg, Flex 35 kg.';
        return '1 cabin bag (7 kg) + 1 personal item (4 kg). Lite 0 kg, Basic 20 kg, Flex 35 kg checked bag.';

      case 'AK':
        if (isTr) return '1 kabin bagajı + 1 kişisel eşya (kombine toplam 7 kg, 56x36x23 cm). Value Pack & Flex: 20 kg kayıtlı bagaj.';
        if (isDe) return '1 Handgepäck + 1 persönlicher Gegenstand (kombiniert 7 kg). Value Pack & Flex: 20 kg Aufgabegepäck.';
        return '1 cabin bag + 1 personal item (combined 7 kg, 56x36x23 cm). Value Pack & Flex: 20 kg checked bag.';

      case 'AI':
        if (isTr) return '1 adet 7 kg kabin bagajı (55x35x25 cm) + 1 kişisel eşya (4 kg). Comfort 15 kg, Comfort Plus 20 kg, Flex 25 kg kayıtlı bagaj.';
        if (isDe) return '1 Handgepäck (7 kg) + 1 persönlicher Gegenstand. Comfort 15 kg, Comfort Plus 20 kg, Flex 25 kg.';
        return '1 cabin bag (7 kg) + 1 personal item (4 kg). Comfort 15 kg, Comfort Plus 20 kg, Flex 25 kg checked bag.';

      case 'FZ':
        if (isTr) return '1 adet 7 kg kabin bagajı (55x38x20 cm) + 1 kişisel eşya (3 kg). Lite 0 kg, Value 20 kg, Flex 30 kg kayıtlı bagaj.';
        if (isDe) return '1 Handgepäck (7 kg) + 1 persönlicher Gegenstand (3 kg). Lite 0 kg, Value 20 kg, Flex 30 kg.';
        return '1 cabin bag (7 kg) + 1 personal item (3 kg). Lite 0 kg, Value 20 kg, Flex 30 kg checked bag.';

      case 'NZ':
        if (isTr) return '1 adet 7 kg kabin bagajı (118 cm) + 1 kişisel eşya (4 kg). Seat: 0 kg, Seat + Bag / Flexi: 23 kg kayıtlı bagaj.';
        return '1 cabin bag (7 kg, 118 cm) + 1 personal item (4 kg). Seat: 0 kg, Seat + Bag / Flexi: 23 kg checked bag.';

      case 'RJ':
        if (isTr) return '1 adet 7 kg kabin bagajı (56x45x25 cm) + 1 kişisel eşya (4 kg). Light: 0 kg, Classic & Flex: 23 kg kayıtlı bagaj.';
        return '1 cabin bag (7 kg) + 1 personal item (4 kg). Light: 0 kg, Classic & Flex: 23 kg checked bag.';

      case 'MS':
        if (isTr) return '1 adet 8 kg kabin bagajı (55x40x23 cm) + 1 kişisel eşya. Good Deal: 23 kg, Fully Flexible: 2 x 23 kg kayıtlı bagaj.';
        return '1 cabin bag (8 kg) + 1 personal item. Good Deal: 23 kg, Fully Flexible: 2 x 23 kg checked bag.';
    }

    // Default dynamic localization for standard carriers
    final cabinKg = cabinLimitKg.toInt();
    final checkedKg = checkedLimitKg.toInt();

    if (isTr) {
      return '1 adet $cabinKg kg kabin bagajı ($cabinDimensions) + 1 kişisel eşya ($personalItemDimensions). Standart ekonomi kayıtlı bagaj $checkedKg kg.';
    } else if (isDe) {
      return '1 Handgepäck ($cabinKg kg, $cabinDimensions) + 1 persönlicher Gegenstand ($personalItemDimensions). Aufgabegepäck $checkedKg kg.';
    } else if (isFr) {
      return '1 bagage cabine ($cabinKg kg, $cabinDimensions) + 1 accessoire personnel ($personalItemDimensions). Soute $checkedKg kg.';
    } else if (isEs) {
      return '1 equipaje de mano ($cabinKg kg, $cabinDimensions) + 1 artículo personal ($personalItemDimensions). Equipaje facturado $checkedKg kg.';
    } else if (isIt) {
      return '1 bagaglio a mano ($cabinKg kg, $cabinDimensions) + 1 accessorio personale ($personalItemDimensions). Bagaglio in stiva $checkedKg kg.';
    } else if (isPt) {
      return '1 bagagem de cabine ($cabinKg kg, $cabinDimensions) + 1 item pessoal ($personalItemDimensions). Bagagem de porão $checkedKg kg.';
    } else if (isNl) {
      return '1 stuk handbagage ($cabinKg kg, $cabinDimensions) + 1 persoonlijk item ($personalItemDimensions). Ruimbagage $checkedKg kg.';
    } else if (isRu) {
      return '1 место ручной клади ($cabinKg кг, $cabinDimensions) + 1 личная вещь ($personalItemDimensions). Регистрируемый багаж $checkedKg кг.';
    } else if (isZh) {
      return '1件随身行李 ($cabinKg kg, $cabinDimensions) + 1件个人随身物品 ($personalItemDimensions)。标准托运行李 $checkedKg kg。';
    } else if (isJa) {
      return '機内持ち込み手荷物1個 ($cabinKg kg, $cabinDimensions) + 身の回り品1個 ($personalItemDimensions)。無料受託手荷物 $checkedKg kg。';
    } else if (isKo) {
      return '기내 수하물 1개 ($cabinKg kg, $cabinDimensions) + 개인 소지품 1개 ($personalItemDimensions). 일반 위탁 수하물 $checkedKg kg.';
    } else if (isAr) {
      return 'حقيبة مقصورة واحدة ($cabinKg كجم, $cabinDimensions) + حقيبة شخصية ($personalItemDimensions). الأمتعة المسجلة $checkedKg كجم.';
    }

    // Default clean fallback
    return notes.isNotEmpty
        ? notes
        : '1 cabin bag ($cabinKg kg, $cabinDimensions) + 1 personal item ($personalItemDimensions). Economy checked bag $checkedKg kg.';
  }
}

/// Directory of the World's Top 50+ Largest & Major Airlines Baggage Allowances
class AirlineBaggageRepository {
  AirlineBaggageRepository._();

  static const List<AirlineBaggageRule> airlines = [
    // --- TURKISH & REGIONAL MAJOR AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'Türk Hava Yolları',
      iataCode: 'TK',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 8 kg kabin bagajı + 1 kişisel eşya (40x30x15 cm). Ekonomi kayıtlı bagaj 23 kg.',
      packages: [
        AirlineFarePackage(
          id: 'TK_ECOFLY',
          name: 'EcoFly',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 15.0,
          description: '1 kabin (8 kg) + 1 kişisel eşya (4 kg) + 15 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'TK_EXTRAFLY',
          name: 'ExtraFly',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (8 kg) + 1 kişisel eşya (4 kg) + 20 kg kayıtlı bagaj + koltuk seçimi',
        ),
        AirlineFarePackage(
          id: 'TK_PRIMEFLY',
          name: 'PrimeFly',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 25.0,
          description: '1 kabin (8 kg) + 1 kişisel eşya (4 kg) + 25 kg kayıtlı bagaj + esnek değişiklik',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Pegasus Airlines',
      iataCode: 'PC',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemLimitKg: 3.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: 'Süper Eko pakette 1 koltuk altı çantası (40x30x15 cm 3 kg). Avantaj ve üzeri paketlerde 8 kg kabin bagajı + 20 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'PC_SUPER_EKO',
          name: 'Süper Eko',
          cabinLimitKg: 0.0,
          cabinDimensions: '-',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 koltuk altı çantası (40x30x15 cm, 3 kg). Kabin dolabı ve kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'PC_AVANTAJ',
          name: 'Avantaj',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 koltuk altı (3 kg) + 1 kabin bagajı (8 kg) + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'PC_COMFORT_FLEX',
          name: 'Comfort Flex',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 koltuk altı (3 kg) + 1 kabin bagajı (8 kg) + 20 kg kayıtlı bagaj + esnek iade',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'AJet (AnadoluJet)',
      iataCode: 'VF',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin bagajı + 1 el çantası (40x30x15 cm, 4 kg). Yurt içi 15-20 kg kayıtlı bagaj hakkı.',
      packages: [
        AirlineFarePackage(
          id: 'VF_BASIC',
          name: 'Basic',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya (4 kg). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'VF_ECOJET',
          name: 'EcoJet',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya (4 kg) + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'VF_FLEX',
          name: 'Flex',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (8 kg) + 1 kişisel eşya (4 kg) + 20 kg kayıtlı + değişiklik hakkı',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'SunExpress',
      iataCode: 'XQ',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin bagajı. Yurt içi 15-20 kg, uluslararası uçuşlarda 20-30 kg paketli bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'XQ_SUNECO',
          name: 'SunEco',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'XQ_SUNCLASSIC',
          name: 'SunClassic',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 25.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 25 kg kayıtlı bagaj + ikram',
        ),
        AirlineFarePackage(
          id: 'XQ_SUNPREMIUM',
          name: 'SunPremium',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj + premium koltuk',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Corendon Airlines',
      iataCode: 'XC',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 25 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin el bagajı dahildir. Kayıtlı bagaj pakete göre 20-32 kg arası değişir.',
      packages: [
        AirlineFarePackage(
          id: 'XC_ECO',
          name: 'Eco',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya. Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'XC_FLEXI',
          name: 'Flexi',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'XC_PREMIUM',
          name: 'Premium',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj + yemek',
        ),
      ],
    ),

    // --- NORTH AMERICA TOP AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'American Airlines',
      iataCode: 'AA',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on bag (56x36x23 cm) + 1 personal item (45x35x20 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Delta Air Lines',
      iataCode: 'DL',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 35 x 23 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 cabin bag + 1 personal item. No strict cabin weight limit on most routes (10 kg recommended). Checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'United Airlines',
      iataCode: 'UA',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 35 x 22 cm',
      personalItemDimensions: '43 x 25 x 22 cm',
      checkedLimitKg: 23.0,
      notes: 'Basic Economy excludes carry-on except intl routes. Regular Economy: 1 carry-on + 1 personal item. Checked 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Southwest Airlines',
      iataCode: 'WN',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '61 x 40 x 25 cm',
      personalItemDimensions: '41 x 34 x 22 cm',
      checkedLimitKg: 23.0,
      notes: '1 cabin bag (61x40x25 cm) + 1 personal item. Includes 2 free checked bags up to 23 kg each!',
    ),
    AirlineBaggageRule(
      airlineName: 'Air Canada',
      iataCode: 'AC',
      countryFlag: '🇨🇦',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '43 x 33 x 16 cm',
      checkedLimitKg: 23.0,
      notes: '1 standard bag (55x40x23 cm, 10 kg) + 1 personal item (43x33x16 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Alaska Airlines',
      iataCode: 'AS',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on bag (56x36x23 cm) + 1 personal item (45x35x20 cm). Economy checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'JetBlue Airways',
      iataCode: 'B6',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 35 x 23 cm',
      personalItemDimensions: '43 x 33 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'Blue fares include 1 carry-on + 1 personal item. Blue Basic includes personal item only. Checked 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Spirit Airlines',
      iataCode: 'NK',
      countryFlag: '🇺🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 46 x 25 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 18.0,
      notes: '1 free personal item (45x35x20 cm). Carry-on and checked bags (18 kg / 40 lbs) require additional fee.',
    ),
    AirlineBaggageRule(
      airlineName: 'WestJet',
      iataCode: 'WS',
      countryFlag: '🇨🇦',
      cabinLimitKg: 10.0,
      cabinDimensions: '53 x 38 x 21 cm',
      personalItemDimensions: '41 x 33 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on bag (53x38x21 cm) + 1 personal item (41x33x15 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Aeromexico',
      iataCode: 'AM',
      countryFlag: '🇲🇽',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 25 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on bag (55x40x25 cm, 10 kg) + 1 personal item. Standard checked bag 23 kg.',
    ),

    // --- EUROPE TOP AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'Ryanair',
      iataCode: 'FR',
      countryFlag: '🇮🇪',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 25 x 20 cm',
      checkedLimitKg: 20.0,
      notes: 'Standart bilette sadece koltuk altı küçük çanta (40x25x20 cm). Priority ile 10 kg baş üstü kabin hakkı.',
      packages: [
        AirlineFarePackage(
          id: 'FR_BASIC',
          name: 'Basic',
          cabinLimitKg: 0.0,
          cabinDimensions: '-',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 25 x 20 cm',
          checkedLimitKg: 0.0,
          description: 'Sadece 1 koltuk altı küçük çanta (40x25x20 cm). Baş üstü kabin ve kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'FR_REGULAR',
          name: 'Regular / Priority',
          cabinLimitKg: 10.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 25 x 20 cm',
          checkedLimitKg: 0.0,
          description: '1 koltuk altı (40x25x20 cm) + 10 kg baş üstü kabin (55x40x20 cm) + öncelikli biniş',
        ),
        AirlineFarePackage(
          id: 'FR_PLUS',
          name: 'Plus',
          cabinLimitKg: 10.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 25 x 20 cm',
          checkedLimitKg: 20.0,
          description: '1 koltuk altı + 10 kg kabin + 20 kg kayıtlı bagaj + koltuk seçimi',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Lufthansa',
      iataCode: 'LH',
      countryFlag: '🇩🇪',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 23.0,
      notes: 'Ekonomi sınıfı için 1 adet 8 kg kabin bagajı + 1 küçük kişisel çanta (40x30x10 cm). Kayıtlı bagaj 23 kg.',
      packages: [
        AirlineFarePackage(
          id: 'LH_LIGHT',
          name: 'Economy Light',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya (40x30x10 cm). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'LH_CLASSIC',
          name: 'Economy Classic',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 23 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'LH_FLEX',
          name: 'Economy Flex',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin (8 kg) + 1 kişisel eşya + 23 kg kayıtlı bagaj + esnek değişiklik',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'British Airways',
      iataCode: 'BA',
      countryFlag: '🇬🇧',
      cabinLimitKg: 23.0,
      cabinDimensions: '56 x 45 x 25 cm',
      personalItemLimitKg: 23.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 23 kg kabin çantası + 1 adet 23 kg dizüstü / el çantası (40x30x15 cm). Kayıtlı bagaj 23 kg.',
      packages: [
        AirlineFarePackage(
          id: 'BA_BASIC',
          name: 'Economy Basic',
          cabinLimitKg: 23.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 23.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin çantası (23 kg) + 1 kişisel el çantası (23 kg). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'BA_PLUS',
          name: 'Economy Plus',
          cabinLimitKg: 23.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 23.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin çantası (23 kg) + 1 kişisel çanta (23 kg) + 23 kg kayıtlı bagaj',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Air France',
      iataCode: 'AF',
      countryFlag: '🇫🇷',
      cabinLimitKg: 12.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 kabin çantası + 1 aksesuarın toplam kombine ağırlığı en fazla 12 kg olmalıdır. Kayıtlı bagaj 23 kg.',
      packages: [
        AirlineFarePackage(
          id: 'AF_LIGHT',
          name: 'Economy Light',
          cabinLimitKg: 12.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı + 1 aksesuar (toplam kombine 12 kg). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'AF_STANDARD',
          name: 'Economy Standard',
          cabinLimitKg: 12.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin + 1 aksesuar (kombine 12 kg) + 23 kg kayıtlı bagaj',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'KLM Royal Dutch Airlines',
      iataCode: 'KL',
      countryFlag: '🇳🇱',
      cabinLimitKg: 12.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 kabin çantası + 1 aksesuar kombine maksimum 12 kg. Standart ekonomi kayıtlı bagaj 23 kg.',
      packages: [
        AirlineFarePackage(
          id: 'KL_LIGHT',
          name: 'Economy Light',
          cabinLimitKg: 12.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı + 1 aksesuar (kombine 12 kg). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'KL_STANDARD',
          name: 'Economy Standard',
          cabinLimitKg: 12.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin + 1 aksesuar (kombine 12 kg) + 23 kg kayıtlı bagaj',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'easyJet',
      iataCode: 'U2',
      countryFlag: '🇬🇧',
      cabinLimitKg: 15.0,
      cabinDimensions: '45 x 36 x 20 cm',
      personalItemLimitKg: 15.0,
      personalItemDimensions: '45 x 36 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'Standart bilet koltuk altı çantası (maks 15 kg). Büyük kabin çantası için Speedy Boarding veya ekstra bacak alanı gerekir.',
      packages: [
        AirlineFarePackage(
          id: 'U2_STANDARD',
          name: 'Standard',
          cabinLimitKg: 0.0,
          cabinDimensions: '-',
          personalItemLimitKg: 15.0,
          personalItemDimensions: '45 x 36 x 20 cm',
          checkedLimitKg: 0.0,
          description: '1 koltuk altı çantası (45x36x20 cm, maks 15 kg). Baş üstü dolap hakkı yok',
        ),
        AirlineFarePackage(
          id: 'U2_SPEEDY',
          name: 'Speedy / Large Cabin',
          cabinLimitKg: 15.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 15.0,
          personalItemDimensions: '45 x 36 x 20 cm',
          checkedLimitKg: 0.0,
          description: '1 koltuk altı çantası + 15 kg büyük baş üstü kabin çantası (56x45x25 cm)',
        ),
        AirlineFarePackage(
          id: 'U2_FLEXI',
          name: 'FLEXI',
          cabinLimitKg: 15.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 15.0,
          personalItemDimensions: '45 x 36 x 20 cm',
          checkedLimitKg: 23.0,
          description: '1 koltuk altı + 15 kg kabin + 23 kg kayıtlı bagaj + Speedy Boarding',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Wizz Air',
      iataCode: 'W6',
      countryFlag: '🇭🇺',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemLimitKg: 10.0,
      personalItemDimensions: '40 x 30 x 20 cm',
      checkedLimitKg: 20.0,
      notes: 'Ücretsiz 1 adet koltuk altı çantası (40x30x20 cm). WIZZ Priority ile 10 kg tekerlekli kabin bagajı.',
      packages: [
        AirlineFarePackage(
          id: 'W6_BASIC',
          name: 'Basic',
          cabinLimitKg: 0.0,
          cabinDimensions: '-',
          personalItemLimitKg: 10.0,
          personalItemDimensions: '40 x 30 x 20 cm',
          checkedLimitKg: 0.0,
          description: 'Ücretsiz 1 koltuk altı çantası (40x30x20 cm, maks 10 kg). Baş üstü kabin yok',
        ),
        AirlineFarePackage(
          id: 'W6_PRIORITY',
          name: 'WIZZ Priority',
          cabinLimitKg: 10.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 10.0,
          personalItemDimensions: '40 x 30 x 20 cm',
          checkedLimitKg: 0.0,
          description: '1 koltuk altı çantası + 10 kg tekerlekli baş üstü kabin bagajı + öncelikli biniş',
        ),
        AirlineFarePackage(
          id: 'W6_PLUS',
          name: 'WIZZ Plus',
          cabinLimitKg: 10.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 10.0,
          personalItemDimensions: '40 x 30 x 20 cm',
          checkedLimitKg: 20.0,
          description: '1 koltuk altı + 10 kg kabin + 20 kg kayıtlı bagaj + koltuk seçimi',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Iberia',
      iataCode: 'IB',
      countryFlag: '🇪🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 40 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 cabin bag (56x40x25 cm, 10 kg) + 1 personal accessory (40x30x15 cm). Checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Swiss International Air Lines',
      iataCode: 'LX',
      countryFlag: '🇨🇭',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (8 kg) + 1 small personal item (40x30x10 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Austrian Airlines',
      iataCode: 'OS',
      countryFlag: '🇦🇹',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (8 kg) + 1 personal item (40x30x10 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Scandinavian Airlines (SAS)',
      iataCode: 'SK',
      countryFlag: '🇸🇪',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'SAS Go: 8 kg cabin bag + 1 personal item + 23 kg checked. SAS Go Light includes underseat bag only.',
    ),
    AirlineBaggageRule(
      airlineName: 'TAP Air Portugal',
      iataCode: 'TP',
      countryFlag: '🇵🇹',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (8 kg) + 1 personal item (2 kg, 40x30x15 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Finnair',
      iataCode: 'AY',
      countryFlag: '🇫🇮',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Superlight: underseat bag only. Light/Classic: 1 cabin bag + personal item (combined 8 kg) + 23 kg checked.',
    ),
    AirlineBaggageRule(
      airlineName: 'Vueling Airlines',
      iataCode: 'VY',
      countryFlag: '🇪🇸',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 20 cm',
      checkedLimitKg: 25.0,
      notes: 'Basic: 1 underseat bag (40x30x20 cm). TimeFlex/Extra: 10 kg overhead cabin bag (55x40x20 cm). Checked 25 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Norwegian Air Shuttle',
      iataCode: 'DY',
      countryFlag: '🇳🇴',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '38 x 30 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'LowFare: 1 underseat bag (10 kg). LowFare+: 1 overhead cabin bag (10 kg) + 23 kg checked bag.',
    ),
    AirlineBaggageRule(
      airlineName: 'Virgin Atlantic',
      iataCode: 'VS',
      countryFlag: '🇬🇧',
      cabinLimitKg: 10.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy Classic/Delight: 1 cabin bag (10 kg) + 1 personal handbag/backpack. Checked bag 23 kg.',
    ),

    // --- MIDDLE EAST & GULF AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'Emirates',
      iataCode: 'EK',
      countryFlag: '🇦🇪',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 38 x 22 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj hakkı bulunur.',
      packages: [
        AirlineFarePackage(
          id: 'EK_SPECIAL',
          name: 'Special',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 22 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'EK_SAVER',
          name: 'Saver',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 22 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 25.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 25 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'EK_FLEX',
          name: 'Flex',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 22 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'EK_FLEX_PLUS',
          name: 'Flex Plus',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 22 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 35.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 35 kg kayıtlı bagaj + esnek bilet',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Qatar Airways',
      iataCode: 'QR',
      countryFlag: '🇶🇦',
      cabinLimitKg: 7.0,
      cabinDimensions: '50 x 37 x 25 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi yolcuları için 1 parça 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'QR_CLASSIC',
          name: 'Classic',
          cabinLimitKg: 7.0,
          cabinDimensions: '50 x 37 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 25.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 25 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'QR_CONVENIENCE',
          name: 'Convenience',
          cabinLimitKg: 7.0,
          cabinDimensions: '50 x 37 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'QR_COMFORT',
          name: 'Comfort',
          cabinLimitKg: 7.0,
          cabinDimensions: '50 x 37 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 35.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 35 kg kayıtlı bagaj + koltuk seçimi',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'flydubai',
      iataCode: 'FZ',
      countryFlag: '🇦🇪',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 38 x 20 cm',
      personalItemLimitKg: 3.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 7 kg kabin bagajı (55x38x20 cm) + 1 kişisel eşya (3 kg). Lite 0 kg, Value 20 kg, Flex 30 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'FZ_LITE',
          name: 'Lite',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 20 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin çantası (7 kg) + 1 kişisel eşya. Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'FZ_VALUE',
          name: 'Value',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 20 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 20 kg kayıtlı bagaj + yemek',
        ),
        AirlineFarePackage(
          id: 'FZ_FLEX',
          name: 'Flex',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 38 x 20 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj + esnek bilet',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Royal Jordanian',
      iataCode: 'RJ',
      countryFlag: '🇯🇴',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 45 x 25 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 7 kg kabin bagajı (56x45x25 cm) + 1 kişisel eşya (4 kg). Light: 0 kg, Classic & Flex: 23 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'RJ_LIGHT',
          name: 'Economy Light',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı (7 kg) + 1 kişisel eşya. Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'RJ_CLASSIC',
          name: 'Economy Classic',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 23 kg kayıtlı bagaj',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Etihad Airways',
      iataCode: 'EY',
      countryFlag: '🇦🇪',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '39 x 23 x 19 cm',
      checkedLimitKg: 30.0,
      notes: 'Economy: 1 cabin bag (7 kg) + 1 personal item (5 kg, 39x23x19 cm). Standard checked bag 23-30 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Saudia',
      iataCode: 'SV',
      countryFlag: '🇸🇦',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 45 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Guest Class: 1 cabin bag (7 kg) + 1 personal accessory. Checked baggage allowance 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'EgyptAir',
      iataCode: 'MS',
      countryFlag: '🇪🇬',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 8 kg kabin bagajı (55x40x23 cm) + 1 kişisel eşya. Good Deal: 23 kg, Fully Flexible: 2 x 23 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'MS_DEAL',
          name: 'Good Deal',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 23.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 23 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'MS_FLEX',
          name: 'Fully Flexible',
          cabinLimitKg: 8.0,
          cabinDimensions: '55 x 40 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 46.0,
          description: '1 kabin bagajı (8 kg) + 1 kişisel eşya + 2 x 23 kg kayıtlı bagaj',
        ),
      ],
    ),

    // --- ASIA & OCEANIA TOP AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'Thai Airways',
      iataCode: 'TG',
      countryFlag: '🇹🇭',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 45 x 25 cm',
      personalItemLimitKg: 3.0,
      personalItemDimensions: '37.5 x 25 x 12.5 cm',
      checkedLimitKg: 30.0,
      notes: '1 adet 7 kg kabin bagajı (56x45x25 cm) + 1 kişisel eşya (37.5x25x12.5 cm, 3 kg). Saver 20 kg, Standard 30 kg, Flexi 35 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'TG_SAVER',
          name: 'Saver',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '37.5 x 25 x 12.5 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya (3 kg) + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'TG_STANDARD',
          name: 'Standard',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '37.5 x 25 x 12.5 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya (3 kg) + 30 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'TG_FLEXI',
          name: 'Flexi',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 45 x 25 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '37.5 x 25 x 12.5 cm',
          checkedLimitKg: 35.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya (3 kg) + 35 kg kayıtlı bagaj + esnek değişiklik',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Singapore Airlines',
      iataCode: 'SQ',
      countryFlag: '🇸🇬',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 1 kişisel eşya (40x30x10 cm). Kayıtlı bagaj 25-30 kg.',
      packages: [
        AirlineFarePackage(
          id: 'SQ_LITE',
          name: 'Economy Lite',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 25.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 25 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'SQ_STANDARD',
          name: 'Economy Standard',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'SQ_FLEXI',
          name: 'Economy Flexi',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 40 x 20 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 30.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 30 kg kayıtlı bagaj + koltuk seçimi',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Malaysia Airlines',
      iataCode: 'MH',
      countryFlag: '🇲🇾',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 7 kg kabin bagajı (56x36x23 cm) + 1 kişisel eşya (4 kg). Lite: 0 kg, Basic: 20 kg, Flex: 35 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'MH_LITE',
          name: 'Economy Lite',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin bagajı (7 kg) + 1 kişisel eşya (4 kg). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'MH_BASIC',
          name: 'Economy Basic',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'MH_FLEX',
          name: 'Economy Flex',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 35.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 35 kg kayıtlı bagaj + esnek bilet',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'AirAsia',
      iataCode: 'AK',
      countryFlag: '🇲🇾',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemLimitKg: 3.0,
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 20.0,
      notes: '1 kabin bagajı + 1 kişisel eşya (kombine toplam 7 kg, 56x36x23 cm). Value Pack & Flex: 20 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'AK_LOW_FARE',
          name: 'Low Fare',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 0.0,
          description: '1 kabin + 1 kişisel eşya (kombine 7 kg). Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'AK_VALUE_PACK',
          name: 'Value Pack',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin + kişisel (7 kg) + 20 kg kayıtlı bagaj + yemek',
        ),
        AirlineFarePackage(
          id: 'AK_PREMIUM_FLEX',
          name: 'Premium Flex',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 3.0,
          personalItemDimensions: '40 x 30 x 10 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin + kişisel (7 kg) + 20 kg kayıtlı bagaj + esnek değişiklik',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Air India',
      iataCode: 'AI',
      countryFlag: '🇮🇳',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 7 kg kabin bagajı (55x35x25 cm) + 1 kişisel eşya (4 kg). Comfort 15 kg, Comfort Plus 20 kg, Flex 25 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'AI_COMFORT',
          name: 'Comfort',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 15.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 15-20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'AI_COMFORT_PLUS',
          name: 'Comfort Plus',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 20.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 20 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'AI_FLEX',
          name: 'Flex',
          cabinLimitKg: 7.0,
          cabinDimensions: '55 x 35 x 25 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '40 x 30 x 15 cm',
          checkedLimitKg: 25.0,
          description: '1 kabin (7 kg) + 1 kişisel eşya + 25 kg kayıtlı bagaj + değişiklik hakkı',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'Air New Zealand',
      iataCode: 'NZ',
      countryFlag: '🇳🇿',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemLimitKg: 4.0,
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 7 kg kabin bagajı (56x36x23 cm) + 1 kişisel eşya (4 kg). Seat: 0 kg, Seat + Bag / Flexi: 23 kg kayıtlı bagaj.',
      packages: [
        AirlineFarePackage(
          id: 'NZ_SEAT',
          name: 'Seat',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '45 x 35 x 20 cm',
          checkedLimitKg: 0.0,
          description: '1 cabin bag (7 kg) + 1 personal item. Kayıtlı bagaj yok',
        ),
        AirlineFarePackage(
          id: 'NZ_SEAT_BAG',
          name: 'Seat + Bag',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '45 x 35 x 20 cm',
          checkedLimitKg: 23.0,
          description: '1 cabin bag (7 kg) + 1 personal item + 23 kg kayıtlı bagaj',
        ),
        AirlineFarePackage(
          id: 'NZ_FLEXI',
          name: 'flexichange',
          cabinLimitKg: 7.0,
          cabinDimensions: '56 x 36 x 23 cm',
          personalItemLimitKg: 4.0,
          personalItemDimensions: '45 x 35 x 20 cm',
          checkedLimitKg: 23.0,
          description: '1 cabin bag (7 kg) + 1 personal item + 23 kg kayıtlı bagaj + esneklik',
        ),
      ],
    ),
    AirlineBaggageRule(
      airlineName: 'All Nippon Airways (ANA)',
      iataCode: 'NH',
      countryFlag: '🇯🇵',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 cabin bag (10 kg combined) + 1 personal item. Generous 2 x 23 kg free checked bags on international flights!',
    ),
    AirlineBaggageRule(
      airlineName: 'Japan Airlines (JAL)',
      iataCode: 'JL',
      countryFlag: '🇯🇵',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on (10 kg combined) + 1 personal item. Free 2 x 23 kg checked baggage in Economy!',
    ),
    AirlineBaggageRule(
      airlineName: 'Cathay Pacific',
      iataCode: 'CX',
      countryFlag: '🇭🇰',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (7 kg) + 1 small personal item (40x30x15 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Korean Air',
      iataCode: 'KE',
      countryFlag: '🇰🇷',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag + personal item (total 10 kg). Checked baggage allowance 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'China Southern Airlines',
      iataCode: 'CZ',
      countryFlag: '🇨🇳',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 piece of 8 kg cabin bag (55x40x20 cm) + 1 personal item. Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'China Eastern Airlines',
      iataCode: 'MU',
      countryFlag: '🇨🇳',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (8 kg) + 1 personal item. Standard international checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Air China',
      iataCode: 'CA',
      countryFlag: '🇨🇳',
      cabinLimitKg: 5.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (5 kg, 55x40x20 cm) + 1 personal item. Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'IndiGo',
      iataCode: '6E',
      countryFlag: '🇮🇳',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 15.0,
      notes: '1 cabin bag (7 kg) + 1 small handbag/laptop (3 kg). Domestic checked 15 kg, international 20-30 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Qantas',
      iataCode: 'QF',
      countryFlag: '🇦🇺',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 30.0,
      notes: 'Economy: 1 cabin bag (7 kg) + 1 personal item. Standard international checked bag 30 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'EVA Air',
      iataCode: 'BR',
      countryFlag: '🇹🇼',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (7 kg) + 1 personal item (40x30x10 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Vietnam Airlines',
      iataCode: 'VN',
      countryFlag: '🇻🇳',
      cabinLimitKg: 12.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 cabin bag (10 kg) + 1 accessory (total 12 kg). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Garuda Indonesia',
      iataCode: 'GA',
      countryFlag: '🇮🇩',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 30.0,
      notes: 'Economy: 1 cabin bag (7 kg) + 1 personal item. Generous checked bag allowance up to 30 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Cebu Pacific',
      iataCode: '5J',
      countryFlag: '🇵🇭',
      cabinLimitKg: 7.0,
      cabinDimensions: '56 x 36 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 carry-on bag (7 kg, 56x36x23 cm) + 1 small personal item. Checked baggage can be added up to 20-32 kg.',
    ),

    // --- LATIN AMERICA & AFRICA AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'LATAM Airlines',
      iataCode: 'LA',
      countryFlag: '🇨🇱',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'Economy: 1 carry-on (10 kg) + 1 personal item (45x35x20 cm). Standard checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Avianca',
      iataCode: 'AV',
      countryFlag: '🇨🇴',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'Basic: 1 personal item. Classic & above: 1 cabin bag (10 kg) + 23 kg checked baggage.',
    ),
    AirlineBaggageRule(
      airlineName: 'GOL Linhas Aéreas',
      iataCode: 'G3',
      countryFlag: '🇧🇷',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '43 x 32 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on bag (10 kg, 55x35x25 cm) + 1 personal item (43x32x20 cm). Checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Azul Brazilian Airlines',
      iataCode: 'AD',
      countryFlag: '🇧🇷',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '45 x 35 x 20 cm',
      checkedLimitKg: 23.0,
      notes: '1 carry-on bag (10 kg) + 1 personal item (45x35x20 cm). Economy checked bag 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Ethiopian Airlines',
      iataCode: 'ET',
      countryFlag: '🇪🇹',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 cabin bag (7 kg) + 1 personal item. 2 x 23 kg checked baggage allowance on international routes.',
    ),
  ];

  /// Resolves default airline (Turkish Airlines)
  static AirlineBaggageRule get defaultAirline => airlines.first;

  /// Looks up airline by name or code
  /// Looks up airline by name, code or alias
  static AirlineBaggageRule? findByQuery(String query) {
    final q = query.trim().toLowerCase();
    // 1. Exact IATA code match
    for (final a in airlines) {
      if (a.iataCode.toLowerCase() == q) return a;
    }
    // 2. Exact alias match
    if (q == 'thy' || q.contains('turkish')) {
      for (final a in airlines) {
        if (a.iataCode == 'TK') return a;
      }
    }
    if (q == 'ana') {
      for (final a in airlines) {
        if (a.iataCode == 'NH') return a;
      }
    }
    if (q == 'jal') {
      for (final a in airlines) {
        if (a.iataCode == 'JL') return a;
      }
    }
    if (q == 'sas') {
      for (final a in airlines) {
        if (a.iataCode == 'SK') return a;
      }
    }
    if (q == 'thai' || q == 'thai airways' || q == 'tg') {
      for (final a in airlines) {
        if (a.iataCode == 'TG') return a;
      }
    }
    if (q == 'malaysia' || q == 'malaysia airlines' || q == 'mas' || q == 'mh') {
      for (final a in airlines) {
        if (a.iataCode == 'MH') return a;
      }
    }
    if (q == 'airasia' || q == 'air asia' || q == 'ak') {
      for (final a in airlines) {
        if (a.iataCode == 'AK') return a;
      }
    }
    if (q == 'flydubai' || q == 'fly dubai' || q == 'fz') {
      for (final a in airlines) {
        if (a.iataCode == 'FZ') return a;
      }
    }
    if (q == 'air india' || q == 'airindia' || q == 'ai') {
      for (final a in airlines) {
        if (a.iataCode == 'AI') return a;
      }
    }
    if (q == 'air new zealand' || q == 'airnz' || q == 'nz') {
      for (final a in airlines) {
        if (a.iataCode == 'NZ') return a;
      }
    }
    if (q == 'royal jordanian' || q == 'rj') {
      for (final a in airlines) {
        if (a.iataCode == 'RJ') return a;
      }
    }
    if (q == 'egyptair' || q == 'egypt air' || q == 'ms') {
      for (final a in airlines) {
        if (a.iataCode == 'MS') return a;
      }
    }

    // 3. Substring match on airline name
    for (final a in airlines) {
      if (a.airlineName.toLowerCase().contains(q)) {
        return a;
      }
    }
    return null;
  }
}
