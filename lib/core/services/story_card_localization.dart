import '../../features/travel_map/presentation/widgets/travel_map_story_card.dart' show StoryCardLayout;

/// Centralized 20-language localization provider for Travel Map Story Share Cards (Feature F-9)
/// Guarantees 100% consistent localized strings across Instagram & Snapchat story templates.
class StoryCardLocalization {
  StoryCardLocalization._();

  static const List<String> supportedLanguages = [
    'tr', 'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
  ];

  /// 1. Classic Header: "WORLD TRAVELER" badge
  static String getWorldTravelerHeader(String lang) {
    switch (lang) {
      case 'tr': return 'DÜNYA KAŞİFİ';
      case 'es': return 'VIAJERO DEL MUNDO';
      case 'fr': return 'VOYAGEUR DU MONDE';
      case 'de': return 'WELTREISENDER';
      case 'it': return 'VIAGGIATORE DEL MONDO';
      case 'pt': return 'VIAJANTE DO MUNDO';
      case 'ru': return 'ПУТЕШЕСТВЕННИК';
      case 'zh': return '环球旅行家';
      case 'ja': return '世界旅行者';
      case 'ko': return '세계 여행자';
      case 'hi': return 'विश्व यात्री';
      case 'ar': return 'مسافر حول العالم';
      case 'nl': return 'WERELDREIZIGER';
      case 'el': return 'ΤΑΞΙΔΙΩΤΗΣ ΤΟΥ ΚΟΣΜΟΥ';
      case 'sv': return 'VÄRLDSRESENÄR';
      case 'pl': return 'PODRÓŻNIK PO ŚWIECIE';
      case 'id': return 'PENJELAJAH DUNIA';
      case 'th': return 'นักเดินทางรอบโลก';
      case 'vi': return 'NGƯỜI DU HÀNH THẾ GIỚI';
      default: return 'WORLD TRAVELER';
    }
  }

  /// 2. Minimal Header: "ATLAS ARCHIVE • %..."
  static String getAtlasArchiveHeader(String lang, double percent) {
    final pctStr = percent.toStringAsFixed(1);
    switch (lang) {
      case 'tr': return 'ATLAS ARŞİVİ • %$pctStr';
      case 'es': return 'ARCHIVO ATLAS • %$pctStr';
      case 'fr': return 'ARCHIVES ATLAS • %$pctStr';
      case 'de': return 'ATLAS-ARCHIV • %$pctStr';
      case 'it': return 'ARCHIVIO ATLAS • %$pctStr';
      case 'pt': return 'ARQUIVO ATLAS • %$pctStr';
      case 'ru': return 'АРХИВ АТЛАСА • %$pctStr';
      case 'zh': return '地图集档案 • %$pctStr';
      case 'ja': return 'アトラス・アーカイブ • %$pctStr';
      case 'ko': return '아틀라스 기록 • %$pctStr';
      case 'hi': return 'एटलस संग्रह • %$pctStr';
      case 'ar': return 'أرشيف الأطلس • %$pctStr';
      case 'nl': return 'ATLAS-ARCHIEF • %$pctStr';
      case 'el': return 'ΑΡΧΕΙΟ ΑΤΛΑΝΤΑ • %$pctStr';
      case 'sv': return 'ATLASARKIV • %$pctStr';
      case 'pl': return 'ARCHIWUM ATLASU • %$pctStr';
      case 'id': return 'ARSIP ATLAS • %$pctStr';
      case 'th': return 'บันทึกแผนที่โลก • %$pctStr';
      case 'vi': return 'LƯU TRỮ ATLAS • %$pctStr';
      default: return 'ATLAS ARCHIVE • %$pctStr';
    }
  }

  /// 3. Minimal Quote: "The world is a book..."
  static String getMinimalQuote(String lang) {
    switch (lang) {
      case 'tr':
        return '"Dünya bir kitaptır ve seyahat etmeyenler sadece tek bir sayfasını okur."';
      case 'es':
        return '"El mundo es un libro y aquellos que no viajan solo leen una página."';
      case 'fr':
        return '"Le monde est un livre et ceux qui ne voyagent pas n\'en lisent qu\'une page."';
      case 'de':
        return '"Die Welt ist ein Buch. Wer nie reist, sieht nur eine Seite davon."';
      case 'it':
        return '"Il mondo è un libro e chi non viaggia ne legge solo una pagina."';
      case 'pt':
        return '"O mundo é um livro e aqueles que não viajam leem apenas uma página."';
      case 'ru':
        return '"Мир — это книга, и те, кто не путешествуют, читают только одну страницу."';
      case 'zh':
        return '"世界是一本书，不旅行的人只读了其中一页。"';
      case 'ja':
        return '"世界は一冊の本であり、旅をしない者はその一頁しか読まない。"';
      case 'ko':
        return '"세상은 한 권의 책이며, 여행하지 않는 자는 오직 한페이지만을 읽을 뿐이다."';
      case 'hi':
        return '"यह दुनिया एक किताब है और जो यात्रा नहीं करते वे केवल एक पन्ना पढ़ते हैं।"';
      case 'ar':
        return '"العالم كتاب، ومن لا يسافر لا يقرأ سوى صفحة واحدة منه."';
      case 'nl':
        return '"De wereld is een boek en zij die niet reizen lezen slechts één pagina."';
      case 'el':
        return '"Ο κόσμος είναι ένα βιβλίο και όσοι δεν ταξιδεύουν διαβάζουν μόνο μία σελίδα."';
      case 'sv':
        return '"Världen är en bok och den som inte reser läser bara en sida."';
      case 'pl':
        return '"Świat jest książką, a ci, którzy nie podróżują, czytają tylko jedną stronę."';
      case 'id':
        return '"Dunia adalah sebuah buku dan mereka yang tidak bepergian hanya membaca satu halaman."';
      case 'th':
        return '"โลกคือหนังสือเล่มหนึ่ง และผู้ที่ไม่เดินทางก็อ่านเพียงหน้าเดียวเท่านั้น"';
      case 'vi':
        return '"Thế giới là một cuốn sách và ai không đi du lịch thì chỉ đọc được một trang."';
      default:
        return '"The world is a book and those who do not travel read only one page."';
    }
  }

