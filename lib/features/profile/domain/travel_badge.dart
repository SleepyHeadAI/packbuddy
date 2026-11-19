import 'package:flutter/material.dart';

/// Badge achievement tiers with distinct metallic styling
enum BadgeTier {
  bronze,
  silver,
  gold,
  diamond;

  Color get primaryColor {
    switch (this) {
      case BadgeTier.bronze:
        return const Color(0xFFCD7F32);
      case BadgeTier.silver:
        return const Color(0xFF9E9E9E);
      case BadgeTier.gold:
        return const Color(0xFFFFB300);
      case BadgeTier.diamond:
        return const Color(0xFF00BCD4);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case BadgeTier.bronze:
        return const Color(0xFF8D5524);
      case BadgeTier.silver:
        return const Color(0xFF757575);
      case BadgeTier.gold:
        return const Color(0xFFFF8F00);
      case BadgeTier.diamond:
        return const Color(0xFF0097A7);
    }
  }

  String getLocalizedLabel(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (this) {
      case BadgeTier.bronze:
        switch (clean) {
          case 'tr': return 'Bronz';
          case 'de': return 'Bronze';
          case 'es': return 'Bronce';
          case 'fr': return 'Bronze';
          case 'it': return 'Bronzo';
          case 'pt': return 'Bronze';
          case 'ru': return 'Бронза';
          case 'zh': return '青铜';
          case 'ja': return 'ブロンズ';
          case 'ko': return '브론즈';
          case 'ar': return 'برونزي';
          case 'hi': return 'कांस्य';
          case 'nl': return 'Brons';
          case 'el': return 'Χάλκινο';
          case 'sv': return 'Brons';
          case 'pl': return 'Brąz';
          case 'id': return 'Perunggu';
          case 'th': return 'บรอนซ์';
          case 'vi': return 'Đồng';
          case 'en':
          default: return 'Bronze';
        }
      case BadgeTier.silver:
        switch (clean) {
          case 'tr': return 'Gümüş';
          case 'de': return 'Silber';
          case 'es': return 'Plata';
          case 'fr': return 'Argent';
          case 'it': return 'Argento';
          case 'pt': return 'Prata';
          case 'ru': return 'Серебро';
          case 'zh': return '白银';
          case 'ja': return 'シルバー';
          case 'ko': return '실버';
          case 'ar': return 'فضي';
          case 'hi': return 'रजत';
          case 'nl': return 'Zilver';
          case 'el': return 'Ασημένιο';
          case 'sv': return 'Silver';
          case 'pl': return 'Srebro';
          case 'id': return 'Perak';
          case 'th': return 'เงิน';
          case 'vi': return 'Bạc';
          case 'en':
          default: return 'Silver';
        }
      case BadgeTier.gold:
        switch (clean) {
          case 'tr': return 'Altın';
          case 'de': return 'Gold';
          case 'es': return 'Oro';
          case 'fr': return 'Or';
          case 'it': return 'Oro';
          case 'pt': return 'Ouro';
          case 'ru': return 'Золото';
          case 'zh': return '黄金';
          case 'ja': return 'ゴールド';
          case 'ko': return '골드';
          case 'ar': return 'ذهبي';
          case 'hi': return 'स्वर्ण';
          case 'nl': return 'Goud';
          case 'el': return 'Χρυσό';
          case 'sv': return 'Guld';
          case 'pl': return 'Złoto';
          case 'id': return 'Emas';
          case 'th': return 'ทอง';
          case 'vi': return 'Vàng';
          case 'en':
          default: return 'Gold';
        }
      case BadgeTier.diamond:
        switch (clean) {
          case 'tr': return 'Elmas';
          case 'de': return 'Diamant';
          case 'es': return 'Diamante';
          case 'fr': return 'Diamant';
          case 'it': return 'Diamante';
          case 'pt': return 'Diamante';
          case 'ru': return 'Алмаз';
          case 'zh': return '钻石';
          case 'ja': return 'ダイヤモンド';
          case 'ko': return '다이아몬드';
          case 'ar': return 'ماسي';
          case 'hi': return 'हीरा';
          case 'nl': return 'Diamant';
          case 'el': return 'Διαμάντι';
          case 'sv': return 'Diamant';
          case 'pl': return 'Diament';
          case 'id': return 'Berlian';
          case 'th': return 'เพชร';
          case 'vi': return 'Kim cương';
          case 'en':
          default: return 'Diamond';
        }
    }
  }
}

/// Domain model representing an automatically earned or progressive travel achievement badge
class TravelBadge {
  final String id;
  final String category;
  final IconData iconData;
  final BadgeTier tier;
  final int currentProgress;
  final int targetProgress;
  final bool isUnlocked;

  const TravelBadge({
    required this.id,
    required this.category,
    required this.iconData,
    required this.tier,
    required this.currentProgress,
    required this.targetProgress,
    required this.isUnlocked,
  });

  double get progressRatio => targetProgress > 0
      ? (currentProgress / targetProgress).clamp(0.0, 1.0)
      : (isUnlocked ? 1.0 : 0.0);

