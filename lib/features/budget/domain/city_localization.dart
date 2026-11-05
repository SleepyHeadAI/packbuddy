import 'country.dart';
import 'country_localization.dart';

/// Represents a globally recognized travel city with full multilingual support.
class PopularCity {
  final String id;
  final String countryCode;
  final Map<String, String> names;

  const PopularCity({
    required this.id,
    required this.countryCode,
    required this.names,
  });

  /// Returns the localized city name for the given language code (fallback to en -> tr -> id).
  String getLocalizedName(String languageCode) {
    final lang = languageCode.toLowerCase().split('_').first.split('-').first;
    return names[lang] ?? names['en'] ?? names['tr'] ?? id;
  }

  /// Returns all available translation variants normalized for search matching.
  Set<String> get allSearchTerms {
    final terms = <String>{CityLocalization.normalizeTerm(id)};
    for (final val in names.values) {
      final clean = CityLocalization.normalizeTerm(val);
      if (clean.isNotEmpty) terms.add(clean);
    }
    return terms;
  }
}

/// Comprehensive Multilingual City Localization & 200+ Global Travel Destinations
class CityLocalization {
  CityLocalization._();

  static const List<PopularCity> popularCities = [
    // ----------------------------------------------------
    // Turkey (TR)
    // ----------------------------------------------------
    PopularCity(
      id: 'istanbul',
      countryCode: 'TR',
      names: {'en': 'Istanbul', 'tr': 'İstanbul', 'de': 'Istanbul', 'fr': 'Istanbul', 'es': 'Estambul', 'it': 'Istanbul', 'ru': 'Стамбул', 'ar': 'إسطنبول', 'zh': '伊斯坦布尔', 'ja': 'イスタンブール'},
    ),
    PopularCity(
      id: 'antalya',
      countryCode: 'TR',
      names: {'en': 'Antalya', 'tr': 'Antalya', 'de': 'Antalya', 'fr': 'Antalya', 'es': 'Antalya', 'it': 'Antalya', 'ru': 'Анталья', 'ar': 'أنطاليا'},
    ),
    PopularCity(
      id: 'izmir',
      countryCode: 'TR',
      names: {'en': 'Izmir', 'tr': 'İzmir', 'de': 'Izmir', 'fr': 'Izmir', 'es': 'Esmirna', 'it': 'Smirne', 'ru': 'Измир', 'ar': 'إزمير'},
    ),
    PopularCity(
      id: 'cappadocia',
      countryCode: 'TR',
      names: {'en': 'Cappadocia', 'tr': 'Kapadokya', 'de': 'Kappadokien', 'fr': 'Cappadoce', 'es': 'Capadocia', 'it': 'Cappadocia', 'ru': 'Каппадокия', 'ar': 'كابادوكيا', 'zh': '卡帕多奇亚'},
    ),
    PopularCity(
      id: 'bodrum',
      countryCode: 'TR',
      names: {'en': 'Bodrum', 'tr': 'Bodrum', 'de': 'Bodrum', 'fr': 'Bodrum', 'es': 'Bodrum', 'it': 'Bodrum', 'ru': 'Бодрум'},
    ),
    PopularCity(
      id: 'ankara',
      countryCode: 'TR',
      names: {'en': 'Ankara', 'tr': 'Ankara', 'de': 'Ankara', 'fr': 'Ankara', 'es': 'Ankara', 'it': 'Ankara', 'ru': 'Анкара', 'ar': 'أنقرة'},
    ),
    PopularCity(
      id: 'trabzon',
      countryCode: 'TR',
      names: {'en': 'Trabzon', 'tr': 'Trabzon', 'de': 'Trabzon', 'fr': 'Trébizonde', 'es': 'Trebisonda', 'it': 'Trebisonda', 'ru': 'Трабзон', 'ar': 'طرابزون'},
    ),
    PopularCity(
      id: 'bursa',
      countryCode: 'TR',
      names: {'en': 'Bursa', 'tr': 'Bursa', 'de': 'Bursa', 'fr': 'Bursa', 'es': 'Bursa', 'it': 'Bursa', 'ru': 'Бурса', 'ar': 'بورصة'},
    ),
    PopularCity(
      id: 'fethiye',
      countryCode: 'TR',
      names: {'en': 'Fethiye', 'tr': 'Fethiye', 'de': 'Fethiye', 'fr': 'Fethiye', 'es': 'Fethiye', 'it': 'Fethiye', 'ru': 'Фетхие'},
    ),
    PopularCity(
      id: 'marmaris',
      countryCode: 'TR',
      names: {'en': 'Marmaris', 'tr': 'Marmaris', 'de': 'Marmaris', 'fr': 'Marmaris', 'es': 'Marmaris', 'it': 'Marmaris', 'ru': 'Мармарис'},
    ),
    PopularCity(
      id: 'alanya',
      countryCode: 'TR',
      names: {'en': 'Alanya', 'tr': 'Alanya', 'de': 'Alanya', 'fr': 'Alanya', 'es': 'Alanya', 'it': 'Alanya', 'ru': 'Аланья'},
    ),
    PopularCity(
      id: 'cesme',
      countryCode: 'TR',
      names: {'en': 'Cesme', 'tr': 'Çeşme', 'de': 'Çeşme', 'fr': 'Çeşme', 'es': 'Çeşme', 'it': 'Çeşme', 'ru': 'Чешме'},
    ),
    PopularCity(
      id: 'pamukkale',
      countryCode: 'TR',
      names: {'en': 'Pamukkale', 'tr': 'Pamukkale', 'de': 'Pamukkale', 'fr': 'Pamukkale', 'es': 'Pamukkale', 'it': 'Pamukkale', 'ru': 'Памуккале'},
    ),
    PopularCity(
      id: 'gaziantep',
      countryCode: 'TR',
      names: {'en': 'Gaziantep', 'tr': 'Gaziantep', 'de': 'Gaziantep', 'fr': 'Gaziantep', 'es': 'Gaziantep', 'it': 'Gaziantep', 'ru': 'Газиантеп'},
    ),

    // ----------------------------------------------------
    // Italy (IT)
    // ----------------------------------------------------
    PopularCity(
      id: 'rome',
      countryCode: 'IT',
      names: {'en': 'Rome', 'tr': 'Roma', 'it': 'Roma', 'de': 'Rom', 'fr': 'Rome', 'es': 'Roma', 'ru': 'Рим', 'el': 'Ρώμη', 'ar': 'روما', 'zh': '罗马', 'ja': 'ローマ'},
    ),
    PopularCity(
      id: 'milan',
      countryCode: 'IT',
      names: {'en': 'Milan', 'tr': 'Milano', 'it': 'Milano', 'de': 'Mailand', 'fr': 'Milan', 'es': 'Milán', 'ru': 'Милан', 'ar': 'ميلانو', 'zh': '米兰'},
    ),
    PopularCity(
      id: 'florence',
      countryCode: 'IT',
      names: {'en': 'Florence', 'tr': 'Floransa', 'it': 'Firenze', 'de': 'Florenz', 'fr': 'Florence', 'es': 'Florencia', 'ru': 'Флоренция', 'ar': 'فلورنسا', 'zh': '佛罗伦萨'},
    ),
    PopularCity(
      id: 'venice',
      countryCode: 'IT',
      names: {'en': 'Venice', 'tr': 'Venedik', 'it': 'Venezia', 'de': 'Venedig', 'fr': 'Venise', 'es': 'Venecia', 'ru': 'Венеция', 'ar': 'البندقية', 'zh': '威尼斯'},
    ),
    PopularCity(
      id: 'naples',
      countryCode: 'IT',
      names: {'en': 'Naples', 'tr': 'Napoli', 'it': 'Napoli', 'de': 'Neapel', 'fr': 'Naples', 'es': 'Nápoles', 'ru': 'Неаполь', 'ar': 'نابولي'},
    ),
    PopularCity(
      id: 'bologna',
      countryCode: 'IT',
      names: {'en': 'Bologna', 'tr': 'Bolonya', 'it': 'Bologna', 'de': 'Bologna', 'fr': 'Bologne', 'es': 'Bolonia', 'ru': 'Болонья'},
    ),
    PopularCity(
      id: 'turin',
      countryCode: 'IT',
      names: {'en': 'Turin', 'tr': 'Torino', 'it': 'Torino', 'de': 'Turin', 'fr': 'Turin', 'es': 'Turín', 'ru': 'Турин'},
    ),
    PopularCity(
      id: 'verona',
      countryCode: 'IT',
      names: {'en': 'Verona', 'tr': 'Verona', 'it': 'Verona', 'de': 'Verona', 'fr': 'Vérone', 'es': 'Verona', 'ru': 'Верона'},
    ),
    PopularCity(
      id: 'palermo',
      countryCode: 'IT',
      names: {'en': 'Palermo', 'tr': 'Palermo', 'it': 'Palermo', 'de': 'Palermo', 'fr': 'Palerme', 'es': 'Palermo', 'ru': 'Палермо'},
    ),
    PopularCity(
      id: 'pisa',
      countryCode: 'IT',
      names: {'en': 'Pisa', 'tr': 'Pisa', 'it': 'Pisa', 'de': 'Pisa', 'fr': 'Pise', 'es': 'Pisa', 'ru': 'Пиза'},
    ),
    PopularCity(
      id: 'amalfi',
      countryCode: 'IT',
      names: {'en': 'Amalfi', 'tr': 'Amalfi', 'it': 'Amalfi', 'de': 'Amalfi', 'fr': 'Amalfi', 'es': 'Amalfi', 'ru': 'Амальфи'},
    ),
    PopularCity(
      id: 'sorrento',
      countryCode: 'IT',
      names: {'en': 'Sorrento', 'tr': 'Sorrento', 'it': 'Sorrento', 'de': 'Sorrent', 'fr': 'Sorrente', 'es': 'Sorrento', 'ru': 'Сорренто'},
    ),
    PopularCity(
      id: 'siena',
      countryCode: 'IT',
      names: {'en': 'Siena', 'tr': 'Siena', 'it': 'Siena', 'de': 'Siena', 'fr': 'Sienne', 'es': 'Siena', 'ru': 'Сиена'},
    ),
    PopularCity(
      id: 'catania',
      countryCode: 'IT',
      names: {'en': 'Catania', 'tr': 'Katanya', 'it': 'Catania', 'de': 'Catania', 'fr': 'Catane', 'es': 'Catania', 'ru': 'Катания'},
    ),
    PopularCity(
      id: 'genoa',
      countryCode: 'IT',
      names: {'en': 'Genoa', 'tr': 'Cenova', 'it': 'Genova', 'de': 'Genua', 'fr': 'Gênes', 'es': 'Génova', 'ru': 'Генуя'},
    ),

    // ----------------------------------------------------
    // France (FR)
    // ----------------------------------------------------
    PopularCity(
      id: 'paris',
      countryCode: 'FR',
      names: {'en': 'Paris', 'tr': 'Paris', 'fr': 'Paris', 'de': 'Paris', 'es': 'París', 'it': 'Parigi', 'ru': 'Париж', 'ar': 'باريس', 'zh': '巴黎', 'ja': 'パリ'},
    ),
    PopularCity(
      id: 'nice',
      countryCode: 'FR',
      names: {'en': 'Nice', 'tr': 'Nice', 'fr': 'Nice', 'de': 'Nizza', 'es': 'Niza', 'it': 'Nizza', 'ru': 'Ницца', 'ar': 'نيس'},
    ),
    PopularCity(
      id: 'lyon',
      countryCode: 'FR',
      names: {'en': 'Lyon', 'tr': 'Lyon', 'fr': 'Lyon', 'de': 'Lyon', 'es': 'Lyon', 'it': 'Lione', 'ru': 'Лион'},
    ),
    PopularCity(
      id: 'marseille',
      countryCode: 'FR',
      names: {'en': 'Marseille', 'tr': 'Marsilya', 'fr': 'Marseille', 'de': 'Marseille', 'es': 'Marsella', 'it': 'Marsiglia', 'ru': 'Марсель'},
    ),
    PopularCity(
      id: 'bordeaux',
      countryCode: 'FR',
      names: {'en': 'Bordeaux', 'tr': 'Bordo', 'fr': 'Bordeaux', 'de': 'Bordeaux', 'es': 'Burdeos', 'it': 'Bordeaux', 'ru': 'Бордо'},
    ),
    PopularCity(
      id: 'cannes',
      countryCode: 'FR',
      names: {'en': 'Cannes', 'tr': 'Cannes', 'fr': 'Cannes', 'de': 'Cannes', 'es': 'Cannes', 'it': 'Cannes', 'ru': 'Канны'},
    ),
    PopularCity(
      id: 'strasbourg',
      countryCode: 'FR',
      names: {'en': 'Strasbourg', 'tr': 'Strazburg', 'fr': 'Strasbourg', 'de': 'Straßburg', 'es': 'Estrasburgo', 'it': 'Strasburgo', 'ru': 'Страсбург'},
    ),
    PopularCity(
      id: 'toulouse',
      countryCode: 'FR',
      names: {'en': 'Toulouse', 'tr': 'Toulouse', 'fr': 'Toulouse', 'de': 'Toulouse', 'es': 'Toulouse', 'it': 'Tolosa', 'ru': 'Тулуза'},
    ),
    PopularCity(
      id: 'lille',
      countryCode: 'FR',
      names: {'en': 'Lille', 'tr': 'Lille', 'fr': 'Lille', 'de': 'Rijsel', 'es': 'Lille', 'it': 'Lilla', 'ru': 'Лилль'},
    ),
    PopularCity(
      id: 'montpellier',
      countryCode: 'FR',
      names: {'en': 'Montpellier', 'tr': 'Montpellier', 'fr': 'Montpellier', 'de': 'Montpellier', 'es': 'Montpellier', 'it': 'Montpellier', 'ru': 'Монпелье'},
    ),
    PopularCity(
      id: 'aix_en_provence',
      countryCode: 'FR',
      names: {'en': 'Aix-en-Provence', 'tr': 'Aix-en-Provence', 'fr': 'Aix-en-Provence', 'de': 'Aix-en-Provence', 'es': 'Aix-en-Provence', 'ru': 'Экс-ан-Прованс'},
    ),

    // ----------------------------------------------------
    // Spain (ES)
    // ----------------------------------------------------
    PopularCity(
      id: 'barcelona',
      countryCode: 'ES',
      names: {'en': 'Barcelona', 'tr': 'Barselona', 'es': 'Barcelona', 'de': 'Barcelona', 'fr': 'Barcelone', 'it': 'Barcellona', 'ru': 'Барселона', 'ar': 'برشلونة', 'zh': '巴塞罗那'},
    ),
    PopularCity(
      id: 'madrid',
      countryCode: 'ES',
      names: {'en': 'Madrid', 'tr': 'Madrid', 'es': 'Madrid', 'de': 'Madrid', 'fr': 'Madrid', 'it': 'Madrid', 'ru': 'Мадрид', 'ar': 'مدريد', 'zh': '马德里'},
    ),
    PopularCity(
      id: 'seville',
      countryCode: 'ES',
      names: {'en': 'Seville', 'tr': 'Sevilla', 'es': 'Sevilla', 'de': 'Sevilla', 'fr': 'Séville', 'it': 'Siviglia', 'ru': 'Севилья', 'ar': 'إشبيلية'},
    ),
    PopularCity(
      id: 'valencia',
      countryCode: 'ES',
      names: {'en': 'Valencia', 'tr': 'Valensiya', 'es': 'Valencia', 'de': 'Valencia', 'fr': 'Valence', 'it': 'Valencia', 'ru': 'Валенсия'},
    ),
    PopularCity(
      id: 'granada',
      countryCode: 'ES',
      names: {'en': 'Granada', 'tr': 'Granada', 'es': 'Granada', 'de': 'Granada', 'fr': 'Grenade', 'it': 'Granada', 'ru': 'Гранада', 'ar': 'غرناطة'},
    ),
    PopularCity(
      id: 'malaga',
      countryCode: 'ES',
      names: {'en': 'Malaga', 'tr': 'Malaga', 'es': 'Málaga', 'de': 'Málaga', 'fr': 'Malaga', 'it': 'Malaga', 'ru': 'Малага'},
    ),
    PopularCity(
      id: 'bilbao',
      countryCode: 'ES',
      names: {'en': 'Bilbao', 'tr': 'Bilbao', 'es': 'Bilbao', 'de': 'Bilbao', 'fr': 'Bilbao', 'it': 'Bilbao', 'ru': 'Бильбао'},
    ),
    PopularCity(
      id: 'san_sebastian',
      countryCode: 'ES',
      names: {'en': 'San Sebastian', 'tr': 'San Sebastian', 'es': 'San Sebastián', 'de': 'San Sebastián', 'fr': 'Saint-Sébastien', 'it': 'San Sebastián', 'ru': 'Сан-Себастьян'},
    ),
    PopularCity(
      id: 'ibiza',
      countryCode: 'ES',
      names: {'en': 'Ibiza', 'tr': 'İbiza', 'es': 'Ibiza', 'de': 'Ibiza', 'fr': 'Ibiza', 'it': 'Ibiza', 'ru': 'Ибица'},
    ),
    PopularCity(
      id: 'mallorca',
      countryCode: 'ES',
      names: {'en': 'Palma de Mallorca', 'tr': 'Palma de Mallorca', 'es': 'Palma de Mallorca', 'de': 'Palma de Mallorca', 'fr': 'Palma de Majorque', 'it': 'Palma di Maiorca', 'ru': 'Пальма-де-Майорка'},
    ),
    PopularCity(
      id: 'tenerife',
      countryCode: 'ES',
      names: {'en': 'Tenerife', 'tr': 'Tenerife', 'es': 'Tenerife', 'de': 'Teneriffa', 'fr': 'Ténérife', 'it': 'Tenerife', 'ru': 'Тенерифе'},
    ),
    PopularCity(
      id: 'cordoba',
      countryCode: 'ES',
      names: {'en': 'Cordoba', 'tr': 'Kurtuba (Kordoba)', 'es': 'Córdoba', 'de': 'Córdoba', 'fr': 'Cordoue', 'it': 'Cordova', 'ru': 'Кордова', 'ar': 'قرطبة'},
    ),
    PopularCity(
      id: 'toledo',
      countryCode: 'ES',
      names: {'en': 'Toledo', 'tr': 'Tuleytula (Toledo)', 'es': 'Toledo', 'de': 'Toledo', 'fr': 'Tolède', 'it': 'Toledo', 'ru': 'Толедо', 'ar': 'طليطلة'},
    ),
    PopularCity(
      id: 'alicante',
      countryCode: 'ES',
      names: {'en': 'Alicante', 'tr': 'Alicante', 'es': 'Alicante', 'de': 'Alicante', 'fr': 'Alicante', 'it': 'Alicante', 'ru': 'Аликанте'},
    ),

    // ----------------------------------------------------
    // Germany (DE)
    // ----------------------------------------------------
    PopularCity(
      id: 'berlin',
      countryCode: 'DE',
      names: {'en': 'Berlin', 'tr': 'Berlin', 'de': 'Berlin', 'fr': 'Berlin', 'es': 'Berlín', 'it': 'Berlino', 'ru': 'Берлин', 'ar': 'برلين', 'zh': '柏林'},
    ),
    PopularCity(
      id: 'munich',
      countryCode: 'DE',
      names: {'en': 'Munich', 'tr': 'Münih', 'de': 'München', 'fr': 'Munich', 'es': 'Múnich', 'it': 'Monaco di Baviera', 'ru': 'Мюнхен', 'ar': 'ميونيخ', 'zh': '慕尼黑'},
    ),
    PopularCity(
      id: 'frankfurt',
      countryCode: 'DE',
      names: {'en': 'Frankfurt', 'tr': 'Frankfurt', 'de': 'Frankfurt am Main', 'fr': 'Francfort', 'es': 'Fráncfort', 'it': 'Francoforte', 'ru': 'Франкфурт', 'zh': '法兰克福'},
    ),
    PopularCity(
      id: 'hamburg',
      countryCode: 'DE',
      names: {'en': 'Hamburg', 'tr': 'Hamburg', 'de': 'Hamburg', 'fr': 'Hambourg', 'es': 'Hamburgo', 'it': 'Amburgo', 'ru': 'Гамбург'},
    ),
    PopularCity(
      id: 'cologne',
      countryCode: 'DE',
      names: {'en': 'Cologne', 'tr': 'Köln', 'de': 'Köln', 'fr': 'Cologne', 'es': 'Colonia', 'it': 'Colonia', 'ru': 'Кёльн'},
    ),
    PopularCity(
      id: 'stuttgart',
      countryCode: 'DE',
      names: {'en': 'Stuttgart', 'tr': 'Stuttgart', 'de': 'Stuttgart', 'fr': 'Stuttgart', 'es': 'Stuttgart', 'it': 'Stoccarda', 'ru': 'Штутгарт'},
    ),
    PopularCity(
      id: 'dusseldorf',
      countryCode: 'DE',
      names: {'en': 'Dusseldorf', 'tr': 'Düsseldorf', 'de': 'Düsseldorf', 'fr': 'Düsseldorf', 'es': 'Düsseldorf', 'it': 'Düsseldorf', 'ru': 'Дюссельдорф'},
    ),
    PopularCity(
      id: 'dresden',
      countryCode: 'DE',
      names: {'en': 'Dresden', 'tr': 'Dresden', 'de': 'Dresden', 'fr': 'Dresde', 'es': 'Dresde', 'it': 'Dresda', 'ru': 'Дрезден'},
    ),
    PopularCity(
      id: 'nuremberg',
      countryCode: 'DE',
      names: {'en': 'Nuremberg', 'tr': 'Nürnberg', 'de': 'Nürnberg', 'fr': 'Nuremberg', 'es': 'Núremberg', 'it': 'Norimberga', 'ru': 'Нюрнберг'},
    ),
    PopularCity(
      id: 'heidelberg',
      countryCode: 'DE',
      names: {'en': 'Heidelberg', 'tr': 'Heidelberg', 'de': 'Heidelberg', 'fr': 'Heidelberg', 'es': 'Heidelberg', 'it': 'Heidelberg', 'ru': 'Гейдельберг'},
    ),

    // ----------------------------------------------------
    // United Kingdom (GB)
    // ----------------------------------------------------
    PopularCity(
      id: 'london',
      countryCode: 'GB',
      names: {'en': 'London', 'tr': 'Londra', 'fr': 'Londres', 'es': 'Londres', 'it': 'Londra', 'de': 'London', 'ru': 'Лондон', 'ar': 'لندن', 'zh': '伦敦', 'ja': 'ロンドン'},
    ),
    PopularCity(
      id: 'edinburgh',
      countryCode: 'GB',
      names: {'en': 'Edinburgh', 'tr': 'Edinburgh', 'fr': 'Édimbourg', 'es': 'Edimburgo', 'it': 'Edimburgo', 'de': 'Edinburgh', 'ru': 'Эдинбург'},
    ),
    PopularCity(
      id: 'manchester',
      countryCode: 'GB',
      names: {'en': 'Manchester', 'tr': 'Manchester', 'de': 'Manchester', 'fr': 'Manchester', 'es': 'Mánchester', 'it': 'Manchester', 'ru': 'Манчестер'},
    ),
    PopularCity(
      id: 'liverpool',
      countryCode: 'GB',
      names: {'en': 'Liverpool', 'tr': 'Liverpool', 'de': 'Liverpool', 'fr': 'Liverpool', 'es': 'Liverpool', 'it': 'Liverpool', 'ru': 'Ливерпуль'},
    ),
    PopularCity(
      id: 'birmingham',
      countryCode: 'GB',
      names: {'en': 'Birmingham', 'tr': 'Birmingham', 'de': 'Birmingham', 'fr': 'Birmingham', 'es': 'Birmingham', 'it': 'Birmingham', 'ru': 'Бирмингем'},
    ),
    PopularCity(
      id: 'oxford',
      countryCode: 'GB',
      names: {'en': 'Oxford', 'tr': 'Oxford', 'de': 'Oxford', 'fr': 'Oxford', 'es': 'Oxford', 'it': 'Oxford', 'ru': 'Оксфорд'},
    ),
    PopularCity(
      id: 'cambridge',
      countryCode: 'GB',
      names: {'en': 'Cambridge', 'tr': 'Cambridge', 'de': 'Cambridge', 'fr': 'Cambridge', 'es': 'Cambridge', 'it': 'Cambridge', 'ru': 'Кембридж'},
    ),
    PopularCity(
      id: 'bath',
      countryCode: 'GB',
      names: {'en': 'Bath', 'tr': 'Bath', 'de': 'Bath', 'fr': 'Bath', 'es': 'Bath', 'it': 'Bath', 'ru': 'Бат'},
    ),
    PopularCity(
      id: 'belfast',
      countryCode: 'GB',
      names: {'en': 'Belfast', 'tr': 'Belfast', 'de': 'Belfast', 'fr': 'Belfast', 'es': 'Belfast', 'it': 'Belfast', 'ru': 'Белфаст'},
    ),
    PopularCity(
      id: 'glasgow',
      countryCode: 'GB',
      names: {'en': 'Glasgow', 'tr': 'Glasgow', 'de': 'Glasgow', 'fr': 'Glasgow', 'es': 'Glasgow', 'it': 'Glasgow', 'ru': 'Глазго'},
    ),

    // ----------------------------------------------------
    // United States (US)
    // ----------------------------------------------------
    PopularCity(
      id: 'new_york',
      countryCode: 'US',
      names: {'en': 'New York', 'tr': 'New York', 'de': 'New York', 'fr': 'New York', 'es': 'Nueva York', 'it': 'New York', 'ru': 'Нью-Йорк', 'ar': 'نيويورك', 'zh': '纽约', 'ja': 'ニューヨーク'},
    ),
    PopularCity(
      id: 'los_angeles',
      countryCode: 'US',
      names: {'en': 'Los Angeles', 'tr': 'Los Angeles', 'es': 'Los Ángeles', 'de': 'Los Angeles', 'fr': 'Los Angeles', 'it': 'Los Angeles', 'ru': 'Лос-Анджелес', 'zh': '洛杉矶'},
    ),
    PopularCity(
      id: 'san_francisco',
      countryCode: 'US',
      names: {'en': 'San Francisco', 'tr': 'San Francisco', 'es': 'San Francisco', 'de': 'San Francisco', 'fr': 'San Francisco', 'it': 'San Francisco', 'ru': 'Сан-Франциско'},
    ),
    PopularCity(
      id: 'miami',
      countryCode: 'US',
      names: {'en': 'Miami', 'tr': 'Miami', 'es': 'Miami', 'de': 'Miami', 'fr': 'Miami', 'it': 'Miami', 'ru': 'Майами'},
    ),
    PopularCity(
      id: 'las_vegas',
      countryCode: 'US',
      names: {'en': 'Las Vegas', 'tr': 'Las Vegas', 'es': 'Las Vegas', 'de': 'Las Vegas', 'fr': 'Las Vegas', 'it': 'Las Vegas', 'ru': 'Лас-Вегас'},
    ),
    PopularCity(
      id: 'chicago',
      countryCode: 'US',
      names: {'en': 'Chicago', 'tr': 'Chicago', 'es': 'Chicago', 'de': 'Chicago', 'fr': 'Chicago', 'it': 'Chicago', 'ru': 'Чикаго'},
    ),
    PopularCity(
      id: 'orlando',
      countryCode: 'US',
      names: {'en': 'Orlando', 'tr': 'Orlando', 'es': 'Orlando', 'de': 'Orlando', 'fr': 'Orlando', 'it': 'Orlando', 'ru': 'Орландо'},
    ),
    PopularCity(
      id: 'washington_dc',
      countryCode: 'US',
      names: {'en': 'Washington D.C.', 'tr': 'Washington D.C.', 'es': 'Washington D.C.', 'de': 'Washington D.C.', 'fr': 'Washington D.C.', 'it': 'Washington D.C.', 'ru': 'Вашингтон'},
    ),
    PopularCity(
      id: 'boston',
      countryCode: 'US',
      names: {'en': 'Boston', 'tr': 'Boston', 'es': 'Boston', 'de': 'Boston', 'fr': 'Boston', 'it': 'Boston', 'ru': 'Бостон'},
    ),
    PopularCity(
      id: 'seattle',
      countryCode: 'US',
      names: {'en': 'Seattle', 'tr': 'Seattle', 'es': 'Seattle', 'de': 'Seattle', 'fr': 'Seattle', 'it': 'Seattle', 'ru': 'Сиэтл'},
    ),
    PopularCity(
      id: 'honolulu',
      countryCode: 'US',
      names: {'en': 'Honolulu', 'tr': 'Honolulu', 'es': 'Honolulu', 'de': 'Honolulu', 'fr': 'Honolulu', 'it': 'Honolulu', 'ru': 'Гонолулу'},
    ),
    PopularCity(
      id: 'new_orleans',
      countryCode: 'US',
      names: {'en': 'New Orleans', 'tr': 'New Orleans', 'es': 'Nueva Orleans', 'de': 'New Orleans', 'fr': 'La Nouvelle-Orléans', 'it': 'New Orleans', 'ru': 'Новый Орлеан'},
    ),
    PopularCity(
      id: 'san_diego',
      countryCode: 'US',
      names: {'en': 'San Diego', 'tr': 'San Diego', 'es': 'San Diego', 'de': 'San Diego', 'fr': 'San Diego', 'it': 'San Diego', 'ru': 'Сан-Диего'},
    ),

    // ----------------------------------------------------
    // Austria (AT)
    // ----------------------------------------------------
    PopularCity(
      id: 'vienna',
      countryCode: 'AT',
      names: {'en': 'Vienna', 'tr': 'Viyana', 'de': 'Wien', 'fr': 'Vienne', 'es': 'Viena', 'it': 'Vienna', 'ru': 'Вена', 'ar': 'فيينا', 'zh': '维也纳'},
    ),
    PopularCity(
      id: 'salzburg',
      countryCode: 'AT',
      names: {'en': 'Salzburg', 'tr': 'Salzburg', 'de': 'Salzburg', 'fr': 'Salzbourg', 'es': 'Salzburgo', 'it': 'Salisburgo', 'ru': 'Зальцбург'},
    ),
    PopularCity(
      id: 'innsbruck',
      countryCode: 'AT',
      names: {'en': 'Innsbruck', 'tr': 'İnnsbruck', 'de': 'Innsbruck', 'fr': 'Innsbruck', 'es': 'Innsbruck', 'it': 'Innsbruck', 'ru': 'Инсбрук'},
    ),
    PopularCity(
      id: 'hallstatt',
      countryCode: 'AT',
      names: {'en': 'Hallstatt', 'tr': 'Hallstatt', 'de': 'Hallstatt', 'fr': 'Hallstatt', 'es': 'Hallstatt', 'it': 'Hallstatt', 'ru': 'Гальштат'},
    ),
    PopularCity(
      id: 'graz',
      countryCode: 'AT',
      names: {'en': 'Graz', 'tr': 'Graz', 'de': 'Graz', 'fr': 'Graz', 'es': 'Graz', 'it': 'Graz', 'ru': 'Грац'},
    ),

    // ----------------------------------------------------
    // Netherlands (NL)
    // ----------------------------------------------------
    PopularCity(
      id: 'amsterdam',
      countryCode: 'NL',
      names: {'en': 'Amsterdam', 'tr': 'Amsterdam', 'nl': 'Amsterdam', 'de': 'Amsterdam', 'fr': 'Amsterdam', 'es': 'Ámsterdam', 'it': 'Amsterdam', 'ru': 'Амстердам', 'zh': '阿姆斯特丹'},
    ),
    PopularCity(
      id: 'rotterdam',
      countryCode: 'NL',
      names: {'en': 'Rotterdam', 'tr': 'Rotterdam', 'nl': 'Rotterdam', 'de': 'Rotterdam', 'fr': 'Rotterdam', 'es': 'Róterdam', 'it': 'Rotterdam', 'ru': 'Роттердам'},
    ),
    PopularCity(
      id: 'the_hague',
      countryCode: 'NL',
      names: {'en': 'The Hague', 'tr': 'Lahey', 'nl': 'Den Haag', 'de': 'Den Haag', 'fr': 'La Haye', 'es': 'La Haya', 'it': 'L’Aia', 'ru': 'Гаага'},
    ),
    PopularCity(
      id: 'utrecht',
      countryCode: 'NL',
      names: {'en': 'Utrecht', 'tr': 'Utrecht', 'nl': 'Utrecht', 'de': 'Utrecht', 'fr': 'Utrecht', 'es': 'Utrecht', 'it': 'Utrecht', 'ru': 'Утрехт'},
    ),

    // ----------------------------------------------------
    // Czech Republic (CZ)
    // ----------------------------------------------------
    PopularCity(
      id: 'prague',
      countryCode: 'CZ',
      names: {'en': 'Prague', 'tr': 'Prag', 'cs': 'Praha', 'de': 'Prag', 'fr': 'Prague', 'es': 'Praga', 'it': 'Praga', 'ru': 'Прага', 'ar': 'براغ', 'zh': '布拉格'},
    ),
    PopularCity(
      id: 'cesky_krumlov',
      countryCode: 'CZ',
      names: {'en': 'Cesky Krumlov', 'tr': 'Český Krumlov', 'cs': 'Český Krumlov', 'de': 'Krumau', 'fr': 'Český Krumlov', 'es': 'Český Krumlov', 'ru': 'Чески-Крумлов'},
    ),
    PopularCity(
      id: 'brno',
      countryCode: 'CZ',
      names: {'en': 'Brno', 'tr': 'Brno', 'cs': 'Brno', 'de': 'Brünn', 'fr': 'Brno', 'es': 'Brno', 'it': 'Brno', 'ru': 'Брно'},
    ),

    // ----------------------------------------------------
    // Hungary (HU)
    // ----------------------------------------------------
    PopularCity(
      id: 'budapest',
      countryCode: 'HU',
      names: {'en': 'Budapest', 'tr': 'Budapeşte', 'hu': 'Budapest', 'de': 'Budapest', 'fr': 'Budapest', 'es': 'Budapest', 'it': 'Budapest', 'ru': 'Будапешт', 'ar': 'بودابست'},
    ),

    // ----------------------------------------------------
    // Portugal (PT)
    // ----------------------------------------------------
    PopularCity(
      id: 'lisbon',
      countryCode: 'PT',
      names: {'en': 'Lisbon', 'tr': 'Lizbon', 'pt': 'Lisboa', 'de': 'Lissabon', 'fr': 'Lisbonne', 'es': 'Lisboa', 'it': 'Lisbona', 'ru': 'Лиссабон', 'ar': 'لشبونة'},
    ),
    PopularCity(
      id: 'porto',
      countryCode: 'PT',
      names: {'en': 'Porto', 'tr': 'Porto', 'pt': 'Porto', 'de': 'Porto', 'fr': 'Porto', 'es': 'Oporto', 'it': 'Porto', 'ru': 'Порту'},
    ),
    PopularCity(
      id: 'sintra',
      countryCode: 'PT',
      names: {'en': 'Sintra', 'tr': 'Sintra', 'pt': 'Sintra', 'de': 'Sintra', 'fr': 'Sintra', 'es': 'Sintra', 'it': 'Sintra', 'ru': 'Синтра'},
    ),
    PopularCity(
      id: 'faro',
      countryCode: 'PT',
      names: {'en': 'Faro', 'tr': 'Faro', 'pt': 'Faro', 'de': 'Faro', 'fr': 'Faro', 'es': 'Faro', 'it': 'Faro', 'ru': 'Фару'},
    ),
    PopularCity(
      id: 'funchal',
      countryCode: 'PT',
      names: {'en': 'Funchal', 'tr': 'Funchal', 'pt': 'Funchal', 'de': 'Funchal', 'fr': 'Funchal', 'es': 'Funchal', 'it': 'Funchal', 'ru': 'Фуншал'},
    ),

    // ----------------------------------------------------
    // Greece (GR)
    // ----------------------------------------------------
    PopularCity(
      id: 'athens',
      countryCode: 'GR',
      names: {'en': 'Athens', 'tr': 'Atina', 'el': 'Αθήνα', 'de': 'Athen', 'fr': 'Athènes', 'es': 'Atenas', 'it': 'Atene', 'ru': 'Афины', 'ar': 'أثينا', 'zh': '雅典'},
    ),
    PopularCity(
      id: 'santorini',
      countryCode: 'GR',
      names: {'en': 'Santorini', 'tr': 'Santorini', 'el': 'Σαντορίνη', 'de': 'Santorin', 'fr': 'Santorin', 'es': 'Santorini', 'it': 'Santorini', 'ru': 'Санторини'},
    ),
    PopularCity(
      id: 'mykonos',
      countryCode: 'GR',
      names: {'en': 'Mykonos', 'tr': 'Mikonos', 'el': 'Μύκονος', 'de': 'Mykonos', 'fr': 'Mykonos', 'es': 'Miconos', 'it': 'Mykonos', 'ru': 'Миконос'},
    ),
    PopularCity(
      id: 'thessaloniki',
      countryCode: 'GR',
      names: {'en': 'Thessaloniki', 'tr': 'Selanik', 'el': 'Θεσσαλονίκη', 'de': 'Thessaloniki', 'fr': 'Thessalonique', 'es': 'Tesalónica', 'it': 'Salonicco', 'ru': 'Салоники'},
    ),
    PopularCity(
      id: 'rhodes',
      countryCode: 'GR',
      names: {'en': 'Rhodes', 'tr': 'Rodos', 'el': 'Ρόδος', 'de': 'Rhodos', 'fr': 'Rhodes', 'es': 'Rodas', 'it': 'Rodi', 'ru': 'Родос'},
    ),
    PopularCity(
      id: 'heraklion',
      countryCode: 'GR',
      names: {'en': 'Heraklion', 'tr': 'Kandiye (Girit)', 'el': 'Ηράκλειο', 'de': 'Heraklion', 'fr': 'Héraklion', 'es': 'Heraclión', 'it': 'Heraklion', 'ru': 'Ираклион'},
    ),
    PopularCity(
      id: 'corfu',
      countryCode: 'GR',
      names: {'en': 'Corfu', 'tr': 'Korfu', 'el': 'Κέρκυρα', 'de': 'Korfu', 'fr': 'Corfou', 'es': 'Corfú', 'it': 'Corfù', 'ru': 'Корфу'},
    ),
    PopularCity(
      id: 'chania',
      countryCode: 'GR',
      names: {'en': 'Chania', 'tr': 'Hanya', 'el': 'Χανιά', 'de': 'Chania', 'fr': 'La Canée', 'es': 'La Canea', 'it': 'La Canea', 'ru': 'Ханья'},
    ),

    // ----------------------------------------------------
    // Switzerland (CH)
    // ----------------------------------------------------
    PopularCity(
      id: 'zurich',
      countryCode: 'CH',
      names: {'en': 'Zurich', 'tr': 'Zürih', 'de': 'Zürich', 'fr': 'Zurich', 'es': 'Zúrich', 'it': 'Zurigo', 'ru': 'Цюрих'},
    ),
    PopularCity(
      id: 'geneva',
      countryCode: 'CH',
      names: {'en': 'Geneva', 'tr': 'Cenevre', 'fr': 'Genève', 'de': 'Genf', 'es': 'Ginebra', 'it': 'Ginevra', 'ru': 'Женева'},
    ),
    PopularCity(
      id: 'lucerne',
      countryCode: 'CH',
      names: {'en': 'Lucerne', 'tr': 'Luzern', 'de': 'Luzern', 'fr': 'Lucerne', 'es': 'Lucerna', 'it': 'Lucerna', 'ru': 'Люцерн'},
    ),
    PopularCity(
      id: 'interlaken',
      countryCode: 'CH',
      names: {'en': 'Interlaken', 'tr': 'İnterlaken', 'de': 'Interlaken', 'fr': 'Interlaken', 'es': 'Interlaken', 'it': 'Interlaken', 'ru': 'Интерлакен'},
    ),
    PopularCity(
      id: 'basel',
      countryCode: 'CH',
      names: {'en': 'Basel', 'tr': 'Basel', 'de': 'Basel', 'fr': 'Bâle', 'es': 'Basilea', 'it': 'Basilea', 'ru': 'Базель'},
    ),
    PopularCity(
      id: 'bern',
      countryCode: 'CH',
      names: {'en': 'Bern', 'tr': 'Bern', 'de': 'Bern', 'fr': 'Berne', 'es': 'Berna', 'it': 'Berna', 'ru': 'Берн'},
    ),

    // ----------------------------------------------------
    // Belgium (BE)
    // ----------------------------------------------------
    PopularCity(
      id: 'brussels',
      countryCode: 'BE',
      names: {'en': 'Brussels', 'tr': 'Brüksel', 'fr': 'Bruxelles', 'nl': 'Brussel', 'de': 'Brüssel', 'es': 'Bruselas', 'it': 'Bruxelles', 'ru': 'Брюссель'},
    ),
    PopularCity(
      id: 'bruges',
      countryCode: 'BE',
      names: {'en': 'Bruges', 'tr': 'Bruges', 'fr': 'Bruges', 'nl': 'Brugge', 'de': 'Brügge', 'es': 'Brujas', 'it': 'Bruges', 'ru': 'Брюгге'},
    ),
    PopularCity(
      id: 'antwerp',
      countryCode: 'BE',
      names: {'en': 'Antwerp', 'tr': 'Anvers', 'nl': 'Antwerpen', 'fr': 'Anvers', 'de': 'Antwerpen', 'es': 'Amberes', 'it': 'Anversa', 'ru': 'Антверпен'},
    ),
    PopularCity(
      id: 'ghent',
      countryCode: 'BE',
      names: {'en': 'Ghent', 'tr': 'Gent', 'nl': 'Gent', 'fr': 'Gand', 'de': 'Gent', 'es': 'Gante', 'it': 'Gand', 'ru': 'Гент'},
    ),

    // ----------------------------------------------------
    // Poland (PL)
    // ----------------------------------------------------
    PopularCity(
      id: 'warsaw',
      countryCode: 'PL',
      names: {'en': 'Warsaw', 'tr': 'Varşova', 'pl': 'Warszawa', 'de': 'Warschau', 'fr': 'Varsovie', 'es': 'Varsovia', 'it': 'Varsavia', 'ru': 'Варшава'},
    ),
    PopularCity(
      id: 'krakow',
      countryCode: 'PL',
      names: {'en': 'Krakow', 'tr': 'Krakov', 'pl': 'Kraków', 'de': 'Krakau', 'fr': 'Cracovie', 'es': 'Cracovia', 'it': 'Cracovia', 'ru': 'Краков'},
    ),
    PopularCity(
      id: 'gdansk',
      countryCode: 'PL',
      names: {'en': 'Gdansk', 'tr': 'Gdansk', 'pl': 'Gdańsk', 'de': 'Danzig', 'fr': 'Gdańsk', 'es': 'Gdansk', 'it': 'Danzica', 'ru': 'Гданьск'},
    ),
    PopularCity(
      id: 'wroclaw',
      countryCode: 'PL',
      names: {'en': 'Wroclaw', 'tr': 'Wroclaw', 'pl': 'Wrocław', 'de': 'Breslau', 'fr': 'Wrocław', 'es': 'Breslavia', 'it': 'Breslavia', 'ru': 'Вроцлав'},
    ),

    // ----------------------------------------------------
    // Croatia (HR)
    // ----------------------------------------------------
    PopularCity(
      id: 'dubrovnik',
      countryCode: 'HR',
      names: {'en': 'Dubrovnik', 'tr': 'Dubrovnik', 'hr': 'Dubrovnik', 'de': 'Dubrovnik', 'fr': 'Dubrovnik', 'es': 'Dubrovnik', 'it': 'Ragusa', 'ru': 'Дубровник'},
    ),
    PopularCity(
      id: 'split',
      countryCode: 'HR',
      names: {'en': 'Split', 'tr': 'Split', 'hr': 'Split', 'de': 'Split', 'fr': 'Split', 'es': 'Split', 'it': 'Spalato', 'ru': 'Сплит'},
    ),
    PopularCity(
      id: 'zagreb',
      countryCode: 'HR',
      names: {'en': 'Zagreb', 'tr': 'Zagreb', 'hr': 'Zagreb', 'de': 'Agram', 'fr': 'Zagreb', 'es': 'Zagreb', 'it': 'Zagabria', 'ru': 'Загреб'},
    ),
    PopularCity(
      id: 'zadar',
      countryCode: 'HR',
      names: {'en': 'Zadar', 'tr': 'Zadar', 'hr': 'Zadar', 'de': 'Zara', 'fr': 'Zadar', 'es': 'Zadar', 'it': 'Zara', 'ru': 'Задар'},
    ),

    // ----------------------------------------------------
    // Nordic Countries (SE, NO, DK, FI, IS)
    // ----------------------------------------------------
    PopularCity(
      id: 'stockholm',
      countryCode: 'SE',
      names: {'en': 'Stockholm', 'tr': 'Stokholm', 'sv': 'Stockholm', 'de': 'Stockholm', 'fr': 'Stockholm', 'es': 'Estocolmo', 'it': 'Stoccolma', 'ru': 'Стокгольм'},
    ),
    PopularCity(
      id: 'gothenburg',
      countryCode: 'SE',
      names: {'en': 'Gothenburg', 'tr': 'Göteborg', 'sv': 'Göteborg', 'de': 'Göteborg', 'fr': 'Göteborg', 'es': 'Gotemburgo', 'it': 'Göteborg', 'ru': 'Гётеборг'},
    ),
    PopularCity(
      id: 'copenhagen',
      countryCode: 'DK',
      names: {'en': 'Copenhagen', 'tr': 'Kopenhag', 'da': 'København', 'de': 'Kopenhagen', 'fr': 'Copenhague', 'es': 'Copenhague', 'it': 'Copenaghen', 'ru': 'Копенгаген'},
    ),
    PopularCity(
      id: 'oslo',
      countryCode: 'NO',
      names: {'en': 'Oslo', 'tr': 'Oslo', 'no': 'Oslo', 'de': 'Oslo', 'fr': 'Oslo', 'es': 'Oslo', 'it': 'Oslo', 'ru': 'Осло'},
    ),
    PopularCity(
      id: 'bergen',
      countryCode: 'NO',
      names: {'en': 'Bergen', 'tr': 'Bergen', 'no': 'Bergen', 'de': 'Bergen', 'fr': 'Bergen', 'es': 'Bergen', 'it': 'Bergen', 'ru': 'Берген'},
    ),
    PopularCity(
      id: 'tromso',
      countryCode: 'NO',
      names: {'en': 'Tromso', 'tr': 'Tromsø', 'no': 'Tromsø', 'de': 'Tromsø', 'fr': 'Tromsø', 'es': 'Tromsø', 'it': 'Tromsø', 'ru': 'Тромсё'},
    ),
    PopularCity(
      id: 'helsinki',
      countryCode: 'FI',
      names: {'en': 'Helsinki', 'tr': 'Helsinki', 'fi': 'Helsinki', 'de': 'Helsinki', 'fr': 'Helsinki', 'es': 'Helsinki', 'it': 'Helsinki', 'ru': 'Хельсинки'},
    ),
    PopularCity(
      id: 'reykjavik',
      countryCode: 'IS',
      names: {'en': 'Reykjavik', 'tr': 'Reykjavik', 'is': 'Reykjavík', 'de': 'Reykjavík', 'fr': 'Reykjavik', 'es': 'Reikiavik', 'it': 'Reykjavík', 'ru': 'Рейкьявик'},
    ),

    // ----------------------------------------------------
    // Japan (JP)
    // ----------------------------------------------------
    PopularCity(
      id: 'tokyo',
      countryCode: 'JP',
      names: {'en': 'Tokyo', 'tr': 'Tokyo', 'ja': '東京', 'de': 'Tokio', 'fr': 'Tokyo', 'es': 'Tokio', 'it': 'Tokyo', 'ru': 'Токио', 'ar': 'طوكيو', 'zh': '东京'},
    ),
    PopularCity(
      id: 'kyoto',
      countryCode: 'JP',
      names: {'en': 'Kyoto', 'tr': 'Kyoto', 'ja': '京都', 'de': 'Kyōto', 'fr': 'Kyoto', 'es': 'Kioto', 'it': 'Kyoto', 'ru': 'Киото', 'ar': 'كيوتو', 'zh': '京都'},
    ),
    PopularCity(
      id: 'osaka',
      countryCode: 'JP',
      names: {'en': 'Osaka', 'tr': 'Osaka', 'ja': '大阪', 'de': 'Osaka', 'fr': 'Osaka', 'es': 'Osaka', 'it': 'Osaka', 'ru': 'Осака', 'zh': '大阪'},
    ),
    PopularCity(
      id: 'hiroshima',
      countryCode: 'JP',
      names: {'en': 'Hiroshima', 'tr': 'Hiroşima', 'ja': '広島', 'de': 'Hiroshima', 'fr': 'Hiroshima', 'es': 'Hiroshima', 'it': 'Hiroshima', 'ru': 'Хиросима'},
    ),
    PopularCity(
      id: 'sapporo',
      countryCode: 'JP',
      names: {'en': 'Sapporo', 'tr': 'Sapporo', 'ja': '札幌', 'de': 'Sapporo', 'fr': 'Sapporo', 'es': 'Sapporo', 'it': 'Sapporo', 'ru': 'Саппоро'},
    ),
    PopularCity(
      id: 'nara',
      countryCode: 'JP',
      names: {'en': 'Nara', 'tr': 'Nara', 'ja': '奈良', 'de': 'Nara', 'fr': 'Nara', 'es': 'Nara', 'it': 'Nara', 'ru': 'Нара'},
    ),

    // ----------------------------------------------------
    // UAE & Gulf (AE, QA, SA)
    // ----------------------------------------------------
    PopularCity(
      id: 'dubai',
      countryCode: 'AE',
      names: {'en': 'Dubai', 'tr': 'Dubai', 'ar': 'دبي', 'de': 'Dubai', 'fr': 'Dubaï', 'es': 'Dubái', 'it': 'Dubai', 'ru': 'Дубай', 'zh': '迪拜'},
    ),
    PopularCity(
      id: 'abu_dhabi',
      countryCode: 'AE',
      names: {'en': 'Abu Dhabi', 'tr': 'Abu Dabi', 'ar': 'أبو ظبي', 'de': 'Abu Dhabi', 'fr': 'Abou Dabi', 'es': 'Abu Dabi', 'it': 'Abu Dhabi', 'ru': 'Абу-Даби'},
    ),
    PopularCity(
      id: 'doha',
      countryCode: 'QA',
      names: {'en': 'Doha', 'tr': 'Doha', 'ar': 'الدوحة', 'de': 'Doha', 'fr': 'Doha', 'es': 'Doha', 'it': 'Doha', 'ru': 'Доха'},
    ),
    PopularCity(
      id: 'riyadh',
      countryCode: 'SA',
      names: {'en': 'Riyadh', 'tr': 'Riyad', 'ar': 'الرياض', 'de': 'Riad', 'fr': 'Riyad', 'es': 'Riad', 'it': 'Riad', 'ru': 'Эр-Рияд'},
    ),
    PopularCity(
      id: 'jeddah',
      countryCode: 'SA',
      names: {'en': 'Jeddah', 'tr': 'Cidde', 'ar': 'جدة', 'de': 'Dschidda', 'fr': 'Djeddah', 'es': 'Yeda', 'it': 'Gedda', 'ru': 'Джидда'},
    ),
    PopularCity(
      id: 'mecca',
      countryCode: 'SA',
      names: {'en': 'Mecca', 'tr': 'Mekke', 'ar': 'مكة المكرمة', 'de': 'Mekka', 'fr': 'La Mecque', 'es': 'La Meca', 'it': 'La Mecca', 'ru': 'Мекка'},
    ),
    PopularCity(
      id: 'medina',
      countryCode: 'SA',
      names: {'en': 'Medina', 'tr': 'Medine', 'ar': 'المدينة المنورة', 'de': 'Medina', 'fr': 'Médine', 'es': 'Medina', 'it': 'Medina', 'ru': 'Медина'},
    ),

    // ----------------------------------------------------
    // Thailand (TH)
    // ----------------------------------------------------
    PopularCity(
      id: 'bangkok',
      countryCode: 'TH',
      names: {'en': 'Bangkok', 'tr': 'Bangkok', 'th': 'กรุงเทพมหานคร', 'de': 'Bangkok', 'fr': 'Bangkok', 'es': 'Bangkok', 'it': 'Bangkok', 'ru': 'Бангкок', 'zh': '曼谷'},
    ),
    PopularCity(
      id: 'phuket',
      countryCode: 'TH',
      names: {'en': 'Phuket', 'tr': 'Phuket', 'th': 'ภูเก็ต', 'de': 'Phuket', 'fr': 'Phuket', 'es': 'Phuket', 'it': 'Phuket', 'ru': 'Пхукет'},
    ),
    PopularCity(
      id: 'chiang_mai',
      countryCode: 'TH',
      names: {'en': 'Chiang Mai', 'tr': 'Chiang Mai', 'th': 'เชียงใหม่', 'de': 'Chiang Mai', 'fr': 'Chiang Mai', 'es': 'Chiang Mai', 'it': 'Chiang Mai', 'ru': 'Чиангмай'},
    ),
    PopularCity(
      id: 'pattaya',
      countryCode: 'TH',
      names: {'en': 'Pattaya', 'tr': 'Pattaya', 'th': 'พัทยา', 'de': 'Pattaya', 'fr': 'Pattaya', 'es': 'Pattaya', 'it': 'Pattaya', 'ru': 'Паттайя'},
    ),
    PopularCity(
      id: 'koh_samui',
      countryCode: 'TH',
      names: {'en': 'Koh Samui', 'tr': 'Koh Samui', 'th': 'เกาะสมุย', 'de': 'Ko Samui', 'fr': 'Koh Samui', 'es': 'Koh Samui', 'ru': 'Самуи'},
    ),
    PopularCity(
      id: 'krabi',
      countryCode: 'TH',
      names: {'en': 'Krabi', 'tr': 'Krabi', 'th': 'กระบี่', 'de': 'Krabi', 'fr': 'Krabi', 'es': 'Krabi', 'it': 'Krabi', 'ru': 'Краби'},
    ),

    // ----------------------------------------------------
    // Indonesia & Malaysia & Singapore (ID, MY, SG)
    // ----------------------------------------------------
    PopularCity(
      id: 'bali',
      countryCode: 'ID',
      names: {'en': 'Bali', 'tr': 'Bali', 'id': 'Bali', 'de': 'Bali', 'fr': 'Bali', 'es': 'Bali', 'it': 'Bali', 'ru': 'Бали', 'zh': '巴厘岛'},
    ),
    PopularCity(
      id: 'jakarta',
      countryCode: 'ID',
      names: {'en': 'Jakarta', 'tr': 'Cakarta', 'id': 'Jakarta', 'de': 'Jakarta', 'fr': 'Jakarta', 'es': 'Yakarta', 'it': 'Giacarta', 'ru': 'Джакарта'},
    ),
    PopularCity(
      id: 'yogyakarta',
      countryCode: 'ID',
      names: {'en': 'Yogyakarta', 'tr': 'Yogyakarta', 'id': 'Yogyakarta', 'de': 'Yogyakarta', 'fr': 'Yogyakarta', 'es': 'Yogyakarta', 'ru': 'Джокьякарта'},
    ),
    PopularCity(
      id: 'singapore',
      countryCode: 'SG',
      names: {'en': 'Singapore', 'tr': 'Singapur', 'ms': 'Singapura', 'de': 'Singapur', 'fr': 'Singapour', 'es': 'Singapur', 'it': 'Singapore', 'ru': 'Сингапур', 'zh': '新加坡'},
    ),
    PopularCity(
      id: 'kuala_lumpur',
      countryCode: 'MY',
      names: {'en': 'Kuala Lumpur', 'tr': 'Kuala Lumpur', 'ms': 'Kuala Lumpur', 'de': 'Kuala Lumpur', 'fr': 'Kuala Lumpur', 'es': 'Kuala Lumpur', 'it': 'Kuala Lumpur', 'ru': 'Куала-Лумпур', 'zh': '吉隆坡'},
    ),
    PopularCity(
      id: 'penang',
      countryCode: 'MY',
      names: {'en': 'Penang', 'tr': 'Penang', 'ms': 'Pulau Pinang', 'de': 'Penang', 'fr': 'Penang', 'es': 'Penang', 'it': 'Penang', 'ru': 'Пенанг'},
    ),
    PopularCity(
      id: 'langkawi',
      countryCode: 'MY',
      names: {'en': 'Langkawi', 'tr': 'Langkawi', 'ms': 'Langkawi', 'de': 'Langkawi', 'fr': 'Langkawi', 'es': 'Langkawi', 'ru': 'Лангкави'},
    ),

    // ----------------------------------------------------
    // South Korea & Greater China (KR, CN, HK, TW, MO)
    // ----------------------------------------------------
    PopularCity(
      id: 'seoul',
      countryCode: 'KR',
      names: {'en': 'Seoul', 'tr': 'Seul', 'ko': '서울', 'de': 'Seoul', 'fr': 'Séoul', 'es': 'Seúl', 'it': 'Seul', 'ru': 'Сеул', 'zh': '首尔', 'ja': 'ソウル'},
    ),
    PopularCity(
      id: 'busan',
      countryCode: 'KR',
      names: {'en': 'Busan', 'tr': 'Busan', 'ko': '부산', 'de': 'Busan', 'fr': 'Pusan', 'es': 'Busan', 'it': 'Pusan', 'ru': 'Пусан', 'zh': '釜山'},
    ),
    PopularCity(
      id: 'jeju',
      countryCode: 'KR',
      names: {'en': 'Jeju', 'tr': 'Jeju', 'ko': '제주', 'de': 'Jeju', 'fr': 'Jeju', 'es': 'Jeju', 'it': 'Jeju', 'ru': 'Чеджу', 'zh': '济州'},
    ),
    PopularCity(
      id: 'beijing',
      countryCode: 'CN',
      names: {'en': 'Beijing', 'tr': 'Pekin', 'zh': '北京', 'de': 'Peking', 'fr': 'Pékin', 'es': 'Pekín', 'it': 'Pechino', 'ru': 'Пекин', 'ja': '北京'},
    ),
    PopularCity(
      id: 'shanghai',
      countryCode: 'CN',
      names: {'en': 'Shanghai', 'tr': 'Şanghay', 'zh': '上海', 'de': 'Schanghai', 'fr': 'Shanghai', 'es': 'Shanghái', 'it': 'Shanghai', 'ru': 'Шанхай', 'ja': '上海'},
    ),
    PopularCity(
      id: 'hong_kong',
      countryCode: 'HK',
      names: {'en': 'Hong Kong', 'tr': 'Hong Kong', 'zh': '香港', 'de': 'Hongkong', 'fr': 'Hong Kong', 'es': 'Hong Kong', 'it': 'Hong Kong', 'ru': 'Гонконг'},
    ),
    PopularCity(
      id: 'taipei',
      countryCode: 'TW',
      names: {'en': 'Taipei', 'tr': 'Taipei', 'zh': '台北', 'de': 'Taipeh', 'fr': 'Taipei', 'es': 'Taipéi', 'it': 'Taipei', 'ru': 'Тайбэй'},
    ),
    PopularCity(
      id: 'macau',
      countryCode: 'MO',
      names: {'en': 'Macau', 'tr': 'Makao', 'zh': '澳门', 'pt': 'Macau', 'de': 'Macau', 'fr': 'Macao', 'es': 'Macao', 'it': 'Macao', 'ru': 'Макао'},
    ),

    // ----------------------------------------------------
    // Egypt & North Africa (EG, MA, TN)
    // ----------------------------------------------------
    PopularCity(
      id: 'cairo',
      countryCode: 'EG',
      names: {'en': 'Cairo', 'tr': 'Kahire', 'ar': 'القاهرة', 'de': 'Kairo', 'fr': 'Le Caire', 'es': 'El Cairo', 'it': 'Il Cairo', 'ru': 'Каир', 'zh': '开罗'},
    ),
    PopularCity(
      id: 'alexandria',
      countryCode: 'EG',
      names: {'en': 'Alexandria', 'tr': 'İskenderiye', 'ar': 'الإسكندرية', 'de': 'Alexandria', 'fr': 'Alexandrie', 'es': 'Alejandría', 'it': 'Alessandria', 'ru': 'Александрия'},
    ),
    PopularCity(
      id: 'sharm_el_sheikh',
      countryCode: 'EG',
      names: {'en': 'Sharm El Sheikh', 'tr': 'Şarm El-Şeyh', 'ar': 'شرم الشيخ', 'de': 'Scharm El-Scheich', 'fr': 'Charm el-Cheikh', 'es': 'Sharm el-Sheij', 'it': 'Sharm el-Sheikh', 'ru': 'Шарм-эль-Шейх'},
    ),
    PopularCity(
      id: 'hurghada',
      countryCode: 'EG',
      names: {'en': 'Hurghada', 'tr': 'Hurgada', 'ar': 'الغردقة', 'de': 'Hurghada', 'fr': 'Hurghada', 'es': 'Hurgada', 'it': 'Hurghada', 'ru': 'Хургада'},
    ),
    PopularCity(
      id: 'luxor',
      countryCode: 'EG',
      names: {'en': 'Luxor', 'tr': 'Luksor', 'ar': 'الأقصر', 'de': 'Luxor', 'fr': 'Louxor', 'es': 'Lúxor', 'it': 'Luxor', 'ru': 'Луксор'},
    ),
    PopularCity(
      id: 'aswan',
      countryCode: 'EG',
      names: {'en': 'Aswan', 'tr': 'Asvan', 'ar': 'أسوان', 'de': 'Assuan', 'fr': 'Assouan', 'es': 'Asuán', 'it': 'Assuan', 'ru': 'Асуан'},
    ),
    PopularCity(
      id: 'marrakech',
      countryCode: 'MA',
      names: {'en': 'Marrakech', 'tr': 'Marakeş', 'ar': 'مراكش', 'fr': 'Marrakech', 'de': 'Marrakesch', 'es': 'Marrakech', 'it': 'Marrakech', 'ru': 'Марракеш'},
    ),
    PopularCity(
      id: 'casablanca',
      countryCode: 'MA',
      names: {'en': 'Casablanca', 'tr': 'Kazablanka', 'ar': 'الدار البيضاء', 'fr': 'Casablanca', 'de': 'Casablanca', 'es': 'Casablanca', 'it': 'Casablanca', 'ru': 'Касабланка'},
    ),
    PopularCity(
      id: 'fes',
      countryCode: 'MA',
      names: {'en': 'Fes', 'tr': 'Fes', 'ar': 'فاس', 'fr': 'Fès', 'de': 'Fès', 'es': 'Fez', 'it': 'Fès', 'ru': 'Фес'},
    ),
    PopularCity(
      id: 'chefchaouen',
      countryCode: 'MA',
      names: {'en': 'Chefchaouen', 'tr': 'Şafşavan', 'ar': 'شفشاون', 'fr': 'Chefchaouen', 'de': 'Chefchaouen', 'es': 'Chauen', 'ru': 'Шефшауэн'},
    ),
    PopularCity(
      id: 'rabat',
      countryCode: 'MA',
      names: {'en': 'Rabat', 'tr': 'Rabat', 'ar': 'الرباط', 'fr': 'Rabat', 'de': 'Rabat', 'es': 'Rabat', 'it': 'Rabat', 'ru': 'Рабат'},
    ),
    PopularCity(
      id: 'tangier',
      countryCode: 'MA',
      names: {'en': 'Tangier', 'tr': 'Tanca', 'ar': 'طنجة', 'fr': 'Tanger', 'de': 'Tanger', 'es': 'Tánger', 'it': 'Tangeri', 'ru': 'Танжер'},
    ),
    PopularCity(
      id: 'tunis',
      countryCode: 'TN',
      names: {'en': 'Tunis', 'tr': 'Tunus', 'ar': 'تونس', 'fr': 'Tunis', 'de': 'Tunis', 'es': 'Túnez', 'it': 'Tunisi', 'ru': 'Тунис'},
    ),
    PopularCity(
      id: 'sousse',
      countryCode: 'TN',
      names: {'en': 'Sousse', 'tr': 'Suse', 'ar': 'سوسة', 'fr': 'Sousse', 'de': 'Sousse', 'es': 'Susa', 'it': 'Susa', 'ru': 'Сус'},
    ),

    // ----------------------------------------------------
    // Australia & New Zealand (AU, NZ)
    // ----------------------------------------------------
    PopularCity(
      id: 'sydney',
      countryCode: 'AU',
      names: {'en': 'Sydney', 'tr': 'Sidney', 'de': 'Sydney', 'fr': 'Sydney', 'es': 'Sídney', 'it': 'Sydney', 'ru': 'Сидней', 'zh': '悉尼'},
    ),
    PopularCity(
      id: 'melbourne',
      countryCode: 'AU',
      names: {'en': 'Melbourne', 'tr': 'Melbourne', 'de': 'Melbourne', 'fr': 'Melbourne', 'es': 'Melbourne', 'it': 'Melbourne', 'ru': 'Мельбурн', 'zh': '墨尔本'},
    ),
    PopularCity(
      id: 'brisbane',
      countryCode: 'AU',
      names: {'en': 'Brisbane', 'tr': 'Brisbane', 'de': 'Brisbane', 'fr': 'Brisbane', 'es': 'Brisbane', 'it': 'Brisbane', 'ru': 'Брисбен'},
    ),
    PopularCity(
      id: 'perth',
      countryCode: 'AU',
      names: {'en': 'Perth', 'tr': 'Perth', 'de': 'Perth', 'fr': 'Perth', 'es': 'Perth', 'it': 'Perth', 'ru': 'Перт'},
    ),
    PopularCity(
      id: 'gold_coast',
      countryCode: 'AU',
      names: {'en': 'Gold Coast', 'tr': 'Gold Coast', 'de': 'Gold Coast', 'fr': 'Gold Coast', 'es': 'Gold Coast', 'it': 'Gold Coast', 'ru': 'Голд-Кост'},
    ),
    PopularCity(
      id: 'cairns',
      countryCode: 'AU',
      names: {'en': 'Cairns', 'tr': 'Cairns', 'de': 'Cairns', 'fr': 'Cairns', 'es': 'Cairns', 'it': 'Cairns', 'ru': 'Кэрнс'},
    ),
    PopularCity(
      id: 'auckland',
      countryCode: 'NZ',
      names: {'en': 'Auckland', 'tr': 'Auckland', 'de': 'Auckland', 'fr': 'Auckland', 'es': 'Auckland', 'it': 'Auckland', 'ru': 'Окленд'},
    ),
    PopularCity(
      id: 'queenstown',
      countryCode: 'NZ',
      names: {'en': 'Queenstown', 'tr': 'Queenstown', 'de': 'Queenstown', 'fr': 'Queenstown', 'es': 'Queenstown', 'it': 'Queenstown', 'ru': 'Квинстаун'},
    ),
    PopularCity(
      id: 'christchurch',
      countryCode: 'NZ',
      names: {'en': 'Christchurch', 'tr': 'Christchurch', 'de': 'Christchurch', 'fr': 'Christchurch', 'es': 'Christchurch', 'it': 'Christchurch', 'ru': 'Крайстчерч'},
    ),
    PopularCity(
      id: 'wellington',
      countryCode: 'NZ',
      names: {'en': 'Wellington', 'tr': 'Wellington', 'de': 'Wellington', 'fr': 'Wellington', 'es': 'Wellington', 'it': 'Wellington', 'ru': 'Веллингтон'},
    ),

    // ----------------------------------------------------
    // Canada & Americas (CA, MX, BR, AR, CO, PE, CL)
    // ----------------------------------------------------
    PopularCity(
      id: 'toronto',
      countryCode: 'CA',
      names: {'en': 'Toronto', 'tr': 'Toronto', 'de': 'Toronto', 'fr': 'Toronto', 'es': 'Toronto', 'it': 'Toronto', 'ru': 'Торонто'},
    ),
    PopularCity(
      id: 'vancouver',
      countryCode: 'CA',
      names: {'en': 'Vancouver', 'tr': 'Vancouver', 'de': 'Vancouver', 'fr': 'Vancouver', 'es': 'Vancouver', 'it': 'Vancouver', 'ru': 'Ванкувер'},
    ),
    PopularCity(
      id: 'montreal',
      countryCode: 'CA',
      names: {'en': 'Montreal', 'tr': 'Montreal', 'fr': 'Montréal', 'de': 'Montreal', 'es': 'Montreal', 'it': 'Montréal', 'ru': 'Монреаль'},
    ),
    PopularCity(
      id: 'quebec_city',
      countryCode: 'CA',
      names: {'en': 'Quebec City', 'tr': 'Quebec', 'fr': 'Québec', 'de': 'Québec', 'es': 'Quebec', 'it': 'Québec', 'ru': 'Квебек'},
    ),
    PopularCity(
      id: 'calgary',
      countryCode: 'CA',
      names: {'en': 'Calgary', 'tr': 'Calgary', 'de': 'Calgary', 'fr': 'Calgary', 'es': 'Calgary', 'it': 'Calgary', 'ru': 'Калгари'},
    ),
    PopularCity(
      id: 'ottawa',
      countryCode: 'CA',
      names: {'en': 'Ottawa', 'tr': 'Ottawa', 'de': 'Ottawa', 'fr': 'Ottawa', 'es': 'Ottawa', 'it': 'Ottawa', 'ru': 'Оттава'},
    ),
    PopularCity(
      id: 'mexico_city',
      countryCode: 'MX',
      names: {'en': 'Mexico City', 'tr': 'Mexico City', 'es': 'Ciudad de México', 'de': 'Mexiko-Stadt', 'fr': 'Mexico', 'it': 'Città del Messico', 'ru': 'Мехико'},
    ),
    PopularCity(
      id: 'cancun',
      countryCode: 'MX',
      names: {'en': 'Cancun', 'tr': 'Cancun', 'es': 'Cancún', 'de': 'Cancún', 'fr': 'Cancún', 'it': 'Cancún', 'ru': 'Канкун'},
    ),
    PopularCity(
      id: 'playa_del_carmen',
      countryCode: 'MX',
      names: {'en': 'Playa del Carmen', 'tr': 'Playa del Carmen', 'es': 'Playa del Carmen', 'de': 'Playa del Carmen', 'fr': 'Playa del Carmen', 'ru': 'Плайя-дель-Кармен'},
    ),
    PopularCity(
      id: 'oaxaca',
      countryCode: 'MX',
      names: {'en': 'Oaxaca', 'tr': 'Oaxaca', 'es': 'Oaxaca', 'de': 'Oaxaca', 'fr': 'Oaxaca', 'it': 'Oaxaca', 'ru': 'Оахака'},
    ),
    PopularCity(
      id: 'guadalajara',
      countryCode: 'MX',
      names: {'en': 'Guadalajara', 'tr': 'Guadalajara', 'es': 'Guadalajara', 'de': 'Guadalajara', 'fr': 'Guadalajara', 'it': 'Guadalajara', 'ru': 'Гвадалахара'},
    ),
    PopularCity(
      id: 'rio_de_janeiro',
      countryCode: 'BR',
      names: {'en': 'Rio de Janeiro', 'tr': 'Rio de Janeiro', 'pt': 'Rio de Janeiro', 'de': 'Rio de Janeiro', 'fr': 'Rio de Janeiro', 'es': 'Río de Janeiro', 'it': 'Rio de Janeiro', 'ru': 'Рио-де-Жанейро'},
    ),
    PopularCity(
      id: 'sao_paulo',
      countryCode: 'BR',
      names: {'en': 'Sao Paulo', 'tr': 'Sao Paulo', 'pt': 'São Paulo', 'de': 'São Paulo', 'fr': 'São Paulo', 'es': 'São Paulo', 'it': 'San Paolo', 'ru': 'Сан-Паулу'},
    ),
    PopularCity(
      id: 'buenos_aires',
      countryCode: 'AR',
      names: {'en': 'Buenos Aires', 'tr': 'Buenos Aires', 'es': 'Buenos Aires', 'de': 'Buenos Aires', 'fr': 'Buenos Aires', 'it': 'Buenos Aires', 'ru': 'Буэнос-Айрес'},
    ),
    PopularCity(
      id: 'bogota',
      countryCode: 'CO',
      names: {'en': 'Bogota', 'tr': 'Bogota', 'es': 'Bogotá', 'de': 'Bogotá', 'fr': 'Bogota', 'it': 'Bogotà', 'ru': 'Богота'},
    ),
    PopularCity(
      id: 'medellin',
      countryCode: 'CO',
      names: {'en': 'Medellin', 'tr': 'Medellin', 'es': 'Medellín', 'de': 'Medellín', 'fr': 'Medellín', 'it': 'Medellín', 'ru': 'Медельин'},
    ),
    PopularCity(
      id: 'cartagena',
      countryCode: 'CO',
      names: {'en': 'Cartagena', 'tr': 'Cartagena', 'es': 'Cartagena', 'de': 'Cartagena', 'fr': 'Carthagène', 'it': 'Cartagena', 'ru': 'Картахена'},
    ),
    PopularCity(
      id: 'lima',
      countryCode: 'PE',
      names: {'en': 'Lima', 'tr': 'Lima', 'es': 'Lima', 'de': 'Lima', 'fr': 'Lima', 'it': 'Lima', 'ru': 'Лима'},
    ),
    PopularCity(
      id: 'cusco',
      countryCode: 'PE',
      names: {'en': 'Cusco', 'tr': 'Kusko', 'es': 'Cusco', 'de': 'Cusco', 'fr': 'Cuzco', 'it': 'Cusco', 'ru': 'Куско'},
    ),
    PopularCity(
      id: 'santiago',
      countryCode: 'CL',
      names: {'en': 'Santiago', 'tr': 'Santiago', 'es': 'Santiago de Chile', 'de': 'Santiago de Chile', 'fr': 'Santiago', 'it': 'Santiago del Cile', 'ru': 'Сантьяго'},
    ),

    // ----------------------------------------------------
    // Balkans & Eastern Europe (CY, NC, XK, BA, RS, ME, MK, AL, BG, RO, SI, SK)
    // ----------------------------------------------------
    PopularCity(
      id: 'nicosia',
      countryCode: 'NC',
      names: {'en': 'Nicosia', 'tr': 'Lefkoşa', 'el': 'Λευκωσία', 'de': 'Nikosia', 'fr': 'Nicosie', 'es': 'Nicosia', 'it': 'Nicosia', 'ru': 'Никосия'},
    ),
    PopularCity(
      id: 'kyrenia',
      countryCode: 'NC',
      names: {'en': 'Kyrenia', 'tr': 'Girne', 'el': 'Κερύνεια', 'de': 'Kyrenia', 'fr': 'Kyrenia', 'es': 'Kyrenia', 'it': 'Kyrenia', 'ru': 'Кирения'},
    ),
    PopularCity(
      id: 'famagusta',
      countryCode: 'NC',
      names: {'en': 'Famagusta', 'tr': 'Gazimağusa', 'el': 'Αμμόχωστος', 'de': 'Famagusta', 'fr': 'Famagouste', 'es': 'Famagusta', 'it': 'Famagosta', 'ru': 'Фамагуста'},
    ),
    PopularCity(
      id: 'pristina',
      countryCode: 'XK',
      names: {'en': 'Pristina', 'tr': 'Priştine', 'sq': 'Prishtinë', 'sr': 'Priština', 'de': 'Pristina', 'fr': 'Pristina', 'es': 'Pristina', 'it': 'Pristina', 'ru': 'Приштина'},
    ),
    PopularCity(
      id: 'prizren',
      countryCode: 'XK',
      names: {'en': 'Prizren', 'tr': 'Prizren', 'sq': 'Prizren', 'sr': 'Prizren', 'de': 'Prizren', 'fr': 'Prizren', 'es': 'Prizren', 'it': 'Prizren', 'ru': 'Призрен'},
    ),
    PopularCity(
      id: 'sarajevo',
      countryCode: 'BA',
      names: {'en': 'Sarajevo', 'tr': 'Saraybosna', 'bs': 'Sarajevo', 'de': 'Sarajevo', 'fr': 'Sarajevo', 'es': 'Sarajevo', 'it': 'Sarajevo', 'ru': 'Сараево', 'ar': 'سراييفو'},
    ),
    PopularCity(
      id: 'mostar',
      countryCode: 'BA',
      names: {'en': 'Mostar', 'tr': 'Mostar', 'bs': 'Mostar', 'de': 'Mostar', 'fr': 'Mostar', 'es': 'Mostar', 'it': 'Mostar', 'ru': 'Мостар'},
    ),
    PopularCity(
      id: 'belgrade',
      countryCode: 'RS',
      names: {'en': 'Belgrade', 'tr': 'Belgrad', 'sr': 'Beograd', 'de': 'Belgrad', 'fr': 'Belgrade', 'es': 'Belgrado', 'it': 'Belgrado', 'ru': 'Белград'},
    ),
    PopularCity(
      id: 'ljubljana',
      countryCode: 'SI',
      names: {'en': 'Ljubljana', 'tr': 'Lübliyana', 'sl': 'Ljubljana', 'de': 'Laibach', 'fr': 'Ljubljana', 'es': 'Liubliana', 'it': 'Lubiana', 'ru': 'Любляна'},
    ),
    PopularCity(
      id: 'skopje',
      countryCode: 'MK',
      names: {'en': 'Skopje', 'tr': 'Üsküp', 'mk': 'Скопје', 'de': 'Skopje', 'fr': 'Skopje', 'es': 'Skopje', 'it': 'Skopje', 'ru': 'Скопье'},
    ),
    PopularCity(
      id: 'tirana',
      countryCode: 'AL',
      names: {'en': 'Tirana', 'tr': 'Tiran', 'sq': 'Tiranë', 'de': 'Tirana', 'fr': 'Tirana', 'es': 'Tirana', 'it': 'Tirana', 'ru': 'Тирана'},
    ),
    PopularCity(
      id: 'podgorica',
      countryCode: 'ME',
      names: {'en': 'Podgorica', 'tr': 'Podgoritsa', 'cnr': 'Podgorica', 'de': 'Podgorica', 'fr': 'Podgorica', 'es': 'Podgorica', 'it': 'Podgorica', 'ru': 'Подгорица'},
    ),
    PopularCity(
      id: 'kotor',
      countryCode: 'ME',
      names: {'en': 'Kotor', 'tr': 'Kotor', 'cnr': 'Kotor', 'de': 'Kotor', 'fr': 'Kotor', 'es': 'Kotor', 'it': 'Cattaro', 'ru': 'Котор'},
    ),
    PopularCity(
      id: 'budva',
      countryCode: 'ME',
      names: {'en': 'Budva', 'tr': 'Budva', 'cnr': 'Budva', 'de': 'Budva', 'fr': 'Budva', 'es': 'Budva', 'it': 'Budua', 'ru': 'Будва'},
    ),
    PopularCity(
      id: 'sofia',
      countryCode: 'BG',
      names: {'en': 'Sofia', 'tr': 'Sofya', 'bg': 'София', 'de': 'Sofia', 'fr': 'Sofia', 'es': 'Sofía', 'it': 'Sofia', 'ru': 'София'},
    ),
    PopularCity(
      id: 'plovdiv',
      countryCode: 'BG',
      names: {'en': 'Plovdiv', 'tr': 'Filibe', 'bg': 'Пловдив', 'de': 'Plowdiw', 'fr': 'Plovdiv', 'es': 'Plovdiv', 'it': 'Plovdiv', 'ru': 'Пловдив'},
    ),
    PopularCity(
      id: 'bucharest',
      countryCode: 'RO',
      names: {'en': 'Bucharest', 'tr': 'Bükreş', 'ro': 'București', 'de': 'Bukarest', 'fr': 'Bucarest', 'es': 'Bucarest', 'it': 'Bucarest', 'ru': 'Бухарест'},
    ),
    PopularCity(
      id: 'brasov',
      countryCode: 'RO',
      names: {'en': 'Brasov', 'tr': 'Braşov', 'ro': 'Brașov', 'de': 'Kronstadt', 'fr': 'Brașov', 'es': 'Brașov', 'it': 'Brașov', 'ru': 'Брашов'},
    ),
    PopularCity(
      id: 'bratislava',
      countryCode: 'SK',
      names: {'en': 'Bratislava', 'tr': 'Bratislava', 'sk': 'Bratislava', 'de': 'Pressburg', 'fr': 'Bratislava', 'es': 'Bratislava', 'it': 'Bratislava', 'ru': 'Братислава'},
    ),

    // ----------------------------------------------------
    // Caucasus & Central Asia (GE, AZ, AM, UZ, KZ)
    // ----------------------------------------------------
    PopularCity(
      id: 'tbilisi',
      countryCode: 'GE',
      names: {'en': 'Tbilisi', 'tr': 'Tiflis', 'ka': 'თბილისი', 'de': 'Tiflis', 'fr': 'Tbilissi', 'es': 'Tiflis', 'it': 'Tbilisi', 'ru': 'Тбилиси'},
    ),
    PopularCity(
      id: 'batumi',
      countryCode: 'GE',
      names: {'en': 'Batumi', 'tr': 'Batum', 'ka': 'ბათუმი', 'de': 'Batumi', 'fr': 'Batoumi', 'es': 'Batumi', 'it': 'Batumi', 'ru': 'Батуми'},
    ),
    PopularCity(
      id: 'baku',
      countryCode: 'AZ',
      names: {'en': 'Baku', 'tr': 'Bakü', 'az': 'Bakı', 'de': 'Baku', 'fr': 'Bakou', 'es': 'Bakú', 'it': 'Baku', 'ru': 'Баку'},
    ),
    PopularCity(
      id: 'yerevan',
      countryCode: 'AM',
      names: {'en': 'Yerevan', 'tr': 'Erivan', 'hy': 'Երևան', 'de': 'Jerewan', 'fr': 'Erevan', 'es': 'Ereván', 'it': 'Erevan', 'ru': 'Ереван'},
    ),
    PopularCity(
      id: 'tashkent',
      countryCode: 'UZ',
      names: {'en': 'Tashkent', 'tr': 'Taşkent', 'uz': 'Toshkent', 'de': 'Taschkent', 'fr': 'Tachkent', 'es': 'Taskent', 'it': 'Tashkent', 'ru': 'Ташкент'},
    ),
    PopularCity(
      id: 'samarkand',
      countryCode: 'UZ',
      names: {'en': 'Samarkand', 'tr': 'Semerkant', 'uz': 'Samarqand', 'de': 'Samarkand', 'fr': 'Samarcande', 'es': 'Samarcanda', 'it': 'Samarcanda', 'ru': 'Самарканд'},
    ),
    PopularCity(
      id: 'bukhara',
      countryCode: 'UZ',
      names: {'en': 'Bukhara', 'tr': 'Buhara', 'uz': 'Buxoro', 'de': 'Buchara', 'fr': 'Boukhara', 'es': 'Bujará', 'it': 'Bukhara', 'ru': 'Бухара'},
    ),
    PopularCity(
      id: 'almaty',
      countryCode: 'KZ',
      names: {'en': 'Almaty', 'tr': 'Almatı', 'kk': 'Алматы', 'de': 'Almaty', 'fr': 'Almaty', 'es': 'Almaty', 'it': 'Almaty', 'ru': 'Алматы'},
    ),
    PopularCity(
      id: 'astana',
      countryCode: 'KZ',
      names: {'en': 'Astana', 'tr': 'Astana', 'kk': 'Астана', 'de': 'Astana', 'fr': 'Astana', 'es': 'Astana', 'it': 'Astana', 'ru': 'Астана'},
    ),

    // ----------------------------------------------------
    // South Asia & Rest of Asia (IN, LK, NP, MV, VN, PH)
    // ----------------------------------------------------
    PopularCity(
      id: 'delhi',
      countryCode: 'IN',
      names: {'en': 'New Delhi', 'tr': 'Yeni Delhi', 'hi': 'नई दिल्ली', 'de': 'Neu-Delhi', 'fr': 'New Delhi', 'es': 'Nueva Delhi', 'it': 'Nuova Delhi', 'ru': 'Нью-Дели'},
    ),
    PopularCity(
      id: 'mumbai',
      countryCode: 'IN',
      names: {'en': 'Mumbai', 'tr': 'Mumbai', 'hi': 'मुंबई', 'de': 'Mumbai', 'fr': 'Mumbai', 'es': 'Bombay', 'it': 'Mumbai', 'ru': 'Мумбаи'},
    ),
    PopularCity(
      id: 'jaipur',
      countryCode: 'IN',
      names: {'en': 'Jaipur', 'tr': 'Jaipur', 'hi': 'जयपुर', 'de': 'Jaipur', 'fr': 'Jaipur', 'es': 'Jaipur', 'it': 'Jaipur', 'ru': 'Джайпур'},
    ),
    PopularCity(
      id: 'agra',
      countryCode: 'IN',
      names: {'en': 'Agra', 'tr': 'Agra', 'hi': 'आगरा', 'de': 'Agra', 'fr': 'Agra', 'es': 'Agra', 'it': 'Agra', 'ru': 'Агра'},
    ),
    PopularCity(
      id: 'colombo',
      countryCode: 'LK',
      names: {'en': 'Colombo', 'tr': 'Kolombo', 'si': 'කොළඹ', 'de': 'Colombo', 'fr': 'Colombo', 'es': 'Colombo', 'it': 'Colombo', 'ru': 'Коломбо'},
    ),
    PopularCity(
      id: 'kathmandu',
      countryCode: 'NP',
      names: {'en': 'Kathmandu', 'tr': 'Katmandu', 'ne': 'काठमाडौं', 'de': 'Kathmandu', 'fr': 'Katmandou', 'es': 'Katmandú', 'it': 'Katmandu', 'ru': 'Катманду'},
    ),
    PopularCity(
      id: 'male',
      countryCode: 'MV',
      names: {'en': 'Male', 'tr': 'Male', 'dv': 'މާލެ', 'de': 'Malé', 'fr': 'Malé', 'es': 'Malé', 'it': 'Malé', 'ru': 'Мале'},
    ),
    PopularCity(
      id: 'hanoi',
      countryCode: 'VN',
      names: {'en': 'Hanoi', 'tr': 'Hanoi', 'vi': 'Hà Nội', 'de': 'Hanoi', 'fr': 'Hanoï', 'es': 'Hanói', 'it': 'Hanoi', 'ru': 'Ханой'},
    ),
    PopularCity(
      id: 'ho_chi_minh',
      countryCode: 'VN',
      names: {'en': 'Ho Chi Minh City', 'tr': 'Ho Chi Minh', 'vi': 'Thành phố Hồ Chí Minh', 'de': 'Ho-Chi-Minh-Stadt', 'fr': 'Hô Chi Minh-Ville', 'es': 'Ciudad Ho Chi Minh', 'it': 'Ho Chi Minh', 'ru': 'Хошимин'},
    ),
    PopularCity(
      id: 'da_nang',
      countryCode: 'VN',
      names: {'en': 'Da Nang', 'tr': 'Da Nang', 'vi': 'Đà Nẵng', 'de': 'Đà Nẵng', 'fr': 'Da Nang', 'es': 'Da Nang', 'it': 'Da Nang', 'ru': 'Дананг'},
    ),
    PopularCity(
      id: 'manila',
      countryCode: 'PH',
      names: {'en': 'Manila', 'tr': 'Manila', 'tl': 'Maynila', 'de': 'Manila', 'fr': 'Manille', 'es': 'Manila', 'it': 'Manila', 'ru': 'Манила'},
    ),
    PopularCity(
      id: 'cebu',
      countryCode: 'PH',
      names: {'en': 'Cebu', 'tr': 'Cebu', 'tl': 'Cebu', 'de': 'Cebu', 'fr': 'Cebu', 'es': 'Cebú', 'it': 'Cebu', 'ru': 'Себу'},
    ),

    // ----------------------------------------------------
    // Baltics & Eastern (EE, LV, LT, UA, RU)
    // ----------------------------------------------------
    PopularCity(
      id: 'tallinn',
      countryCode: 'EE',
      names: {'en': 'Tallinn', 'tr': 'Tallinn', 'et': 'Tallinn', 'de': 'Tallinn', 'fr': 'Tallinn', 'es': 'Tallin', 'it': 'Tallinn', 'ru': 'Таллин'},
    ),
    PopularCity(
      id: 'riga',
      countryCode: 'LV',
      names: {'en': 'Riga', 'tr': 'Riga', 'lv': 'Rīga', 'de': 'Riga', 'fr': 'Riga', 'es': 'Riga', 'it': 'Riga', 'ru': 'Рига'},
    ),
    PopularCity(
      id: 'vilnius',
      countryCode: 'LT',
      names: {'en': 'Vilnius', 'tr': 'Vilnüs', 'lt': 'Vilnius', 'de': 'Vilnius', 'fr': 'Vilnius', 'es': 'Vilna', 'it': 'Vilnius', 'ru': 'Вильнюс'},
    ),
    PopularCity(
      id: 'kyiv',
      countryCode: 'UA',
      names: {'en': 'Kyiv', 'tr': 'Kiev', 'uk': 'Київ', 'de': 'Kiew', 'fr': 'Kyïv', 'es': 'Kiev', 'it': 'Kiev', 'ru': 'Киев'},
    ),
    PopularCity(
      id: 'lviv',
      countryCode: 'UA',
      names: {'en': 'Lviv', 'tr': 'Lviv', 'uk': 'Львів', 'de': 'Lemberg', 'fr': 'Lviv', 'es': 'Leópolis', 'it': 'Leopoli', 'ru': 'Львов'},
    ),
    PopularCity(
      id: 'odesa',
      countryCode: 'UA',
      names: {'en': 'Odesa', 'tr': 'Odessa', 'uk': 'Одеса', 'de': 'Odessa', 'fr': 'Odessa', 'es': 'Odesa', 'it': 'Odessa', 'ru': 'Одесса'},
    ),
    PopularCity(
      id: 'moscow',
      countryCode: 'RU',
      names: {'en': 'Moscow', 'tr': 'Moskova', 'ru': 'Москва', 'de': 'Moskau', 'fr': 'Moscou', 'es': 'Moscú', 'it': 'Mosca'},
    ),
    PopularCity(
      id: 'saint_petersburg',
      countryCode: 'RU',
      names: {'en': 'Saint Petersburg', 'tr': 'Sankt Peterburg', 'ru': 'Санкт-Петербург', 'de': 'Sankt Petersburg', 'fr': 'Saint-Pétersbourg', 'es': 'San Petersburgo', 'it': 'San Pietroburgo'},
    ),
    PopularCity(
      id: 'kazan',
      countryCode: 'RU',
      names: {'en': 'Kazan', 'tr': 'Kazan', 'ru': 'Казань', 'tt': 'Казан', 'de': 'Kasan', 'fr': 'Kazan', 'es': 'Kazán', 'it': 'Kazan'},
    ),
    PopularCity(
      id: 'sochi',
      countryCode: 'RU',
      names: {'en': 'Sochi', 'tr': 'Soçi', 'ru': 'Сочи', 'de': 'Sotschi', 'fr': 'Sotchi', 'es': 'Sochi', 'it': 'Soči'},
    ),

    // ----------------------------------------------------
    // Sub-Saharan Africa & Indian Ocean (ZA, KE, TZ, ZW, MU, SC)
    // ----------------------------------------------------
    PopularCity(
      id: 'cape_town',
      countryCode: 'ZA',
      names: {'en': 'Cape Town', 'tr': 'Cape Town', 'af': 'Kaapstad', 'de': 'Kapstadt', 'fr': 'Le Cap', 'es': 'Ciudad del Cabo', 'it': 'Città del Capo', 'ru': 'Кейптаун'},
    ),
    PopularCity(
      id: 'johannesburg',
      countryCode: 'ZA',
      names: {'en': 'Johannesburg', 'tr': 'Johannesburg', 'af': 'Johannesburg', 'de': 'Johannesburg', 'fr': 'Johannesbourg', 'es': 'Johannesburgo', 'it': 'Johannesburg', 'ru': 'Йоханнесбург'},
    ),
    PopularCity(
      id: 'nairobi',
      countryCode: 'KE',
      names: {'en': 'Nairobi', 'tr': 'Nairobi', 'sw': 'Nairobi', 'de': 'Nairobi', 'fr': 'Nairobi', 'es': 'Nairobi', 'it': 'Nairobi', 'ru': 'Найроби'},
    ),
    PopularCity(
      id: 'zanzibar',
      countryCode: 'TZ',
      names: {'en': 'Zanzibar City', 'tr': 'Zanzibar', 'sw': 'Jiji la Zanzibar', 'de': 'Sansibar-Stadt', 'fr': 'Zanzibar', 'es': 'Zanzíbar', 'it': 'Zanzibar', 'ru': 'Занзибар'},
    ),
    PopularCity(
      id: 'victoria_falls',
      countryCode: 'ZW',
      names: {'en': 'Victoria Falls', 'tr': 'Victoria Şelaleleri', 'de': 'Victoriafälle', 'fr': 'Chutes Victoria', 'es': 'Cataratas Victoria', 'ru': 'Виктория-Фоллс'},
    ),
    PopularCity(
      id: 'port_louis',
      countryCode: 'MU',
      names: {'en': 'Port Louis', 'tr': 'Port Louis', 'fr': 'Port-Louis', 'de': 'Port Louis', 'es': 'Port Louis', 'it': 'Port Louis', 'ru': 'Порт-Луи'},
    ),

    // ----------------------------------------------------
    // Caribbean & Central America (CU, DO, PR, CR, PA)
    // ----------------------------------------------------
    PopularCity(
      id: 'havana',
      countryCode: 'CU',
      names: {'en': 'Havana', 'tr': 'Havana', 'es': 'La Habana', 'de': 'Havanna', 'fr': 'La Havane', 'it': 'L’Avana', 'ru': 'Гавана'},
    ),
    PopularCity(
      id: 'punta_cana',
      countryCode: 'DO',
      names: {'en': 'Punta Cana', 'tr': 'Punta Cana', 'es': 'Punta Cana', 'de': 'Punta Cana', 'fr': 'Punta Cana', 'ru': 'Пунта-Кана'},
    ),
    PopularCity(
      id: 'santo_domingo',
      countryCode: 'DO',
      names: {'en': 'Santo Domingo', 'tr': 'Santo Domingo', 'es': 'Santo Domingo', 'de': 'Santo Domingo', 'fr': 'Saint-Domingue', 'ru': 'Санто-Доминго'},
    ),
    PopularCity(
      id: 'san_juan',
      countryCode: 'PR',
      names: {'en': 'San Juan', 'tr': 'San Juan', 'es': 'San Juan', 'de': 'San Juan', 'fr': 'San Juan', 'it': 'San Juan', 'ru': 'Сан-Хуан'},
    ),
    PopularCity(
      id: 'san_jose_cr',
      countryCode: 'CR',
      names: {'en': 'San Jose', 'tr': 'San Jose', 'es': 'San José', 'de': 'San José', 'fr': 'San José', 'it': 'San José', 'ru': 'Сан-Хосе'},
    ),
    PopularCity(
      id: 'panama_city',
      countryCode: 'PA',
      names: {'en': 'Panama City', 'tr': 'Panama City', 'es': 'Ciudad de Panamá', 'de': 'Panama-Stadt', 'fr': 'Panama', 'it': 'Panamá', 'ru': 'Панама'},
    ),

    // ----------------------------------------------------
    // Microstates & Unique Destinations (MC, SM, VA, MT, AD, LI)
    // ----------------------------------------------------
    PopularCity(
      id: 'monaco',
      countryCode: 'MC',
      names: {'en': 'Monaco', 'tr': 'Monako', 'fr': 'Monaco', 'de': 'Monaco', 'es': 'Mónaco', 'it': 'Monaco', 'ru': 'Монако'},
    ),
    PopularCity(
      id: 'san_marino',
      countryCode: 'SM',
      names: {'en': 'San Marino', 'tr': 'San Marino', 'it': 'San Marino', 'de': 'San Marino', 'fr': 'Saint-Marin', 'es': 'San Marino', 'ru': 'Сан-Марино'},
    ),
    PopularCity(
      id: 'vatican_city',
      countryCode: 'VA',
      names: {'en': 'Vatican City', 'tr': 'Vatikan', 'it': 'Città del Vaticano', 'de': 'Vatikanstadt', 'fr': 'Cité du Vatican', 'es': 'Ciudad del Vaticano', 'ru': 'Ватикан'},
    ),
    PopularCity(
      id: 'valletta',
      countryCode: 'MT',
      names: {'en': 'Valletta', 'tr': 'Valletta', 'mt': 'Valletta', 'de': 'Valletta', 'fr': 'La Valette', 'es': 'La Valeta', 'it': 'La Valletta', 'ru': 'Валлетта'},
    ),
    PopularCity(
      id: 'andorra_la_vella',
      countryCode: 'AD',
      names: {'en': 'Andorra la Vella', 'tr': 'Andorra la Vella', 'ca': 'Andorra la Vella', 'es': 'Andorra la Vieja', 'fr': 'Andorre-la-Vieille', 'de': 'Andorra la Vella', 'ru': 'Андорра-ла-Велья'},
    ),
    PopularCity(
      id: 'vaduz',
      countryCode: 'LI',
      names: {'en': 'Vaduz', 'tr': 'Vaduz', 'de': 'Vaduz', 'fr': 'Vaduz', 'es': 'Vaduz', 'it': 'Vaduz', 'ru': 'Вадуц'},
    ),
  ];

