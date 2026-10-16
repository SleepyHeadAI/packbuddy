// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('lib/l10n/app_en.arb');
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

  // 1. Update English ARB
  enJson['annualSave'] = 'Save 58%';

  final newEnKeys = <String, String>{
    'perMonth': '/ mo',
    'perYear': '/ yr',
    'storeBillingRequiredTitle': 'Store Billing Required',
    'storeBillingRequiredMessage':
        'Official Google Play & App Store billing is currently being activated for this production build. Subscription transactions cannot be bypassed for free.',
    'adminTestPurchaseTitle': 'Admin / Sandbox Test Purchase',
    'adminTestPurchaseMessage':
        'You are signed in as Super Admin. Would you like to confirm and activate PackBuddy Pro test subscription?',
    'activateTestPro': 'Activate Pro (Test)',
    'templateSummerTitle': 'Beach & Summer Vacation',
    'templateSummerDesc':
        'Essential packing list for sea, sand, sun, and warm weather getaways',
    'templateWinterTitle': 'Winter & Ski Trip',
    'templateWinterDesc':
        'Protective gear and warm layers for cold climates and ski resorts',
    'templateBusinessTitle': 'Business & Conference',
    'templateBusinessDesc':
        'Tailored packing list for meetings, conferences, and corporate trips',
    'templateCampingTitle': 'Nature & Camping Expedition',
    'templateCampingDesc':
        'Durable outdoor gear for tent camping, trekking, and hiking',
    'templateCityTitle': 'Weekend City Break',
    'templateCityDesc':
        'Lightweight and compact essentials for a 2-3 day city getaway',
  };

  for (final entry in newEnKeys.entries) {
    enJson[entry.key] = entry.value;
    enJson['@${entry.key}'] = {
      'description': 'Localization key for ${entry.key}',
    };
  }

  const encoder = JsonEncoder.withIndent('  ');
  enFile.writeAsStringSync(encoder.convert(enJson));
  print('Updated app_en.arb with ${newEnKeys.length} new keys and updated annualSave.');

  // 2. Translations for all 19 other languages
  final Map<String, Map<String, String>> translations = {
    'tr': {
      'annualSave': '%58 Tasarruf',
      'perMonth': '/ ay',
      'perYear': '/ yıl',
      'storeBillingRequiredTitle': 'Mağaza Ödemesi Gerekli',
      'storeBillingRequiredMessage':
          'Resmi Google Play ve App Store mağaza ödemeleri bu sürüm için etkinleştirilmektedir. Abonelik işlemleri ücretsiz olarak atlanamaz.',
      'adminTestPurchaseTitle': 'Yönetici / Sandbox Test Satın Alımı',
      'adminTestPurchaseMessage':
          'Süper Yönetici olarak oturum açtınız. PackBuddy Pro test aboneliğini onaylayıp aktifleştirmek istiyor musunuz?',
      'activateTestPro': "Pro'yu Aktifleştir (Test)",
      'templateSummerTitle': 'Plaj & Yaz Tatili',
      'templateSummerDesc':
          'Deniz, kum, güneş ve sıcak hava kaçamakları için eksiksiz bavul hazırlığı',
      'templateWinterTitle': 'Kış & Kayak Seyahati',
      'templateWinterDesc':
          'Soğuk iklimler, kayak merkezleri ve kış tatili için koruyucu donanımlar',
      'templateBusinessTitle': 'İş & Konferans Seyahati',
      'templateBusinessDesc':
          'Toplantılar, konferanslar ve profesyonel iş gezileri için kusursuz bavul',
      'templateCampingTitle': 'Doğa & Kamp Keşfi',
      'templateCampingDesc':
          'Çadır kampı, trekking ve doğa yürüyüşleri için dayanıklı ekipmanlar',
      'templateCityTitle': 'Hafta Sonu Şehir Turu',
      'templateCityDesc':
          'Pratik sırt çantasıyla 2-3 günlük rahat ve kompakt şehir kaçamağı',
    },
    'de': {
      'annualSave': '58% Sparen',
      'perMonth': '/ Monat',
      'perYear': '/ Jahr',
      'storeBillingRequiredTitle': 'Store-Abrechnung erforderlich',
      'storeBillingRequiredMessage':
          'Die offizielle Abrechnung über Google Play und den App Store wird derzeit für dieses Build aktiviert. Abonnements können nicht kostenlos freigeschaltet werden.',
      'adminTestPurchaseTitle': 'Admin / Sandbox Testkauf',
      'adminTestPurchaseMessage':
          'Sie sind als Super-Admin angemeldet. Möchten Sie das PackBuddy Pro-Testabonnement bestätigen und aktivieren?',
      'activateTestPro': 'Pro aktivieren (Test)',
      'templateSummerTitle': 'Strand- & Sommerurlaub',
      'templateSummerDesc':
          'Vollständige Packliste für Meer, Strand, Sonne und warmes Wetter',
      'templateWinterTitle': 'Winter- & Skiurlaub',
      'templateWinterDesc':
          'Schutzkleidung und Ausrüstung für kalte Klimazonen und Skigebiete',
      'templateBusinessTitle': 'Geschäfts- & Konferenzreise',
      'templateBusinessDesc':
          'Maßgeschneiderte Packliste für Meetings, Konferenzen und Dienstreisen',
      'templateCampingTitle': 'Natur- & Campingabenteuer',
      'templateCampingDesc':
          'Strapazierfähige Outdoor-Ausrüstung für Zeltcamping und Wandern',
      'templateCityTitle': 'Wochenend-Städtetrip',
      'templateCityDesc':
          'Leichte und kompakte Basics für einen 2-3-tägigen Städtetrip',
    },
    'es': {
      'annualSave': 'Ahorra 58%',
      'perMonth': '/ mes',
      'perYear': '/ año',
      'storeBillingRequiredTitle': 'Facturación de tienda requerida',
      'storeBillingRequiredMessage':
          'La facturación oficial de Google Play y App Store se está activando para esta versión. Las suscripciones no se pueden omitir de forma gratuita.',
      'adminTestPurchaseTitle': 'Compra de prueba de administrador / Sandbox',
      'adminTestPurchaseMessage':
          'Has iniciado sesión como Superadministrador. ¿Deseas confirmar y activar la suscripción de prueba de PackBuddy Pro?',
      'activateTestPro': 'Activar Pro (Prueba)',
      'templateSummerTitle': 'Playa y Vacaciones de Verano',
      'templateSummerDesc':
          'Lista completa para el mar, arena, sol y escapadas de clima cálido',
      'templateWinterTitle': 'Viaje de Invierno y Esquí',
      'templateWinterDesc':
          'Equipamiento protector y prendas de abrigo para climas fríos y estaciones de esquí',
      'templateBusinessTitle': 'Negocios y Conferencias',
      'templateBusinessDesc':
          'Equipaje ideal para reuniones de trabajo, conferencias y viajes corporativos',
      'templateCampingTitle': 'Naturaleza y Acampada',
      'templateCampingDesc':
          'Equipo duradero para acampada en tienda, senderismo y trekking',
      'templateCityTitle': 'Escapada Urbana de Fin de Semana',
      'templateCityDesc':
          'Esenciales ligeros y prácticos para una escapada urbana de 2 o 3 días',
    },
    'fr': {
      'annualSave': 'Économisez 58%',
      'perMonth': '/ mois',
      'perYear': '/ an',
      'storeBillingRequiredTitle': 'Facturation du Store requise',
      'storeBillingRequiredMessage':
          "La facturation officielle Google Play et App Store est en cours d'activation pour cette version. Les abonnements ne peuvent pas être obtenus gratuitement.",
      'adminTestPurchaseTitle': 'Achat test administrateur / Sandbox',
      'adminTestPurchaseMessage':
          'Vous êtes connecté en tant que Super Admin. Souhaitez-vous confirmer et activer l\'abonnement test PackBuddy Pro ?',
      'activateTestPro': 'Activer Pro (Test)',
      'templateSummerTitle': 'Plage & Vacances d\'été',
      'templateSummerDesc':
          'Liste complète pour la mer, le sable, le soleil et les escapades estivales',
      'templateWinterTitle': 'Voyage Hiver & Ski',
      'templateWinterDesc':
          'Équipement de protection et vêtements chauds pour le ski et le grand froid',
      'templateBusinessTitle': 'Affaires & Conférence',
      'templateBusinessDesc':
          'Bagage soigné pour réunions, conférences et déplacements professionnels',
      'templateCampingTitle': 'Nature & Camping',
      'templateCampingDesc':
          'Matériel robuste pour le camping sous tente, la randonnée et le trekking',
      'templateCityTitle': 'Week-end en Ville',
      'templateCityDesc':
          'Bagage léger et pratique pour une escapade citadine de 2 à 3 jours',
    },
    'it': {
      'annualSave': 'Risparmia il 58%',
      'perMonth': '/ mese',
      'perYear': '/ anno',
      'storeBillingRequiredTitle': 'Fatturazione dello Store richiesta',
      'storeBillingRequiredMessage':
          'La fatturazione ufficiale di Google Play e App Store è in fase di attivazione per questa versione. Gli abbonamenti non possono essere ignorati gratuitamente.',
      'adminTestPurchaseTitle': 'Acquisto di prova amministratore / Sandbox',
      'adminTestPurchaseMessage':
          'Hai effettuato l\'accesso come Super Admin. Vuoi confermare e attivare l\'abbonamento di prova a PackBuddy Pro?',
      'activateTestPro': 'Attiva Pro (Test)',
      'templateSummerTitle': 'Spiaggia e Vacanze Estive',
      'templateSummerDesc':
          'Lista completa per mare, sabbia, sole e mete calde',
      'templateWinterTitle': 'Viaggio Invernale e Sci',
      'templateWinterDesc':
          'Attrezzatura protettiva e capi caldi per climi freddi e settimane bianche',
      'templateBusinessTitle': 'Lavoro e Conferenze',
      'templateBusinessDesc':
          'Bagaglio perfetto per meeting, congressi e viaggi aziendali',
      'templateCampingTitle': 'Natura e Campeggio',
      'templateCampingDesc':
          'Attrezzatura outdoor resistente per campeggio in tenda e trekking',
      'templateCityTitle': 'Weekend in Città',
      'templateCityDesc':
          'Bagaglio compatto e leggero per un city break di 2-3 giorni',
    },
    'pt': {
      'annualSave': 'Economize 58%',
      'perMonth': '/ mês',
      'perYear': '/ ano',
      'storeBillingRequiredTitle': 'Faturamento da loja necessário',
      'storeBillingRequiredMessage':
          'O faturamento oficial do Google Play e da App Store está sendo ativado para esta versão. As assinaturas não podem ser ignoradas gratuitamente.',
      'adminTestPurchaseTitle': 'Compra de teste do administrador / Sandbox',
      'adminTestPurchaseMessage':
          'Você está conectado como Super Admin. Deseja confirmar e ativar a assinatura de teste do PackBuddy Pro?',
      'activateTestPro': 'Ativar Pro (Teste)',
      'templateSummerTitle': 'Praia e Férias de Verão',
      'templateSummerDesc':
          'Lista essencial para mar, areia, sol e destinos de clima quente',
      'templateWinterTitle': 'Viagem de Inverno e Esqui',
      'templateWinterDesc':
          'Roupas térmicas e equipamentos de proteção para destinos frios e estações de esqui',
      'templateBusinessTitle': 'Trabalho e Conferências',
      'templateBusinessDesc':
          'Mala sob medida para reuniões, congressos e viagens de negócios',
      'templateCampingTitle': 'Natureza e Acampamento',
      'templateCampingDesc':
          'Equipamentos duráveis para acampar em barraca, trilhas e trekking',
      'templateCityTitle': 'Fim de Semana na Cidade',
      'templateCityDesc':
          'Mochila leve e compacta para um passeio de 2 a 3 dias na cidade',
    },
    'ru': {
      'annualSave': 'Скидка 58%',
      'perMonth': '/ мес',
      'perYear': '/ год',
      'storeBillingRequiredTitle': 'Требуется биллинг магазина',
      'storeBillingRequiredMessage':
          'Официальный биллинг Google Play и App Store в настоящее время активируется для этой сборки. Подписку нельзя активировать бесплатно.',
      'adminTestPurchaseTitle': 'Тестовая покупка администратора / Sandbox',
      'adminTestPurchaseMessage':
          'Вы вошли как супер-администратор. Хотите подтвердить и активировать тестовую подписку PackBuddy Pro?',
      'activateTestPro': 'Активировать Pro (Тест)',
      'templateSummerTitle': 'Пляж и Летний Отпуск',
      'templateSummerDesc':
          'Полный список вещей для моря, песка, солнца и теплого отдыха',
      'templateWinterTitle': 'Зимний Отдых и Горные Лыжи',
      'templateWinterDesc':
          'Теплая одежда и экипировка для холодных стран и горнолыжных курортов',
      'templateBusinessTitle': 'Бизнес и Конференции',
      'templateBusinessDesc':
          'Идеальный багаж для деловых встреч, конференций и командировок',
      'templateCampingTitle': 'Природа и Кемпинг',
      'templateCampingDesc':
          'Надежное снаряжение для палаточного лагеря, походов и треккинга',
      'templateCityTitle': 'Выходные в Городе',
      'templateCityDesc':
          'Удобный и компактный рюкзак для короткой поездки на 2-3 дня',
    },
    'zh': {
      'annualSave': '省58%',
      'perMonth': '/月',
      'perYear': '/年',
      'storeBillingRequiredTitle': '需要商店结算',
      'storeBillingRequiredMessage':
          '官方 Google Play 与 App Store 商店支付正在为该正式版激活中。不可免费跳过购买订阅。',
      'adminTestPurchaseTitle': '管理员 / 沙盒测试购买',
      'adminTestPurchaseMessage':
          '您已作为超级管理员登录。是否确认并激活 PackBuddy Pro 测试订阅？',
      'activateTestPro': '激活 Pro (测试)',
      'templateSummerTitle': '海滩与夏日度假',
      'templateSummerDesc': '专为阳光、沙滩和温暖假期打造的行李打包清单',
      'templateWinterTitle': '冬季与滑雪之旅',
      'templateWinterDesc': '应对寒冷气候和滑雪胜地的防护保暖装备清单',
      'templateBusinessTitle': '商务与差旅会议',
      'templateBusinessDesc': '适合商务谈判、行业会议和出差的专业行李配置',
      'templateCampingTitle': '户外露营与徒步',
      'templateCampingDesc': '帐篷露营、野外穿越与徒步探险的耐用专业装备',
      'templateCityTitle': '周末城市漫游',
      'templateCityDesc': '轻松紧凑的双肩包出行，适合2-3天城市短途游',
    },
    'ja': {
      'annualSave': '58%お得',
      'perMonth': '/月',
      'perYear': '/年',
      'storeBillingRequiredTitle': 'ストア決済が必要です',
      'storeBillingRequiredMessage':
          '公式のGoogle PlayおよびApp Storeの決済は、本製品版向けに有効化の準備中です。無料でProを有効化することはできません。',
      'adminTestPurchaseTitle': '管理者 / サンドボックス テスト購入',
      'adminTestPurchaseMessage':
          'スーパー管理者としてログインしています。PackBuddy Proのテストサブスクリプションを確定して有効化しますか？',
      'activateTestPro': 'Proを有効化 (テスト)',
      'templateSummerTitle': 'ビーチ＆夏休み旅行',
      'templateSummerDesc': '海、砂浜、太陽、暖かいリゾートに最適なパッキングリスト',
      'templateWinterTitle': '冬＆スキースノボ旅行',
      'templateWinterDesc': '寒冷地やスキー場向けの防寒具と保護用ギア一式',
      'templateBusinessTitle': 'ビジネス＆カンファレンス出張',
      'templateBusinessDesc': '商談、会議、出張に最適なプロフェッショナル装備',
      'templateCampingTitle': '大自然＆キャンプ探検',
      'templateCampingDesc': 'テント泊、トレッキング、ハイキングに適したアウトドアギア',
      'templateCityTitle': '週末シティトリップ',
      'templateCityDesc': '2〜3日の都市旅行にぴったりの身軽でコンパクトなバックパック',
    },
    'ko': {
      'annualSave': '58% 절약',
      'perMonth': '/월',
      'perYear': '/년',
      'storeBillingRequiredTitle': '스토어 결제가 필요합니다',
      'storeBillingRequiredMessage':
          '공식 Google Play 및 App Store 인앱 결제가 현재 본 프로덕션 빌드용으로 활성화되는 중입니다. 무료로 구독을 우회할 수 없습니다.',
      'adminTestPurchaseTitle': '관리자 / 샌드박스 테스트 구매',
      'adminTestPurchaseMessage':
          '최고 관리자로 로그인되어 있습니다. PackBuddy Pro 테스트 구독을 확인하고 활성화하시겠습니까?',
      'activateTestPro': 'Pro 활성화 (테스트)',
      'templateSummerTitle': '해변 및 여름 휴가',
      'templateSummerDesc': '바다, 모래사장, 햇살, 따뜻한 날씨를 위한 완벽한 짐 꾸리기',
      'templateWinterTitle': '겨울 및 스키 여행',
      'templateWinterDesc': '추운 날씨와 스키장을 위한 방한복 및 안전 장비',
      'templateBusinessTitle': '비즈니스 및 콘퍼런스 출장',
      'templateBusinessDesc': '회의, 포럼, 비즈니스 출장에 최적화된 스마트 패킹',
      'templateCampingTitle': '자연 탐험 및 캠핑',
      'templateCampingDesc': '텐트 캠핑, 트레킹, 등산을 위한 튼튼한 아웃도어 장비',
      'templateCityTitle': '주말 도시 여행',
      'templateCityDesc': '2~3일간의 가볍고 편리한 도심 여행을 위한 콤팩트 배낭',
    },
    'hi': {
      'annualSave': '58% बचत',
      'perMonth': '/माह',
      'perYear': '/वर्ष',
      'storeBillingRequiredTitle': 'स्टोर बिलिंग आवश्यक है',
      'storeBillingRequiredMessage':
          'इस उत्पादन संस्करण के लिए आधिकारिक Google Play और App Store बिलिंग सक्रिय की जा रही है। सदस्यता को निःशुल्क बाईपास नहीं किया जा सकता है।',
      'adminTestPurchaseTitle': 'व्यवस्थापक / सैंडबॉक्स परीक्षण खरीद',
      'adminTestPurchaseMessage':
          'आप सुपर एडमिन के रूप में लॉग इन हैं। क्या आप PackBuddy Pro परीक्षण सदस्यता की पुष्टि और सक्रिय करना चाहते हैं?',
      'activateTestPro': 'Pro सक्रिय करें (परीक्षण)',
      'templateSummerTitle': 'समुद्र तट और गर्मी की छुट्टियां',
      'templateSummerDesc':
          'धूप, रेत और गर्म मौसम की यात्राओं के लिए आवश्यक पैकिंग सूची',
      'templateWinterTitle': 'सर्दियों और स्की यात्रा',
      'templateWinterDesc':
          'ठंडे मौसम और स्की रिसॉर्ट के लिए गर्म कपड़े और सुरक्षात्मक उपकरण',
      'templateBusinessTitle': 'व्यापार और सम्मेलन यात्रा',
      'templateBusinessDesc':
          'व्यावसायिक बैठकों, सम्मेलनों और कॉर्पोरेट दौरों के लिए पैकिंग सूची',
      'templateCampingTitle': 'प्रकृति और कैम्पिंग अभियान',
      'templateCampingDesc':
          'टेंट कैंपिंग, ट्रैकिंग और लंबी पैदल यात्रा के लिए मजबूत उपकरण',
      'templateCityTitle': 'सप्ताहांत शहर का दौरा',
      'templateCityDesc':
          '2-3 दिनों की शहर की यात्रा के लिए हल्का और सुविधाजनक बैग',
    },
    'ar': {
      'annualSave': 'وفّر 58%',
      'perMonth': '/شهر',
      'perYear': '/سنة',
      'storeBillingRequiredTitle': 'الدفع عبر المتجر مطلوب',
      'storeBillingRequiredMessage':
          'تجري حاليًا تهيئة الدفع الرسمي عبر متجري Google Play وApp Store لهذا الإصدار. لا يمكن تفعيل الاشتراك مجانًا.',
      'adminTestPurchaseTitle': 'شراء تجريبي للمسؤول / Sandbox',
      'adminTestPurchaseMessage':
          'لقد سجلت الدخول كمسؤول رئيسي. هل ترغب في تأكيد وتفعيل اشتراك PackBuddy Pro التجريبي؟',
      'activateTestPro': 'تفعيل Pro (تجريبي)',
      'templateSummerTitle': 'الشاطئ وعطلة الصيف',
      'templateSummerDesc':
          'قائمة أمتعة متكاملة للبحر والشمس والرحلات الصيفية الدافئة',
      'templateWinterTitle': 'رحلة الشتاء والتزلج',
      'templateWinterDesc':
          'معدات واقية وملابس دافئة للمناطق الباردة ومنتجعات التزلج',
      'templateBusinessTitle': 'رحلة عمل ومؤتمرات',
      'templateBusinessDesc':
          'حقيبة سفر مهنية مخصصة للاجتماعات والمؤتمرات ورحلات العمل',
      'templateCampingTitle': 'استكشاف الطبيعة والتخييم',
      'templateCampingDesc':
          'معدات خارجية متينة وموثوقة للتخييم والمسارات الجبلية',
      'templateCityTitle': 'جولة نهاية الأسبوع في المدينة',
      'templateCityDesc':
          'حقيبة ظهر خفيفة ومريحة لرحلة استكشافية بالمدينة مدتها 2-3 أيام',
    },
    'nl': {
      'annualSave': 'Bespaar 58%',
      'perMonth': '/mnd',
      'perYear': '/jr',
      'storeBillingRequiredTitle': 'Store-betaling vereist',
      'storeBillingRequiredMessage':
          'Officiële facturering via Google Play en de App Store wordt momenteel geactiveerd voor deze versie. Abonnementen kunnen niet gratis worden omzeild.',
      'adminTestPurchaseTitle': 'Beheerder / Sandbox test aankoop',
      'adminTestPurchaseMessage':
          'U bent ingelogd als hoofdbeheerder. Wilt u het PackBuddy Pro-testabonnement bevestigen en activeren?',
      'activateTestPro': 'Activeer Pro (Test)',
      'templateSummerTitle': 'Strand & Zomervakantie',
      'templateSummerDesc':
          'Complete inpaklijst voor zon, zee, strand en warme bestemmingen',
      'templateWinterTitle': 'Winter- & Skivakantie',
      'templateWinterDesc':
          'Beschermende kleding en warme uitrusting voor koude oorden en skigebieden',
      'templateBusinessTitle': 'Zaken- & Conferentiereis',
      'templateBusinessDesc':
          'Strakke bagage voor vergaderingen, conferenties en zakelijke bezoeken',
      'templateCampingTitle': 'Natuur- & Kampeeravontuur',
      'templateCampingDesc':
          'Stevige uitrusting voor tentkamperen, trektochten en wandelingen',
      'templateCityTitle': 'Weekendje Stad',
      'templateCityDesc':
          'Compacte en lichte rugzak voor een 2-3 daagse stedentrip',
    },
    'el': {
      'annualSave': 'Έκπτωση 58%',
      'perMonth': '/μήνα',
      'perYear': '/έτος',
      'storeBillingRequiredTitle': 'Απαιτείται χρέωση καταστήματος',
      'storeBillingRequiredMessage':
          'Η επίσημη χρέωση Google Play και App Store ενεργοποιείται για αυτήν την έκδοση. Οι συνδρομές δεν μπορούν να παρακαμφθούν δωρεάν.',
      'adminTestPurchaseTitle': 'Δοκιμαστική αγορά διαχειριστή / Sandbox',
      'adminTestPurchaseMessage':
          'Έχετε συνδεθεί ως Super Admin. Θέλετε να επιβεβαιώσετε και να ενεργοποιήσετε τη δοκιμαστική συνδρομή PackBuddy Pro;',
      'activateTestPro': 'Ενεργοποίηση Pro (Δοκιμή)',
      'templateSummerTitle': 'Παραλία & Καλοκαιρινές Διακοπές',
      'templateSummerDesc':
          'Πλήρης λίστα για θάλασσα, άμμο, ήλιο και ζεστούς προορισμούς',
      'templateWinterTitle': 'Χειμερινό Ταξίδι & Σκι',
      'templateWinterDesc':
          'Ζεστά ρούχα και εξοπλισμός προστασίας για χιονοδρομικά και κρύο κλίμα',
      'templateBusinessTitle': 'Επαγγελματικό Ταξίδι & Συνέδριο',
      'templateBusinessDesc':
          'Κομψές αποσκευές για συναντήσεις, συνέδρια και επαγγελματικά ταξίδια',
      'templateCampingTitle': 'Φύση & Κατασκήνωση',
      'templateCampingDesc':
          'Ανθεκτικός εξοπλισμός για κάμπινγκ, ορειβασία και πεζοπορία',
      'templateCityTitle': 'Απόδραση Σαββατοκύριακου στην Πόλη',
      'templateCityDesc':
          'Πρακτικό και άνετο σακίδιο για ένα 2ήμερο ή 3ήμερο city break',
    },
    'sv': {
      'annualSave': 'Spara 58%',
      'perMonth': '/mån',
      'perYear': '/år',
      'storeBillingRequiredTitle': 'Butiksdebitering krävs',
      'storeBillingRequiredMessage':
          'Officiell fakturering via Google Play och App Store aktiveras för denna version. Prenumerationer kan inte kringgås gratis.',
      'adminTestPurchaseTitle': 'Admin / Sandbox testköp',
      'adminTestPurchaseMessage':
          'Du är inloggad som superadministratör. Vill du bekräfta och aktivera PackBuddy Pro-testprenumerationen?',
      'activateTestPro': 'Aktivera Pro (Test)',
      'templateSummerTitle': 'Strand & Sommarsemester',
      'templateSummerDesc':
          'Komplett packlista för sol, bad, strand och varma resmål',
      'templateWinterTitle': 'Vinter- & Skidresa',
      'templateWinterDesc':
          'Skyddande utrustning och varma lager för kalla klimat och skidorter',
      'templateBusinessTitle': 'Affärsresa & Konferens',
      'templateBusinessDesc':
          'Professionell packning för möten, konferenser och tjänsteresor',
      'templateCampingTitle': 'Natur & Campingexpedition',
      'templateCampingDesc':
          'Tålig utrustning för tältning, vandring och friluftsliv',
      'templateCityTitle': 'Weekend i Stan',
      'templateCityDesc':
          'Lätt och kompakt packning för en 2-3 dagars storstadshelg',
    },
    'pl': {
      'annualSave': 'Zaoszczędź 58%',
      'perMonth': '/mies.',
      'perYear': '/rok',
      'storeBillingRequiredTitle': 'Wymagana płatność w sklepie',
      'storeBillingRequiredMessage':
          'Oficjalne rozliczenia w Google Play i App Store są obecnie aktywowane dla tej wersji. Subskrypcji nie można aktywować bezpłatnie.',
      'adminTestPurchaseTitle': 'Zakup testowy administratora / Sandbox',
      'adminTestPurchaseMessage':
          'Jesteś zalogowany jako Super Administrator. Czy chcesz potwierdzić i aktywować subskrypcję testową PackBuddy Pro?',
      'activateTestPro': 'Aktywuj Pro (Test)',
      'templateSummerTitle': 'Plaża i Letnie Wakacje',
      'templateSummerDesc':
          'Niezbędna lista rzeczy na morze, piasek, słońce i ciepłe dni',
      'templateWinterTitle': 'Zimowy Wyjazd i Narty',
      'templateWinterDesc':
          'Odzież ochronna i ciepły ekwipunek na mroźny klimat i stoki narciarskie',
      'templateBusinessTitle': 'Biznes i Konferencje',
      'templateBusinessDesc':
          'Profesjonalny bagaż na spotkania, konferencje i wyjazdy służbowe',
      'templateCampingTitle': 'Natura i Biwak',
      'templateCampingDesc':
          'Trwały ekwipunek na biwak pod namiotem, trekking i piesze wędrówki',
      'templateCityTitle': 'Weekendowy City Break',
      'templateCityDesc':
          'Lekki i kompaktowy plecak na 2-3 dniowy wypad do miasta',
    },
    'id': {
      'annualSave': 'Hemat 58%',
      'perMonth': '/bln',
      'perYear': '/thn',
      'storeBillingRequiredTitle': 'Penagihan Toko Diperlukan',
      'storeBillingRequiredMessage':
          'Penagihan resmi Google Play & App Store saat ini sedang diaktifkan untuk build ini. Transaksi langganan tidak dapat dilewati secara gratis.',
      'adminTestPurchaseTitle': 'Pembelian Uji Coba Admin / Sandbox',
      'adminTestPurchaseMessage':
          'Anda masuk sebagai Super Admin. Apakah Anda ingin mengonfirmasi dan mengaktifkan langganan uji coba PackBuddy Pro?',
      'activateTestPro': 'Aktifkan Pro (Uji Coba)',
      'templateSummerTitle': 'Pantai & Liburan Musim Panas',
      'templateSummerDesc':
          'Daftar barang penting untuk laut, pasir, matahari, dan liburan tropis',
      'templateWinterTitle': 'Liburan Musim Dingin & Ski',
      'templateWinterDesc':
          'Pakaian pelindung dan perlengkapan hangat untuk iklim dingin dan resor ski',
      'templateBusinessTitle': 'Bisnis & Konferensi',
      'templateBusinessDesc':
          'Koper rapi untuk pertemuan, konferensi, dan perjalanan dinas',
      'templateCampingTitle': 'Petualangan Alam & Berkemah',
      'templateCampingDesc':
          'Peralatan luar ruangan tangguh untuk berkemah dengan tenda dan trekking',
      'templateCityTitle': 'Wisata Akhir Pekan di Kota',
      'templateCityDesc':
          'Ransel ringkas dan praktis untuk liburan kota selama 2-3 hari',
    },
    'th': {
      'annualSave': 'ประหยัด 58%',
      'perMonth': '/เดือน',
      'perYear': '/ปี',
      'storeBillingRequiredTitle': 'จำเป็นต้องชำระเงินผ่านสโตร์',
      'storeBillingRequiredMessage':
          'ระบบชำระเงิน Google Play และ App Store กำลังเปิดใช้งานสำหรับเวอร์ชันนี้ ไม่สามารถข้ามการสมัครเพื่อรับสิทธิ์ฟรีได้',
      'adminTestPurchaseTitle': 'การสั่งซื้อทดสอบของผู้ดูแลระบบ / Sandbox',
      'adminTestPurchaseMessage':
          'คุณเข้าสู่ระบบในฐานะผู้ดูแลระบบระดับสูง คุณต้องการยืนยันและเปิดใช้งานการทดสอบสมาชิก PackBuddy Pro หรือไม่?',
      'activateTestPro': 'เปิดใช้งาน Pro (ทดสอบ)',
      'templateSummerTitle': 'ชายหาดและวันหยุดฤดูร้อน',
      'templateSummerDesc':
          'รายการจัดกระเป๋าครบครันสำหรับทะเล ทราย แสงแดด และวันพักผ่อน',
      'templateWinterTitle': 'ทริปฤดูหนาวและสกี',
      'templateWinterDesc':
          'อุปกรณ์กันหนาวและเครื่องแต่งกายสำหรับเมืองหนาวและลานสกี',
      'templateBusinessTitle': 'ธุรกิจและการประชุม',
      'templateBusinessDesc':
          'กระเป๋าเดินทางมาตรฐานสำหรับประชุม สัมมนา และการเดินทางธุรกิจ',
      'templateCampingTitle': 'สำรวจธรรมชาติและแคมป์ปิ้ง',
      'templateCampingDesc':
          'อุปกรณ์กลางแจ้งทนทานสำหรับกางเต็นท์ เดินป่า และแค้มปิ้ง',
      'templateCityTitle': 'เที่ยวชมเมืองสุดสัปดาห์',
      'templateCityDesc':
          'กระเป๋าเป้กะทัดรัดคล่องตัวสำหรับทริปเที่ยวเมือง 2-3 วัน',
    },
    'vi': {
      'annualSave': 'Tiết kiệm 58%',
      'perMonth': '/tháng',
      'perYear': '/năm',
      'storeBillingRequiredTitle': 'Yêu cầu thanh toán qua cửa hàng',
      'storeBillingRequiredMessage':
          'Thanh toán chính thức qua Google Play và App Store đang được kích hoạt cho bản dựng này. Không thể bỏ qua thanh toán để nhận miễn phí.',
      'adminTestPurchaseTitle': 'Mua thử nghiệm quản trị viên / Sandbox',
      'adminTestPurchaseMessage':
          'Bạn đã đăng nhập với tư cách Quản trị viên cấp cao. Bạn có muốn xác nhận và kích hoạt đăng ký thử nghiệm PackBuddy Pro không?',
      'activateTestPro': 'Kích hoạt Pro (Thử nghiệm)',
      'templateSummerTitle': 'Bãi biển & Nghỉ dưỡng mùa hè',
      'templateSummerDesc':
          'Danh sách đồ đạc chuẩn bị cho biển, cát, nắng và thời tiết ấm áp',
      'templateWinterTitle': 'Chuyến đi mùa đông & Trượt tuyết',
      'templateWinterDesc':
          'Trang phục ấm áp và đồ bảo hộ cho khí hậu lạnh và khu trượt tuyết',
      'templateBusinessTitle': 'Công tác & Hội nghị',
      'templateBusinessDesc':
          'Hành lý chỉn chu cho các cuộc họp, hội thảo và chuyến công tác',
      'templateCampingTitle': 'Khám phá thiên nhiên & Cắm trại',
      'templateCampingDesc':
          'Trang thiết bị dã ngoại bền bỉ cho cắm trại lều và leo núi',
      'templateCityTitle': 'Dạo chơi thành phố cuối tuần',
      'templateCityDesc':
          'Balo gọn nhẹ và tiện lợi cho chuyến du lịch thành phố 2-3 ngày',
    },
  };

  final arbDir = Directory('lib/l10n');
  final arbFiles = arbDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList();

  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    if (fileName == 'app_en.arb') continue;
    final langCode = fileName.replaceAll('app_', '').replaceAll('.arb', '');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final langTranslations = translations[langCode];
    if (langTranslations != null) {
      for (final entry in langTranslations.entries) {
        data[entry.key] = entry.value;
      }
    }

    // Fallback any missing
    for (final key in newEnKeys.keys) {
      if (!data.containsKey(key)) {
        data[key] = newEnKeys[key]!;
      }
    }
    if (!data.containsKey('annualSave')) {
      data['annualSave'] = 'Save 58%';
    }

    file.writeAsStringSync(encoder.convert(data));
    print('Updated $fileName');
  }

  print('\nAll 20 ARB files successfully updated!');
}
