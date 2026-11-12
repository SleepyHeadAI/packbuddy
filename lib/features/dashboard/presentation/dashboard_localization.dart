/// Localization helper for Dashboard customization, reordering, and greeting extensions
/// Supports all 20 official PackBuddy languages.
class DashboardLocalization {
  DashboardLocalization._();

  static String timeIcon(int hour) {
    if (hour >= 5 && hour < 12) {
      return '☀️';
    } else if (hour >= 12 && hour < 18) {
      return '✈️';
    } else {
      return '🌙';
    }
  }

  static String timeGreetingClean(String lang, int hour) {
    if (hour >= 5 && hour < 12) {
      switch (lang) {
        case 'tr': return 'Günaydın';
        case 'es': return 'Buenos días';
        case 'fr': return 'Bonjour';
        case 'de': return 'Guten Morgen';
        case 'it': return 'Buongiorno';
        case 'pt': return 'Bom dia';
        case 'ru': return 'Доброе утро';
        case 'zh': return '早上好';
        case 'ja': return 'おはようございます';
        case 'ko': return '좋은 아침입니다';
        case 'hi': return 'शुभ प्रभात';
        case 'ar': return 'صباح الخير';
        case 'nl': return 'Goedemorgen';
        case 'el': return 'Καλημέρα';
        case 'sv': return 'God morgon';
        case 'pl': return 'Dzień dobry';
        case 'id': return 'Selamat pagi';
        case 'th': return 'สวัสดีตอนเช้า';
        case 'vi': return 'Chào buổi sáng';
        case 'en':
        default:
          return 'Good morning';
      }
    } else if (hour >= 12 && hour < 18) {
      switch (lang) {
        case 'tr': return 'İyi Günler';
        case 'es': return 'Buenas tardes';
        case 'fr': return 'Bon après-midi';
        case 'de': return 'Guten Tag';
        case 'it': return 'Buon pomeriggio';
        case 'pt': return 'Boa tarde';
        case 'ru': return 'Добрый день';
        case 'zh': return '下午好';
        case 'ja': return 'こんにちは';
        case 'ko': return '좋은 오후입니다';
        case 'hi': return 'शुभ दोपहर';
        case 'ar': return 'مساء الخير';
        case 'nl': return 'Goedemiddag';
        case 'el': return 'Καλό απόγευμα';
        case 'sv': return 'God eftermiddag';
        case 'pl': return 'Dobre popołudnie';
        case 'id': return 'Selamat siang';
        case 'th': return 'สวัสดีตอนบ่าย';
        case 'vi': return 'Chào buổi chiều';
        case 'en':
        default:
          return 'Good afternoon';
      }
    } else if (hour >= 18 && hour < 23) {
      switch (lang) {
        case 'tr': return 'İyi Akşamlar';
        case 'es': return 'Buenas tardes';
        case 'fr': return 'Bonsoir';
        case 'de': return 'Guten Abend';
        case 'it': return 'Buonasera';
        case 'pt': return 'Boa noite';
        case 'ru': return 'Добрый вечер';
        case 'zh': return '晚上好';
        case 'ja': return 'こんばんは';
        case 'ko': return '좋은 저녁입니다';
        case 'hi': return 'शुभ संध्या';
        case 'ar': return 'طاب مساؤك';
        case 'nl': return 'Goedenavond';
        case 'el': return 'Καλό βράδυ';
        case 'sv': return 'God kväll';
        case 'pl': return 'Dobry wieczór';
        case 'id': return 'Selamat malam';
        case 'th': return 'สวัสดีตอนเย็น';
        case 'vi': return 'Chào buổi tối';
        case 'en':
        default:
          return 'Good evening';
      }
    } else {
      switch (lang) {
        case 'tr': return 'İyi Geceler';
        case 'es': return 'Buenas noches';
        case 'fr': return 'Bonne nuit';
        case 'de': return 'Gute Nacht';
        case 'it': return 'Buonanotte';
        case 'pt': return 'Boa noite';
        case 'ru': return 'Спокойной ночи';
        case 'zh': return '晚安';
        case 'ja': return 'おやすみなさい';
        case 'ko': return '안녕히 주무세요';
        case 'hi': return 'शुभ रात्रि';
        case 'ar': return 'تصبح على خير';
        case 'nl': return 'Goedenacht';
        case 'el': return 'Καληνύχτα';
        case 'sv': return 'God natt';
        case 'pl': return 'Dobranoc';
        case 'id': return 'Selamat tidur';
        case 'th': return 'ราตรีสวัสดิ์';
        case 'vi': return 'Chúc ngủ ngon';
        case 'en':
        default:
          return 'Good night';
      }
    }
  }

  static String travelerTitle(String lang) {
    switch (lang) {
      case 'tr': return 'Gezgin';
      case 'es': return 'Viajero';
      case 'fr': return 'Voyageur';
      case 'de': return 'Reisender';
      case 'it': return 'Viaggiatore';
      case 'pt': return 'Viajante';
      case 'ru': return 'Путешественник';
      case 'zh': return '旅行者';
      case 'ja': return '旅行者';
      case 'ko': return '여행자';
      case 'hi': return 'यात्री';
      case 'ar': return 'مسافر';
      case 'nl': return 'Reiziger';
      case 'el': return 'Ταξιδιώτης';
      case 'sv': return 'Resenär';
      case 'pl': return 'Podróżnik';
      case 'id': return 'Penjelajah';
      case 'th': return 'นักเดินทาง';
      case 'vi': return 'Lữ khách';
      case 'en':
      default:
        return 'Traveler';
    }
  }

