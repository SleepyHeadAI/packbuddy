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
      names: {'en': 'Istanbul', 'tr': 'İstanbul', 'de': 'Istanbul', 'fr': 'Istanbul', 'es': 'Estambul', 'it': 'Istanbul', 'ru': 'Стамбул', 'ar': 'إسطنبول', 'zh': '伊斯坦布尔', 'ja': 'イスタンブール', 'el': 'Ιστανμπούλ', 'th': 'อิสตันบูล', 'hi': 'इस्तांबुल', 'ko': '이스탄불'},
    ),
    PopularCity(
      id: 'antalya',
      countryCode: 'TR',
      names: {'en': 'Antalya', 'tr': 'Antalya', 'de': 'Antalya', 'fr': 'Antalya', 'es': 'Antalya', 'it': 'Antalya', 'ru': 'Анталья', 'ar': 'أنطاليا', 'zh': '安塔利亚', 'ja': 'アンタルヤ', 'el': 'Αττάλεια', 'th': 'อันตัลยา', 'hi': 'अंताल्या', 'ko': '안탈리아'},
    ),
    PopularCity(
      id: 'izmir',
      countryCode: 'TR',
      names: {'en': 'Izmir', 'tr': 'İzmir', 'de': 'Izmir', 'fr': 'Izmir', 'es': 'Esmirna', 'it': 'Smirne', 'ru': 'Измир', 'ar': 'إزمير', 'zh': '伊兹密尔', 'ja': 'イズミル', 'el': 'Σμύρνη', 'th': 'อิซมีร์', 'hi': 'इज़मिर', 'ko': '이즈미르'},
    ),
    PopularCity(
      id: 'cappadocia',
      countryCode: 'TR',
      names: {'en': 'Cappadocia', 'tr': 'Kapadokya', 'de': 'Kappadokien', 'fr': 'Cappadoce', 'es': 'Capadocia', 'it': 'Cappadocia', 'ru': 'Каппадокия', 'ar': 'كابادوكيا', 'zh': '卡帕多奇亚', 'ja': 'カッパドキア', 'el': 'Καππαδοκία', 'th': 'แคปพาโดเชีย', 'hi': 'काप्पादोकिया', 'ko': '카파도키아'},
    ),
    PopularCity(
      id: 'bodrum',
      countryCode: 'TR',
      names: {'en': 'Bodrum', 'tr': 'Bodrum', 'de': 'Bodrum', 'fr': 'Bodrum', 'es': 'Bodrum', 'it': 'Bodrum', 'ru': 'Бодрум', 'ar': 'بدروم', 'zh': '博德鲁姆', 'ja': 'ボドルム', 'el': 'Μπόντρουμ', 'th': 'โบดรุม', 'hi': 'बोद्रुम', 'ko': '보드룸'},
    ),
    PopularCity(
      id: 'ankara',
      countryCode: 'TR',
      names: {'en': 'Ankara', 'tr': 'Ankara', 'de': 'Ankara', 'fr': 'Ankara', 'es': 'Ankara', 'it': 'Ankara', 'ru': 'Анкара', 'ar': 'أنقرة', 'zh': '安卡拉', 'ja': 'アンカラ', 'el': 'Άγκυρα', 'th': 'อังการา', 'hi': 'अंकारा', 'ko': '앙카라'},
    ),
    PopularCity(
      id: 'trabzon',
      countryCode: 'TR',
      names: {'en': 'Trabzon', 'tr': 'Trabzon', 'de': 'Trabzon', 'fr': 'Trébizonde', 'es': 'Trebisonda', 'it': 'Trebisonda', 'ru': 'Трабзон', 'ar': 'طرابزون', 'zh': '特拉布宗', 'ja': 'トラブゾン', 'el': 'Τραπεζούντα', 'th': 'แทรปซอน', 'hi': 'त्राबज़ोन', 'ko': '트라브존'},
    ),
    PopularCity(
      id: 'bursa',
      countryCode: 'TR',
      names: {'en': 'Bursa', 'tr': 'Bursa', 'de': 'Bursa', 'fr': 'Bursa', 'es': 'Bursa', 'it': 'Bursa', 'ru': 'Бурса', 'ar': 'بورصة', 'zh': '布尔萨', 'ja': 'ブルサ', 'el': 'Προύσα', 'th': 'บูร์ซา', 'hi': 'बुर्सा', 'ko': '부르사'},
    ),
    PopularCity(
      id: 'fethiye',
      countryCode: 'TR',
      names: {'en': 'Fethiye', 'tr': 'Fethiye', 'de': 'Fethiye', 'fr': 'Fethiye', 'es': 'Fethiye', 'it': 'Fethiye', 'ru': 'Фетхие', 'ar': 'الفتحية', 'zh': '费特希耶', 'ja': 'フェトヒイェ', 'el': 'Φετχιγιέ', 'th': 'เฟทิเย', 'hi': 'फ़ेतिये', 'ko': '페티예'},
    ),
    PopularCity(
      id: 'marmaris',
      countryCode: 'TR',
      names: {'en': 'Marmaris', 'tr': 'Marmaris', 'de': 'Marmaris', 'fr': 'Marmaris', 'es': 'Marmaris', 'it': 'Marmaris', 'ru': 'Мармарис', 'ar': 'مرمريس', 'zh': '马尔马里斯港', 'ja': 'マルマリス', 'el': 'Μαρμαρίδα', 'th': 'มาร์มาริส', 'hi': 'मार्मारिस', 'ko': '마르마리스'},
    ),
    PopularCity(
      id: 'alanya',
      countryCode: 'TR',
      names: {'en': 'Alanya', 'tr': 'Alanya', 'de': 'Alanya', 'fr': 'Alanya', 'es': 'Alanya', 'it': 'Alanya', 'ru': 'Аланья', 'ar': 'علانية', 'zh': '阿拉尼亚', 'ja': 'アランヤ', 'el': 'Αλάνγια', 'th': 'อาลันยา', 'hi': 'अलान्या', 'ko': '알라니아'},
    ),
    PopularCity(
      id: 'cesme',
      countryCode: 'TR',
      names: {'en': 'Cesme', 'tr': 'Çeşme', 'de': 'Çeşme', 'fr': 'Çeşme', 'es': 'Çeşme', 'it': 'Çeşme', 'ru': 'Чешме', 'ar': 'جشمة', 'zh': '切什梅', 'ja': 'チェシュメ', 'el': 'Τσεσμέ', 'th': 'เชชเม', 'hi': 'चेशमे', 'ko': '체슈메'},
    ),
    PopularCity(
      id: 'pamukkale',
      countryCode: 'TR',
      names: {'en': 'Pamukkale', 'tr': 'Pamukkale', 'de': 'Pamukkale', 'fr': 'Pamukkale', 'es': 'Pamukkale', 'it': 'Pamukkale', 'ru': 'Памуккале', 'ar': 'باموق قلعة', 'zh': '棉花堡', 'ja': 'パムッカレ', 'el': 'Παμούκαλε', 'th': 'ปามุกกาเล', 'hi': 'पामुक्काले', 'ko': '파묵칼레'},
    ),
    PopularCity(
      id: 'gaziantep',
      countryCode: 'TR',
      names: {'en': 'Gaziantep', 'tr': 'Gaziantep', 'de': 'Gaziantep', 'fr': 'Gaziantep', 'es': 'Gaziantep', 'it': 'Gaziantep', 'ru': 'Газиантеп', 'ar': 'عين تاب', 'zh': '加济安泰普', 'ja': 'ガズィアンテプ', 'el': 'Γκαζιαντέπ', 'th': 'กาซีอันเท็พ', 'hi': 'ग़ाज़ियांतेप', 'ko': '가지안테프'},
    ),

    // ----------------------------------------------------
    // Italy (IT)
    // ----------------------------------------------------
    PopularCity(
      id: 'rome',
      countryCode: 'IT',
      names: {'en': 'Rome', 'tr': 'Roma', 'it': 'Roma', 'de': 'Rom', 'fr': 'Rome', 'es': 'Roma', 'ru': 'Рим', 'el': 'Ρώμη', 'ar': 'روما', 'zh': '罗马', 'ja': 'ローマ', 'th': 'โรม', 'hi': 'रोम', 'ko': '로마'},
    ),
    PopularCity(
      id: 'milan',
      countryCode: 'IT',
      names: {'en': 'Milan', 'tr': 'Milano', 'it': 'Milano', 'de': 'Mailand', 'fr': 'Milan', 'es': 'Milán', 'ru': 'Милан', 'ar': 'ميلانو', 'zh': '米兰', 'ja': 'ミラノ', 'el': 'Μιλάνο', 'th': 'มิลาน', 'hi': 'मिलानो', 'ko': '밀라노'},
    ),
    PopularCity(
      id: 'florence',
      countryCode: 'IT',
      names: {'en': 'Florence', 'tr': 'Floransa', 'it': 'Firenze', 'de': 'Florenz', 'fr': 'Florence', 'es': 'Florencia', 'ru': 'Флоренция', 'ar': 'فلورنسا', 'zh': '佛罗伦萨', 'ja': 'フィレンツェ', 'el': 'Φλωρεντία', 'th': 'ฟลอเรนซ์', 'hi': 'फ़्लोरेन्स', 'ko': '피렌체'},
    ),
    PopularCity(
      id: 'venice',
      countryCode: 'IT',
      names: {'en': 'Venice', 'tr': 'Venedik', 'it': 'Venezia', 'de': 'Venedig', 'fr': 'Venise', 'es': 'Venecia', 'ru': 'Венеция', 'ar': 'البندقية', 'zh': '威尼斯', 'ja': 'ヴェネツィア', 'el': 'Βενετία', 'th': 'เวนิส', 'hi': 'वेनिस', 'ko': '베네치아'},
    ),
    PopularCity(
      id: 'naples',
      countryCode: 'IT',
      names: {'en': 'Naples', 'tr': 'Napoli', 'it': 'Napoli', 'de': 'Neapel', 'fr': 'Naples', 'es': 'Nápoles', 'ru': 'Неаполь', 'ar': 'نابولي', 'zh': '那不勒斯', 'ja': 'ナポリ', 'el': 'Νάπολη', 'th': 'เนเปิลส์', 'hi': 'नेपल्स', 'ko': '나폴리'},
    ),
    PopularCity(
      id: 'bologna',
      countryCode: 'IT',
      names: {'en': 'Bologna', 'tr': 'Bolonya', 'it': 'Bologna', 'de': 'Bologna', 'fr': 'Bologne', 'es': 'Bolonia', 'ru': 'Болонья', 'ar': 'بولونيا', 'zh': '博洛尼亚', 'ja': 'ボローニャ', 'el': 'Μπολόνια', 'th': 'โบโลญญา', 'hi': 'बोलोन्या', 'ko': '볼로냐'},
    ),
    PopularCity(
      id: 'turin',
      countryCode: 'IT',
      names: {'en': 'Turin', 'tr': 'Torino', 'it': 'Torino', 'de': 'Turin', 'fr': 'Turin', 'es': 'Turín', 'ru': 'Турин', 'ar': 'تورينو', 'zh': '都灵', 'ja': 'トリノ', 'el': 'Τορίνο', 'th': 'ตูริน', 'hi': 'टोरीनो', 'ko': '토리노'},
    ),
    PopularCity(
      id: 'verona',
      countryCode: 'IT',
      names: {'en': 'Verona', 'tr': 'Verona', 'it': 'Verona', 'de': 'Verona', 'fr': 'Vérone', 'es': 'Verona', 'ru': 'Верона', 'ar': 'فيرونا', 'zh': '维罗纳', 'ja': 'ヴェローナ', 'el': 'Βερόνα', 'th': 'เวโรนา', 'hi': 'वेरोना', 'ko': '베로나'},
    ),
    PopularCity(
      id: 'palermo',
      countryCode: 'IT',
      names: {'en': 'Palermo', 'tr': 'Palermo', 'it': 'Palermo', 'de': 'Palermo', 'fr': 'Palerme', 'es': 'Palermo', 'ru': 'Палермо', 'ar': 'باليرمو', 'zh': '巴勒莫', 'ja': 'パレルモ', 'el': 'Παλέρμο', 'th': 'ปาแลร์โม', 'hi': 'पलेर्मो', 'ko': '팔레르모'},
    ),
    PopularCity(
      id: 'pisa',
      countryCode: 'IT',
      names: {'en': 'Pisa', 'tr': 'Pisa', 'it': 'Pisa', 'de': 'Pisa', 'fr': 'Pise', 'es': 'Pisa', 'ru': 'Пиза', 'ar': 'بيزا', 'zh': '比萨', 'ja': 'ピサ', 'el': 'Πίζα', 'th': 'ปิซา', 'hi': 'पीसा', 'ko': '피사'},
    ),
    PopularCity(
      id: 'amalfi',
      countryCode: 'IT',
      names: {'en': 'Amalfi', 'tr': 'Amalfi', 'it': 'Amalfi', 'de': 'Amalfi', 'fr': 'Amalfi', 'es': 'Amalfi', 'ru': 'Амальфи', 'ar': 'أمالفي', 'zh': '阿玛菲', 'ja': 'アマルフィ', 'el': 'Αμάλφι', 'th': 'อามาลฟี', 'hi': 'अमाल्फ़ी', 'ko': '아말피'},
    ),
    PopularCity(
      id: 'sorrento',
      countryCode: 'IT',
      names: {'en': 'Sorrento', 'tr': 'Sorrento', 'it': 'Sorrento', 'de': 'Sorrent', 'fr': 'Sorrente', 'es': 'Sorrento', 'ru': 'Сорренто', 'ar': 'سرنت', 'zh': '索伦托', 'ja': 'ソレント', 'el': 'Σορρέντο', 'th': 'ซอร์เรนโต', 'hi': 'सोरेन्टो', 'ko': '소렌토'},
    ),
    PopularCity(
      id: 'siena',
      countryCode: 'IT',
      names: {'en': 'Siena', 'tr': 'Siena', 'it': 'Siena', 'de': 'Siena', 'fr': 'Sienne', 'es': 'Siena', 'ru': 'Сиена', 'ar': 'سيينا', 'zh': '锡耶纳', 'ja': 'シエーナ', 'el': 'Σιένα', 'th': 'ซีเอนา', 'hi': 'सियेना', 'ko': '시에나'},
    ),
    PopularCity(
      id: 'catania',
      countryCode: 'IT',
      names: {'en': 'Catania', 'tr': 'Katanya', 'it': 'Catania', 'de': 'Catania', 'fr': 'Catane', 'es': 'Catania', 'ru': 'Катания', 'ar': 'قطانية', 'zh': '卡塔尼亚', 'ja': 'カターニア', 'el': 'Κατάνια', 'th': 'คาตาเนีย', 'hi': 'केटानिया', 'ko': '카타니아'},
    ),
    PopularCity(
      id: 'genoa',
      countryCode: 'IT',
      names: {'en': 'Genoa', 'tr': 'Cenova', 'it': 'Genova', 'de': 'Genua', 'fr': 'Gênes', 'es': 'Génova', 'ru': 'Генуя', 'ar': 'جنوة', 'zh': '热那亚', 'ja': 'ジェノヴァ', 'el': 'Γένοβα', 'th': 'เจนัว', 'hi': 'जेनोआ', 'ko': '제노바'},
    ),

    // ----------------------------------------------------
    // France (FR)
    // ----------------------------------------------------
    PopularCity(
      id: 'paris',
      countryCode: 'FR',
      names: {'en': 'Paris', 'tr': 'Paris', 'fr': 'Paris', 'de': 'Paris', 'es': 'París', 'it': 'Parigi', 'ru': 'Париж', 'ar': 'باريس', 'zh': '巴黎', 'ja': 'パリ', 'el': 'Παρίσι', 'th': 'ปารีส', 'hi': 'पेरिस', 'ko': '파리'},
    ),
    PopularCity(
      id: 'nice',
      countryCode: 'FR',
      names: {'en': 'Nice', 'tr': 'Nice', 'fr': 'Nice', 'de': 'Nizza', 'es': 'Niza', 'it': 'Nizza', 'ru': 'Ницца', 'ar': 'نيس', 'zh': '尼斯', 'ja': 'ニース', 'el': 'Νίκαια', 'th': 'นิส', 'hi': 'नीस', 'ko': '니스'},
    ),
    PopularCity(
      id: 'lyon',
      countryCode: 'FR',
      names: {'en': 'Lyon', 'tr': 'Lyon', 'fr': 'Lyon', 'de': 'Lyon', 'es': 'Lyon', 'it': 'Lione', 'ru': 'Лион', 'ar': 'ليون', 'zh': '里昂', 'ja': 'リヨン', 'el': 'Λυών', 'th': 'ลียง', 'hi': 'ल्यों', 'ko': '리옹'},
    ),
    PopularCity(
      id: 'marseille',
      countryCode: 'FR',
      names: {'en': 'Marseille', 'tr': 'Marsilya', 'fr': 'Marseille', 'de': 'Marseille', 'es': 'Marsella', 'it': 'Marsiglia', 'ru': 'Марсель', 'ar': 'مرسيليا', 'zh': '马赛', 'ja': 'マルセイユ', 'el': 'Μασσαλία', 'th': 'มาร์แซย์', 'hi': 'मार्सेय', 'ko': '마르세유'},
    ),
    PopularCity(
      id: 'bordeaux',
      countryCode: 'FR',
      names: {'en': 'Bordeaux', 'tr': 'Bordo', 'fr': 'Bordeaux', 'de': 'Bordeaux', 'es': 'Burdeos', 'it': 'Bordeaux', 'ru': 'Бордо', 'ar': 'بوردو', 'zh': '波尔多', 'ja': 'ボルドー', 'el': 'Μπορντώ', 'th': 'บอร์โด', 'hi': 'बोर्दो', 'ko': '보르도'},
    ),
    PopularCity(
      id: 'cannes',
      countryCode: 'FR',
      names: {'en': 'Cannes', 'tr': 'Cannes', 'fr': 'Cannes', 'de': 'Cannes', 'es': 'Cannes', 'it': 'Cannes', 'ru': 'Канны', 'ar': 'كان', 'zh': '戛纳', 'ja': 'カンヌ', 'el': 'Κάννες', 'th': 'กาน', 'hi': 'कान', 'ko': '칸'},
    ),
    PopularCity(
      id: 'strasbourg',
      countryCode: 'FR',
      names: {'en': 'Strasbourg', 'tr': 'Strazburg', 'fr': 'Strasbourg', 'de': 'Straßburg', 'es': 'Estrasburgo', 'it': 'Strasburgo', 'ru': 'Страсбург', 'ar': 'ستراسبورغ', 'zh': '斯特拉斯堡', 'ja': 'ストラスブール', 'el': 'Στρασβούργο', 'th': 'สทราซบูร์', 'hi': 'स्त्रासबुर', 'ko': '스트라스부르'},
    ),
    PopularCity(
      id: 'toulouse',
      countryCode: 'FR',
      names: {'en': 'Toulouse', 'tr': 'Toulouse', 'fr': 'Toulouse', 'de': 'Toulouse', 'es': 'Toulouse', 'it': 'Tolosa', 'ru': 'Тулуза', 'ar': 'تولوز', 'zh': '图卢兹', 'ja': 'トゥールーズ', 'el': 'Τουλούζη', 'th': 'ตูลูซ', 'hi': 'तुलूज़', 'ko': '툴루즈'},
    ),
    PopularCity(
      id: 'lille',
      countryCode: 'FR',
      names: {'en': 'Lille', 'tr': 'Lille', 'fr': 'Lille', 'de': 'Rijsel', 'es': 'Lille', 'it': 'Lilla', 'ru': 'Лилль', 'ar': 'ليل', 'zh': '里尔', 'ja': 'リール', 'el': 'Λιλ', 'th': 'ลีล', 'hi': 'लील', 'ko': '릴'},
    ),
    PopularCity(
      id: 'montpellier',
      countryCode: 'FR',
      names: {'en': 'Montpellier', 'tr': 'Montpellier', 'fr': 'Montpellier', 'de': 'Montpellier', 'es': 'Montpellier', 'it': 'Montpellier', 'ru': 'Монпелье', 'ar': 'مونبلييه', 'zh': '蒙彼利埃', 'ja': 'モンペリエ', 'el': 'Μονπελιέ', 'th': 'มงเปอลีเย', 'hi': 'मोंपलिये', 'ko': '몽펠리에'},
    ),
    PopularCity(
      id: 'aix_en_provence',
      countryCode: 'FR',
      names: {'en': 'Aix-en-Provence', 'tr': 'Aix-en-Provence', 'fr': 'Aix-en-Provence', 'de': 'Aix-en-Provence', 'es': 'Aix-en-Provence', 'ru': 'Экс-ан-Прованс', 'ar': 'آكس أون بروفانس', 'zh': '普罗旺斯地区艾克斯', 'ja': 'エクス＝アン＝プロヴァンス', 'el': 'Αιξ-αν-Προβάνς', 'th': 'แอ็กซ็องพรอว็องส์', 'hi': 'ए-आँ-प्रोवाँस', 'ko': '엑상프로방스'},
    ),

    // ----------------------------------------------------
    // Spain (ES)
    // ----------------------------------------------------
    PopularCity(
      id: 'barcelona',
      countryCode: 'ES',
      names: {'en': 'Barcelona', 'tr': 'Barselona', 'es': 'Barcelona', 'de': 'Barcelona', 'fr': 'Barcelone', 'it': 'Barcellona', 'ru': 'Барселона', 'ar': 'برشلونة', 'zh': '巴塞罗那', 'ja': 'バルセロナ', 'el': 'Βαρκελώνη', 'th': 'บาร์เซโลนา', 'hi': 'बार्सिलोना', 'ko': '바르셀로나'},
    ),
    PopularCity(
      id: 'madrid',
      countryCode: 'ES',
      names: {'en': 'Madrid', 'tr': 'Madrid', 'es': 'Madrid', 'de': 'Madrid', 'fr': 'Madrid', 'it': 'Madrid', 'ru': 'Мадрид', 'ar': 'مدريد', 'zh': '马德里', 'ja': 'マドリード', 'el': 'Μαδρίτη', 'th': 'มาดริด', 'hi': 'मद्रिद', 'ko': '마드리드'},
    ),
    PopularCity(
      id: 'seville',
      countryCode: 'ES',
      names: {'en': 'Seville', 'tr': 'Sevilla', 'es': 'Sevilla', 'de': 'Sevilla', 'fr': 'Séville', 'it': 'Siviglia', 'ru': 'Севилья', 'ar': 'إشبيلية', 'zh': '塞维利亚', 'ja': 'セビリア', 'el': 'Σεβίλλη', 'th': 'เซบิยา', 'hi': 'सेविला', 'ko': '세비야'},
    ),
    PopularCity(
      id: 'valencia',
      countryCode: 'ES',
      names: {'en': 'Valencia', 'tr': 'Valensiya', 'es': 'Valencia', 'de': 'Valencia', 'fr': 'Valence', 'it': 'Valencia', 'ru': 'Валенсия', 'ar': 'بلنسية', 'zh': '巴伦西亚', 'ja': 'バレンシア', 'el': 'Βαλένθια', 'th': 'บาเลนเซีย', 'hi': 'वालेंसिया / वालेंसिया', 'ko': '발렌시아'},
    ),
    PopularCity(
      id: 'granada',
      countryCode: 'ES',
      names: {'en': 'Granada', 'tr': 'Granada', 'es': 'Granada', 'de': 'Granada', 'fr': 'Grenade', 'it': 'Granada', 'ru': 'Гранада', 'ar': 'غرناطة', 'zh': '格拉纳达', 'ja': 'グラナダ', 'el': 'Γρανάδα', 'th': 'กรานาดา', 'hi': 'ग्रानादा', 'ko': '그라나다'},
    ),
    PopularCity(
      id: 'malaga',
      countryCode: 'ES',
      names: {'en': 'Malaga', 'tr': 'Malaga', 'es': 'Málaga', 'de': 'Málaga', 'fr': 'Malaga', 'it': 'Malaga', 'ru': 'Малага', 'ar': 'مالقة', 'zh': '马拉加', 'ja': 'マラガ', 'el': 'Μάλαγα', 'th': 'มาลากา', 'hi': 'मालागा', 'ko': '말라가'},
    ),
    PopularCity(
      id: 'bilbao',
      countryCode: 'ES',
      names: {'en': 'Bilbao', 'tr': 'Bilbao', 'es': 'Bilbao', 'de': 'Bilbao', 'fr': 'Bilbao', 'it': 'Bilbao', 'ru': 'Бильбао', 'ar': 'بلباو', 'zh': '毕尔巴鄂', 'ja': 'ビルバオ', 'el': 'Μπιλμπάο', 'th': 'บิลบาโอ', 'hi': 'बिलबाओ', 'ko': '빌바오'},
    ),
    PopularCity(
      id: 'san_sebastian',
      countryCode: 'ES',
      names: {'en': 'San Sebastian', 'tr': 'San Sebastian', 'es': 'San Sebastián', 'de': 'San Sebastián', 'fr': 'Saint-Sébastien', 'it': 'San Sebastián', 'ru': 'Сан-Себастьян', 'ar': 'سان سبستيان', 'zh': '圣塞瓦斯蒂安', 'ja': 'サン・セバスティアン', 'el': 'Σαν Σεμπαστιάν', 'th': 'ซานเซบัสเตียน', 'hi': 'सान सेबास्तियान', 'ko': '산세바스티안'},
    ),
    PopularCity(
      id: 'ibiza',
      countryCode: 'ES',
      names: {'en': 'Ibiza', 'tr': 'İbiza', 'es': 'Ibiza', 'de': 'Ibiza', 'fr': 'Ibiza', 'it': 'Ibiza', 'ru': 'Ибица', 'ar': 'يابسة', 'zh': '伊维萨岛', 'ja': 'イビサ島', 'el': 'Ίμπιζα', 'th': 'เกาะอิบิซา', 'hi': 'इबिसा', 'ko': '이비사섬'},
    ),
    PopularCity(
      id: 'mallorca',
      countryCode: 'ES',
      names: {'en': 'Palma de Mallorca', 'tr': 'Palma de Mallorca', 'es': 'Palma de Mallorca', 'de': 'Palma de Mallorca', 'fr': 'Palma de Majorque', 'it': 'Palma di Maiorca', 'ru': 'Пальма-де-Майорка', 'ar': 'ميورقة', 'zh': '马略卡岛帕尔马', 'ja': 'パルマ・デ・マヨルカ', 'el': 'Πάλμα ντε Μαγιόρκα', 'th': 'ปัลมาเดมายอร์กา', 'hi': 'पाल्मा डे मायोर्का', 'ko': '팔마데마요르카'},
    ),
    PopularCity(
      id: 'tenerife',
      countryCode: 'ES',
      names: {'en': 'Tenerife', 'tr': 'Tenerife', 'es': 'Tenerife', 'de': 'Teneriffa', 'fr': 'Ténérife', 'it': 'Tenerife', 'ru': 'Тенерифе', 'ar': 'تنريفه', 'zh': '特内里费岛', 'ja': 'テネリフェ', 'el': 'Τενερίφη', 'th': 'เกาะเตเนริเฟ', 'hi': 'तेनरीफ़', 'ko': '테네리페섬'},
    ),
    PopularCity(
      id: 'cordoba',
      countryCode: 'ES',
      names: {'en': 'Cordoba', 'tr': 'Kurtuba (Kordoba)', 'es': 'Córdoba', 'de': 'Córdoba', 'fr': 'Cordoue', 'it': 'Cordova', 'ru': 'Кордова', 'ar': 'قرطبة', 'zh': '科尔多瓦', 'ja': 'コルドバ', 'el': 'Κόρδοβα', 'th': 'กอร์โดบา', 'hi': 'कोर्दोबा', 'ko': '코르도바'},
    ),
    PopularCity(
      id: 'toledo',
      countryCode: 'ES',
      names: {'en': 'Toledo', 'tr': 'Tuleytula (Toledo)', 'es': 'Toledo', 'de': 'Toledo', 'fr': 'Tolède', 'it': 'Toledo', 'ru': 'Толедо', 'ar': 'طليطلة', 'zh': '托莱多', 'ja': 'トレド', 'el': 'Τολέδο', 'th': 'โตเลโด', 'hi': 'टोलेडो', 'ko': '톨레도'},
    ),
    PopularCity(
      id: 'alicante',
      countryCode: 'ES',
      names: {'en': 'Alicante', 'tr': 'Alicante', 'es': 'Alicante', 'de': 'Alicante', 'fr': 'Alicante', 'it': 'Alicante', 'ru': 'Аликанте', 'ar': 'لقنت', 'zh': '阿利坎特', 'ja': 'アリカンテ', 'el': 'Αλικάντε', 'th': 'อาลิกันเต', 'hi': 'अलिकांते', 'ko': '알리칸테'},
    ),

    // ----------------------------------------------------
    // Germany (DE)
    // ----------------------------------------------------
    PopularCity(
      id: 'berlin',
      countryCode: 'DE',
      names: {'en': 'Berlin', 'tr': 'Berlin', 'de': 'Berlin', 'fr': 'Berlin', 'es': 'Berlín', 'it': 'Berlino', 'ru': 'Берлин', 'ar': 'برلين', 'zh': '柏林', 'ja': 'ベルリン', 'el': 'Βερολίνο', 'th': 'เบอร์ลิน', 'hi': 'बर्लिन', 'ko': '베를린'},
    ),
    PopularCity(
      id: 'munich',
      countryCode: 'DE',
      names: {'en': 'Munich', 'tr': 'Münih', 'de': 'München', 'fr': 'Munich', 'es': 'Múnich', 'it': 'Monaco di Baviera', 'ru': 'Мюнхен', 'ar': 'ميونيخ', 'zh': '慕尼黑', 'ja': 'ミュンヘン', 'el': 'Μόναχο', 'th': 'มิวนิก', 'hi': 'म्यूनिख', 'ko': '뮌헨'},
    ),
    PopularCity(
      id: 'frankfurt',
      countryCode: 'DE',
      names: {'en': 'Frankfurt', 'tr': 'Frankfurt', 'de': 'Frankfurt am Main', 'fr': 'Francfort', 'es': 'Fráncfort', 'it': 'Francoforte', 'ru': 'Франкфурт', 'zh': '法兰克福', 'ar': 'فرانكفورت', 'ja': 'フランクフルト・アム・マイン', 'el': 'Φρανκφούρτη', 'th': 'แฟรงก์เฟิร์ต', 'hi': 'फ़्रैंकफ़र्ट', 'ko': '프랑크푸르트암마인'},
    ),
    PopularCity(
      id: 'hamburg',
      countryCode: 'DE',
      names: {'en': 'Hamburg', 'tr': 'Hamburg', 'de': 'Hamburg', 'fr': 'Hambourg', 'es': 'Hamburgo', 'it': 'Amburgo', 'ru': 'Гамбург', 'ar': 'هامبورغ', 'zh': '汉堡', 'ja': 'ハンブルク', 'el': 'Αμβούργο', 'th': 'ฮัมบวร์ค', 'hi': 'हैम्बर्ग', 'ko': '함부르크'},
    ),
    PopularCity(
      id: 'cologne',
      countryCode: 'DE',
      names: {'en': 'Cologne', 'tr': 'Köln', 'de': 'Köln', 'fr': 'Cologne', 'es': 'Colonia', 'it': 'Colonia', 'ru': 'Кёльн', 'ar': 'كولونيا', 'zh': '科隆', 'ja': 'ケルン', 'el': 'Κολωνία', 'th': 'โคโลญ', 'hi': 'कोलोन', 'ko': '쾰른'},
    ),
    PopularCity(
      id: 'stuttgart',
      countryCode: 'DE',
      names: {'en': 'Stuttgart', 'tr': 'Stuttgart', 'de': 'Stuttgart', 'fr': 'Stuttgart', 'es': 'Stuttgart', 'it': 'Stoccarda', 'ru': 'Штутгарт', 'ar': 'شتوتغارت', 'zh': '斯图加特', 'ja': 'シュトゥットガルト', 'el': 'Στουτγκάρδη', 'th': 'ชตุทการ์ท', 'hi': 'श्टुटगार्ट', 'ko': '슈투트가르트'},
    ),
    PopularCity(
      id: 'dusseldorf',
      countryCode: 'DE',
      names: {'en': 'Dusseldorf', 'tr': 'Düsseldorf', 'de': 'Düsseldorf', 'fr': 'Düsseldorf', 'es': 'Düsseldorf', 'it': 'Düsseldorf', 'ru': 'Дюссельдорф', 'ar': 'دوسلدورف', 'zh': '杜塞尔多夫', 'ja': 'デュッセルドルフ', 'el': 'Ντύσσελντορφ', 'th': 'ดึสเซิลดอร์ฟ', 'hi': 'डसेलडॉर्फ़', 'ko': '뒤셀도르프'},
    ),
    PopularCity(
      id: 'dresden',
      countryCode: 'DE',
      names: {'en': 'Dresden', 'tr': 'Dresden', 'de': 'Dresden', 'fr': 'Dresde', 'es': 'Dresde', 'it': 'Dresda', 'ru': 'Дрезден', 'ar': 'درسدن', 'zh': '德累斯顿', 'ja': 'ドレスデン', 'el': 'Δρέσδη', 'th': 'เดรสเดิน', 'hi': 'ड्रेसडेन', 'ko': '드레스덴'},
    ),
    PopularCity(
      id: 'nuremberg',
      countryCode: 'DE',
      names: {'en': 'Nuremberg', 'tr': 'Nürnberg', 'de': 'Nürnberg', 'fr': 'Nuremberg', 'es': 'Núremberg', 'it': 'Norimberga', 'ru': 'Нюрнберг', 'ar': 'نورنبرغ', 'zh': '纽伦堡', 'ja': 'ニュルンベルク', 'el': 'Νυρεμβέργη', 'th': 'เนือร์นแบร์ค', 'hi': 'नूर्नबर्ग', 'ko': '뉘른베르크'},
    ),
    PopularCity(
      id: 'heidelberg',
      countryCode: 'DE',
      names: {'en': 'Heidelberg', 'tr': 'Heidelberg', 'de': 'Heidelberg', 'fr': 'Heidelberg', 'es': 'Heidelberg', 'it': 'Heidelberg', 'ru': 'Гейдельберг', 'ar': 'هيدلبرغ', 'zh': '海德堡', 'ja': 'ハイデルベルク', 'el': 'Χαϊδελβέργη', 'th': 'ไฮเดิลแบร์ค', 'hi': 'हाइडलबर्ग', 'ko': '하이델베르크'},
    ),

    // ----------------------------------------------------
    // United Kingdom (GB)
    // ----------------------------------------------------
    PopularCity(
      id: 'london',
      countryCode: 'GB',
      names: {'en': 'London', 'tr': 'Londra', 'fr': 'Londres', 'es': 'Londres', 'it': 'Londra', 'de': 'London', 'ru': 'Лондон', 'ar': 'لندن', 'zh': '伦敦', 'ja': 'ロンドン', 'el': 'Λονδίνο', 'th': 'ลอนดอน', 'hi': 'लंदन', 'ko': '런던'},
    ),
    PopularCity(
      id: 'edinburgh',
      countryCode: 'GB',
      names: {'en': 'Edinburgh', 'tr': 'Edinburgh', 'fr': 'Édimbourg', 'es': 'Edimburgo', 'it': 'Edimburgo', 'de': 'Edinburgh', 'ru': 'Эдинбург', 'ar': 'إدنبرة', 'zh': '爱丁堡', 'ja': 'エディンバラ', 'el': 'Εδιμβούργο', 'th': 'เอดินบะระ', 'hi': 'एडिनबरा', 'ko': '에든버러'},
    ),
    PopularCity(
      id: 'manchester',
      countryCode: 'GB',
      names: {'en': 'Manchester', 'tr': 'Manchester', 'de': 'Manchester', 'fr': 'Manchester', 'es': 'Mánchester', 'it': 'Manchester', 'ru': 'Манчестер', 'ar': 'مانشستر', 'zh': '曼彻斯特', 'ja': 'マンチェスター', 'el': 'Μάντσεστερ', 'th': 'แมนเชสเตอร์', 'hi': 'मैन्चेस्टर', 'ko': '맨체스터'},
    ),
    PopularCity(
      id: 'liverpool',
      countryCode: 'GB',
      names: {'en': 'Liverpool', 'tr': 'Liverpool', 'de': 'Liverpool', 'fr': 'Liverpool', 'es': 'Liverpool', 'it': 'Liverpool', 'ru': 'Ливерпуль', 'ar': 'ليفربول', 'zh': '利物浦', 'ja': 'リヴァプール', 'el': 'Λίβερπουλ', 'th': 'ลิเวอร์พูล', 'hi': 'लिवरपूल', 'ko': '리버풀'},
    ),
    PopularCity(
      id: 'birmingham',
      countryCode: 'GB',
      names: {'en': 'Birmingham', 'tr': 'Birmingham', 'de': 'Birmingham', 'fr': 'Birmingham', 'es': 'Birmingham', 'it': 'Birmingham', 'ru': 'Бирмингем', 'ar': 'برمنغهام', 'zh': '伯明翰', 'ja': 'バーミンガム', 'el': 'Μπέρμιγχαμ', 'th': 'เบอร์มิงแฮม', 'hi': 'बर्मिंघम', 'ko': '버밍엄'},
    ),
    PopularCity(
      id: 'oxford',
      countryCode: 'GB',
      names: {'en': 'Oxford', 'tr': 'Oxford', 'de': 'Oxford', 'fr': 'Oxford', 'es': 'Oxford', 'it': 'Oxford', 'ru': 'Оксфорд', 'ar': 'أكسفورد', 'zh': '牛津', 'ja': 'オックスフォード', 'el': 'Οξφόρδη', 'th': 'ออกซฟอร์ด', 'hi': 'ऑक्सफोर्ड', 'ko': '옥스퍼드'},
    ),
    PopularCity(
      id: 'cambridge',
      countryCode: 'GB',
      names: {'en': 'Cambridge', 'tr': 'Cambridge', 'de': 'Cambridge', 'fr': 'Cambridge', 'es': 'Cambridge', 'it': 'Cambridge', 'ru': 'Кембридж', 'ar': 'كامبريدج', 'zh': '剑桥', 'ja': 'ケンブリッジ', 'el': 'Κέιμπριτζ', 'th': 'เคมบริดจ์', 'hi': 'कैम्ब्रिज', 'ko': '케임브리지'},
    ),
    PopularCity(
      id: 'bath',
      countryCode: 'GB',
      names: {'en': 'Bath', 'tr': 'Bath', 'de': 'Bath', 'fr': 'Bath', 'es': 'Bath', 'it': 'Bath', 'ru': 'Бат', 'ar': 'باث', 'zh': '巴斯', 'ja': 'バース', 'el': 'Μπαθ', 'th': 'บาธ', 'hi': 'बाथ', 'ko': '바스'},
    ),
    PopularCity(
      id: 'belfast',
      countryCode: 'GB',
      names: {'en': 'Belfast', 'tr': 'Belfast', 'de': 'Belfast', 'fr': 'Belfast', 'es': 'Belfast', 'it': 'Belfast', 'ru': 'Белфаст', 'ar': 'بلفاست', 'zh': '贝尔法斯特', 'ja': 'ベルファスト', 'el': 'Μπέλφαστ', 'th': 'เบลฟาสต์', 'hi': 'बेलफ़ास्ट', 'ko': '벨파스트'},
    ),
    PopularCity(
      id: 'glasgow',
      countryCode: 'GB',
      names: {'en': 'Glasgow', 'tr': 'Glasgow', 'de': 'Glasgow', 'fr': 'Glasgow', 'es': 'Glasgow', 'it': 'Glasgow', 'ru': 'Глазго', 'ar': 'غلاسكو', 'zh': '格拉斯哥', 'ja': 'グラスゴー', 'el': 'Γλασκώβη', 'th': 'กลาสโกว์', 'hi': 'ग्लासगो', 'ko': '글래스고'},
    ),

    // ----------------------------------------------------
    // United States (US)
    // ----------------------------------------------------
    PopularCity(
      id: 'new_york',
      countryCode: 'US',
      names: {'en': 'New York', 'tr': 'New York', 'de': 'New York', 'fr': 'New York', 'es': 'Nueva York', 'it': 'New York', 'ru': 'Нью-Йорк', 'ar': 'نيويورك', 'zh': '纽约', 'ja': 'ニューヨーク', 'el': 'Νέα Υόρκη', 'th': 'นครนิวยอร์ก', 'hi': 'न्यूयॉर्क', 'ko': '뉴욕'},
    ),
    PopularCity(
      id: 'los_angeles',
      countryCode: 'US',
      names: {'en': 'Los Angeles', 'tr': 'Los Angeles', 'es': 'Los Ángeles', 'de': 'Los Angeles', 'fr': 'Los Angeles', 'it': 'Los Angeles', 'ru': 'Лос-Анджелес', 'zh': '洛杉矶', 'ar': 'لوس أنجلوس', 'ja': 'ロサンゼルス', 'el': 'Λος Άντζελες', 'th': 'ลอสแอนเจลิส', 'hi': 'लॉस एंजेलिस', 'ko': '로스앤젤레스'},
    ),
    PopularCity(
      id: 'san_francisco',
      countryCode: 'US',
      names: {'en': 'San Francisco', 'tr': 'San Francisco', 'es': 'San Francisco', 'de': 'San Francisco', 'fr': 'San Francisco', 'it': 'San Francisco', 'ru': 'Сан-Франциско', 'ar': 'سان فرانسيسكو', 'zh': '旧金山', 'ja': 'サンフランシスコ', 'el': 'Σαν Φρανσίσκο', 'th': 'ซานฟรานซิสโก', 'hi': 'सैन फ्रांसिस्को', 'ko': '샌프란시스코'},
    ),
    PopularCity(
      id: 'miami',
      countryCode: 'US',
      names: {'en': 'Miami', 'tr': 'Miami', 'es': 'Miami', 'de': 'Miami', 'fr': 'Miami', 'it': 'Miami', 'ru': 'Майами', 'ar': 'ميامي', 'zh': '迈阿密', 'ja': 'マイアミ', 'el': 'Μαϊάμι', 'th': 'ไมแอมี', 'hi': 'मियामी', 'ko': '마이애미'},
    ),
    PopularCity(
      id: 'las_vegas',
      countryCode: 'US',
      names: {'en': 'Las Vegas', 'tr': 'Las Vegas', 'es': 'Las Vegas', 'de': 'Las Vegas', 'fr': 'Las Vegas', 'it': 'Las Vegas', 'ru': 'Лас-Вегас', 'ar': 'لاس فيغاس', 'zh': '拉斯维加斯', 'ja': 'ラスベガス', 'el': 'Λας Βέγκας', 'th': 'ลาสเวกัส', 'hi': 'लास वेगास', 'ko': '라스베이거스'},
    ),
    PopularCity(
      id: 'chicago',
      countryCode: 'US',
      names: {'en': 'Chicago', 'tr': 'Chicago', 'es': 'Chicago', 'de': 'Chicago', 'fr': 'Chicago', 'it': 'Chicago', 'ru': 'Чикаго', 'ar': 'شيكاغو', 'zh': '芝加哥', 'ja': 'シカゴ', 'el': 'Σικάγο', 'th': 'ชิคาโก', 'hi': 'शिकागो', 'ko': '시카고'},
    ),
    PopularCity(
      id: 'orlando',
      countryCode: 'US',
      names: {'en': 'Orlando', 'tr': 'Orlando', 'es': 'Orlando', 'de': 'Orlando', 'fr': 'Orlando', 'it': 'Orlando', 'ru': 'Орландо', 'ar': 'أورلاندو', 'zh': '奥兰多', 'ja': 'オーランド', 'el': 'Ορλάντο', 'th': 'ออร์แลนโด', 'hi': 'ऑरलैंडो', 'ko': '올랜도'},
    ),
    PopularCity(
      id: 'washington_dc',
      countryCode: 'US',
      names: {'en': 'Washington D.C.', 'tr': 'Washington D.C.', 'es': 'Washington D.C.', 'de': 'Washington D.C.', 'fr': 'Washington D.C.', 'it': 'Washington D.C.', 'ru': 'Вашингтон', 'ar': 'واشنطن العاصمة', 'zh': '华盛顿', 'ja': 'ワシントンD.C.', 'el': 'Ουάσινγκτον', 'th': 'วอชิงตัน ดี.ซี.', 'hi': 'वॉशिंगटन डी॰ सी॰', 'ko': '워싱턴 D.C.'},
    ),
    PopularCity(
      id: 'boston',
      countryCode: 'US',
      names: {'en': 'Boston', 'tr': 'Boston', 'es': 'Boston', 'de': 'Boston', 'fr': 'Boston', 'it': 'Boston', 'ru': 'Бостон', 'ar': 'بوسطن', 'zh': '波士顿', 'ja': 'ボストン', 'el': 'Βοστώνη', 'th': 'บอสตัน', 'hi': 'बोस्टन', 'ko': '보스턴'},
    ),
    PopularCity(
      id: 'seattle',
      countryCode: 'US',
      names: {'en': 'Seattle', 'tr': 'Seattle', 'es': 'Seattle', 'de': 'Seattle', 'fr': 'Seattle', 'it': 'Seattle', 'ru': 'Сиэтл', 'ar': 'سياتل', 'zh': '西雅图', 'ja': 'シアトル', 'el': 'Σιάτλ', 'th': 'ซีแอตเทิล', 'hi': 'सीऐटल', 'ko': '시애틀'},
    ),
    PopularCity(
      id: 'honolulu',
      countryCode: 'US',
      names: {'en': 'Honolulu', 'tr': 'Honolulu', 'es': 'Honolulu', 'de': 'Honolulu', 'fr': 'Honolulu', 'it': 'Honolulu', 'ru': 'Гонолулу', 'ar': 'هونولولو', 'zh': '火奴鲁鲁', 'ja': 'ホノルル', 'el': 'Χονολουλού', 'th': 'โฮโนลูลู', 'hi': 'होनोलूलू', 'ko': '호놀룰루'},
    ),
    PopularCity(
      id: 'new_orleans',
      countryCode: 'US',
      names: {'en': 'New Orleans', 'tr': 'New Orleans', 'es': 'Nueva Orleans', 'de': 'New Orleans', 'fr': 'La Nouvelle-Orléans', 'it': 'New Orleans', 'ru': 'Новый Орлеан', 'ar': 'نيو أورلينز', 'zh': '新奥尔良', 'ja': 'ニューオーリンズ', 'el': 'Νέα Ορλεάνη', 'th': 'นิวออร์ลีนส์', 'hi': 'न्यू ओर्लियंस', 'ko': '뉴올리언스'},
    ),
    PopularCity(
      id: 'san_diego',
      countryCode: 'US',
      names: {'en': 'San Diego', 'tr': 'San Diego', 'es': 'San Diego', 'de': 'San Diego', 'fr': 'San Diego', 'it': 'San Diego', 'ru': 'Сан-Диего', 'ar': 'سان دييغو', 'zh': '圣迭戈', 'ja': 'サン・ディエゴ', 'el': 'Σαν Ντιέγκο', 'th': 'แซนดีเอโก', 'hi': 'सैन डिएगो', 'ko': '샌디에고'},
    ),

    // ----------------------------------------------------
    // Austria (AT)
    // ----------------------------------------------------
    PopularCity(
      id: 'vienna',
      countryCode: 'AT',
      names: {'en': 'Vienna', 'tr': 'Viyana', 'de': 'Wien', 'fr': 'Vienne', 'es': 'Viena', 'it': 'Vienna', 'ru': 'Вена', 'ar': 'فيينا', 'zh': '维也纳', 'ja': 'ウィーン', 'el': 'Βιέννη', 'th': 'เวียนนา', 'hi': 'वियना', 'ko': '빈'},
    ),
    PopularCity(
      id: 'salzburg',
      countryCode: 'AT',
      names: {'en': 'Salzburg', 'tr': 'Salzburg', 'de': 'Salzburg', 'fr': 'Salzbourg', 'es': 'Salzburgo', 'it': 'Salisburgo', 'ru': 'Зальцбург', 'ar': 'سالزبورغ', 'zh': '萨尔茨堡', 'ja': 'ザルツブルク', 'el': 'Σάλτσμπουργκ', 'th': 'ซัลทซ์บวร์ค', 'hi': 'साल्त्सबर्ग', 'ko': '잘츠부르크'},
    ),
    PopularCity(
      id: 'innsbruck',
      countryCode: 'AT',
      names: {'en': 'Innsbruck', 'tr': 'İnnsbruck', 'de': 'Innsbruck', 'fr': 'Innsbruck', 'es': 'Innsbruck', 'it': 'Innsbruck', 'ru': 'Инсбрук', 'ar': 'إنسبروك', 'zh': '因斯布鲁克', 'ja': 'インスブルック', 'el': 'Ίνσμπρουκ', 'th': 'อินส์บรุค', 'hi': 'इंसब्रुक', 'ko': '인스브루크'},
    ),
    PopularCity(
      id: 'hallstatt',
      countryCode: 'AT',
      names: {'en': 'Hallstatt', 'tr': 'Hallstatt', 'de': 'Hallstatt', 'fr': 'Hallstatt', 'es': 'Hallstatt', 'it': 'Hallstatt', 'ru': 'Гальштат', 'ar': 'هالشتات', 'zh': '哈尔施塔特', 'ja': 'ハルシュタット', 'el': 'Χάλστατ', 'th': 'ฮัลชตัท', 'hi': 'हालश्टाट', 'ko': '할슈타트'},
    ),
    PopularCity(
      id: 'graz',
      countryCode: 'AT',
      names: {'en': 'Graz', 'tr': 'Graz', 'de': 'Graz', 'fr': 'Graz', 'es': 'Graz', 'it': 'Graz', 'ru': 'Грац', 'ar': 'غراتس', 'zh': '格拉茨', 'ja': 'グラーツ', 'el': 'Γκρατς', 'th': 'กราทซ์', 'hi': 'ग्रात्स', 'ko': '그라츠'},
    ),

    // ----------------------------------------------------
    // Netherlands (NL)
    // ----------------------------------------------------
    PopularCity(
      id: 'amsterdam',
      countryCode: 'NL',
      names: {'en': 'Amsterdam', 'tr': 'Amsterdam', 'nl': 'Amsterdam', 'de': 'Amsterdam', 'fr': 'Amsterdam', 'es': 'Ámsterdam', 'it': 'Amsterdam', 'ru': 'Амстердам', 'zh': '阿姆斯特丹', 'ar': 'أمستردام', 'ja': 'アムステルダム', 'el': 'Άμστερνταμ', 'th': 'อัมสเตอร์ดัม', 'hi': 'ऐम्स्टर्डैम', 'ko': '암스테르담'},
    ),
    PopularCity(
      id: 'rotterdam',
      countryCode: 'NL',
      names: {'en': 'Rotterdam', 'tr': 'Rotterdam', 'nl': 'Rotterdam', 'de': 'Rotterdam', 'fr': 'Rotterdam', 'es': 'Róterdam', 'it': 'Rotterdam', 'ru': 'Роттердам', 'ar': 'روتردام', 'zh': '鹿特丹', 'ja': 'ロッテルダム', 'el': 'Ρότερνταμ', 'th': 'รอตเทอร์ดาม', 'hi': 'रॉटरडाम', 'ko': '로테르담'},
    ),
    PopularCity(
      id: 'the_hague',
      countryCode: 'NL',
      names: {'en': 'The Hague', 'tr': 'Lahey', 'nl': 'Den Haag', 'de': 'Den Haag', 'fr': 'La Haye', 'es': 'La Haya', 'it': 'L’Aia', 'ru': 'Гаага', 'ar': 'لاهاي', 'zh': '海牙', 'ja': 'デン・ハーグ', 'el': 'Χάγη', 'th': 'เดอะเฮก', 'hi': 'हेग', 'ko': '헤이그'},
    ),
    PopularCity(
      id: 'utrecht',
      countryCode: 'NL',
      names: {'en': 'Utrecht', 'tr': 'Utrecht', 'nl': 'Utrecht', 'de': 'Utrecht', 'fr': 'Utrecht', 'es': 'Utrecht', 'it': 'Utrecht', 'ru': 'Утрехт', 'ar': 'أترخت', 'zh': '乌得勒支', 'ja': 'ユトレヒト', 'el': 'Ουτρέχτη', 'th': 'ยูเทรกต์', 'hi': 'उट्रेख़्ट', 'ko': '위트레흐트'},
    ),

    // ----------------------------------------------------
    // Czech Republic (CZ)
    // ----------------------------------------------------
    PopularCity(
      id: 'prague',
      countryCode: 'CZ',
      names: {'en': 'Prague', 'tr': 'Prag', 'cs': 'Praha', 'de': 'Prag', 'fr': 'Prague', 'es': 'Praga', 'it': 'Praga', 'ru': 'Прага', 'ar': 'براغ', 'zh': '布拉格', 'ja': 'プラハ', 'el': 'Πράγα', 'th': 'ปราก', 'hi': 'प्राग', 'ko': '프라하'},
    ),
    PopularCity(
      id: 'cesky_krumlov',
      countryCode: 'CZ',
      names: {'en': 'Cesky Krumlov', 'tr': 'Český Krumlov', 'cs': 'Český Krumlov', 'de': 'Krumau', 'fr': 'Český Krumlov', 'es': 'Český Krumlov', 'ru': 'Чески-Крумлов', 'ar': 'تشيسكي كروملوف', 'zh': '捷克克鲁姆洛夫', 'ja': 'チェスキー・クルムロフ', 'el': 'Τσεσκύ Κρούμλοβ', 'th': 'แช็สกีกรุมโลฟ', 'hi': 'चेस्की क्रमलोव', 'ko': '체스키크룸로프'},
    ),
    PopularCity(
      id: 'brno',
      countryCode: 'CZ',
      names: {'en': 'Brno', 'tr': 'Brno', 'cs': 'Brno', 'de': 'Brünn', 'fr': 'Brno', 'es': 'Brno', 'it': 'Brno', 'ru': 'Брно', 'ar': 'برنو', 'zh': '布尔诺', 'ja': 'ブルノ', 'el': 'Μπρνο', 'th': 'เบอร์โน', 'hi': 'ब्र्नो', 'ko': '브르노'},
    ),

    // ----------------------------------------------------
    // Hungary (HU)
    // ----------------------------------------------------
    PopularCity(
      id: 'budapest',
      countryCode: 'HU',
      names: {'en': 'Budapest', 'tr': 'Budapeşte', 'hu': 'Budapest', 'de': 'Budapest', 'fr': 'Budapest', 'es': 'Budapest', 'it': 'Budapest', 'ru': 'Будапешт', 'ar': 'بودابست', 'zh': '布达佩斯', 'ja': 'ブダペスト', 'el': 'Βουδαπέστη', 'th': 'บูดาเปสต์', 'hi': 'बुडापेस्ट', 'ko': '부다페스트'},
    ),

    // ----------------------------------------------------
    // Portugal (PT)
    // ----------------------------------------------------
    PopularCity(
      id: 'lisbon',
      countryCode: 'PT',
      names: {'en': 'Lisbon', 'tr': 'Lizbon', 'pt': 'Lisboa', 'de': 'Lissabon', 'fr': 'Lisbonne', 'es': 'Lisboa', 'it': 'Lisbona', 'ru': 'Лиссабон', 'ar': 'لشبونة', 'zh': '里斯本', 'ja': 'リスボン', 'el': 'Λισαβόνα', 'th': 'ลิสบอน', 'hi': 'लिस्बन', 'ko': '리스본'},
    ),
    PopularCity(
      id: 'porto',
      countryCode: 'PT',
      names: {'en': 'Porto', 'tr': 'Porto', 'pt': 'Porto', 'de': 'Porto', 'fr': 'Porto', 'es': 'Oporto', 'it': 'Porto', 'ru': 'Порту', 'ar': 'بورتو', 'zh': '波尔图', 'ja': 'ポルト', 'el': 'Πόρτο', 'th': 'โปร์ตู', 'hi': 'पोर्टो', 'ko': '포르투'},
    ),
    PopularCity(
      id: 'sintra',
      countryCode: 'PT',
      names: {'en': 'Sintra', 'tr': 'Sintra', 'pt': 'Sintra', 'de': 'Sintra', 'fr': 'Sintra', 'es': 'Sintra', 'it': 'Sintra', 'ru': 'Синтра', 'ar': 'شنترة', 'zh': '辛特拉', 'ja': 'シントラ', 'el': 'Σίντρα', 'th': 'ซิงตรา', 'hi': 'सिंट्रा', 'ko': '신트라'},
    ),
    PopularCity(
      id: 'faro',
      countryCode: 'PT',
      names: {'en': 'Faro', 'tr': 'Faro', 'pt': 'Faro', 'de': 'Faro', 'fr': 'Faro', 'es': 'Faro', 'it': 'Faro', 'ru': 'Фару', 'ar': 'فارو', 'zh': '法鲁', 'ja': 'ファロ', 'el': 'Φάρο', 'th': 'ฟารู', 'hi': 'फेरो', 'ko': '파루'},
    ),
    PopularCity(
      id: 'funchal',
      countryCode: 'PT',
      names: {'en': 'Funchal', 'tr': 'Funchal', 'pt': 'Funchal', 'de': 'Funchal', 'fr': 'Funchal', 'es': 'Funchal', 'it': 'Funchal', 'ru': 'Фуншал', 'ar': 'فُنْشال', 'zh': '丰沙尔', 'ja': 'フンシャル', 'el': 'Φουνσάλ', 'th': 'ฟุงชาล', 'hi': 'फुंचाल', 'ko': '푼샬'},
    ),

    // ----------------------------------------------------
    // Greece (GR)
    // ----------------------------------------------------
    PopularCity(
      id: 'athens',
      countryCode: 'GR',
      names: {'en': 'Athens', 'tr': 'Atina', 'el': 'Αθήνα', 'de': 'Athen', 'fr': 'Athènes', 'es': 'Atenas', 'it': 'Atene', 'ru': 'Афины', 'ar': 'أثينا', 'zh': '雅典', 'ja': 'アテネ', 'th': 'เอเธนส์', 'hi': 'एथेंस', 'ko': '아테네'},
    ),
    PopularCity(
      id: 'santorini',
      countryCode: 'GR',
      names: {'en': 'Santorini', 'tr': 'Santorini', 'el': 'Σαντορίνη', 'de': 'Santorin', 'fr': 'Santorin', 'es': 'Santorini', 'it': 'Santorini', 'ru': 'Санторини', 'ar': 'سنتوريني', 'zh': '圣托里尼', 'ja': 'サントリーニ島', 'th': 'ซันโดรีนี', 'hi': 'सांडोरिनी', 'ko': '산토리니섬'},
    ),
    PopularCity(
      id: 'mykonos',
      countryCode: 'GR',
      names: {'en': 'Mykonos', 'tr': 'Mikonos', 'el': 'Μύκονος', 'de': 'Mykonos', 'fr': 'Mykonos', 'es': 'Miconos', 'it': 'Mykonos', 'ru': 'Миконос', 'ar': 'ميكونوس', 'zh': '米科诺斯岛', 'ja': 'ミコノス島', 'th': 'มีโคนอส', 'hi': 'मायकोनोस', 'ko': '미코노스섬'},
    ),
    PopularCity(
      id: 'thessaloniki',
      countryCode: 'GR',
      names: {'en': 'Thessaloniki', 'tr': 'Selanik', 'el': 'Θεσσαλονίκη', 'de': 'Thessaloniki', 'fr': 'Thessalonique', 'es': 'Tesalónica', 'it': 'Salonicco', 'ru': 'Салоники', 'ar': 'سالونيك', 'zh': '塞萨洛尼基', 'ja': 'テッサロニキ', 'th': 'เทสซาโลนีกี', 'hi': 'थेसालोनिकी', 'ko': '테살로니키'},
    ),
    PopularCity(
      id: 'rhodes',
      countryCode: 'GR',
      names: {'en': 'Rhodes', 'tr': 'Rodos', 'el': 'Ρόδος', 'de': 'Rhodos', 'fr': 'Rhodes', 'es': 'Rodas', 'it': 'Rodi', 'ru': 'Родос', 'ar': 'رودس', 'zh': '罗得岛', 'ja': 'ロドス島', 'th': 'โรดส์', 'hi': 'रोदोस', 'ko': '로도스섬'},
    ),
    PopularCity(
      id: 'heraklion',
      countryCode: 'GR',
      names: {'en': 'Heraklion', 'tr': 'Kandiye (Girit)', 'el': 'Ηράκλειο', 'de': 'Heraklion', 'fr': 'Héraklion', 'es': 'Heraclión', 'it': 'Heraklion', 'ru': 'Ираклион', 'ar': 'كاندية', 'zh': '伊拉克利翁', 'ja': 'イラクリオン', 'th': 'ฮีราคลีออน', 'hi': 'हेराक्लेयोन', 'ko': '이라클리오'},
    ),
    PopularCity(
      id: 'corfu',
      countryCode: 'GR',
      names: {'en': 'Corfu', 'tr': 'Korfu', 'el': 'Κέρκυρα', 'de': 'Korfu', 'fr': 'Corfou', 'es': 'Corfú', 'it': 'Corfù', 'ru': 'Корфу', 'ar': 'قرفس', 'zh': '克基拉岛', 'ja': 'ケルキラ島', 'th': 'เกาะคอร์ฟู', 'hi': 'कोर्फ़ू', 'ko': '케르키라섬'},
    ),
    PopularCity(
      id: 'chania',
      countryCode: 'GR',
      names: {'en': 'Chania', 'tr': 'Hanya', 'el': 'Χανιά', 'de': 'Chania', 'fr': 'La Canée', 'es': 'La Canea', 'it': 'La Canea', 'ru': 'Ханья', 'ar': 'خانية', 'zh': '哈尼亚', 'ja': 'ハニア', 'th': 'ชาเนีย', 'hi': 'खानिया', 'ko': '하니아'},
    ),

    // ----------------------------------------------------
    // Switzerland (CH)
    // ----------------------------------------------------
    PopularCity(
      id: 'zurich',
      countryCode: 'CH',
      names: {'en': 'Zurich', 'tr': 'Zürih', 'de': 'Zürich', 'fr': 'Zurich', 'es': 'Zúrich', 'it': 'Zurigo', 'ru': 'Цюрих', 'ar': 'زيورخ', 'zh': '苏黎世', 'ja': 'チューリッヒ', 'el': 'Ζυρίχη', 'th': 'ซือริช', 'hi': 'ज़्यूरिख़', 'ko': '취리히'},
    ),
    PopularCity(
      id: 'geneva',
      countryCode: 'CH',
      names: {'en': 'Geneva', 'tr': 'Cenevre', 'fr': 'Genève', 'de': 'Genf', 'es': 'Ginebra', 'it': 'Ginevra', 'ru': 'Женева', 'ar': 'جنيف', 'zh': '日内瓦', 'ja': 'ジュネーヴ', 'el': 'Γενεύη', 'th': 'เจนีวา', 'hi': 'जिनेवा', 'ko': '제네바'},
    ),
    PopularCity(
      id: 'lucerne',
      countryCode: 'CH',
      names: {'en': 'Lucerne', 'tr': 'Luzern', 'de': 'Luzern', 'fr': 'Lucerne', 'es': 'Lucerna', 'it': 'Lucerna', 'ru': 'Люцерн', 'ar': 'لوسرن', 'zh': '卢塞恩', 'ja': 'ルツェルン', 'el': 'Λουκέρνη', 'th': 'ลูเซิร์น', 'hi': 'लुसेर्न', 'ko': '루체른'},
    ),
    PopularCity(
      id: 'interlaken',
      countryCode: 'CH',
      names: {'en': 'Interlaken', 'tr': 'İnterlaken', 'de': 'Interlaken', 'fr': 'Interlaken', 'es': 'Interlaken', 'it': 'Interlaken', 'ru': 'Интерлакен', 'ar': 'إنترلاكن', 'zh': '因特拉肯', 'ja': 'インターラーケン', 'el': 'Ίντερλακεν', 'th': 'อินเทอร์ลาเคิน', 'hi': 'इंटरलाकेन', 'ko': '인터라켄'},
    ),
    PopularCity(
      id: 'basel',
      countryCode: 'CH',
      names: {'en': 'Basel', 'tr': 'Basel', 'de': 'Basel', 'fr': 'Bâle', 'es': 'Basilea', 'it': 'Basilea', 'ru': 'Базель', 'ar': 'بازل', 'zh': '巴塞尔', 'ja': 'バーゼル', 'el': 'Βασιλεία', 'th': 'บาเซิล', 'hi': 'बाज़ल', 'ko': '바젤'},
    ),
    PopularCity(
      id: 'bern',
      countryCode: 'CH',
      names: {'en': 'Bern', 'tr': 'Bern', 'de': 'Bern', 'fr': 'Berne', 'es': 'Berna', 'it': 'Berna', 'ru': 'Берн', 'ar': 'برن', 'zh': '伯尔尼', 'ja': 'ベルン', 'el': 'Βέρνη', 'th': 'แบร์น', 'hi': 'बर्न', 'ko': '베른'},
    ),

    // ----------------------------------------------------
    // Belgium (BE)
    // ----------------------------------------------------
    PopularCity(
      id: 'brussels',
      countryCode: 'BE',
      names: {'en': 'Brussels', 'tr': 'Brüksel', 'fr': 'Bruxelles', 'nl': 'Brussel', 'de': 'Brüssel', 'es': 'Bruselas', 'it': 'Bruxelles', 'ru': 'Брюссель', 'ar': 'بروكسل', 'zh': '布鲁塞尔', 'ja': 'ブリュッセル', 'el': 'Βρυξέλλες', 'th': 'บรัสเซลส์', 'hi': 'ब्रसेल्स', 'ko': '브뤼셀'},
    ),
    PopularCity(
      id: 'bruges',
      countryCode: 'BE',
      names: {'en': 'Bruges', 'tr': 'Bruges', 'fr': 'Bruges', 'nl': 'Brugge', 'de': 'Brügge', 'es': 'Brujas', 'it': 'Bruges', 'ru': 'Брюгге', 'ar': 'بروج', 'zh': '布鲁日', 'ja': 'ブルッヘ', 'el': 'Μπρυζ', 'th': 'บรูช', 'hi': 'ब्रुज', 'ko': '브뤼허'},
    ),
    PopularCity(
      id: 'antwerp',
      countryCode: 'BE',
      names: {'en': 'Antwerp', 'tr': 'Anvers', 'nl': 'Antwerpen', 'fr': 'Anvers', 'de': 'Antwerpen', 'es': 'Amberes', 'it': 'Anversa', 'ru': 'Антверпен', 'ar': 'أنتويرب', 'zh': '安特卫普', 'ja': 'アントウェルペン', 'el': 'Αμβέρσα', 'th': 'แอนต์เวิร์ป', 'hi': 'एंटवर्प', 'ko': '안트베르펜'},
    ),
    PopularCity(
      id: 'ghent',
      countryCode: 'BE',
      names: {'en': 'Ghent', 'tr': 'Gent', 'nl': 'Gent', 'fr': 'Gand', 'de': 'Gent', 'es': 'Gante', 'it': 'Gand', 'ru': 'Гент', 'ar': 'خنت', 'zh': '根特', 'ja': 'ヘント', 'el': 'Γάνδη', 'th': 'เกนต์', 'hi': 'गेंट', 'ko': '헨트'},
    ),

    // ----------------------------------------------------
    // Poland (PL)
    // ----------------------------------------------------
    PopularCity(
      id: 'warsaw',
      countryCode: 'PL',
      names: {'en': 'Warsaw', 'tr': 'Varşova', 'pl': 'Warszawa', 'de': 'Warschau', 'fr': 'Varsovie', 'es': 'Varsovia', 'it': 'Varsavia', 'ru': 'Варшава', 'ar': 'وارسو', 'zh': '华沙', 'ja': 'ワルシャワ', 'el': 'Βαρσοβία', 'th': 'วอร์ซอ', 'hi': 'वारसॉ', 'ko': '바르샤바'},
    ),
    PopularCity(
      id: 'krakow',
      countryCode: 'PL',
      names: {'en': 'Krakow', 'tr': 'Krakov', 'pl': 'Kraków', 'de': 'Krakau', 'fr': 'Cracovie', 'es': 'Cracovia', 'it': 'Cracovia', 'ru': 'Краков', 'ar': 'كراكوف', 'zh': '克拉科夫', 'ja': 'クラクフ', 'el': 'Κρακοβία', 'th': 'กรากุฟ', 'hi': 'क्राकुव', 'ko': '크라쿠프'},
    ),
    PopularCity(
      id: 'gdansk',
      countryCode: 'PL',
      names: {'en': 'Gdansk', 'tr': 'Gdansk', 'pl': 'Gdańsk', 'de': 'Danzig', 'fr': 'Gdańsk', 'es': 'Gdansk', 'it': 'Danzica', 'ru': 'Гданьск', 'ar': 'غدانسك', 'zh': '格但斯克', 'ja': 'グダニスク', 'el': 'Γκντανσκ', 'th': 'กดัญสก์', 'hi': 'डांस्क', 'ko': '그단스크'},
    ),
    PopularCity(
      id: 'wroclaw',
      countryCode: 'PL',
      names: {'en': 'Wroclaw', 'tr': 'Wroclaw', 'pl': 'Wrocław', 'de': 'Breslau', 'fr': 'Wrocław', 'es': 'Breslavia', 'it': 'Breslavia', 'ru': 'Вроцлав', 'ar': 'فروتسواف', 'zh': '弗罗茨瓦夫', 'ja': 'ヴロツワフ', 'el': 'Βρότσλαβ', 'th': 'วรอตสวัฟ', 'hi': 'व्रोत्स्वाव', 'ko': '브로츠와프'},
    ),

    // ----------------------------------------------------
    // Croatia (HR)
    // ----------------------------------------------------
    PopularCity(
      id: 'dubrovnik',
      countryCode: 'HR',
      names: {'en': 'Dubrovnik', 'tr': 'Dubrovnik', 'hr': 'Dubrovnik', 'de': 'Dubrovnik', 'fr': 'Dubrovnik', 'es': 'Dubrovnik', 'it': 'Ragusa', 'ru': 'Дубровник', 'ar': 'دوبروفنيك', 'zh': '杜布罗夫尼克', 'ja': 'ドゥブロヴニク', 'el': 'Ντούμπροβνικ', 'th': 'ดูบรอฟนีก', 'hi': 'दुब्रोवनीक', 'ko': '두브로브니크'},
    ),
    PopularCity(
      id: 'split',
      countryCode: 'HR',
      names: {'en': 'Split', 'tr': 'Split', 'hr': 'Split', 'de': 'Split', 'fr': 'Split', 'es': 'Split', 'it': 'Spalato', 'ru': 'Сплит', 'ar': 'أسبالطو', 'zh': '斯普利特', 'ja': 'スプリト', 'el': 'Σπλιτ', 'th': 'สปลิต', 'hi': 'स्प्लित', 'ko': '스플리트'},
    ),
    PopularCity(
      id: 'zagreb',
      countryCode: 'HR',
      names: {'en': 'Zagreb', 'tr': 'Zagreb', 'hr': 'Zagreb', 'de': 'Agram', 'fr': 'Zagreb', 'es': 'Zagreb', 'it': 'Zagabria', 'ru': 'Загреб', 'ar': 'زغرب', 'zh': '萨格勒布', 'ja': 'ザグレブ', 'el': 'Ζάγκρεμπ', 'th': 'ซาเกร็บ', 'hi': 'ज़ाग्रेब', 'ko': '자그레브'},
    ),
    PopularCity(
      id: 'zadar',
      countryCode: 'HR',
      names: {'en': 'Zadar', 'tr': 'Zadar', 'hr': 'Zadar', 'de': 'Zara', 'fr': 'Zadar', 'es': 'Zadar', 'it': 'Zara', 'ru': 'Задар', 'ar': 'زادار', 'zh': '扎达尔', 'ja': 'ザダル', 'el': 'Ζάνταρ', 'th': 'ซาดาร์', 'hi': 'ज़ादार', 'ko': '자다르'},
    ),

    // ----------------------------------------------------
    // Nordic Countries (SE, NO, DK, FI, IS)
    // ----------------------------------------------------
    PopularCity(
      id: 'stockholm',
      countryCode: 'SE',
      names: {'en': 'Stockholm', 'tr': 'Stokholm', 'sv': 'Stockholm', 'de': 'Stockholm', 'fr': 'Stockholm', 'es': 'Estocolmo', 'it': 'Stoccolma', 'ru': 'Стокгольм', 'ar': 'ستوكهولم', 'zh': '斯德哥尔摩', 'ja': 'ストックホルム', 'el': 'Στοκχόλμη', 'th': 'สต็อกโฮล์ม', 'hi': 'स्टॉकहोम', 'ko': '스톡홀름'},
    ),
    PopularCity(
      id: 'gothenburg',
      countryCode: 'SE',
      names: {'en': 'Gothenburg', 'tr': 'Göteborg', 'sv': 'Göteborg', 'de': 'Göteborg', 'fr': 'Göteborg', 'es': 'Gotemburgo', 'it': 'Göteborg', 'ru': 'Гётеборг', 'ar': 'غوتنبرغ', 'zh': '哥德堡', 'ja': 'ヨーテボリ', 'el': 'Γκέτεμποργκ', 'th': 'กอเทนเบิร์ก', 'hi': 'गोथनबर्ग', 'ko': '예테보리'},
    ),
    PopularCity(
      id: 'copenhagen',
      countryCode: 'DK',
      names: {'en': 'Copenhagen', 'tr': 'Kopenhag', 'da': 'København', 'de': 'Kopenhagen', 'fr': 'Copenhague', 'es': 'Copenhague', 'it': 'Copenaghen', 'ru': 'Копенгаген', 'ar': 'كوبنهاغن', 'zh': '哥本哈根', 'ja': 'コペンハーゲン', 'el': 'Κοπεγχάγη', 'th': 'โคเปนเฮเกน', 'hi': 'कोपनहेगन', 'ko': '코펜하겐'},
    ),
    PopularCity(
      id: 'oslo',
      countryCode: 'NO',
      names: {'en': 'Oslo', 'tr': 'Oslo', 'no': 'Oslo', 'de': 'Oslo', 'fr': 'Oslo', 'es': 'Oslo', 'it': 'Oslo', 'ru': 'Осло', 'ar': 'أوسلو', 'zh': '奥斯陆', 'ja': 'オスロ', 'el': 'Όσλο', 'th': 'ออสโล', 'hi': 'ओस्लो', 'ko': '오슬로'},
    ),
    PopularCity(
      id: 'bergen',
      countryCode: 'NO',
      names: {'en': 'Bergen', 'tr': 'Bergen', 'no': 'Bergen', 'de': 'Bergen', 'fr': 'Bergen', 'es': 'Bergen', 'it': 'Bergen', 'ru': 'Берген', 'ar': 'برغن', 'zh': '卑尔根', 'ja': 'ベルゲン', 'el': 'Μπέργκεν', 'th': 'บาร์เกิน', 'hi': 'बेर्गेन', 'ko': '베르겐'},
    ),
    PopularCity(
      id: 'tromso',
      countryCode: 'NO',
      names: {'en': 'Tromso', 'tr': 'Tromsø', 'no': 'Tromsø', 'de': 'Tromsø', 'fr': 'Tromsø', 'es': 'Tromsø', 'it': 'Tromsø', 'ru': 'Тромсё', 'ar': 'ترومسو', 'zh': '特罗姆瑟', 'ja': 'トロムソ', 'el': 'Τρούμσε', 'th': 'ทรอมโซ', 'hi': 'ट्रोम्सो', 'ko': '트롬쇠'},
    ),
    PopularCity(
      id: 'helsinki',
      countryCode: 'FI',
      names: {'en': 'Helsinki', 'tr': 'Helsinki', 'fi': 'Helsinki', 'de': 'Helsinki', 'fr': 'Helsinki', 'es': 'Helsinki', 'it': 'Helsinki', 'ru': 'Хельсинки', 'ar': 'هلسنكي', 'zh': '赫尔辛基', 'ja': 'ヘルシンキ', 'el': 'Ελσίνκι', 'th': 'เฮลซิงกิ', 'hi': 'हेलसिंकी', 'ko': '헬싱키'},
    ),
    PopularCity(
      id: 'reykjavik',
      countryCode: 'IS',
      names: {'en': 'Reykjavik', 'tr': 'Reykjavik', 'is': 'Reykjavík', 'de': 'Reykjavík', 'fr': 'Reykjavik', 'es': 'Reikiavik', 'it': 'Reykjavík', 'ru': 'Рейкьявик', 'ar': 'ريكيافيك', 'zh': '雷克雅未克', 'ja': 'レイキャヴィーク', 'el': 'Ρέικιαβικ', 'th': 'เรคยาวิก', 'hi': 'रेक्जाविक', 'ko': '레이캬비크'},
    ),

    // ----------------------------------------------------
    // Japan (JP)
    // ----------------------------------------------------
    PopularCity(
      id: 'tokyo',
      countryCode: 'JP',
      names: {'en': 'Tokyo', 'tr': 'Tokyo', 'ja': '東京', 'de': 'Tokio', 'fr': 'Tokyo', 'es': 'Tokio', 'it': 'Tokyo', 'ru': 'Токио', 'ar': 'طوكيو', 'zh': '东京', 'el': 'Τόκιο', 'th': 'โตเกียว', 'hi': 'टोक्यो', 'ko': '도쿄'},
    ),
    PopularCity(
      id: 'kyoto',
      countryCode: 'JP',
      names: {'en': 'Kyoto', 'tr': 'Kyoto', 'ja': '京都', 'de': 'Kyōto', 'fr': 'Kyoto', 'es': 'Kioto', 'it': 'Kyoto', 'ru': 'Киото', 'ar': 'كيوتو', 'zh': '京都', 'el': 'Κιότο', 'th': 'เกียวโต', 'hi': 'क्योतो', 'ko': '교토'},
    ),
    PopularCity(
      id: 'osaka',
      countryCode: 'JP',
      names: {'en': 'Osaka', 'tr': 'Osaka', 'ja': '大阪', 'de': 'Osaka', 'fr': 'Osaka', 'es': 'Osaka', 'it': 'Osaka', 'ru': 'Осака', 'zh': '大阪', 'ar': 'أوساكا', 'el': 'Οσάκα', 'th': 'โอซากะ', 'hi': 'ओसाका', 'ko': '오사카'},
    ),
    PopularCity(
      id: 'hiroshima',
      countryCode: 'JP',
      names: {'en': 'Hiroshima', 'tr': 'Hiroşima', 'ja': '広島', 'de': 'Hiroshima', 'fr': 'Hiroshima', 'es': 'Hiroshima', 'it': 'Hiroshima', 'ru': 'Хиросима', 'ar': 'هيروشيما', 'zh': '广岛', 'el': 'Χιροσίμα', 'th': 'ฮิโรชิมะ', 'hi': 'हिरोशिमा', 'ko': '히로시마'},
    ),
    PopularCity(
      id: 'sapporo',
      countryCode: 'JP',
      names: {'en': 'Sapporo', 'tr': 'Sapporo', 'ja': '札幌', 'de': 'Sapporo', 'fr': 'Sapporo', 'es': 'Sapporo', 'it': 'Sapporo', 'ru': 'Саппоро', 'ar': 'سابورو', 'zh': '札幌', 'el': 'Σαππόρο', 'th': 'ซัปโปโระ', 'hi': 'साप्पोरो', 'ko': '삿포로'},
    ),
    PopularCity(
      id: 'nara',
      countryCode: 'JP',
      names: {'en': 'Nara', 'tr': 'Nara', 'ja': '奈良', 'de': 'Nara', 'fr': 'Nara', 'es': 'Nara', 'it': 'Nara', 'ru': 'Нара', 'ar': 'نارا', 'zh': '奈良', 'el': 'Νάρα', 'th': 'นาระ', 'hi': 'नारा', 'ko': '나라'},
    ),

    // ----------------------------------------------------
    // UAE & Gulf (AE, QA, SA)
    // ----------------------------------------------------
    PopularCity(
      id: 'dubai',
      countryCode: 'AE',
      names: {'en': 'Dubai', 'tr': 'Dubai', 'ar': 'دبي', 'de': 'Dubai', 'fr': 'Dubaï', 'es': 'Dubái', 'it': 'Dubai', 'ru': 'Дубай', 'zh': '迪拜', 'ja': 'ドバイ', 'el': 'Ντουμπάι', 'th': 'ดูไบ', 'hi': 'दुबई', 'ko': '두바이'},
    ),
    PopularCity(
      id: 'abu_dhabi',
      countryCode: 'AE',
      names: {'en': 'Abu Dhabi', 'tr': 'Abu Dabi', 'ar': 'أبو ظبي', 'de': 'Abu Dhabi', 'fr': 'Abou Dabi', 'es': 'Abu Dabi', 'it': 'Abu Dhabi', 'ru': 'Абу-Даби', 'zh': '阿布扎比', 'ja': 'アブダビ', 'el': 'Άμπου Ντάμπι', 'th': 'อาบูดาบี', 'hi': 'अबू धाबी', 'ko': '아부다비'},
    ),
    PopularCity(
      id: 'doha',
      countryCode: 'QA',
      names: {'en': 'Doha', 'tr': 'Doha', 'ar': 'الدوحة', 'de': 'Doha', 'fr': 'Doha', 'es': 'Doha', 'it': 'Doha', 'ru': 'Доха', 'zh': '多哈', 'ja': 'ドーハ', 'el': 'Ντόχα', 'th': 'โดฮา', 'hi': 'दोहा', 'ko': '도하'},
    ),
    PopularCity(
      id: 'riyadh',
      countryCode: 'SA',
      names: {'en': 'Riyadh', 'tr': 'Riyad', 'ar': 'الرياض', 'de': 'Riad', 'fr': 'Riyad', 'es': 'Riad', 'it': 'Riad', 'ru': 'Эр-Рияд', 'zh': '利雅得', 'ja': 'リヤド', 'el': 'Ριάντ', 'th': 'รียาด', 'hi': 'रियाद', 'ko': '리야드'},
    ),
    PopularCity(
      id: 'jeddah',
      countryCode: 'SA',
      names: {'en': 'Jeddah', 'tr': 'Cidde', 'ar': 'جدة', 'de': 'Dschidda', 'fr': 'Djeddah', 'es': 'Yeda', 'it': 'Gedda', 'ru': 'Джидда', 'zh': '吉达', 'ja': 'ジッダ', 'el': 'Τζέντα', 'th': 'ญิดดะฮ์', 'hi': 'जेद्दाह', 'ko': '지다'},
    ),
    PopularCity(
      id: 'mecca',
      countryCode: 'SA',
      names: {'en': 'Mecca', 'tr': 'Mekke', 'ar': 'مكة المكرمة', 'de': 'Mekka', 'fr': 'La Mecque', 'es': 'La Meca', 'it': 'La Mecca', 'ru': 'Мекка', 'zh': '麦加', 'ja': 'メッカ', 'el': 'Μέκκα', 'th': 'มักกะฮ์', 'hi': 'मक्का', 'ko': '메카'},
    ),
    PopularCity(
      id: 'medina',
      countryCode: 'SA',
      names: {'en': 'Medina', 'tr': 'Medine', 'ar': 'المدينة المنورة', 'de': 'Medina', 'fr': 'Médine', 'es': 'Medina', 'it': 'Medina', 'ru': 'Медина', 'zh': '麦地那', 'ja': 'マディーナ', 'el': 'Μεδίνα', 'th': 'อัลมะดีนะฮ์', 'hi': 'मदीना', 'ko': '메디나'},
    ),

    // ----------------------------------------------------
    // Thailand (TH)
    // ----------------------------------------------------
    PopularCity(
      id: 'bangkok',
      countryCode: 'TH',
      names: {'en': 'Bangkok', 'tr': 'Bangkok', 'th': 'กรุงเทพมหานคร', 'de': 'Bangkok', 'fr': 'Bangkok', 'es': 'Bangkok', 'it': 'Bangkok', 'ru': 'Бангкок', 'zh': '曼谷', 'ar': 'بانكوك', 'ja': 'バンコク', 'el': 'Μπανγκόκ', 'hi': 'बैंकॉक', 'ko': '방콕'},
    ),
    PopularCity(
      id: 'phuket',
      countryCode: 'TH',
      names: {'en': 'Phuket', 'tr': 'Phuket', 'th': 'ภูเก็ต', 'de': 'Phuket', 'fr': 'Phuket', 'es': 'Phuket', 'it': 'Phuket', 'ru': 'Пхукет', 'ar': 'بوكيت', 'zh': '普吉', 'ja': 'テーサバーンナコーン・プーケット', 'el': 'Πουκέτ', 'hi': 'फुकेत', 'ko': '푸껫'},
    ),
    PopularCity(
      id: 'chiang_mai',
      countryCode: 'TH',
      names: {'en': 'Chiang Mai', 'tr': 'Chiang Mai', 'th': 'เชียงใหม่', 'de': 'Chiang Mai', 'fr': 'Chiang Mai', 'es': 'Chiang Mai', 'it': 'Chiang Mai', 'ru': 'Чиангмай', 'ar': 'تشيانغ مي', 'zh': '清迈', 'ja': 'テーサバーンナコーン・チエンマイ', 'el': 'Τσανγκ Μάι', 'hi': 'चिआंग माई', 'ko': '치앙마이'},
    ),
    PopularCity(
      id: 'pattaya',
      countryCode: 'TH',
      names: {'en': 'Pattaya', 'tr': 'Pattaya', 'th': 'พัทยา', 'de': 'Pattaya', 'fr': 'Pattaya', 'es': 'Pattaya', 'it': 'Pattaya', 'ru': 'Паттайя', 'ar': 'باتايا', 'zh': '芭堤雅', 'ja': 'パッタヤー', 'el': 'Πατάγια', 'hi': 'पटाया', 'ko': '파타야'},
    ),
    PopularCity(
      id: 'koh_samui',
      countryCode: 'TH',
      names: {'en': 'Koh Samui', 'tr': 'Koh Samui', 'th': 'เกาะสมุย', 'de': 'Ko Samui', 'fr': 'Koh Samui', 'es': 'Koh Samui', 'ru': 'Самуи', 'ar': 'جزيرة ساموي', 'zh': '沙湄岛', 'ja': 'サムイ島', 'el': 'Κο Σαμούι', 'hi': 'को समुई', 'ko': '사무이섬'},
    ),
    PopularCity(
      id: 'krabi',
      countryCode: 'TH',
      names: {'en': 'Krabi', 'tr': 'Krabi', 'th': 'กระบี่', 'de': 'Krabi', 'fr': 'Krabi', 'es': 'Krabi', 'it': 'Krabi', 'ru': 'Краби', 'ar': 'كرابي', 'zh': '甲米', 'ja': 'クラビー', 'el': 'Κράμπι', 'hi': 'क्राबी', 'ko': '끄라비'},
    ),

    // ----------------------------------------------------
    // Indonesia & Malaysia & Singapore (ID, MY, SG)
    // ----------------------------------------------------
    PopularCity(
      id: 'bali',
      countryCode: 'ID',
      names: {'en': 'Bali', 'tr': 'Bali', 'id': 'Bali', 'de': 'Bali', 'fr': 'Bali', 'es': 'Bali', 'it': 'Bali', 'ru': 'Бали', 'zh': '巴厘岛', 'ar': 'بالي', 'ja': 'バリ州', 'el': 'Μπαλί', 'th': 'บาหลี', 'hi': 'बाली', 'ko': '발리'},
    ),
    PopularCity(
      id: 'jakarta',
      countryCode: 'ID',
      names: {'en': 'Jakarta', 'tr': 'Cakarta', 'id': 'Jakarta', 'de': 'Jakarta', 'fr': 'Jakarta', 'es': 'Yakarta', 'it': 'Giacarta', 'ru': 'Джакарта', 'ar': 'جاكرتا', 'zh': '雅加达', 'ja': 'ジャカルタ', 'el': 'Τζακάρτα', 'th': 'จาการ์ตา', 'hi': 'जकार्ता', 'ko': '자카르타'},
    ),
    PopularCity(
      id: 'yogyakarta',
      countryCode: 'ID',
      names: {'en': 'Yogyakarta', 'tr': 'Yogyakarta', 'id': 'Yogyakarta', 'de': 'Yogyakarta', 'fr': 'Yogyakarta', 'es': 'Yogyakarta', 'ru': 'Джокьякарта', 'ar': 'يوغياكارتا', 'zh': '日惹', 'ja': 'ジョグジャカルタ', 'el': 'Γιογκιακάρτα', 'th': 'ยกยาการ์ตา', 'hi': 'योग्यकार्ता', 'ko': '욕야카르타'},
    ),
    PopularCity(
      id: 'singapore',
      countryCode: 'SG',
      names: {'en': 'Singapore', 'tr': 'Singapur', 'ms': 'Singapura', 'de': 'Singapur', 'fr': 'Singapour', 'es': 'Singapur', 'it': 'Singapore', 'ru': 'Сингапур', 'zh': '新加坡', 'ar': 'سنغافورة', 'ja': 'シンガポール', 'el': 'Σιγκαπούρη', 'th': 'ประเทศสิงคโปร์', 'hi': 'सिंगापुर', 'ko': '싱가포르'},
    ),
    PopularCity(
      id: 'kuala_lumpur',
      countryCode: 'MY',
      names: {'en': 'Kuala Lumpur', 'tr': 'Kuala Lumpur', 'ms': 'Kuala Lumpur', 'de': 'Kuala Lumpur', 'fr': 'Kuala Lumpur', 'es': 'Kuala Lumpur', 'it': 'Kuala Lumpur', 'ru': 'Куала-Лумпур', 'zh': '吉隆坡', 'ar': 'كوالالمبور', 'ja': 'クアラルンプール', 'el': 'Κουάλα Λουμπούρ', 'th': 'กัวลาลัมเปอร์', 'hi': 'कुआलालम्पुर', 'ko': '쿠알라룸푸르'},
    ),
    PopularCity(
      id: 'penang',
      countryCode: 'MY',
      names: {'en': 'Penang', 'tr': 'Penang', 'ms': 'Pulau Pinang', 'de': 'Penang', 'fr': 'Penang', 'es': 'Penang', 'it': 'Penang', 'ru': 'Пенанг', 'ar': 'بينانق', 'zh': '槟城', 'ja': 'ペナン州', 'el': 'Πενάνγκ', 'th': 'รัฐปีนัง', 'hi': 'पिनांग', 'ko': '페낭'},
    ),
    PopularCity(
      id: 'langkawi',
      countryCode: 'MY',
      names: {'en': 'Langkawi', 'tr': 'Langkawi', 'ms': 'Langkawi', 'de': 'Langkawi', 'fr': 'Langkawi', 'es': 'Langkawi', 'ru': 'Лангкави', 'ar': 'لانكاوي', 'zh': '兰卡威', 'ja': 'ランカウイ島', 'el': 'Λανγκάουι', 'th': 'เกาะลังกาวี', 'hi': 'लांगकवी', 'ko': '랑카위'},
    ),

    // ----------------------------------------------------
    // South Korea & Greater China (KR, CN, HK, TW, MO)
    // ----------------------------------------------------
    PopularCity(
      id: 'seoul',
      countryCode: 'KR',
      names: {'en': 'Seoul', 'tr': 'Seul', 'ko': '서울', 'de': 'Seoul', 'fr': 'Séoul', 'es': 'Seúl', 'it': 'Seul', 'ru': 'Сеул', 'zh': '首尔', 'ja': 'ソウル', 'ar': 'سول', 'el': 'Σεούλ', 'th': 'โซล', 'hi': 'सियोल'},
    ),
    PopularCity(
      id: 'busan',
      countryCode: 'KR',
      names: {'en': 'Busan', 'tr': 'Busan', 'ko': '부산', 'de': 'Busan', 'fr': 'Pusan', 'es': 'Busan', 'it': 'Pusan', 'ru': 'Пусан', 'zh': '釜山', 'ar': 'بوسان', 'ja': '釜山広域', 'el': 'Μπουσάν', 'th': 'ปูซาน', 'hi': 'बुसान'},
    ),
    PopularCity(
      id: 'jeju',
      countryCode: 'KR',
      names: {'en': 'Jeju', 'tr': 'Jeju', 'ko': '제주', 'de': 'Jeju', 'fr': 'Jeju', 'es': 'Jeju', 'it': 'Jeju', 'ru': 'Чеджу', 'zh': '济州', 'ar': 'جزيرة جيجو', 'ja': '済州島', 'el': 'Νησί Τζέτζου', 'th': 'เกาะเชจู', 'hi': 'जेजू द्वीप'},
    ),
    PopularCity(
      id: 'beijing',
      countryCode: 'CN',
      names: {'en': 'Beijing', 'tr': 'Pekin', 'zh': '北京', 'de': 'Peking', 'fr': 'Pékin', 'es': 'Pekín', 'it': 'Pechino', 'ru': 'Пекин', 'ja': '北京', 'ar': 'بكين', 'el': 'Πεκίνο', 'th': 'ปักกิ่ง', 'hi': 'बीजिंग', 'ko': '베이징'},
    ),
    PopularCity(
      id: 'shanghai',
      countryCode: 'CN',
      names: {'en': 'Shanghai', 'tr': 'Şanghay', 'zh': '上海', 'de': 'Schanghai', 'fr': 'Shanghai', 'es': 'Shanghái', 'it': 'Shanghai', 'ru': 'Шанхай', 'ja': '上海', 'ar': 'شانغهاي', 'el': 'Σαγκάη', 'th': 'เซี่ยงไฮ้', 'hi': 'शंघाई', 'ko': '상하이'},
    ),
    PopularCity(
      id: 'hong_kong',
      countryCode: 'HK',
      names: {'en': 'Hong Kong', 'tr': 'Hong Kong', 'zh': '香港', 'de': 'Hongkong', 'fr': 'Hong Kong', 'es': 'Hong Kong', 'it': 'Hong Kong', 'ru': 'Гонконг', 'ar': 'هونغ كونغ', 'ja': '香港', 'el': 'Χονγκ Κονγκ', 'th': 'ฮ่องกง', 'hi': 'हांगकांग', 'ko': '홍콩'},
    ),
    PopularCity(
      id: 'taipei',
      countryCode: 'TW',
      names: {'en': 'Taipei', 'tr': 'Taipei', 'zh': '台北', 'de': 'Taipeh', 'fr': 'Taipei', 'es': 'Taipéi', 'it': 'Taipei', 'ru': 'Тайбэй', 'ar': 'تايبيه', 'ja': '台北', 'el': 'Ταϊπέι', 'th': 'ไทเป', 'hi': 'ताइपे', 'ko': '타이베이'},
    ),
    PopularCity(
      id: 'macau',
      countryCode: 'MO',
      names: {'en': 'Macau', 'tr': 'Makao', 'zh': '澳门', 'pt': 'Macau', 'de': 'Macau', 'fr': 'Macao', 'es': 'Macao', 'it': 'Macao', 'ru': 'Макао', 'ar': 'ماكاو', 'ja': 'マカオ', 'el': 'Μακάου', 'th': 'มาเก๊า', 'hi': 'मकाउ', 'ko': '마카오'},
    ),

    // ----------------------------------------------------
    // Egypt & North Africa (EG, MA, TN)
    // ----------------------------------------------------
    PopularCity(
      id: 'cairo',
      countryCode: 'EG',
      names: {'en': 'Cairo', 'tr': 'Kahire', 'ar': 'القاهرة', 'de': 'Kairo', 'fr': 'Le Caire', 'es': 'El Cairo', 'it': 'Il Cairo', 'ru': 'Каир', 'zh': '开罗', 'ja': 'カイロ', 'el': 'Κάιρο', 'th': 'ไคโร', 'hi': 'क़ाहिरा', 'ko': '카이로'},
    ),
    PopularCity(
      id: 'alexandria',
      countryCode: 'EG',
      names: {'en': 'Alexandria', 'tr': 'İskenderiye', 'ar': 'الإسكندرية', 'de': 'Alexandria', 'fr': 'Alexandrie', 'es': 'Alejandría', 'it': 'Alessandria', 'ru': 'Александрия', 'zh': '亚历山大', 'ja': 'アレクサンドリア', 'el': 'Αλεξάνδρεια', 'th': 'อะเล็กซานเดรีย', 'hi': 'सिकन्दरिया', 'ko': '알렉산드리아'},
    ),
    PopularCity(
      id: 'sharm_el_sheikh',
      countryCode: 'EG',
      names: {'en': 'Sharm El Sheikh', 'tr': 'Şarm El-Şeyh', 'ar': 'شرم الشيخ', 'de': 'Scharm El-Scheich', 'fr': 'Charm el-Cheikh', 'es': 'Sharm el-Sheij', 'it': 'Sharm el-Sheikh', 'ru': 'Шарм-эль-Шейх', 'zh': '沙姆沙伊赫', 'ja': 'シャルム・エル・シェイク', 'el': 'Σαρμ ελ-Σείχ', 'th': 'ชาร์ม เอล-ชีค', 'hi': 'शर्म अल शेख', 'ko': '샤름엘셰이크'},
    ),
    PopularCity(
      id: 'hurghada',
      countryCode: 'EG',
      names: {'en': 'Hurghada', 'tr': 'Hurgada', 'ar': 'الغردقة', 'de': 'Hurghada', 'fr': 'Hurghada', 'es': 'Hurgada', 'it': 'Hurghada', 'ru': 'Хургада', 'zh': '赫尔格达', 'ja': 'フルガダ', 'el': 'Χουργκάντα', 'th': 'อัลฆ็อรดะเกาะฮ์', 'hi': 'हूरगाडा', 'ko': '후르가다'},
    ),
    PopularCity(
      id: 'luxor',
      countryCode: 'EG',
      names: {'en': 'Luxor', 'tr': 'Luksor', 'ar': 'الأقصر', 'de': 'Luxor', 'fr': 'Louxor', 'es': 'Lúxor', 'it': 'Luxor', 'ru': 'Луксор', 'zh': '卢克索', 'ja': 'ルクソール', 'el': 'Λούξορ', 'th': 'ลักซอร์', 'hi': 'लक्सर', 'ko': '룩소르'},
    ),
    PopularCity(
      id: 'aswan',
      countryCode: 'EG',
      names: {'en': 'Aswan', 'tr': 'Asvan', 'ar': 'أسوان', 'de': 'Assuan', 'fr': 'Assouan', 'es': 'Asuán', 'it': 'Assuan', 'ru': 'Асуан', 'zh': '阿斯旺', 'ja': 'アスワン', 'el': 'Ασσουάν', 'th': 'อัสวาน', 'hi': 'अस्वान', 'ko': '아스완'},
    ),
    PopularCity(
      id: 'marrakech',
      countryCode: 'MA',
      names: {'en': 'Marrakech', 'tr': 'Marakeş', 'ar': 'مراكش', 'fr': 'Marrakech', 'de': 'Marrakesch', 'es': 'Marrakech', 'it': 'Marrakech', 'ru': 'Марракеш', 'zh': '马拉喀什', 'ja': 'マラケシュ', 'el': 'Μαρακές', 'th': 'มาร์ราคิช', 'hi': 'मर्राकेश', 'ko': '마라케'},
    ),
    PopularCity(
      id: 'casablanca',
      countryCode: 'MA',
      names: {'en': 'Casablanca', 'tr': 'Kazablanka', 'ar': 'الدار البيضاء', 'fr': 'Casablanca', 'de': 'Casablanca', 'es': 'Casablanca', 'it': 'Casablanca', 'ru': 'Касабланка', 'zh': '卡萨布兰卡', 'ja': 'カサブランカ', 'el': 'Καζαμπλάνκα', 'th': 'กาซาบล็องกา', 'hi': 'कासाब्लांका', 'ko': '카사블랑카'},
    ),
    PopularCity(
      id: 'fes',
      countryCode: 'MA',
      names: {'en': 'Fes', 'tr': 'Fes', 'ar': 'فاس', 'fr': 'Fès', 'de': 'Fès', 'es': 'Fez', 'it': 'Fès', 'ru': 'Фес', 'zh': '非斯', 'ja': 'フェズ', 'el': 'Φεζ', 'th': 'แฟ็ส', 'hi': 'फ़ास', 'ko': '페스'},
    ),
    PopularCity(
      id: 'chefchaouen',
      countryCode: 'MA',
      names: {'en': 'Chefchaouen', 'tr': 'Şafşavan', 'ar': 'شفشاون', 'fr': 'Chefchaouen', 'de': 'Chefchaouen', 'es': 'Chauen', 'ru': 'Шефшауэн', 'zh': '舍夫沙万', 'ja': 'シャウエン', 'el': 'Σεφσαουέν', 'th': 'ชัฟชาวัน', 'hi': 'शेफ़शावेन', 'ko': '쉐프샤우엔'},
    ),
    PopularCity(
      id: 'rabat',
      countryCode: 'MA',
      names: {'en': 'Rabat', 'tr': 'Rabat', 'ar': 'الرباط', 'fr': 'Rabat', 'de': 'Rabat', 'es': 'Rabat', 'it': 'Rabat', 'ru': 'Рабат', 'zh': '拉巴特', 'ja': 'ラバト', 'el': 'Ραμπάτ', 'th': 'ราบัต', 'hi': 'रबात', 'ko': '라바트'},
    ),
    PopularCity(
      id: 'tangier',
      countryCode: 'MA',
      names: {'en': 'Tangier', 'tr': 'Tanca', 'ar': 'طنجة', 'fr': 'Tanger', 'de': 'Tanger', 'es': 'Tánger', 'it': 'Tangeri', 'ru': 'Танжер', 'zh': '丹吉尔', 'ja': 'タンジェ', 'el': 'Ταγγέρη', 'th': 'แทนเกียร์', 'hi': 'टैंजियर', 'ko': '탕헤르'},
    ),
    PopularCity(
      id: 'tunis',
      countryCode: 'TN',
      names: {'en': 'Tunis', 'tr': 'Tunus', 'ar': 'تونس', 'fr': 'Tunis', 'de': 'Tunis', 'es': 'Túnez', 'it': 'Tunisi', 'ru': 'Тунис', 'zh': '突尼斯', 'ja': 'チュニス', 'el': 'Τύνιδα', 'th': 'ตูนิส', 'hi': 'ट्यूनिस', 'ko': '튀니스'},
    ),
    PopularCity(
      id: 'sousse',
      countryCode: 'TN',
      names: {'en': 'Sousse', 'tr': 'Suse', 'ar': 'سوسة', 'fr': 'Sousse', 'de': 'Sousse', 'es': 'Susa', 'it': 'Susa', 'ru': 'Сус', 'zh': '苏塞', 'ja': 'スース', 'el': 'Σους', 'th': 'ซูซะฮ์', 'hi': 'सूस', 'ko': '수스'},
    ),

    // ----------------------------------------------------
    // Australia & New Zealand (AU, NZ)
    // ----------------------------------------------------
    PopularCity(
      id: 'sydney',
      countryCode: 'AU',
      names: {'en': 'Sydney', 'tr': 'Sidney', 'de': 'Sydney', 'fr': 'Sydney', 'es': 'Sídney', 'it': 'Sydney', 'ru': 'Сидней', 'zh': '悉尼', 'ar': 'سيدني', 'ja': 'シドニー', 'el': 'Σίδνεϊ', 'th': 'ซิดนีย์', 'hi': 'सिडनी', 'ko': '시드니'},
    ),
    PopularCity(
      id: 'melbourne',
      countryCode: 'AU',
      names: {'en': 'Melbourne', 'tr': 'Melbourne', 'de': 'Melbourne', 'fr': 'Melbourne', 'es': 'Melbourne', 'it': 'Melbourne', 'ru': 'Мельбурн', 'zh': '墨尔本', 'ar': 'ملبورن', 'ja': 'メルボルン', 'el': 'Μελβούρνη', 'th': 'เมลเบิร์น', 'hi': 'मेलबॉर्न', 'ko': '멜버른'},
    ),
    PopularCity(
      id: 'brisbane',
      countryCode: 'AU',
      names: {'en': 'Brisbane', 'tr': 'Brisbane', 'de': 'Brisbane', 'fr': 'Brisbane', 'es': 'Brisbane', 'it': 'Brisbane', 'ru': 'Брисбен', 'ar': 'بريزبان', 'zh': '布里斯班', 'ja': 'ブリスベン', 'el': 'Μπρίσμπεϊν', 'th': 'บริสเบน', 'hi': 'ब्रिस्बेन', 'ko': '브리즈번'},
    ),
    PopularCity(
      id: 'perth',
      countryCode: 'AU',
      names: {'en': 'Perth', 'tr': 'Perth', 'de': 'Perth', 'fr': 'Perth', 'es': 'Perth', 'it': 'Perth', 'ru': 'Перт', 'ar': 'برث', 'zh': '珀斯', 'ja': 'パース', 'el': 'Περθ', 'th': 'เพิร์ท', 'hi': 'पर्थ', 'ko': '퍼스'},
    ),
    PopularCity(
      id: 'gold_coast',
      countryCode: 'AU',
      names: {'en': 'Gold Coast', 'tr': 'Gold Coast', 'de': 'Gold Coast', 'fr': 'Gold Coast', 'es': 'Gold Coast', 'it': 'Gold Coast', 'ru': 'Голд-Кост', 'ar': 'غولد كوست', 'zh': '黄金海岸', 'ja': 'ゴールドコースト', 'el': 'Γκολντ Κόουστ', 'th': 'โกลด์โคสต์', 'hi': 'गोल्ड कोस्ट', 'ko': '골드코스트'},
    ),
    PopularCity(
      id: 'cairns',
      countryCode: 'AU',
      names: {'en': 'Cairns', 'tr': 'Cairns', 'de': 'Cairns', 'fr': 'Cairns', 'es': 'Cairns', 'it': 'Cairns', 'ru': 'Кэрнс', 'ar': 'كيرنز', 'zh': '凯恩斯', 'ja': 'ケアンズ', 'el': 'Καιρνς', 'th': 'แคนส์', 'hi': 'केर्न्स', 'ko': '케언스'},
    ),
    PopularCity(
      id: 'auckland',
      countryCode: 'NZ',
      names: {'en': 'Auckland', 'tr': 'Auckland', 'de': 'Auckland', 'fr': 'Auckland', 'es': 'Auckland', 'it': 'Auckland', 'ru': 'Окленд', 'ar': 'أوكلاند', 'zh': '奥克兰', 'ja': 'オークランド', 'el': 'Όκλαντ', 'th': 'ออกแลนด์', 'hi': 'ऑक्लैण्ड', 'ko': '오클랜드'},
    ),
    PopularCity(
      id: 'queenstown',
      countryCode: 'NZ',
      names: {'en': 'Queenstown', 'tr': 'Queenstown', 'de': 'Queenstown', 'fr': 'Queenstown', 'es': 'Queenstown', 'it': 'Queenstown', 'ru': 'Квинстаун', 'ar': 'كوينزتاون', 'zh': '皇后镇', 'ja': 'クイーンズタウン', 'el': 'Κουίνσταουν', 'th': 'ควีนส์ทาวน์', 'hi': 'क्वीन्सटाउन', 'ko': '퀸스타운'},
    ),
    PopularCity(
      id: 'christchurch',
      countryCode: 'NZ',
      names: {'en': 'Christchurch', 'tr': 'Christchurch', 'de': 'Christchurch', 'fr': 'Christchurch', 'es': 'Christchurch', 'it': 'Christchurch', 'ru': 'Крайстчерч', 'ar': 'كرايستشرش', 'zh': '克赖斯特彻奇', 'ja': 'クライストチャーチ', 'el': 'Κράισττσερτς', 'th': 'ไครสต์เชิร์ช', 'hi': 'क्राइस्टचर्च', 'ko': '크라이스트처치'},
    ),
    PopularCity(
      id: 'wellington',
      countryCode: 'NZ',
      names: {'en': 'Wellington', 'tr': 'Wellington', 'de': 'Wellington', 'fr': 'Wellington', 'es': 'Wellington', 'it': 'Wellington', 'ru': 'Веллингтон', 'ar': 'ويلينغتون', 'zh': '惠灵顿', 'ja': 'ウェリントン', 'el': 'Ουέλλινγκτον', 'th': 'เวลลิงตัน', 'hi': 'वेलिंग्टन', 'ko': '웰링턴'},
    ),

    // ----------------------------------------------------
    // Canada & Americas (CA, MX, BR, AR, CO, PE, CL)
    // ----------------------------------------------------
    PopularCity(
      id: 'toronto',
      countryCode: 'CA',
      names: {'en': 'Toronto', 'tr': 'Toronto', 'de': 'Toronto', 'fr': 'Toronto', 'es': 'Toronto', 'it': 'Toronto', 'ru': 'Торонто', 'ar': 'تورنتو', 'zh': '多伦多', 'ja': 'トロント', 'el': 'Τορόντο', 'th': 'โทรอนโต', 'hi': 'टोरण्टो', 'ko': '토론토'},
    ),
    PopularCity(
      id: 'vancouver',
      countryCode: 'CA',
      names: {'en': 'Vancouver', 'tr': 'Vancouver', 'de': 'Vancouver', 'fr': 'Vancouver', 'es': 'Vancouver', 'it': 'Vancouver', 'ru': 'Ванкувер', 'ar': 'فانكوفر', 'zh': '温哥华', 'ja': 'バンクーバー', 'el': 'Βανκούβερ', 'th': 'แวนคูเวอร์', 'hi': 'वैंकूवर', 'ko': '밴쿠버'},
    ),
    PopularCity(
      id: 'montreal',
      countryCode: 'CA',
      names: {'en': 'Montreal', 'tr': 'Montreal', 'fr': 'Montréal', 'de': 'Montreal', 'es': 'Montreal', 'it': 'Montréal', 'ru': 'Монреаль', 'ar': 'مونتريال', 'zh': '蒙特利尔', 'ja': 'モントリオール', 'el': 'Μόντρεαλ', 'th': 'มอนทรีออล', 'hi': 'मॉन्ट्रियल', 'ko': '몬트리올'},
    ),
    PopularCity(
      id: 'quebec_city',
      countryCode: 'CA',
      names: {'en': 'Quebec City', 'tr': 'Quebec', 'fr': 'Québec', 'de': 'Québec', 'es': 'Quebec', 'it': 'Québec', 'ru': 'Квебек', 'ar': 'كبك', 'zh': '魁北克城', 'ja': 'ケベック', 'el': 'Κεμπέκ', 'th': 'นครเกแบ็ก', 'hi': 'क्यूबेक नगर', 'ko': '퀘벡'},
    ),
    PopularCity(
      id: 'calgary',
      countryCode: 'CA',
      names: {'en': 'Calgary', 'tr': 'Calgary', 'de': 'Calgary', 'fr': 'Calgary', 'es': 'Calgary', 'it': 'Calgary', 'ru': 'Калгари', 'ar': 'كالغاري', 'zh': '卡尔加里', 'ja': 'カルガリー', 'el': 'Κάλγκαρι', 'th': 'แคลกะรี', 'hi': 'कैलगरी', 'ko': '캘거리'},
    ),
    PopularCity(
      id: 'ottawa',
      countryCode: 'CA',
      names: {'en': 'Ottawa', 'tr': 'Ottawa', 'de': 'Ottawa', 'fr': 'Ottawa', 'es': 'Ottawa', 'it': 'Ottawa', 'ru': 'Оттава', 'ar': 'أوتاوا', 'zh': '渥太华', 'ja': 'オタワ', 'el': 'Οττάβα', 'th': 'ออตตาวา', 'hi': 'ओटावा', 'ko': '오타와'},
    ),
    PopularCity(
      id: 'mexico_city',
      countryCode: 'MX',
      names: {'en': 'Mexico City', 'tr': 'Mexico City', 'es': 'Ciudad de México', 'de': 'Mexiko-Stadt', 'fr': 'Mexico', 'it': 'Città del Messico', 'ru': 'Мехико', 'ar': 'مكسيكو', 'zh': '墨西哥城', 'ja': 'メキシコシティ', 'el': 'Πόλη του Μεξικού', 'th': 'เม็กซิโกซิตี', 'hi': 'मेक्सिको नगर', 'ko': '멕시코시티'},
    ),
    PopularCity(
      id: 'cancun',
      countryCode: 'MX',
      names: {'en': 'Cancun', 'tr': 'Cancun', 'es': 'Cancún', 'de': 'Cancún', 'fr': 'Cancún', 'it': 'Cancún', 'ru': 'Канкун', 'ar': 'كانكون', 'zh': '坎昆', 'ja': 'カンクン', 'el': 'Κανκούν', 'th': 'กังกุน', 'hi': 'कान्कुन', 'ko': '캉쿤'},
    ),
    PopularCity(
      id: 'playa_del_carmen',
      countryCode: 'MX',
      names: {'en': 'Playa del Carmen', 'tr': 'Playa del Carmen', 'es': 'Playa del Carmen', 'de': 'Playa del Carmen', 'fr': 'Playa del Carmen', 'ru': 'Плайя-дель-Кармен', 'ar': 'بلايا ديل كارمن', 'zh': '普拉亚德尔卡门', 'ja': 'プラヤ・デル・カルメン', 'el': 'Πλάγια ντελ Κάρμεν', 'th': 'ปลายาเดลการ์เมน', 'hi': 'प्लाया डेल कारमेन', 'ko': '플라야델카르멘'},
    ),
    PopularCity(
      id: 'oaxaca',
      countryCode: 'MX',
      names: {'en': 'Oaxaca', 'tr': 'Oaxaca', 'es': 'Oaxaca', 'de': 'Oaxaca', 'fr': 'Oaxaca', 'it': 'Oaxaca', 'ru': 'Оахака', 'ar': 'واهاكا', 'zh': '瓦哈卡', 'ja': 'オアハカ', 'el': 'Οαχάκα', 'th': 'วาฮากา', 'hi': 'वाख़ाका', 'ko': '오아하카'},
    ),
    PopularCity(
      id: 'guadalajara',
      countryCode: 'MX',
      names: {'en': 'Guadalajara', 'tr': 'Guadalajara', 'es': 'Guadalajara', 'de': 'Guadalajara', 'fr': 'Guadalajara', 'it': 'Guadalajara', 'ru': 'Гвадалахара', 'ar': 'غوادالاخارا', 'zh': '瓜达拉哈拉', 'ja': 'グアダラハラ', 'el': 'Γουαδαλαχάρα', 'th': 'กัวดาลาฮารา', 'hi': 'ग्वादालाख़ारा', 'ko': '과달라하라'},
    ),
    PopularCity(
      id: 'rio_de_janeiro',
      countryCode: 'BR',
      names: {'en': 'Rio de Janeiro', 'tr': 'Rio de Janeiro', 'pt': 'Rio de Janeiro', 'de': 'Rio de Janeiro', 'fr': 'Rio de Janeiro', 'es': 'Río de Janeiro', 'it': 'Rio de Janeiro', 'ru': 'Рио-де-Жанейро', 'ar': 'ريو دي جانيرو', 'zh': '里约热内卢', 'ja': 'リオデジャネイロ', 'el': 'Ρίο Ντε Τζανέιρο', 'th': 'รีโอเดจาเนโร', 'hi': 'रियो डि जेनेरो', 'ko': '리우데자네이루'},
    ),
    PopularCity(
      id: 'sao_paulo',
      countryCode: 'BR',
      names: {'en': 'Sao Paulo', 'tr': 'Sao Paulo', 'pt': 'São Paulo', 'de': 'São Paulo', 'fr': 'São Paulo', 'es': 'São Paulo', 'it': 'San Paolo', 'ru': 'Сан-Паулу', 'ar': 'ساو باولو', 'zh': '圣保罗', 'ja': 'サンパウロ', 'el': 'Σάο Πάολο', 'th': 'เซาเปาลู', 'hi': 'साओ पाउलो', 'ko': '상파울루'},
    ),
    PopularCity(
      id: 'buenos_aires',
      countryCode: 'AR',
      names: {'en': 'Buenos Aires', 'tr': 'Buenos Aires', 'es': 'Buenos Aires', 'de': 'Buenos Aires', 'fr': 'Buenos Aires', 'it': 'Buenos Aires', 'ru': 'Буэнос-Айрес', 'ar': 'بوينس آيرس', 'zh': '布宜诺斯艾利斯', 'ja': 'ブエノスアイレス', 'el': 'Μπουένος Άιρες', 'th': 'บัวโนสไอเรส', 'hi': 'ब्यूनस आयर्स', 'ko': '부에노스아이레스'},
    ),
    PopularCity(
      id: 'bogota',
      countryCode: 'CO',
      names: {'en': 'Bogota', 'tr': 'Bogota', 'es': 'Bogotá', 'de': 'Bogotá', 'fr': 'Bogota', 'it': 'Bogotà', 'ru': 'Богота', 'ar': 'بوغوتا', 'zh': '波哥大', 'ja': 'ボゴタ', 'el': 'Μπογκοτά', 'th': 'โบโกตา', 'hi': 'बोगोटा', 'ko': '보고타'},
    ),
    PopularCity(
      id: 'medellin',
      countryCode: 'CO',
      names: {'en': 'Medellin', 'tr': 'Medellin', 'es': 'Medellín', 'de': 'Medellín', 'fr': 'Medellín', 'it': 'Medellín', 'ru': 'Медельин', 'ar': 'ميديلين', 'zh': '麦德林', 'ja': 'メデジン', 'el': 'Μεδεγίν', 'th': 'เมเดยิน', 'hi': 'मेदेयिन', 'ko': '메데인'},
    ),
    PopularCity(
      id: 'cartagena',
      countryCode: 'CO',
      names: {'en': 'Cartagena', 'tr': 'Cartagena', 'es': 'Cartagena', 'de': 'Cartagena', 'fr': 'Carthagène', 'it': 'Cartagena', 'ru': 'Картахена', 'ar': 'قرطاجنة', 'zh': '卡塔赫纳', 'ja': 'カルタヘナ', 'el': 'Καρταχένα', 'th': 'การ์ตาเฮนา', 'hi': 'कार्ताख़ेना', 'ko': '카르타헤나'},
    ),
    PopularCity(
      id: 'lima',
      countryCode: 'PE',
      names: {'en': 'Lima', 'tr': 'Lima', 'es': 'Lima', 'de': 'Lima', 'fr': 'Lima', 'it': 'Lima', 'ru': 'Лима', 'ar': 'ليما', 'zh': '利马', 'ja': 'リマ', 'el': 'Λίμα', 'th': 'ลิมา', 'hi': 'लीमा', 'ko': '리마'},
    ),
    PopularCity(
      id: 'cusco',
      countryCode: 'PE',
      names: {'en': 'Cusco', 'tr': 'Kusko', 'es': 'Cusco', 'de': 'Cusco', 'fr': 'Cuzco', 'it': 'Cusco', 'ru': 'Куско', 'ar': 'كوسكو', 'zh': '库斯科', 'ja': 'クスコ', 'el': 'Κούζκο', 'th': 'กุสโก', 'hi': 'कुस्को', 'ko': '쿠스코'},
    ),
    PopularCity(
      id: 'santiago',
      countryCode: 'CL',
      names: {'en': 'Santiago', 'tr': 'Santiago', 'es': 'Santiago de Chile', 'de': 'Santiago de Chile', 'fr': 'Santiago', 'it': 'Santiago del Cile', 'ru': 'Сантьяго', 'ar': 'سانتياغو', 'zh': '圣地亚哥', 'ja': 'サンティアゴ', 'el': 'Σαντιάγο', 'th': 'ซันติอาโก', 'hi': 'सेण्टियागो', 'ko': '산티아고'},
    ),

    // ----------------------------------------------------
    // Balkans & Eastern Europe (CY, NC, XK, BA, RS, ME, MK, AL, BG, RO, SI, SK)
    // ----------------------------------------------------
    PopularCity(
      id: 'nicosia',
      countryCode: 'NC',
      names: {'en': 'Nicosia', 'tr': 'Lefkoşa', 'el': 'Λευκωσία', 'de': 'Nikosia', 'fr': 'Nicosie', 'es': 'Nicosia', 'it': 'Nicosia', 'ru': 'Никосия', 'ar': 'نيقوسيا', 'zh': '尼科西亚', 'ja': 'ニコシア', 'th': 'นิโคเซีย', 'hi': 'निकोसिया', 'ko': '니코시아'},
    ),
    PopularCity(
      id: 'kyrenia',
      countryCode: 'NC',
      names: {'en': 'Kyrenia', 'tr': 'Girne', 'el': 'Κερύνεια', 'de': 'Kyrenia', 'fr': 'Kyrenia', 'es': 'Kyrenia', 'it': 'Kyrenia', 'ru': 'Кирения', 'ar': 'غرنة', 'zh': '凯里尼亚', 'ja': 'キレニア', 'th': 'ไครีเนีย', 'hi': 'किरेनिया', 'ko': '키레니아'},
    ),
    PopularCity(
      id: 'famagusta',
      countryCode: 'NC',
      names: {'en': 'Famagusta', 'tr': 'Gazimağusa', 'el': 'Αμμόχωστος', 'de': 'Famagusta', 'fr': 'Famagouste', 'es': 'Famagusta', 'it': 'Famagosta', 'ru': 'Фамагуста', 'ar': 'فاماغوستا', 'zh': '法马古斯塔', 'ja': 'ファマグスタ', 'th': 'ฟามากุสตา', 'hi': 'फामागुस्ता', 'ko': '파마구스타'},
    ),
    PopularCity(
      id: 'pristina',
      countryCode: 'XK',
      names: {'en': 'Pristina', 'tr': 'Priştine', 'sq': 'Prishtinë', 'sr': 'Priština', 'de': 'Pristina', 'fr': 'Pristina', 'es': 'Pristina', 'it': 'Pristina', 'ru': 'Приштина', 'ar': 'برشتينة', 'zh': '普里什蒂纳', 'ja': 'プリシュティナ', 'el': 'Πρίστινα', 'th': 'พริสตีนา', 'hi': 'प्रिस्टिना', 'ko': '프리슈티나'},
    ),
    PopularCity(
      id: 'prizren',
      countryCode: 'XK',
      names: {'en': 'Prizren', 'tr': 'Prizren', 'sq': 'Prizren', 'sr': 'Prizren', 'de': 'Prizren', 'fr': 'Prizren', 'es': 'Prizren', 'it': 'Prizren', 'ru': 'Призрен', 'ar': 'برزرين', 'zh': '普里兹伦', 'ja': 'プリズレン', 'el': 'Πρίζρεν', 'th': 'ปริซเร็น', 'hi': 'प्रिज़्रेन', 'ko': '프리즈렌'},
    ),
    PopularCity(
      id: 'sarajevo',
      countryCode: 'BA',
      names: {'en': 'Sarajevo', 'tr': 'Saraybosna', 'bs': 'Sarajevo', 'de': 'Sarajevo', 'fr': 'Sarajevo', 'es': 'Sarajevo', 'it': 'Sarajevo', 'ru': 'Сараево', 'ar': 'سراييفو', 'zh': '萨拉热窝', 'ja': 'サラエヴォ', 'el': 'Σαράγιεβο', 'th': 'ซาราเยโว', 'hi': 'सारायेवो', 'ko': '사라예보'},
    ),
    PopularCity(
      id: 'mostar',
      countryCode: 'BA',
      names: {'en': 'Mostar', 'tr': 'Mostar', 'bs': 'Mostar', 'de': 'Mostar', 'fr': 'Mostar', 'es': 'Mostar', 'it': 'Mostar', 'ru': 'Мостар', 'ar': 'موستار', 'zh': '莫斯塔尔', 'ja': 'モスタル', 'el': 'Μόσταρ', 'th': 'ม็อสตาร์', 'hi': 'मोस्टर', 'ko': '모스타르'},
    ),
    PopularCity(
      id: 'belgrade',
      countryCode: 'RS',
      names: {'en': 'Belgrade', 'tr': 'Belgrad', 'sr': 'Beograd', 'de': 'Belgrad', 'fr': 'Belgrade', 'es': 'Belgrado', 'it': 'Belgrado', 'ru': 'Белград', 'ar': 'بلغراد', 'zh': '贝尔格莱德', 'ja': 'ベオグラード', 'el': 'Βελιγράδι', 'th': 'เบลเกรด', 'hi': 'बेलग्रेड', 'ko': '베오그라드'},
    ),
    PopularCity(
      id: 'ljubljana',
      countryCode: 'SI',
      names: {'en': 'Ljubljana', 'tr': 'Lübliyana', 'sl': 'Ljubljana', 'de': 'Laibach', 'fr': 'Ljubljana', 'es': 'Liubliana', 'it': 'Lubiana', 'ru': 'Любляна', 'ar': 'لبلانة', 'zh': '卢布尔雅那', 'ja': 'リュブリャナ', 'el': 'Λιουμπλιάνα', 'th': 'ลูบลิยานา', 'hi': 'लुब्लियाना', 'ko': '류블랴나'},
    ),
    PopularCity(
      id: 'skopje',
      countryCode: 'MK',
      names: {'en': 'Skopje', 'tr': 'Üsküp', 'mk': 'Скопје', 'de': 'Skopje', 'fr': 'Skopje', 'es': 'Skopje', 'it': 'Skopje', 'ru': 'Скопье', 'ar': 'إسكوبية', 'zh': '斯科普里', 'ja': 'スコピエ', 'el': 'Σκόπια', 'th': 'สกอเปีย', 'hi': 'स्कोपिये', 'ko': '스코페'},
    ),
    PopularCity(
      id: 'tirana',
      countryCode: 'AL',
      names: {'en': 'Tirana', 'tr': 'Tiran', 'sq': 'Tiranë', 'de': 'Tirana', 'fr': 'Tirana', 'es': 'Tirana', 'it': 'Tirana', 'ru': 'Тирана', 'ar': 'تيرانا', 'zh': '地拉那', 'ja': 'ティラナ', 'el': 'Τίρανα', 'th': 'ติรานา', 'hi': 'तिराना', 'ko': '티라나'},
    ),
    PopularCity(
      id: 'podgorica',
      countryCode: 'ME',
      names: {'en': 'Podgorica', 'tr': 'Podgoritsa', 'cnr': 'Podgorica', 'de': 'Podgorica', 'fr': 'Podgorica', 'es': 'Podgorica', 'it': 'Podgorica', 'ru': 'Подгорица', 'ar': 'بودغوريتسا', 'zh': '波德戈里察', 'ja': 'ポドゴリツァ', 'el': 'Ποντγκόριτσα', 'th': 'พอดกอรีตซา', 'hi': 'पॉडगिरिट्सा', 'ko': '포드고리차'},
    ),
    PopularCity(
      id: 'kotor',
      countryCode: 'ME',
      names: {'en': 'Kotor', 'tr': 'Kotor', 'cnr': 'Kotor', 'de': 'Kotor', 'fr': 'Kotor', 'es': 'Kotor', 'it': 'Cattaro', 'ru': 'Котор', 'ar': 'كوتور', 'zh': '科托尔', 'ja': 'コトル', 'el': 'Κότορ', 'th': 'เมืองโคเตอร์', 'hi': 'कोटोर', 'ko': '코토르'},
    ),
    PopularCity(
      id: 'budva',
      countryCode: 'ME',
      names: {'en': 'Budva', 'tr': 'Budva', 'cnr': 'Budva', 'de': 'Budva', 'fr': 'Budva', 'es': 'Budva', 'it': 'Budua', 'ru': 'Будва', 'ar': 'بودفا', 'zh': '布德瓦', 'ja': 'ブドヴァ', 'el': 'Μπούντβα', 'th': 'บุดวา', 'hi': 'बुडवा', 'ko': '부드바'},
    ),
    PopularCity(
      id: 'sofia',
      countryCode: 'BG',
      names: {'en': 'Sofia', 'tr': 'Sofya', 'bg': 'София', 'de': 'Sofia', 'fr': 'Sofia', 'es': 'Sofía', 'it': 'Sofia', 'ru': 'София', 'ar': 'صوفيا', 'zh': '索非亚', 'ja': 'ソフィア', 'el': 'Σόφια', 'th': 'โซเฟีย', 'hi': 'सोफिया', 'ko': '소피아'},
    ),
    PopularCity(
      id: 'plovdiv',
      countryCode: 'BG',
      names: {'en': 'Plovdiv', 'tr': 'Filibe', 'bg': 'Пловдив', 'de': 'Plowdiw', 'fr': 'Plovdiv', 'es': 'Plovdiv', 'it': 'Plovdiv', 'ru': 'Пловдив', 'ar': 'بلوفديف', 'zh': '普罗夫迪夫', 'ja': 'プロヴディフ', 'el': 'Φιλιππούπολη', 'th': 'ปลอฟดิฟ', 'hi': 'प्लोव्दिव', 'ko': '플로브디프'},
    ),
    PopularCity(
      id: 'bucharest',
      countryCode: 'RO',
      names: {'en': 'Bucharest', 'tr': 'Bükreş', 'ro': 'București', 'de': 'Bukarest', 'fr': 'Bucarest', 'es': 'Bucarest', 'it': 'Bucarest', 'ru': 'Бухарест', 'ar': 'بوخارست', 'zh': '布加勒斯特', 'ja': 'ブカレスト', 'el': 'Βουκουρέστι', 'th': 'บูคาเรสต์', 'hi': 'बुख़ारेस्ट', 'ko': '부쿠레슈티'},
    ),
    PopularCity(
      id: 'brasov',
      countryCode: 'RO',
      names: {'en': 'Brasov', 'tr': 'Braşov', 'ro': 'Brașov', 'de': 'Kronstadt', 'fr': 'Brașov', 'es': 'Brașov', 'it': 'Brașov', 'ru': 'Брашов', 'ar': 'براشوف', 'zh': '布拉索夫', 'ja': 'ブラショヴ', 'el': 'Μπρασόβ', 'th': 'บราซอฟ', 'hi': 'ब्रासोव', 'ko': '브라쇼브'},
    ),
    PopularCity(
      id: 'bratislava',
      countryCode: 'SK',
      names: {'en': 'Bratislava', 'tr': 'Bratislava', 'sk': 'Bratislava', 'de': 'Pressburg', 'fr': 'Bratislava', 'es': 'Bratislava', 'it': 'Bratislava', 'ru': 'Братислава', 'ar': 'براتيسلافا', 'zh': '布拉迪斯拉发', 'ja': 'ブラチスラヴァ', 'el': 'Μπρατισλάβα', 'th': 'บราติสลาวา', 'hi': 'ब्रातिस्लावा', 'ko': '브라티슬라바'},
    ),

    // ----------------------------------------------------
    // Caucasus & Central Asia (GE, AZ, AM, UZ, KZ)
    // ----------------------------------------------------
    PopularCity(
      id: 'tbilisi',
      countryCode: 'GE',
      names: {'en': 'Tbilisi', 'tr': 'Tiflis', 'ka': 'თბილისი', 'de': 'Tiflis', 'fr': 'Tbilissi', 'es': 'Tiflis', 'it': 'Tbilisi', 'ru': 'Тбилиси', 'ar': 'تبليسي', 'zh': '第比利斯', 'ja': 'トビリシ', 'el': 'Τιφλίδα', 'th': 'ทบิลีซี', 'hi': 'त्बिलिसी', 'ko': '트빌리'},
    ),
    PopularCity(
      id: 'batumi',
      countryCode: 'GE',
      names: {'en': 'Batumi', 'tr': 'Batum', 'ka': 'ბათუმი', 'de': 'Batumi', 'fr': 'Batoumi', 'es': 'Batumi', 'it': 'Batumi', 'ru': 'Батуми', 'ar': 'باطوم', 'zh': '巴统', 'ja': 'バトゥミ', 'el': 'Μπατούμι', 'th': 'บาทูมี', 'hi': 'बातुमी', 'ko': '바투미'},
    ),
    PopularCity(
      id: 'baku',
      countryCode: 'AZ',
      names: {'en': 'Baku', 'tr': 'Bakü', 'az': 'Bakı', 'de': 'Baku', 'fr': 'Bakou', 'es': 'Bakú', 'it': 'Baku', 'ru': 'Баку', 'ar': 'باكو', 'zh': '巴库', 'ja': 'バクー', 'el': 'Μπακού', 'th': 'บากู', 'hi': 'बाकू', 'ko': '바쿠'},
    ),
    PopularCity(
      id: 'yerevan',
      countryCode: 'AM',
      names: {'en': 'Yerevan', 'tr': 'Erivan', 'hy': 'Երևան', 'de': 'Jerewan', 'fr': 'Erevan', 'es': 'Ereván', 'it': 'Erevan', 'ru': 'Ереван', 'ar': 'يريفان', 'zh': '埃里温', 'ja': 'イェレヴァン', 'el': 'Γερεβάν', 'th': 'เยเรวาน', 'hi': 'येरेवान', 'ko': '예레반'},
    ),
    PopularCity(
      id: 'tashkent',
      countryCode: 'UZ',
      names: {'en': 'Tashkent', 'tr': 'Taşkent', 'uz': 'Toshkent', 'de': 'Taschkent', 'fr': 'Tachkent', 'es': 'Taskent', 'it': 'Tashkent', 'ru': 'Ташкент', 'ar': 'طشقند', 'zh': '塔什干', 'ja': 'タシュケント', 'el': 'Τασκένδη', 'th': 'ทาชเคนต์', 'hi': 'ताशकन्द', 'ko': '타슈켄트'},
    ),
    PopularCity(
      id: 'samarkand',
      countryCode: 'UZ',
      names: {'en': 'Samarkand', 'tr': 'Semerkant', 'uz': 'Samarqand', 'de': 'Samarkand', 'fr': 'Samarcande', 'es': 'Samarcanda', 'it': 'Samarcanda', 'ru': 'Самарканд', 'ar': 'سمرقند', 'zh': '撒马尔罕', 'ja': 'サマルカンド', 'el': 'Σαμαρκάνδη', 'th': 'ซามาร์กันต์', 'hi': 'समरक़न्द', 'ko': '사마르칸트'},
    ),
    PopularCity(
      id: 'bukhara',
      countryCode: 'UZ',
      names: {'en': 'Bukhara', 'tr': 'Buhara', 'uz': 'Buxoro', 'de': 'Buchara', 'fr': 'Boukhara', 'es': 'Bujará', 'it': 'Bukhara', 'ru': 'Бухара', 'ar': 'بخارى', 'zh': '布哈拉', 'ja': 'ブハラ', 'el': 'Μπουχάρα', 'th': 'บูฆอรอ', 'hi': 'बुख़ारा', 'ko': '부하라'},
    ),
    PopularCity(
      id: 'almaty',
      countryCode: 'KZ',
      names: {'en': 'Almaty', 'tr': 'Almatı', 'kk': 'Алматы', 'de': 'Almaty', 'fr': 'Almaty', 'es': 'Almaty', 'it': 'Almaty', 'ru': 'Алматы', 'ar': 'ألماطة', 'zh': '阿拉木图', 'ja': 'アルマトイ', 'el': 'Αλμάτι', 'th': 'อัลมาเตอ', 'hi': 'अलमाती', 'ko': '알마티'},
    ),
    PopularCity(
      id: 'astana',
      countryCode: 'KZ',
      names: {'en': 'Astana', 'tr': 'Astana', 'kk': 'Астана', 'de': 'Astana', 'fr': 'Astana', 'es': 'Astana', 'it': 'Astana', 'ru': 'Астана', 'ar': 'أستانة', 'zh': '阿斯塔纳', 'ja': 'アスタナ', 'el': 'Αστανά', 'th': 'อัสตานา', 'hi': 'अस्ताना', 'ko': '아스타나'},
    ),

    // ----------------------------------------------------
    // South Asia & Rest of Asia (IN, LK, NP, MV, VN, PH)
    // ----------------------------------------------------
    PopularCity(
      id: 'delhi',
      countryCode: 'IN',
      names: {'en': 'New Delhi', 'tr': 'Yeni Delhi', 'hi': 'नई दिल्ली', 'de': 'Neu-Delhi', 'fr': 'New Delhi', 'es': 'Nueva Delhi', 'it': 'Nuova Delhi', 'ru': 'Нью-Дели', 'ar': 'نيو دلهي', 'zh': '新德里', 'ja': 'ニューデリー', 'el': 'Νέο Δελχί', 'th': 'นิวเดลี', 'ko': '뉴델리'},
    ),
    PopularCity(
      id: 'mumbai',
      countryCode: 'IN',
      names: {'en': 'Mumbai', 'tr': 'Mumbai', 'hi': 'मुंबई', 'de': 'Mumbai', 'fr': 'Mumbai', 'es': 'Bombay', 'it': 'Mumbai', 'ru': 'Мумбаи', 'ar': 'مومباي', 'zh': '孟买', 'ja': 'ムンバイ', 'el': 'Μουμπάι', 'th': 'มุมไบ', 'ko': '뭄바이'},
    ),
    PopularCity(
      id: 'jaipur',
      countryCode: 'IN',
      names: {'en': 'Jaipur', 'tr': 'Jaipur', 'hi': 'जयपुर', 'de': 'Jaipur', 'fr': 'Jaipur', 'es': 'Jaipur', 'it': 'Jaipur', 'ru': 'Джайпур', 'ar': 'جيبور', 'zh': '斋浦尔', 'ja': 'ジャイプル', 'el': 'Τζαϊπούρ', 'th': 'ชัยปุระ', 'ko': '자이푸르'},
    ),
    PopularCity(
      id: 'agra',
      countryCode: 'IN',
      names: {'en': 'Agra', 'tr': 'Agra', 'hi': 'आगरा', 'de': 'Agra', 'fr': 'Agra', 'es': 'Agra', 'it': 'Agra', 'ru': 'Агра', 'ar': 'أغرة', 'zh': '阿格拉', 'ja': 'アーグラ', 'el': 'Άγκρα', 'th': 'อาครา', 'ko': '아그라'},
    ),
    PopularCity(
      id: 'colombo',
      countryCode: 'LK',
      names: {'en': 'Colombo', 'tr': 'Kolombo', 'si': 'කොළඹ', 'de': 'Colombo', 'fr': 'Colombo', 'es': 'Colombo', 'it': 'Colombo', 'ru': 'Коломбо', 'ar': 'كولمبو', 'zh': '科伦坡', 'ja': 'コロンボ', 'el': 'Κολόμπο', 'th': 'โคลัมโบ', 'hi': 'कोलंबो', 'ko': '콜롬보'},
    ),
    PopularCity(
      id: 'kathmandu',
      countryCode: 'NP',
      names: {'en': 'Kathmandu', 'tr': 'Katmandu', 'ne': 'काठमाडौं', 'de': 'Kathmandu', 'fr': 'Katmandou', 'es': 'Katmandú', 'it': 'Katmandu', 'ru': 'Катманду', 'ar': 'كتمندو', 'zh': '加德满都', 'ja': 'カトマンズ', 'el': 'Κατμαντού', 'th': 'กาฐมาณฑุ', 'hi': 'काठमांडू', 'ko': '카트만두'},
    ),
    PopularCity(
      id: 'male',
      countryCode: 'MV',
      names: {'en': 'Male', 'tr': 'Male', 'dv': 'މާލެ', 'de': 'Malé', 'fr': 'Malé', 'es': 'Malé', 'it': 'Malé', 'ru': 'Мале', 'ar': 'ماليه', 'zh': '马累', 'ja': 'マレ', 'el': 'Μαλέ', 'th': 'มาเล', 'hi': 'माले', 'ko': '말레'},
    ),
    PopularCity(
      id: 'hanoi',
      countryCode: 'VN',
      names: {'en': 'Hanoi', 'tr': 'Hanoi', 'vi': 'Hà Nội', 'de': 'Hanoi', 'fr': 'Hanoï', 'es': 'Hanói', 'it': 'Hanoi', 'ru': 'Ханой', 'ar': 'هانوي', 'zh': '河内', 'ja': 'ハノイ', 'el': 'Ανόι', 'th': 'ฮานอย', 'hi': 'हनोई', 'ko': '하노이'},
    ),
    PopularCity(
      id: 'ho_chi_minh',
      countryCode: 'VN',
      names: {'en': 'Ho Chi Minh City', 'tr': 'Ho Chi Minh', 'vi': 'Thành phố Hồ Chí Minh', 'de': 'Ho-Chi-Minh-Stadt', 'fr': 'Hô Chi Minh-Ville', 'es': 'Ciudad Ho Chi Minh', 'it': 'Ho Chi Minh', 'ru': 'Хошимин', 'ar': 'هو تشي منه', 'zh': '胡志明', 'ja': 'ホーチミン', 'el': 'Χο Τσι Μινχ', 'th': 'นครโฮจิมินห์', 'hi': 'हो ची मिन नगर', 'ko': '호찌민'},
    ),
    PopularCity(
      id: 'da_nang',
      countryCode: 'VN',
      names: {'en': 'Da Nang', 'tr': 'Da Nang', 'vi': 'Đà Nẵng', 'de': 'Đà Nẵng', 'fr': 'Da Nang', 'es': 'Da Nang', 'it': 'Da Nang', 'ru': 'Дананг', 'ar': 'دا نانغ', 'zh': '岘港', 'ja': 'ダナン', 'el': 'Ντα Νανγκ', 'th': 'ดานัง', 'hi': 'दा नांग', 'ko': '다낭'},
    ),
    PopularCity(
      id: 'manila',
      countryCode: 'PH',
      names: {'en': 'Manila', 'tr': 'Manila', 'tl': 'Maynila', 'de': 'Manila', 'fr': 'Manille', 'es': 'Manila', 'it': 'Manila', 'ru': 'Манила', 'ar': 'مانيلا', 'zh': '马尼拉', 'ja': 'マニラ', 'el': 'Μανίλα', 'th': 'มะนิลา', 'hi': 'मनीला', 'ko': '마닐라'},
    ),
    PopularCity(
      id: 'cebu',
      countryCode: 'PH',
      names: {'en': 'Cebu', 'tr': 'Cebu', 'tl': 'Cebu', 'de': 'Cebu', 'fr': 'Cebu', 'es': 'Cebú', 'it': 'Cebu', 'ru': 'Себу', 'ar': 'سيبو', 'zh': '宿务', 'ja': 'セブ州', 'el': 'Σεμπού', 'th': 'เซบู', 'hi': 'सिबु', 'ko': '세부'},
    ),

    // ----------------------------------------------------
    // Baltics & Eastern (EE, LV, LT, UA, RU)
    // ----------------------------------------------------
    PopularCity(
      id: 'tallinn',
      countryCode: 'EE',
      names: {'en': 'Tallinn', 'tr': 'Tallinn', 'et': 'Tallinn', 'de': 'Tallinn', 'fr': 'Tallinn', 'es': 'Tallin', 'it': 'Tallinn', 'ru': 'Таллин', 'ar': 'تالين', 'zh': '塔林', 'ja': 'タリン', 'el': 'Τάλιν', 'th': 'ทาลลินน์', 'hi': 'ताल्लिन', 'ko': '탈린'},
    ),
    PopularCity(
      id: 'riga',
      countryCode: 'LV',
      names: {'en': 'Riga', 'tr': 'Riga', 'lv': 'Rīga', 'de': 'Riga', 'fr': 'Riga', 'es': 'Riga', 'it': 'Riga', 'ru': 'Рига', 'ar': 'ريغا', 'zh': '里加', 'ja': 'リガ', 'el': 'Ρίγα', 'th': 'รีกา', 'hi': 'रीगा', 'ko': '리가'},
    ),
    PopularCity(
      id: 'vilnius',
      countryCode: 'LT',
      names: {'en': 'Vilnius', 'tr': 'Vilnüs', 'lt': 'Vilnius', 'de': 'Vilnius', 'fr': 'Vilnius', 'es': 'Vilna', 'it': 'Vilnius', 'ru': 'Вильнюс', 'ar': 'فيلنيوس', 'zh': '维尔纽斯', 'ja': 'ヴィルニュス', 'el': 'Βίλνιους', 'th': 'วิลนีอัส', 'hi': 'विल्नुस', 'ko': '빌뉴스'},
    ),
    PopularCity(
      id: 'kyiv',
      countryCode: 'UA',
      names: {'en': 'Kyiv', 'tr': 'Kiev', 'uk': 'Київ', 'de': 'Kiew', 'fr': 'Kyïv', 'es': 'Kiev', 'it': 'Kiev', 'ru': 'Киев', 'ar': 'كييف', 'zh': '基辅', 'ja': 'キーウ', 'el': 'Κίεβο', 'th': 'เคียฟ', 'hi': 'कीव', 'ko': '키이우'},
    ),
    PopularCity(
      id: 'lviv',
      countryCode: 'UA',
      names: {'en': 'Lviv', 'tr': 'Lviv', 'uk': 'Львів', 'de': 'Lemberg', 'fr': 'Lviv', 'es': 'Leópolis', 'it': 'Leopoli', 'ru': 'Львов', 'ar': 'لفيف', 'zh': '利沃夫', 'ja': 'リヴィウ', 'el': 'Λβιβ', 'th': 'ลวิว', 'hi': 'लुव्यूव', 'ko': '르비우'},
    ),
    PopularCity(
      id: 'odesa',
      countryCode: 'UA',
      names: {'en': 'Odesa', 'tr': 'Odessa', 'uk': 'Одеса', 'de': 'Odessa', 'fr': 'Odessa', 'es': 'Odesa', 'it': 'Odessa', 'ru': 'Одесса', 'ar': 'أوديسا', 'zh': '敖德萨', 'ja': 'オデーサ', 'el': 'Οδησσός', 'th': 'ออแดซา', 'hi': 'ओडेसा', 'ko': '오데사'},
    ),
    PopularCity(
      id: 'moscow',
      countryCode: 'RU',
      names: {'en': 'Moscow', 'tr': 'Moskova', 'ru': 'Москва', 'de': 'Moskau', 'fr': 'Moscou', 'es': 'Moscú', 'it': 'Mosca', 'ar': 'موسكو', 'zh': '莫斯科', 'ja': 'モスクワ', 'el': 'Μόσχα', 'th': 'มอสโก', 'hi': 'मास्को', 'ko': '모스크바'},
    ),
    PopularCity(
      id: 'saint_petersburg',
      countryCode: 'RU',
      names: {'en': 'Saint Petersburg', 'tr': 'Sankt Peterburg', 'ru': 'Санкт-Петербург', 'de': 'Sankt Petersburg', 'fr': 'Saint-Pétersbourg', 'es': 'San Petersburgo', 'it': 'San Pietroburgo', 'ar': 'سانت بطرسبرغ', 'zh': '圣彼得堡', 'ja': 'サンクトペテルブルク', 'el': 'Αγία Πετρούπολη', 'th': 'เซนต์ปีเตอส์เบิร์ก', 'hi': 'सेंट पीटर्सबर्ग', 'ko': '상트페테르부르크'},
    ),
    PopularCity(
      id: 'kazan',
      countryCode: 'RU',
      names: {'en': 'Kazan', 'tr': 'Kazan', 'ru': 'Казань', 'tt': 'Казан', 'de': 'Kasan', 'fr': 'Kazan', 'es': 'Kazán', 'it': 'Kazan', 'ar': 'قازان', 'zh': '喀山', 'ja': 'カザン', 'el': 'Καζάν', 'th': 'คาซัน', 'hi': 'काज़ान', 'ko': '카잔'},
    ),
    PopularCity(
      id: 'sochi',
      countryCode: 'RU',
      names: {'en': 'Sochi', 'tr': 'Soçi', 'ru': 'Сочи', 'de': 'Sotschi', 'fr': 'Sotchi', 'es': 'Sochi', 'it': 'Soči', 'ar': 'سوتشي', 'zh': '索契', 'ja': 'ソチ', 'el': 'Σότσι', 'th': 'โซชี', 'hi': 'सोची', 'ko': '소치'},
    ),

    // ----------------------------------------------------
    // Sub-Saharan Africa & Indian Ocean (ZA, KE, TZ, ZW, MU, SC)
    // ----------------------------------------------------
    PopularCity(
      id: 'cape_town',
      countryCode: 'ZA',
      names: {'en': 'Cape Town', 'tr': 'Cape Town', 'af': 'Kaapstad', 'de': 'Kapstadt', 'fr': 'Le Cap', 'es': 'Ciudad del Cabo', 'it': 'Città del Capo', 'ru': 'Кейптаун', 'ar': 'كيب تاون', 'zh': '开普敦', 'ja': 'ケープタウン', 'el': 'Κέιπ Τάουν', 'th': 'เคปทาวน์', 'hi': 'केप टाउन', 'ko': '케이프타운'},
    ),
    PopularCity(
      id: 'johannesburg',
      countryCode: 'ZA',
      names: {'en': 'Johannesburg', 'tr': 'Johannesburg', 'af': 'Johannesburg', 'de': 'Johannesburg', 'fr': 'Johannesbourg', 'es': 'Johannesburgo', 'it': 'Johannesburg', 'ru': 'Йоханнесбург', 'ar': 'جوهانسبرغ', 'zh': '约翰内斯堡', 'ja': 'ヨハネスブルグ', 'el': 'Γιοχάνεσμπουργκ', 'th': 'โจฮันเนสเบิร์ก', 'hi': 'जोहानिसबर्ग', 'ko': '요하네스버그'},
    ),
    PopularCity(
      id: 'nairobi',
      countryCode: 'KE',
      names: {'en': 'Nairobi', 'tr': 'Nairobi', 'sw': 'Nairobi', 'de': 'Nairobi', 'fr': 'Nairobi', 'es': 'Nairobi', 'it': 'Nairobi', 'ru': 'Найроби', 'ar': 'نيروبي', 'zh': '内罗毕', 'ja': 'ナイロビ', 'el': 'Ναϊρόμπι', 'th': 'ไนโรบี', 'hi': 'नायरोबी', 'ko': '나이로비'},
    ),
    PopularCity(
      id: 'zanzibar',
      countryCode: 'TZ',
      names: {'en': 'Zanzibar City', 'tr': 'Zanzibar', 'sw': 'Jiji la Zanzibar', 'de': 'Sansibar-Stadt', 'fr': 'Zanzibar', 'es': 'Zanzíbar', 'it': 'Zanzibar', 'ru': 'Занзибар', 'ar': 'زنجبار', 'zh': '桑给巴尔', 'ja': 'ザンジバルシティ', 'el': 'Πόλη της Ζανζιβάρης', 'th': 'ซานซิบาร์', 'hi': 'ज़ंज़ीबार सिटी', 'ko': '잔지바르 '},
    ),
    PopularCity(
      id: 'victoria_falls',
      countryCode: 'ZW',
      names: {'en': 'Victoria Falls', 'tr': 'Victoria Şelaleleri', 'de': 'Victoriafälle', 'fr': 'Chutes Victoria', 'es': 'Cataratas Victoria', 'ru': 'Виктория-Фоллс', 'ar': 'شلالات فكتوريا', 'zh': '维多利亚瀑布', 'ja': 'ヴィクトリアの滝', 'el': 'Καταρράκτες Βικτωρίας', 'th': 'น้ำตกวิกตอเรีย', 'hi': 'विक्टोरिया जलप्रपात', 'ko': '빅토리아 폭포'},
    ),
    PopularCity(
      id: 'port_louis',
      countryCode: 'MU',
      names: {'en': 'Port Louis', 'tr': 'Port Louis', 'fr': 'Port-Louis', 'de': 'Port Louis', 'es': 'Port Louis', 'it': 'Port Louis', 'ru': 'Порт-Луи', 'ar': 'بورت لويس', 'zh': '路易港', 'ja': 'ポートルイス', 'el': 'Πορ-Λουί', 'th': 'พอร์ตลูอิส', 'hi': 'पोर्ट लुई', 'ko': '포트루이스'},
    ),

    // ----------------------------------------------------
    // Caribbean & Central America (CU, DO, PR, CR, PA)
    // ----------------------------------------------------
    PopularCity(
      id: 'havana',
      countryCode: 'CU',
      names: {'en': 'Havana', 'tr': 'Havana', 'es': 'La Habana', 'de': 'Havanna', 'fr': 'La Havane', 'it': 'L’Avana', 'ru': 'Гавана', 'ar': 'هافانا', 'zh': '哈瓦那', 'ja': 'ハバナ', 'el': 'Αβάνα', 'th': 'อาบานา', 'hi': 'हवाना', 'ko': '아바나'},
    ),
    PopularCity(
      id: 'punta_cana',
      countryCode: 'DO',
      names: {'en': 'Punta Cana', 'tr': 'Punta Cana', 'es': 'Punta Cana', 'de': 'Punta Cana', 'fr': 'Punta Cana', 'ru': 'Пунта-Кана', 'ar': 'بونتا كانا', 'zh': '蓬塔卡纳', 'ja': 'プンタ・カナ', 'el': 'Πούντα Κάνα', 'th': 'ปุนตากานา', 'hi': 'पुंता काना', 'ko': '푼타카나'},
    ),
    PopularCity(
      id: 'santo_domingo',
      countryCode: 'DO',
      names: {'en': 'Santo Domingo', 'tr': 'Santo Domingo', 'es': 'Santo Domingo', 'de': 'Santo Domingo', 'fr': 'Saint-Domingue', 'ru': 'Санто-Доминго', 'ar': 'سانتو دومينغو', 'zh': '圣多明哥', 'ja': 'サント・ドミンゴ', 'el': 'Σάντο Ντομίγκο', 'th': 'ซานโตโดมิงโก', 'hi': 'सेंटो डोमिंगो', 'ko': '산토도밍고'},
    ),
    PopularCity(
      id: 'san_juan',
      countryCode: 'PR',
      names: {'en': 'San Juan', 'tr': 'San Juan', 'es': 'San Juan', 'de': 'San Juan', 'fr': 'San Juan', 'it': 'San Juan', 'ru': 'Сан-Хуан', 'ar': 'سان خوان', 'zh': '圣胡安', 'ja': 'サン・フアン', 'el': 'Σαν Χουάν', 'th': 'ซานฮวน', 'hi': 'सैन जुआन', 'ko': '산후안'},
    ),
    PopularCity(
      id: 'san_jose_cr',
      countryCode: 'CR',
      names: {'en': 'San Jose', 'tr': 'San Jose', 'es': 'San José', 'de': 'San José', 'fr': 'San José', 'it': 'San José', 'ru': 'Сан-Хосе', 'ar': 'سان خوسيه', 'zh': '圣何塞', 'ja': 'サンホセ', 'el': 'Σαν Χοσέ', 'th': 'ซานโฮเซ', 'hi': 'सान होज़े', 'ko': '산호세'},
    ),
    PopularCity(
      id: 'panama_city',
      countryCode: 'PA',
      names: {'en': 'Panama City', 'tr': 'Panama City', 'es': 'Ciudad de Panamá', 'de': 'Panama-Stadt', 'fr': 'Panama', 'it': 'Panamá', 'ru': 'Панама', 'ar': 'بنما', 'zh': '巴拿马城', 'ja': 'パナマ', 'el': 'Πόλη του Παναμά', 'th': 'ปานามาซิตี', 'hi': 'पनामा सिटी', 'ko': '파나마시티'},
    ),

    // ----------------------------------------------------
    // Microstates & Unique Destinations (MC, SM, VA, MT, AD, LI)
    // ----------------------------------------------------
    PopularCity(
      id: 'monaco',
      countryCode: 'MC',
      names: {'en': 'Monaco', 'tr': 'Monako', 'fr': 'Monaco', 'de': 'Monaco', 'es': 'Mónaco', 'it': 'Monaco', 'ru': 'Монако', 'ar': 'موناكو', 'zh': '摩纳哥', 'ja': 'モナコ', 'el': 'Μονακό', 'th': 'ประเทศโมนาโก', 'hi': 'मोनाको', 'ko': '모나코'},
    ),
    PopularCity(
      id: 'san_marino',
      countryCode: 'SM',
      names: {'en': 'San Marino', 'tr': 'San Marino', 'it': 'San Marino', 'de': 'San Marino', 'fr': 'Saint-Marin', 'es': 'San Marino', 'ru': 'Сан-Марино', 'ar': 'سان مارينو', 'zh': '圣马力诺', 'ja': 'サンマリノ', 'el': 'Άγιος Μαρίνος', 'th': 'ประเทศซานมารีโน', 'hi': 'सान मारिनो', 'ko': '산마리노'},
    ),
    PopularCity(
      id: 'vatican_city',
      countryCode: 'VA',
      names: {'en': 'Vatican City', 'tr': 'Vatikan', 'it': 'Città del Vaticano', 'de': 'Vatikanstadt', 'fr': 'Cité du Vatican', 'es': 'Ciudad del Vaticano', 'ru': 'Ватикан', 'ar': 'الفاتيكان', 'zh': '梵蒂冈', 'ja': 'バチカン', 'el': 'Βατικανό', 'th': 'นครรัฐวาติกัน', 'hi': 'वैटिकन नगर', 'ko': '바티칸 시국'},
    ),
    PopularCity(
      id: 'valletta',
      countryCode: 'MT',
      names: {'en': 'Valletta', 'tr': 'Valletta', 'mt': 'Valletta', 'de': 'Valletta', 'fr': 'La Valette', 'es': 'La Valeta', 'it': 'La Valletta', 'ru': 'Валлетта', 'ar': 'البلد', 'zh': '瓦莱塔', 'ja': 'バレッタ', 'el': 'Βαλέτα', 'th': 'วัลเลตตา', 'hi': 'वैलेटा', 'ko': '발레타'},
    ),
    PopularCity(
      id: 'andorra_la_vella',
      countryCode: 'AD',
      names: {'en': 'Andorra la Vella', 'tr': 'Andorra la Vella', 'ca': 'Andorra la Vella', 'es': 'Andorra la Vieja', 'fr': 'Andorre-la-Vieille', 'de': 'Andorra la Vella', 'ru': 'Андорра-ла-Велья', 'ar': 'أندورا لا فيلا', 'zh': '安道尔城', 'ja': 'アンドラ・ラ・ベリャ', 'el': 'Ανδόρρα λα Βέλια', 'th': 'อันดอร์ราลาเวยา', 'hi': 'अण्डोरा ला वेला', 'ko': '안도라라벨랴'},
    ),
    PopularCity(
      id: 'vaduz',
      countryCode: 'LI',
      names: {'en': 'Vaduz', 'tr': 'Vaduz', 'de': 'Vaduz', 'fr': 'Vaduz', 'es': 'Vaduz', 'it': 'Vaduz', 'ru': 'Вадуц', 'ar': 'فادوتس', 'zh': '瓦杜兹', 'ja': 'ファドゥーツ', 'el': 'Βαντούζ', 'th': 'วาดุซ', 'hi': 'वादुज़', 'ko': '파두츠'},
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