  /// Strips diacritics and normalizes Turkish/European chars for robust cross-language comparisons.
  static String normalizeTerm(String text) {
    return text
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase()
        .replaceAll('\u0307', '');
  }

  /// Finds cities matching query with prefix-first priority across localized, English, Turkish and native names.
  static List<PopularCity> searchCities(String query, {int limit = 10}) {
    final q = normalizeTerm(query);
    if (q.length < 2) return const [];

    final prefixMatches = <PopularCity>[];
    final containsMatches = <PopularCity>[];

    for (final city in popularCities) {
      bool isPrefix = false;
      bool isContains = false;

      for (final term in city.allSearchTerms) {
        if (term.startsWith(q)) {
          isPrefix = true;
          break;
        } else if (term.contains(q)) {
          isContains = true;
        }
      }

      if (isPrefix) {
        prefixMatches.add(city);
      } else if (isContains) {
        containsMatches.add(city);
      }
    }

    return [...prefixMatches, ...containsMatches].take(limit).toList();
  }

  /// Exact match resolver for city name across any supported language.
  static PopularCity? findCityExact(String query) {
    final q = normalizeTerm(query);
    if (q.isEmpty) return null;

    for (final city in popularCities) {
      for (final term in city.allSearchTerms) {
        if (term == q) return city;
      }
    }
    return null;
  }