  String getLocalizedTitle(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (id) {
      case 'explorer_bronze':
        switch (clean) {
          case 'tr': return 'İlk Sınır Ötesi';
          case 'de': return 'Grenzgänger';
          case 'es': return 'Primer Cruce';
          case 'fr': return 'Passeur de Frontière';
          case 'it': return 'Primo Confine';
          case 'pt': return 'Primeira Fronteira';
          case 'ru': return 'Первый рубеж';
          case 'zh': return '初次出国';
          case 'ja': return 'ボーダーホッパー';
          case 'ko': return '첫 국경 넘기';
          case 'ar': return 'عابر الحدود الأول';
          case 'hi': return 'सीमा पार';
          case 'nl': return 'Grensganger';
          case 'el': return 'Πρώτο Σύνορο';
          case 'sv': return 'Gränsresenär';
          case 'pl': return 'Pierwsza Granica';
          case 'id': return 'Pelintas Batas';
          case 'th': return 'ก้าวข้ามพรมแดนแรก';
          case 'vi': return 'Vượt Biên Giới';
          default: return 'Border Hopper';
        }
      case 'explorer_silver':
        switch (clean) {
          case 'tr': return 'Kıta Gezgini';
          case 'de': return 'Kontinentalwanderer';
          case 'es': return 'Viajero Continental';
          case 'fr': return 'Voyageur Continental';
          case 'it': return 'Viaggiatore Continentale';
          case 'pt': return 'Viajante Continental';
          case 'ru': return 'Странник континентов';
          case 'zh': return '洲际漫游者';
          case 'ja': return '大陸の放浪者';
          case 'ko': return '대륙 방랑자';
          case 'ar': return 'جوال القارات';
          case 'hi': return 'महाद्वीपीय पथिक';
          case 'nl': return 'Continentale Reiziger';
          case 'el': return 'Πλανήτης της Ηπείρου';
          case 'sv': return 'Kontinentalresenär';
          case 'pl': return 'Kontynentalny Wędrowiec';
          case 'id': return 'Penjelajah Benua';
          case 'th': return 'นักท่องทวีป';
          case 'vi': return 'Lữ Khách Lục Địa';
          default: return 'Continental Wanderer';
        }
      case 'explorer_gold':
        switch (clean) {
          case 'tr': return 'Dünya Kaşifi';
          case 'de': return 'Weltenbummler';
          case 'es': return 'Trotamundos';
          case 'fr': return 'Globe-Trotteur';
          case 'it': return 'Giramondo';
          case 'pt': return 'Globetrotter';
          case 'ru': return 'Исследователь мира';
          case 'zh': return '环球旅行家';
          case 'ja': return 'グローブトロッター';
          case 'ko': return '글로브 트로터';
          case 'ar': return 'مستكشف العالم';
          case 'hi': return 'विश्व खोजी';
          case 'nl': return 'Wereldreiziger';
          case 'el': return 'Εξερευνητής του Κόσμου';
          case 'sv': return 'Jordomseglare';
          case 'pl': return 'Obieżyświat';
          case 'id': return 'Penjelajah Dunia';
          case 'th': return 'นักสำรวจรอบโลก';
          case 'vi': return 'Nhà Thám Hiểm Thế Giới';
          default: return 'Globe Trotter';
        }
      case 'explorer_diamond':
        switch (clean) {
          case 'tr': return 'Evrensel Kaşif';
          case 'de': return 'Universeller Entdecker';
          case 'es': return 'Explorador Universal';
          case 'fr': return 'Explorateur Universel';
          case 'it': return 'Esploratore Universale';
          case 'pt': return 'Explorador Universal';
          case 'ru': return 'Великий исследователь';
          case 'zh': return '无界探索者';
          case 'ja': return 'ユニバーサル探検家';
          case 'ko': return '우주적 탐험가';
          case 'ar': return 'المستكشف الشامل';
          case 'hi': return 'सर्वकालिक खोजकर्ता';
          case 'nl': return 'Universele Ontdekker';
          case 'el': return 'Παγκόσμιος Εξερευνητής';
          case 'sv': return 'Universell Upptäckare';
          case 'pl': return 'Uniwersalny Odkrywca';
          case 'id': return 'Penjelajah Ulung';
          case 'th': return 'สุดยอดนักสำรวจสากล';
          case 'vi': return 'Nhà Thám Hiểm Vĩ Đại';
          default: return 'Universal Explorer';
        }

      case 'trips_bronze':
        switch (clean) {
          case 'tr': return 'İlk Yolculuk';
          case 'de': return 'Erste Reise';
          case 'es': return 'Primer Viaje';
          case 'fr': return 'Premier Voyage';
          case 'it': return 'Primo Viaggio';
          case 'pt': return 'Primeira Viagem';
          case 'ru': return 'Первое путешествие';
          case 'zh': return '初次启程';
          case 'ja': return '最初の旅';
          case 'ko': return '첫 번째 여정';
          case 'ar': return 'الرحلة الأولى';
          case 'hi': return 'पहली यात्रा';
          case 'nl': return 'Eerste Reis';
          case 'el': return 'Πρώτο Ταξίδι';
          case 'sv': return 'Första Resan';
          case 'pl': return 'Pierwsza Podróż';
          case 'id': return 'Perjalanan Pertama';
          case 'th': return 'การเดินทางครั้งแรก';
          case 'vi': return 'Hành Trình Đầu Tiên';
          default: return 'First Journey';
        }
      case 'trips_silver':
        switch (clean) {
          case 'tr': return 'Yol Tutkunu';
          case 'de': return 'Reisebegeisterter';
          case 'es': return 'Entusiasta de la Ruta';
          case 'fr': return 'Passionné de Route';
          case 'it': return 'Appassionato di Viaggi';
          case 'pt': return 'Entusiasta da Estrada';
          case 'ru': return 'Энтузиаст дорог';
          case 'zh': return '旅行热衷者';
          case 'ja': return '旅の愛好家';
          case 'ko': return '여행 열정가';
          case 'ar': return 'عاشق الطرق';
          case 'hi': return 'सफर प्रेमी';
          case 'nl': return 'Reisliefhebber';
          case 'el': return 'Λάτρης του Δρόμου';
          case 'sv': return 'Reseentusiast';
          case 'pl': return 'Miłośnik Podróży';
          case 'id': return 'Pecinta Jalanan';
          case 'th': return 'ผู้หลงใหลการเดินทาง';
          case 'vi': return 'Người Mê Dịch Chuyển';
          default: return 'Road Enthusiast';
        }
      case 'trips_gold':
        switch (clean) {
          case 'tr': return 'Seyahat Ustası';
          case 'de': return 'Reisemeister';
          case 'es': return 'Maestro Viajero';
          case 'fr': return 'Maître Voyageur';
          case 'it': return 'Maestro dei Viaggi';
          case 'pt': return 'Mestre Viajante';
          case 'ru': return 'Мастер путешествий';
          case 'zh': return '旅行大师';
          case 'ja': return '旅の達人';
          case 'ko': return '여행의 달인';
          case 'ar': return 'سيد السفر';
          case 'hi': return 'यात्रा गुरु';
          case 'nl': return 'Reismeester';
          case 'el': return 'Αυθεντία Ταξιδιών';
          case 'sv': return 'Resemästare';
          case 'pl': return 'Mistrz Podróży';
          case 'id': return 'Master Traveler';
          case 'th': return 'ปรมาจารย์การเดินทาง';
          case 'vi': return 'Bậc Thầy Du Lịch';
          default: return 'Master Traveler';
        }
      case 'trips_diamond':
        switch (clean) {
          case 'tr': return 'Efsanevi Seyyah';
          case 'de': return 'Legendärer Nomade';
          case 'es': return 'Nómada Legendario';
          case 'fr': return 'Nomade Légendaire';
          case 'it': return 'Nomade Leggendario';
          case 'pt': return 'Nômade Lendário';
          case 'ru': return 'Легендарный кочевник';
          case 'zh': return '传奇行者';
          case 'ja': return '伝説の遊牧民';
          case 'ko': return '전설적인 방랑자';
          case 'ar': return 'الرحالة الأسطوري';
          case 'hi': return 'महान घुमक्कड़';
          case 'nl': return 'Legendarische Nomade';
          case 'el': return 'Θρυλικός Νομάς';
          case 'sv': return 'Legendarisk Nomad';
          case 'pl': return 'Legendarny Nomada';
          case 'id': return 'Nomaden Legendaris';
          case 'th': return 'คนพเนจรในตำนาน';
          case 'vi': return 'Du Mục Huyền Thoại';
          default: return 'Legendary Nomad';
        }

      case 'packing_bronze':
        switch (clean) {
          case 'tr': return 'Hazırlıklı Bavul';
          case 'de': return 'Gepackter Koffer';
          case 'es': return 'Maleta Preparada';
          case 'fr': return 'Valise Prête';
          case 'it': return 'Valigia Pronta';
          case 'pt': return 'Mala Pronta';
          case 'ru': return 'Собранный багаж';
          case 'zh': return '准备就绪';
          case 'ja': return '準備万端';
          case 'ko': return '준비된 여행 가방';
          case 'ar': return 'حقيبة جاهزة';
          case 'hi': return 'तैयार सूटकेस';
          case 'nl': return 'Klaargemaakte Koffer';
          case 'el': return 'Έτοιμη Αποσκευή';
          case 'sv': return 'Packad Resväska';
          case 'pl': return 'Gotowa Walizka';
          case 'id': return 'Koper Siap';
          case 'th': return 'กระเป๋าพร้อมเดินทาง';
          case 'vi': return 'Hành Lý Sẵn Sàng';
          default: return 'Ready Luggage';
        }
      case 'packing_silver':
        switch (clean) {
          case 'tr': return 'Kompakt Paketleyici';
          case 'de': return 'Kompakter Packer';
          case 'es': return 'Empacador Compacto';
          case 'fr': return 'Emballeur Compact';
          case 'it': return 'Organizzatore Compatto';
          case 'pt': return 'Embalador Compacto';
          case 'ru': return 'Компактный упаковщик';
          case 'zh': return '收纳能手';
          case 'ja': return 'コンパクトパッカー';
          case 'ko': return '컴팩트 패커';
          case 'ar': return 'الحازم الذكي';
          case 'hi': return 'कुशल पैकर';
          case 'nl': return 'Compacte Inpakker';
          case 'el': return 'Συμπαγής Πακεταριστής';
          case 'sv': return 'Kompaktpackare';
          case 'pl': return 'Kompaktowy Pakowacz';
          case 'id': return 'Pengemas Efisien';
          case 'th': return 'นักจัดกระเป๋าตัวยง';
          case 'vi': return 'Chuyên Gia Xếp Đồ';
          default: return 'Compact Packer';
        }
      case 'packing_gold':
        switch (clean) {
          case 'tr': return 'Bavul Virtüözü';
          case 'de': return 'Pack-Virtuose';
          case 'es': return 'Virtuoso de la Maleta';
          case 'fr': return 'Virtuose du Bagage';
          case 'it': return 'Virtuoso della Valigia';
          case 'pt': return 'Virtuoso da Mala';
          case 'ru': return 'Виртуоз багажа';
          case 'zh': return '整理大师';
          case 'ja': return 'パッキングの達人';
          case 'ko': return '패킹의 명수';
          case 'ar': return 'بارع التوضيب';
          case 'hi': return 'पैकिंग उस्ताद';
          case 'nl': return 'Inpakvirtuoos';
          case 'el': return 'Βιρτουόζος Αποσκευών';
          case 'sv': return 'Packvirtuos';
          case 'pl': return 'Wirtuoz Pakowania';
          case 'id': return 'Ahli Pengepakan';
          case 'th': return 'เซียนจัดกระเป๋า';
          case 'vi': return 'Bậc Thầy Hành Lý';
          default: return 'Packing Virtuoso';
        }
      case 'packing_diamond':
        switch (clean) {
          case 'tr': return 'Kusursuz Lojistik';
          case 'de': return 'Perfekte Logistik';
          case 'es': return 'Logística Impecable';
          case 'fr': return 'Logistique Impeccable';
          case 'it': return 'Logistica Impeccabile';
          case 'pt': return 'Logística Impecável';
          case 'ru': return 'Безупречная логистика';
          case 'zh': return '完美管家';
          case 'ja': return '完璧なロジスティクス';
          case 'ko': return '완벽한 로지스틱스';
          case 'ar': return 'اللوجستيات الفائقة';
          case 'hi': return 'सटीक प्रबंधन';
          case 'nl': return 'Vlekkeloze Logistiek';
          case 'el': return 'Άψογη Επιμελητεία';
          case 'sv': return 'Felfri Logistik';
          case 'pl': return 'Bezbłędna Logistyka';
          case 'id': return 'Logistik Sempurna';
          case 'th': return 'การจัดการไร้ที่ติ';
          case 'vi': return 'Hậu Cần Hoàn Hảo';
          default: return 'Flawless Logistics';
        }

      case 'vault_bronze':
        switch (clean) {
          case 'tr': return 'Güvenli Yolcu';
          case 'de': return 'Geschützter Reisender';
          case 'es': return 'Viajero Protegido';
          case 'fr': return 'Voyageur Protégé';
          case 'it': return 'Viaggiatore Protetto';
          case 'pt': return 'Viajante Protegido';
          case 'ru': return 'Защищенный путник';
          case 'zh': return '安心出行';
          case 'ja': return '安心トラベラー';
          case 'ko': return '안전한 여행자';
          case 'ar': return 'المسافر المحمي';
          case 'hi': return 'सुरक्षित यात्री';
          case 'nl': return 'Beschermde Reiziger';
          case 'el': return 'Προστατευμένος Ταξιδιώτης';
          case 'sv': return 'Skyddad Resenär';
          case 'pl': return 'Bezpieczny Podróżnik';
          case 'id': return 'Pelancong Terlindungi';
          case 'th': return 'นักเดินทางปลอดภัย';
          case 'vi': return 'Lữ Khách An Toàn';
          default: return 'Protected Traveler';
        }
      case 'vault_silver':
        switch (clean) {
          case 'tr': return 'Evrak Muhafızı';
          case 'de': return 'Dokumentenwächter';
          case 'es': return 'Guardián de la Bóveda';
          case 'fr': return 'Sentinelle du Coffre';
          case 'it': return 'Sentinella dei Documenti';
          case 'pt': return 'Sentinela do Cofre';
          case 'ru': return 'Страж документов';
          case 'zh': return '文档守卫';
          case 'ja': return '保管庫の番人';
          case 'ko': return '문서 수호자';
          case 'ar': return 'حارس الخزنة';
          case 'hi': return 'दस्तावेज़ रक्षक';
          case 'nl': return 'Kluisbewaker';
          case 'el': return 'Φρουρός Θησαυροφυλακίου';
          case 'sv': return 'Valvväktare';
          case 'pl': return 'Strażnik Sejfu';
          case 'id': return 'Penjaga Brankas';
          case 'th': return 'ผู้พิทักษ์เอกสาร';
          case 'vi': return 'Người Giữ Tài Liệu';
          default: return 'Vault Sentinel';
        }
      case 'vault_gold':
        switch (clean) {
          case 'tr': return 'Eksiksiz Arşiv';
          case 'de': return 'Makelloses Archiv';
          case 'es': return 'Archivo Impecable';
          case 'fr': return 'Archive Impeccable';
          case 'it': return 'Archivio Impeccabile';
          case 'pt': return 'Arquivo Impecável';
          case 'ru': return 'Безупречный архив';
          case 'zh': return '完备档案';
          case 'ja': return '完全なるアーカイブ';
          case 'ko': return '완벽한 아카이브';
          case 'ar': return 'الأرشيف المتكامل';
          case 'hi': return 'उत्कृष्ट अभिलेखागार';
          case 'nl': return 'Vlekkeloos Archief';
          case 'el': return 'Άψογο Αρχείο';
          case 'sv': return 'Felfritt Arkiv';
          case 'pl': return 'Bezbłędne Archiwum';
          case 'id': return 'Arsip Sempurna';
          case 'th': return 'คลังเอกสารสมบูรณ์แบบ';
          case 'vi': return 'Lưu Trữ Hoàn Hảo';
          default: return 'Flawless Archive';
        }

      default:
        return 'Traveler Badge';
    }
  }

