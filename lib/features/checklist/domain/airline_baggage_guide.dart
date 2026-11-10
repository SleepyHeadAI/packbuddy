/// Airline Baggage rule entity
class AirlineBaggageRule {
  final String airlineName;
  final String iataCode;
  final String countryFlag;
  final double cabinLimitKg;
  final String cabinDimensions;
  final double checkedLimitKg;
  final String personalItemDimensions;
  final String notes;

  const AirlineBaggageRule({
    required this.airlineName,
    required this.iataCode,
    required this.countryFlag,
    required this.cabinLimitKg,
    required this.cabinDimensions,
    required this.checkedLimitKg,
    this.personalItemDimensions = '40 x 30 x 15 cm',
    required this.notes,
  });

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
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 8 kg kabin bagajı + 1 kişisel eşya (40x30x15 cm). Ekonomi kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Pegasus Airlines',
      iataCode: 'PC',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: 'Süper Eko pakette 1 koltuk altı çantası (40x30x15 cm 3 kg). Avantaj ve üzeri paketlerde 8 kg kabin bagajı + 20 kg kayıtlı bagaj.',
    ),
    AirlineBaggageRule(
      airlineName: 'AJet (AnadoluJet)',
      iataCode: 'VF',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin bagajı + 1 el çantası (40x30x15 cm, 4 kg). Yurt içi 15-20 kg kayıtlı bagaj hakkı.',
    ),
    AirlineBaggageRule(
      airlineName: 'SunExpress',
      iataCode: 'XQ',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin bagajı. Yurt içi 15-20 kg, uluslararası uçuşlarda 20-30 kg paketli bagaj.',
    ),
    AirlineBaggageRule(
      airlineName: 'Corendon Airlines',
      iataCode: 'XC',
      countryFlag: '🇹🇷',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 20.0,
      notes: '1 adet 8 kg kabin el bagajı dahildir. Kayıtlı bagaj pakete göre 20-32 kg arası değişir.',
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
      personalItemDimensions: '40 x 25 x 20 cm',
      checkedLimitKg: 20.0,
      notes: 'Standart bilette sadece koltuk altı küçük çanta (40x25x20 cm). Priority ile 10 kg baş üstü kabin hakkı.',
    ),
    AirlineBaggageRule(
      airlineName: 'Lufthansa',
      iataCode: 'LH',
      countryFlag: '🇩🇪',
      cabinLimitKg: 8.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 23.0,
      notes: 'Ekonomi sınıfı için 1 adet 8 kg kabin bagajı + 1 küçük kişisel çanta (40x30x10 cm). Kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'British Airways',
      iataCode: 'BA',
      countryFlag: '🇬🇧',
      cabinLimitKg: 23.0,
      cabinDimensions: '56 x 45 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 adet 23 kg kabin çantası + 1 adet 23 kg dizüstü / el çantası (40x30x15 cm). Kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'Air France',
      iataCode: 'AF',
      countryFlag: '🇫🇷',
      cabinLimitKg: 12.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 kabin çantası + 1 aksesuarın toplam kombine ağırlığı en fazla 12 kg olmalıdır. Kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'KLM Royal Dutch Airlines',
      iataCode: 'KL',
      countryFlag: '🇳🇱',
      cabinLimitKg: 12.0,
      cabinDimensions: '55 x 35 x 25 cm',
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 23.0,
      notes: '1 kabin çantası + 1 aksesuar kombine maksimum 12 kg. Standart ekonomi kayıtlı bagaj 23 kg.',
    ),
    AirlineBaggageRule(
      airlineName: 'easyJet',
      iataCode: 'U2',
      countryFlag: '🇬🇧',
      cabinLimitKg: 15.0,
      cabinDimensions: '45 x 36 x 20 cm',
      personalItemDimensions: '45 x 36 x 20 cm',
      checkedLimitKg: 23.0,
      notes: 'Standart bilet koltuk altı çantası (maks 15 kg). Büyük kabin çantası için Speedy Boarding veya ekstra bacak alanı gerekir.',
    ),
    AirlineBaggageRule(
      airlineName: 'Wizz Air',
      iataCode: 'W6',
      countryFlag: '🇭🇺',
      cabinLimitKg: 10.0,
      cabinDimensions: '55 x 40 x 23 cm',
      personalItemDimensions: '40 x 30 x 20 cm',
      checkedLimitKg: 20.0,
      notes: 'Ücretsiz 1 adet koltuk altı çantası (40x30x20 cm). WIZZ Priority ile 10 kg tekerlekli kabin bagajı.',
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
      personalItemDimensions: '40 x 30 x 15 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj hakkı bulunur.',
    ),
    AirlineBaggageRule(
      airlineName: 'Qatar Airways',
      iataCode: 'QR',
      countryFlag: '🇶🇦',
      cabinLimitKg: 7.0,
      cabinDimensions: '50 x 37 x 25 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi yolcuları için 1 parça 7 kg kabin bagajı + 25-30 kg kayıtlı bagaj.',
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

    // --- ASIA & OCEANIA TOP AIRLINES ---
    AirlineBaggageRule(
      airlineName: 'Singapore Airlines',
      iataCode: 'SQ',
      countryFlag: '🇸🇬',
      cabinLimitKg: 7.0,
      cabinDimensions: '55 x 40 x 20 cm',
      personalItemDimensions: '40 x 30 x 10 cm',
      checkedLimitKg: 30.0,
      notes: 'Ekonomi sınıfı için 1 adet 7 kg kabin bagajı + 1 kişisel eşya (40x30x10 cm). Kayıtlı bagaj 25-30 kg.',
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

    // 3. Substring match on airline name
    for (final a in airlines) {
      if (a.airlineName.toLowerCase().contains(q)) {
        return a;
      }
    }
    return null;
  }
}
