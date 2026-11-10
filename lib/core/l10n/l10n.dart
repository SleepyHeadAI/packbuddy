import 'package:flutter/material.dart';

/// Localization helper and supported 20 languages for PackBuddy
class L10n {
  /// Default list of supported 20 languages in English alphabetical order
  static const List<Locale> all = [
    Locale('ar'),
    Locale('zh'),
    Locale('nl'),
    Locale('en'),
    Locale('fr'),
    Locale('de'),
    Locale('el'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('es'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
  ];

  /// Clean native endonym for each language
  static const Map<String, String> _nativeNames = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'pl': 'Polski',
    'id': 'Bahasa Indonesia',
    'vi': 'Tiếng Việt',
    'el': 'Ελληνικά',
    'ar': 'العربية',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'hi': 'हिन्दी',
    'th': 'ไทย',
  };

  /// Localized language names across all 20 supported languages
  static const Map<String, Map<String, String>> _localizedNames = {
    'en': {
      'ar': 'Arabic',
      'zh': 'Chinese',
      'nl': 'Dutch',
      'en': 'English',
      'fr': 'French',
      'de': 'German',
      'el': 'Greek',
      'hi': 'Hindi',
      'id': 'Indonesian',
      'it': 'Italian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'pl': 'Polish',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'es': 'Spanish',
      'sv': 'Swedish',
      'th': 'Thai',
      'tr': 'Turkish',
      'vi': 'Vietnamese',
    },
    'tr': {
      'de': 'Almanca',
      'ar': 'Arapça',
      'zh': 'Çince',
      'id': 'Endonezce',
      'nl': 'Felemenkçe',
      'fr': 'Fransızca',
      'hi': 'Hintçe',
      'en': 'İngilizce',
      'es': 'İspanyolca',
      'sv': 'İsveççe',
      'it': 'İtalyanca',
      'ja': 'Japonca',
      'ko': 'Korece',
      'pl': 'Lehçe',
      'pt': 'Portekizce',
      'ru': 'Rusça',
      'th': 'Tayca',
      'tr': 'Türkçe',
      'vi': 'Vietnamca',
      'el': 'Yunanca',
    },
    'de': {
      'ar': 'Arabisch',
      'zh': 'Chinesisch',
      'de': 'Deutsch',
      'en': 'Englisch',
      'fr': 'Französisch',
      'el': 'Griechisch',
      'hi': 'Hindi',
      'id': 'Indonesisch',
      'it': 'Italienisch',
      'ja': 'Japanisch',
      'ko': 'Koreanisch',
      'nl': 'Niederländisch',
      'pl': 'Polnisch',
      'pt': 'Portugiesisch',
      'ru': 'Russisch',
      'sv': 'Schwedisch',
      'es': 'Spanisch',
      'th': 'Thailändisch',
      'tr': 'Türkisch',
      'vi': 'Vietnamesisch',
    },
    'fr': {
      'de': 'Allemand',
      'en': 'Anglais',
      'ar': 'Arabe',
      'zh': 'Chinois',
      'ko': 'Coréen',
      'es': 'Espagnol',
      'fr': 'Français',
      'el': 'Grec',
      'hi': 'Hindi',
      'id': 'Indonésien',
      'it': 'Italien',
      'ja': 'Japonais',
      'nl': 'Néerlandais',
      'pl': 'Polonais',
      'pt': 'Portugais',
      'ru': 'Russe',
      'sv': 'Suédois',
      'th': 'Thaï',
      'tr': 'Turc',
      'vi': 'Vietnamien',
    },
    'es': {
      'de': 'Alemán',
      'ar': 'Árabe',
      'zh': 'Chino',
      'ko': 'Coreano',
      'es': 'Español',
      'fr': 'Francés',
      'el': 'Griego',
      'hi': 'Hindi',
      'id': 'Indonesio',
      'en': 'Inglés',
      'it': 'Italiano',
      'ja': 'Japonés',
      'nl': 'Neerlandés',
      'pl': 'Polaco',
      'pt': 'Portugués',
      'ru': 'Ruso',
      'sv': 'Sueco',
      'th': 'Tailandés',
      'tr': 'Turco',
      'vi': 'Vietnamita',
    },
    'it': {
      'ar': 'Arabo',
      'zh': 'Cinese',
      'ko': 'Coreano',
      'fr': 'Francese',
      'ja': 'Giapponese',
      'el': 'Greco',
      'hi': 'Hindi',
      'id': 'Indonesiano',
      'en': 'Inglese',
      'it': 'Italiano',
      'nl': 'Olandese',
      'pl': 'Polacco',
      'pt': 'Portoghese',
      'ru': 'Russo',
      'es': 'Spagnolo',
      'sv': 'Svedese',
      'de': 'Tedesco',
      'th': 'Tailandese',
      'tr': 'Turco',
      'vi': 'Vietnamita',
    },
    'pt': {
      'de': 'Alemão',
      'ar': 'Árabe',
      'zh': 'Chinês',
      'ko': 'Coreano',
      'es': 'Espanhol',
      'fr': 'Francês',
      'el': 'Grego',
      'hi': 'Hindi',
      'nl': 'Holandês',
      'id': 'Indonésio',
      'en': 'Inglês',
      'it': 'Italiano',
      'ja': 'Japonês',
      'pl': 'Polonês',
      'pt': 'Português',
      'ru': 'Russo',
      'sv': 'Sueco',
      'th': 'Tailandês',
      'tr': 'Turco',
      'vi': 'Vietnamita',
    },
    'ru': {
      'en': 'Английский',
      'ar': 'Арабский',
      'vi': 'Вьетнамский',
      'el': 'Греческий',
      'id': 'Индонезийский',
      'es': 'Испанский',
      'it': 'Итальянский',
      'zh': 'Китайский',
      'ko': 'Корейский',
      'de': 'Немецкий',
      'nl': 'Нидерландский',
      'pl': 'Польский',
      'pt': 'Португальский',
      'ru': 'Русский',
      'th': 'Тайский',
      'tr': 'Турецкий',
      'fr': 'Французский',
      'hi': 'Хинди',
      'sv': 'Шведский',
      'ja': 'Японский',
    },
    'nl': {
      'ar': 'Arabisch',
      'zh': 'Chinees',
      'de': 'Duits',
      'en': 'Engels',
      'fr': 'Frans',
      'el': 'Grieks',
      'hi': 'Hindi',
      'id': 'Indonesisch',
      'it': 'Italiaans',
      'ja': 'Japans',
      'ko': 'Koreaans',
      'nl': 'Nederlands',
      'pl': 'Pools',
      'pt': 'Portugees',
      'ru': 'Russisch',
      'es': 'Spaans',
      'th': 'Thais',
      'tr': 'Turks',
      'vi': 'Vietnamees',
      'sv': 'Zweeds',
    },
    'sv': {
      'ar': 'Arabiska',
      'en': 'Engelska',
      'fr': 'Franska',
      'el': 'Grekiska',
      'hi': 'Hindi',
      'id': 'Indonesiska',
      'it': 'Italienska',
      'ja': 'Japanska',
      'zh': 'Kinesiska',
      'ko': 'Koreanska',
      'nl': 'Nederländska',
      'pl': 'Polska',
      'pt': 'Portugisiska',
      'ru': 'Ryska',
      'es': 'Spanska',
      'sv': 'Svenska',
      'th': 'Thailändska',
      'tr': 'Turkiska',
      'de': 'Tyska',
      'vi': 'Vietnamesiska',
    },
    'pl': {
      'en': 'Angielski',
      'ar': 'Arabski',
      'zh': 'Chiński',
      'fr': 'Francuski',
      'el': 'Grecki',
      'es': 'Hiszpański',
      'hi': 'Hindi',
      'id': 'Indonezyjski',
      'ja': 'Japoński',
      'ko': 'Koreański',
      'nl': 'Niderlandzki',
      'de': 'Niemiecki',
      'pl': 'Polski',
      'pt': 'Portugalski',
      'ru': 'Rosyjski',
      'sv': 'Szwedzki',
      'th': 'Tajski',
      'tr': 'Turecki',
      'vi': 'Wietnamski',
      'it': 'Włoski',
    },
    'id': {
      'ar': 'Arab',
      'nl': 'Belanda',
      'hi': 'Hindi',
      'id': 'Indonesia',
      'en': 'Inggris',
      'it': 'Italia',
      'ja': 'Jepang',
      'de': 'Jerman',
      'ko': 'Korea',
      'zh': 'Mandarin',
      'pl': 'Polandia',
      'pt': 'Portugis',
      'fr': 'Prancis',
      'ru': 'Rusia',
      'es': 'Spanyol',
      'sv': 'Swedia',
      'th': 'Thailand',
      'tr': 'Turki',
      'vi': 'Vietnam',
      'el': 'Yunani',
    },
    'vi': {
      'ar': 'Tiếng Ả Rập',
      'en': 'Tiếng Anh',
      'pl': 'Tiếng Ba Lan',
      'pt': 'Tiếng Bồ Đào Nha',
      'de': 'Tiếng Đức',
      'nl': 'Tiếng Hà Lan',
      'ko': 'Tiếng Hàn',
      'hi': 'Tiếng Hindi',
      'el': 'Tiếng Hy Lạp',
      'id': 'Tiếng Indonesia',
      'ru': 'Tiếng Nga',
      'ja': 'Tiếng Nhật',
      'fr': 'Tiếng Pháp',
      'es': 'Tiếng Tây Ban Nha',
      'th': 'Tiếng Thái',
      'tr': 'Tiếng Thổ Nhĩ Kỳ',
      'sv': 'Tiếng Thụy Điển',
      'zh': 'Tiếng Trung',
      'vi': 'Tiếng Việt',
      'it': 'Tiếng Ý',
    },
    'el': {
      'en': 'Αγγλικά',
      'ar': 'Αραβικά',
      'vi': 'Βιετναμικά',
      'fr': 'Γαλλικά',
      'de': 'Γερμανικά',
      'el': 'Ελληνικά',
      'ja': 'Ιαπωνικά',
      'id': 'Ινδονησιακά',
      'es': 'Ισπανικά',
      'it': 'Ιταλικά',
      'zh': 'Κινεζικά',
      'ko': 'Κορεατικά',
      'nl': 'Ολλανδικά',
      'pl': 'Πολωνικά',
      'pt': 'Πορτογαλικά',
      'ru': 'Ρωσικά',
      'sv': 'Σουηδικά',
      'th': 'Ταϊλανδικά',
      'tr': 'Τουρκικά',
      'hi': 'Χίντι',
    },
    'ar': {
      'es': 'الإسبانية',
      'de': 'الألمانية',
      'en': 'الإنجليزية',
      'id': 'الإندونيسية',
      'it': 'الإيطالية',
      'pt': 'البرتغالية',
      'pl': 'البولندية',
      'th': 'التايلاندية',
      'tr': 'التركية',
      'ru': 'الروسية',
      'sv': 'السويدية',
      'zh': 'الصينية',
      'ar': 'العربية',
      'fr': 'الفرنسية',
      'vi': 'الفيتنامية',
      'ko': 'الكورية',
      'nl': 'الهولندية',
      'hi': 'الهندية',
      'ja': 'اليابانية',
      'el': 'اليونانية',
    },
    'zh': {
      'ar': '阿拉伯语',
      'pl': '波兰语',
      'de': '德语',
      'ru': '俄语',
      'fr': '法语',
      'ko': '韩语',
      'nl': '荷兰语',
      'pt': '葡萄牙语',
      'ja': '日语',
      'sv': '瑞典语',
      'th': '泰语',
      'tr': '土耳其语',
      'es': '西班牙语',
      'el': '希腊语',
      'it': '意大利语',
      'en': '英语',
      'hi': '印地语',
      'id': '印度尼西亚语',
      'vi': '越南语',
      'zh': '中文',
    },
    'ja': {
      'ar': 'アラビア語',
      'it': 'イタリア語',
      'id': 'インドネシア語',
      'en': '英語',
      'nl': 'オランダ語',
      'el': 'ギリシャ語',
      'sv': 'スウェーデン語',
      'es': 'スペイン語',
      'th': 'タイ語',
      'ko': '韓国語',
      'zh': '中国語',
      'de': 'ドイツ語',
      'tr': 'トルコ語',
      'ja': '日本語',
      'hi': 'ヒンディー語',
      'fr': 'フランス語',
      'vi': 'ベトナム語',
      'pl': 'ポーランド語',
      'pt': 'ポルトガル語',
      'ru': 'ロシア語',
    },
    'ko': {
      'el': '그리스어',
      'nl': '네덜란드어',
      'de': '독일어',
      'ru': '러시아어',
      'vi': '베트남어',
      'sv': '스웨덴어',
      'es': '스페인어',
      'ar': '아랍어',
      'en': '영어',
      'it': '이탈리아어',
      'id': '인도네시아어',
      'ja': '일본어',
      'zh': '중국어',
      'th': '태국어',
      'tr': '튀르키예어',
      'pt': '포르투갈어',
      'pl': '폴란드어',
      'fr': '프랑스어',
      'ko': '한국어',
      'hi': '힌디어',
    },
    'hi': {
      'en': 'अंग्रेज़ी',
      'ar': 'अरबी',
      'it': 'इतालवी',
      'id': 'इंडोनेशियाई',
      'ko': 'कोरियाई',
      'el': 'ग्रीक',
      'zh': 'चीनी',
      'de': 'जर्मन',
      'ja': 'जापानी',
      'nl': 'डच',
      'th': 'थाई',
      'tr': 'तुर्की',
      'pt': 'पुर्तगाली',
      'pl': 'पोलिश',
      'fr': 'फ़्रांसीसी',
      'vi': 'वियतनामी',
      'ru': 'रूसी',
      'es': 'स्पैनिश',
      'sv': 'स्वीडिश',
      'hi': 'हिन्दी',
    },
    'th': {
      'el': 'กรีก',
      'ko': 'เกาหลี',
      'zh': 'จีน',
      'ja': 'ญี่ปุ่น',
      'nl': 'ดัตช์',
      'tr': 'ตุรกี',
      'th': 'ไทย',
      'fr': 'ฝรั่งเศส',
      'de': 'เยอรมัน',
      'ru': 'รัสเซีย',
      'vi': 'เวียดนาม',
      'es': 'สเปน',
      'sv': 'สวีเดน',
      'en': 'อังกฤษ',
      'ar': 'อาหรับ',
      'it': 'อิตาลี',
      'id': 'อินโดนีเซีย',
      'hi': 'ฮินดี',
      'pl': 'โปแลนด์',
      'pt': 'โปรตุเกส',
    },
  };

  /// Exact alphabetical order of 20 language codes for each supported language
  static const Map<String, List<String>> _alphabeticalOrderPerLocale = {
    'en': [
      'ar', 'zh', 'nl', 'en', 'fr', 'de', 'el', 'hi', 'id', 'it',
      'ja', 'ko', 'pl', 'pt', 'ru', 'es', 'sv', 'th', 'tr', 'vi',
    ],
    'tr': [
      'de', 'ar', 'zh', 'id', 'nl', 'fr', 'hi', 'en', 'es', 'sv',
      'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 'el',
    ],
    'de': [
      'ar', 'zh', 'de', 'en', 'fr', 'el', 'hi', 'id', 'it', 'ja',
      'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'es', 'th', 'tr', 'vi',
    ],
    'fr': [
      'de', 'en', 'ar', 'zh', 'ko', 'es', 'fr', 'el', 'hi', 'id',
      'it', 'ja', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi',
    ],
    'es': [
      'de', 'ar', 'zh', 'ko', 'es', 'fr', 'el', 'hi', 'id', 'en',
      'it', 'ja', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi',
    ],
    'it': [
      'ar', 'zh', 'ko', 'fr', 'ja', 'el', 'hi', 'id', 'en', 'it',
      'nl', 'pl', 'pt', 'ru', 'es', 'sv', 'de', 'th', 'tr', 'vi',
    ],
    'pt': [
      'de', 'ar', 'zh', 'ko', 'es', 'fr', 'el', 'hi', 'nl', 'id',
      'en', 'it', 'ja', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi',
    ],
    'ru': [
      'en', 'ar', 'vi', 'el', 'id', 'es', 'it', 'zh', 'ko', 'de',
      'nl', 'pl', 'pt', 'ru', 'th', 'tr', 'fr', 'hi', 'sv', 'ja',
    ],
    'nl': [
      'ar', 'zh', 'de', 'en', 'fr', 'el', 'hi', 'id', 'it', 'ja',
      'ko', 'nl', 'pl', 'pt', 'ru', 'es', 'th', 'tr', 'vi', 'sv',
    ],
    'sv': [
      'ar', 'en', 'fr', 'el', 'hi', 'id', 'it', 'ja', 'zh', 'ko',
      'nl', 'pl', 'pt', 'ru', 'es', 'sv', 'th', 'tr', 'de', 'vi',
    ],
    'pl': [
      'en', 'ar', 'zh', 'fr', 'el', 'es', 'hi', 'id', 'ja', 'ko',
      'nl', 'de', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi', 'it',
    ],
    'id': [
      'ar', 'nl', 'hi', 'id', 'en', 'it', 'ja', 'de', 'ko', 'zh',
      'pl', 'pt', 'fr', 'ru', 'es', 'sv', 'th', 'tr', 'vi', 'el',
    ],
    'vi': [
      'ar', 'en', 'pl', 'pt', 'de', 'nl', 'ko', 'hi', 'el', 'id',
      'ru', 'ja', 'fr', 'es', 'th', 'tr', 'sv', 'zh', 'vi', 'it',
    ],
    'el': [
      'en', 'ar', 'vi', 'fr', 'de', 'el', 'ja', 'id', 'es', 'it',
      'zh', 'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'hi',
    ],
    'ar': [
      'es', 'de', 'en', 'id', 'it', 'pt', 'pl', 'th', 'tr', 'ru',
      'sv', 'zh', 'ar', 'fr', 'vi', 'ko', 'nl', 'hi', 'ja', 'el',
    ],
    'zh': [
      'ar', 'pl', 'de', 'ru', 'fr', 'ko', 'nl', 'pt', 'ja', 'sv',
      'th', 'tr', 'es', 'el', 'it', 'en', 'hi', 'id', 'vi', 'zh',
    ],
    'ja': [
      'ar', 'it', 'id', 'en', 'nl', 'el', 'sv', 'es', 'th', 'ko',
      'zh', 'de', 'tr', 'ja', 'hi', 'fr', 'vi', 'pl', 'pt', 'ru',
    ],
    'ko': [
      'el', 'nl', 'de', 'ru', 'vi', 'sv', 'es', 'ar', 'en', 'it',
      'id', 'ja', 'zh', 'th', 'tr', 'pt', 'pl', 'fr', 'ko', 'hi',
    ],
    'hi': [
      'en', 'ar', 'it', 'id', 'ko', 'el', 'zh', 'de', 'ja', 'nl',
      'th', 'tr', 'pt', 'pl', 'fr', 'vi', 'ru', 'es', 'sv', 'hi',
    ],
    'th': [
      'el', 'ko', 'zh', 'ja', 'nl', 'tr', 'th', 'fr', 'de', 'ru',
      'vi', 'es', 'sv', 'en', 'ar', 'it', 'id', 'hi', 'pl', 'pt',
    ],
  };

  /// Returns clean native name (e.g. 'English', 'Türkçe', 'Deutsch')
  static String getCleanNativeName(String code) {
    return _nativeNames[code] ?? code.toUpperCase();
  }

  /// Returns localized language name in [inLocale] (e.g. 'German' in 'en', 'Almanca' in 'tr')
  static String getLocalizedLanguageName(String code, String inLocale) {
    final map = _localizedNames[inLocale] ?? _localizedNames['en']!;
    return map[code] ?? _nativeNames[code] ?? code.toUpperCase();
  }

  /// Formatted language display name for selection menus:
  /// - If the localized name is the same as the native name (e.g. 'English' in en, 'Türkçe' in tr), returns just that.
  /// - Otherwise returns '$localized ($native)', e.g. 'German (Deutsch)' in en, 'Almanca (Deutsch)' in tr.
  static String getLanguageDisplayName(String code, String inLocale) {
    final localized = getLocalizedLanguageName(code, inLocale);
    final native = getCleanNativeName(code);

    if (localized.trim().toLowerCase() == native.trim().toLowerCase()) {
      return localized;
    }
    return '$localized ($native)';
  }

  /// Returns all 20 locales sorted in exact alphabetical order according to [inLocale]
  static List<Locale> getSortedLocales(String inLocale) {
    final order = _alphabeticalOrderPerLocale[inLocale] ?? _alphabeticalOrderPerLocale['en']!;
    return order.map((code) => Locale(code)).toList();
  }

  /// Human-readable native language name for UI pickers (backward compatibility)
  static String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文 (Chinese)';
      case 'ja':
        return '日本語 (Japanese)';
      case 'ko':
        return '한국어 (Korean)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'ar':
        return 'العربية (Arabic)';
      case 'nl':
        return 'Nederlands';
      case 'el':
        return 'Ελληνικά (Greek)';
      case 'sv':
        return 'Svenska';
      case 'pl':
        return 'Polski';
      case 'id':
        return 'Bahasa Indonesia';
      case 'th':
        return 'ไทย (Thai)';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return code.toUpperCase();
    }
  }

  /// Flag emoji or badge label for each language
  static String getLanguageFlag(String code) {
    switch (code) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇬🇧';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'ru':
        return '🇷🇺';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'hi':
        return '🇮🇳';
      case 'ar':
        return '🇸🇦';
      case 'nl':
        return '🇳🇱';
      case 'el':
        return '🇬🇷';
      case 'sv':
        return '🇸🇪';
      case 'pl':
        return '🇵🇱';
      case 'id':
        return '🇮🇩';
      case 'th':
        return '🇹🇭';
      case 'vi':
        return '🇻🇳';
      default:
        return '🌐';
    }
  }
}