  /// 4. Showcase Badge: "%... EXPLORED COUNTRIES"
  static String getShowcaseExploredBadge(String lang, int count) {
    switch (lang) {
      case 'tr': return '$count KEŞFEDİLEN ÜLKE';
      case 'es': return '$count PAÍSES EXPLORADOS';
      case 'fr': return '$count PAYS EXPLORÉS';
      case 'de': return '$count LÄNDER ERKUNDET';
      case 'it': return '$count PAESI ESPLORATI';
      case 'pt': return '$count PAÍSES EXPLORADOS';
      case 'ru': return '$count ИССЛЕДОВАННЫХ СТРАН';
      case 'zh': return '已探索 $count 个国家';
      case 'ja': return '$count か国を探索';
      case 'ko': return '$count개국 탐험';
      case 'hi': return '$count देश खोजे गए';
      case 'ar': return '$count دولة تم استكشافها';
      case 'nl': return '$count LANDEN ONTDEKT';
      case 'el': return '$count ΧΩΡΕΣ ΕΞΕΡΕΥΝΗΘΗΚΑΝ';
      case 'sv': return '$count LÄNDER UTFORSKADE';
      case 'pl': return '$count ODKRYTYCH KRAJÓW';
      case 'id': return '$count NEGARA DIJELAJAHI';
      case 'th': return 'สำรวจแล้ว $count ประเทศ';
      case 'vi': return 'ĐÃ KHÁM PHÁ $count QUỐC GIA';
      default: return '$count COUNTRIES EXPLORED';
    }
  }

  /// 5. Journey Header: "JOURNEY LOG"
  static String getJourneyLogHeader(String lang) {
    switch (lang) {
      case 'tr': return 'YOLCULUK GÜNLÜĞÜ';
      case 'es': return 'DIARIO DE VIAJE';
      case 'fr': return 'CARNET DE VOYAGE';
      case 'de': return 'REISETAGEBUCH';
      case 'it': return 'DIARIO DI VIAGGIO';
      case 'pt': return 'DIÁRIO DE BORDO';
      case 'ru': return 'ДНЕВНИК ПУТЕШЕСТВИЙ';
      case 'zh': return '旅行日志';
      case 'ja': return '旅の記録';
      case 'ko': return '여행 일지';
      case 'hi': return 'यात्रा डायरी';
      case 'ar': return 'سجل الرحلة';
      case 'nl': return 'REISJOURNAAL';
      case 'el': return 'ΗΜΕΡΟΛΟΓΙΟ ΤΑΞΙΔΙΟΥ';
      case 'sv': return 'RESEDAGBOK';
      case 'pl': return 'DZIENNIK PODRÓŻY';
      case 'id': return 'CATATAN PERJALANAN';
      case 'th': return 'บันทึกการเดินทาง';
      case 'vi': return 'NHẬT KÝ HÀNH TRÌNH';
      default: return 'JOURNEY LOG';
    }
  }

  /// 6. Exploration Rate Header: "EXPLORATION RATE"
  static String getExplorationRateHeader(String lang) {
    switch (lang) {
      case 'tr': return 'KEŞİF ORANI';
      case 'es': return 'TASA DE EXPLORACIÓN';
      case 'fr': return 'TAUX D\'EXPLORATION';
      case 'de': return 'ERKUNDUNGSRATE';
      case 'it': return 'TASSO DI ESPLORAZIONE';
      case 'pt': return 'TAXA DE EXPLORAÇÃO';
      case 'ru': return 'ПРОЦЕНТ ИССЛЕДОВАНИЯ';
      case 'zh': return '探索率';
      case 'ja': return '探索率';
      case 'ko': return '탐험률';
      case 'hi': return 'अन्वेषण दर';
      case 'ar': return 'نسبة الاستكشاف';
      case 'nl': return 'ONTDEKKINGSGRAAD';
      case 'el': return 'ΠΟΣΟΣΤΟ ΕΞΕΡΕΥΝΗΣΗΣ';
      case 'sv': return 'UTFORSKNINGSGRAD';
      case 'pl': return 'WSKAŹNIK ODKRYĆ';
      case 'id': return 'TINGKAT EKSPLORASI';
      case 'th': return 'อัตราการสำรวจ';
      case 'vi': return 'TỶ LỆ KHÁM PHÁ';
      default: return 'EXPLORATION RATE';
    }
  }

  /// 7. Countries Count Badge: "$count COUNTRIES"
  static String getCountriesCountBadge(String lang, int count) {
    switch (lang) {
      case 'tr': return '$count ÜLKE';
      case 'es': return '$count PAÍSES';
      case 'fr': return '$count PAYS';
      case 'de': return '$count LÄNDER';
      case 'it': return '$count PAESI';
      case 'pt': return '$count PAÍSES';
      case 'ru': return '$count СТРАН';
      case 'zh': return '$count 个国家';
      case 'ja': return '$count か国';
      case 'ko': return '$count개국';
      case 'hi': return '$count देश';
      case 'ar': return '$count دولة';
      case 'nl': return '$count LANDEN';
      case 'el': return '$count ΧΩΡΕΣ';
      case 'sv': return '$count LÄNDER';
      case 'pl': return '$count KRAJÓW';
      case 'id': return '$count NEGARA';
      case 'th': return '$count ประเทศ';
      case 'vi': return '$count QUỐC GIA';
      default: return '$count COUNTRIES';
    }
  }

  /// 8. Continents Count Badge: "$count CONTINENTS"
  static String getContinentsCountBadge(String lang, int count) {
    switch (lang) {
      case 'tr': return '$count KITA';
      case 'es': return '$count CONTINENTES';
      case 'fr': return '$count CONTINENTS';
      case 'de': return '$count KONTINENTE';
      case 'it': return '$count CONTINENTI';
      case 'pt': return '$count CONTINENTES';
      case 'ru': return '$count КОНТИНЕНТОВ';
      case 'zh': return '$count 个大洲';
      case 'ja': return '$count 大陸';
      case 'ko': return '$count개 대륙';
      case 'hi': return '$count महाद्वीप';
      case 'ar': return '$count قارات';
      case 'nl': return '$count CONTINENTEN';
      case 'el': return '$count ΗΠΕΙΡΟΙ';
      case 'sv': return '$count KONTINENTER';
      case 'pl': return '$count KONTYNENTÓW';
      case 'id': return '$count BENUA';
      case 'th': return '$count ทวีป';
      case 'vi': return '$count CHÂU LỤC';
      default: return '$count CONTINENTS';
    }
  }

  /// 9. Postcard Header: "POSTCARD"
  static String getPostcardHeader(String lang) {
    switch (lang) {
      case 'tr': return 'KARTPOSTAL';
      case 'es': return 'TARJETA POSTAL';
      case 'fr': return 'CARTE POSTALE';
      case 'de': return 'POSTKARTE';
      case 'it': return 'CARTOLINA';
      case 'pt': return 'CARTÃO-POSTAL';
      case 'ru': return 'ОТКРЫТКА';
      case 'zh': return '明信片';
      case 'ja': return 'ポストカード';
      case 'ko': return '엽서';
      case 'hi': return 'पोस्टकार्ड';
      case 'ar': return 'بطاقة بريدية';
      case 'nl': return 'BRIEFKAART';
      case 'el': return 'ΚΑΡΤ ΠΟΣΤΑΛ';
      case 'sv': return 'VYKORT';
      case 'pl': return 'POCZTÓWKA';
      case 'id': return 'KARTU POS';
      case 'th': return 'โปสการ์ด';
      case 'vi': return 'BƯU THIẾP';
      default: return 'POSTCARD';
    }
  }