  String getLocalizedDescription(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (id) {
      case 'explorer_bronze':
        switch (clean) {
          case 'tr': return '1 ülke ziyaret edildi';
          case 'de': return '1 Land besucht';
          case 'es': return '1 país visitado';
          case 'fr': return '1 pays visité';
          case 'it': return '1 paese visitato';
          case 'pt': return '1 país visitado';
          case 'ru': return '1 страна посещена';
          case 'zh': return '已探索1个国家';
          case 'ja': return '1か国を訪問';
          case 'ko': return '1개국 방문';
          case 'ar': return 'تمت زيارة بلد واحد';
          case 'hi': return '1 देश की यात्रा की';
          case 'nl': return '1 land bezocht';
          case 'el': return '1 χώρα επισκέφθηκε';
          case 'sv': return '1 land besökt';
          case 'pl': return 'Odwiedzono 1 kraj';
          case 'id': return '1 negara dikunjungi';
          case 'th': return 'เยือน 1 ประเทศ';
          case 'vi': return 'Đã đến 1 quốc gia';
          default: return '1 country visited';
        }
      case 'explorer_silver':
        switch (clean) {
          case 'tr': return '5 ülke ziyaret edildi';
          case 'de': return '5 Länder besucht';
          case 'es': return '5 países visitados';
          case 'fr': return '5 pays visités';
          case 'it': return '5 paesi visitati';
          case 'pt': return '5 países visitados';
          case 'ru': return '5 стран посещено';
          case 'zh': return '已探索5个国家';
          case 'ja': return '5か国を訪問';
          case 'ko': return '5개국 방문';
          case 'ar': return 'تمت زيارة 5 دول';
          case 'hi': return '5 देशों की यात्रा की';
          case 'nl': return '5 landen bezocht';
          case 'el': return '5 χώρες επισκέφθηκαν';
          case 'sv': return '5 länder besökta';
          case 'pl': return 'Odwiedzono 5 krajów';
          case 'id': return '5 negara dikunjungi';
          case 'th': return 'เยือน 5 ประเทศ';
          case 'vi': return 'Đã đến 5 quốc gia';
          default: return '5 countries visited';
        }
      case 'explorer_gold':
        switch (clean) {
          case 'tr': return '10 ülke ziyaret edildi';
          case 'de': return '10 Länder besucht';
          case 'es': return '10 países visitados';
          case 'fr': return '10 pays visités';
          case 'it': return '10 paesi visitati';
          case 'pt': return '10 países visitados';
          case 'ru': return '10 стран посещено';
          case 'zh': return '已探索10个国家';
          case 'ja': return '10か国を訪問';
          case 'ko': return '10개국 방문';
          case 'ar': return 'تمت زيارة 10 دول';
          case 'hi': return '10 देशों की यात्रा की';
          case 'nl': return '10 landen bezocht';
          case 'el': return '10 χώρες επισκέφθηκαν';
          case 'sv': return '10 länder besökta';
          case 'pl': return 'Odwiedzono 10 krajów';
          case 'id': return '10 negara dikunjungi';
          case 'th': return 'เยือน 10 ประเทศ';
          case 'vi': return 'Đã đến 10 quốc gia';
          default: return '10 countries visited';
        }
      case 'explorer_diamond':
        switch (clean) {
          case 'tr': return '25 ülke ziyaret edildi';
          case 'de': return '25 Länder besucht';
          case 'es': return '25 países visitados';
          case 'fr': return '25 pays visités';
          case 'it': return '25 paesi visitati';
          case 'pt': return '25 países visitados';
          case 'ru': return '25 стран посещено';
          case 'zh': return '已探索25个国家';
          case 'ja': return '25か国を訪問';
          case 'ko': return '25개국 방문';
          case 'ar': return 'تمت زيارة 25 بلداً';
          case 'hi': return '25 देशों की यात्रा की';
          case 'nl': return '25 landen bezocht';
          case 'el': return '25 χώρες επισκέφθηκαν';
          case 'sv': return '25 länder besökta';
          case 'pl': return 'Odwiedzono 25 krajów';
          case 'id': return '25 negara dikunjungi';
          case 'th': return 'เยือน 25 ประเทศ';
          case 'vi': return 'Đã đến 25 quốc gia';
          default: return '25 countries visited';
        }

      case 'trips_bronze':
        switch (clean) {
          case 'tr': return '1 seyahat planlandı';
          case 'de': return '1 Reise geplant';
          case 'es': return '1 viaje planeado';
          case 'fr': return '1 voyage planifié';
          case 'it': return '1 viaggio pianificato';
          case 'pt': return '1 viagem planejada';
          case 'ru': return '1 поездка спланирована';
          case 'zh': return '已规划1次旅行';
          case 'ja': return '1回の旅行を計画';
          case 'ko': return '1개 여행 계획 완료';
          case 'ar': return 'تم التخطيط لرحلة واحدة';
          case 'hi': return '1 यात्रा की योजना बनाई';
          case 'nl': return '1 reis gepland';
          case 'el': return '1 ταξίδι προγραμματίστηκε';
          case 'sv': return '1 resa planerad';
          case 'pl': return 'Zaplanowano 1 podróż';
          case 'id': return '1 perjalanan direncanakan';
          case 'th': return 'วางแผน 1 ทริป';
          case 'vi': return 'Đã lên kế hoạch 1 chuyến đi';
          default: return '1 trip planned';
        }
      case 'trips_silver':
        switch (clean) {
          case 'tr': return '5 seyahat tamamlandı';
          case 'de': return '5 Reisen abgeschlossen';
          case 'es': return '5 viajes completados';
          case 'fr': return '5 voyages terminés';
          case 'it': return '5 viaggi completati';
          case 'pt': return '5 viagens concluídas';
          case 'ru': return '5 поездок завершено';
          case 'zh': return '已完成5次旅行';
          case 'ja': return '5回の旅行を完了';
          case 'ko': return '5개 여행 완료';
          case 'ar': return 'تم إكمال 5 رحلات';
          case 'hi': return '5 यात्राएं पूरी कीं';
          case 'nl': return '5 reizen voltooid';
          case 'el': return '5 ταξίδια ολοκληρώθηκαν';
          case 'sv': return '5 resor slutförda';
          case 'pl': return 'Ukończono 5 podróży';
          case 'id': return '5 perjalanan diselesaikan';
          case 'th': return 'สำเร็จ 5 ทริป';
          case 'vi': return 'Đã hoàn thành 5 chuyến đi';
          default: return '5 trips completed';
        }
      case 'trips_gold':
        switch (clean) {
          case 'tr': return '15 seyahat tamamlandı';
          case 'de': return '15 Reisen abgeschlossen';
          case 'es': return '15 viajes completados';
          case 'fr': return '15 voyages terminés';
          case 'it': return '15 viaggi completati';
          case 'pt': return '15 viagens concluídas';
          case 'ru': return '15 поездок завершено';
          case 'zh': return '已完成15次旅行';
          case 'ja': return '15回の旅行を完了';
          case 'ko': return '15개 여행 완료';
          case 'ar': return 'تم إكمال 15 رحلة';
          case 'hi': return '15 यात्राएं पूरी कीं';
          case 'nl': return '15 reizen voltooid';
          case 'el': return '15 ταξίδια ολοκληρώθηκαν';
          case 'sv': return '15 resor slutförda';
          case 'pl': return 'Ukończono 15 podróży';
          case 'id': return '15 perjalanan diselesaikan';
          case 'th': return 'สำเร็จ 15 ทริป';
          case 'vi': return 'Đã hoàn thành 15 chuyến đi';
          default: return '15 trips completed';
        }
      case 'trips_diamond':
        switch (clean) {
          case 'tr': return '30 seyahat tamamlandı';
          case 'de': return '30 Reisen abgeschlossen';
          case 'es': return '30 viajes completados';
          case 'fr': return '30 voyages terminés';
          case 'it': return '30 viaggi completati';
          case 'pt': return '30 viagens concluídas';
          case 'ru': return '30 поездок завершено';
          case 'zh': return '已完成30次旅行';
          case 'ja': return '30回の旅行を完了';
          case 'ko': return '30개 여행 완료';
          case 'ar': return 'تم إكمال 30 رحلة';
          case 'hi': return '30 यात्राएं पूरी कीं';
          case 'nl': return '30 reizen voltooid';
          case 'el': return '30 ταξίδια ολοκληρώθηκαν';
          case 'sv': return '30 resor slutförda';
          case 'pl': return 'Ukończono 30 podróży';
          case 'id': return '30 perjalanan diselesaikan';
          case 'th': return 'สำเร็จ 30 ทริป';
          case 'vi': return 'Đã hoàn thành 30 chuyến đi';
          default: return '30 trips completed';
        }

      case 'packing_bronze':
        switch (clean) {
          case 'tr': return '25 bavul eşyası eklendi';
          case 'de': return '25 Gegenstände gepackt';
          case 'es': return '25 artículos empacados';
          case 'fr': return '25 articles emballés';
          case 'it': return '25 oggetti preparati';
          case 'pt': return '25 itens embalados';
          case 'ru': return '25 предметов упаковано';
          case 'zh': return '已整理25件行李';
          case 'ja': return '25個の荷造り完了';
          case 'ko': return '25개 짐 패킹';
          case 'ar': return 'تم حزم 25 غرضاً';
          case 'hi': return '25 सामान पैक किए';
          case 'nl': return '25 items ingepakt';
          case 'el': return '25 αντικείμενα πακεταρίστηκαν';
          case 'sv': return '25 föremål packade';
          case 'pl': return 'Spakowano 25 przedmiotów';
          case 'id': return '25 barang dikemas';
          case 'th': return 'จัดของ 25 ชิ้น';
          case 'vi': return 'Đã đóng gói 25 món đồ';
          default: return '25 items packed';
        }
      case 'packing_silver':
        switch (clean) {
          case 'tr': return '100 bavul eşyası hazırlandı';
          case 'de': return '100 Gegenstände gepackt';
          case 'es': return '100 artículos empacados';
          case 'fr': return '100 articles emballés';
          case 'it': return '100 oggetti preparati';
          case 'pt': return '100 itens embalados';
          case 'ru': return '100 предметов упаковано';
          case 'zh': return '已整理100件行李';
          case 'ja': return '100個の荷造り完了';
          case 'ko': return '100개 짐 패킹';
          case 'ar': return 'تم حزم 100 غرض';
          case 'hi': return '100 सामान पैक किए';
          case 'nl': return '100 items ingepakt';
          case 'el': return '100 αντικείμενα πακεταρίστηκαν';
          case 'sv': return '100 föremål packade';
          case 'pl': return 'Spakowano 100 przedmiotów';
          case 'id': return '100 barang dikemas';
          case 'th': return 'จัดของ 100 ชิ้น';
          case 'vi': return 'Đã đóng gói 100 món đồ';
          default: return '100 items packed';
        }
      case 'packing_gold':
        switch (clean) {
          case 'tr': return '250 bavul eşyası organize edildi';
          case 'de': return '250 Gegenstände gepackt';
          case 'es': return '250 artículos empacados';
          case 'fr': return '250 articles emballés';
          case 'it': return '250 oggetti preparati';
          case 'pt': return '250 itens embalados';
          case 'ru': return '250 предметов упаковано';
          case 'zh': return '已整理250件行李';
          case 'ja': return '250個の荷造り完了';
          case 'ko': return '250개 짐 패킹';
          case 'ar': return 'تم تنظيم 250 غرضاً';
          case 'hi': return '250 सामान पैक किए';
          case 'nl': return '250 items georganiseerd';
          case 'el': return '250 αντικείμενα οργανώθηκαν';
          case 'sv': return '250 föremål organiserade';
          case 'pl': return 'Uporządkowano 250 przedmiotów';
          case 'id': return '250 barang diatur';
          case 'th': return 'จัดระเบียบ 250 ชิ้น';
          case 'vi': return 'Đã tổ chức 250 món đồ';
          default: return '250 items packed';
        }
      case 'packing_diamond':
        switch (clean) {
          case 'tr': return '500 bavul eşyası organize edildi';
          case 'de': return '500 Gegenstände gepackt';
          case 'es': return '500 artículos empacados';
          case 'fr': return '500 articles emballés';
          case 'it': return '500 oggetti preparati';
          case 'pt': return '500 itens embalados';
          case 'ru': return '500 предметов упаковано';
          case 'zh': return '已整理500件行李';
          case 'ja': return '500個の荷造り完了';
          case 'ko': return '500개 짐 패킹';
          case 'ar': return 'تم تنظيم 500 غرض';
          case 'hi': return '500 सामान पैक किए';
          case 'nl': return '500 items georganiseerd';
          case 'el': return '500 αντικείμενα οργανώθηκαν';
          case 'sv': return '500 föremål organiserade';
          case 'pl': return 'Uporządkowano 500 przedmiotów';
          case 'id': return '500 barang diatur';
          case 'th': return 'จัดระเบียบ 500 ชิ้น';
          case 'vi': return 'Đã tổ chức 500 món đồ';
          default: return '500 items packed';
        }

      case 'vault_bronze':
        switch (clean) {
          case 'tr': return '1 seyahat belgesi kasada korundu';
          case 'de': return '1 Reisedokument im Safe gesichert';
          case 'es': return '1 documento asegurado en la bóveda';
          case 'fr': return '1 document sécurisé dans le coffre';
          case 'it': return '1 documento protetto in cassaforte';
          case 'pt': return '1 documento protegido no cofre';
          case 'ru': return '1 документ защищен в сейфе';
          case 'zh': return '1份旅行文件已安全存档';
          case 'ja': return '1件の旅行書類を保管';
          case 'ko': return '1개 문서 금고 보관';
          case 'ar': return 'تم تأمين وثيقة سفر واحدة في الخزنة';
          case 'hi': return '1 यात्रा दस्तावेज़ सुरक्षित';
          case 'nl': return '1 reisdocument beveiligd in kluis';
          case 'el': return '1 ταξιδιωτικό έγγραφο στο θησαυροφυλάκιο';
          case 'sv': return '1 resedokument säkrat i valvet';
          case 'pl': return '1 dokument zabezpieczony w sejfie';
          case 'id': return '1 dokumen aman di brankas';
          case 'th': return 'เก็บเอกสารในตู้เซฟ 1 รายการ';
          case 'vi': return '1 tài liệu bảo mật trong két';
          default: return '1 travel doc secured in vault';
        }
      case 'vault_silver':
        switch (clean) {
          case 'tr': return '5 seyahat belgesi kasada korundu';
          case 'de': return '5 Reisedokumente im Safe gesichert';
          case 'es': return '5 documentos asegurados en la bóveda';
          case 'fr': return '5 documents sécurisés dans le coffre';
          case 'it': return '5 documenti protetti in cassaforte';
          case 'pt': return '5 documentos protegidos no cofre';
          case 'ru': return '5 документов защищено в сейфе';
          case 'zh': return '5份旅行文件已安全存档';
          case 'ja': return '5件の旅行書類を保管';
          case 'ko': return '5개 문서 금고 보관';
          case 'ar': return 'تم تأمين 5 وثائق في الخزنة';
          case 'hi': return '5 यात्रा दस्तावेज़ सुरक्षित';
          case 'nl': return '5 reisdocumenten beveiligd in kluis';
          case 'el': return '5 ταξιδιωτικά έγγραφα στο θησαυροφυλάκιο';
          case 'sv': return '5 resedokument säkrade i valvet';
          case 'pl': return '5 dokumentów zabezpieczonych w sejfie';
          case 'id': return '5 dokumen aman di brankas';
          case 'th': return 'เก็บเอกสารในตู้เซฟ 5 รายการ';
          case 'vi': return '5 tài liệu bảo mật trong két';
          default: return '5 travel docs secured in vault';
        }
      case 'vault_gold':
        switch (clean) {
          case 'tr': return '15 seyahat belgesi kasada korundu';
          case 'de': return '15 Reisedokumente im Safe gesichert';
          case 'es': return '15 documentos asegurados en la bóveda';
          case 'fr': return '15 documents sécurisés dans le coffre';
          case 'it': return '15 documenti protetti in cassaforte';
          case 'pt': return '15 documentos protegidos no cofre';
          case 'ru': return '15 документов защищено в сейфе';
          case 'zh': return '15份旅行文件已安全存档';
          case 'ja': return '15件の旅行書類を保管';
          case 'ko': return '15개 문서 금고 보관';
          case 'ar': return 'تم تأمين 15 وثيقة في الخزنة';
          case 'hi': return '15 यात्रा दस्तावेज़ सुरक्षित';
          case 'nl': return '15 reisdocumenten beveiligd in kluis';
          case 'el': return '15 ταξιδιωτικά έγγραφα στο θησαυροφυλάκιο';
          case 'sv': return '15 resedokument säkrade i valvet';
          case 'pl': return '15 dokumentów zabezpieczonych w sejfie';
          case 'id': return '15 dokumen aman di brankas';
          case 'th': return 'เก็บเอกสารในตู้เซฟ 15 รายการ';
          case 'vi': return '15 tài liệu bảo mật trong két';
          default: return '15 travel docs secured in vault';
        }

      default:
        return '';
    }
  }