  static String syncStatusBanner(String lang, String statusKey) {
    switch (statusKey) {
      case 'syncing':
        switch (lang) {
          case 'tr': return 'Eşitleniyor...';
          case 'es': return 'Sincronizando...';
          case 'fr': return 'Synchronisation...';
          case 'de': return 'Synchronisiere...';
          case 'it': return 'Sincronizzazione...';
          case 'pt': return 'Sincronizando...';
          case 'ru': return 'Синхронизация...';
          case 'zh': return '同步中...';
          case 'ja': return '同期中...';
          case 'ko': return '동기화 중...';
          case 'hi': return 'सिंक हो रहा है...';
          case 'ar': return 'جارٍ المزامنة...';
          case 'nl': return 'Synchroniseren...';
          case 'el': return 'Συγχρονισμός...';
          case 'sv': return 'Synkroniserar...';
          case 'pl': return 'Synchronizacja...';
          case 'id': return 'Menyinkronkan...';
          case 'th': return 'กำลังซิงค์...';
          case 'vi': return 'Đang đồng bộ...';
          case 'en':
          default:
            return 'Syncing...';
        }
      case 'upToDate':
        switch (lang) {
          case 'tr': return 'Güncel';
          case 'es': return 'Actualizado';
          case 'fr': return 'À jour';
          case 'de': return 'Aktuell';
          case 'it': return 'Aggiornato';
          case 'pt': return 'Atualizado';
          case 'ru': return 'Синхронизировано';
          case 'zh': return '已更新';
          case 'ja': return '最新';
          case 'ko': return '최신';
          case 'hi': return 'अद्यतन';
          case 'ar': return 'محدث';
          case 'nl': return 'Bijgewerkt';
          case 'el': return 'Ενημερωμένο';
          case 'sv': return 'Uppdaterad';
          case 'pl': return 'Aktualne';
          case 'id': return 'Terbaru';
          case 'th': return 'อัปเดตแล้ว';
          case 'vi': return 'Đã cập nhật';
          case 'en':
          default:
            return 'Up to date';
        }
      case 'failed':
        switch (lang) {
          case 'tr': return 'Eşitleme Hatası';
          case 'es': return 'Error de sinc.';
          case 'fr': return 'Erreur sync';
          case 'de': return 'Sync-Fehler';
          case 'it': return 'Errore sync';
          case 'pt': return 'Erro de sinc.';
          case 'ru': return 'Ошибка';
          case 'zh': return '同步失败';
          case 'ja': return '同期エラー';
          case 'ko': return '동기화 오류';
          case 'hi': return 'सिंक त्रुटि';
          case 'ar': return 'خطأ مزامنة';
          case 'nl': return 'Sync-fout';
          case 'el': return 'Σφάλμα συγχρ.';
          case 'sv': return 'Synkfel';
          case 'pl': return 'Błąd synchr.';
          case 'id': return 'Gagal Sinkron';
          case 'th': return 'การซิงค์ล้มเหลว';
          case 'vi': return 'Lỗi đồng bộ';
          case 'en':
          default:
            return 'Sync Failed';
        }
      case 'noInternet':
        switch (lang) {
          case 'tr': return 'Çevrimdışı';
          case 'es': return 'Sin conexión';
          case 'fr': return 'Hors ligne';
          case 'de': return 'Offline';
          case 'it': return 'Offline';
          case 'pt': return 'Offline';
          case 'ru': return 'Офлайн';
          case 'zh': return '离线';
          case 'ja': return 'オフライン';
          case 'ko': return '오프라인';
          case 'hi': return 'ऑफलाइन';
          case 'ar': return 'بدون إنترنت';
          case 'nl': return 'Offline';
          case 'el': return 'Εκτός σύνδεσης';
          case 'sv': return 'Offline';
          case 'pl': return 'Offline';
          case 'id': return 'Offline';
          case 'th': return 'ออฟไลน์';
          case 'vi': return 'Ngoại tuyến';
          case 'en':
          default:
            return 'Offline';
        }
      case 'idle':
      default:
        switch (lang) {
          case 'tr': return 'Eşitle';
          case 'es': return 'Sincronizar';
          case 'fr': return 'Synchroniser';
          case 'de': return 'Sync';
          case 'it': return 'Sincronizza';
          case 'pt': return 'Sincronizar';
          case 'ru': return 'Синхронизировать';
          case 'zh': return '同步';
          case 'ja': return '同期';
          case 'ko': return '동기화';
          case 'hi': return 'सिंक करें';
          case 'ar': return 'مزامنة';
          case 'nl': return 'Synchroniseren';
          case 'el': return 'Συγχρονισμός';
          case 'sv': return 'Synka';
          case 'pl': return 'Synchronizuj';
          case 'id': return 'Sinkronkan';
          case 'th': return 'ซิงค์';
          case 'vi': return 'Đồng bộ';
          case 'en':
          default:
            return 'Sync';
        }
    }
  }