  /// 10. Postcard Photo Caption
  static String getPostcardCaption(String lang, int count) {
    switch (lang) {
      case 'tr': return '🌍 Dünya Seyahat Hatırası • $count Ülke Keşfedildi';
      case 'es': return '🌍 Recuerdo de Viaje Mundial • $count Países Explorados';
      case 'fr': return '🌍 Souvenir de Voyage Mondial • $count Pays Explorés';
      case 'de': return '🌍 Weltreise-Erinnerung • $count Länder Erkundet';
      case 'it': return '🌍 Ricordo di Viaggio nel Mondo • $count Paesi Esplorati';
      case 'pt': return '🌍 Lembrança de Viagem Mundial • $count Países Explorados';
      case 'ru': return '🌍 Память о путешествиях • Исследовано стран: $count';
      case 'zh': return '🌍 环球旅行纪念 • 已探索 $count 个国家';
      case 'ja': return '🌍 世界旅行の記念 • $count か国を探索';
      case 'ko': return '🌍 세계 여행 추억 • $count개국 탐험 완료';
      case 'hi': return '🌍 विश्व यात्रा की स्मृति • $count देश खोजे गए';
      case 'ar': return '🌍 تذكار السفر حول العالم • تم استكشاف $count دولة';
      case 'nl': return '🌍 Wereldreisherinnering • $count Landen Ontdekt';
      case 'el': return '🌍 Αναμνηστικό Παγκόσμιου Ταξιδιού • $count Χώρες Εξερευνήθηκαν';
      case 'sv': return '🌍 Världsresminne • $count Länder Utforskade';
      case 'pl': return '🌍 Pamiątka z Podróży po Świecie • $count Odkrytych Krajów';
      case 'id': return '🌍 Kenangan Perjalanan Dunia • $count Negara Dijelajahi';
      case 'th': return '🌍 ความทรงจำการเดินทางรอบโลก • สำรวจแล้ว $count ประเทศ';
      case 'vi': return '🌍 Kỷ Niệm Du Hành Thế Giới • Đã Khám Phá $count Quốc Gia';
      default: return '🌍 World Travel Keepsake • $count Countries Explored';
    }
  }

  /// 11. Postcard Travel Note
  static String getPostcardNote(String lang, int visitedCount, int continentsCount) {
    switch (lang) {
      case 'tr':
        return '$visitedCount ülke ve $continentsCount kıtada unutulmaz seyahat anıları.';
      case 'es':
        return 'Recuerdos de viaje inolvidables en $visitedCount países y $continentsCount continentes.';
      case 'fr':
        return 'Des souvenirs de voyage inoubliables dans $visitedCount pays et $continentsCount continents.';
      case 'de':
        return 'Unvergessliche Reiseerinnerungen in $visitedCount Ländern und $continentsCount Kontinenten.';
      case 'it':
        return 'Ricordi di viaggio indimenticabili in $visitedCount paesi e $continentsCount continenti.';
      case 'pt':
        return 'Memórias de viagem inesquecíveis em $visitedCount países e $continentsCount continentes.';
      case 'ru':
        return 'Незабываемые воспоминания о путешествиях по $visitedCount странам и $continentsCount континентам.';
      case 'zh':
        return '在 $continentsCount 个大洲 $visitedCount 个国家留下的难忘旅行回忆。';
      case 'ja':
        return '$continentsCount 大陸 $visitedCount か国での忘れられない旅の思い出。';
      case 'ko':
        return '$continentsCount개 대륙 $visitedCount개국에서 쌓은 잊을 수 없는 여행 추억.';
      case 'hi':
        return '$continentsCount महाद्वीपों और $visitedCount देशों में अविस्मरणीय यात्रा की यादें।';
      case 'ar':
        return 'ذكريات سفر لا تُنسى في $visitedCount دولة و$continentsCount قارات.';
      case 'nl':
        return 'Onvergetelijke reisherinneringen in $visitedCount landen en $continentsCount continenten.';
      case 'el':
        return 'Αξέχαστες ταξιδιωτικές αναμνήσεις σε $visitedCount χώρες και $continentsCount ηπείρους.';
      case 'sv':
        return 'Oförglömliga resminnen i $visitedCount länder och $continentsCount kontinenter.';
      case 'pl':
        return 'Niezapomniane wspomnienia z podróży po $visitedCount krajach i $continentsCount kontynentach.';
      case 'id':
        return 'Kenangan perjalanan tak terlupakan di $visitedCount negara dan $continentsCount benua.';
      case 'th':
        return 'ความทรงจำการเดินทางที่ยากจะลืมเลือนใน $visitedCount ประเทศและ $continentsCount ทวีป';
      case 'vi':
        return 'Những kỷ niệm du lịch khó quên tại $visitedCount quốc gia và $continentsCount châu lục.';
      default:
        return 'Unforgettable travel memories across $visitedCount countries and $continentsCount continents.';
    }
  }

  /// 12. Infographic Header: "INFOGRAPHIC"
  static String getInfographicHeader(String lang) {
    switch (lang) {
      case 'tr': return 'İNFOGRAFİK';
      case 'es': return 'INFOGRAFÍA';
      case 'fr': return 'INFOGRAPHIE';
      case 'de': return 'INFOGRAFIK';
      case 'it': return 'INFOGRAFICA';
      case 'pt': return 'INFOGRÁFICO';
      case 'ru': return 'ИНФОГРАФИКА';
      case 'zh': return '信息图表';
      case 'ja': return 'インフォグラフィック';
      case 'ko': return '인포그래픽';
      case 'hi': return 'इन्फोग्राफिक';
      case 'ar': return 'انفوجرافيك';
      case 'nl': return 'INFOGRAPHIC';
      case 'el': return 'ΙΝΦΟΓΡΑΦΗΜΑ';
      case 'sv': return 'INFOGRAFIK';
      case 'pl': return 'INFOGRAFIKA';
      case 'id': return 'INFOGRAFIS';
      case 'th': return 'อินโฟกราฟิก';
      case 'vi': return 'ĐỒ HỌA THÔNG TIN';
      default: return 'INFOGRAPHIC';
    }
  }

