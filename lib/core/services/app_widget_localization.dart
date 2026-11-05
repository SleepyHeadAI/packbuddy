/// Centralized localization repository for Home Screen Widgets and In-App Widget Preview (Feature F-9)
/// Supports all 20 official PackBuddy languages with zero missing keys or Turkish fallback artifacts.
class AppWidgetLocalization {
  AppWidgetLocalization._();

  static const List<String> supportedLanguages = [
    'tr', 'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
  ];

  /// Resolves the header subtitle under "Home Screen Widget"
  static String getHeaderSubtitle(String lang) {
    switch (lang) {
      case 'tr':
        return 'Aktif seyahat ve dünya haritası anlık istatistikleri';
      case 'es':
        return 'Estadísticas de viaje activo y mapa mundial en tiempo real';
      case 'fr':
        return 'Statistiques en direct pour voyages et carte du monde';
      case 'de':
        return 'Echtzeit-Statistiken für aktive Reise & Weltkarte';
      case 'it':
        return 'Statistiche in tempo reale per viaggi e mappa del mondo';
      case 'pt':
        return 'Estatísticas de viagem ativa e mapa-múndi em tempo real';
      case 'ru':
        return 'Статистика поездки и карты мира в реальном времени';
      case 'zh':
        return '活跃行程与世界地图实时统计';
      case 'ja':
        return '旅行と世界地図のリアルタイム統計';
      case 'ko':
        return '진행 중인 여행 및 세계 지도 실시간 통계';
      case 'hi':
        return 'सक्रिय यात्रा और विश्व मानचित्र के वास्तविक आँकड़े';
      case 'ar':
        return 'إحصائيات فورية للرحلة النشطة وخريطة العالم';
      case 'nl':
        return 'Live statistieken voor actieve reizen & wereldkaart';
      case 'el':
        return 'Στατιστικά σε πραγματικό χρόνο για ταξίδια και παγκόσμιο χάρτη';
      case 'sv':
        return 'Realtidsstatistik för aktiva resor & världskarta';
      case 'pl':
        return 'Statystyki aktywnej podróży i mapy świata na żywo';
      case 'id':
        return 'Statistik langsung untuk perjalanan aktif & peta dunia';
      case 'th':
        return 'สถิติแบบเรียลไทม์สำหรับทริปและแผนที่โลก';
      case 'vi':
        return 'Thống kê trực tiếp cho chuyến đi & bản đồ thế giới';
      default:
        return 'Live stats for active trips & world travel map';
    }
  }

  /// Resolves "🌟 Auto (Smart)" mode chip label
  static String getAutoModeLabel(String lang) {
    switch (lang) {
      case 'tr':
        return '🌟 Otomatik (Akıllı)';
      case 'es':
        return '🌟 Automático (Inteligente)';
      case 'fr':
        return '🌟 Automatique (Intelligent)';
      case 'de':
        return '🌟 Automatisch (Smart)';
      case 'it':
        return '🌟 Automatico (Smart)';
      case 'pt':
        return '🌟 Automático (Inteligente)';
      case 'ru':
        return '🌟 Авто (Умный)';
      case 'zh':
        return '🌟 自动 (智能)';
      case 'ja':
        return '🌟 自動 (スマート)';
      case 'ko':
        return '🌟 자동 (스마트)';
      case 'hi':
        return '🌟 स्वचालित (स्मार्ट)';
      case 'ar':
        return '🌟 تلقائي (ذكي)';
      case 'nl':
        return '🌟 Automatisch (Slim)';
      case 'el':
        return '🌟 Αυτόματο (Έξυπνο)';
      case 'sv':
        return '🌟 Automatiskt (Smart)';
      case 'pl':
        return '🌟 Automatyczny (Smart)';
      case 'id':
        return '🌟 Otomatis (Pintar)';
      case 'th':
        return '🌟 อัตโนมัติ (สมาร์ท)';
      case 'vi':
        return '🌟 Tự động (Thông minh)';
      default:
        return '🌟 Auto (Smart)';
    }
  }

  /// Resolves "✈️ Active Trip" mode chip label
  static String getTripModeLabel(String lang) {
    switch (lang) {
      case 'tr':
        return '✈️ Aktif Seyahat';
      case 'es':
        return '✈️ Viaje Activo';
      case 'fr':
        return '✈️ Voyage Actif';
      case 'de':
        return '✈️ Aktive Reise';
      case 'it':
        return '✈️ Viaggio Attivo';
      case 'pt':
        return '✈️ Viagem Ativa';
      case 'ru':
        return '✈️ Активная поездка';
      case 'zh':
        return '✈️ 进行中行程';
      case 'ja':
        return '✈️ 旅行中';
      case 'ko':
        return '✈️ 진행 중인 여행';
      case 'hi':
        return '✈️ सक्रिय यात्रा';
      case 'ar':
        return '✈️ الرحلة النشطة';
      case 'nl':
        return '✈️ Actieve Reis';
      case 'el':
        return '✈️ Ενεργό Ταξίδι';
      case 'sv':
        return '✈️ Aktiv Resa';
      case 'pl':
        return '✈️ Aktywna Podróż';
      case 'id':
        return '✈️ Perjalanan Aktif';
      case 'th':
        return '✈️ ทริปที่กำลังเดินทาง';
      case 'vi':
        return '✈️ Chuyến đi hiện tại';
      default:
        return '✈️ Active Trip';
    }
  }

  /// Resolves "🌍 World Map" mode chip label
  static String getWorldMapModeLabel(String lang) {
    switch (lang) {
      case 'tr':
        return '🌍 Dünya Haritası';
      case 'es':
        return '🌍 Mapa Mundial';
      case 'fr':
        return '🌍 Carte du Monde';
      case 'de':
        return '🌍 Weltkarte';
      case 'it':
        return '🌍 Mappa del Mondo';
      case 'pt':
        return '🌍 Mapa-Múndi';
      case 'ru':
        return '🌍 Карта мира';
      case 'zh':
        return '🌍 世界地图';
      case 'ja':
        return '🌍 世界地図';
      case 'ko':
        return '🌍 세계 지도';
      case 'hi':
        return '🌍 विश्व मानचित्र';
      case 'ar':
        return '🌍 خريطة العالم';
      case 'nl':
        return '🌍 Wereldkaart';
      case 'el':
        return '🌍 Παγκόσμιος Χάρτης';
      case 'sv':
        return '🌍 Världskarta';
      case 'pl':
        return '🌍 Mapa Świata';
      case 'id':
        return '🌍 Peta Dunia';
      case 'th':
        return '🌍 แผนที่โลก';
      case 'vi':
        return '🌍 Bản đồ thế giới';
      default:
        return '🌍 World Map';
    }
  }

  /// Resolves "💱 Currency Converter" mode chip label
  static String getCurrencyConverterModeLabel(String lang) {
    switch (lang) {
      case 'tr':
        return '💱 Döviz Çevirici';
      case 'es':
        return '💱 Conversor de Divisas';
      case 'fr':
        return '💱 Convertisseur de Devises';
      case 'de':
        return '💱 Währungsrechner';
      case 'it':
        return '💱 Convertitore di Valuta';
      case 'pt':
        return '💱 Conversor de Moedas';
      case 'ru':
        return '💱 Конвертер валют';
      case 'zh':
        return '💱 汇率换算器';
      case 'ja':
        return '💱 為替レート計算機';
      case 'ko':
        return '💱 환율 계산기';
      case 'hi':
        return '💱 मुद्रा परिवर्तक';
      case 'ar':
        return '💱 محول العملات';
      case 'nl':
        return '💱 Valutaconverter';
      case 'el':
        return '💱 Μετατροπέας Νομισμάτων';
      case 'sv':
        return '💱 Valutaomvandlare';
      case 'pl':
        return '💱 Przelicznik Walut';
      case 'id':
        return '💱 Konverter Mata Uang';
      case 'th':
        return '💱 แปลงสกุลเงิน';
      case 'vi':
        return '💱 Chuyển đổi tiền tệ';
      default:
        return '💱 Currency Converter';
    }
  }

  /// Resolves "💰 Quick Expense" mode chip label
  static String getQuickExpenseModeLabel(String lang) {
    switch (lang) {
      case 'tr':
        return '💰 Hızlı Harcama';
      case 'es':
        return '💰 Gasto Rápido';
      case 'fr':
        return '💰 Dépense Rapide';
      case 'de':
        return '💰 Schnellausgabe';
      case 'it':
        return '💰 Spesa Rapida';
      case 'pt':
        return '💰 Despesa Rápida';
      case 'ru':
        return '💰 Быстрый расход';
      case 'zh':
        return '💰 快捷记账';
      case 'ja':
        return '💰 クイック支出';
      case 'ko':
        return '💰 빠른 지출 기록';
      case 'hi':
        return '💰 त्वरित व्यय';
      case 'ar':
        return '💰 تسجيل مصروف';
      case 'nl':
        return '💰 Snelle Uitgave';
      case 'el':
        return '💰 Γρήγορο Έξοδο';
      case 'sv':
        return '💰 Snabbutgift';
      case 'pl':
        return '💰 Szybki Wydatek';
      case 'id':
        return '💰 Pengeluaran Cepat';
      case 'th':
        return '💰 บันทึกค่าใช้จ่ายด่วน';
      case 'vi':
        return '💰 Thêm chi tiêu nhanh';
      default:
        return '💰 Quick Expense';
    }
  }