  static String goodNight(String lang) {
    switch (lang) {
      case 'tr': return 'İyi Geceler, Gezgin 🌙';
      case 'es': return 'Buenas noches, Viajero 🌙';
      case 'fr': return 'Bonne nuit, Voyageur 🌙';
      case 'de': return 'Gute Nacht, Reisender 🌙';
      case 'it': return 'Buonanotte, Viaggiatore 🌙';
      case 'pt': return 'Boa noite, Viajante 🌙';
      case 'ru': return 'Доброй ночи, Путешественник 🌙';
      case 'zh': return '晚安，旅行者 🌙';
      case 'ja': return 'おやすみなさい、旅行者 🌙';
      case 'ko': return '안녕히 주무세요, 여행자 🌙';
      case 'hi': return 'शुभ रात्रि, यात्री 🌙';
      case 'ar': return 'تصبح على خير، أيها المسافر 🌙';
      case 'nl': return 'Goedenacht, Reiziger 🌙';
      case 'el': return 'Καληνύχτα, Ταξιδιώτη 🌙';
      case 'sv': return 'God natt, Resenär 🌙';
      case 'pl': return 'Dobranoc, Podróżniku 🌙';
      case 'id': return 'Selamat malam, Penjelajah 🌙';
      case 'th': return 'ราตรีสวัสดิ์ นักเดินทาง 🌙';
      case 'vi': return 'Chúc ngủ ngon, Lữ khách 🌙';
      case 'en':
      default:
        return 'Good night, Traveler 🌙';
    }
  }

  static String greetingUser(String lang, String name) {
    switch (lang) {
      case 'tr': return 'Merhaba, $name';
      case 'es': return '¡Hola, $name!';
      case 'fr': return 'Bonjour, $name';
      case 'de': return 'Hallo, $name';
      case 'it': return 'Ciao, $name';
      case 'pt': return 'Olá, $name';
      case 'ru': return 'Привет, $name';
      case 'zh': return '你好，$name';
      case 'ja': return 'こんにちは、$nameさん';
      case 'ko': return '안녕하세요, $name님';
      case 'hi': return 'नमस्ते, $name';
      case 'ar': return 'مرحباً، $name';
      case 'nl': return 'Hallo, $name';
      case 'el': return 'Γεια σου, $name';
      case 'sv': return 'Hej, $name';
      case 'pl': return 'Cześć, $name';
      case 'id': return 'Halo, $name';
      case 'th': return 'สวัสดี $name';
      case 'vi': return 'Xin chào, $name';
      case 'en':
      default:
        return 'Hello, $name';
    }
  }

  static String customizeHome(String lang) {
    switch (lang) {
      case 'tr': return 'Ana Sayfayı Özelleştir';
      case 'es': return 'Personalizar Inicio';
      case 'fr': return 'Personnaliser l\'Accueil';
      case 'de': return 'Startseite anpassen';
      case 'it': return 'Personalizza Home';
      case 'pt': return 'Personalizar Início';
      case 'ru': return 'Настроить главную';
      case 'zh': return '自定义主页';
      case 'ja': return 'ホームをカスタマイズ';
      case 'ko': return '홈 화면 편집';
      case 'hi': return 'होम कस्टमाइज़ करें';
      case 'ar': return 'تخصيص الصفحة الرئيسية';
      case 'nl': return 'Startpagina aanpassen';
      case 'el': return 'Προσαρμογή αρχικής';
      case 'sv': return 'Anpassa hem';
      case 'pl': return 'Dostosuj ekran główny';
      case 'id': return 'Sesuaikan Beranda';
      case 'th': return 'ปรับแต่งหน้าแรก';
      case 'vi': return 'Tùy chỉnh Trang chủ';
      case 'en':
      default:
        return 'Customize Home';
    }
  }

  static String customizeSubtitle(String lang) {
    switch (lang) {
      case 'tr': return 'Bölümleri sürükleyerek sıralayın veya gizleyin';
      case 'es': return 'Arrastra para reordenar secciones o alternar visibilidad';
      case 'fr': return 'Glissez pour réorganiser ou masquer les sections';
      case 'de': return 'Ziehen zum Neuordnen oder Abschnitte ausblenden';
      case 'it': return 'Trascina per riordinare o nascondere le sezioni';
      case 'pt': return 'Arraste para reordenar ou ocultar seções';
      case 'ru': return 'Перетаскивайте для изменения порядка или скройте';
      case 'zh': return '拖动以调整版块顺序或切换显示';
      case 'ja': return 'ドラッグして並べ替え、または表示を切り替え';
      case 'ko': return '드래그하여 순서를 바꾸거나 섹션을 숨기세요';
      case 'hi': return 'क्रम बदलने या छुपाने के लिए खींचें';
      case 'ar': return 'اسحب لإعادة الترتيب أو إخفاء الأقسام';
      case 'nl': return 'Sleep om secties te rangschikken of te verbergen';
      case 'el': return 'Σύρετε για αναδιάταξη ή απόκρυψη ενοτήτων';
      case 'sv': return 'Dra för att ändra ordning eller dölja sektioner';
      case 'pl': return 'Przeciągnij, aby zmienić kolejność lub ukryć';
      case 'id': return 'Tarik untuk mengubah urutan atau sembunyikan bagian';
      case 'th': return 'ลากเพื่อจัดลำดับใหม่หรือซ่อนส่วนต่างๆ';
      case 'vi': return 'Kéo để sắp xếp lại hoặc ẩn các mục';
      case 'en':
      default:
        return 'Drag to reorder sections or toggle visibility';
    }
  }

  static String resetDefault(String lang) {
    switch (lang) {
      case 'tr': return 'Varsayılana Sıfırla';
      case 'es': return 'Restablecer';
      case 'fr': return 'Réinitialiser';
      case 'de': return 'Zurücksetzen';
      case 'it': return 'Reimposta';
      case 'pt': return 'Redefinir';
      case 'ru': return 'По умолчанию';
      case 'zh': return '恢复默认';
      case 'ja': return 'デフォルトに戻す';
      case 'ko': return '기본값으로 재설정';
      case 'hi': return 'डिफ़ॉल्ट पर रीसेट करें';
      case 'ar': return 'إعادة ضبط للافتراضي';
      case 'nl': return 'Standaard herstellen';
      case 'el': return 'Επαναφορά προεπιλογών';
      case 'sv': return 'Återställ';
      case 'pl': return 'Przywróć domyślne';
      case 'id': return 'Atur Ulang ke Default';
      case 'th': return 'รีเซ็ตเป็นค่าเริ่มต้น';
      case 'vi': return 'Đặt lại mặc định';
      case 'en':
      default:
        return 'Reset to Default';
    }
  }