  /// 13. Visa Pending Badge
  static String getVisaPendingBadge(String lang) {
    switch (lang) {
      case 'tr': return '★ VİZE ONAYI BEKLENİYOR ★';
      case 'es': return '★ VISADO EN TRÁMITE ★';
      case 'fr': return '★ VISA EN ATTENTE ★';
      case 'de': return '★ VISA-FREIGABE AUSSTEHEND ★';
      case 'it': return '★ VISTO IN ATTESA ★';
      case 'pt': return '★ VISTO EM PROCESSAMENTO ★';
      case 'ru': return '★ ОЖИДАЕТСЯ ВИЗА ★';
      case 'zh': return '★ 签证审核中 ★';
      case 'ja': return '★ ビザ承認待ち ★';
      case 'ko': return '★ 비자 승인 대기 중 ★';
      case 'hi': return '★ वीज़ा मंज़ूरी लंबित ★';
      case 'ar': return '★ في انتظار الموافقة على التأشيرة ★';
      case 'nl': return '★ VISUM GOEDKEURING IN BEHANDELING ★';
      case 'el': return '★ ΕΚΚΡΕΜΕΙ ΕΓΚΡΙΣΗ ΒΙΖΑΣ ★';
      case 'sv': return '★ VISUMBEHANDLING PÅGÅR ★';
      case 'pl': return '★ OCZEKIWANIE NA WIZĘ ★';
      case 'id': return '★ MENUNGGU PERSETUJUAN VISA ★';
      case 'th': return '★ กำลังรอการอนุมัติวีซ่า ★';
      case 'vi': return '★ ĐANG CHỜ PHÊ DUYỆT THỊ THỰC ★';
      default: return '★ VISA CLEARANCE PENDING ★';
    }
  }

  /// 14. Target Destinations Header
  static String getTargetDestinationsHeader(String lang) {
    switch (lang) {
      case 'tr': return 'HEDEF ROTALAR';
      case 'es': return 'DESTINOS OBJETIVO';
      case 'fr': return 'DESTINATIONS CIBLES';
      case 'de': return 'REISEZIELE';
      case 'it': return 'DESTINAZIONI PREVISTE';
      case 'pt': return 'DESTINOS DESEJADOS';
      case 'ru': return 'ЖЕЛАЕМЫЕ НАПРАВЛЕНИЯ';
      case 'zh': return '目标目的地';
      case 'ja': return '目標の目的地';
      case 'ko': return '목표 여행지';
      case 'hi': return 'लक्ष्य गंतव्य';
      case 'ar': return 'الوجهات المستهدفة';
      case 'nl': return 'DOELBESTEMMINGEN';
      case 'el': return 'ΕΠΙΘΥΜΗΤΟΙ ΠΡΟΟΡΙΣΜΟΙ';
      case 'sv': return 'MÅLDESTINATIONER';
      case 'pl': return 'DOCELOWE MIEJSCA';
      case 'id': return 'DESTINASI IMPIAN';
      case 'th': return 'จุดหมายปลายทางในฝัน';
      case 'vi': return 'ĐIỂM ĐẾN MỤC TIÊU';
      default: return 'TARGET DESTINATIONS';
    }
  }

  /// 15. Ready for takeoff hint
  static String getReadyForTakeoffHint(String lang) {
    switch (lang) {
      case 'tr': return 'Kalkışa hazır • İlk ziyaret ettiğin ülkeyi işaretle';
      case 'es': return 'Listo para el despegue • Marca tu primer país visitado';
      case 'fr': return 'Prêt au décollage • Marquez votre premier pays visité';
      case 'de': return 'Bereit zum Abflug • Markiere dein erstes besuchtes Land';
      case 'it': return 'Pronto al decollo • Segna il tuo primo paese visitato';
      case 'pt': return 'Pronto para decolar • Marque seu primeiro país visitado';
      case 'ru': return 'Готовы к взлету • Отметьте первую посещенную страну';
      case 'zh': return '准备启航 • 标记你的第一个旅行国家';
      case 'ja': return '出発の準備 • 最初に訪れた国を記録しましょう';
      case 'ko': return '이륙 준비 완료 • 첫 방문 국가를 표시해 보세요';
      case 'hi': return 'उड़ान के लिए तैयार • अपना पहला देखा गया देश चिह्नित करें';
      case 'ar': return 'جاهز للإقلاع • حدد أول دولة قمت بزيارتها';
      case 'nl': return 'Klaar voor vertrek • Markeer je eerste bezochte land';
      case 'el': return 'Έτοιμοι για απογείωση • Σημειώστε την πρώτη χώρα που επισκεφτήκατε';
      case 'sv': return 'Redo för avfärd • Markera ditt första besökta land';
      case 'pl': return 'Gotowy do startu • Zaznacz swój pierwszy odwiedzony kraj';
      case 'id': return 'Siap lepas landas • Tandai negara pertama yang Anda kunjungi';
      case 'th': return 'พร้อมออกเดินทาง • ทำเครื่องหมายประเทศแรกที่คุณไปเยือน';
      case 'vi': return 'Sẵn sàng cất cánh • Đánh dấu quốc gia đầu tiên bạn đã đến';
      default: return 'Ready for takeoff • Mark your first visited country';
    }
  }

  /// 16. Visa Admitted Stamp: "★ ADMITTED ★"
  static String getVisaAdmittedStamp(String lang) {
    switch (lang) {
      case 'tr': return '★ ONAYLANDI ★';
      case 'es': return '★ ADMITIDO ★';
      case 'fr': return '★ ADMIS ★';
      case 'de': return '★ EINGEREIST ★';
      case 'it': return '★ AMMESSO ★';
      case 'pt': return '★ ADMITIDO ★';
      case 'ru': return '★ ОДОБРЕНО ★';
      case 'zh': return '★ 已获准入境 ★';
      case 'ja': return '★ 入国許可 ★';
      case 'ko': return '★ 입국 허가 ★';
      case 'hi': return '★ स्वीकृत ★';
      case 'ar': return '★ مقبول ★';
      case 'nl': return '★ TOEGELATEN ★';
      case 'el': return '★ ΕΓΚΕΚΡΙΜΕΝΟ ★';
      case 'sv': return '★ BEVILJAD ★';
      case 'pl': return '★ WIZA PRZYZNANA ★';
      case 'id': return '★ DISETUJUI ★';
      case 'th': return '★ อนุมัติแล้ว ★';
      case 'vi': return '★ ĐÃ CHẤP THUẬN ★';
      default: return '★ ADMITTED ★';
    }
  }

  /// 17. Next on the Radar Header
  static String getNextRadarHeader(String lang) {
    switch (lang) {
      case 'tr': return 'RADARDAKİ YENİ ROTALAR';
      case 'es': return 'PRÓXIMO EN EL RADAR';
      case 'fr': return 'PROCHAIN SUR LE RADAR';
      case 'de': return 'ALS NÄCHSTES AUF DEM RADAR';
      case 'it': return 'PROSSIMO SUL RADAR';
      case 'pt': return 'PRÓXIMO NO RADAR';
      case 'ru': return 'СЛЕДУЮЩИЕ НА РАДАРЕ';
      case 'zh': return '下一个探索目标';
      case 'ja': return '次の目標地';
      case 'ko': return '다음 여행 레이더';
      case 'hi': return 'अगला गंतव्य';
      case 'ar': return 'التالي على الرادار';
      case 'nl': return 'VOLGENDE OP DE RADAR';
      case 'el': return 'ΕΠΟΜΕΝΟΣ ΠΡΟΟΡΙΣΜΟΣ';
      case 'sv': return 'NÄSTA PÅ RADARN';
      case 'pl': return 'NASTĘPNY CEL NA RADARZE';
      case 'id': return 'SELANJUTNYA DI RADAR';
      case 'th': return 'เป้าหมายถัดไป';
      case 'vi': return 'MỤC TIÊU TIẾP THEO';
      default: return 'NEXT ON THE RADAR';
    }
  }

