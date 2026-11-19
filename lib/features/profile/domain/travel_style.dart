/// Represents a customizable traveler personality style/tag
class TravelStyle {
  final String id;
  final String emoji;
  final String defaultName;

  const TravelStyle({
    required this.id,
    required this.emoji,
    required this.defaultName,
  });

  /// Resolves localized style title across 20 supported languages
  String getLocalizedName(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (id) {
      case 'backpacker':
        switch (clean) {
          case 'tr': return 'Sırt Çantalı';
          case 'de': return 'Rucksackreisender';
          case 'es': return 'Mochilero';
          case 'fr': return 'Routard';
          case 'it': return 'Zaino in spalla';
          case 'pt': return 'Mochileiro';
          case 'ru': return 'С рюкзаком';
          case 'zh': return '背包客';
          case 'ja': return 'バックパッカー';
          case 'ko': return '배낭여행자';
          case 'hi': return 'बैकपैकर';
          case 'ar': return 'رحالة حقائب';
          case 'nl': return 'Backpacker';
          case 'el': return 'Ταξιδιώτης με σακίδιο';
          case 'sv': return 'Backpacker';
          case 'pl': return 'Plecakowicz';
          case 'id': return 'Backpacker';
          case 'th': return 'สะพายเป้';
          case 'vi': return 'Dân phượt';
          case 'en':
          default: return 'Backpacker';
        }
      case 'beach':
        switch (clean) {
          case 'tr': return 'Deniz & Plaj';
          case 'de': return 'Strandurlauber';
          case 'es': return 'Amante de la Playa';
          case 'fr': return 'Amateur de plage';
          case 'it': return 'Amante del mare';
          case 'pt': return 'Amante da Praia';
          case 'ru': return 'Пляжный отдых';
          case 'zh': return '海滩爱好者';
          case 'ja': return 'ビーチ派';
          case 'ko': return '해변 휴양객';
          case 'hi': return 'समुद्र तट प्रेमी';
          case 'ar': return 'محب الشواطئ';
          case 'nl': return 'Strandliefhebber';
          case 'el': return 'Λάτρης της παραλίας';
          case 'sv': return 'Strandälskare';
          case 'pl': return 'Miłośnik plaży';
          case 'id': return 'Pecinta Pantai';
          case 'th': return 'สายทะเล';
          case 'vi': return 'Yêu biển';
          case 'en':
          default: return 'Beach Lover';
        }
      case 'culture':
        switch (clean) {
          case 'tr': return 'Kültür & Tarih';
          case 'de': return 'Kultur & Geschichte';
          case 'es': return 'Cultura e Historia';
          case 'fr': return 'Culture & Histoire';
          case 'it': return 'Cultura e Storia';
          case 'pt': return 'Cultura e História';
          case 'ru': return 'Культура и история';
          case 'zh': return '文化与历史';
          case 'ja': return '歴史と文化';
          case 'ko': return '문화와 역사';
          case 'hi': return 'संस्कृति और इतिहास';
          case 'ar': return 'ثقافة وتاريخ';
          case 'nl': return 'Cultuur & Historie';
          case 'el': return 'Πολιτισμός & Ιστορία';
          case 'sv': return 'Kultur & Historia';
          case 'pl': return 'Kultura i historia';
          case 'id': return 'Budaya & Sejarah';
          case 'th': return 'วัฒนธรรมและประวัติศาสตร์';
          case 'vi': return 'Văn hóa & Lịch sử';
          case 'en':
          default: return 'Culture & History';
        }
      case 'nature':
        switch (clean) {
          case 'tr': return 'Doğa & Kamp';
          case 'de': return 'Natur & Camping';
          case 'es': return 'Naturaleza y Camping';
          case 'fr': return 'Nature & Camping';
          case 'it': return 'Natura e Campeggio';
          case 'pt': return 'Natureza e Acampamento';
          case 'ru': return 'Природа и кемпинг';
          case 'zh': return '自然与露营';
          case 'ja': return '自然とキャンプ';
          case 'ko': return '자연과 캠핑';
          case 'hi': return 'प्रकृति और शिविर';
          case 'ar': return 'طبيعة وتخييم';
          case 'nl': return 'Natuur & Kamperen';
          case 'el': return 'Φύση & Κατασκήνωση';
          case 'sv': return 'Natur & Camping';
          case 'pl': return 'Natura i kemping';
          case 'id': return 'Alam & Berkemah';
          case 'th': return 'ธรรมชาติและแคมป์ปิ้ง';
          case 'vi': return 'Thiên nhiên & Cắm trại';
          case 'en':
          default: return 'Nature & Camping';
        }
      case 'foodie':
        switch (clean) {
          case 'tr': return 'Gurme & Tatlar';
          case 'de': return 'Feinschmecker';
          case 'es': return 'Gastronomía & Sabor';
          case 'fr': return 'Gastronomie';
          case 'it': return 'Gourmet & Sapori';
          case 'pt': return 'Gastronomia';
          case 'ru': return 'Гурман';
          case 'zh': return '美食探索';
          case 'ja': return 'グルメ旅';
          case 'ko': return '미식 탐방';
          case 'hi': return 'स्वाद और खानपान';
          case 'ar': return 'عاشق المأكولات';
          case 'nl': return 'Fijnproever';
          case 'el': return 'Γαστρονομία';
          case 'sv': return 'Matälskare';
          case 'pl': return 'Smakosz';
          case 'id': return 'Wisata Kuliner';
          case 'th': return 'สายกิน';
          case 'vi': return 'Ẩm thực';
          case 'en':
          default: return 'Foodie';
        }
      case 'photographer':
        switch (clean) {
          case 'tr': return 'Fotoğraf & Keşif';
          case 'de': return 'Fotografie & Entdeckung';
          case 'es': return 'Fotografía & Exploración';
          case 'fr': return 'Photo & Découverte';
          case 'it': return 'Fotografia e Scoperte';
          case 'pt': return 'Fotografia & Exploração';
          case 'ru': return 'Фотография и кадры';
          case 'zh': return '摄影与探索';
          case 'ja': return '写真と探検';
          case 'ko': return '사진과 탐험';
          case 'hi': return 'फोटोग्राफी और खोज';
          case 'ar': return 'تصوير واستكشاف';
          case 'nl': return 'Fotografie & Ontdekking';
          case 'el': return 'Φωτογραφία & Εξερεύνηση';
          case 'sv': return 'Foto & Utforskning';
          case 'pl': return 'Fotografia i odkrycia';
          case 'id': return 'Fotografi & Eksplorasi';
          case 'th': return 'ช่างภาพและสำรวจ';
          case 'vi': return 'Nhiếp ảnh & Khám phá';
          case 'en':
          default: return 'Photographer';
        }
      case 'minimalist':
        switch (clean) {
          case 'tr': return 'Minimalist Bavulcu';
          case 'de': return 'Minimalistischer Packer';
          case 'es': return 'Equipaje Mínimo';
          case 'fr': return 'Voyageur minimaliste';
          case 'it': return 'Bagaglio Essenziale';
          case 'pt': return 'Bagagem Leve';
          case 'ru': return 'Минималист';
          case 'zh': return '极简打包者';
          case 'ja': return 'ミニマリスト';
          case 'ko': return '미니멀 패커';
          case 'hi': return 'कम सामान वाले';
          case 'ar': return 'حزم بسيط وخفيف';
          case 'nl': return 'Minimalistische Inpakker';
          case 'el': return 'Μινιμαλιστής';
          case 'sv': return 'Minimalistisk packare';
          case 'pl': return 'Minimalista pakowania';
          case 'id': return 'Pengemas Minimalis';
          case 'th': return 'แพ็กของแบบมินิมอล';
          case 'vi': return 'Gọn nhẹ tối giản';
          case 'en':
          default: return 'Minimalist Packer';
        }
      case 'spontaneous':
        switch (clean) {
          case 'tr': return 'Spontane Gezgin';
          case 'de': return 'Spontaner Reisender';
          case 'es': return 'Viajero Espontáneo';
          case 'fr': return 'Voyageur spontané';
          case 'it': return 'Viaggiatore Spontaneo';
          case 'pt': return 'Viajante Espontâneo';
          case 'ru': return 'Спонтанный путешественник';
          case 'zh': return '随性旅人';
          case 'ja': return '気ままな旅人';
          case 'ko': return '즉흥 여행가';
          case 'hi': return 'सहज यात्री';
          case 'ar': return 'مسافر عفوي';
          case 'nl': return 'Spontane Reiziger';
          case 'el': return 'Αυθόρμητος ταξιδιώτης';
          case 'sv': return 'Spontan resenär';
          case 'pl': return 'Spontaniczny podróżnik';
          case 'id': return 'Pelancong Spontan';
          case 'th': return 'เดินทางแบบตามใจ';
          case 'vi': return 'Ngẫu hứng tự do';
          case 'en':
          default: return 'Spontaneous';
        }
      case 'luxury':
        switch (clean) {
          case 'tr': return 'Konfor & Lüks';
          case 'de': return 'Luxus & Komfort';
          case 'es': return 'Lujo y Confort';
          case 'fr': return 'Luxe & Confort';
          case 'it': return 'Lusso e Comfort';
          case 'pt': return 'Luxo e Conforto';
          case 'ru': return 'Комфорт и люкс';
          case 'zh': return '奢华与舒适';
          case 'ja': return 'ラグジュアリー';
          case 'ko': return '럭셔리 & 힐링';
          case 'hi': return 'विलासिता और आराम';
          case 'ar': return 'فخامة وراحة';
          case 'nl': return 'Luxe & Comfort';
          case 'el': return 'Πολυτέλεια & Άνεση';
          case 'sv': return 'Lyx & Komfort';
          case 'pl': return 'Luksus i wygoda';
          case 'id': return 'Mewah & Nyaman';
          case 'th': return 'หรูหราสะดวกสบาย';
          case 'vi': return 'Sang trọng & Tiện nghi';
          case 'en':
          default: return 'Luxury & Comfort';
        }
      case 'roadtripper':
        switch (clean) {
          case 'tr': return 'Yol & Rota Tutkunu';
          case 'de': return 'Roadtrip-Fan';
          case 'es': return 'Amante de las Rutas';
          case 'fr': return 'Amateur de Road Trip';
          case 'it': return 'Amante dei Road Trip';
          case 'pt': return 'Fã de Road Trips';
          case 'ru': return 'Автопутешественник';
          case 'zh': return '自驾路线控';
          case 'ja': return 'ロードトリップ派';
          case 'ko': return '로드트립 매니아';
          case 'hi': return 'सड़क यात्रा प्रेमी';
          case 'ar': return 'عاشق الرحلات البرية';
          case 'nl': return 'Roadtrip-liefhebber';
          case 'el': return 'Λάτρης οδικών ταξιδιών';
          case 'sv': return 'Roadtrip-entusiast';
          case 'pl': return 'Miłośnik tras';
          case 'id': return 'Pecinta Perjalanan Darat';
          case 'th': return 'สายโรดทริป';
          case 'vi': return 'Thích đi phượt xe';
          case 'en':
          default: return 'Roadtripper';
        }
      default:
        return defaultName;
    }
  }

  static const List<TravelStyle> catalog = [
    TravelStyle(id: 'backpacker', emoji: '🎒', defaultName: 'Backpacker'),
    TravelStyle(id: 'beach', emoji: '🏖️', defaultName: 'Beach Lover'),
    TravelStyle(id: 'culture', emoji: '🏛️', defaultName: 'Culture & History'),
    TravelStyle(id: 'nature', emoji: '🏕️', defaultName: 'Nature & Camping'),
    TravelStyle(id: 'foodie', emoji: '🍽️', defaultName: 'Foodie'),
    TravelStyle(id: 'photographer', emoji: '📸', defaultName: 'Photographer'),
    TravelStyle(id: 'minimalist', emoji: '🧳', defaultName: 'Minimalist Packer'),
    TravelStyle(id: 'spontaneous', emoji: '⚡', defaultName: 'Spontaneous'),
    TravelStyle(id: 'luxury', emoji: '👑', defaultName: 'Luxury & Comfort'),
    TravelStyle(id: 'roadtripper', emoji: '🚗', defaultName: 'Roadtripper'),
  ];

  static TravelStyle? findById(String id) {
    try {
      return catalog.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