  /// Dynamically localizes an itinerary stop string (e.g. "🇮🇹 Roma, İtalya" -> "🇮🇹 Rome, Italy")
  /// to the active language. Also preserves custom locations like "📍 My Grandma's Farm".
  static String localizeStop(String stop, String languageCode) {
    final trimmed = stop.trim();
    if (trimmed.isEmpty || trimmed.startsWith('📍')) return trimmed;

    // Extract leading flag emoji or travel icon if present using Unicode code points
    String flag = '';
    String rest = trimmed;

    final runes = trimmed.runes.toList();
    if (runes.length >= 2 &&
        runes[0] >= 0x1F1E6 && runes[0] <= 0x1F1FF &&
        runes[1] >= 0x1F1E6 && runes[1] <= 0x1F1FF) {
      flag = String.fromCharCodes([runes[0], runes[1]]);
      rest = String.fromCharCodes(runes.sublist(2)).trim();
    } else if (runes.isNotEmpty &&
        (runes[0] == 0x2708 ||
            runes[0] == 0x1F30D ||
            runes[0] == 0x1F30E ||
            runes[0] == 0x1F30F)) {
      flag = String.fromCharCodes([runes[0]]);
      rest = String.fromCharCodes(runes.sublist(1)).trim();
    }

    if (rest.contains(',')) {
      final parts = rest.split(',');
      final cityPart = parts[0].trim();
      final countryPart = parts.sublist(1).join(',').trim();

      // Find matching city
      final city = findCityExact(cityPart);
      if (city != null) {
        final locCity = city.getLocalizedName(languageCode);
        final country = Country.fromCode(city.countryCode);
        final locCountry = country != null
            ? country.getLocalizedName(languageCode)
            : (CountryLocalization.getCountryName(city.countryCode, languageCode) ?? city.countryCode);
        final activeFlag = country?.flag ?? flag;
        return '$activeFlag $locCity, $locCountry'.trim();
      }

      // If city isn't in popular list, try localizing country part
      for (final c in Country.allCountries) {
        if (c.matchesSearch(countryPart)) {
          final locCountry = c.getLocalizedName(languageCode);
          final activeFlag = c.flag.isNotEmpty ? c.flag : flag;
          return '$activeFlag $cityPart, $locCountry'.trim();
        }
      }
    } else {
      // Just a city or country name
      final city = findCityExact(rest);
      if (city != null) {
        final locCity = city.getLocalizedName(languageCode);
        final country = Country.fromCode(city.countryCode);
        final activeFlag = country?.flag ?? flag;
        return '$activeFlag $locCity'.trim();
      }
      for (final c in Country.allCountries) {
        if (c.matchesSearch(rest)) {
          final locCountry = c.getLocalizedName(languageCode);
          return '${c.flag} $locCountry';
        }
      }
    }

    return trimmed;
  }

  /// Localizes an entire route / destination chain (e.g. "🇹🇷 İstanbul, Türkiye ➔ 🇩🇪 Münih, Almanya")
  static String localizeDestination(String destination, String languageCode) {
    if (destination.trim().isEmpty) return destination;
    final stops = destination.split(RegExp(r'\s*➔\s*'));
    final localizedStops = stops.map((s) => localizeStop(s, languageCode)).toList();
    return localizedStops.join(' ➔ ');
  }
}