  /// 18. Horizon Awaits Header
  static String getHorizonAwaitsHeader(String lang) {
    switch (lang) {
      case 'tr': return 'UFUK SENİ BEKLİYOR';
      case 'es': return 'EL HORIZONTE ESPERA';
      case 'fr': return 'L\'HORIZON VOUS ATTEND';
      case 'de': return 'DER HORIZONT WARTET';
      case 'it': return 'L\'ORIZZONTE ATTENDE';
      case 'pt': return 'O HORIZONTE ESPERA';
      case 'ru': return 'ГОРИЗОНТ ЖДЕТ';
      case 'zh': return '地平线在召唤';
      case 'ja': return '地平線が待っている';
      case 'ko': return '새로운 지평이 기다립니다';
      case 'hi': return 'क्षितिज आपका इंतज़ार कर रहा है';
      case 'ar': return 'الأفق في انتظارك';
      case 'nl': return 'DE HORIZON WACHT';
      case 'el': return 'Ο ΟΡΙΖΟΝΤΑΣ ΠΕΡΙΜΕΝΕΙ';
      case 'sv': return 'HORISONTEN VÄNTAR';
      case 'pl': return 'HORYZONT CZEKA';
      case 'id': return 'CAKRAWALA MENANTI';
      case 'th': return 'ขอบฟ้ารอคุณอยู่';
      case 'vi': return 'CHÂN TRỜI ĐANG VẪY GỌI';
      default: return 'HORIZON AWAITS';
    }
  }

  /// 19. Empty Explorer State Prompt
  static String getExplorerEmptyPrompt(String lang) {
    switch (lang) {
      case 'tr': return 'Her büyük seyahat tek bir adımla başlar • Yeni ülkeler keşfetmeye başla';
      case 'es': return 'Todo gran viaje comienza con un solo paso • Empieza a explorar nuevos países';
      case 'fr': return 'Chaque grand voyage commence par un premier pas • Commencez à explorer de nouveaux pays';
      case 'de': return 'Jede große Reise beginnt mit einem ersten Schritt • Entdecke neue Länder';
      case 'it': return 'Ogni grande viaggio inizia con un singolo passo • Inizia ad esplorare nuovi paesi';
      case 'pt': return 'Toda grande jornada começa com um único passo • Comece a explorar novos países';
      case 'ru': return 'Каждое великое путешествие начинается с одного шага • Начните открывать новые страны';
      case 'zh': return '千里之行始于足下 • 开始探索新的国家吧';
      case 'ja': return 'すべての素晴らしい旅は一歩から始まります • 新しい国を探索しましょう';
      case 'ko': return '모든 위대한 여정은 한 걸음부터 시작됩니다 • 새로운 나라를 탐험해 보세요';
      case 'hi': return 'हर महान यात्रा एक कदम से शुरू होती है • नए देशों की खोज शुरू करें';
      case 'ar': return 'كل رحلة عظيمة تبدأ بخطوة واحدة • ابدأ باستكشاف بلدان جديدة';
      case 'nl': return 'Elke grote reis begint met een enkele stap • Begin met het ontdekken van nieuwe landen';
      case 'el': return 'Κάθε μεγάλο ταξίδι ξεκινά με ένα μόνο βήμα • Ξεκινήστε να εξερευνάτε νέες χώρες';
      case 'sv': return 'Varje stor resa börjar med ett enda steg • Börja utforska nya länder';
      case 'pl': return 'Każda wielka podróż zaczyna się od jednego kroku • Rozpocznij odkrywanie nowych krajów';
      case 'id': return 'Setiap perjalanan hebat dimulai dengan satu langkah • Mulai jelajahi negara baru';
      case 'th': return 'การเดินทางอันยิ่งใหญ่เริ่มต้นด้วยก้าวเดียวเสมอ • เริ่มสำรวจประเทศใหม่ๆ ได้เลย';
      case 'vi': return 'Mọi hành trình vĩ đại đều bắt đầu từ một bước đi • Hãy bắt đầu khám phá các quốc gia mới';
      default: return 'Every great journey begins with a single step • Start exploring new countries';
    }
  }

  /// 20. New Adventures Prompt
  static String getNewAdventuresPrompt(String lang) {
    switch (lang) {
      case 'tr': return 'Yeni rotalar, yeni maceralar • Keşfetmeye başla';
      case 'es': return 'Nuevas rutas, nuevas aventuras • Empieza a explorar';
      case 'fr': return 'Nouvelles routes, nouvelles aventures • Commencez à explorer';
      case 'de': return 'Neue Routen, neue Abenteuer • Jetzt erkunden';
      case 'it': return 'Nuove rotte, nuove avventure • Inizia ad esplorare';
      case 'pt': return 'Novas rotas, novas aventuras • Comece a explorar';
      case 'ru': return 'Новые маршруты, новые приключения • Начните исследовать';
      case 'zh': return '新路线，新冒险 • 开始探索';
      case 'ja': return '新しいルート、新しい冒険 • 探索を始めましょう';
      case 'ko': return '새로운 경로, 새로운 모험 • 탐험을 시작하세요';
      case 'hi': return 'नए रास्ते, नए रोमांच • अन्वेषण शुरू करें';
      case 'ar': return 'مسارات جديدة، مغامرات جديدة • ابدأ الاستكشاف';
      case 'nl': return 'Nieuwe routes, nieuwe avonturen • Begin met ontdekken';
      case 'el': return 'Νέες διαδρομές, νέες περιπέτειες • Ξεκινήστε την εξερεύνηση';
      case 'sv': return 'Nya rutter, nya äventyr • Börja utforska';
      case 'pl': return 'Nowe trasy, nowe przygody • Rozpocznij odkrywanie';
      case 'id': return 'Rute baru, petualangan baru • Mulai eksplorasi';
      case 'th': return 'เส้นทางใหม่ การผจญภัยครั้งใหม่ • เริ่มการสำรวจ';
      case 'vi': return 'Tuyến đường mới, cuộc phiêu lưu mới • Bắt đầu khám phá';
      default: return 'New routes, new adventures • Start exploring';
    }
  }