  /// App name badge header for Currency Converter
  static String getCurrencyHeader(String lang) {
    switch (lang) {
      case 'tr':
        return 'PackBuddy • Kur';
      case 'es':
        return 'PackBuddy • Divisas';
      case 'fr':
        return 'PackBuddy • Devises';
      case 'de':
        return 'PackBuddy • Kurse';
      case 'it':
        return 'PackBuddy • Valute';
      case 'pt':
        return 'PackBuddy • Câmbio';
      case 'ru':
        return 'PackBuddy • Валюты';
      case 'zh':
        return 'PackBuddy • 汇率';
      case 'ja':
        return 'PackBuddy • 為替';
      case 'ko':
        return 'PackBuddy • 환율';
      case 'hi':
        return 'PackBuddy • मुद्रा';
      case 'ar':
        return 'PackBuddy • العملات';
      case 'nl':
        return 'PackBuddy • Valuta';
      case 'el':
        return 'PackBuddy • Συνάλλαγμα';
      case 'sv':
        return 'PackBuddy • Valutor';
      case 'pl':
        return 'PackBuddy • Waluty';
      case 'id':
        return 'PackBuddy • Kurs';
      case 'th':
        return 'PackBuddy • อัตราแลกเปลี่ยน';
      case 'vi':
        return 'PackBuddy • Tỷ giá';
      default:
        return 'PackBuddy • Rates';
    }
  }

  /// App name badge header for Quick Expense
  static String getExpenseHeader(String lang) {
    switch (lang) {
      case 'tr':
        return 'PackBuddy • Bütçe';
      case 'es':
        return 'PackBuddy • Presupuesto';
      case 'fr':
        return 'PackBuddy • Budget';
      case 'de':
        return 'PackBuddy • Budget';
      case 'it':
        return 'PackBuddy • Budget';
      case 'pt':
        return 'PackBuddy • Orçamento';
      case 'ru':
        return 'PackBuddy • Бюджет';
      case 'zh':
        return 'PackBuddy • 预算';
      case 'ja':
        return 'PackBuddy • 予算';
      case 'ko':
        return 'PackBuddy • 예산';
      case 'hi':
        return 'PackBuddy • बजट';
      case 'ar':
        return 'PackBuddy • الميزانية';
      case 'nl':
        return 'PackBuddy • Budget';
      case 'el':
        return 'PackBuddy • Προϋπολογισμός';
      case 'sv':
        return 'PackBuddy • Budget';
      case 'pl':
        return 'PackBuddy • Budżet';
      case 'id':
        return 'PackBuddy • Anggaran';
      case 'th':
        return 'PackBuddy • งบประมาณ';
      case 'vi':
        return 'PackBuddy • Ngân sách';
      default:
        return 'PackBuddy • Budget';
    }
  }