  static String wideCard(String lang) {
    switch (lang) {
      case 'tr': return 'Geniş Kart';
      case 'es': return 'Tarjeta ancha';
      case 'fr': return 'Carte large';
      case 'de': return 'Breite Karte';
      case 'it': return 'Scheda ampia';
      case 'pt': return 'Cartão amplo';
      case 'ru': return 'Широкая карточка';
      case 'zh': return '宽卡片';
      case 'ja': return 'ワイドカード';
      case 'ko': return '와이드 카드';
      case 'ar': return 'بطاقة عريضة';
      case 'nl': return 'Brede kaart';
      case 'el': return 'Πλατιά κάρτα';
      case 'sv': return 'Bredt kort';
      case 'pl': return 'Szeroka karta';
      case 'id': return 'Kartu Lebar';
      case 'th': return 'การ์ดกว้าง';
      case 'vi': return 'Thẻ rộng';
      case 'hi': return 'चौड़ा कार्ड';
      case 'en':
      default:
        return 'Wide Card';
    }
  }

  static String miniBox(String lang) {
    switch (lang) {
      case 'tr': return 'Mini Kutu';
      case 'es': return 'Mini caja';
      case 'fr': return 'Mini boîte';
      case 'de': return 'Mini-Box';
      case 'it': return 'Mini riquadro';
      case 'pt': return 'Mini bloco';
      case 'ru': return 'Мини-блок';
      case 'zh': return '微型卡片';
      case 'ja': return 'ミニボックス';
      case 'ko': return '미니 박스';
      case 'ar': return 'صندوق صغير';
      case 'nl': return 'Minibox';
      case 'el': return 'Μίνι κουτί';
      case 'sv': return 'Minibox';
      case 'pl': return 'Minibox';
      case 'id': return 'Kotak Mini';
      case 'th': return 'กล่องมินิ';
      case 'vi': return 'Hộp nhỏ';
      case 'hi': return 'मिनी बॉक्स';
      case 'en':
      default:
        return 'Mini Box';
    }
  }

  static String sectionActiveTrip(String lang) {
    switch (lang) {
      case 'tr': return 'Aktif Seyahat';
      case 'es': return 'Viaje activo';
      case 'fr': return 'Voyage en cours';
      case 'de': return 'Aktive Reise';
      case 'it': return 'Viaggio attivo';
      case 'pt': return 'Viagem ativa';
      case 'ru': return 'Активная поездка';
      case 'zh': return '进行中行程';
      case 'ja': return 'アクティブな旅行';
      case 'ko': return '현재 여행';
      case 'ar': return 'الرحلة النشطة';
      case 'nl': return 'Actieve reis';
      case 'el': return 'Ενεργό ταξίδι';
      case 'sv': return 'Aktiv resa';
      case 'pl': return 'Aktywna podróż';
      case 'id': return 'Perjalanan Aktif';
      case 'th': return 'ทริปที่กำลังดำเนินการ';
      case 'vi': return 'Chuyến đi hiện tại';
      case 'hi': return 'सक्रिय यात्रा';
      case 'en':
      default:
        return 'Active Trip';
    }
  }

  static String sectionLuggageChecklist(String lang) {
    switch (lang) {
      case 'tr': return 'Bavul & Kontrol Listesi';
      case 'es': return 'Equipaje y Lista';
      case 'fr': return 'Bagages & Liste';
      case 'de': return 'Gepäck & Packliste';
      case 'it': return 'Bagagli & Lista';
      case 'pt': return 'Bagagem & Checklist';
      case 'ru': return 'Багаж и чеклист';
      case 'zh': return '行李与打包清单';
      case 'ja': return '手荷物＆チェックリスト';
      case 'ko': return '수하물 & 체크리스트';
      case 'ar': return 'الأمتعة وقائمة التحقق';
      case 'nl': return 'Bagage & Checklist';
      case 'el': return 'Αποσκευές & Λίστα';
      case 'sv': return 'Bagage & Packlista';
      case 'pl': return 'Bagaż i lista';
      case 'id': return 'Bagasi & Daftar Periksa';
      case 'th': return 'สัมภาระและเช็กลิสต์';
      case 'vi': return 'Hành lý & Danh sách';
      case 'hi': return 'सामान और चेकलिस्ट';
      case 'en':
      default:
        return 'Luggage & Checklist';
    }
  }

  static String sectionCurrencyConverter(String lang) {
    switch (lang) {
      case 'tr': return 'Canlı Döviz Çevirici';
      case 'es': return 'Conversor de divisas en vivo';
      case 'fr': return 'Convertisseur de devises en direct';
      case 'de': return 'Live-Währungsrechner';
      case 'it': return 'Convertitore valuta live';
      case 'pt': return 'Conversor de moedas ao vivo';
      case 'ru': return 'Онлайн конвертер валют';
      case 'zh': return '实时货币转换器';
      case 'ja': return 'リアルタイム為替計算機';
      case 'ko': return '실시간 환율 계산기';
      case 'ar': return 'محول العملات المباشر';
      case 'nl': return 'Live valutaconverter';
      case 'el': return 'Ζωντανός μετατροπέας συναλλάγματος';
      case 'sv': return 'Valutaomvandlare i realtid';
      case 'pl': return 'Przelicznik walut na żywo';
      case 'id': return 'Konverter Mata Uang Langsung';
      case 'th': return 'แปลงสกุลเงินสด';
      case 'vi': return 'Chuyển đổi tiền tệ trực tiếp';
      case 'hi': return 'लाइव मुद्रा परिवर्तक';
      case 'en':
      default:
        return 'Live Currency Converter';
    }
  }

