/// Canonical Packing Catalog providing deterministic identifiers, keyword recognition,
/// and dynamic multi-language translation for default and template packing items.
class CanonicalPackingCatalog {
  CanonicalPackingCatalog._();

  /// Normalizes a string by converting to lowercase, replacing accented / Turkish
  /// characters, and removing non-alphanumeric punctuation.
  static String normalize(String input) {
    var s = input.trim().toLowerCase();
    const replacements = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'i̇': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
      'ä': 'a',
      'ë': 'e',
      'ï': 'i',
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ñ': 'n',
      'ß': 'ss',
    };
    replacements.forEach((key, val) {
      s = s.replaceAll(key, val);
    });
    return s.replaceAll(RegExp(r'[^a-z0-9]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Generates a strictly deterministic ID for a seeded default item or template item.
  /// Prevents duplicate row generation across reloads and sync operations.
  static String generateDeterministicId({
    required String prefix,
    String? userId,
    required String canonicalKey,
    String? tripId,
  }) {
    final effectiveUser = (userId != null && userId.isNotEmpty) ? userId : 'local';
    final effectiveTrip = (tripId != null && tripId.isNotEmpty) ? '_$tripId' : '';
    return '${prefix}_$effectiveUser${effectiveTrip}_$canonicalKey';
  }

  /// Resolves canonical key by fuzzy keyword matching against stored names in any language
  static String? resolveCanonicalKey(String storedName) {
    final n = normalize(storedName);
    if (n.isEmpty) return null;

    // Passport & Travel documents
    if (n.contains('pasaport') || n.contains('passport') || (n.contains('vize') && n.contains('bilet')) || n.contains('reisepass')) {
      return 'passport';
    }
    // Noise-cancelling headphones
    if (n.contains('kulaklik') || n.contains('headphone') || n.contains('kopfhorer') || n.contains('casque') || n.contains('auricolari')) {
      return 'headphones';
    }
    // Raincoat
    if (n.contains('yagmurluk') || n.contains('raincoat') || n.contains('regenjacke') || n.contains('impermeable')) {
      return 'raincoat';
    }
    // Universal Charger / Adapter
    if (n.contains('priz') || (n.contains('sarj') && n.contains('cihazi')) || (n.contains('travel') && n.contains('adapter')) || n.contains('reiseadapter')) {
      return 'charger';
    }
    // Fast charger / cable
    if (n.contains('hizli sarj') || (n.contains('sarj') && n.contains('kablosu')) || n.contains('phone cable')) {
      return 'phone_cable';
    }
    // Laptop charger
    if (n.contains('dizustu') || n.contains('laptop') || n.contains('notebook charger')) {
      return 'laptop_charger';
    }
    // Powerbank
    if (n.contains('powerbank') || n.contains('tasinabilir sarj') || n.contains('batterie externe')) {
      return 'powerbank';
    }
    // Toiletry kit
    if (n.contains('kisisel bakim') || n.contains('kozmetik cantasi') || n.contains('toiletry') || n.contains('kulturbeutel') || n.contains('trousse de toilette')) {
      return 'toiletries';
    }
    // Toothbrush
    if (n.contains('dis fircasi') || n.contains('toothbrush') || n.contains('zahnbuerste') || n.contains('brosse a dents')) {
      return 'toothbrush';
    }
    // Walking shoes / sneakers
    if (n.contains('konforlu yuruyus') || n.contains('walking shoes') || n.contains('sneaker') || n.contains('turnschuhe')) {
      return 'walking_shoes';
    }
    // Thermal underwear / base layer
    if (n.contains('termal iclik') || n.contains('thermal underwear') || n.contains('skiunterwaesche') || n.contains('sous vetement thermique')) {
      return 'thermal_underwear';
    }
    // Swimwear
    if (n.contains('mayo') || n.contains('swimwear') || n.contains('swimsuit') || n.contains('badehose') || n.contains('maillot')) {
      return 'swimwear';
    }
    // Linen shirts
    if (n.contains('keten gomlek') || n.contains('linen shirt') || n.contains('leinenhemd')) {
      return 'linen_shirt';
    }
    // Shorts
    if (n.contains('sort') || n.contains('shorts')) {
      return 'shorts';
    }
    // Underwear & socks
    if (n.contains('ic camadiri') || n.contains('ic camagiri') || n.contains('ic camasiri') || (n.contains('underwear') && n.contains('socks')) || n.contains('unterwaesche')) {
      return 'underwear_socks';
    }
    // Beach slippers
    if (n.contains('terlik') || n.contains('slipper') || n.contains('flip flop') || n.contains('badelatschen')) {
      return 'beach_slippers';
    }
    // Sunscreen
    if (n.contains('gunes kremi') || n.contains('sunscreen') || n.contains('sonnencreme') || n.contains('creme solaire')) {
      return 'sunscreen';
    }
    // Aloe vera
    if (n.contains('aloe vera') || n.contains('gunes sonrasi') || n.contains('after sun')) {
      return 'aloe_vera';
    }
    // Beach towel
    if (n.contains('plaj havlusu') || n.contains('beach towel') || n.contains('strandtuch')) {
      return 'beach_towel';
    }
    // Sunglasses
    if (n.contains('gunes gozlugu') || n.contains('sunglasses') || n.contains('sonnenbrille') || n.contains('lunettes de soleil')) {
      return 'sunglasses';
    }
    // Sun hat
    if (n.contains('gunes sapkasi') || n.contains('sun hat') || n.contains('sonnenhut')) {
      return 'sun_hat';
    }
    // Waterproof pouch
    if (n.contains('su gecirmez kilif') || n.contains('waterproof') && (n.contains('case') || n.contains('pouch'))) {
      return 'waterproof_case';
    }
    // Ski jacket / parka
    if (n.contains('mont') || n.contains('parka') || n.contains('ski jacket') || n.contains('skijacke') || n.contains('anorak')) {
      return 'ski_jacket';
    }
    // Ski pants
    if (n.contains('kayak pantolonu') || n.contains('kar pantolonu') || n.contains('ski pants') || n.contains('skihose')) {
      return 'ski_pants';
    }
    // Sweaters / Fleece
    if (n.contains('kazak') || n.contains('sweatshirt') || n.contains('pullover') || n.contains('fleece')) {
      return 'sweater';
    }
    // Thermal socks
    if (n.contains('termal') && n.contains('corap') || n.contains('thermal socks') || n.contains('thermosocken')) {
      return 'thermal_socks';
    }
    // Snow / winter boots
    if (n.contains('kar ayakkabisi') || n.contains('kislik bot') || n.contains('snow boots') || n.contains('winterstiefel')) {
      return 'snow_boots';
    }
    // Beanie & scarf
    if (n.contains('bere') || n.contains('boyunluk') || n.contains('atki') || n.contains('beanie') || n.contains('scarf') || n.contains('muetze')) {
      return 'beanie_scarf';
    }
    // Ski gloves
    if (n.contains('eldiven') || n.contains('ski gloves') || n.contains('handschuhe') || n.contains('gants de ski')) {
      return 'ski_gloves';
    }
    // Hand cream & lip balm
    if (n.contains('el kremi') || n.contains('dudak') || n.contains('lip balm') || n.contains('lippenbalsam')) {
      return 'lip_balm';
    }
    // Ski goggles
    if (n.contains('kayak gozlugu') || n.contains('ski goggles') || n.contains('skibrille')) {
      return 'ski_goggles';
    }
    // Thermos
    if (n.contains('matara') || n.contains('termos') || n.contains('thermos') || n.contains('flask')) {
      return 'thermos';
    }
    // Suit / Blazer
    if (n.contains('takim elbise') || n.contains('blazer') || n.contains('suit') || n.contains('anzug') || n.contains('costume')) {
      return 'suit';
    }
    // Dress shirt
    if (n.contains('utulu gomlek') || n.contains('bluz') || n.contains('dress shirt') || n.contains('hemd')) {
      return 'dress_shirt';
    }
    // Chino / dress pants
    if (n.contains('chino') || n.contains('kumas pantolon') || n.contains('dress pants') || n.contains('stoffhose')) {
      return 'chino_pants';
    }
    // Business shoes
    if (n.contains('is ayakkabisi') || n.contains('klasik ayakkabi') || n.contains('business shoes') || n.contains('anzugschuhe')) {
      return 'business_shoes';
    }
    // Wireless mouse
    if (n.contains('mouse') || n.contains('kumanda') || n.contains('presenter')) {
      return 'wireless_mouse';
    }
    // Business cards
    if (n.contains('kartvizit') || n.contains('not defteri') || n.contains('business card')) {
      return 'business_cards';
    }
    // Travel tickets
    if (n.contains('biletleri') || n.contains('rezervasyon') || (n.contains('tickets') && n.contains('hotel'))) {
      return 'travel_tickets';
    }
    // Perfume / Deodorant
    if (n.contains('parfum') || n.contains('deodorant') || n.contains('perfume')) {
      return 'perfume_deodorant';
    }
    // Shaving kit
    if (n.contains('tiras') || n.contains('shaving') || n.contains('rasier')) {
      return 'shaving_kit';
    }
    // Trekking pants
    if (n.contains('trekking pantolonu') || n.contains('hiking pants') || n.contains('trekkinghose')) {
      return 'trekking_pants';
    }
    // Trekking boots
    if (n.contains('trekking botu') || n.contains('hiking boots') || n.contains('wanderschuhe')) {
      return 'trekking_boots';
    }
    // Tent
    if (n.contains('cadir') || n.contains('tent') || n.contains('zelt') || n.contains('tente')) {
      return 'tent';
    }
    // Sleeping bag
    if (n.contains('uyku tulumu') || n.contains('sleeping bag') || n.contains('schlafsack')) {
      return 'sleeping_bag';
    }
    // Headlamp
    if (n.contains('kafa feneri') || n.contains('headlamp') || n.contains('stirnlampe')) {
      return 'headlamp';
    }
    // Pocket knife
    if (n.contains('caki') || n.contains('pensesi') || n.contains('pocket knife') || n.contains('taschenmesser')) {
      return 'pocket_knife';
    }
    // First aid kit
    if (n.contains('ilk yardim') || n.contains('first aid') || n.contains('erste hilfe') || n.contains('premiers secours')) {
      return 'first_aid';
    }
    // Insect spray
    if (n.contains('hasere') || n.contains('sinek') || n.contains('insect') || n.contains('repellent') || n.contains('mueckenspray')) {
      return 'insect_spray';
    }
    // Water filter bottle
    if (n.contains('su aritma') || n.contains('water filter') || n.contains('purification')) {
      return 'water_filter';
    }
    // Jeans & Joggers
    if (n.contains('kot pantolon') || n.contains('esofman') || n.contains('jeans') || n.contains('jogger')) {
      return 'jeans_joggers';
    }
    // Casual t-shirts
    if (n.contains('tisort') || n.contains('t shirt')) {
      return 'casual_tshirts';
    }
    // Umbrella
    if (n.contains('semsiye') || n.contains('umbrella') || n.contains('regenschirm') || n.contains('parapluie')) {
      return 'umbrella';
    }
    // Transit & ID cards
    if (n.contains('kimlik') || n.contains('ulasim kart') || n.contains('transit cards')) {
      return 'id_cards';
    }

    return null;
  }

  /// Master translations catalog for all canonical keys across 20 languages
  static const Map<String, Map<String, String>> _translations = {
    'passport': {
      'en': 'Passport, Visa & Flight Tickets',
      'tr': 'Pasaport, Vize & Uçuş Biletleri',
      'de': 'Reisepass, Visum & Flugtickets',
      'es': 'Pasaporte, Visado y Billetes de Avión',
      'fr': 'Passeport, Visa et Billets d\'avion',
      'it': 'Passaporto, Visto e Biglietti Aerei',
      'pt': 'Passaporte, Visto e Passagens Aéreas',
      'ru': 'Паспорт, виза и авиабилеты',
      'zh': '护照、签证与机票',
      'ja': 'パスポート、ビザ、航空券',
      'ko': '여권, 비자 및 항공권',
      'hi': 'पासपोर्ट, वीजा और उड़ान टिकट',
      'ar': 'جواز السفر والتأشيرة وتذاكر الطيران',
      'nl': 'Paspoort, visum & vliegtickets',
      'el': 'Διαβατήριο, Βίζα & Αεροπορικά Εισιτήρια',
      'sv': 'Pass, visum & flygbiljetter',
      'pl': 'Paszport, wiza i bilety lotnicze',
      'id': 'Paspor, Visa & Tiket Pesawat',
      'th': 'หนังสือเดินทาง วีซ่า และตั๋วเครื่องบิน',
      'vi': 'Hộ chiếu, thị thực & vé máy bay',
    },
    'headphones': {
      'en': 'Noise-Cancelling Headphones & Case',
      'tr': 'Gürültü Engelleyici Kulaklık & Kılıfı',
      'de': 'Noise-Cancelling-Kopfhörer & Etui',
      'es': 'Auriculares con Cancelación de Ruido y Estuche',
      'fr': 'Casque à Réduction de Bruit et Étui',
      'it': 'Cuffie con Cancellazione del Rumore e Custodia',
      'pt': 'Fones com Cancelamento de Ruído e Estojo',
      'ru': 'Наушники с шумоподавлением и чехол',
      'zh': '降噪耳机及保护收纳盒',
      'ja': 'ノイズキャンセリングヘッドホン＆ケース',
      'ko': '노이즈 캔슬링 헤드폰 및 케이스',
      'hi': 'नॉइज़-कैंसलिंग हेडफ़ोन और केस',
      'ar': 'سماعات إلغاء الضوضاء وحقيبتها',
      'nl': 'Noise-cancelling koptelefoon & hoes',
      'el': 'Ακουστικά με Ακύρωση Θορύβου & Θήκη',
      'sv': 'Brusreducerande hörlurar & fodral',
      'pl': 'Słuchawki z redukcją szumów i etui',
      'id': 'Headphone Peredam Bising & Casing',
      'th': 'หูฟังตัดเสียงรบกวนพร้อมกล่องใส่',
      'vi': 'Tai nghe chống ồn & hộp đựng',
    },
    'raincoat': {
      'en': 'Lightweight Waterproof Raincoat',
      'tr': 'Hafif Su Geçirmez Yağmurluk',
      'de': 'Leichte wasserdichte Regenjacke',
      'es': 'Chubasquero Ligero e Impermeable',
      'fr': 'Imperméable Léger',
      'it': 'Impermeabile Leggero',
      'pt': 'Capa de Chuva Leve e Impermeável',
      'ru': 'Легкий водонепроницаемый дождевик',
      'zh': '轻便防水雨衣',
      'ja': '軽量防水レインコート',
      'ko': '경량 방수 우비',
      'hi': 'हल्का वाटरप्रूफ रेनकोट',
      'ar': 'معطف واق من المطر خفيف ومقاوم للماء',
      'nl': 'Lichte waterdichte regenjas',
      'el': 'Ελαφρύ Αδιάβροχο Μπουφάν',
      'sv': 'Lätt vattentät regnjacka',
      'pl': 'Lekka nieprzemakalna kurtka przeciwdeszczowa',
      'id': 'Jas Hujan Ringan Tahan Air',
      'th': 'เสื้อกันฝนน้ำหนักเบากันน้ำ',
      'vi': 'Áo mưa mỏng nhẹ chống thấm nước',
    },
    'charger': {
      'en': 'Universal Travel Adapter & Fast Charger',
      'tr': 'Evrensel Seyahat Prizi & Hızlı Şarj Cihazı',
      'de': 'Universal-Reiseadapter & Schnellladegerät',
      'es': 'Adaptador Universal de Viaje y Cargador Rápido',
      'fr': 'Adaptateur de Voyage Universel et Chargeur Rapide',
      'it': 'Adattatore Universale da Viaggio e Caricatore Rapido',
      'pt': 'Adaptador Universal de Viagem e Carregador Rápido',
      'ru': 'Универсальный дорожный адаптер и быстрая зарядка',
      'zh': '通用旅行转换插头及快充充电器',
      'ja': '海外旅行用変換プラグ＆急速充電器',
      'ko': '여행용 멀티 어댑터 및 고속 충전기',
      'hi': 'यूनिवर्सल ट्रैवल एडाप्टर और फास्ट चार्जर',
      'ar': 'محول سفر عالمي وشاحن سريع',
      'nl': 'Universele reisadapter & snellader',
      'el': 'Παγκόσμιος Αντάπτορας Ταξιδιού & Ταχυφορτιστής',
      'sv': 'Universell reseadapter & snabbladdare',
      'pl': 'Uniwersalny adapter podróżny i szybka ładowarka',
      'id': 'Adaptor Perjalanan Universal & Pengisi Daya Cepat',
      'th': 'หัวแปลงปลั๊กไฟสากลพร้อมที่ชาร์จเร็ว',
      'vi': 'Đầu cắm du lịch đa năng & củ sạc nhanh',
    },
    'phone_cable': {
      'en': 'Fast Charger Adapter & Phone Cable',
      'tr': 'Hızlı Şarj Adaptörü & Telefon Kablosu',
      'de': 'Schnellladeadapter & Telefonkabel',
      'es': 'Adaptador de Carga Rápida y Cable',
      'fr': 'Adaptateur Charge Rapide et Câble Téléphone',
      'it': 'Caricatore Rapido e Cavo Telefono',
      'pt': 'Carregador Rápido e Cabo de Celular',
      'ru': 'Быстрое зарядное устройство и кабель',
      'zh': '快充头及手机充电线',
      'ja': '急速充電アダプター＆スマホ充電ケーブル',
      'ko': '고속 충전 어댑터 및 휴대폰 케이블',
      'hi': 'फास्ट चार्जर एडाप्टर और फोन केबल',
      'ar': 'شاحن سريع وكابل الهاتف',
      'nl': 'Snellaadadapter & telefoonkabel',
      'el': 'Αντάπτορας Ταχείας Φόρτισης & Καλώδιο',
      'sv': 'Snabbladdare & mobilkabel',
      'pl': 'Szybka ładowarka i kabel do telefonu',
      'id': 'Adaptor Pengisi Daya Cepat & Kabel HP',
      'th': 'หัวชาร์จเร็วและสายชาร์จโทรศัพท์',
      'vi': 'Củ sạc nhanh & cáp sạc điện thoại',
    },
    'laptop_charger': {
      'en': 'Laptop & Original Power Adapter',
      'tr': 'Dizüstü Bilgisayar & Orijinal Şarj Adaptörü',
      'de': 'Laptop & Original-Netzteil',
      'es': 'Portátil y Cargador Original',
      'fr': 'Ordinateur Portable et Chargeur d\'Origine',
      'it': 'Computer Portatile e Alimentatore Originale',
      'pt': 'Notebook e Carregador Original',
      'ru': 'Ноутбук и оригинальное зарядное устройство',
      'zh': '笔记本电脑及原装电源适配器',
      'ja': 'ノートパソコン＆純正電源アダプター',
      'ko': '노트북 및 정품 충전 어댑터',
      'hi': 'लैपटॉप और मूल पावर एडाप्टर',
      'ar': 'كمبيوتر محمول ومحول الطاقة الأصلي',
      'nl': 'Laptop & originele oplader',
      'el': 'Φορητός Υπολογιστής & Αυθεντικός Φορτιστής',
      'sv': 'Bärbar dator & originalladdare',
      'pl': 'Laptop i oryginalny zasilacz',
      'id': 'Laptop & Adaptor Pengisi Daya Asli',
      'th': 'แล็ปท็อปและอะแดปเตอร์ชาร์จไฟแท้',
      'vi': 'Máy tính xách tay & sạc chính hãng',
    },
    'powerbank': {
      'en': 'Flight-Approved Powerbank',
      'tr': 'Powerbank 20.000 mAh (Uçuş Onaylı)',
      'de': 'Flugzugelassene Powerbank',
      'es': 'Batería Externa Aprobada para Vuelo',
      'fr': 'Batterie Externe Certifiée Vol',
      'it': 'Powerbank Omologato per Volo',
      'pt': 'Powerbank Aprovado para Voo',
      'ru': 'Внешний аккумулятор (разрешен в самолет)',
      'zh': '符合航空标准便携充电宝',
      'ja': '機内持ち込み対応モバイルバッテリー',
      'ko': '기내 반입 승인 보조배터리',
      'hi': 'फ्लाइट-अनुमोदित पावरबैंक',
      'ar': 'بطارية متنقلة معتمدة للرحلات الجوية',
      'nl': 'Vliegtuig-goedgekeurde powerbank',
      'el': 'Powerbank Εγκεκριμένο για Πτήσεις',
      'sv': 'Flyggodkänd powerbank',
      'pl': 'Powerbank dopuszczony do lotu',
      'id': 'Powerbank Disetujui untuk Penerbangan',
      'th': 'พาวเวอร์แบงก์ที่อนุญาตให้นำขึ้นเครื่องได้',
      'vi': 'Pin sạc dự phòng đủ chuẩn mang lên máy bay',
    },
    'toiletries': {
      'en': 'Personal Care & Toiletry Bag (100ml TSA)',
      'tr': 'Kişisel Bakım & Kozmetik Çantası (100ml TSA)',
      'de': 'Körperpflege- & Kosmetikbeutel (100ml TSA)',
      'es': 'Neceser de Cuidado Personal (100ml TSA)',
      'fr': 'Trousse de Toilette et Soins (100ml TSA)',
      'it': 'Beauty Case e Kit Cura Personale (100ml TSA)',
      'pt': 'Necessaire de Cuidados Pessoais (100ml TSA)',
      'ru': 'Косметичка и средства ухода (100 мл TSA)',
      'zh': '便携个人洗漱包 (100ml TSA标准)',
      'ja': '洗面用具・コスメポーチ (100ml TSA対応)',
      'ko': '세면도구 및 화장품 파우치 (100ml 기내 규정)',
      'hi': 'पर्सनल केयर और टॉयलेटरी बैग (100ml TSA)',
      'ar': 'حقيبة العناية الشخصية ومستحضرات التجميل (100 مل)',
      'nl': 'Toilet- & cosmeticatas (100ml TSA)',
      'el': 'Νεσεσέρ Προσωπικής Φροντίδας (100ml TSA)',
      'sv': 'Necessär & personlig vård (100ml TSA)',
      'pl': 'Kosmetyczka i przybory toaletowe (100ml TSA)',
      'id': 'Peralatan Mandi & Perawatan Diri (100ml TSA)',
      'th': 'กระเป๋าอุปกรณ์อาบน้ำและของใช้ส่วนตัว (100มล. TSA)',
      'vi': 'Túi đồ vệ sinh cá nhân & mỹ phẩm (100ml TSA)',
    },
    'toothbrush': {
      'en': 'Travel Toothbrush & Toothpaste',
      'tr': 'Seyahat Boy Diş Fırçası & Macunu',
      'de': 'Reisezahnbürste & Zahnpasta',
      'es': 'Cepillo de Dientes de Viaje y Pasta',
      'fr': 'Brosse à Dents de Voyage et Dentifrice',
      'it': 'Spazzolino da Denti da Viaggio e Dentifricio',
      'pt': 'Escova e Pasta de Dentes de Viagem',
      'ru': 'Дорожная зубная щетка и паста',
      'zh': '便携旅行牙刷及牙膏',
      'ja': '携帯用歯ブラシ＆歯磨き粉',
      'ko': '여행용 칫솔 및 치약',
      'hi': 'यात्रा टूथब्रश और टूथपेस्ट',
      'ar': 'فرشاة أسنان ومعجون للسفر',
      'nl': 'Reistandenborstel & tandpasta',
      'el': 'Οδοντόβουρτσα Ταξιδιού & Οδοντόκρεμα',
      'sv': 'Rezetandborste & tandkräm',
      'pl': 'Podróżna szczoteczka i pasta do zębów',
      'id': 'Sikat Gigi & Pasta Gigi Travel',
      'th': 'แปรงสีฟันและยาสีฟันขนาดพกพา',
      'vi': 'Bàn chải & kem đánh răng du lịch',
    },
    'walking_shoes': {
      'en': 'Comfortable Walking Shoes',
      'tr': 'Konforlu Yürüyüş Ayakkabısı',
      'de': 'Bequeme Wanderschuhe / Sneaker',
      'es': 'Calzado Cómodo para Caminar',
      'fr': 'Chaussures de Marche Confortables',
      'it': 'Scarpe Comode da Camminata',
      'pt': 'Tênis Confortável para Caminhada',
      'ru': 'Удобная обувь для ходьбы',
      'zh': '舒适步行鞋 / 运动鞋',
      'ja': '歩きやすいウォーキングスニーカー',
      'ko': '편안한 워킹화 / 스니커즈',
      'hi': 'आरामदायक चलने वाले जूते',
      'ar': 'حذاء مشي مريح',
      'nl': 'Comfortabele wandelschoenen',
      'el': 'Άνετα Παπούτσια Περιπάτου',
      'sv': 'Bekväma promenadskor',
      'pl': 'Wygodne buty do chodzenia',
      'id': 'Sepatu Jalan yang Nyaman',
      'th': 'รองเท้าเดินที่ใส่สบาย',
      'vi': 'Giày đi bộ thoải mái',
    },
    'thermal_underwear': {
      'en': 'Merino Wool Thermal Underwear & Socks',
      'tr': 'Merino Yün Termal İçlik & Çoraplar',
      'de': 'Merinowolle Thermounterwäsche & Socken',
      'es': 'Ropa Interior Térmica de Lana Merina y Calcetines',
      'fr': 'Sous-vêtements Thermiques en Laine Mérinos et Chaussettes',
      'it': 'Intimo Termico in Lana Merino e Calze',
      'pt': 'Segunda Pele Térmica de Lã Merino e Meias',
      'ru': 'Термобелье из мериносовой шерсти и носки',
      'zh': '美利奴羊毛保暖内衣及羊毛袜',
      'ja': 'メリノウール保温インナー＆靴下',
      'ko': '메리노 울 보온 내의 및 양말',
      'hi': 'मेरिनो वूल थर्मल इनरवियर और मोजे',
      'ar': 'ملابس حرارية وجوارب من صوف الميرينو',
      'nl': 'Merinowol thermisch ondergoed & sokken',
      'el': 'Ισοθερμικά Εσώρουχα από Μαλλί Merino & Κάλτσες',
      'sv': 'Merinoull underställ & strumpor',
      'pl': 'Bielizna termiczna z wełny merynosa i skarpety',
      'id': 'Pakaian Dalam Termal Wol Merino & Kaus Kaki',
      'th': 'ชุดชั้นในและถุงเท้าเก็บความร้อนผ้าวูลเมอริโน',
      'vi': 'Quần áo lót giữ nhiệt len Merino & tất',
    },
    'swimwear': {
      'en': 'Swimwear & Trunks',
      'tr': 'Mayo / Şort (Yedekli)',
      'de': 'Badebekleidung & Badehose',
      'es': 'Bañador y Ropa de Baño',
      'fr': 'Maillot de Bain et Shorts',
      'it': 'Costume da Bagno e Pantaloncini',
      'pt': 'Trajes de Banho e Biquíni/Sunga',
      'ru': 'Купальник / плавки (запасные)',
      'zh': '泳衣 / 泳裤 (备用)',
      'ja': '水着・スイムウェア (予備含む)',
      'ko': '수영복 및 비치웨어 (여분)',
      'hi': 'स्विमवियर और ट्रंक्स',
      'ar': 'ملابس سباحة وشورتات إضافية',
      'nl': 'Zwemkleding & zwembroek',
      'el': 'Μαγιό & Βερμούδες',
      'sv': 'Badkläder & badbyxor',
      'pl': 'Strój kąpielowy i kąpielówki',
      'id': 'Pakaian Renang & Celana Pantai',
      'th': 'ชุดว่ายน้ำและกางเกงว่ายน้ำ',
      'vi': 'Đồ bơi & quần bơi (dự phòng)',
    },
    'linen_shirt': {
      'en': 'Linen Shirts & T-Shirts',
      'tr': 'Keten Gömlek & Tişörtler',
      'de': 'Leinenhemden & T-Shirts',
      'es': 'Camisas de Lino y Camisetas',
      'fr': 'Chemises en Lin et T-shirts',
      'it': 'Camicie di Lino e T-shirt',
      'pt': 'Camisas de Linho e Camisetas',
      'ru': 'Льняные рубашки и футболки',
      'zh': '亚麻衬衫与透气T恤',
      'ja': 'リネンシャツ＆Tシャツ',
      'ko': '린넨 셔츠 및 티셔츠',
      'hi': 'लिनन शर्ट और टी-शर्ट',
      'ar': 'قمصان كتان وتيشيرتات خفيفة',
      'nl': 'Linnen overhemden & T-shirts',
      'el': 'Λινά Πουκάμισα & T-shirts',
      'sv': 'Linneskjortor & t-shirts',
      'pl': 'Lniane koszule i koszulki',
      'id': 'Kemeja Katun Linen & Kaos',
      'th': 'เสื้อเชิ้ตผ้าลินินและเสื้อยืด',
      'vi': 'Áo sơ mi đũi & áo thun',
    },
    'shorts': {
      'en': 'Shorts & Lightweight Pants',
      'tr': 'Şort & Hafif Pantolon',
      'de': 'Shorts & leichte Hosen',
      'es': 'Pantalones Cortos y Pantalones Ligeros',
      'fr': 'Shorts et Pantalons Légers',
      'it': 'Pantaloncini e Pantaloni Leggeri',
      'pt': 'Bermudas e Calças Leves',
      'ru': 'Шорты и легкие брюки',
      'zh': '短裤与轻薄长裤',
      'ja': 'ショートパンツ＆薄手パンツ',
      'ko': '반바지 및 얇은 바지',
      'hi': 'शॉर्ट्स और हल्की पैंट',
      'ar': 'شورتات وسراويل صيفية خفيفة',
      'nl': 'Korte broeken & lichte broeken',
      'el': 'Σορτς & Ελαφριά Παντελόνια',
      'sv': 'Shorts & lätta byxor',
      'pl': 'Szorty i lekkie spodnie',
      'id': 'Celana Pendek & Celana Ringan',
      'th': 'กางเกงขาสั้นและกางเกงขายาวผ้าบาง',
      'vi': 'Quần đùi & quần dài mỏng nhẹ',
    },
    'underwear_socks': {
      'en': 'Underwear & Socks Set',
      'tr': 'İç Çamaşırı & Çorap',
      'de': 'Unterwäsche & Socken-Set',
      'es': 'Ropa Interior y Calcetines',
      'fr': 'Sous-vêtements et Chaussettes',
      'it': 'Intimo e Calze',
      'pt': 'Roupas Íntimas e Meias',
      'ru': 'Нижнее белье и носки',
      'zh': '内衣裤与棉袜套组',
      'ja': '下着＆靴下セット',
      'ko': '속옷 및 양말 세트',
      'hi': 'अंडरवियर और मोजे सेट',
      'ar': 'ملابس داخلية وجوارب',
      'nl': 'Ondergoed & sokken',
      'el': 'Εσώρουχα & Κάλτσες',
      'sv': 'Underkläder & strumpor',
      'pl': 'Bielizna i skarpety',
      'id': 'Pakaian Dalam & Kaus Kaki',
      'th': 'ชุดชั้นในและถุงเท้า',
      'vi': 'Đồ lót & tất',
    },
    'beach_slippers': {
      'en': 'Beach Slippers & Sandals',
      'tr': 'Plaj Terliği & Sandalet',
      'de': 'Badelatschen & Sandalen',
      'es': 'Chanclas y Sandalias de Playa',
      'fr': 'Tongs et Sandales de Plage',
      'it': 'Ciabatte da Spiaggia e Sandali',
      'pt': 'Chinelos e Sandálias de Praia',
      'ru': 'Пляжные тапочки и сандалии',
      'zh': '沙滩拖鞋与凉鞋',
      'ja': 'ビーチサンダル＆サンダル',
      'ko': '비치 슬리퍼 및 샌들',
      'hi': 'बीच चप्पल और सैंडल',
      'ar': 'صنادل وأحذية الشاطئ',
      'nl': 'Strand倜lippers & sandalen',
      'el': 'Σαγιονάρες & Σανδάλια Παραλίας',
      'sv': 'Badtofflor & sandaler',
      'pl': 'Klapki plażowe i sandały',
      'id': 'Sandal Jepit & Sandal Pantai',
      'th': 'รองเท้าแตะชายหาดและรองเท้าแตะรัดส้น',
      'vi': 'Dép đi biển & sandal',
    },
    'sunscreen': {
      'en': 'High-Protection Sunscreen (SPF 50+)',
      'tr': 'Güneş Kremi (Yüksek Korumalı SPF 50+)',
      'de': 'Sonnencreme (Hoher Schutz SPF 50+)',
      'es': 'Protector Solar (Alta Protección SPF 50+)',
      'fr': 'Crème Solaire Haute Protection (SPF 50+)',
      'it': 'Crema Solare ad Alta Protezione (SPF 50+)',
      'pt': 'Protetor Solar Alta Proteção (FPS 50+)',
      'ru': 'Солнцезащитный крем (SPF 50+)',
      'zh': '高倍防晒霜 (SPF 50+)',
      'ja': '高プロテクト日焼け止め (SPF 50+)',
      'ko': '고보호 자외선 차단제 (SPF 50+)',
      'hi': 'सनस्क्रीन (उच्च सुरक्षा SPF 50+)',
      'ar': 'واقي شمس عالي الحماية (SPF 50+)',
      'nl': 'Zonnebrandcrème (Hoge bescherming SPF 50+)',
      'el': 'Αντηλιακό Υψηλής Προστασίας (SPF 50+)',
      'sv': 'Solskyddskräm (Högt skydd SPF 50+)',
      'pl': 'Krem z wysokim filtrem UV (SPF 50+)',
      'id': 'Tabir Surya Perlindungan Tinggi (SPF 50+)',
      'th': 'ครีมกันแดดป้องกันสูง (SPF 50+)',
      'vi': 'Kem chống nắng bảo vệ cao (SPF 50+)',
    },
    'aloe_vera': {
      'en': 'After-Sun Moisturizing Gel (Aloe Vera)',
      'tr': 'Güneş Sonrası Nemlendirici Jel (Aloe Vera)',
      'de': 'After-Sun Feuchtigkeitsgel (Aloe Vera)',
      'es': 'Gel Hidratante After-Sun (Aloe Vera)',
      'fr': 'Gel Hydratant Après-Soleil (Aloe Vera)',
      'it': 'Gel Doposole Idratante (Aloe Vera)',
      'pt': 'Gel Hidratante Pós-Sol (Aloe Vera)',
      'ru': 'Увлажняющий гель после загара (Алоэ Вера)',
      'zh': '晒后修护保湿芦荟胶',
      'ja': 'アフターサン保湿ジェル (アロエベラ)',
      'ko': '애프터 선 수분 진정 젤 (알로에 베라)',
      'hi': 'आफ्टर-सन मॉइस्चराइजिंग जेल (एलोवेरा)',
      'ar': 'جل الصبار المرطب بعد التعرض للشمس',
      'nl': 'Aftersun hydraterende gel (Aloë Vera)',
      'el': 'Ενυδατικό Gel για μετά τον Ήλιο (Αλόη)',
      'sv': 'After-sun fuktgivande gel (Aloe Vera)',
      'pl': 'Nawilżający żel po opalaniu (Aloes)',
      'id': 'Gel Pelembap Setelah Berjemur (Lidah Buaya)',
      'th': 'เจลว่านหางจระเข้บำรุงผิวหลังออกแดด',
      'vi': 'Gel lô hội dưỡng ẩm làm dịu da sau nắng',
    },
    'beach_towel': {
      'en': 'Microfiber Fast-Drying Beach Towel',
      'tr': 'Mikrofiber Hızlı Kuruyan Plaj Havlusu',
      'de': 'Mikrofaser-Strandtuch (Schnelltrocknend)',
      'es': 'Toalla de Playa de Secado Rápido',
      'fr': 'Serviette de Plage Microfibre Séchage Rapide',
      'it': 'Telo Mare in Microfibra ad Asciugatura Rapida',
      'pt': 'Toalha de Praia de Secagem Rápida',
      'ru': 'Быстросохнущее пляжное полотенце из микрофибры',
      'zh': '超细纤维速干沙滩毛巾',
      'ja': '速乾マイクロファイバービーチタオル',
      'ko': '초극세사 빠른 건조 비치 타월',
      'hi': 'माइक्रोफाइबर क्विक-ड्राई बीच तौलिया',
      'ar': 'منشفة شاطئ سريعة الجفاف من المايكروفايبر',
      'nl': 'Sneldrogende microvezel strandhanddoek',
      'el': 'Πετσέτα Παραλίας Μικροϊνών Ταχείας Στέγνωσης',
      'sv': 'Snabbtorkande mikrofiber strandhandduk',
      'pl': 'Szybkoschnący ręcznik plażowy z mikrofibry',
      'id': 'Handuk Pantai Cepat Kering Mikrofiber',
      'th': 'ผ้าขนหนูชายหาดไมโครไฟเบอร์แห้งเร็ว',
      'vi': 'Khăn tắm biển sợi microfiber nhanh khô',
    },
    'sunglasses': {
      'en': 'UV Protection Sunglasses & Case',
      'tr': 'UV Korumalı Güneş Gözlüğü & Kılıfı',
      'de': 'UV-Schutz-Sonnenbrille & Etui',
      'es': 'Gafas de Sol con Protección UV y Funda',
      'fr': 'Lunettes de Soleil Anti-UV et Étui',
      'it': 'Occhiali da Sole con Protezione UV e Custodia',
      'pt': 'Óculos de Sol com Proteção UV e Estojo',
      'ru': 'Солнцезащитные очки с защитой от УФ и футляр',
      'zh': '抗UV防紫外线太阳镜及眼镜盒',
      'ja': 'UVカットサングラス＆保護メガネケース',
      'ko': '자외선 차단 선글라스 및 케이스',
      'hi': 'यूवी संरक्षण धूप का चश्मा और केस',
      'ar': 'نظارات شمسية بحماية من الأشعة فوق البنفسجية وحافظة',
      'nl': 'UV-beschermende zonnebril & etui',
      'el': 'Γυαλιά Ηλίου Προστασίας UV & Θήκη',
      'sv': 'UV-skyddande solglasögon & fodral',
      'pl': 'Okulary przeciwsłoneczne z filtrem UV i etui',
      'id': 'Kacamata Hitam Pelindung UV & Tempat Kacamata',
      'th': 'แว่นกันแดดป้องกันรังสี UV พร้อมกล่องใส่',
      'vi': 'Kính mát chống tia UV & hộp đựng',
    },
    'sun_hat': {
      'en': 'Wide-Brim Sun Hat',
      'tr': 'Geniş Siperlikli Güneş Şapkası',
      'de': 'Sonnenhut mit breiter Krempe',
      'es': 'Sombrero de Sol de Ala Ancha',
      'fr': 'Chapeau de Soleil à Bord Large',
      'it': 'Cappello da Sole a Tesa Larga',
      'pt': 'Chapéu de Sol de Aba Larga',
      'ru': 'Широкополая солнцезащитная шляпа',
      'zh': '大檐遮阳防晒帽',
      'ja': 'つば広UVハット・日よけ帽子',
      'ko': '챙 넓은 자외선 차단 모자',
      'hi': 'चौड़ी किनारी वाली धूप की टोपी',
      'ar': 'قبعة شمسية عريضة الحواف',
      'nl': 'Zonnehoed met brede rand',
      'el': 'Καπέλο Ηλίου με Μεγάλο Γείσο',
      'sv': 'Bredbrättad solhatt',
      'pl': 'Kapelusz przeciwsłoneczny z szerokim rondem',
      'id': 'Topi Pantai Lebar Pelindung Matahari',
      'th': 'หมวกกันแดดปีกกว้าง',
      'vi': 'Mũ rộng vành che nắng',
    },
    'waterproof_case': {
      'en': 'Waterproof Phone & Wallet Pouch',
      'tr': 'Su Geçirmez Telefon & Cüzdan Kılıfı',
      'de': 'Wasserdichte Hülle für Handy & Geldbörse',
      'es': 'Funda Impermeable para Móvil y Documentos',
      'fr': 'Pochette Étanche Téléphone et Papiers',
      'it': 'Custodia Impermeabile per Telefono e Portafoglio',
      'pt': 'Bolsa Impermeável para Celular e Documentos',
      'ru': 'Водонепроницаемый чехол для телефона и денег',
      'zh': '手机防水袋与贵重物品密封包',
      'ja': 'スマホ用防水ケース・貴重品ポーチ',
      'ko': '방수 휴대폰 및 지갑 파우치',
      'hi': 'वाटरप्रूफ फोन और वॉलेट पाउच',
      'ar': 'جراب مقاوم للماء للهاتف والمحفظة',
      'nl': 'Waterdicht hoesje voor telefoon en portemonnee',
      'el': 'Αδιάβροχη Θήκη για Κινητό & Πορτοφόλι',
      'sv': 'Vattentätt fodral för mobil & plånbok',
      'pl': 'Wodoszczelne etui na telefon i dokumenty',
      'id': 'Kantong Tahan Air untuk HP & Dompet',
      'th': 'ซองกันน้ำสำหรับโทรศัพท์และกระเป๋าสตางค์',
      'vi': 'Túi chống nước cho điện thoại & ví',
    },
    'ski_jacket': {
      'en': 'Windproof & Waterproof Ski Parka',
      'tr': 'Rüzgar & Su Geçirmez Kalın Mont / Parka',
      'de': 'Wind- & wasserdichte Skijacke / Parka',
      'es': 'Chaqueta de Esquí Cortavientos e Impermeable',
      'fr': 'Parka de Ski Coupe-Vent et Imperméable',
      'it': 'Giacca da Sci Antivento e Impermeabile',
      'pt': 'Jaqueta de Esqui Impermeável e Corta-Vento',
      'ru': 'Ветро- и водонепроницаемая куртка / парка',
      'zh': '防风防水加厚滑雪服 / 冲锋衣',
      'ja': '防風防水スノーボード・スキージャケット',
      'ko': '방풍 방수 스키 재킷 / 파카',
      'hi': 'विंडप्रूफ और वाटरप्रूफ स्की जैकेट',
      'ar': 'سترة تزلج سميكة مقاومة للرياح والماء',
      'nl': 'Wind- en waterdichte ski-jas / parka',
      'el': 'Αντιανεμικό & Αδιάβροχο Μπουφάν Σκι',
      'sv': 'Vind- & vattentät skidjacka / parka',
      'pl': 'Wiatro- i wodoodporna kurtka narciarska',
      'id': 'Jaket Ski Tahan Angin & Tahan Air',
      'th': 'เสื้อแจ็คเก็ตสกีกันลมและกันน้ำ',
      'vi': 'Áo khoác trượt tuyết chống gió & chống nước',
    },
    'ski_pants': {
      'en': 'Snow & Ski Pants',
      'tr': 'Kar / Kayak Pantolonu',
      'de': 'Schnee- & Skihose',
      'es': 'Pantalones de Nieve y Esquí',
      'fr': 'Pantalon de Ski et Neige',
      'it': 'Pantaloni da Sci e Neve',
      'pt': 'Calça de Neve e Esqui',
      'ru': 'Лыжные / сноубордические штаны',
      'zh': '专业防风保暖滑雪裤',
      'ja': 'スノー・スキーパンツ',
      'ko': '방수 스키 / 스노보드 팬츠',
      'hi': 'स्नो और स्की पैंट',
      'ar': 'سروال التزلج على الجليد',
      'nl': 'Sneeuw- & skibroek',
      'el': 'Παντελόνι Χιονιού & Σκι',
      'sv': 'Snö- & skidbyxor',
      'pl': 'Spodnie narciarskie / snowboardowe',
      'id': 'Celana Salju & Ski',
      'th': 'กางเกงกันหิมะและสกี',
      'vi': 'Quần trượt tuyết chống thấm nước',
    },
    'sweater': {
      'en': 'Wool & Fleece Sweaters',
      'tr': 'Yün / Polar Kazak ve Sweatshirt',
      'de': 'Woll- & Fleecepullover',
      'es': 'Jerseys de Lana y Sudaderas Polares',
      'fr': 'Pulls en Laine et Polaires',
      'it': 'Maglioni in Lana e Pile',
      'pt': 'Suéteres de Lã e Casacos Fleece',
      'ru': 'Шерстяные свитера и флисовые кофты',
      'zh': '羊毛衫与抓绒卫衣',
      'ja': 'フリース＆ウールセーター',
      'ko': '울 니트 및 플리스 스웨트셔츠',
      'hi': 'ऊन और फ्लीस स्वेटर',
      'ar': 'سترات صوفية وبلوفرات دافئة',
      'nl': 'Wollen & fleece truien',
      'el': 'Μάλλινα Πουλόβερ & Φούτερ Fleece',
      'sv': 'Ylle- & fleecetröjor',
      'pl': 'Swetry wełniane i bluzy polarowe',
      'id': 'Sweter Wol & Jaket Fleece',
      'th': 'เสื้อกันหนาวผ้าขนสัตว์และฟลีซ',
      'vi': 'Áo len & áo nỉ lót lông',
    },
    'thermal_socks': {
      'en': 'Thermal Wool Socks',
      'tr': 'Termal Yün Çoraplar',
      'de': 'Thermowollsocken',
      'es': 'Calcetines Térmicos de Lana',
      'fr': 'Chaussettes Thermiques en Laine',
      'it': 'Calze Termiche in Lana',
      'pt': 'Meias Térmicas de Lã',
      'ru': 'Термоноски из шерсти',
      'zh': '加厚羊毛保暖袜',
      'ja': '防寒サーマルウールソックス',
      'ko': '방한 울 보온 양말',
      'hi': 'थर्मल ऊनी मोजे',
      'ar': 'جوارب صوفية حرارية',
      'nl': 'Thermische wollen sokken',
      'el': 'Ισοθερμικές Μάλλινες Κάλτσες',
      'sv': 'Termiska ullstrumpor',
      'pl': 'Wełniane skarpety termiczne',
      'id': 'Kaus Kaki Wol Termal',
      'th': 'ถุงเท้าผ้าวูลกันหนาว',
      'vi': 'Tất len giữ nhiệt',
    },
    'snow_boots': {
      'en': 'Waterproof Winter Snow Boots',
      'tr': 'Su Geçirmez Kışlık Bot / Kar Ayakkabısı',
      'de': 'Wasserdichte Winter- & Schneestiefel',
      'es': 'Botas de Nieve e Invierno Impermeables',
      'fr': 'Bottes de Neige d\'Hiver Imperméables',
      'it': 'Scarponi da Neve Impermeabili',
      'pt': 'Botas de Neve Impermeáveis',
      'ru': 'Водонепроницаемые зимние ботинки / снегоходы',
      'zh': '防水防滑冬季雪地靴',
      'ja': '防寒・防水スノーブーツ',
      'ko': '방수 방한 스노우 부츠',
      'hi': 'वाटरप्रूफ विंटर स्नो बूट्स',
      'ar': 'أحذية ثلج شتوية مقاومة للماء',
      'nl': 'Waterdichte winter- & sneeuwlaarzen',
      'el': 'Αδιάβροχες Χειμερινές Μπότες Χιονιού',
      'sv': 'Vattentäta vinter- & snökängor',
      'pl': 'Nieprzemakalne śniegowce / buty zimowe',
      'id': 'Sepatu Bot Musim Dingin Tahan Air',
      'th': 'รองเท้าบูทลุยหิมะกันน้ำ',
      'vi': 'Ủng đi tuyết mùa đông chống thấm nước',
    },
    'beanie_scarf': {
      'en': 'Wool Beanie, Neck Warmer & Scarf',
      'tr': 'Yün Bere, Polar Boyunluk & Atkı',
      'de': 'Wollmütze, Schlauchschal & Schal',
      'es': 'Gorro de Lana, Braga de Cuello y Bufanda',
      'fr': 'Bonnet en Laine, Tour de Cou et Écharpe',
      'it': 'Berretto di Lana, Scaldacollo e Sciarpa',
      'pt': 'Gorro de Lã, Cachecol e Gola Térmica',
      'ru': 'Шерстяная шапка, снуд и шарф',
      'zh': '羊毛针织帽、围巾与保暖脖套',
      'ja': 'ニット帽・ネックウォーマー＆マフラー',
      'ko': '울 비니, 넥워머 및 목도리',
      'hi': 'ऊनी टोपी, नेक वार्मर और मफलर',
      'ar': 'قبعة صوفية ووشاح دافئ للرقبة',
      'nl': 'Wollen muts, nekwarmer & sjaal',
      'el': 'Μάλλινος Σκούφος, Περιλαίμιο & Κασκόλ',
      'sv': 'Yllemössa, halsvärmare & halsduk',
      'pl': 'Wełniana czapka, komin i szalik',
      'id': 'Kupluk Wol, Penghangat Leher & Syal',
      'th': 'หมวกไหมพรม ผ้าพันคอ และผ้าคลุมคอ',
      'vi': 'Mũ len, khăn quàng cổ & ống giữ ấm cổ',
    },
    'ski_gloves': {
      'en': 'Insulated Waterproof Ski Gloves',
      'tr': 'Su ve Soğuk Geçirmez Kayak Eldiveni',
      'de': 'Wasserdichte isolierte Skihandschuhe',
      'es': 'Guantes de Esquí Impermeables y Aislantes',
      'fr': 'Gants de Ski Imperméables et Isolants',
      'it': 'Guanti da Sci Impermeabili e Termici',
      'pt': 'Luvas de Esqui Térmicas e Impermeáveis',
      'ru': 'Непромокаемые лыжные перчатки',
      'zh': '加绒加厚防风防水滑雪手套',
      'ja': '防寒・防水スノーボード・スキーグローブ',
      'ko': '방수 보온 스키 장갑',
      'hi': 'वाटरप्रूफ स्की दस्ताने',
      'ar': 'قفازات تزلج عازلة ومقاومة للماء',
      'nl': 'Geïsoleerde waterdichte skihandschoenen',
      'el': 'Αδιάβροχα & Ισοθερμικά Γάντια Σκι',
      'sv': 'Fodrade vattentäta skidhandskar',
      'pl': 'Ocieplane wodoodporne rękawice narciarskie',
      'id': 'Sarung Tangan Ski Tahan Air',
      'th': 'ถุงมือสกีกันน้ำและกันหนาว',
      'vi': 'Găng tay trượt tuyết chống nước giữ ấm',
    },
    'lip_balm': {
      'en': 'Intensive Hand Cream & Lip Balm',
      'tr': 'Yoğun Nemlendirici El Kremi & Dudak Balmı',
      'de': 'Intensive Handcreme & Lippenbalsam',
      'es': 'Crema de Manos Hidratante y Bálsamo Labial',
      'fr': 'Crème Mains Réparatrice et Baume à Lèvres',
      'it': 'Crema Mani Idratante e Burrocacao',
      'pt': 'Creme Hidratante para Mãos e Protetor Labial',
      'ru': 'Питательный крем для рук и бальзам для губ',
      'zh': '滋润修护护手霜及润唇膏',
      'ja': '高保湿ハンドクリーム＆リップバーム',
      'ko': '고보습 핸드크림 및 립밤',
      'hi': 'हैंड क्रीम और लिप बाम',
      'ar': 'كريم ترطيب مكثف لليدين ومرطب شفاه',
      'nl': 'Intensieve handcrème & lippenbalsem',
      'el': 'Ενυδατική Κρέμα Χεριών & Lip Balm',
      'sv': 'Intensiv handkräm & läppbalsam',
      'pl': 'Regenerujący krem do rąk i balsam do ust',
      'id': 'Krim Tangan & Pelembap Bibir Intensif',
      'th': 'แฮนด์ครีมบำรุงเข้มข้นและลิปบาล์ม',
      'vi': 'Kem dưỡng da tay & son dưỡng ẩm môi',
    },
    'ski_goggles': {
      'en': 'Snow & Ski Goggles',
      'tr': 'Kar Güneş Gözlüğü / Kayak Gözlüğü',
      'de': 'Schnee- & Skibrille',
      'es': 'Gafas de Ventisca y Esquí',
      'fr': 'Masque de Ski et de Snowboard',
      'it': 'Maschera da Sci e Neve',
      'pt': 'Óculos de Proteção para Neve e Esqui',
      'ru': 'Горнолыжная маска / очки',
      'zh': '防雾双层雪镜 / 滑雪护目镜',
      'ja': '防曇スノーゴーグル・スキーゴーグル',
      'ko': '자외선 차단 방담 스키 고글',
      'hi': 'स्नो और स्की गॉगल्स',
      'ar': 'نظارات واقية للتزلج على الجليد',
      'nl': 'Sneeuw- & skibril',
      'el': 'Μάσκα Χιονιού & Σκι',
      'sv': 'Skidglasögon / goggles',
      'pl': 'Gogle narciarskie z powłoką anti-fog',
      'id': 'Kacamata Pelindung Salju & Ski',
      'th': 'แว่นตากันลมและหิมะสำหรับสกี',
      'vi': 'Kính bảo hộ trượt tuyết chống đọng sương',
    },
    'thermos': {
      'en': 'Insulated Stainless Steel Thermos',
      'tr': 'Termal Matara / Çelik Termos',
      'de': 'Edelstahl-Thermosflasche',
      'es': 'Termo de Acero Inoxidable',
      'fr': 'Bouteille Isotherme en Acier Inoxydable',
      'it': 'Borraccia Termica in Acciaio Inox',
      'pt': 'Garrafa Térmica de Aço Inox',
      'ru': 'Стальной вакуумный термос',
      'zh': '不锈钢真空保温杯 / 旅行水壶',
      'ja': 'ステンレス真空断熱保温ボトル',
      'ko': '스테인리스 보온병 / 텀블러',
      'hi': 'स्टेनलेस स्टील थर्मस फ्लास्क',
      'ar': 'قارورة حرارية من الفولاذ المقاوم للصدأ',
      'nl': 'RVS geïsoleerde thermosfles',
      'el': 'Ανοξείδωτο Θερμός Ταξιδιού',
      'sv': 'Termos i rostfritt stål',
      'pl': 'Termos próżniowy ze stali nierdzewnej',
      'id': 'Termos Baja Tahan Karat',
      'th': 'กระติกน้ำสแตนเลสเก็บอุณหภูมิ',
      'vi': 'Bình giữ nhiệt inox',
    },
    'suit': {
      'en': 'Suit / Blazer Jacket',
      'tr': 'Takım Elbise / Blazer Ceket',
      'de': 'Anzug / Blazer',
      'es': 'Traje / Chaqueta Blazer',
      'fr': 'Costume / Veste de Blazer',
      'it': 'Abito Completo / Giacca Blazer',
      'pt': 'Terno / Blazer',
      'ru': 'Деловой костюм / блейзер',
      'zh': '商务西装套装 / 便西外套',
      'ja': 'スーツ・テーラードジャケット',
      'ko': '정장 수트 / 블레이저 재킷',
      'hi': 'सूट / ब्लेज़र जैकेट',
      'ar': 'بدلة رسمية / بليزر',
      'nl': 'Kostuum / colbert',
      'el': 'Κοστούμι / Σακάκι Blazer',
      'sv': 'Kostym / blazer',
      'pl': 'Garnitur / marynarka',
      'id': 'Jas Formal / Blazer',
      'th': 'ชุดสูทและเสื้อเบลเซอร์',
      'vi': 'Bộ vest / áo khoác blazer',
    },
    'dress_shirt': {
      'en': 'Wrinkle-Free Dress Shirts',
      'tr': 'Kırışmaz Ütülü Gömlek / Bluz',
      'de': 'Bügelfreie Businesshemden',
      'es': 'Camisas de Vestir sin Plancha',
      'fr': 'Chemises Infroissables',
      'it': 'Camicie da Lavoro Antipiega',
      'pt': 'Camisas Sociais Anti-Amassado',
      'ru': 'Рубашки из несминаемой ткани',
      'zh': '抗皱免烫商务正装衬衫',
      'ja': '形態安定ノーアイロンワイシャツ',
      'ko': '구김 방지 링클프리 드레스 셔츠',
      'hi': 'रिंकल-फ्री फॉर्मल शर्ट',
      'ar': 'قمصان رسمية مضادة للتجعد',
      'nl': 'Strijkvrije overhemden',
      'el': 'Ατσαλάκωτα Επαγγελματικά Πουκάμισα',
      'sv': 'Strykfri skjorta / blus',
      'pl': 'Koszule niemnące typu non-iron',
      'id': 'Kemeja Kerja Bebas Kusut',
      'th': 'เสื้อเชิ้ตทำงานไม่ยับง่าย',
      'vi': 'Áo sơ mi công sở chống nhăn',
    },
    'chino_pants': {
      'en': 'Chino & Dress Pants',
      'tr': 'Kumaş / Chino Pantolon',
      'de': 'Chinos & Stoffhosen',
      'es': 'Pantalones Chinos y de Vestir',
      'fr': 'Pantalons Chino et de Ville',
      'it': 'Pantaloni Chino e Sartoriali',
      'pt': 'Calças Chino e Sociais',
      'ru': 'Брюки чинос и классические брюки',
      'zh': '商务休闲裤及直筒长裤',
      'ja': 'チノパン＆スラックス',
      'ko': '치노 팬츠 및 정장 바지',
      'hi': 'चिनो और फॉर्मल पैंट',
      'ar': 'سراويل قماشية وشينو',
      'nl': 'Chino\'s & pantalons',
      'el': 'Παντελόνια Chino & Υφασμάτινα',
      'sv': 'Chinos & kostymbyxor',
      'pl': 'Spodnie chino i eleganckie',
      'id': 'Celana Chino & Celana Bahan',
      'th': 'กางเกงชิโนและกางเกงสแล็ค',
      'vi': 'Quần âu & quần chinos',
    },
    'business_shoes': {
      'en': 'Leather Business Shoes & Belt',
      'tr': 'Klasik İş Ayakkabısı & Kemer',
      'de': 'Lederschuhe & Gürtel',
      'es': 'Zapatos de Vestir de Cuero y Cinturón',
      'fr': 'Chaussures de Ville en Cuir et Ceinture',
      'it': 'Scarpe Eleganti in Pelle e Cintura',
      'pt': 'Sapatos Sociais de Couro e Cinto',
      'ru': 'Классические кожаные туфли и ремень',
      'zh': '正装商务皮鞋及皮带',
      'ja': '革靴・ビジネスシューズ＆レザーベルト',
      'ko': '클래식 가죽 구두 및 벨트',
      'hi': 'चमड़े के फॉर्मल जूते और बेल्ट',
      'ar': 'أحذية جلدية رسمية وحزام',
      'nl': 'Zakelijke leren schoenen & riem',
      'el': 'Δερμάτινα Παπούτσια Κοστουμιού & Ζώνη',
      'sv': 'Klassiska läderskor & bälte',
      'pl': 'Skórzane buty wizytowe i pasek',
      'id': 'Sepatu Kulit Formal & Ikat Pinggang',
      'th': 'รองเท้าหนังคัทชูและเข็มขัด',
      'vi': 'Giày tây da & thắt lưng',
    },
    'wireless_mouse': {
      'en': 'Wireless Mouse & Presentation Remote',
      'tr': 'Kablosuz Mouse & Sunum Kumandası',
      'de': 'Kabellose Maus & Presenter',
      'es': 'Ratón Inalámbrico y Puntero de Presentaciones',
      'fr': 'Souris Sans Fil et Télécommande de Présentation',
      'it': 'Mouse Wireless e Puntatore per Presentazioni',
      'pt': 'Mouse Sem Fio e Apresentador Multimídia',
      'ru': 'Беспроводная мышь и кликер для презентаций',
      'zh': '无线鼠标及演示翻页笔',
      'ja': 'ワイヤレスマウス＆プレゼンリモコン',
      'ko': '무선 마우스 및 발표용 프리젠터',
      'hi': 'वायरलेस माउस और प्रेजेंटेशन रिमोट',
      'ar': 'فأرة لاسلكية وجهاز تحكم بالعروض التقديمية',
      'nl': 'Draadloze muis & presentatieklikker',
      'el': 'Ασύρματο Ποντίκι & Τηλεχειριστήριο Παρουσιάσεων',
      'sv': 'Trådlös mus & presentationsklicker',
      'pl': 'Mysz bezprzewodowa i pilot do prezentacji',
      'id': 'Mouse Nirkabel & Remote Presentasi',
      'th': 'เมาส์ไร้สายและรีโมตพรีเซนต์งาน',
      'vi': 'Chuột không dây & bút trình chiếu',
    },
    'business_cards': {
      'en': 'Business Cards, Notepad & Pen',
      'tr': 'Kartvizitlik, Şık Not Defteri & Kalem',
      'de': 'Visitenkarten, Notizbuch & Stift',
      'es': 'Tarjetero, Cuaderno y Bolígrafo',
      'fr': 'Porte-Cartes, Carnet et Stylo',
      'it': 'Portabiglietti da Visita, Taccuino e Penna',
      'pt': 'Porta-Cartões, Bloco de Notas e Caneta',
      'ru': 'Визитница, стильный блокнот и ручка',
      'zh': '名片夹、精装笔记本与商务笔',
      'ja': '名刺入れ・上質ノート＆ボールペン',
      'ko': '명함 지갑, 고급 노트 및 펜',
      'hi': 'विजिटिंग कार्ड, नोटपैड और पेन',
      'ar': 'حافظة بطاقات العمل ودفتر وقلم',
      'nl': 'Visitekaartjes, notitieboek & pen',
      'el': 'Θήκη Επαγγελματικών Καρτών, Σημειωματάριο & Στυλό',
      'sv': 'Visitkortsfodral, anteckningsblock & penna',
      'pl': 'Wizytownik, elegancki notatnik i długopis',
      'id': 'Kotak Kartu Nama, Buku Catatan & Pena',
      'th': 'กล่องใส่นามบัตร สมุดโน้ต และปากกา',
      'vi': 'Hộp đựng danh thiếp, sổ tay & bút',
    },
    'travel_tickets': {
      'en': 'Flight & Train Tickets, Hotel Reservations',
      'tr': 'Uçak / Tren Biletleri & Otel Rezervasyonu',
      'de': 'Flug- & Zugtickets, Hotelreservierungen',
      'es': 'Billetes de Tren/Avión y Reservas de Hotel',
      'fr': 'Billets Train/Avion et Réservations d\'Hôtel',
      'it': 'Biglietti Aerei/Treno e Prenotazioni Alberghiere',
      'pt': 'Passagens de Avião/Trem e Reservas de Hotel',
      'ru': 'Билеты на самолет / поезд и брони отелей',
      'zh': '机票/火车票及酒店预订凭证',
      'ja': '航空券・新幹線チケット＆ホテル予約控え',
      'ko': '항공권 / 기차표 및 호텔 예약증',
      'hi': 'उड़ान/ट्रेन टिकट और होटल आरक्षण',
      'ar': 'تذاكر السفر وحجوزات الفنادق',
      'nl': 'Vliegtickets, treinkaartjes & hotelreserveringen',
      'el': 'Εισιτήρια Αεροπλάνου/Τρένου & Κρατήσεις Ξενοδοχείων',
      'sv': 'Flyg- & tågbiljetter, hotellbokningar',
      'pl': 'Bilety lotnicze/kolejowe i rezerwacje hoteli',
      'id': 'Tiket Pesawat/Kereta & Reservasi Hotel',
      'th': 'ตั๋วเครื่องบิน/รถไฟและใบจองโรงแรม',
      'vi': 'Vé máy bay/tàu & xác nhận đặt phòng khách sạn',
    },
    'perfume_deodorant': {
      'en': 'Travel-Size Perfume & Deodorant (<100ml)',
      'tr': 'Seyahat Boy Parfüm & Deodorant (100ml altı)',
      'de': 'Parfüm & Deodorant in Reisegröße (<100ml)',
      'es': 'Perfume y Desodorante de Viaje (<100ml)',
      'fr': 'Parfum et Déodorant Format Voyage (<100ml)',
      'it': 'Profumo e Deodorante da Viaggio (<100ml)',
      'pt': 'Perfume e Desodorante Tamanho Viagem (<100ml)',
      'ru': 'Дорожный парфюм и дезодорант (до 100 мл)',
      'zh': '便携旅行装香水及止汗喷雾 (<100ml)',
      'ja': '携帯用香水＆デオドラント (<100ml)',
      'ko': '여행용 미니 향수 및 데오도란트 (<100ml)',
      'hi': 'ट्रैवल-साइज़ परफ्यूम और डिओडोरेंट (<100ml)',
      'ar': 'عطر ومزيل عرق بحجم السفر (أقل من 100 مل)',
      'nl': 'Reisformaat parfum & deodorant (<100ml)',
      'el': 'Άρωμα & Αποσμητικό Ταξιδιού (<100ml)',
      'sv': 'Parfym & deodorant i resestorlek (<100ml)',
      'pl': 'Perfumy i dezodorant w rozmiarze podróżnym (<100ml)',
      'id': 'Parfum & Deodoran Ukuran Travel (<100ml)',
      'th': 'น้ำหอมและโรลออนขนาดพกพา (ต่ำกว่า 100มล.)',
      'vi': 'Nước hoa & lăn khử mùi mini (<100ml)',
    },
    'shaving_kit': {
      'en': 'Compact Grooming & Shaving Kit',
      'tr': 'Kompakt Tıraş Seti / Bakım Kiti',
      'de': 'Kompaktes Rasierset / Pflegeset',
      'es': 'Kit Compacto de Afeitado y Aseo',
      'fr': 'Kit de Rasage et Soin Compact',
      'it': 'Set da Barba e Toeletta Compatto',
      'pt': 'Kit Compacto de Barbear e Cuidados',
      'ru': 'Компактный бритвенный набор',
      'zh': '便携式剃须刀及男士修容套装',
      'ja': 'コンパクトシェーバー＆グルーミングキット',
      'ko': '콤팩트 면도기 및 그루밍 키트',
      'hi': 'शेविंग और ग्रूमिंग किट',
      'ar': 'مجموعة حلاقة وعناية شخصية مدمجة',
      'nl': 'Compacte scheer- en verzorgingsset',
      'el': 'Συμπαγές Σετ Ξυρίσματος & Περιποίησης',
      'sv': 'Kompakt rak- & hygienkit',
      'pl': 'Kompaktowy zestaw do golenia i pielęgnacji',
      'id': 'Perlengkapan Cukur & Perawatan Ringkas',
      'th': 'ชุดโกนหนวดและดูแลตัวเองขนาดกะทัดรัด',
      'vi': 'Bộ cạo râu & chăm sóc cá nhân nhỏ gọn',
    },
    'trekking_pants': {
      'en': 'Breathable Trekking Pants',
      'tr': 'Nefes Alabilir Trekking Pantolonu',
      'de': 'Atmungsaktive Trekkinghose',
      'es': 'Pantalones Transpirables de Trekking',
      'fr': 'Pantalon de Randonnée Respirant',
      'it': 'Pantaloni da Trekking Traspiranti',
      'pt': 'Calça de Trekking Respirável',
      'ru': 'Дышащие треккинговые брюки',
      'zh': '速干透气专业徒步长裤',
      'ja': '通気性トレッキングパンツ',
      'ko': '통기성 트레킹 팬츠',
      'hi': 'सांस लेने योग्य ट्रेकिंग पैंट',
      'ar': 'سروال مسارات جبلية مريح وجيد التهوية',
      'nl': 'Ademende trekkingbroek',
      'el': 'Διαπνέον Παντελόνι Πεζοπορίας',
      'sv': 'Trekkingbyxor med andasfunktion',
      'pl': 'Oddychające spodnie trekkingowe',
      'id': 'Celana Trekking Berpori',
      'th': 'กางเกงเดินป่าระบายอากาศได้ดี',
      'vi': 'Quần leo núi dã ngoại thoáng khí',
    },
    'trekking_boots': {
      'en': 'Ankle-Support Trekking Boots',
      'tr': 'Bileklik Destekli Trekking Botu',
      'de': 'Trekkingstiefel mit Knöchelunterstützung',
      'es': 'Botas de Trekking con Soporte de Tobillo',
      'fr': 'Chaussures de Randonnée Montantes',
      'it': 'Scarponi da Trekking con Supporto alla Caviglia',
      'pt': 'Botas de Trekking com Suporte de Tornozelo',
      'ru': 'Треккинговые ботинки с поддержкой голеностопа',
      'zh': '高帮防滑专业徒步登山靴',
      'ja': '足首サポート付トレッキングブーツ',
      'ko': '발목 지지 트레킹 등산화',
      'hi': 'ट्रेकिंग जूते',
      'ar': 'أحذية تسلق الجبال مع دعم للكاحل',
      'nl': 'Trekkinglaarzen met enkelsteun',
      'el': 'Μποτάκια Πεζοπορίας με Υποστήριξη Αστραγάλου',
      'sv': 'Vandringskängor med fotledsstöd',
      'pl': 'Buty trekkingowe ze stabilizacją kostki',
      'id': 'Sepatu Bot Trekking Penopang Pergelangan Kaki',
      'th': 'รองเท้าบูทเดินป่าหุ้มข้อ',
      'vi': 'Giày leo núi có đệm đỡ cổ chân',
    },
    'tent': {
      'en': 'Camping Tent, Mat & Stakes',
      'tr': 'Çadır, Mat & Kazıklar',
      'de': 'Zelt, Isomatte & Heringe',
      'es': 'Tienda de Campaña, Esterilla y Piquetas',
      'fr': 'Tente, Matelas et Piquets',
      'it': 'Tenda da Campeggio, Materassino e Picchetti',
      'pt': 'Barraca de Camping, Isolante Térmico e Estacas',
      'ru': 'Палатка, туристический коврик и колышки',
      'zh': '露营帐篷、防潮地垫与地钉',
      'ja': 'キャンプテント・インナーマット＆ペグ',
      'ko': '캠핑 텐트, 매트 및 팩',
      'hi': 'तंबू, मैट और खूंटे',
      'ar': 'خيمة تخييم وسجادة وأوتاد',
      'nl': 'Kampeertent, slaapmat & haringen',
      'el': 'Σκηνή Camping, Υπόστρωμα & Πασσαλάκια',
      'sv': 'Tält, liggunderlag & tältpinnar',
      'pl': 'Namiot kempingowy, mata i śledzie',
      'id': 'Tenda Berkemah, Matras & Pasak',
      'th': 'เต็นท์แคมป์ปิ้ง แผ่นรองนอน และสมอบก',
      'vi': 'Lều cắm trại, đệm lót & cọc lều',
    },
    'sleeping_bag': {
      'en': 'Weather-Rated Sleeping Bag',
      'tr': 'Uyku Tulumu (Mevsime Uygun Dereceli)',
      'de': 'Temperaturangepasster Schlafsack',
      'es': 'Saco de Dormir Térmico',
      'fr': 'Sac de Couchage Adapté à la Saison',
      'it': 'Sacco a Pelo Termico',
      'pt': 'Saco de Dormir Térmico',
      'ru': 'Спальный мешок (по сезону)',
      'zh': '温标相符的专业露营睡袋',
      'ja': '季節対応スリーピングバッグ・寝袋',
      'ko': '계절 맞춤형 침낭',
      'hi': 'मौसम के अनुकूल स्लीपिंग बैग',
      'ar': 'كيس نوم ملائم للطقس',
      'nl': 'Weerbestendige slaapzak',
      'el': 'Υπνόσακος Ανάλογα με την Εποχή',
      'sv': 'Säsongsanpassad sovsäck',
      'pl': 'Śpiwór turystyczny dobrany do temperatury',
      'id': 'Kantong Tidur Sesuai Musim',
      'th': 'ถุงนอนกันความเย็นตามฤดูกาล',
      'vi': 'Túi ngủ dã ngoại theo mùa',
    },
    'headlamp': {
      'en': 'Headlamp & Spare Batteries',
      'tr': 'Kafa Feneri & Yedek Piller',
      'de': 'Stirnlampe & Ersatzbatterien',
      'es': 'Linterna Frontal y Pilas de Repuesto',
      'fr': 'Lampe Frontale et Piles de Rechange',
      'it': 'Torcia Frontale e Batterie di Scorta',
      'pt': 'Lanterna de Cabeça e Pilhas Extras',
      'ru': 'Налобный фонарь и запасные батарейки',
      'zh': '强光头灯及备用电池',
      'ja': 'ヘッドライト＆予備バッテリー',
      'ko': '헤드랜턴 및 여분 배터리',
      'hi': 'हेडलैम्प और अतिरिक्त बैटरी',
      'ar': 'مصباح رأس وبطاريات إضافية',
      'nl': 'Hoofdlamp & reservebatterijen',
      'el': 'Φακός Κεφαλής & Εφεδρικές Μπαταρίες',
      'sv': 'Pannlampa & extrabatterier',
      'pl': 'Czołówka i zapasowe baterie',
      'id': 'Senter Kepala & Baterai Cadangan',
      'th': 'ไฟฉายคาดศีรษะและแบตเตอรี่สำรอง',
      'vi': 'Đèn pin đội đầu & pin dự phòng',
    },
    'pocket_knife': {
      'en': 'Multi-Tool Pocket Knife',
      'tr': 'Çok Amaçlı Çakı / Kamp Pensesi',
      'de': 'Multifunktions-Taschenmesser',
      'es': 'Navaja Multiusos y Alicates de Camping',
      'fr': 'Couteau Multifonction / Pince de Camping',
      'it': 'Coltellino Multiuso / Pinza da Campeggio',
      'pt': 'Canivete Multifuncional',
      'ru': 'Мультитул / складной нож',
      'zh': '多功能瑞士军刀 / 户外工具钳',
      'ja': '多機能アーミーナイフ・マルチツール',
      'ko': '다목적 맥가이버 칼 / 멀티툴',
      'hi': 'मल्टी-टूल पॉकेट चाकू',
      'ar': 'سكين جيب متعدد الأدوات',
      'nl': 'Multitool zakmes',
      'el': 'Πολυεργαλείο Σουγιάς / Πένσα Camping',
      'sv': 'Multiverktyg / fickkniv',
      'pl': 'Scyzoryk wielofunkcyjny / multitool',
      'id': 'Pisau Lipat Multifungsi',
      'th': 'มีดพับอเนกประสงค์ / คีมแค้มปิ้ง',
      'vi': 'Dao xếp đa năng & kìm dã ngoại',
    },
    'first_aid': {
      'en': 'First Aid Kit (Bandages, Painkillers)',
      'tr': 'İlk Yardım Çantası (Yara Bandı, Sargı, Ağrı Kesici)',
      'de': 'Erste-Hilfe-Set (Pflaster, Schmerzmittel)',
      'es': 'Botiquín de Primeros Auxilios',
      'fr': 'Trousse de Premiers Soins',
      'it': 'Kit di Primo Soccorso',
      'pt': 'Kit de Primeiros Socorros',
      'ru': 'Аптечка первой помощи (бинты, обезболивающее)',
      'zh': '应急急救包 (创口贴、绷带、止痛药)',
      'ja': '救急セット・ファーストエイドキット',
      'ko': '구급약 상자 (밴드, 붕대, 진통제)',
      'hi': 'प्राथमिक चिकित्सा किट',
      'ar': 'حقيبة الإسعافات الأولية',
      'nl': 'EHBO-kit (pleisters, pijnstillers)',
      'el': 'Κουτί Πρώτων Βοηθειών',
      'sv': 'Första hjälpen-kit',
      'pl': 'Apteczka pierwszej pomocy',
      'id': 'Kotak P3K (Plester, Perban, Obat Pereda Nyeri)',
      'th': 'ชุดปฐมพยาบาลเบื้องต้น',
      'vi': 'Túi sơ cứu y tế (băng dán, bông gạc, giảm đau)',
    },
    'insect_spray': {
      'en': 'Bug & Insect Repellent Spray',
      'tr': 'Sinek & Haşere Kovucu Sprey',
      'de': 'Insektenschutz- & Mückenspray',
      'es': 'Spray Repelente de Mosquitos e Insectos',
      'fr': 'Spray Anti-Moustiques et Insectes',
      'it': 'Spray Antizanzare e Insetti',
      'pt': 'Spray Repelente de Insetos',
      'ru': 'Спрей от комаров и насекомых',
      'zh': '户外防蚊防虫驱蚊喷雾',
      'ja': '虫よけスプレー・蚊よけミスト',
      'ko': '모기 및 벌레 기피제 스프레이',
      'hi': 'कीट विकर्षक स्प्रे',
      'ar': 'بخاخ طارد للبعوض والحشرات',
      'nl': 'Insecten- & muggenspray',
      'el': 'Αντικουνουπικό & Εντομοαπωθητικό Σπρέι',
      'sv': 'Mygg- & insektsmedel',
      'pl': 'Spray przeciw komarom i kleszczom',
      'id': 'Semprotan Anti Nyamuk & Serangga',
      'th': 'สเปรย์กันยุงและแมลง',
      'vi': 'Xịt chống muỗi & côn trùng',
    },
    'water_filter': {
      'en': 'Steel Water Bottle & Purification Tablets',
      'tr': 'Çelik Su Matarası & Su Arıtma Tableti',
      'de': 'Edelstahl-Flasche & Wasserreinigungstabletten',
      'es': 'Botella de Acero y Pastillas Purificadoras',
      'fr': 'Gourde Inox et Pastilles Purificatrices',
      'it': 'Borraccia in Acciaio e Compresse Purificatrici',
      'pt': 'Garrafa de Água e Pastilhas de Purificação',
      'ru': 'Стальная фляга и таблетки для очистки воды',
      'zh': '不锈钢水壶及户外净水药片',
      'ja': 'ステンレス水筒＆浄水タブレット',
      'ko': '스테인리스 물병 및 정수 알약',
      'hi': 'स्टील की पानी की बोतल और जल शोधन की गोलियां',
      'ar': 'قارورة ماء من الفولاذ وأقراص تنقية المياه',
      'nl': 'Stalen waterfles & waterzuiveringstabletten',
      'el': 'Ανοξείδωτο Παγούρι & Χάπια Καθαρισμού Νερού',
      'sv': 'Stålflaska & vattenreningstabletter',
      'pl': 'Stalowa butelka i tabletki do uzdatniania wody',
      'id': 'Botol Air Baja & Tablet Pemurni Air',
      'th': 'กระบอกน้ำสแตนเลสและเม็ดฟอกน้ำบริสุทธิ์',
      'vi': 'Bình nước inox & viên lọc nước',
    },
    'jeans_joggers': {
      'en': 'Jeans & Casual Joggers',
      'tr': 'Kot Pantolon & Rahat Eşofman',
      'de': 'Jeans & bequeme Jogginghose',
      'es': 'Vaqueros y Pantalones Cómodos',
      'fr': 'Jeans et Jogging Confortable',
      'it': 'Jeans e Pantaloni della Tuta',
      'pt': 'Calça Jeans e Moletom Confortável',
      'ru': 'Джинсы и удобные спортивные штаны',
      'zh': '舒适牛仔裤与休闲卫裤',
      'ja': 'ジーンズ＆リラックスジョガーパンツ',
      'ko': '청바지 및 편안한 조거 팬츠',
      'hi': 'जींस और आरामदायक जॉगर्स',
      'ar': 'جينز وبنطال رياضي مريح',
      'nl': 'Jeans & comfortabele joggingbroek',
      'el': 'Τζιν & Άνετη Φόρμα',
      'sv': 'Jeans & bekväma mjukisbyxor',
      'pl': 'Dżinsy i wygodne spodnie dresowe',
      'id': 'Celana Jeans & Celana Santai',
      'th': 'กางเกงยีนส์และกางเกงวอร์ม',
      'vi': 'Quần bò & quần jogger thoải mái',
    },
    'casual_tshirts': {
      'en': 'T-Shirts & Light Sweatshirt',
      'tr': 'Tişörtler & Hafif Sweatshirt',
      'de': 'T-Shirts & leichtes Sweatshirt',
      'es': 'Camisetas y Sudadera Ligera',
      'fr': 'T-shirts et Sweat Léger',
      'it': 'T-shirt e Felpa Leggera',
      'pt': 'Camisetas e Moletom Leve',
      'ru': 'Футболки и легкий свитшот',
      'zh': '休闲T恤与薄款卫衣',
      'ja': 'Tシャツ＆薄手スウェット',
      'ko': '티셔츠 및 가벼운 맨투맨',
      'hi': 'टी-शर्ट और हल्की स्वेटशर्ट',
      'ar': 'تيشيرتات وسترة خفيفة',
      'nl': 'T-shirts & lichte sweater',
      'el': 'T-shirts & Ελαφρύ Φούτερ',
      'sv': 'T-shirts & lätt sweatshirt',
      'pl': 'Koszulki i lekka bluza',
      'id': 'Kaos & Kaos Lengan Panjang Ringan',
      'th': 'เสื้อยืดและเสื้อกันหนาวแบบบาง',
      'vi': 'Áo phông & áo nỉ mỏng',
    },
    'umbrella': {
      'en': 'Compact Umbrella & Windbreaker',
      'tr': 'Katlanabilir Cep Şemsiyesi / Yağmurluk',
      'de': 'Kompakter Taschenschirm / Windjacke',
      'es': 'Paraguas Plegable y Cortavientos',
      'fr': 'Parapluie de Poche et Coupe-Vent',
      'it': 'Ombrello Tascabile e Antivento',
      'pt': 'Guarda-Chuva de Bolso e Corta-Vento',
      'ru': 'Складной карманный зонт / ветровка',
      'zh': '便携折叠雨伞 / 防风外套',
      'ja': '折りたたみ傘・ウィンドブレーカー',
      'ko': '접이식 휴대용 우산 / 바람막이',
      'hi': 'छोटा फोल्डिंग छाता और विंडब्रेकर',
      'ar': 'مظلة جيب قابلة للطي وسترة واقية',
      'nl': 'Opvouwbare paraplu & windjack',
      'el': 'Πτυσσόμενη Ομπρέλα Τσέπης & Αντιανεμικό',
      'sv': 'Hopfällbart paraply & vindjacka',
      'pl': 'Składany parasol kieszonkowy / wiatrówka',
      'id': 'Payung Lipat Ringkas & Jaket Angin',
      'th': 'ร่มพับพกพาและเสื้อกันลม',
      'vi': 'Ô gấp gọn bỏ túi & áo gió',
    },
    'id_cards': {
      'en': 'ID, Passport & Transit Cards',
      'tr': 'Kimlik, Pasaport & Ulaşım Kartları',
      'de': 'Ausweis, Pass & Fahrkarten',
      'es': 'DNI, Pasaporte y Tarjetas de Transporte',
      'fr': 'Carte d\'Identité, Passeport et Titres de Transport',
      'it': 'Carta d\'Identità, Passaporto e Tessere Trasporto',
      'pt': 'Identidade, Passaporte e Cartões de Transporte',
      'ru': 'Удостоверение, паспорт и проездные карты',
      'zh': '身份证、护照及公共交通乘车卡',
      'ja': '身分証明書・パスポート＆交通ICカード',
      'ko': '신분증, 여권 및 교통카드',
      'hi': 'पहचान पत्र, पासपोर्ट और ट्रांजिट कार्ड',
      'ar': 'الهوية وجواز السفر وبطاقات المواصلات',
      'nl': 'ID, paspoort & ov-kaarten',
      'el': 'Ταυτότητα, Διαβατήριο & Κάρτες Συγκοινωνιών',
      'sv': 'ID, pass & resekort',
      'pl': 'Dowód tożsamości, paszport i karty miejskie',
      'id': 'KTP, Paspor & Kartu Transportasi',
      'th': 'บัตรประจำตัว หนังสือเดินทาง และบัตรโดยสาร',
      'vi': 'Căn cước, hộ chiếu & thẻ phương tiện công cộng',
    },
  };

  /// Returns the dynamically localized name for any stored item title based on user language.
  /// If the item is recognized from the canonical catalog, returns the localized equivalent.
  /// If it is a custom item typed by the user, returns the stored title as-is.
  static String getLocalizedItemName(String storedName, String languageCode) {
    final canonicalKey = resolveCanonicalKey(storedName);
    if (canonicalKey == null) {
      return storedName;
    }

    final keyTranslations = _translations[canonicalKey];
    if (keyTranslations == null) {
      return storedName;
    }

    final lang = languageCode.toLowerCase().split('_').first;
    return keyTranslations[lang] ?? keyTranslations['en'] ?? keyTranslations['tr'] ?? storedName;
  }
}