  /// Labels for custom mini option switches
  static String getShowContinentsLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Kıta İstatistiklerini Göster';
      case 'es':
        return 'Mostrar estadísticas de continentes';
      case 'fr':
        return 'Afficher les statistiques de continents';
      case 'de':
        return 'Kontinent-Statistiken anzeigen';
      default:
        return 'Show Continent Stats';
    }
  }

  static String getShowWishlistLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Hedef Ülkeleri Göster';
      case 'es':
        return 'Mostrar países deseados';
      case 'fr':
        return 'Afficher la liste des souhaits';
      case 'de':
        return 'Wunschländer anzeigen';
      default:
        return 'Show Wishlist Countries';
    }
  }

  static String getShowLiveRateLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Canlı / Çevrimdışı Kur Göstergesi';
      case 'es':
        return 'Mostrar indicador en vivo / sin conexión';
      case 'fr':
        return 'Afficher l\'indicateur direct / hors-ligne';
      case 'de':
        return 'Live / Offline-Indikator anzeigen';
      default:
        return 'Show Live / Offline Indicator';
    }
  }

  static String getShowReverseRateLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Ters Çevrim Kurunu Göster';
      case 'es':
        return 'Mostrar tasa de cambio inversa';
      case 'fr':
        return 'Afficher le taux de change inverse';
      case 'de':
        return 'Inversen Wechselkurs anzeigen';
      default:
        return 'Show Inverse Conversion Rate';
    }
  }

  static String getShowRemainingBudgetLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Kalan Bütçeyi Göster';
      case 'es':
        return 'Mostrar presupuesto restante';
      case 'fr':
        return 'Afficher le budget restant';
      case 'de':
        return 'Verbleibendes Budget anzeigen';
      default:
        return 'Show Remaining Budget';
    }
  }

  static String getShowLastExpenseLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Son Harcama Detayını Göster';
      case 'es':
        return 'Mostrar último gasto';
      case 'fr':
        return 'Afficher la dernière dépense';
      case 'de':
        return 'Letzte Ausgabe anzeigen';
      default:
        return 'Show Last Expense Summary';
    }
  }

  /// App name badge header for World Map
  static String getWorldHeader(String lang) {
    switch (lang) {
      case 'tr':
        return 'PackBuddy • Dünya';
      case 'es':
        return 'PackBuddy • Mundo';
      case 'fr':
        return 'PackBuddy • Monde';
      case 'de':
        return 'PackBuddy • Welt';
      case 'it':
        return 'PackBuddy • Mondo';
      case 'pt':
        return 'PackBuddy • Mundo';
      case 'ru':
        return 'PackBuddy • Мир';
      case 'zh':
        return 'PackBuddy • 世界';
      case 'ja':
        return 'PackBuddy • 世界';
      case 'ko':
        return 'PackBuddy • 세계';
      case 'hi':
        return 'PackBuddy • विश्व';
      case 'ar':
        return 'PackBuddy • العالم';
      case 'nl':
        return 'PackBuddy • Wereld';
      case 'el':
        return 'PackBuddy • Κόσμος';
      case 'sv':
        return 'PackBuddy • Världen';
      case 'pl':
        return 'PackBuddy • Świat';
      case 'id':
        return 'PackBuddy • Dunia';
      case 'th':
        return 'PackBuddy • โลก';
      case 'vi':
        return 'PackBuddy • Thế giới';
      default:
        return 'PackBuddy • World';
    }
  }

  /// App name badge header for Trip
  static String getTripHeader(String lang) {
    switch (lang) {
      case 'tr':
        return 'PackBuddy • Seyahat';
      case 'es':
        return 'PackBuddy • Viaje';
      case 'fr':
        return 'PackBuddy • Voyage';
      case 'de':
        return 'PackBuddy • Reise';
      case 'it':
        return 'PackBuddy • Viaggio';
      case 'pt':
        return 'PackBuddy • Viagem';
      case 'ru':
        return 'PackBuddy • Поездка';
      case 'zh':
        return 'PackBuddy • 行程';
      case 'ja':
        return 'PackBuddy • 旅行';
      case 'ko':
        return 'PackBuddy • 여행';
      case 'hi':
        return 'PackBuddy • यात्रा';
      case 'ar':
        return 'PackBuddy • رحلة';
      case 'nl':
        return 'PackBuddy • Reis';
      case 'el':
        return 'PackBuddy • Ταξίδι';
      case 'sv':
        return 'PackBuddy • Resa';
      case 'pl':
        return 'PackBuddy • Podróż';
      case 'id':
        return 'PackBuddy • Perjalanan';
      case 'th':
        return 'PackBuddy • ทริป';
      case 'vi':
        return 'PackBuddy • Chuyến đi';
      default:
        return 'PackBuddy • Trip';
    }
  }

  /// Visited countries title
  static String getVisitedTitle(String lang, int count) {
    if (count <= 0) {
      switch (lang) {
        case 'tr':
          return 'Dünya Haritası';
        case 'es':
          return 'Mapa Mundial';
        case 'fr':
          return 'Carte du Monde';
        case 'de':
          return 'Weltkarte';
        case 'it':
          return 'Mappa del Mondo';
        case 'pt':
          return 'Mapa-Múndi';
        case 'ru':
          return 'Карта мира';
        case 'zh':
          return '世界地图';
        case 'ja':
          return '世界地図';
        case 'ko':
          return '세계 지도';
        case 'hi':
          return 'विश्व मानचित्र';
        case 'ar':
          return 'خريطة العالم';
        case 'nl':
          return 'Wereldkaart';
        case 'el':
          return 'Παγκόσμιος Χάρτης';
        case 'sv':
          return 'Världskarta';
        case 'pl':
          return 'Mapa Świata';
        case 'id':
          return 'Peta Dunia';
        case 'th':
          return 'แผนที่โลก';
        case 'vi':
          return 'Bản đồ thế giới';
        default:
          return 'World Map';
      }
    }

    switch (lang) {
      case 'tr':
        return '$count Ülke Gezildi';
      case 'es':
        return count == 1 ? '1 País Visitado' : '$count Países Visitados';
      case 'fr':
        return count == 1 ? '1 Pays Visité' : '$count Pays Visités';
      case 'de':
        return count == 1 ? '1 Land Besucht' : '$count Länder Besucht';
      case 'it':
        return '$count Paesi Visitati';
      case 'pt':
        return '$count Países Visitados';
      case 'ru':
        return '$count Стран Посещено';
      case 'zh':
        return '已游历 $count 个国家';
      case 'ja':
        return '$count か国を訪問';
      case 'ko':
        return '$count개국 방문 완료';
      case 'hi':
        return '$count देश घूमे';
      case 'ar':
        return 'تمت زيارة $count دولة';
      case 'nl':
        return '$count Landen Bezocht';
      case 'el':
        return '$count Χώρες Επισκέφθηκαν';
      case 'sv':
        return '$count Länder Besökta';
      case 'pl':
        return '$count Krajów Odwiedzonych';
      case 'id':
        return '$count Negara Dikunjungi';
      case 'th':
        return 'เที่ยวแล้ว $count ประเทศ';
      case 'vi':
        return 'Đã đến $count quốc gia';
      default:
        return count == 1 ? '1 Country Visited' : '$count Countries Visited';
    }
  }

  /// Continents explored subtitle
  static String getContinentsSubtitle(String lang, int count) {
    if (count <= 0) {
      switch (lang) {
        case 'tr':
          return 'Ülkeleri haritadan işaretle';
        case 'es':
          return 'Marca países en el mapa';
        case 'fr':
          return 'Marquez les pays sur la carte';
        case 'de':
          return 'Länder auf der Karte markieren';
        case 'it':
          return 'Segna i paesi sulla mappa';
        case 'pt':
          return 'Marque países no mapa';
        case 'ru':
          return 'Отметьте страны на карте';
        case 'zh':
          return '在地图上标记国家';
        case 'ja':
          return '地図上で国を記録';
        case 'ko':
          return '지도에서 국가를 표시하세요';
        case 'hi':
          return 'मानचित्र पर देशों को चिह्नित करें';
        case 'ar':
          return 'حدد الدول على الخريطة';
        case 'nl':
          return 'Markeer landen op de kaart';
        case 'el':
          return 'Σημειώστε χώρες στον χάρτη';
        case 'sv':
          return 'Markera länder på kartan';
        case 'pl':
          return 'Zaznacz kraje na mapie';
        case 'id':
          return 'Tandai negara di peta';
        case 'th':
          return 'ทำเครื่องหมายประเทศบนแผนที่';
        case 'vi':
          return 'Đánh dấu các quốc gia trên bản đồ';
        default:
          return 'Mark countries on map';
      }
    }

    switch (lang) {
      case 'tr':
        return '$count Kıta Keşfedildi';
      case 'es':
        return count == 1 ? '1 Continente Explorado' : '$count Continentes Explorados';
      case 'fr':
        return count == 1 ? '1 Continent Exploré' : '$count Continents Explorés';
      case 'de':
        return count == 1 ? '1 Kontinent Entdeckt' : '$count Kontinente Entdeckt';
      case 'it':
        return '$count Continenti Esplorati';
      case 'pt':
        return '$count Continentes Explorados';
      case 'ru':
        return '$count Континентов Исследовано';
      case 'zh':
        return '已探索 $count 个大洲';
      case 'ja':
        return '$count 大陸を探検';
      case 'ko':
        return '$count개 대륙 탐험';
      case 'hi':
        return '$count महाद्वीप खोजे गए';
      case 'ar':
        return 'تم استكشاف $count قارات';
      case 'nl':
        return '$count Continenten Ontdekt';
      case 'el':
        return '$count Ήπειροι Εξερευνήθηκαν';
      case 'sv':
        return '$count Kontinenter Utforskade';
      case 'pl':
        return '$count Kontynentów Odkrytych';
      case 'id':
        return '$count Benua Dijelajahi';
      case 'th':
        return 'สำรวจแล้ว $count ทวีป';
      case 'vi':
        return 'Đã khám phá $count châu lục';
      default:
        return count == 1 ? '1 Continent Explored' : '$count Continents Explored';
    }
  }

  /// Exploration Rate label
  static String getExplorationRateLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Keşif Oranı';
      case 'es':
        return 'Tasa de Exploración';
      case 'fr':
        return 'Taux d\'Exploration';
      case 'de':
        return 'Erkundungsrate';
      case 'it':
        return 'Tasso di Esplorazione';
      case 'pt':
        return 'Taxa de Exploração';
      case 'ru':
        return 'Степень исследования';
      case 'zh':
        return '探索率';
      case 'ja':
        return '探検率';
      case 'ko':
        return '탐험률';
      case 'hi':
        return 'अन्वेषण दर';
      case 'ar':
        return 'نسبة الاستكشاف';
      case 'nl':
        return 'Verkenningspercentage';
      case 'el':
        return 'Ποσοστό Εξερεύνησης';
      case 'sv':
        return 'Utforskningsgrad';
      case 'pl':
        return 'Wskaźnik Odkrycia';
      case 'id':
        return 'Tingkat Eksplorasi';
      case 'th':
        return 'อัตราการสำรวจ';
      case 'vi':
        return 'Tỷ lệ khám phá';
      default:
        return 'Exploration Rate';
    }
  }

  /// Visited stat badge label (e.g. ✈️ 28 Visited)
  static String getVisitedStatLabel(String lang, int count) {
    switch (lang) {
      case 'tr':
        return '✈️ $count Gezildi';
      case 'es':
        return '✈️ $count Visitado';
      case 'fr':
        return '✈️ $count Visité';
      case 'de':
        return '✈️ $count Besucht';
      case 'it':
        return '✈️ $count Visitato';
      case 'pt':
        return '✈️ $count Visitado';
      case 'ru':
        return '✈️ $count Посещено';
      case 'zh':
        return '✈️ $count 已游历';
      case 'ja':
        return '✈️ $count 訪問済';
      case 'ko':
        return '✈️ $count 방문';
      case 'hi':
        return '✈️ $count घूमे';
      case 'ar':
        return '✈️ $count تمت زيارتها';
      case 'nl':
        return '✈️ $count Bezocht';
      case 'el':
        return '✈️ $count Επισκέφθηκαν';
      case 'sv':
        return '✈️ $count Besökta';
      case 'pl':
        return '✈️ $count Odwiedzone';
      case 'id':
        return '✈️ $count Dikunjungi';
      case 'th':
        return '✈️ $count เที่ยวแล้ว';
      case 'vi':
        return '✈️ $count Đã đến';
      default:
        return '✈️ $count Visited';
    }
  }

  /// Wishlist stat badge label (e.g. 🌟 0 Wishlist)
  static String getWishlistStatLabel(String lang, int count) {
    switch (lang) {
      case 'tr':
        return '🌟 $count Hedef';
      case 'es':
        return '🌟 $count Deseado';
      case 'fr':
        return '🌟 $count Envie';
      case 'de':
        return '🌟 $count Wunschliste';
      case 'it':
        return '🌟 $count Desiderati';
      case 'pt':
        return '🌟 $count Desejados';
      case 'ru':
        return '🌟 $count В планах';
      case 'zh':
        return '🌟 $count 愿望单';
      case 'ja':
        return '🌟 $count 行きたい';
      case 'ko':
        return '🌟 $count 위시리스트';
      case 'hi':
        return '🌟 $count इच्छासूची';
      case 'ar':
        return '🌟 $count في الأمنيات';
      case 'nl':
        return '🌟 $count Verlanglijst';
      case 'el':
        return '🌟 $count Επιθυμητά';
      case 'sv':
        return '🌟 $count Önskelista';
      case 'pl':
        return '🌟 $count Na liście';
      case 'id':
        return '🌟 $count Impian';
      case 'th':
        return '🌟 $count สิ่งที่อยากไป';
      case 'vi':
        return '🌟 $count Muốn đến';
      default:
        return '🌟 $count Wishlist';
    }
  }

  /// Continents stat badge label (e.g. 🌍 2 Continents)
  static String getContinentsStatLabel(String lang, int count) {
    switch (lang) {
      case 'tr':
        return '🌍 $count Kıta';
      case 'es':
        return count == 1 ? '🌍 1 Continente' : '🌍 $count Continentes';
      case 'fr':
        return count == 1 ? '🌍 1 Continent' : '🌍 $count Continents';
      case 'de':
        return count == 1 ? '🌍 1 Kontinent' : '🌍 $count Kontinente';
      case 'it':
        return count == 1 ? '🌍 1 Continente' : '🌍 $count Continenti';
      case 'pt':
        return count == 1 ? '🌍 1 Continente' : '🌍 $count Continentes';
      case 'ru':
        return '🌍 $count Континентов';
      case 'zh':
        return '🌍 $count 大洲';
      case 'ja':
        return '🌍 $count 大陸';
      case 'ko':
        return '🌍 $count 대륙';
      case 'hi':
        return '🌍 $count महाद्वीप';
      case 'ar':
        return '🌍 $count قارات';
      case 'nl':
        return '🌍 $count Continenten';
      case 'el':
        return '🌍 $count Ήπειροι';
      case 'sv':
        return '🌍 $count Kontinenter';
      case 'pl':
        return '🌍 $count Kontynentów';
      case 'id':
        return '🌍 $count Benua';
      case 'th':
        return '🌍 $count ทวีป';
      case 'vi':
        return '🌍 $count Châu lục';
      default:
        return count == 1 ? '🌍 1 Continent' : '🌍 $count Continents';
    }
  }

  /// Map legend labels
  static String getLegendLived(String lang) {
    switch (lang) {
      case 'tr':
        return 'Yaşandı';
      case 'es':
        return 'Vivido';
      case 'fr':
        return 'Vécu';
      case 'de':
        return 'Gelebt';
      case 'it':
        return 'Vissuto';
      case 'pt':
        return 'Morou';
      case 'ru':
        return 'Жил';
      case 'zh':
        return '居住过';
      case 'ja':
        return '在住';
      case 'ko':
        return '거주';
      case 'hi':
        return 'निवास किया';
      case 'ar':
        return 'إقامة';
      case 'nl':
        return 'Gewoond';
      case 'el':
        return 'Έζησε';
      case 'sv':
        return 'Bott';
      case 'pl':
        return 'Mieszkane';
      case 'id':
        return 'Tinggal';
      case 'th':
        return 'เคยอยู่';
      case 'vi':
        return 'Đã sống';
      default:
        return 'Lived';
    }
  }

  static String getLegendVisited(String lang) {
    switch (lang) {
      case 'tr':
        return 'Gezildi';
      case 'es':
        return 'Visitado';
      case 'fr':
        return 'Visité';
      case 'de':
        return 'Besucht';
      case 'it':
        return 'Visitato';
      case 'pt':
        return 'Visitado';
      case 'ru':
        return 'Посещено';
      case 'zh':
        return '已游历';
      case 'ja':
        return '訪問';
      case 'ko':
        return '방문';
      case 'hi':
        return 'घूमे';
      case 'ar':
        return 'زيارة';
      case 'nl':
        return 'Bezocht';
      case 'el':
        return 'Επίσκεψη';
      case 'sv':
        return 'Besökt';
      case 'pl':
        return 'Odwiedzone';
      case 'id':
        return 'Dikunjungi';
      case 'th':
        return 'เที่ยวแล้ว';
      case 'vi':
        return 'Đã đến';
      default:
        return 'Visited';
    }
  }

  static String getLegendWishlist(String lang) {
    switch (lang) {
      case 'tr':
        return 'Hedef';
      case 'es':
        return 'Deseado';
      case 'fr':
        return 'Envie';
      case 'de':
        return 'Wunschliste';
      case 'it':
        return 'Desiderato';
      case 'pt':
        return 'Desejo';
      case 'ru':
        return 'В планах';
      case 'zh':
        return '愿望单';
      case 'ja':
        return '行きたい';
      case 'ko':
        return '위시리스트';
      case 'hi':
        return 'इच्छासूची';
      case 'ar':
        return 'في الأمنيات';
      case 'nl':
        return 'Wens';
      case 'el':
        return 'Στόχος';
      case 'sv':
        return 'Önskelista';
      case 'pl':
        return 'Na liście';
      case 'id':
        return 'Impian';
      case 'th':
        return 'อยากไป';
      case 'vi':
        return 'Muốn đến';
      default:
        return 'Wishlist';
    }
  }

  /// Days countdown formatters
  static String getDaysSuffix(String lang) {
    switch (lang) {
      case 'tr':
        return 'g';
      case 'de':
        return 'T';
      case 'fr':
        return 'j';
      case 'it':
        return 'g';
      case 'ru':
        return 'д';
      case 'zh':
        return '天';
      case 'ja':
        return '日';
      case 'ko':
        return '일';
      case 'ar':
        return 'ي';
      case 'el':
        return 'ημ';
      case 'th':
        return 'วัน';
      case 'vi':
        return 'ng';
      default:
        return 'd';
    }
  }

  static String formatDaysUntil(String lang, int days) {
    if (days > 0) {
      switch (lang) {
        case 'tr':
          return '$days gün kaldı';
        case 'es':
          return 'Faltan $days días';
        case 'fr':
          return 'Dans $days jours';
        case 'de':
          return 'Noch $days Tage';
        case 'it':
          return 'Mancano $days giorni';
        case 'pt':
          return 'Faltam $days dias';
        case 'ru':
          return 'Осталось $days дн.';
        case 'zh':
          return '还有 $days 天';
        case 'ja':
          return 'あと $days 日';
        case 'ko':
          return '$days일 남음';
        case 'hi':
          return '$days दिन शेष';
        case 'ar':
          return 'باقٍ $days أيام';
        case 'nl':
          return 'Nog $days dagen';
        case 'el':
          return 'Απομένουν $days μέρες';
        case 'sv':
          return '$days dagar kvar';
        case 'pl':
          return 'Pozostało $days dni';
        case 'id':
          return 'Sisa $days hari';
        case 'th':
          return 'เหลืออีก $days วัน';
        case 'vi':
          return 'Còn $days ngày';
        default:
          return '$days days left';
      }
    } else if (days == 0) {
      switch (lang) {
        case 'tr':
          return 'Bugün';
        case 'es':
          return 'Hoy';
        case 'fr':
          return "Aujourd'hui";
        case 'de':
          return 'Heute';
        case 'it':
          return 'Oggi';
        case 'pt':
          return 'Hoje';
        case 'ru':
          return 'Сегодня';
        case 'zh':
          return '今天';
        case 'ja':
          return '今日';
        case 'ko':
          return '오늘';
        case 'hi':
          return 'आज';
        case 'ar':
          return 'اليوم';
        case 'nl':
          return 'Vandaag';
        case 'el':
          return 'Σήμερα';
        case 'sv':
          return 'Idag';
        case 'pl':
          return 'Dzisiaj';
        case 'id':
          return 'Hari ini';
        case 'th':
          return 'วันนี้';
        case 'vi':
          return 'Hôm nay';
        default:
          return 'Today';
      }
    } else {
      switch (lang) {
        case 'tr':
          return 'Hazır';
        case 'es':
          return 'Listo';
        case 'fr':
          return 'Prêt';
        case 'de':
          return 'Bereit';
        case 'it':
          return 'Pronto';
        case 'pt':
          return 'Pronto';
        case 'ru':
          return 'Готово';
        case 'zh':
          return '准备就绪';
        case 'ja':
          return '準備完了';
        case 'ko':
          return '준비 완료';
        case 'hi':
          return 'तैयार';
        case 'ar':
          return 'جاهز';
        case 'nl':
          return 'Gereed';
        case 'el':
          return 'Έτοιμο';
        case 'sv':
          return 'Redo';
        case 'pl':
          return 'Gotowe';
        case 'id':
          return 'Siap';
        case 'th':
          return 'พร้อม';
        case 'vi':
          return 'Sẵn sàng';
        default:
          return 'Ready';
      }
    }
  }

  /// Default trip destination label when no upcoming trip exists
  static String getDefaultDestination(String lang) {
    switch (lang) {
      case 'tr':
        return 'Bir sonraki seyahatini planla';
      case 'es':
        return 'Planea tu próximo viaje';
      case 'fr':
        return 'Planifiez votre prochain voyage';
      case 'de':
        return 'Plane deine nächste Reise';
      case 'it':
        return 'Pianifica il tuo prossimo viaggio';
      case 'pt':
        return 'Planeje sua próxima viagem';
      case 'ru':
        return 'Запланируйте следующую поездку';
      case 'zh':
        return '规划你的下一次旅行';
      case 'ja':
        return '次の旅行を計画する';
      case 'ko':
        return '다음 여행을 계획해 보세요';
      case 'hi':
        return 'अपनी अगली यात्रा की योजना बनाएं';
      case 'ar':
        return 'خطط لرحلتك القادمة';
      case 'nl':
        return 'Plan je volgende reis';
      case 'el':
        return 'Σχεδιάστε το επόμενο ταξίδι σας';
      case 'sv':
        return 'Planera din nästa resa';
      case 'pl':
        return 'Zaplanuj kolejną podróż';
      case 'id':
        return 'Rencanakan perjalanan berikutnya';
      case 'th':
        return 'วางแผนทริปต่อไปของคุณ';
      case 'vi':
        return 'Lên kế hoạch cho chuyến đi tiếp theo';
      default:
        return 'Plan your next trip';
    }
  }

  /// Packing progress label (e.g. Packing: 5/10)
  static String getPackingLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Bavul';
      case 'es':
        return 'Equipaje';
      case 'fr':
        return 'Bagages';
      case 'de':
        return 'Gepäck';
      case 'it':
        return 'Bagagli';
      case 'pt':
        return 'Malas';
      case 'ru':
        return 'Сборы';
      case 'zh':
        return '行李';
      case 'ja':
        return '荷物';
      case 'ko':
        return '짐 싸기';
      case 'hi':
        return 'पैकिंग';
      case 'ar':
        return 'الحقائب';
      case 'nl':
        return 'Inpakken';
      case 'el':
        return 'Πακετάρισμα';
      case 'sv':
        return 'Packning';
      case 'pl':
        return 'Pakowanie';
      case 'id':
        return 'Packing';
      case 'th':
        return 'จัดกระเป๋า';
      case 'vi':
        return 'Đóng gói';
      default:
        return 'Packing';
    }
  }

  /// Spent budget label
  static String getSpentLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Harcanan';
      case 'es':
        return 'Gastado';
      case 'fr':
        return 'Dépensé';
      case 'de':
        return 'Ausgegeben';
      case 'it':
        return 'Speso';
      case 'pt':
        return 'Gasto';
      case 'ru':
        return 'Потрачено';
      case 'zh':
        return '已支出';
      case 'ja':
        return '支出済';
      case 'ko':
        return '지출';
      case 'hi':
        return 'खर्च';
      case 'ar':
        return 'تم إنفاقه';
      case 'nl':
        return 'Uitgegeven';
      case 'el':
        return 'Δαπανήθηκαν';
      case 'sv':
        return 'Spenderat';
      case 'pl':
        return 'Wydano';
      case 'id':
        return 'Dibelanjakan';
      case 'th':
        return 'ใช้ไปแล้ว';
      case 'vi':
        return 'Đã chi';
      default:
        return 'Spent';
    }
  }

  /// Budget summary title
  static String getBudgetLabel(String lang) {
    switch (lang) {
      case 'tr':
        return 'Bütçe';
      case 'es':
        return 'Presupuesto';
      case 'fr':
        return 'Budget';
      case 'de':
        return 'Budget';
      case 'it':
        return 'Budget';
      case 'pt':
        return 'Orçamento';
      case 'ru':
        return 'Бюджет';
      case 'zh':
        return '预算';
      case 'ja':
        return '予算';
      case 'ko':
        return '예산';
      case 'hi':
        return 'बजट';
      case 'ar':
        return 'الميزانية';
      case 'nl':
        return 'Budget';
      case 'el':
        return 'Προϋπολογισμός';
      case 'sv':
        return 'Budget';
      case 'pl':
        return 'Budżet';
      case 'id':
        return 'Anggaran';
      case 'th':
        return 'งบประมาณ';
      case 'vi':
        return 'Ngân sách';
      default:
        return 'Budget';
    }
  }

  /// Countdown active message
  static String getCountdownActive(String lang) {
    switch (lang) {
      case 'tr':
        return 'Geri sayım başladı';
      case 'es':
        return 'Cuenta regresiva activa';
      case 'fr':
        return 'Compte à rebours actif';
      case 'de':
        return 'Countdown aktiv';
      case 'it':
        return 'Conto alla rovescia attivo';
      case 'pt':
        return 'Contagem regressiva ativa';
      case 'ru':
        return 'Обратный отсчет активен';
      case 'zh':
        return '倒计时进行中';
      case 'ja':
        return 'カウントダウン中';
      case 'ko':
        return '카운트다운 시작';
      case 'hi':
        return 'उलटी गिनती जारी है';
      case 'ar':
        return 'بدأ العد التنازلي';
      case 'nl':
        return 'Aftellen gestart';
      case 'el':
        return 'Αντίστροφη μέτρηση ενεργή';
      case 'sv':
        return 'Nedräkning pågår';
      case 'pl':
        return 'Odliczanie aktywne';
      case 'id':
        return 'Hitung mundur aktif';
      case 'th':
        return 'เริ่มนับถอยหลังแล้ว';
      case 'vi':
        return 'Đang đếm ngược';
      default:
        return 'Countdown active';
    }
  }

  /// Resolves the section title for widget theme selection
  static String getThemeSectionTitle(String lang) {
    switch (lang) {
      case 'tr':
        return 'Widget Teması & Renkleri';
      case 'es':
        return 'Tema y Colores del Widget';
      case 'fr':
        return 'Thème et Couleurs du Widget';
      case 'de':
        return 'Widget-Design & Farben';
      case 'it':
        return 'Tema e Colori del Widget';
      case 'pt':
        return 'Tema e Cores do Widget';
      case 'ru':
        return 'Тема и цвета виджета';
      case 'zh':
        return '小部件主题与配色';
      case 'ja':
        return 'ウィジェットのテーマと色';
      case 'ko':
        return '위젯 테마 및 색상';
      case 'hi':
        return 'विजेट थीम और रंग';
      case 'ar':
        return 'سمة وألوان القطعة';
      case 'nl':
        return 'Widget Thema & Kleuren';
      case 'el':
        return 'Θέμα και Χρώματα Widget';
      case 'sv':
        return 'Widget-tema & Färger';
      case 'pl':
        return 'Motyw i Kolory Widżetu';
      case 'id':
        return 'Tema & Warna Widget';
      case 'th':
        return 'ธีมและสีวิดเจ็ต';
      case 'vi':
        return 'Chủ đề & Màu sắc Tiện ích';
      default:
        return 'Widget Theme & Colors';
    }
  }

  /// Resolves the Dark Themes category header/tab label
  static String getDarkThemesCategory(String lang) {
    switch (lang) {
      case 'tr':
        return 'Karanlık';
      case 'es':
        return 'Oscuro';
      case 'fr':
        return 'Sombre';
      case 'de':
        return 'Dunkel';
      case 'it':
        return 'Scuro';
      case 'pt':
        return 'Escuro';
      case 'ru':
        return 'Тёмные';
      case 'zh':
        return '深色';
      case 'ja':
        return 'ダーク';
      case 'ko':
        return '다크';
      case 'hi':
        return 'डार्क';
      case 'ar':
        return 'داكن';
      case 'nl':
        return 'Donker';
      case 'el':
        return 'Σκούρα';
      case 'sv':
        return 'Mörk';
      case 'pl':
        return 'Ciemne';
      case 'id':
        return 'Gelap';
      case 'th':
        return 'มืด';
      case 'vi':
        return 'Tối';
      default:
        return 'Dark';
    }
  }

  /// Resolves the Light Themes category header/tab label
  static String getLightThemesCategory(String lang) {
    switch (lang) {
      case 'tr':
        return 'Aydınlık';
      case 'es':
        return 'Claro';
      case 'fr':
        return 'Clair';
      case 'de':
        return 'Hell';
      case 'it':
        return 'Chiaro';
      case 'pt':
        return 'Claro';
      case 'ru':
        return 'Светлые';
      case 'zh':
        return '浅色';
      case 'ja':
        return 'ライト';
      case 'ko':
        return '라이트';
      case 'hi':
        return 'लाइट';
      case 'ar':
        return 'فاتح';
      case 'nl':
        return 'Licht';
      case 'el':
        return 'Φωτεινά';
      case 'sv':
        return 'Ljus';
      case 'pl':
        return 'Jasne';
      case 'id':
        return 'Terang';
      case 'th':
        return 'สว่าง';
      case 'vi':
        return 'Sáng';
      default:
        return 'Light';
    }
  }

  /// Resolves the localized display name of a widget theme
  static String getThemeName(String lang, String themeKey) {
    switch (themeKey) {
      case 'ocean':
        switch (lang) {
          case 'tr':
            return 'Derin Okyanus';
          case 'es':
            return 'Océano Profundo';
          case 'fr':
            return 'Océan Profond';
          case 'de':
            return 'Tiefsee Blau';
          case 'it':
            return 'Oceano Profondo';
          case 'pt':
            return 'Oceano Profundo';
          case 'ru':
            return 'Глубокий океان';
          case 'zh':
            return '深海大洋';
          case 'ja':
            return 'ディープオーシャン';
          case 'ko':
            return '딥 오션';
          case 'hi':
            return 'गहरा सागर';
          case 'ar':
            return 'محيط عميق';
          case 'nl':
            return 'Diepe Oceaan';
          case 'el':
            return 'Βαθύς Ωκεανός';
          case 'sv':
            return 'Djupt Hav';
          case 'pl':
            return 'Głębia Oceanu';
          case 'id':
            return 'Samudra Dalam';
          case 'th':
            return 'ดีปโอเชียน';
          case 'vi':
            return 'Đại Dương Sâu';
          default:
            return 'Deep Ocean';
        }
      case 'light':
        switch (lang) {
          case 'tr':
            return 'Açık Minimal';
          case 'es':
            return 'Claro Minimal';
          case 'fr':
            return 'Clair Épuré';
          case 'de':
            return 'Helles Design';
          case 'it':
            return 'Chiaro Minimale';
          case 'pt':
            return 'Claro Minimalista';
          case 'ru':
            return 'Светлый';
          case 'zh':
            return '纯白极简';
          case 'ja':
            return 'クリーンライト';
          case 'ko':
            return '클린 화이트';
          case 'hi':
            return 'साफ हल्का';
          case 'ar':
            return 'فاتح نقي';
          case 'nl':
            return 'Licht & Helder';
          case 'el':
            return 'Φωτεινό Μίνιμαλ';
          case 'sv':
            return 'Ljus & Ren';
          case 'pl':
            return 'Jasny Minimal';
          case 'id':
            return 'Terang Minimalis';
          case 'th':
            return 'สว่างมินิมอล';
          case 'vi':
            return 'Sáng Tối Giản';
          default:
            return 'Clean Light';
        }
      case 'emerald':
        switch (lang) {
          case 'tr':
            return 'Aurora';
          case 'es':
            return 'Aurora';
          case 'fr':
            return 'Aurore';
          case 'de':
            return 'Nordlicht';
          case 'it':
            return 'Aurora';
          case 'pt':
            return 'Aurora';
          case 'ru':
            return 'Северное сияние';
          case 'zh':
            return '极光翡翠';
          case 'ja':
            return 'オーロラ';
          case 'ko':
            return '오로라';
          case 'hi':
            return 'अरोरा';
          case 'ar':
            return 'الشفق القطبي';
          case 'nl':
            return 'Noorderlicht';
          case 'el':
            return 'Σέλας';
          case 'sv':
            return 'Norrsken';
          case 'pl':
            return 'Zorza Polarna';
          case 'id':
            return 'Aurora';
          case 'th':
            return 'ออโรรา';
          case 'vi':
            return 'Cực Quang';
          default:
            return 'Aurora';
        }
      case 'sunset':
        switch (lang) {
          case 'tr':
            return 'Sıcak Günbatımı';
          case 'es':
            return 'Ámbar Atardecer';
          case 'fr':
            return 'Ambre Couchant';
          case 'de':
            return 'Sonnenuntergang';
          case 'it':
            return 'Ambra Tramonto';
          case 'pt':
            return 'Âmbar Pôr do Sol';
          case 'ru':
            return 'Закатный янтарь';
          case 'zh':
            return '日落琥珀';
          case 'ja':
            return 'サンセットアンバー';
          case 'ko':
            return '선셋 앰버';
          case 'hi':
            return 'सूर्यास्त एम्बर';
          case 'ar':
            return 'كهرمان الغروب';
          case 'nl':
            return 'Zonsondergang';
          case 'el':
            return 'Ηλιοβασίλεμα';
          case 'sv':
            return 'Solnedgång';
          case 'pl':
            return 'Bursztynowy Zachód';
          case 'id':
            return 'Kuning Senja';
          case 'th':
            return 'ซันเซ็ตแอมเบอร์';
          case 'vi':
            return 'Hoàng Hôn';
          default:
            return 'Sunset Amber';
        }
      case 'cyberpunk':
        switch (lang) {
          case 'tr':
            return 'Siber';
          case 'es':
            return 'Ciberpunk';
          case 'fr':
            return 'Cyberpunk';
          case 'de':
            return 'Cyberpunk';
          case 'it':
            return 'Cyberpunk';
          case 'pt':
            return 'Cyberpunk';
          case 'ru':
            return 'Киберпанк';
          case 'zh':
            return '赛博朋克';
          case 'ja':
            return 'サイバーパンク';
          case 'ko':
            return '사이버펑크';
          case 'hi':
            return 'साइबरपंक';
          case 'ar':
            return 'سايبربانك';
          case 'nl':
            return 'Cyberpunk';
          case 'el':
            return 'Cyberpunk';
          case 'sv':
            return 'Cyberpunk';
          case 'pl':
            return 'Cyberpunk';
          case 'id':
            return 'Cyberpunk';
          case 'th':
            return 'ไซเบอร์พังก์';
          case 'vi':
            return 'Cyberpunk';
          default:
            return 'Cyberpunk';
        }
      case 'volcano':
        switch (lang) {
          case 'tr':
            return 'Lav';
          case 'es':
            return 'Volcán';
          case 'fr':
            return 'Volcan';
          case 'de':
            return 'Vulkan';
          case 'it':
            return 'Vulcano';
          case 'pt':
            return 'Vulcão';
          case 'ru':
            return 'Вулкан';
          case 'zh':
            return '熔岩火山';
          case 'ja':
            return 'ボルケーノ';
          case 'ko':
            return '화산';
          case 'hi':
            return 'ज्वालामुखी';
          case 'ar':
            return 'بركان';
          case 'nl':
            return 'Vulkaan';
          case 'el':
            return 'Ηφαίστειο';
          case 'sv':
            return 'Vulkan';
          case 'pl':
            return 'Wulkan';
          case 'id':
            return 'Gunung Berapi';
          case 'th':
            return 'ภูเขาไฟ';
          case 'vi':
            return 'Núi Lửa';
          default:
            return 'Volcano';
        }
      case 'nordicForest':
        switch (lang) {
          case 'tr':
            return 'Fiyort';
          case 'es':
            return 'Fiordo';
          case 'fr':
            return 'Fjord';
          case 'de':
            return 'Fjord';
          case 'it':
            return 'Fiordo';
          case 'pt':
            return 'Fiorde';
          case 'ru':
            return 'Фьорд';
          case 'zh':
            return '北欧峡湾';
          case 'ja':
            return 'フィヨルド';
          case 'ko':
            return '피오르';
          case 'hi':
            return 'फियोर्ड';
          case 'ar':
            return 'مضيق بحري';
          case 'nl':
            return 'Fjord';
          case 'el':
            return 'Φιόρδ';
          case 'sv':
            return 'Fjord';
          case 'pl':
            return 'Fiord';
          case 'id':
            return 'Fjord';
          case 'th':
            return 'ฟยอร์ด';
          case 'vi':
            return 'Vịnh Hẹp';
          default:
            return 'Fjord';
        }
      case 'goldenHour':
        switch (lang) {
          case 'tr':
            return 'Altın Çağ';
          case 'es':
            return 'Hora Dorada';
          case 'fr':
            return 'Heure Dorée';
          case 'de':
            return 'Goldene Stunde';
          case 'it':
            return 'Ora d\'Oro';
          case 'pt':
            return 'Hora de Ouro';
          case 'ru':
            return 'Золотой час';
          case 'zh':
            return '黄金时刻';
          case 'ja':
            return 'ゴールデンアワー';
          case 'ko':
            return '골든 아워';
          case 'hi':
            return 'स्वर्ण प्रहर';
          case 'ar':
            return 'الساعة الذهبية';
          case 'nl':
            return 'Gouden Uur';
          case 'el':
            return 'Χρυσή Ώρα';
          case 'sv':
            return 'Gyllene Timmen';
          case 'pl':
            return 'Złota Godzina';
          case 'id':
            return 'Golden Hour';
          case 'th':
            return 'โกลเดนอาวเวอร์';
          case 'vi':
            return 'Giờ Vàng';
          default:
            return 'Golden Hour';
        }
      case 'galaxy':
        switch (lang) {
          case 'tr':
            return 'Galaksi';
          case 'es':
            return 'Galaxia';
          case 'fr':
            return 'Galaxie';
          case 'de':
            return 'Galaxie';
          case 'it':
            return 'Galassia';
          case 'pt':
            return 'Galáxia';
          case 'ru':
            return 'Галактика';
          case 'zh':
            return '璀璨星系';
          case 'ja':
            return 'ギャラクシー';
          case 'ko':
            return '은하수';
          case 'hi':
            return 'आकाशगंगा';
          case 'ar':
            return 'مجرة';
          case 'nl':
            return 'Melkweg';
          case 'el':
            return 'Γαλαξίας';
          case 'sv':
            return 'Galax';
          case 'pl':
            return 'Galaktyka';
          case 'id':
            return 'Galaksi';
          case 'th':
            return 'กาแล็กซี';
          case 'vi':
            return 'Thiên Hà';
          default:
            return 'Galaxy';
        }
      case 'monochromeDark':
        switch (lang) {
          case 'tr':
            return 'Karbon';
          case 'es':
            return 'Carbón';
          case 'fr':
            return 'Carbone';
          case 'de':
            return 'Karbon';
          case 'it':
            return 'Carbonio';
          case 'pt':
            return 'Carbono';
          case 'ru':
            return 'Карбон';
          case 'zh':
            return '曜石碳黑';
          case 'ja':
            return 'カーボン';
          case 'ko':
            return '카본 블랙';
          case 'hi':
            return 'कार्बन';
          case 'ar':
            return 'كربون';
          case 'nl':
            return 'Koolstof';
          case 'el':
            return 'Άνθρακας';
          case 'sv':
            return 'Kolfiber';
          case 'pl':
            return 'Węgiel';
          case 'id':
            return 'Karbon';
          case 'th':
            return 'คาร์บอน';
          case 'vi':
            return 'Carbon';
          default:
            return 'Carbon';
        }
      case 'minimalLight':
        switch (lang) {
          case 'tr':
            return 'İskandinav';
          case 'es':
            return 'Nórdico';
          case 'fr':
            return 'Nordique';
          case 'de':
            return 'Nordisch';
          case 'it':
            return 'Nordico';
          case 'pt':
            return 'Nórdico';
          case 'ru':
            return 'Скандинавский';
          case 'zh':
            return '极简北欧';
          case 'ja':
            return 'ノルディック';
          case 'ko':
            return '노르딕';
          case 'hi':
            return 'नॉर्डिक';
          case 'ar':
            return 'نوردي';
          case 'nl':
            return 'Scandinavisch';
          case 'el':
            return 'Σκανδιναβικό';
          case 'sv':
            return 'Nordisk';
          case 'pl':
            return 'Nordycki';
          case 'id':
            return 'Nordik';
          case 'th':
            return 'นอร์ดิก';
          case 'vi':
            return 'Bắc Âu';
          default:
            return 'Nordic';
        }
      case 'sandLight':
        switch (lang) {
          case 'tr':
            return 'Sahra';
          case 'es':
            return 'Sáhara';
          case 'fr':
            return 'Sahara';
          case 'de':
            return 'Sahara';
          case 'it':
            return 'Sahara';
          case 'pt':
            return 'Saara';
          case 'ru':
            return 'Сахара';
          case 'zh':
            return '撒哈拉暖沙';
          case 'ja':
            return 'サハラ';
          case 'ko':
            return '사하라';
          case 'hi':
            return 'सहारा';
          case 'ar':
            return 'الصحراء';
          case 'nl':
            return 'Sahara';
          case 'el':
            return 'Σαχάρα';
          case 'sv':
            return 'Sahara';
          case 'pl':
            return 'Sahara';
          case 'id':
            return 'Sahara';
          case 'th':
            return 'ซาฮารา';
          case 'vi':
            return 'Sahara';
          default:
            return 'Sahara';
        }
      case 'oceanLight':
        switch (lang) {
          case 'tr':
            return 'Akdeniz';
          case 'es':
            return 'Mediterráneo';
          case 'fr':
            return 'Méditerranée';
          case 'de':
            return 'Mittelmeer';
          case 'it':
            return 'Mediterraneo';
          case 'pt':
            return 'Mediterrâneo';
          case 'ru':
            return 'Средиземноморье';
          case 'zh':
            return '地中海晴蓝';
          case 'ja':
            return '地中海';
          case 'ko':
            return '지중해';
          case 'hi':
            return 'भूमध्यसागरीय';
          case 'ar':
            return 'البحر المتوسط';
          case 'nl':
            return 'Middellandse Zee';
          case 'el':
            return 'Μεσόγειος';
          case 'sv':
            return 'Medelhavet';
          case 'pl':
            return 'Śródziemnomorski';
          case 'id':
            return 'Mediterania';
          case 'th':
            return 'เมดิเตอร์เรเนียน';
          case 'vi':
            return 'Địa Trung Hải';
          default:
            return 'Mediterranean';
        }
      case 'cherryBlossom':
        switch (lang) {
          case 'tr':
            return 'Sakura';
          case 'es':
            return 'Sakura';
          case 'fr':
            return 'Sakura';
          case 'de':
            return 'Sakura';
          case 'it':
            return 'Sakura';
          case 'pt':
            return 'Sakura';
          case 'ru':
            return 'Сакура';
          case 'zh':
            return '春樱盛开';
          case 'ja':
            return '桜 (さくら)';
          case 'ko':
            return '사쿠라';
          case 'hi':
            return 'साकुरा';
          case 'ar':
            return 'ساكورا';
          case 'nl':
            return 'Kersenbloesem';
          case 'el':
            return 'Άνθη Κερασιάς';
          case 'sv':
            return 'Körsbärsblom';
          case 'pl':
            return 'Kwiat Wiśni';
          case 'id':
            return 'Bunga Sakura';
          case 'th':
            return 'ซากุระ';
          case 'vi':
            return 'Hoa Anh Đào';
          default:
            return 'Sakura';
        }
      case 'vintageSepia':
        switch (lang) {
          case 'tr':
            return 'Parşömen';
          case 'es':
            return 'Pergamino';
          case 'fr':
            return 'Parchemin';
          case 'de':
            return 'Pergament';
          case 'it':
            return 'Pergamena';
          case 'pt':
            return 'Pergaminho';
          case 'ru':
            return 'Пергамент';
          case 'zh':
            return '复古羊皮纸';
          case 'ja':
            return '羊皮紙';
          case 'ko':
            return '양피지';
          case 'hi':
            return 'चर्मपत्र';
          case 'ar':
            return 'رق';
          case 'nl':
            return 'Perkament';
          case 'el':
            return 'Περγαμηνή';
          case 'sv':
            return 'Pergament';
          case 'pl':
            return 'Pergamin';
          case 'id':
            return 'Perkamen';
          case 'th':
            return 'กระดาษโบราณ';
          case 'vi':
            return 'Giấy Da Cổ';
          default:
            return 'Parchment';
        }
      case 'matcha':
        switch (lang) {
          case 'tr':
            return 'Matcha';
          case 'es':
            return 'Matcha';
          case 'fr':
            return 'Matcha';
          case 'de':
            return 'Matcha';
          case 'it':
            return 'Matcha';
          case 'pt':
            return 'Matcha';
          case 'ru':
            return 'Матча';
          case 'zh':
            return '静谧抹茶';
          case 'ja':
            return '抹茶 (まっちゃ)';
          case 'ko':
            return '말차';
          case 'hi':
            return 'माचा';
          case 'ar':
            return 'ماتشا';
          case 'nl':
            return 'Matcha';
          case 'el':
            return 'Μάτσα';
          case 'sv':
            return 'Matcha';
          case 'pl':
            return 'Matcha';
          case 'id':
            return 'Matcha';
          case 'th':
            return 'มัทฉะ';
          case 'vi':
            return 'Trà Xanh Matcha';
          default:
            return 'Matcha';
        }
      case 'pastelDream':
        switch (lang) {
          case 'tr':
            return 'Pastel Rüya';
          case 'es':
            return 'Sueño Pastel';
          case 'fr':
            return 'Rêve Pastel';
          case 'de':
            return 'Pastelltraum';
          case 'it':
            return 'Sogno Pastello';
          case 'pt':
            return 'Sonho Pastel';
          case 'ru':
            return 'Пастельная мечта';
          case 'zh':
            return '梦幻粉彩';
          case 'ja':
            return 'パステルドリーム';
          case 'ko':
            return '파스텔 드림';
          case 'hi':
            return 'पेस्टल ड्रीम';
          case 'ar':
            return 'حلم باستيل';
          case 'nl':
            return 'Pasteldroom';
          case 'el':
            return 'Παστέλ Όνειρο';
          case 'sv':
            return 'Pastelldröm';
          case 'pl':
            return 'Pastelowy Sen';
          case 'id':
            return 'Mimpi Pastel';
          case 'th':
            return 'พาสเทลดรีม';
          case 'vi':
            return 'Giấc Mơ Pastel';
          default:
            return 'Pastel Dream';
        }
      case 'midnight':
      default:
        switch (lang) {
          case 'tr':
            return 'Gece Mavisi';
          case 'es':
            return 'Azul Medianoche';
          case 'fr':
            return 'Bleu Minuit';
          case 'de':
            return 'Mitternachtsblau';
          case 'it':
            return 'Blu Notte';
          case 'pt':
            return 'Azul Meia-Noite';
          case 'ru':
            return 'Полуночный';
          case 'zh':
            return '午夜深蓝';
          case 'ja':
            return 'ミッドナイト';
          case 'ko':
            return '미드나잇 네이비';
          case 'hi':
            return 'मिडनाइट नेवी';
          case 'ar':
            return 'كحلي ليلي';
          case 'nl':
            return 'Middernachtblauw';
          case 'el':
            return 'Μπλε Μεσάνυχτα';
          case 'sv':
            return 'Midnattsblå';
          case 'pl':
            return 'Granat Północy';
          case 'id':
            return 'Biru Malam';
          case 'th':
            return 'มิดไนท์เนวี';
          case 'vi':
            return 'Xanh Nửa Đêm';
          default:
            return 'Midnight Navy';
        }
    }
  }

  /// Resolves "Harcanan Bütçe" (Spent Budget) label across 20 languages
  static String getSpentBudgetLabel(String lang) {
    switch (lang) {
      case 'tr': return 'Harcanan Bütçe';
      case 'es': return 'Presupuesto gastado';
      case 'fr': return 'Budget dépensé';
      case 'de': return 'Ausgegebenes Budget';
      case 'it': return 'Budget speso';
      case 'pt': return 'Orçamento gasto';
      case 'ru': return 'Потраченный бюджет';
      case 'zh': return '已用预算';
      case 'ja': return '使用済み予算';
      case 'ko': return '사용된 예산';
      case 'hi': return 'खर्च किया गया बजट';
      case 'ar': return 'الميزانية المستهلكة';
      case 'nl': return 'Besteed budget';
      case 'el': return 'Δαπανημένος προϋπολογισμός';
      case 'sv': return 'Förbrukad budget';
      case 'pl': return 'Wydany budżet';
      case 'id': return 'Anggaran Terpakai';
      case 'th': return 'งบประมาณที่ใช้ไป';
      case 'vi': return 'Ngân sách đã tiêu';
      default: return 'Spent Budget';
    }
  }

  /// Resolves "Kalan Bütçe" (Remaining Budget) label across 20 languages
  static String getRemainingBudgetTitle(String lang) {
    switch (lang) {
      case 'tr': return 'Kalan Bütçe';
      case 'es': return 'Presupuesto restante';
      case 'fr': return 'Budget restant';
      case 'de': return 'Verbleibendes Budget';
      case 'it': return 'Budget rimanente';
      case 'pt': return 'Orçamento restante';
      case 'ru': return 'Оставшийся бюджет';
      case 'zh': return '剩余预算';
      case 'ja': return '残りの予算';
      case 'ko': return '남은 예산';
      case 'hi': return 'शेष बजट';
      case 'ar': return 'الميزانية المتبقية';
      case 'nl': return 'Resterend budget';
      case 'el': return 'Υπόλοιπο προϋπολογισμού';
      case 'sv': return 'Kvarvarande budget';
      case 'pl': return 'Pozostały budżet';
      case 'id': return 'Sisa Anggaran';
      case 'th': return 'งบประมาณที่เหลือ';
      case 'vi': return 'Ngân sách còn lại';
      default: return 'Remaining Budget';
    }
  }

  /// Resolves "Son Harcama" (Last Expense) label across 20 languages
  static String getLastExpenseLabel(String lang) {
    switch (lang) {
      case 'tr': return 'Son Harcama';
      case 'es': return 'Último gasto';
      case 'fr': return 'Dernière dépense';
      case 'de': return 'Letzte Ausgabe';
      case 'it': return 'Ultima spesa';
      case 'pt': return 'Último gasto';
      case 'ru': return 'Последний расход';
      case 'zh': return '最新支出';
      case 'ja': return '最近の支出';
      case 'ko': return '최근 지출';
      case 'hi': return 'अंतिम खर्च';
      case 'ar': return 'آخر نفقة';
      case 'nl': return 'Laatste uitgave';
      case 'el': return 'Τελευταίο έξοδο';
      case 'sv': return 'Senaste utgift';
      case 'pl': return 'Ostatni wydatek';
      case 'id': return 'Pengeluaran Terakhir';
      case 'th': return 'ค่าใช้จ่ายล่าสุด';
      case 'vi': return 'Chi tiêu gần nhất';
      default: return 'Last Expense';
    }
  }

  /// Resolves "Henüz harcama kaydedilmedi" (No expenses logged) label across 20 languages
  static String getNoExpensesLoggedLabel(String lang) {
    switch (lang) {
      case 'tr': return 'Henüz harcama kaydedilmedi';
      case 'es': return 'Sin gastos registrados aún';
      case 'fr': return 'Aucune dépense enregistrée';
      case 'de': return 'Noch keine Ausgaben erfasst';
      case 'it': return 'Nessuna spesa registrata';
      case 'pt': return 'Nenhum gasto registrado ainda';
      case 'ru': return 'Расходы пока не записаны';
      case 'zh': return '暂无支出记录';
      case 'ja': return '支出はまだ記録されていません';
      case 'ko': return '아직 기록된 지출이 없습니다';
      case 'hi': return 'अभी तक कोई खर्च दर्ज नहीं हुआ';
      case 'ar': return 'لم يتم تسجيل أي نفقات بعد';
      case 'nl': return 'Nog geen uitgaven geregistreerd';
      case 'el': return 'Δεν έχουν καταγραφεί έξοδα ακόμα';
      case 'sv': return 'Inga utgifter registrerade än';
      case 'pl': return 'Brak zarejestrowanych wydatków';
      case 'id': return 'Belum ada pengeluaran dicatat';
      case 'th': return 'ยังไม่มีการบันทึกค่าใช้จ่าย';
      case 'vi': return 'Chưa có chi tiêu nào được ghi lại';
      default: return 'No expenses recorded yet';
    }
  }

  /// Resolves "+ Harcama Ekle" (Add Expense) label across 20 languages
  static String getAddExpenseActionLabel(String lang) {
    switch (lang) {
      case 'tr': return '+ Harcama Ekle';
      case 'es': return '+ Añadir gasto';
      case 'fr': return '+ Ajouter dépense';
      case 'de': return '+ Ausgabe erfassen';
      case 'it': return '+ Aggiungi spesa';
      case 'pt': return '+ Adicionar gasto';
      case 'ru': return '+ Добавить расход';
      case 'zh': return '+ 添加支出';
      case 'ja': return '+ 支出を追加';
      case 'ko': return '+ 지출 추가';
      case 'hi': return '+ खर्च जोड़ें';
      case 'ar': return '+ إضافة نفقة';
      case 'nl': return '+ Uitgave toevoegen';
      case 'el': return '+ Προσθήκη εξόδου';
      case 'sv': return '+ Lägg till utgift';
      case 'pl': return '+ Dodaj wydatek';
      case 'id': return '+ Tambah Pengeluaran';
      case 'th': return '+ เพิ่มค่าใช้จ่าย';
      case 'vi': return '+ Thêm chi tiêu';
      default: return '+ Add Expense';
    }
  }

  /// Resolves "Hızlı Kayıt" (Quick Log) badge label across 20 languages
  static String getQuickLogBadge(String lang) {
    switch (lang) {
      case 'tr': return 'Hızlı Kayıt';
      case 'es': return 'Registro rápido';
      case 'fr': return 'Saisie rapide';
      case 'de': return 'Schnellerfassung';
      case 'it': return 'Registrazione rapida';
      case 'pt': return 'Registro rápido';
      case 'ru': return 'Быстрая запись';
      case 'zh': return '快速记录';
      case 'ja': return 'クイック記録';
      case 'ko': return '빠른 기록';
      case 'hi': return 'त्वरित प्रविष्टि';
      case 'ar': return 'تسجيل سريع';
      case 'nl': return 'Snelle invoer';
      case 'el': return 'Γρήγορη καταγραφή';
      case 'sv': return 'Snabbregistrering';
      case 'pl': return 'Szybki wpis';
      case 'id': return 'Catat Cepat';
      case 'th': return 'บันทึกด่วน';
      case 'vi': return 'Ghi nhanh';
      default: return 'Quick Log';
    }
  }

  /// Resolves "Hızlı Çevrimler" (Quick Conversions) label across 20 languages
  static String getQuickConversionsLabel(String lang) {
    switch (lang) {
      case 'tr': return 'Hızlı Çevrimler';
      case 'es': return 'Conversiones rápidas';
      case 'fr': return 'Conversions rapides';
      case 'de': return 'Schnellumrechnungen';
      case 'it': return 'Conversioni rapide';
      case 'pt': return 'Conversões rápidas';
      case 'ru': return 'Быстрая конвертация';
      case 'zh': return '快捷换算';
      case 'ja': return 'クイック換算';
      case 'ko': return '빠른 환산';
      case 'hi': return 'त्वरित रूपांतरण';
      case 'ar': return 'تحويلات سريعة';
      case 'nl': return 'Snelle omrekening';
      case 'el': return 'Γρήγορες μετατροπές';
      case 'sv': return 'Snabbkonvertering';
      case 'pl': return 'Szybkie przeliczniki';
      case 'id': return 'Konversi Cepat';
      case 'th': return 'แปลงด่วน';
      case 'vi': return 'Chuyển đổi nhanh';
      default: return 'Quick Conversions';
    }
  }

  /// Resolves "● Canlı Kurlar" (Live Rates) label across 20 languages
  static String getLiveRatesLabel(String lang) {
    switch (lang) {
      case 'tr': return '● Canlı Kurlar';
      case 'es': return '● Tasas en vivo';
      case 'fr': return '● Taux en direct';
      case 'de': return '● Live-Kurse';
      case 'it': return '● Tassi in tempo reale';
      case 'pt': return '● Taxas ao vivo';
      case 'ru': return '● Текущие курсы';
      case 'zh': return '● 实时汇率';
      case 'ja': return '● リアルタイム為替レート';
      case 'ko': return '● 실시간 환율';
      case 'hi': return '● लाइव दरें';
      case 'ar': return '● أسعار مباشرة';
      case 'nl': return '● Live koersen';
      case 'el': return '● Ζωντανές ισοτιμίες';
      case 'sv': return '● Livekurser';
      case 'pl': return '● Kursy na żywo';
      case 'id': return '● Kurs Langsung';
      case 'th': return '● อัตราแลกเปลี่ยนสด';
      case 'vi': return '● Tỷ giá trực tiếp';
      default: return '● Live Rates';
    }
  }

  /// Resolves "✓ Otomatik Çift Yönlü Senkron" label across 20 languages
  static String getAutoSyncLabel(String lang) {
    switch (lang) {
      case 'tr': return '✓ Otomatik Çift Yönlü Senkron';
      case 'es': return '✓ Sincronización bidireccional auto';
      case 'fr': return '✓ Synchro bidirectionnelle auto';
      case 'de': return '✓ Auto bidirektionale Synchronisation';
      case 'it': return '✓ Sincronizzazione bidirezionale auto';
      case 'pt': return '✓ Sincronização bidirecional auto';
      case 'ru': return '✓ Двусторонняя автосинхронизация';
      case 'zh': return '✓ 自动双向同步';
      case 'ja': return '✓ 自動双方向同期';
      case 'ko': return '✓ 자동 양방향 동기화';
      case 'hi': return '✓ स्वतः द्विदिशीय समन्वय';
      case 'ar': return '✓ مزامنة ثنائية الاتجاه تلقائية';
      case 'nl': return '✓ Auto bidirectionele synchronisatie';
      case 'el': return '✓ Αυτόματος αμφίδρομος συγχρονισμός';
      case 'sv': return '✓ Automatisk tvåvägssynk';
      case 'pl': return '✓ Automatyczna synchronizacja dwukierunkowa';
      case 'id': return '✓ Sinkronisasi Dua Arah Otomatis';
      case 'th': return '✓ ซิงค์แบบสองทิศทางอัตโนมัติ';
      case 'vi': return '✓ Tự động đồng bộ hai chiều';
      default: return '✓ Auto Bidirectional Sync';
    }
  }

  /// Resolves "Çevrim Çevrimdışı Hazır" label across 20 languages
  static String getOfflineReadyLabel(String lang) {
    switch (lang) {
      case 'tr': return 'Çevrim Çevrimdışı Hazır';
      case 'es': return 'Listo sin conexión';
      case 'fr': return 'Prêt hors ligne';
      case 'de': return 'Offline bereit';
      case 'it': return 'Pronto offline';
      case 'pt': return 'Pronto offline';
      case 'ru': return 'Готово офлайн';
      case 'zh': return '支持离线换算';
      case 'ja': return 'オフライン対応';
      case 'ko': return '오프라인 사용 가능';
      case 'hi': return 'ऑफ़लाइन तैयार';
      case 'ar': return 'جاهز بدون إنترنت';
      case 'nl': return 'Offline gereed';
      case 'el': return 'Έτοιμο εκτός σύνδεσης';
      case 'sv': return 'Redo offline';
      case 'pl': return 'Gotowe offline';
      case 'id': return 'Siap Offline';
      case 'th': return 'พร้อมใช้งานออฟไลน์';
      case 'vi': return 'Sẵn sàng ngoại tuyến';
      default: return 'Offline Ready';
    }
  }
}