  static String sectionTravelMap(String lang) {
    switch (lang) {
      case 'tr': return 'Dünya Keşif Haritası';
      case 'es': return 'Mapa de exploración mundial';
      case 'fr': return 'Carte d\'exploration du monde';
      case 'de': return 'Welt-Erkundungskarte';
      case 'it': return 'Mappa di esplorazione del mondo';
      case 'pt': return 'Mapa de exploração mundial';
      case 'ru': return 'Карта исследований мира';
      case 'zh': return '世界探索地图';
      case 'ja': return '世界探索マップ';
      case 'ko': return '세계 탐험 지도';
      case 'ar': return 'خريطة استكشاف العالم';
      case 'nl': return 'Wereldreiskaart';
      case 'el': return 'Παγκόσμιος χάρτης ταξιδιών';
      case 'sv': return 'Världsresekarta';
      case 'pl': return 'Mapa podróży po świecie';
      case 'id': return 'Peta Perjalanan Dunia';
      case 'th': return 'แผนที่การท่องเที่ยวรอบโลก';
      case 'vi': return 'Bản đồ du lịch thế giới';
      case 'hi': return 'विश्व यात्रा मानचित्र';
      case 'en':
      default:
        return 'World Travel Map';
    }
  }

  static String sectionVault(String lang) {
    switch (lang) {
      case 'tr': return 'Belge Kasası';
      case 'es': return 'Bóveda de documentos';
      case 'fr': return 'Coffre de documents';
      case 'de': return 'Dokumentensafe';
      case 'it': return 'Cassaforte documenti';
      case 'pt': return 'Cofre de documentos';
      case 'ru': return 'Сейф документов';
      case 'zh': return '文档保险库';
      case 'ja': return 'ドキュメント保管庫';
      case 'ko': return '문서 보관함';
      case 'ar': return 'خزينة المستندات';
      case 'nl': return 'Documentenkluis';
      case 'el': return 'Θησαυροφυλάκιο εγγράφων';
      case 'sv': return 'Dokumentvalv';
      case 'pl': return 'Sejf na dokumenty';
      case 'id': return 'Brankas Dokumen';
      case 'th': return 'ตู้นิรภัยเอกสาร';
      case 'vi': return 'Két tài liệu';
      case 'hi': return 'दस्तावेज़ वॉल्ट';
      case 'en':
      default:
        return 'Document Vault';
    }
  }

  static String sectionTripComparison(String lang) {
    switch (lang) {
      case 'tr': return 'Seyahat Kıyaslama';
      case 'es': return 'Comparar viajes';
      case 'fr': return 'Comparer les voyages';
      case 'de': return 'Reisen vergleichen';
      case 'it': return 'Confronta viaggi';
      case 'pt': return 'Comparar viagens';
      case 'ru': return 'Сравнение поездок';
      case 'zh': return '行程对比';
      case 'ja': return '旅行の比較';
      case 'ko': return '여행 비교';
      case 'ar': return 'مقارنة الرحلات';
      case 'nl': return 'Reizen vergelijken';
      case 'el': return 'Σύγκριση ταξιδιών';
      case 'sv': return 'Jämför resor';
      case 'pl': return 'Porównaj podróże';
      case 'id': return 'Bandingkan Perjalanan';
      case 'th': return 'เปรียบเทียบทริป';
      case 'vi': return 'So sánh chuyến đi';
      case 'hi': return 'यात्राओं की तुलना करें';
      case 'en':
      default:
        return 'Compare Trips';
    }
  }

  static String sectionAllTrips(String lang) {
    switch (lang) {
      case 'tr': return 'Seyahatlerim & Bütçe';
      case 'es': return 'Mis viajes y presupuesto';
      case 'fr': return 'Mes voyages & budget';
      case 'de': return 'Meine Reisen & Budget';
      case 'it': return 'I miei viaggi e budget';
      case 'pt': return 'Minhas viagens e orçamento';
      case 'ru': return 'Мои поездки и бюджет';
      case 'zh': return '我的行程与预算';
      case 'ja': return 'マイ旅行＆予算';
      case 'ko': return '내 여행 & 예산';
      case 'ar': return 'رحلاتي والميزانية';
      case 'nl': return 'Mijn reizen & budget';
      case 'el': return 'Τα ταξίδια μου & Προϋπολογισμός';
      case 'sv': return 'Mina resor & budget';
      case 'pl': return 'Moje podróże i budżet';
      case 'id': return 'Perjalanan & Anggaran Saya';
      case 'th': return 'ทริปและงบประมาณของฉัน';
      case 'vi': return 'Chuyến đi & Ngân sách của tôi';
      case 'hi': return 'मेरी यात्राएँ और बजट';
      case 'en':
      default:
        return 'My Trips & Budget';
    }
  }