  /// 21. Story Card Theme Names (All 16 themes in all 20 languages)
  static String getThemeName(String themeKey, String lang) {
    switch (themeKey) {
      case 'midnight':
        switch (lang) {
          case 'tr': return 'Gece';
          case 'es': return 'Medianoche';
          case 'fr': return 'Minuit';
          case 'de': return 'Mitternacht';
          case 'it': return 'Mezzanotte';
          case 'pt': return 'Meia-noite';
          case 'ru': return 'Полночь';
          case 'zh': return '午夜';
          case 'ja': return 'ミッドナイト';
          case 'ko': return '미드나잇';
          case 'hi': return 'मध्यरात्रि';
          case 'ar': return 'منتصف الليل';
          case 'nl': return 'Middernacht';
          case 'el': return 'Μεσάνυχτα';
          case 'sv': return 'Midnatt';
          case 'pl': return 'Północ';
          case 'id': return 'Tengah Malam';
          case 'th': return 'เที่ยงคืน';
          case 'vi': return 'Nửa Đêm';
          default: return 'Midnight';
        }

      case 'sunset':
        switch (lang) {
          case 'tr': return 'Gün Batımı';
          case 'es': return 'Atardecer';
          case 'fr': return 'Coucher de soleil';
          case 'de': return 'Sonnenuntergang';
          case 'it': return 'Tramonto';
          case 'pt': return 'Pôr do Sol';
          case 'ru': return 'Закат';
          case 'zh': return '日落';
          case 'ja': return '夕焼け';
          case 'ko': return '일몰';
          case 'hi': return 'सूर्यास्त';
          case 'ar': return 'غروب الشمس';
          case 'nl': return 'Zonsondergang';
          case 'el': return 'Ηλιοβασίλεμα';
          case 'sv': return 'Solnedgång';
          case 'pl': return 'Zachód Słońca';
          case 'id': return 'Matahari Terbenam';
          case 'th': return 'พระอาทิตย์ตก';
          case 'vi': return 'Hoàng Hôn';
          default: return 'Sunset';
        }

      case 'emerald':
        switch (lang) {
          case 'tr': return 'Aurora';
          case 'es': return 'Aurora';
          case 'fr': return 'Aurore';
          case 'de': return 'Polarlicht';
          case 'it': return 'Aurora';
          case 'pt': return 'Aurora';
          case 'ru': return 'Аврора';
          case 'zh': return '极光';
          case 'ja': return 'オーロラ';
          case 'ko': return '오로라';
          case 'hi': return 'ऑरोरा';
          case 'ar': return 'الشفق القطبي';
          case 'nl': return 'Noorderlicht';
          case 'el': return 'Σέλας';
          case 'sv': return 'Norrsken';
          case 'pl': return 'Zorza Polarna';
          case 'id': return 'Aurora';
          case 'th': return 'แสงเหนือ';
          case 'vi': return 'Cực Quang';
          default: return 'Aurora';
        }

      case 'cyberpunk':
        switch (lang) {
          case 'tr': return 'Siber';
          case 'es': return 'Ciberpunk';
          case 'fr': return 'Cyberpunk';
          case 'de': return 'Cyberpunk';
          case 'it': return 'Cyberpunk';
          case 'pt': return 'Cyberpunk';
          case 'ru': return 'Киберпанк';
          case 'zh': return '赛博';
          case 'ja': return 'サイバーパンク';
          case 'ko': return '사이버펑크';
          case 'hi': return 'साइबरपंक';
          case 'ar': return 'سايبر بانك';
          case 'nl': return 'Cyberpunk';
          case 'el': return 'Κυβερνοπάνκ';
          case 'sv': return 'Cyberpunk';
          case 'pl': return 'Cyberpunk';
          case 'id': return 'Cyberpunk';
          case 'th': return 'ไซเบอร์พังค์';
          case 'vi': return 'Không Gian Mạng';
          default: return 'Cyberpunk';
        }

      case 'volcano':
        switch (lang) {
          case 'tr': return 'Lav';
          case 'es': return 'Volcán';
          case 'fr': return 'Volcan';
          case 'de': return 'Vulkan';
          case 'it': return 'Vulcano';
          case 'pt': return 'Vulcão';
          case 'ru': return 'Вулкан';
          case 'zh': return '火山';
          case 'ja': return 'ボルケーノ';
          case 'ko': return '화산';
          case 'hi': return 'ज्वालामुखी';
          case 'ar': return 'بركان';
          case 'nl': return 'Vulkaan';
          case 'el': return 'Ηφαίστειο';
          case 'sv': return 'Vulkan';
          case 'pl': return 'Wulkan';
          case 'id': return 'Gunung Berapi';
          case 'th': return 'ภูเขาไฟ';
          case 'vi': return 'Núi Lửa';
          default: return 'Volcano';
        }

      case 'nordicForest':
        switch (lang) {
          case 'tr': return 'Fiyort';
          case 'es': return 'Fiordo';
          case 'fr': return 'Fjord';
          case 'de': return 'Fjord';
          case 'it': return 'Fiordo';
          case 'pt': return 'Fiorde';
          case 'ru': return 'Фьорд';
          case 'zh': return '峡湾';
          case 'ja': return 'フィヨルド';
          case 'ko': return '피오르드';
          case 'hi': return 'फ़्योर्ड';
          case 'ar': return 'مضيق بحري';
          case 'nl': return 'Fjord';
          case 'el': return 'Φιόρδ';
          case 'sv': return 'Fjord';
          case 'pl': return 'Fiord';
          case 'id': return 'Fjord';
          case 'th': return 'ฟยอร์ด';
          case 'vi': return 'Vịnh Hẹp';
          default: return 'Fjord';
        }

      case 'goldenHour':
        switch (lang) {
          case 'tr': return 'Altın Çağ';
          case 'es': return 'Hora Dorada';
          case 'fr': return 'Heure Dorée';
          case 'de': return 'Goldene Stunde';
          case 'it': return 'Ora Dorata';
          case 'pt': return 'Hora de Ouro';
          case 'ru': return 'Золотой Час';
          case 'zh': return '金色时刻';
          case 'ja': return 'ゴールデンアワー';
          case 'ko': return '골든 아워';
          case 'hi': return 'स्वर्णिम काल';
          case 'ar': return 'الساعة الذهبية';
          case 'nl': return 'Gouden Uur';
          case 'el': return 'Χρυσή Ώρα';
          case 'sv': return 'Gyllene Timmen';
          case 'pl': return 'Złota Godzina';
          case 'id': return 'Waktu Emas';
          case 'th': return 'ชั่วโมงทอง';
          case 'vi': return 'Giờ Vàng';
          default: return 'Golden Hour';
        }

      case 'galaxy':
        switch (lang) {
          case 'tr': return 'Galaksi';
          case 'es': return 'Galaxia';
          case 'fr': return 'Galaxie';
          case 'de': return 'Galaxie';
          case 'it': return 'Galassia';
          case 'pt': return 'Galáxia';
          case 'ru': return 'Галактика';
          case 'zh': return '星系';
          case 'ja': return 'ギャラクシー';
          case 'ko': return '은하';
          case 'hi': return 'आकाशगंगा';
          case 'ar': return 'المجرة';
          case 'nl': return 'Melkweg';
          case 'el': return 'Γαλαξίας';
          case 'sv': return 'Galax';
          case 'pl': return 'Galaktyka';
          case 'id': return 'Galaksi';
          case 'th': return 'กาแล็กซี';
          case 'vi': return 'Ngân Hà';
          default: return 'Galaxy';
        }

      case 'monochromeDark':
        switch (lang) {
          case 'tr': return 'Karbon';
          case 'es': return 'Carbón';
          case 'fr': return 'Carbone';
          case 'de': return 'Karbon';
          case 'it': return 'Carbonio';
          case 'pt': return 'Carbono';
          case 'ru': return 'Углерод';
          case 'zh': return '碳黑';
          case 'ja': return 'カーボン';
          case 'ko': return '카본';
          case 'hi': return 'कार्बन';
          case 'ar': return 'كربون';
          case 'nl': return 'Koolstof';
          case 'el': return 'Άνθρακας';
          case 'sv': return 'Kolfiber';
          case 'pl': return 'Karbon';
          case 'id': return 'Karbon';
          case 'th': return 'คาร์บอน';
          case 'vi': return 'Cacbon';
          default: return 'Carbon';
        }

      case 'minimalLight':
        switch (lang) {
          case 'tr': return 'İskandinav';
          case 'es': return 'Nórdico';
          case 'fr': return 'Nordique';
          case 'de': return 'Nordisch';
          case 'it': return 'Nordico';
          case 'pt': return 'Nórdico';
          case 'ru': return 'Скандинавский';
          case 'zh': return '北欧';
          case 'ja': return '北欧スタイル';
          case 'ko': return '노르딕';
          case 'hi': return 'नॉर्डिक';
          case 'ar': return 'نوردي';
          case 'nl': return 'Scandinavisch';
          case 'el': return 'Σκανδιναβικό';
          case 'sv': return 'Nordisk';
          case 'pl': return 'Skandynawski';
          case 'id': return 'Nordik';
          case 'th': return 'นอร์ดิก';
          case 'vi': return 'Bắc Âu';
          default: return 'Nordic';
        }

      case 'sandLight':
        switch (lang) {
          case 'tr': return 'Sahra';
          case 'es': return 'Sahara';
          case 'fr': return 'Sahara';
          case 'de': return 'Sahara';
          case 'it': return 'Sahara';
          case 'pt': return 'Saara';
          case 'ru': return 'Сахара';
          case 'zh': return '撒哈拉';
          case 'ja': return 'サハラ';
          case 'ko': return '사하라';
          case 'hi': return 'सहारा';
          case 'ar': return 'الصحراء الكبرى';
          case 'nl': return 'Sahara';
          case 'el': return 'Σαχάρα';
          case 'sv': return 'Sahara';
          case 'pl': return 'Sahara';
          case 'id': return 'Sahara';
          case 'th': return 'ซาฮารา';
          case 'vi': return 'Sahara';
          default: return 'Sahara';
        }

      case 'oceanLight':
        switch (lang) {
          case 'tr': return 'Akdeniz';
          case 'es': return 'Mediterráneo';
          case 'fr': return 'Méditerranée';
          case 'de': return 'Mittelmeer';
          case 'it': return 'Mediterraneo';
          case 'pt': return 'Mediterrâneo';
          case 'ru': return 'Средиземноморье';
          case 'zh': return '地中海';
          case 'ja': return '地中海';
          case 'ko': return '지중해';
          case 'hi': return 'भूमध्यसागरीय';
          case 'ar': return 'البحر الأبيض المتوسط';
          case 'nl': return 'Middellandse Zee';
          case 'el': return 'Μεσόγειος';
          case 'sv': return 'Medelhavet';
          case 'pl': return 'Śródziemnomorski';
          case 'id': return 'Mediterania';
          case 'th': return 'เมดิเตอร์เรเนียน';
          case 'vi': return 'Địa Trung Hải';
          default: return 'Mediterranean';
        }

      case 'cherryBlossom':
        switch (lang) {
          case 'tr': return 'Sakura';
          case 'es': return 'Sakura';
          case 'fr': return 'Sakura';
          case 'de': return 'Sakura';
          case 'it': return 'Sakura';
          case 'pt': return 'Sakura';
          case 'ru': return 'Сакура';
          case 'zh': return '樱花';
          case 'ja': return '桜';
          case 'ko': return '벚꽃';
          case 'hi': return 'सकुरा';
          case 'ar': return 'ساكورا';
          case 'nl': return 'Kersenbloesem';
          case 'el': return 'Άνθη Κερασιάς';
          case 'sv': return 'Körsbärsblom';
          case 'pl': return 'Wiśnia (Sakura)';
          case 'id': return 'Sakura';
          case 'th': return 'ซากุระ';
          case 'vi': return 'Hoa Anh Đào';
          default: return 'Sakura';
        }

      case 'vintageSepia':
        switch (lang) {
          case 'tr': return 'Parşömen';
          case 'es': return 'Pergamino';
          case 'fr': return 'Parchemin';
          case 'de': return 'Pergament';
          case 'it': return 'Pergamena';
          case 'pt': return 'Pergaminho';
          case 'ru': return 'Пергамент';
          case 'zh': return '羊皮纸';
          case 'ja': return '羊皮紙';
          case 'ko': return '양피지';
          case 'hi': return 'चर्मपत्र';
          case 'ar': return 'ورق البردي';
          case 'nl': return 'Perkament';
          case 'el': return 'Περγαμηνή';
          case 'sv': return 'Pergament';
          case 'pl': return 'Pergamin';
          case 'id': return 'Perkamen';
          case 'th': return 'กระดาษโบราณ';
          case 'vi': return 'Bản Thảo';
          default: return 'Parchment';
        }

      case 'matcha':
        switch (lang) {
          case 'tr': return 'Matcha';
          case 'es': return 'Matcha';
          case 'fr': return 'Matcha';
          case 'de': return 'Matcha';
          case 'it': return 'Matcha';
          case 'pt': return 'Matcha';
          case 'ru': return 'Матча';
          case 'zh': return '抹茶';
          case 'ja': return '抹茶';
          case 'ko': return '말차';
          case 'hi': return 'माचा';
          case 'ar': return 'ماتشا';
          case 'nl': return 'Matcha';
          case 'el': return 'Μάτσα';
          case 'sv': return 'Matcha';
          case 'pl': return 'Matcha';
          case 'id': return 'Matcha';
          case 'th': return 'มัทฉะ';
          case 'vi': return 'Trà Xanh';
          default: return 'Matcha';
        }

      case 'pastelDream':
        switch (lang) {
          case 'tr': return 'Pastel Rüya';
          case 'es': return 'Sueño Pastel';
          case 'fr': return 'Rêve Pastel';
          case 'de': return 'Pastelltraum';
          case 'it': return 'Sogno Pastello';
          case 'pt': return 'Sonho Pastel';
          case 'ru': return 'Пастельная Мечта';
          case 'zh': return '梦幻粉彩';
          case 'ja': return 'パステルドリーム';
          case 'ko': return '파스텔 드림';
          case 'hi': return 'पेस्टल ड्रीम';
          case 'ar': return 'حلم الباستيل';
          case 'nl': return 'Pasteldroom';
          case 'el': return 'Παστέλ Όνειρο';
          case 'sv': return 'Pastelldröm';
          case 'pl': return 'Pastelowy Sen';
          case 'id': return 'Mimpi Pastel';
          case 'th': return 'ความฝันสีพาสเทล';
          case 'vi': return 'Giấc Mơ Pastel';
          default: return 'Pastel Dream';
        }

      default:
        return 'Custom';
    }
  }