  /// Calculates the complete achievement list from live user statistics
  static List<TravelBadge> calculateBadges({
    required int totalTrips,
    required int totalCountries,
    required int totalItems,
    required int totalDocuments,
  }) {
    return [
      // 1. World Explorer Milestones
      TravelBadge(
        id: 'explorer_bronze',
        category: 'countries',
        iconData: Icons.explore_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalCountries,
        targetProgress: 1,
        isUnlocked: totalCountries >= 1,
      ),
      TravelBadge(
        id: 'explorer_silver',
        category: 'countries',
        iconData: Icons.public_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalCountries,
        targetProgress: 5,
        isUnlocked: totalCountries >= 5,
      ),
      TravelBadge(
        id: 'explorer_gold',
        category: 'countries',
        iconData: Icons.language_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalCountries,
        targetProgress: 10,
        isUnlocked: totalCountries >= 10,
      ),
      TravelBadge(
        id: 'explorer_diamond',
        category: 'countries',
        iconData: Icons.auto_awesome_rounded,
        tier: BadgeTier.diamond,
        currentProgress: totalCountries,
        targetProgress: 25,
        isUnlocked: totalCountries >= 25,
      ),

      // 2. Trips Milestones
      TravelBadge(
        id: 'trips_bronze',
        category: 'trips',
        iconData: Icons.flight_takeoff_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalTrips,
        targetProgress: 1,
        isUnlocked: totalTrips >= 1,
      ),
      TravelBadge(
        id: 'trips_silver',
        category: 'trips',
        iconData: Icons.flight_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalTrips,
        targetProgress: 5,
        isUnlocked: totalTrips >= 5,
      ),
      TravelBadge(
        id: 'trips_gold',
        category: 'trips',
        iconData: Icons.connecting_airports_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalTrips,
        targetProgress: 15,
        isUnlocked: totalTrips >= 15,
      ),
      TravelBadge(
        id: 'trips_diamond',
        category: 'trips',
        iconData: Icons.stars_rounded,
        tier: BadgeTier.diamond,
        currentProgress: totalTrips,
        targetProgress: 30,
        isUnlocked: totalTrips >= 30,
      ),

      // 3. Packing Milestones
      TravelBadge(
        id: 'packing_bronze',
        category: 'items',
        iconData: Icons.check_circle_outline_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalItems,
        targetProgress: 25,
        isUnlocked: totalItems >= 25,
      ),
      TravelBadge(
        id: 'packing_silver',
        category: 'items',
        iconData: Icons.inventory_2_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalItems,
        targetProgress: 100,
        isUnlocked: totalItems >= 100,
      ),
      TravelBadge(
        id: 'packing_gold',
        category: 'items',
        iconData: Icons.task_alt_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalItems,
        targetProgress: 250,
        isUnlocked: totalItems >= 250,
      ),
      TravelBadge(
        id: 'packing_diamond',
        category: 'items',
        iconData: Icons.verified_rounded,
        tier: BadgeTier.diamond,
        currentProgress: totalItems,
        targetProgress: 500,
        isUnlocked: totalItems >= 500,
      ),

      // 4. Vault Documents Milestones
      TravelBadge(
        id: 'vault_bronze',
        category: 'docs',
        iconData: Icons.security_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalDocuments,
        targetProgress: 1,
        isUnlocked: totalDocuments >= 1,
      ),
      TravelBadge(
        id: 'vault_silver',
        category: 'docs',
        iconData: Icons.lock_clock_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalDocuments,
        targetProgress: 5,
        isUnlocked: totalDocuments >= 5,
      ),
      TravelBadge(
        id: 'vault_gold',
        category: 'docs',
        iconData: Icons.shield_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalDocuments,
        targetProgress: 15,
        isUnlocked: totalDocuments >= 15,
      ),
    ];
  }
}