  static String offlineAndEncrypted(String lang) {
    switch (lang) {
      case 'tr': return 'Çevrimdışı & Şifreli';
      case 'es': return 'Sin conexión y cifrado';
      case 'fr': return 'Hors-ligne et chiffré';
      case 'de': return 'Offline & verschlüsselt';
      case 'it': return 'Offline e crittografato';
      case 'pt': return 'Offline e criptografado';
      case 'ru': return 'Офлайн и зашифровано';
      case 'zh': return '离线加密';
      case 'ja': return 'オフライン暗号化';
      case 'ko': return '오프라인 및 암호화됨';
      case 'ar': return 'غير متصل ومشفر';
      case 'nl': return 'Offline & versleuteld';
      case 'el': return 'Εκτός σύνδεσης & κρυπτογραφημένο';
      case 'sv': return 'Offline & krypterad';
      case 'pl': return 'Offline i zaszyfrowane';
      case 'id': return 'Offline & Terenkripsi';
      case 'th': return 'ออฟไลน์และเข้ารหัส';
      case 'vi': return 'Ngoại tuyến & Mã hóa';
      case 'hi': return 'ऑफ़लाइन और एन्क्रिप्टेड';
      case 'en':
      default:
        return 'Offline & Encrypted';
    }
  }

  static String countriesVisited(String lang) {
    switch (lang) {
      case 'tr': return 'Ülke Ziyaret Edildi';
      case 'es': return 'Países visitados';
      case 'fr': return 'Pays visités';
      case 'de': return 'Länder besucht';
      case 'it': return 'Paesi visitati';
      case 'pt': return 'Países visitados';
      case 'ru': return 'Стран посещено';
      case 'zh': return '个已访问国家';
      case 'ja': return 'カ国を訪問';
      case 'ko': return '개국 방문';
      case 'ar': return 'دولة تمت زيارتها';
      case 'nl': return 'Landen bezocht';
      case 'el': return 'Χώρες που επισκεφθήκατε';
      case 'sv': return 'Länder besökta';
      case 'pl': return 'Odwiedzonych krajów';
      case 'id': return 'Negara Dikunjungi';
      case 'th': return 'ประเทศที่เคยไป';
      case 'vi': return 'Quốc gia đã đến';
      case 'hi': return 'देशों का दौरा किया';
      case 'en':
      default:
        return 'Countries Visited';
    }
  }

  static String compareRoutesAndBudget(String lang) {
    switch (lang) {
      case 'tr': return 'Rotaları ve bütçeleri kıyasla';
      case 'es': return 'Compara rutas y presupuestos';
      case 'fr': return 'Comparez itinéraires et budgets';
      case 'de': return 'Routen & Budgets vergleichen';
      case 'it': return 'Confronta percorsi e budget';
      case 'pt': return 'Compare rotas e orçamentos';
      case 'ru': return 'Сравните маршруты и бюджеты';
      case 'zh': return '对比路线与预算';
      case 'ja': return 'ルートと予算を比較';
      case 'ko': return '경로 및 예산 비교';
      case 'ar': return 'قارن المسارات والميزانيات';
      case 'nl': return 'Vergelijk routes & budgetten';
      case 'el': return 'Συγκρίνετε διαδρομές & προϋπολογισμούς';
      case 'sv': return 'Jämför rutter och budgetar';
      case 'pl': return 'Porównaj trasy i budżety';
      case 'id': return 'Bandingkan rute & anggaran';
      case 'th': return 'เปรียบเทียบเส้นทางและงบ';
      case 'vi': return 'So sánh lộ trình & ngân sách';
      case 'hi': return 'मार्गों और बजट की तुलना करें';
      case 'en':
      default:
        return 'Compare routes & budgets';
    }
  }

  // Vault Lockout & Recovery Localizations across all 20 languages
  static String vaultLockedTitle(String lang, String time) {
    switch (lang) {
      case 'tr': return 'Kasa Kilitlendi ($time)';
      case 'es': return 'Bóveda bloqueada ($time)';
      case 'fr': return 'Coffre verrouillé ($time)';
      case 'de': return 'Safe gesperrt ($time)';
      case 'it': return 'Cassaforte bloccata ($time)';
      case 'pt': return 'Cofre bloqueado ($time)';
      case 'ru': return 'Сейф заблокирован ($time)';
      case 'zh': return '保险库已锁定 ($time)';
      case 'ja': return '保管庫がロックされました ($time)';
      case 'ko': return '보관함 잠김 ($time)';
      case 'ar': return 'الخزينة مقفلة ($time)';
      case 'nl': return 'Kluis vergrendeld ($time)';
      case 'el': return 'Το θησαυροφυλάκιο κλειδώθηκε ($time)';
      case 'sv': return 'Valvet låst ($time)';
      case 'pl': return 'Sejf zablokowany ($time)';
      case 'id': return 'Brankas Terkunci ($time)';
      case 'th': return 'ตู้นิรภัยถูกล็อก ($time)';
      case 'vi': return 'Két đã bị khóa ($time)';
      case 'hi': return 'वॉल्ट लॉक हो गया ($time)';
      case 'en':
      default:
        return 'Vault Locked ($time)';
    }
  }

