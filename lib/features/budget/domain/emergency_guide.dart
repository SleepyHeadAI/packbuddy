import 'country.dart';

/// Represents an essential phrase in local script with phonetic pronunciation
class LocalPhrase {
  final String key;
  final String phrase;
  final String pronunciation;
  final String meaningEn;

  const LocalPhrase({
    required this.key,
    required this.phrase,
    this.pronunciation = '',
    required this.meaningEn,
  });
}

/// Offline emergency numbers, power plug standards, and essential local phrases
class EmergencyGuide {
  final String countryCode;
  final String countryName;
  final String police;
  final String ambulance;
  final String fire;
  final String generalSos;
  final String powerPlugs;
  final List<LocalPhrase> phrases;

  const EmergencyGuide({
    required this.countryCode,
    required this.countryName,
    required this.police,
    required this.ambulance,
    required this.fire,
    required this.generalSos,
    required this.powerPlugs,
    required this.phrases,
  });

  /// Resolves the emergency guide for a given country code or destination name.
  /// Always returns a valid guide with smart fallback.
  static EmergencyGuide forCountry(String? countryCode, [String? destination]) {
    final code = countryCode?.trim().toUpperCase();
    if (code != null && _guides.containsKey(code)) {
      return _guides[code]!;
    }

    // Try finding by destination name in Country list
    if (destination != null && destination.trim().isNotEmpty) {
      final destLower = destination.trim().toLowerCase();
      for (final c in Country.allCountries) {
        if (destLower.contains(c.name.toLowerCase()) ||
            destLower.contains(c.localName.toLowerCase()) ||
            c.popularDestinations.any((p) => destLower.contains(p.toLowerCase()))) {
          if (_guides.containsKey(c.code)) {
            return _guides[c.code]!;
          }
          return _generateRegionalFallback(c.code, c.name);
        }
      }
    }

    if (code != null && code.isNotEmpty) {
      final match = Country.allCountries.where((c) => c.code == code).firstOrNull;
      return _generateRegionalFallback(code, match?.name ?? code);
    }

    return _defaultInternationalGuide;
  }

  static EmergencyGuide _generateRegionalFallback(String code, String name) {
    // European standard
    const euCodes = {
      'FR', 'IT', 'ES', 'PT', 'NL', 'BE', 'AT', 'CH', 'SE', 'NO', 'DK', 'FI',
      'PL', 'CZ', 'SK', 'HU', 'RO', 'BG', 'HR', 'GR', 'IE', 'IS', 'EE', 'LV', 'LT'
    };
    if (euCodes.contains(code)) {
      return EmergencyGuide(
        countryCode: code,
        countryName: name,
        police: '112',
        ambulance: '112',
        fire: '112',
        generalSos: '112',
        powerPlugs: 'Type C / F (230V, 50Hz)',
        phrases: _englishPhrases,
      );
    }

    // Americas
    const americasCodes = {
      'MX', 'BR', 'AR', 'CL', 'CO', 'PE', 'PA', 'CR', 'UY', 'EC'
    };
    if (americasCodes.contains(code)) {
      return EmergencyGuide(
        countryCode: code,
        countryName: name,
        police: '911',
        ambulance: '911',
        fire: '911',
        generalSos: '911',
        powerPlugs: 'Type A / B / C (110-220V, 60Hz)',
        phrases: _spanishPhrases,
      );
    }

    return EmergencyGuide(
      countryCode: code,
      countryName: name,
      police: '112 / 911',
      ambulance: '112 / 911',
      fire: '112 / 911',
      generalSos: '112',
      powerPlugs: 'Type C / G / A (110-240V, 50/60Hz)',
      phrases: _englishPhrases,
    );
  }

  static const EmergencyGuide _defaultInternationalGuide = EmergencyGuide(
    countryCode: 'INTL',
    countryName: 'International',
    police: '112 / 911',
    ambulance: '112 / 911',
    fire: '112 / 911',
    generalSos: '112',
    powerPlugs: 'Universal Adapter Recommended (100-240V)',
    phrases: _englishPhrases,
  );