  /// 22. Story Card Layout Names (All 7 layouts in all 20 languages)
  static String getLayoutName(StoryCardLayout layout, String lang) {
    switch (layout) {
      case StoryCardLayout.classic:
        switch (lang) {
          case 'tr': return 'Klasik';
          case 'es': return 'Clásico';
          case 'fr': return 'Classique';
          case 'de': return 'Klassisch';
          case 'it': return 'Classico';
          case 'pt': return 'Clássico';
          case 'ru': return 'Классика';
          case 'zh': return '经典版';
          case 'ja': return 'クラシック';
          case 'ko': return '클래식';
          case 'hi': return 'क्लासिक';
          case 'ar': return 'كلاسيكي';
          case 'nl': return 'Klassiek';
          case 'el': return 'Κλασικό';
          case 'sv': return 'Klassisk';
          case 'pl': return 'Klasyczny';
          case 'id': return 'Klasik';
          case 'th': return 'คลาสสิก';
          case 'vi': return 'Cổ Điển';
          default: return 'Classic';
        }

      case StoryCardLayout.passport:
        switch (lang) {
          case 'tr': return 'Pasaport';
          case 'es': return 'Pasaporte';
          case 'fr': return 'Passeport';
          case 'de': return 'Reisepass';
          case 'it': return 'Passaporto';
          case 'pt': return 'Passaporte';
          case 'ru': return 'Паспорт';
          case 'zh': return '护照版';
          case 'ja': return 'パスポート';
          case 'ko': return '여권';
          case 'hi': return 'पासपोर्ट';
          case 'ar': return 'جواز السفر';
          case 'nl': return 'Paspoort';
          case 'el': return 'Διαβατήριο';
          case 'sv': return 'Pass';
          case 'pl': return 'Paszport';
          case 'id': return 'Paspor';
          case 'th': return 'พาสปอร์ต';
          case 'vi': return 'Hộ Chiếu';
          default: return 'Passport';
        }

      case StoryCardLayout.minimal:
        switch (lang) {
          case 'tr': return 'Minimal';
          case 'es': return 'Minimalista';
          case 'fr': return 'Minimaliste';
          case 'de': return 'Minimalistisch';
          case 'it': return 'Minimale';
          case 'pt': return 'Minimalista';
          case 'ru': return 'Минимал';
          case 'zh': return '极简版';
          case 'ja': return 'ミニマル';
          case 'ko': return '미니멀';
          case 'hi': return 'मिनिमल';
          case 'ar': return 'مبسط';
          case 'nl': return 'Minimalistisch';
          case 'el': return 'Μινιμάλ';
          case 'sv': return 'Minimalistisk';
          case 'pl': return 'Minimalistyczny';
          case 'id': return 'Minimalis';
          case 'th': return 'มินิมอล';
          case 'vi': return 'Tối Giản';
          default: return 'Minimal';
        }

      case StoryCardLayout.showcase:
        switch (lang) {
          case 'tr': return 'Vitrin';
          case 'es': return 'Vitrina';
          case 'fr': return 'Vitrine';
          case 'de': return 'Schaufenster';
          case 'it': return 'Vetrina';
          case 'pt': return 'Vitrine';
          case 'ru': return 'Витрина';
          case 'zh': return '全景橱窗';
          case 'ja': return 'ショーケース';
          case 'ko': return '쇼케이스';
          case 'hi': return 'शोकेस';
          case 'ar': return 'واجهة العرض';
          case 'nl': return 'Showcase';
          case 'el': return 'Βιτρίνα';
          case 'sv': return 'Utställning';
          case 'pl': return 'Wizytówka';
          case 'id': return 'Showcase';
          case 'th': return 'โชว์เคส';
          case 'vi': return 'Trưng Bày';
          default: return 'Showcase';
        }

      case StoryCardLayout.journey:
        switch (lang) {
          case 'tr': return 'Yolculuk';
          case 'es': return 'Viaje';
          case 'fr': return 'Voyage';
          case 'de': return 'Reise';
          case 'it': return 'Viaggio';
          case 'pt': return 'Jornada';
          case 'ru': return 'Маршрут';
          case 'zh': return '旅程纪实';
          case 'ja': return 'ジャーニー';
          case 'ko': return '여정';
          case 'hi': return 'यात्रा';
          case 'ar': return 'رحلة';
          case 'nl': return 'Reis';
          case 'el': return 'Ταξίδι';
          case 'sv': return 'Resa';
          case 'pl': return 'Podróż';
          case 'id': return 'Perjalanan';
          case 'th': return 'การเดินทาง';
          case 'vi': return 'Hành Trình';
          default: return 'Journey';
        }

      case StoryCardLayout.polaroid:
        switch (lang) {
          case 'tr': return 'Kartpostal';
          case 'es': return 'Postal';
          case 'fr': return 'Carte Postale';
          case 'de': return 'Postkarte';
          case 'it': return 'Cartolina';
          case 'pt': return 'Cartão-Postal';
          case 'ru': return 'Открытка';
          case 'zh': return '拍立得';
          case 'ja': return 'ポラロイド';
          case 'ko': return '폴라로이드';
          case 'hi': return 'पोस्टकार्ड';
          case 'ar': return 'بطاقة بريدية';
          case 'nl': return 'Briefkaart';
          case 'el': return 'Καρτ Ποστάλ';
          case 'sv': return 'Vykort';
          case 'pl': return 'Pocztówka';
          case 'id': return 'Kartu Pos';
          case 'th': return 'โปสการ์ด';
          case 'vi': return 'Bưu Thiếp';
          default: return 'Postcard';
        }

      case StoryCardLayout.infographic:
        switch (lang) {
          case 'tr': return 'İnfografik';
          case 'es': return 'Infografía';
          case 'fr': return 'Infographie';
          case 'de': return 'Infografik';
          case 'it': return 'Infografica';
          case 'pt': return 'Infográfico';
          case 'ru': return 'Инфографика';
          case 'zh': return '数据图表';
          case 'ja': return 'インフォグラフィック';
          case 'ko': return '인포그래픽';
          case 'hi': return 'इन्फोग्राफिक';
          case 'ar': return 'انفوجرافيك';
          case 'nl': return 'Infographic';
          case 'el': return 'Ινφογράφημα';
          case 'sv': return 'Infografik';
          case 'pl': return 'Infografika';
          case 'id': return 'Infografis';
          case 'th': return 'อินโฟกราฟิก';
          case 'vi': return 'Đồ Họa Thông Tin';
          default: return 'Infographic';
        }
    }
  }
}