  static String vaultLockedDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Son 10 dakikada 5 kez hatalı PIN girildi. Güvenliğiniz için kasa geçici olarak kilitlendi. Bekleyebilir veya \'PIN\'imi Unuttum\' seçeneğiyle sıfırlayabilirsiniz.';
      case 'es': return 'Demasiados intentos incorrectos (5/5). Por seguridad, la bóveda está bloqueada temporalmente durante 10 minutos. Puedes esperar o restablecerla con "Olvidé el PIN".';
      case 'fr': return 'Trop de tentatives incorrectes (5/5). Pour votre sécurité, le coffre est temporairement verrouillé pendant 10 minutes. Vous pouvez attendre ou réinitialiser avec "PIN oublié".';
      case 'de': return 'Zu viele Fehlversuche (5/5). Zu Ihrer Sicherheit ist der Safe für 10 Minuten gesperrt. Sie können warten oder mit "PIN vergessen" zurücksetzen.';
      case 'it': return 'Troppi tentativi errati (5/5). Per la tua sicurezza, la cassaforte è temporaneamente bloccata per 10 minuti. Puoi attendere o reimpostarla con "PIN dimenticato".';
      case 'pt': return 'Muitas tentativas incorretas (5/5). Para sua segurança, o cofre está temporariamente bloqueado por 10 minutos. Você pode esperar ou redefinir em "Esqueci o PIN".';
      case 'ru': return 'Слишком много неверных попыток (5/5). В целях безопасности сейф заблокирован на 10 минут. Вы можете подождать или сбросить через "Забыли PIN".';
      case 'zh': return '错误尝试过多 (5/5)。为了您的安全，保险库已临时锁定10分钟。您可以等待或通过“忘记PIN码”进行重置。';
      case 'ja': return '誤った試行が多すぎます (5/5)。セキュリティのため、保管庫は10分間一時的にロックされています。お待ちいただくか、「PINを忘れた場合」からリセットできます。';
      case 'ko': return '잘못된 시도가 너무 많습니다 (5/5). 보안을 위해 보관함이 10분 동안 일시적으로 잠겼습니다. 잠시 기다리거나 \'PIN 분실\'을 통해 재설정할 수 있습니다.';
      case 'ar': return 'محاولات خاطئة كثيرة (5/5). لأمانك، تم قفل الخزينة مؤقتاً لمدة 10 دقائق. يمكنك الانتظار أو إعادة التعيين عبر "نسيت رمز PIN".';
      case 'nl': return 'Te veel onjuiste pogingen (5/5). Voor uw veiligheid is de kluis tijdelijk 10 minuten vergrendeld. U kunt wachten of resetten via "PIN vergeten".';
      case 'el': return 'Πολλές λανθασμένες προσπάθειες (5/5). Για την ασφάλειά σας, το θησαυροφυλάκιο κλειδώθηκε προσωρινά για 10 λεπτά. Μπορείτε να περιμένετε ή να κάνετε επαναφορά.';
      case 'sv': return 'För många felaktiga försök (5/5). För din säkerhet är valvet tillfälligt låst i 10 minuter. Du kan vänta eller återställa med "Glömt PIN".';
      case 'pl': return 'Zbyt wiele nieudanych prób (5/5). Dla Twojego bezpieczeństwa sejf został zablokowany na 10 minut. Możesz poczekać lub zresetować za pomocą "Nie pamiętam PIN".';
      case 'id': return 'Terlalu banyak percobaan salah (5/5). Demi keamanan, brankas dikunci sementara selama 10 menit. Anda dapat menunggu atau menyetel ulang via "Lupa PIN".';
      case 'th': return 'ป้อนรหัสผิดหลายครั้งเกินไป (5/5) เพื่อความปลอดภัย ตู้นิรภัยถูกล็อกชั่วคราวเป็นเวลา 10 นาที คุณสามารถรอหรือรีเซ็ตผ่าน "ลืมรหัส PIN"';
      case 'vi': return 'Quá nhiều lần thử sai (5/5). Vì sự an toàn của bạn, két bị khóa tạm thời trong 10 phút. Bạn có thể đợi hoặc đặt lại bằng "Quên mã PIN".';
      case 'hi': return 'बहुत सारे गलत प्रयास (5/5)। आपकी सुरक्षा के लिए वॉल्ट को 10 मिनट के लिए अस्थायी रूप से लॉक कर दिया गया है। आप प्रतीक्षा कर सकते हैं या "पिन भूल गए" से रीसेट कर सकते हैं।';
      case 'en':
      default:
        return 'Too many incorrect attempts (5/5). For your security, the vault is temporarily locked for 10 minutes. You can wait or reset it using "Forgot PIN".';
    }
  }

  static String vaultLockedSnackbar(String lang) {
    switch (lang) {
      case 'tr': return 'Çok fazla hatalı deneme (5/5). Kasa 10 dakika süreyle kilitlendi.';
      case 'es': return 'Demasiados intentos incorrectos (5/5). Bóveda bloqueada por 10 minutos.';
      case 'fr': return 'Trop de tentatives incorrectes (5/5). Coffre verrouillé pour 10 minutes.';
      case 'de': return 'Zu viele Fehlversuche (5/5). Safe für 10 Minuten gesperrt.';
      case 'it': return 'Troppi tentativi errati (5/5). Cassaforte bloccata per 10 minuti.';
      case 'pt': return 'Muitas tentativas incorretas (5/5). Cofre bloqueado por 10 minutos.';
      case 'ru': return 'Слишком много неверных попыток (5/5). Сейф заблокирован на 10 минут.';
      case 'zh': return '错误尝试过多 (5/5)。保险库已锁定10分钟。';
      case 'ja': return '誤った試行が多すぎます (5/5)。保管庫は10分間ロックされました。';
      case 'ko': return '잘못된 시도가 너무 많습니다 (5/5). 보관함이 10분간 잠겼습니다.';
      case 'ar': return 'محاولات خاطئة كثيرة (5/5). تم قفل الخزينة لمدة 10 دقائق.';
      case 'nl': return 'Te veel onjuiste pogingen (5/5). Kluis is 10 minuten vergrendeld.';
      case 'el': return 'Πολλές λανθασμένες προσπάθειες (5/5). Το θησαυροφυλάκιο κλειδώθηκε για 10 λεπτά.';
      case 'sv': return 'För många felaktiga försök (5/5). Valvet är låst i 10 minuter.';
      case 'pl': return 'Zbyt wiele nieudanych prób (5/5). Sejf zablokowany na 10 minut.';
      case 'id': return 'Terlalu banyak percobaan salah (5/5). Brankas dikunci selama 10 menit.';
      case 'th': return 'ป้อนรหัสผิดหลายครั้งเกินไป (5/5) ตู้นิรภัยถูกล็อก 10 นาที';
      case 'vi': return 'Quá nhiều lần thử sai (5/5). Két bị khóa trong 10 phút.';
      case 'hi': return 'बहुत सारे गलत प्रयास (5/5)। वॉल्ट 10 मिनट के लिए लॉक है।';
      case 'en':
      default:
        return 'Too many incorrect attempts (5/5). Vault is locked for 10 minutes.';
    }
  }

  static String vaultRemainingAttempts(String lang, int remaining, [int max = 5]) {
    switch (lang) {
      case 'tr': return 'Kalan deneme hakkı: $remaining/$max';
      case 'es': return 'Intentos restantes: $remaining/$max';
      case 'fr': return 'Tentatives restantes : $remaining/$max';
      case 'de': return 'Verbleibende Versuche: $remaining/$max';
      case 'it': return 'Tentativi rimasti: $remaining/$max';
      case 'pt': return 'Tentativas restantes: $remaining/$max';
      case 'ru': return 'Осталось попыток: $remaining/$max';
      case 'zh': return '剩余尝试次数：$remaining/$max';
      case 'ja': return '残り試行回数: $remaining/$max';
      case 'ko': return '남은 시도 횟수: $remaining/$max';
      case 'ar': return 'المحاولات المتبقية: $remaining/$max';
      case 'nl': return 'Resterende pogingen: $remaining/$max';
      case 'el': return 'Απομένουσες προσπάθειες: $remaining/$max';
      case 'sv': return 'Återstående försök: $remaining/$max';
      case 'pl': return 'Pozostałe próby: $remaining/$max';
      case 'id': return 'Sisa percobaan: $remaining/$max';
      case 'th': return 'จำนวนครั้งที่เหลือ: $remaining/$max';
      case 'vi': return 'Số lần thử còn lại: $remaining/$max';
      case 'hi': return 'शेष प्रयास: $remaining/$max';
      case 'en':
      default:
        return 'Attempts remaining: $remaining/$max';
    }
  }

  static String vaultIncorrectPinBanner(String lang, int remaining, [int max = 5]) {
    switch (lang) {
      case 'tr': return 'Hatalı PIN kodu! Kalan deneme hakkı: $remaining/$max';
      case 'es': return '¡PIN incorrecto! Intentos restantes: $remaining/$max';
      case 'fr': return 'Code PIN incorrect ! Tentatives restantes : $remaining/$max';
      case 'de': return 'Falsche PIN! Verbleibende Versuche: $remaining/$max';
      case 'it': return 'PIN errato! Tentativi rimasti: $remaining/$max';
      case 'pt': return 'PIN incorreto! Tentativas restantes: $remaining/$max';
      case 'ru': return 'Неверный PIN! Осталось попыток: $remaining/$max';
      case 'zh': return 'PIN码错误！剩余尝试次数：$remaining/$max';
      case 'ja': return 'PINが正しくありません！残り試行回数: $remaining/$max';
      case 'ko': return '잘못된 PIN입니다! 남은 시도 횟수: $remaining/$max';
      case 'ar': return 'رمز PIN غير صحيح! المحاولات المتبقية: $remaining/$max';
      case 'nl': return 'Onjuiste pincode! Resterende pogingen: $remaining/$max';
      case 'el': return 'Λανθασμένο PIN! Απομένουσες προσπάθειες: $remaining/$max';
      case 'sv': return 'Fel PIN-kod! Återstående försök: $remaining/$max';
      case 'pl': return 'Nieprawidłowy PIN! Pozostałe próby: $remaining/$max';
      case 'id': return 'PIN salah! Sisa percobaan: $remaining/$max';
      case 'th': return 'รหัส PIN ไม่ถูกต้อง! จำนวนครั้งที่เหลือ: $remaining/$max';
      case 'vi': return 'Mã PIN không đúng! Số lần thử còn lại: $remaining/$max';
      case 'hi': return 'गलत पिन कोड! शेष प्रयास: $remaining/$max';
      case 'en':
      default:
        return 'Incorrect PIN! Attempts remaining: $remaining/$max';
    }
  }

  static String vaultAutofillCode(String lang) {
    switch (lang) {
      case 'tr': return 'Kodu Otomatik Doldur';
      case 'es': return 'Autorrellenar código';
      case 'fr': return 'Remplissage automatique du code';
      case 'de': return 'Code automatisch ausfüllen';
      case 'it': return 'Compila automaticamente il codice';
      case 'pt': return 'Preencher código automaticamente';
      case 'ru': return 'Автозаполнение кода';
      case 'zh': return '自动填充验证码';
      case 'ja': return 'コードを自動入力';
      case 'ko': return '인증 코드 자동 입력';
      case 'ar': return 'ملء الرمز تلقائياً';
      case 'nl': return 'Code automatisch invullen';
      case 'el': return 'Αυτόματη συμπλήρωση κωδικού';
      case 'sv': return 'Fyll i kod automatiskt';
      case 'pl': return 'Wypełnij kod automatycznie';
      case 'id': return 'Isi Kode Otomatis';
      case 'th': return 'กรอกรหัสอัตโนมัติ';
      case 'vi': return 'Tự động điền mã';
      case 'hi': return 'कोड स्वतः भरें';
      case 'en':
      default:
        return 'Auto-fill Code';
    }
  }
}