  static const List<LocalPhrase> _englishPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'Hello', pronunciation: 'heh-LOH', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'Thank you', pronunciation: 'THANK-yoo', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'How much is this?', pronunciation: 'HOW much iz this', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: 'Help! Emergency!', pronunciation: 'HELP eh-MUR-juhn-see', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: 'Where is the hospital?', pronunciation: 'WAIR iz the HOS-pi-tul', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: 'Do you speak English?', pronunciation: 'DOO yoo speek ING-glish', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _turkishPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'Merhaba', pronunciation: 'mehr-hah-BAH', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'Teşekkürler', pronunciation: 'teh-shek-kyur-LER', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'Bu ne kadar?', pronunciation: 'boo neh kah-DAR', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: 'İmdat! Acil durum!', pronunciation: 'eem-DAHT ah-jeel doo-ROOM', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: 'Hastane nerede?', pronunciation: 'hahs-tah-NEH neh-reh-deh', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: 'İngilizce biliyor musunuz?', pronunciation: 'een-gee-leez-JEH bee-lee-YOR moo-soo-nooz', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _germanPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'Hallo / Guten Tag', pronunciation: 'hah-LOH / GOO-ten tahk', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'Danke schön', pronunciation: 'DAHN-kuh shurn', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'Wie viel kostet das?', pronunciation: 'vee feel KOS-tet dahs', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: 'Hilfe! Notfall!', pronunciation: 'HIL-fuh / NOT-fahl', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: 'Wo ist das Krankenhaus?', pronunciation: 'vo ist dahs KRAHN-ken-hows', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: 'Sprechen Sie Englisch?', pronunciation: 'SHPREH-khen zee ENG-lish', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _frenchPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'Bonjour', pronunciation: 'bohn-ZHOOR', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'Merci beaucoup', pronunciation: 'mair-SEE boh-KOO', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'C\'est combien ?', pronunciation: 'say kohm-BYEN', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: 'Au secours ! Urgence !', pronunciation: 'oh suh-KOOR / oor-ZHAHNS', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: 'Où est l\'hôpital ?', pronunciation: 'oo ay loh-pee-TAHL', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: 'Parlez-vous anglais ?', pronunciation: 'par-lay voo ahn-GLAY', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _spanishPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'Hola', pronunciation: 'OH-lah', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'Muchas gracias', pronunciation: 'MOO-chahs GRAH-syahs', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: '¿Cuánto cuesta esto?', pronunciation: 'KWAHN-toh KWEHS-tah EHS-toh', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: '¡Ayuda! ¡Emergencia!', pronunciation: 'ah-YOO-dah / eh-mair-HEN-syah', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: '¿Dónde está el hospital?', pronunciation: 'DON-deh ehs-TAH el ohs-pee-TAHL', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: '¿Habla inglés?', pronunciation: 'AH-blah een-GLEHS', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _italianPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'Ciao / Buongiorno', pronunciation: 'CHOW / bwon-JOHR-noh', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'Grazie mille', pronunciation: 'GRAHT-syeh MEEL-leh', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'Quanto costa questo?', pronunciation: 'KWAHN-toh KOS-tah KWEHS-toh', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: 'Aiuto! Emergenza!', pronunciation: 'ah-YOO-toh / eh-mair-JEN-tsah', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: 'Dov\'è l\'ospedale?', pronunciation: 'doh-VEH lohs-peh-DAH-leh', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: 'Parla inglese?', pronunciation: 'PAR-lah een-GLEH-zeh', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _japanesePhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'こんにちは (Konnichiwa)', pronunciation: 'kohn-nee-chee-wah', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'ありがとうございます (Arigatou gozaimasu)', pronunciation: 'ah-ree-GAH-toh goh-zye-mahs', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'いくらですか？ (Ikura desu ka?)', pronunciation: 'ee-koo-rah dess kah', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: '助けて！ 緊急です！ (Tasukete! Kinkyuu desu!)', pronunciation: 'tah-soo-KEH-teh keen-kyoo dess', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: '病院はどこですか？ (Byouin wa doko desu ka?)', pronunciation: 'byoh-een wah doh-koh dess kah', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: '英語を話せますか？ (Eigo o hanasemasu ka?)', pronunciation: 'ay-goh oh hah-nah-seh-mahs kah', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _koreanPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: '안녕하세요 (Annyeonghaseyo)', pronunciation: 'ahn-nyong-hah-seh-yoh', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: '감사합니다 (Gamsahamnida)', pronunciation: 'gahm-sah-hahm-nee-dah', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: '얼마예요? (Eolmayeyo?)', pronunciation: 'uhl-mah-yay-yoh', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: '도와주세요! 응급상황입니다! (Dowajuseyo! Eunggeup sanghwang-imnida!)', pronunciation: 'doh-wah-joo-seh-yoh oong-geup', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: '병원이 어디에 있나요? (Byeong-won-i eodie innayo?)', pronunciation: 'byong-won-ee uh-dee-eh een-nah-yoh', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: '영어 할 수 있으세요? (Yeong-eo hal su isseuseyo?)', pronunciation: 'yong-uh hahl soo ees-sooh-seh-yoh', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _chinesePhrases = [
    LocalPhrase(key: 'phraseHello', phrase: '你好 (Nǐ hǎo)', pronunciation: 'nee how', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: '谢谢 (Xièxiè)', pronunciation: 'shyeh-shyeh', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: '这个多少钱？ (Zhège duōshǎo qián?)', pronunciation: 'juh-guh dwoh-shaow chyen', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: '救命！ 紧急情况！ (Jiùmìng! Jǐnjí qíngkuàng!)', pronunciation: 'jyoh-meeng jeen-jee cheeng-kwahng', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: '医院在哪里？ (Yīyuàn zài nǎlǐ?)', pronunciation: 'ee-yoo-en dzye nah-lee', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: '你会说英语吗？ (Nǐ huì shuō yīngyǔ ma?)', pronunciation: 'nee hway shwoh yeeng-yoo mah', meaningEn: 'Do you speak English?'),
  ];

