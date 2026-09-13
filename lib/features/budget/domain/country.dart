/// Domain entity representing a Country for travel destination routes
class Country {
  final String code;
  final String name;
  final String localName;
  final String flag;
  final String defaultCurrency;
  final List<String> popularDestinations;

  const Country({
    required this.code,
    required this.name,
    required this.localName,
    required this.flag,
    required this.defaultCurrency,
    this.popularDestinations = const [],
  });

  /// Master directory of world travel destinations
  static const List<Country> allCountries = [
    Country(
      code: 'TR',
      name: 'Turkey',
      localName: 'Türkiye',
      flag: '🇹🇷',
      defaultCurrency: 'TRY',
      popularDestinations: ['İstanbul', 'Antalya', 'Kapadokya', 'İzmir', 'Bodrum'],
    ),
    Country(
      code: 'IT',
      name: 'Italy',
      localName: 'İtalya',
      flag: '🇮🇹',
      defaultCurrency: 'EUR',
      popularDestinations: ['Roma', 'Venedik', 'Floransa', 'Milano', 'Amalfi'],
    ),
    Country(
      code: 'FR',
      name: 'France',
      localName: 'Fransa',
      flag: '🇫🇷',
      defaultCurrency: 'EUR',
      popularDestinations: ['Paris', 'Nice', 'Lyon', 'Marsilya', 'Bordeaux'],
    ),
    Country(
      code: 'ES',
      name: 'Spain',
      localName: 'İspanya',
      flag: '🇪🇸',
      defaultCurrency: 'EUR',
      popularDestinations: ['Barselona', 'Madrid', 'Sevilla', 'Valensiya', 'İbiza'],
    ),
    Country(
      code: 'DE',
      name: 'Germany',
      localName: 'Almanya',
      flag: '🇩🇪',
      defaultCurrency: 'EUR',
      popularDestinations: ['Berlin', 'Münih', 'Frankfurt', 'Hamburg', 'Köln'],
    ),
    Country(
      code: 'GB',
      name: 'United Kingdom',
      localName: 'Birleşik Krallık',
      flag: '🇬🇧',
      defaultCurrency: 'GBP',
      popularDestinations: ['Londra', 'Edinburgh', 'Manchester', 'Oxford', 'Liverpool'],
    ),
    Country(
      code: 'US',
      name: 'United States',
      localName: 'Amerika Birleşik Devletleri',
      flag: '🇺🇸',
      defaultCurrency: 'USD',
      popularDestinations: ['New York', 'Los Angeles', 'Miami', 'San Francisco', 'Las Vegas'],
    ),
    Country(
      code: 'JP',
      name: 'Japan',
      localName: 'Japonya',
      flag: '🇯🇵',
      defaultCurrency: 'JPY',
      popularDestinations: ['Tokyo', 'Kyoto', 'Osaka', 'Hiroşima', 'Sapporo'],
    ),
    Country(
      code: 'GR',
      name: 'Greece',
      localName: 'Yunanistan',
      flag: '🇬🇷',
      defaultCurrency: 'EUR',
      popularDestinations: ['Atina', 'Santorini', 'Mikonos', 'Girit', 'Selanik'],
    ),
    Country(
      code: 'PT',
      name: 'Portugal',
      localName: 'Portekiz',
      flag: '🇵🇹',
      defaultCurrency: 'EUR',
      popularDestinations: ['Lizbon', 'Porto', 'Algarve', 'Sintra', 'Madeira'],
    ),
    Country(
      code: 'NL',
      name: 'Netherlands',
      localName: 'Hollanda',
      flag: '🇳🇱',
      defaultCurrency: 'EUR',
      popularDestinations: ['Amsterdam', 'Rotterdam', 'Lahey', 'Utrecht'],
    ),
    Country(
      code: 'CH',
      name: 'Switzerland',
      localName: 'İsviçre',
      flag: '🇨🇭',
      defaultCurrency: 'CHF',
      popularDestinations: ['Zürih', 'Cenevre', 'Luzern', 'Interlaken', 'Zermatt'],
    ),
    Country(
      code: 'AT',
      name: 'Austria',
      localName: 'Avusturya',
      flag: '🇦🇹',
      defaultCurrency: 'EUR',
      popularDestinations: ['Viyana', 'Salzburg', 'Innsbruck', 'Hallstatt'],
    ),
    Country(
      code: 'TH',
      name: 'Thailand',
      localName: 'Tayland',
      flag: '🇹🇭',
      defaultCurrency: 'THB',
      popularDestinations: ['Bangkok', 'Phuket', 'Chiang Mai', 'Koh Samui', 'Pattaya'],
    ),
    Country(
      code: 'AE',
      name: 'United Arab Emirates',
      localName: 'Birleşik Arap Emirlikleri',
      flag: '🇦🇪',
      defaultCurrency: 'AED',
      popularDestinations: ['Dubai', 'Abu Dabi', 'Şarika'],
    ),
    Country(
      code: 'EG',
      name: 'Egypt',
      localName: 'Mısır',
      flag: '🇪🇬',
      defaultCurrency: 'EGP',
      popularDestinations: ['Kahire', 'Şarm El-Şeyh', 'Hurgada', 'Luksor', 'Gize'],
    ),
    Country(
      code: 'KR',
      name: 'South Korea',
      localName: 'Güney Kore',
      flag: '🇰🇷',
      defaultCurrency: 'KRW',
      popularDestinations: ['Seul', 'Busan', 'Jeju Adası', 'Incheon'],
    ),
    Country(
      code: 'ID',
      name: 'Indonesia',
      localName: 'Endonezya',
      flag: '🇮🇩',
      defaultCurrency: 'IDR',
      popularDestinations: ['Bali', 'Cakarta', 'Yogyakarta', 'Lombok'],
    ),
    Country(
      code: 'VN',
      name: 'Vietnam',
      localName: 'Vietnam',
      flag: '🇻🇳',
      defaultCurrency: 'VND',
      popularDestinations: ['Hanoi', 'Ho Chi Minh', 'Da Nang', 'Ha Long Bay'],
    ),
    Country(
      code: 'BR',
      name: 'Brazil',
      localName: 'Brezilya',
      flag: '🇧🇷',
      defaultCurrency: 'BRL',
      popularDestinations: ['Rio de Janeiro', 'Sao Paulo', 'Salvador', 'Brasilia'],
    ),
    Country(
      code: 'MX',
      name: 'Mexico',
      localName: 'Meksika',
      flag: '🇲🇽',
      defaultCurrency: 'MXN',
      popularDestinations: ['Cancun', 'Mexico City', 'Playa del Carmen', 'Oaxaca'],
    ),
    Country(
      code: 'CA',
      name: 'Canada',
      localName: 'Kanada',
      flag: '🇨🇦',
      defaultCurrency: 'CAD',
      popularDestinations: ['Toronto', 'Vancouver', 'Montreal', 'Banff', 'Calgary'],
    ),
    Country(
      code: 'AU',
      name: 'Australia',
      localName: 'Avustralya',
      flag: '🇦🇺',
      defaultCurrency: 'AUD',
      popularDestinations: ['Sidney', 'Melbourne', 'Brisbane', 'Gold Coast', 'Perth'],
    ),
    Country(
      code: 'SE',
      name: 'Sweden',
      localName: 'İsveç',
      flag: '🇸🇪',
      defaultCurrency: 'SEK',
      popularDestinations: ['Stockholm', 'Göteborg', 'Malmö'],
    ),
    Country(
      code: 'NO',
      name: 'Norway',
      localName: 'Norveç',
      flag: '🇳🇴',
      defaultCurrency: 'NOK',
      popularDestinations: ['Oslo', 'Bergen', 'Tromsø', 'Lofoten'],
    ),
    Country(
      code: 'PL',
      name: 'Poland',
      localName: 'Polonya',
      flag: '🇵🇱',
      defaultCurrency: 'PLN',
      popularDestinations: ['Krakow', 'Varşova', 'Wroclaw', 'Gdansk'],
    ),
    Country(
      code: 'CZ',
      name: 'Czech Republic',
      localName: 'Çek Cumhuriyeti',
      flag: '🇨🇿',
      defaultCurrency: 'CZK',
      popularDestinations: ['Prag', 'Brno', 'Cesky Krumlov'],
    ),
    Country(
      code: 'HU',
      name: 'Hungary',
      localName: 'Macaristan',
      flag: '🇭🇺',
      defaultCurrency: 'HUF',
      popularDestinations: ['Budapeşte', 'Debrecen', 'Szeged'],
    ),
    Country(
      code: 'GE',
      name: 'Georgia',
      localName: 'Gürcistan',
      flag: '🇬🇪',
      defaultCurrency: 'USD',
      popularDestinations: ['Tiflis', 'Batum', 'Kazbegi', 'Sighnaghi'],
    ),
    Country(
      code: 'AZ',
      name: 'Azerbaijan',
      localName: 'Azerbaycan',
      flag: '🇦🇿',
      defaultCurrency: 'USD',
      popularDestinations: ['Bakü', 'Şeki', 'Kuba', 'Gence'],
    ),
  ];

  static Country? findByCode(String? code) {
    if (code == null) return null;
    try {
      return allCountries.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