  static const List<LocalPhrase> _arabicPhrases = [
    LocalPhrase(key: 'phraseHello', phrase: 'مرحباً (Marhaban)', pronunciation: 'mar-hah-bahn', meaningEn: 'Hello'),
    LocalPhrase(key: 'phraseThankYou', phrase: 'شكراً جزيلاً (Shukran jazeelan)', pronunciation: 'shook-rahn jah-zee-lahn', meaningEn: 'Thank you'),
    LocalPhrase(key: 'phraseHowMuch', phrase: 'بكم هذا؟ (Bikam hatha?)', pronunciation: 'bee-kahm HAH-thah', meaningEn: 'How much is this?'),
    LocalPhrase(key: 'phraseHelp', phrase: 'النجدة! طوارئ! (Al-najdah! Tawari\'!)', pronunciation: 'ahn-nahj-dah tah-wah-ree', meaningEn: 'Help / Emergency'),
    LocalPhrase(key: 'phraseHospital', phrase: 'أين أقرب مستشفى؟ (Ayna aqrab mustashfa?)', pronunciation: 'AY-nah AHK-rahb moos-TASH-fah', meaningEn: 'Where is the hospital?'),
    LocalPhrase(key: 'phraseEnglish', phrase: 'هل تتحدث الإنجليزية؟ (Hal tatakallam al-ingliziyya?)', pronunciation: 'hahl tah-tah-kah-lahm ahl-eeng-lee-ZEE-yah', meaningEn: 'Do you speak English?'),
  ];

  static final Map<String, EmergencyGuide> _guides = {
    // Turkey & KKTC
    'TR': const EmergencyGuide(
      countryCode: 'TR',
      countryName: 'Turkey',
      police: '112',
      ambulance: '112',
      fire: '112',
      generalSos: '112',
      powerPlugs: 'Type C / F (230V, 50Hz)',
      phrases: _turkishPhrases,
    ),
    'NC': const EmergencyGuide(
      countryCode: 'NC',
      countryName: 'Northern Cyprus',
      police: '155',
      ambulance: '112',
      fire: '199',
      generalSos: '112',
      powerPlugs: 'Type G (240V, 50Hz)',
      phrases: _turkishPhrases,
    ),

    // United States
    'US': const EmergencyGuide(
      countryCode: 'US',
      countryName: 'United States',
      police: '911',
      ambulance: '911',
      fire: '911',
      generalSos: '911',
      powerPlugs: 'Type A / B (120V, 60Hz)',
      phrases: _englishPhrases,
    ),

    // United Kingdom
    'GB': const EmergencyGuide(
      countryCode: 'GB',
      countryName: 'United Kingdom',
      police: '999',
      ambulance: '999',
      fire: '999',
      generalSos: '999 / 112',
      powerPlugs: 'Type G (230V, 50Hz)',
      phrases: _englishPhrases,
    ),
    'UK': const EmergencyGuide(
      countryCode: 'UK',
      countryName: 'United Kingdom',
      police: '999',
      ambulance: '999',
      fire: '999',
      generalSos: '999 / 112',
      powerPlugs: 'Type G (230V, 50Hz)',
      phrases: _englishPhrases,
    ),

    // Germany
    'DE': const EmergencyGuide(
      countryCode: 'DE',
      countryName: 'Germany',
      police: '110',
      ambulance: '112',
      fire: '112',
      generalSos: '112',
      powerPlugs: 'Type C / F (230V, 50Hz)',
      phrases: _germanPhrases,
    ),

    // France
    'FR': const EmergencyGuide(
      countryCode: 'FR',
      countryName: 'France',
      police: '17',
      ambulance: '15',
      fire: '18',
      generalSos: '112',
      powerPlugs: 'Type C / E (230V, 50Hz)',
      phrases: _frenchPhrases,
    ),

    // Italy
    'IT': const EmergencyGuide(
      countryCode: 'IT',
      countryName: 'Italy',
      police: '112 / 113',
      ambulance: '118',
      fire: '115',
      generalSos: '112',
      powerPlugs: 'Type C / F / L (230V, 50Hz)',
      phrases: _italianPhrases,
    ),

    // Spain
    'ES': const EmergencyGuide(
      countryCode: 'ES',
      countryName: 'Spain',
      police: '091 / 092',
      ambulance: '061',
      fire: '080',
      generalSos: '112',
      powerPlugs: 'Type C / F (230V, 50Hz)',
      phrases: _spanishPhrases,
    ),

    // Japan
    'JP': const EmergencyGuide(
      countryCode: 'JP',
      countryName: 'Japan',
      police: '110',
      ambulance: '119',
      fire: '119',
      generalSos: '110 / 119',
      powerPlugs: 'Type A / B (100V, 50/60Hz)',
      phrases: _japanesePhrases,
    ),

    // South Korea
    'KR': const EmergencyGuide(
      countryCode: 'KR',
      countryName: 'South Korea',
      police: '112',
      ambulance: '119',
      fire: '119',
      generalSos: '112 / 119',
      powerPlugs: 'Type C / F (220V, 60Hz)',
      phrases: _koreanPhrases,
    ),

    // China
    'CN': const EmergencyGuide(
      countryCode: 'CN',
      countryName: 'China',
      police: '110',
      ambulance: '120',
      fire: '119',
      generalSos: '110',
      powerPlugs: 'Type A / C / I (220V, 50Hz)',
      phrases: _chinesePhrases,
    ),

    // United Arab Emirates
    'AE': const EmergencyGuide(
      countryCode: 'AE',
      countryName: 'United Arab Emirates',
      police: '999',
      ambulance: '998',
      fire: '997',
      generalSos: '999',
      powerPlugs: 'Type G (230V, 50Hz)',
      phrases: _arabicPhrases,
    ),

    // Saudi Arabia
    'SA': const EmergencyGuide(
      countryCode: 'SA',
      countryName: 'Saudi Arabia',
      police: '999',
      ambulance: '997',
      fire: '998',
      generalSos: '911 / 999',
      powerPlugs: 'Type G (230V, 60Hz)',
      phrases: _arabicPhrases,
    ),

    // Canada
    'CA': const EmergencyGuide(
      countryCode: 'CA',
      countryName: 'Canada',
      police: '911',
      ambulance: '911',
      fire: '911',
      generalSos: '911',
      powerPlugs: 'Type A / B (120V, 60Hz)',
      phrases: _englishPhrases,
    ),

    // Australia
    'AU': const EmergencyGuide(
      countryCode: 'AU',
      countryName: 'Australia',
      police: '000',
      ambulance: '000',
      fire: '000',
      generalSos: '000 / 112',
      powerPlugs: 'Type I (230V, 50Hz)',
      phrases: _englishPhrases,
    ),

    // Greece
    'GR': const EmergencyGuide(
      countryCode: 'GR',
      countryName: 'Greece',
      police: '100',
      ambulance: '166',
      fire: '199',
      generalSos: '112',
      powerPlugs: 'Type C / F (230V, 50Hz)',
      phrases: [
        LocalPhrase(key: 'phraseHello', phrase: 'Γειά σας (Geia sas)', pronunciation: 'YAH sahs', meaningEn: 'Hello'),
        LocalPhrase(key: 'phraseThankYou', phrase: 'Ευχαριστώ (Efcharisto)', pronunciation: 'ef-hah-rees-TOH', meaningEn: 'Thank you'),
        LocalPhrase(key: 'phraseHowMuch', phrase: 'Πόσο κάνει αυτό; (Poso kani afto?)', pronunciation: 'POH-soh KAH-nee ahf-TOH', meaningEn: 'How much is this?'),
        LocalPhrase(key: 'phraseHelp', phrase: 'Βοήθεια! Έκτακτη ανάγκη! (Voithia! Ektakti anagki!)', pronunciation: 'voy-THEE-ah EK-tahk-tee ah-NAHNG-kee', meaningEn: 'Help / Emergency'),
        LocalPhrase(key: 'phraseHospital', phrase: 'Πού είναι το νοσοκομείο; (Pou ine to nosokomio?)', pronunciation: 'POO EE-neh toh noh-soh-koh-MEE-oh', meaningEn: 'Where is the hospital?'),
        LocalPhrase(key: 'phraseEnglish', phrase: 'Μιλάτε αγγλικά; (Milate agglika?)', pronunciation: 'mee-LAH-teh ahng-glee-KAH', meaningEn: 'Do you speak English?'),
      ],
    ),

    // Netherlands
    'NL': const EmergencyGuide(
      countryCode: 'NL',
      countryName: 'Netherlands',
      police: '112',
      ambulance: '112',
      fire: '112',
      generalSos: '112',
      powerPlugs: 'Type C / F (230V, 50Hz)',
      phrases: [
        LocalPhrase(key: 'phraseHello', phrase: 'Hallo / Goedendag', pronunciation: 'HAH-loh / khoo-yuhn-DAHKH', meaningEn: 'Hello'),
        LocalPhrase(key: 'phraseThankYou', phrase: 'Dank u wel', pronunciation: 'DAHNK oo vel', meaningEn: 'Thank you'),
        LocalPhrase(key: 'phraseHowMuch', phrase: 'Hoeveel kost dit?', pronunciation: 'hoo-VEEL kohst dit', meaningEn: 'How much is this?'),
        LocalPhrase(key: 'phraseHelp', phrase: 'Help! Noodgeval!', pronunciation: 'HELP / NOHT-khuh-vahl', meaningEn: 'Help / Emergency'),
        LocalPhrase(key: 'phraseHospital', phrase: 'Waar is het ziekenhuis?', pronunciation: 'VAHR is het ZEE-kuhn-hoys', meaningEn: 'Where is the hospital?'),
        LocalPhrase(key: 'phraseEnglish', phrase: 'Spreekt u Engels?', pronunciation: 'SPRAYKT oo ENG-uhls', meaningEn: 'Do you speak English?'),
      ],
    ),
  };
}

