/// Native localization for Connectivity Banner, Sync Status and Diagnostic Logs across 20 languages
class ConnectivityLocalization {
  ConnectivityLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String getOfflineBanner(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Çevrimdışısınız — Değişiklikler bağlandığınızda buluta eşitlenecek';
      case 'de':
        return 'Offline — Änderungen werden bei Verbindung synchronisiert';
      case 'es':
        return 'Sin conexión — Los cambios se sincronizarán al conectarte';
      case 'fr':
        return 'Hors ligne — Les modifications seront synchronisées dès connexion';
      case 'it':
        return 'Sei offline — Le modifiche verranno sincronizzate alla riconnessione';
      case 'pt':
        return 'Você está offline — As alterações serão sincronizadas ao conectar';
      case 'ru':
        return 'Вы не в сети — Изменения синхронизируются при подключении';
      case 'zh':
        return '当前处于离线状态 — 连接网络后将自动同步更改';
      case 'ja':
        return 'オフラインです — 再接続時に変更内容がクラウドへ同期されます';
      case 'ko':
        return '오프라인 상태입니다 — 연결되면 변경사항이 클라우드에 동기화됩니다';
      case 'hi':
        return 'आप ऑफलाइन हैं — कनेक्ट होने पर बदलाव सिंक हो जाएंगे';
      case 'ar':
        return 'أنت غير متصل — ستتم مزامنة التغييرات فور استعادة الاتصال';
      case 'nl':
        return 'U bent offline — Wijzigingen worden gesynchroniseerd bij verbinding';
      case 'el':
        return 'Είστε εκτός σύνδεσης — Οι αλλαγές θα συγχρονιστούν όταν συνδεθείτε';
      case 'sv':
        return 'Du är offline — Ändringar synkroniseras vid återanslutning';
      case 'pl':
        return 'Jesteś offline — Zmiany zostaną zsynchronizowane po połączeniu';
      case 'id':
        return 'Anda sedang offline — Perubahan akan disinkronkan saat terhubung';
      case 'th':
        return 'คุณออฟไลน์อยู่ — ข้อมูลจะซิงค์กับคลาวด์เมื่อเชื่อมต่ออินเทอร์เน็ต';
      case 'vi':
        return 'Bạn đang ngoại tuyến — Thay đổi sẽ đồng bộ khi có kết nối';
      case 'en':
      default:
        return 'You are offline — Changes will sync when reconnected';
    }
  }

  static String getSyncingBanner(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Bulutla eşitleniyor...';
      case 'de':
        return 'Mit Cloud synchronisieren...';
      case 'es':
        return 'Sincronizando con la nube...';
      case 'fr':
        return 'Synchronisation avec le cloud...';
      case 'it':
        return 'Sincronizzazione in corso...';
      case 'pt':
        return 'Sincronizando com a nuvem...';
      case 'ru':
        return 'Синхронизация с облаком...';
      case 'zh':
        return '正在与云端同步...';
      case 'ja':
        return 'クラウドと同期中...';
      case 'ko':
        return '클라우드와 동기화 중...';
      case 'hi':
        return 'क्लाउड से सिंक हो रहा है...';
      case 'ar':
        return 'جارٍ المزامنة مع السحابة...';
      case 'nl':
        return 'Synchroniseren met cloud...';
      case 'el':
        return 'Συγχρονισμός με το cloud...';
      case 'sv':
        return 'Synkroniserar med molnet...';
      case 'pl':
        return 'Synchronizacja z chmurą...';
      case 'id':
        return 'Menyinkronkan dengan cloud...';
      case 'th':
        return 'กำลังซิงค์กับคลาวด์...';
      case 'vi':
        return 'Đang đồng bộ với đám mây...';
      case 'en':
      default:
        return 'Syncing with cloud...';
    }
  }

  static String getSyncFailedBanner(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Eşleme başarısız oldu — Tekrar deneyin';
      case 'de':
        return 'Synchronisierung fehlgeschlagen — Erneut versuchen';
      case 'es':
        return 'Error de sincronización — Toca para reintentar';
      case 'fr':
        return 'Échec de synchronisation — Appuyez pour réessayer';
      case 'it':
        return 'Sincronizzazione non riuscita — Riprova';
      case 'pt':
        return 'Falha na sincronização — Toque para tentar de novo';
      case 'ru':
        return 'Сбой синхронизации — Нажмите для повтора';
      case 'zh':
        return '同步失败 — 点击重试';
      case 'ja':
        return '同期に失敗しました — 再試行してください';
      case 'ko':
        return '동기화 실패 — 다시 시도하세요';
      case 'hi':
        return 'सिंक विफल रहा — पुनः प्रयास करें';
      case 'ar':
        return 'فشلت المزامنة — اضغط لإعادة المحاولة';
      case 'nl':
        return 'Synchronisatie mislukt — Tik om opnieuw te proberen';
      case 'el':
        return 'Ο συγχρονισμός απέτυχε — Δοκιμάστε ξανά';
      case 'sv':
        return 'Synkronisering misslyckades — Försök igen';
      case 'pl':
        return 'Synchronizacja nie powiodła się — Spróbuj ponownie';
      case 'id':
        return 'Sinkronisasi gagal — Ketuk untuk mencoba lagi';
      case 'th':
        return 'การซิงค์ล้มเหลว — แตะเพื่อลองใหม่';
      case 'vi':
        return 'Đồng bộ thất bại — Nhấn để thử lại';
      case 'en':
      default:
        return 'Sync failed — Tap to retry';
    }
  }

  static String getRetry(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Tekrar Dene';
      case 'de':
        return 'Wiederholen';
      case 'es':
        return 'Reintentar';
      case 'fr':
        return 'Réessayer';
      case 'it':
        return 'Riprova';
      case 'pt':
        return 'Tentar de novo';
      case 'ru':
        return 'Повторить';
      case 'zh':
        return '重试';
      case 'ja':
        return '再試行';
      case 'ko':
        return '다시 시도';
      case 'hi':
        return 'पुनः प्रयास';
      case 'ar':
        return 'إعادة المحاولة';
      case 'nl':
        return 'Opnieuw';
      case 'el':
        return 'Επανάληψη';
      case 'sv':
        return 'Försök igen';
      case 'pl':
        return 'Ponów';
      case 'id':
        return 'Coba Lagi';
      case 'th':
        return 'ลองใหม่';
      case 'vi':
        return 'Thử lại';
      case 'en':
      default:
        return 'Retry';
    }
  }

  static String getSyncStatusTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Eşleme Durumu & Günlük';
      case 'de':
        return 'Synchronisationsstatus & Protokoll';
      case 'es':
        return 'Estado de Sincronización y Registro';
      case 'fr':
        return 'État et Historique de Synchronisation';
      case 'it':
        return 'Stato di Sincronizzazione e Log';
      case 'pt':
        return 'Status de Sincronização e Histórico';
      case 'ru':
        return 'Статус синхронизации и журнал';
      case 'zh':
        return '同步状态与日志';
      case 'ja':
        return '同期ステータスとログ';
      case 'ko':
        return '동기화 상태 및 로그';
      case 'hi':
        return 'सिंक स्थिति और लॉग';
      case 'ar':
        return 'حالة المزامنة وسجل العمليات';
      case 'nl':
        return 'Synchronisatiestatus & Log';
      case 'el':
        return 'Κατάσταση Συγχρονισμού & Ιστορικό';
      case 'sv':
        return 'Synkroniseringsstatus & logg';
      case 'pl':
        return 'Status synchronizacji i historia';
      case 'id':
        return 'Status & Log Sinkronisasi';
      case 'th':
        return 'สถานะและประวัติการซิงค์';
      case 'vi':
        return 'Trạng thái & Nhật ký đồng bộ';
      case 'en':
      default:
        return 'Sync Status & Log';
    }
  }

  static String getSyncStatusSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Çift yönlü diferansiyel eşleme ve çakışma çözüm geçmişi';
      case 'de':
        return 'Bidirektionale Synchronisation und Konfliktlösungsprotokoll';
      case 'es':
        return 'Historial de sincronización bidireccional y resolución de conflictos';
      case 'fr':
        return 'Historique de synchronisation bidirectionnelle et résolutions';
      case 'it':
        return 'Sincronizzazione bidirezionale e risoluzione automatica';
      case 'pt':
        return 'Sincronização bidirecional e resolução de conflitos';
      case 'ru':
        return 'Двусторонняя синхронизация и журнал разрешения конфликтов';
      case 'zh':
        return '双向差分同步与冲突自动解决记录';
      case 'ja':
        return '双方向差分同期と競合自動解決の履歴';
      case 'ko':
        return '양방향 차분 동기화 및 충돌 자동 해결 내역';
      case 'hi':
        return 'दोतरफा सिंक और विरोध समाधान इतिहास';
      case 'ar':
        return 'المزامنة ثنائية الاتجاه وسجل تسوية التضارب التلقائي';
      case 'nl':
        return 'Bidirectionele synchronisatie en conflictoplossingsgeschiedenis';
      case 'el':
        return 'Ιστορικό αμφίδρομου συγχρονισμού και επίλυσης διενέξεων';
      case 'sv':
        return 'Tvåvägssynkronisering och historik för konfliktlösning';
      case 'pl':
        return 'Dwukierunkowa synchronizacja i historia rozwiązywania konfliktów';
      case 'id':
        return 'Riwayat sinkronisasi dua arah dan penyelesaian konflik';
      case 'th':
        return 'การซิงค์สองทางและประวัติการจัดการความขัดแย้งของข้อมูล';
      case 'vi':
        return 'Lịch sử đồng bộ hai chiều và giải quyết xung đột';
      case 'en':
      default:
        return 'Two-way delta sync & automatic conflict resolution logs';
    }
  }

  static String getOnlineStatus(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Çevrimiçi (Bulut Bağlantısı Aktif)';
      case 'de':
        return 'Online (Cloud aktiv)';
      case 'es':
        return 'En línea (Nube conectada)';
      case 'fr':
        return 'En ligne (Cloud connecté)';
      case 'it':
        return 'Online (Cloud attivo)';
      case 'pt':
        return 'Online (Nuvem conectada)';
      case 'ru':
        return 'В сети (Облако подключено)';
      case 'zh':
        return '在线 (云端已连接)';
      case 'ja':
        return 'オンライン (クラウド接続中)';
      case 'ko':
        return '온라인 (클라우드 연결됨)';
      case 'hi':
        return 'ऑनलाइन (क्लाउड सक्रिय)';
      case 'ar':
        return 'متصل (السحابة نشطة)';
      case 'nl':
        return 'Online (Cloud verbonden)';
      case 'el':
        return 'Σε σύνδεση (Cloud ενεργό)';
      case 'sv':
        return 'Online (Molnet anslutet)';
      case 'pl':
        return 'Online (Połączono z chmurą)';
      case 'id':
        return 'Online (Terhubung ke Cloud)';
      case 'th':
        return 'ออนไลน์ (เชื่อมต่อคลาวด์แล้ว)';
      case 'vi':
        return 'Trực tuyến (Đã kết nối đám mây)';
      case 'en':
      default:
        return 'Online (Cloud Connected)';
    }
  }

  static String getOfflineStatus(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Çevrimdışı (Yerel Veritabanı Aktif)';
      case 'de':
        return 'Offline (Lokale Datenbank aktiv)';
      case 'es':
        return 'Desconectado (Base local activa)';
      case 'fr':
        return 'Hors ligne (Base locale active)';
      case 'it':
        return 'Offline (Database locale attivo)';
      case 'pt':
        return 'Offline (Banco local ativo)';
      case 'ru':
        return 'Не в сети (Локальная база)';
      case 'zh':
        return '离线 (本地数据库运行)';
      case 'ja':
        return 'オフライン (ローカルDB動作中)';
      case 'ko':
        return '오프라인 (로컬 DB 작동 중)';
      case 'hi':
        return 'ऑफलाइन (स्थानीय डेटाबेस सक्रिय)';
      case 'ar':
        return 'غير متصل (قاعدة البيانات المحلية تعمل)';
      case 'nl':
        return 'Offline (Lokale database actief)';
      case 'el':
        return 'Εκτός σύνδεσης (Τοπική βάση ενεργή)';
      case 'sv':
        return 'Offline (Lokal databas aktiv)';
      case 'pl':
        return 'Offline (Działa baza lokalna)';
      case 'id':
        return 'Offline (Database lokal aktif)';
      case 'th':
        return 'ออฟไลน์ (ฐานข้อมูลในเครื่องทำงาน)';
      case 'vi':
        return 'Ngoại tuyến (Cơ sở dữ liệu cục bộ)';
      case 'en':
      default:
        return 'Offline (Local Database Active)';
    }
  }

  static String getLastSync(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Son Başarılı Eşleme';
      case 'de':
        return 'Letzte Synchronisation';
      case 'es':
        return 'Última sincronización exitosa';
      case 'fr':
        return 'Dernière synchronisation réussie';
      case 'it':
        return 'Ultima sincronizzazione';
      case 'pt':
        return 'Última sincronização';
      case 'ru':
        return 'Последняя синхронизация';
      case 'zh':
        return '上次成功同步时间';
      case 'ja':
        return '最終成功同期日時';
      case 'ko':
        return '최근 성공 동기화';
      case 'hi':
        return 'अंतिम सफल सिंक';
      case 'ar':
        return 'آخر مزامنة ناجحة';
      case 'nl':
        return 'Laatste synchronisatie';
      case 'el':
        return 'Τελευταίος επιτυχής συγχρονισμός';
      case 'sv':
        return 'Senaste lyckade synk';
      case 'pl':
        return 'Ostatnia udana synchronizacja';
      case 'id':
        return 'Sinkronisasi Terakhir';
      case 'th':
        return 'ซิงค์สำเร็จล่าสุด';
      case 'vi':
        return 'Lần đồng bộ thành công gần nhất';
      case 'en':
      default:
        return 'Last Successful Sync';
    }
  }

  static String getPendingChanges(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Buluta Aktarılmayı Bekleyenler';
      case 'de':
        return 'Ausstehende lokale Änderungen';
      case 'es':
        return 'Cambios locales pendientes';
      case 'fr':
        return 'Modifications locales en attente';
      case 'it':
        return 'Modifiche locali in attesa';
      case 'pt':
        return 'Alterações locais pendentes';
      case 'ru':
        return 'Ожидают отправки в облако';
      case 'zh':
        return '待上传至云端的本地更改';
      case 'ja':
        return '保留中のローカル変更';
      case 'ko':
        return '대기 중인 로컬 변경사항';
      case 'hi':
        return 'लंबित स्थानीय परिवर्तन';
      case 'ar':
        return 'تغييرات محلية قيد الانتظار';
      case 'nl':
        return 'Wachtende lokale wijzigingen';
      case 'el':
        return 'Εκκρεμείς τοπικές αλλαγές';
      case 'sv':
        return 'Väntande lokala ändringar';
      case 'pl':
        return 'Oczekujące zmiany lokalne';
      case 'id':
        return 'Perubahan lokal tertunda';
      case 'th':
        return 'การเปลี่ยนแปลงที่รออัปโหลด';
      case 'vi':
        return 'Thay đổi cục bộ đang chờ đồng bộ';
      case 'en':
      default:
        return 'Pending Local Changes';
    }
  }

  static String getSyncNow(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Şimdi Eşle';
      case 'de':
        return 'Jetzt synchronisieren';
      case 'es':
        return 'Sincronizar ahora';
      case 'fr':
        return 'Synchroniser maintenant';
      case 'it':
        return 'Sincronizza ora';
      case 'pt':
        return 'Sincronizar agora';
      case 'ru':
        return 'Синхронизировать сейчас';
      case 'zh':
        return '立即同步';
      case 'ja':
        return '今すぐ同期';
      case 'ko':
        return '지금 동기화';
      case 'hi':
        return 'अभी सिंक करें';
      case 'ar':
        return 'مزامنة الآن';
      case 'nl':
        return 'Nu synchroniseren';
      case 'el':
        return 'Συγχρονισμός τώρα';
      case 'sv':
        return 'Synkronisera nu';
      case 'pl':
        return 'Synchronizuj teraz';
      case 'id':
        return 'Sinkronkan Sekarang';
      case 'th':
        return 'ซิงค์ทันที';
      case 'vi':
        return 'Đồng bộ ngay';
      case 'en':
      default:
        return 'Sync Now';
    }
  }

  static String getSyncHistory(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Eşleme Geçmişi';
      case 'de':
        return 'Synchronisationsverlauf';
      case 'es':
        return 'Historial de sincronización';
      case 'fr':
        return 'Historique des synchronisations';
      case 'it':
        return 'Cronologia sincronizzazioni';
      case 'pt':
        return 'Histórico de sincronizações';
      case 'ru':
        return 'История синхронизаций';
      case 'zh':
        return '历史同步记录';
      case 'ja':
        return '同期履歴';
      case 'ko':
        return '동기화 기록';
      case 'hi':
        return 'सिंक इतिहास';
      case 'ar':
        return 'سجل المزامنة';
      case 'nl':
        return 'Synchronisatiegeschiedenis';
      case 'el':
        return 'Ιστορικό συγχρονισμού';
      case 'sv':
        return 'Synkroniseringshistorik';
      case 'pl':
        return 'Historia synchronizacji';
      case 'id':
        return 'Riwayat Sinkronisasi';
      case 'th':
        return 'ประวัติการซิงค์';
      case 'vi':
        return 'Lịch sử đồng bộ';
      case 'en':
      default:
        return 'Sync History';
    }
  }

  static String getNoHistory(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Henüz kayıtlı bir eşleme olayı bulunmuyor.';
      case 'de':
        return 'Bisher keine Synchronisationsereignisse aufgezeichnet.';
      case 'es':
        return 'Aún no hay eventos de sincronización registrados.';
      case 'fr':
        return 'Aucun événement de synchronisation enregistré pour l\'instant.';
      case 'it':
        return 'Nessun evento di sincronizzazione ancora registrato.';
      case 'pt':
        return 'Nenhum evento de sincronização registrado ainda.';
      case 'ru':
        return 'События синхронизации пока не зафиксированы.';
      case 'zh':
        return '暂无同步历史记录。';
      case 'ja':
        return '同期イベントはまだ記録されていません。';
      case 'ko':
        return '기록된 동기화 이벤트가 아직 없습니다.';
      case 'hi':
        return 'अभी तक कोई सिंक इतिहास दर्ज नहीं है।';
      case 'ar':
        return 'لا توجد سجلات مزامنة سابقة حتى الآن.';
      case 'nl':
        return 'Nog geen synchronisatiegebeurtenissen geregistreerd.';
      case 'el':
        return 'Δεν υπάρχουν ακόμη καταγεγραμμένα συμβάντα συγχρονισμού.';
      case 'sv':
        return 'Inga synkroniseringshändelser registrerade ännu.';
      case 'pl':
        return 'Brak zarejestrowanych zdarzeń synchronizacji.';
      case 'id':
        return 'Belum ada riwayat aktivitas sinkronisasi.';
      case 'th':
        return 'ยังไม่มีบันทึกประวัติการซิงค์';
      case 'vi':
        return 'Chưa có sự kiện đồng bộ nào được ghi nhận.';
      case 'en':
      default:
        return 'No sync events recorded yet.';
    }
  }

  static String getClearHistory(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Geçmişi Temizle';
      case 'de':
        return 'Verlauf löschen';
      case 'es':
        return 'Borrar historial';
      case 'fr':
        return 'Effacer l\'historique';
      case 'it':
        return 'Cancella cronologia';
      case 'pt':
        return 'Limpar histórico';
      case 'ru':
        return 'Очистить историю';
      case 'zh':
        return '清除历史';
      case 'ja':
        return '履歴を消去';
      case 'ko':
        return '기록 삭제';
      case 'hi':
        return 'इतिहास साफ़ करें';
      case 'ar':
        return 'مسح السجل';
      case 'nl':
        return 'Geschiedenis wissen';
      case 'el':
        return 'Εκκαθάριση ιστορικού';
      case 'sv':
        return 'Rensa historik';
      case 'pl':
        return 'Wyczyść historię';
      case 'id':
        return 'Hapus Riwayat';
      case 'th':
        return 'ล้างประวัติ';
      case 'vi':
        return 'Xóa lịch sử';
      case 'en':
      default:
        return 'Clear History';
    }
  }

  static String getPendingChangesSummary(String lang, int count) {
    final clean = _cleanLang(lang);
    if (count > 0) {
      switch (clean) {
        case 'tr': return '$count yerel kayıt eşitlenmeyi bekliyor';
        case 'de': return '$count lokale Änderungen warten auf Synchronisation';
        case 'fr': return '$count modifications locales en attente de synchronisation';
        case 'es': return '$count cambios locales pendientes de sincronizar';
        case 'it': return '$count modifiche locali in attesa di sincronizzazione';
        case 'pt': return '$count alterações locais aguardando sincronização';
        case 'ru': return '$count локальных изменений ожидают синхронизации';
        case 'zh': return '$count 条本地更改等待同步';
        case 'ja': return '$count 件の未同期データがあります';
        case 'ko': return '$count개의 로컬 변경사항 동기화 대기 중';
        case 'ar': return '$count تعديلات محلية في انتظار المزامنة';
        case 'hi': return '$count स्थानीय परिवर्तन सिंक होने की प्रतीक्षा में हैं';
        case 'nl': return '$count lokale wijzigingen wachten op synchronisatie';
        case 'el': return '$count τοπικές αλλαγές σε αναμονή συγχρονισμού';
        case 'sv': return '$count lokala ändringar väntar på att synkroniseras';
        case 'pl': return '$count lokalnych zmian oczekuje na synchronizację';
        case 'id': return '$count perubahan lokal menunggu sinkronisasi';
        case 'th': return '$count รายการรอการซิงค์ข้อมูล';
        case 'vi': return '$count thay đổi cục bộ đang chờ đồng bộ';
        case 'en':
        default: return '$count local ${count == 1 ? "change" : "changes"} waiting to sync';
      }
    } else {
      switch (clean) {
        case 'tr': return 'Tüm yerel verileriniz bulut ile güncel';
        case 'de': return 'Alle lokalen Daten sind vollständig synchronisiert';
        case 'fr': return 'Toutes les données locales sont synchronisées avec le cloud';
        case 'es': return 'Todos los datos locales están sincronizados con la nube';
        case 'it': return 'Tutti i dati locali sono sincronizzati con il cloud';
        case 'pt': return 'Todas as alterações locais estão sincronizadas com a nuvem';
        case 'ru': return 'Все локальные данные синхронизированы с облаком';
        case 'zh': return '所有本地更改均已同步至云端';
        case 'ja': return 'すべてのローカルデータはクラウドと同期済みです';
        case 'ko': return '모든 로컬 데이터가 클라우드와 동기화되었습니다';
        case 'ar': return 'جميع البيانات المحلية متزامنة بالكامل مع السحابة';
        case 'hi': return 'सभी स्थानीय डेटा क्लाउड के साथ पूरी तरह से सिंक हैं';
        case 'nl': return 'Alle lokale gegevens zijn gesynchroniseerd met de cloud';
        case 'el': return 'Όλα τα τοπικά δεδομένα είναι πλήρως συγχρονισμένα';
        case 'sv': return 'Alla lokala data är synkroniserade med molnet';
        case 'pl': return 'Wszystkie dane lokalne są w pełni zsynchronizowane';
        case 'id': return 'Semua perubahan lokal sudah tersinkronisasi ke cloud';
        case 'th': return 'ข้อมูลทั้งหมดซิงค์กับคลาวด์เรียบร้อยแล้ว';
        case 'vi': return 'Tất cả dữ liệu cục bộ đã được đồng bộ với đám mây';
        case 'en':
        default: return 'All local changes are fully synchronized';
      }
    }
  }

  static String tripsCountLabel(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Seyahat';
      case 'de': return '$count Reisen';
      case 'fr': return '$count Voyages';
      case 'es': return '$count Viajes';
      case 'it': return '$count Viaggi';
      case 'pt': return '$count Viagens';
      case 'ru': return '$count Поездок';
      case 'zh': return '$count 个行程';
      case 'ja': return '$count 件の旅行';
      case 'ko': return '$count개 여행';
      case 'ar': return '$count رحلات';
      case 'hi': return '$count यात्राएं';
      case 'nl': return '$count Reizen';
      case 'el': return '$count Ταξίδια';
      case 'sv': return '$count Resor';
      case 'pl': return '$count Podróży';
      case 'id': return '$count Perjalanan';
      case 'th': return '$count การเดินทาง';
      case 'vi': return '$count Chuyến đi';
      case 'en':
      default: return '$count ${count == 1 ? "Trip" : "Trips"}';
    }
  }

  static String itemsCountLabel(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Eşya';
      case 'de': return '$count Gegenstände';
      case 'fr': return '$count Objets';
      case 'es': return '$count Artículos';
      case 'it': return '$count Oggetti';
      case 'pt': return '$count Itens';
      case 'ru': return '$count Вещей';
      case 'zh': return '$count 件物品';
      case 'ja': return '$count 個のアイテム';
      case 'ko': return '$count개 소지품';
      case 'ar': return '$count أغراض';
      case 'hi': return '$count वस्तुएं';
      case 'nl': return '$count Items';
      case 'el': return '$count Αντικείμενα';
      case 'sv': return '$count Föremål';
      case 'pl': return '$count Rzeczy';
      case 'id': return '$count Barang';
      case 'th': return '$count สิ่งของ';
      case 'vi': return '$count Đồ dùng';
      case 'en':
      default: return '$count ${count == 1 ? "Item" : "Items"}';
    }
  }

  static String expensesCountLabel(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Harcama';
      case 'de': return '$count Ausgaben';
      case 'fr': return '$count Dépenses';
      case 'es': return '$count Gastos';
      case 'it': return '$count Spese';
      case 'pt': return '$count Despesas';
      case 'ru': return '$count Расходов';
      case 'zh': return '$count 笔开销';
      case 'ja': return '$count 件の支出';
      case 'ko': return '$count개 지출';
      case 'ar': return '$count مصاريف';
      case 'hi': return '$count खर्च';
      case 'nl': return '$count Uitgaven';
      case 'el': return '$count Έξοδα';
      case 'sv': return '$count Utgifter';
      case 'pl': return '$count Wydatków';
      case 'id': return '$count Pengeluaran';
      case 'th': return '$count รายจ่าย';
      case 'vi': return '$count Chi tiêu';
      case 'en':
      default: return '$count ${count == 1 ? "Expense" : "Expenses"}';
    }
  }

  static String documentsCountLabel(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Belge';
      case 'de': return '$count Dokumente';
      case 'fr': return '$count Documents';
      case 'es': return '$count Documentos';
      case 'it': return '$count Documenti';
      case 'pt': return '$count Documentos';
      case 'ru': return '$count Документов';
      case 'zh': return '$count 份文件';
      case 'ja': return '$count 件の書類';
      case 'ko': return '$count개 문서';
      case 'ar': return '$count وثائق';
      case 'hi': return '$count दस्तावेज़';
      case 'nl': return '$count Documenten';
      case 'el': return '$count Έγγραφα';
      case 'sv': return '$count Dokument';
      case 'pl': return '$count Dokumentów';
      case 'id': return '$count Dokumen';
      case 'th': return '$count เอกสาร';
      case 'vi': return '$count Tài liệu';
      case 'en':
      default: return '$count ${count == 1 ? "Document" : "Documents"}';
    }
  }

  static String syncStatusTitle(String lang, String status) {
    final clean = _cleanLang(lang);
    switch (status) {
      case 'upToDate':
        switch (clean) {
          case 'tr': return 'Eşleme Başarılı';
          case 'de': return 'Synchronisation erfolgreich';
          case 'fr': return 'Synchronisation réussie';
          case 'es': return 'Sincronización exitosa';
          case 'it': return 'Sincronizzazione riuscita';
          case 'pt': return 'Sincronização bem-sucedida';
          case 'ru': return 'Синхронизация успешна';
          case 'zh': return '同步成功';
          case 'ja': return '同期完了';
          case 'ko': return '동기화 성공';
          case 'ar': return 'تمت المزامنة بنجاح';
          case 'hi': return 'सिंक सफल';
          case 'nl': return 'Synchronisatie geslaagd';
          case 'el': return 'Συγχρονισμός επιτυχής';
          case 'sv': return 'Synkronisering slutförd';
          case 'pl': return 'Synchronizacja udana';
          case 'id': return 'Sinkronisasi Berhasil';
          case 'th': return 'ซิงค์ข้อมูลสำเร็จ';
          case 'vi': return 'Đồng bộ thành công';
          case 'en':
          default: return 'Sync Succeeded';
        }
      case 'noInternet':
        switch (clean) {
          case 'tr': return 'İnternet Yok';
          case 'de': return 'Kein Internet';
          case 'fr': return 'Pas d\'internet';
          case 'es': return 'Sin conexión';
          case 'it': return 'Nessuna connessione';
          case 'pt': return 'Sem conexão';
          case 'ru': return 'Нет интернета';
          case 'zh': return '无网络连接';
          case 'ja': return 'インターネット未接続';
          case 'ko': return '인터넷 연결 없음';
          case 'ar': return 'لا يوجد اتصال';
          case 'hi': return 'इंटरनेट नहीं है';
          case 'nl': return 'Geen internet';
          case 'el': return 'Χωρίς διαδίκτυο';
          case 'sv': return 'Inget internet';
          case 'pl': return 'Brak internetu';
          case 'id': return 'Tidak Ada Internet';
          case 'th': return 'ไม่มีอินเทอร์เน็ต';
          case 'vi': return 'Không có mạng';
          case 'en':
          default: return 'No Internet';
        }
      case 'failed':
      default:
        switch (clean) {
          case 'tr': return 'Eşleme Hatası';
          case 'de': return 'Synchronisationsfehler';
          case 'fr': return 'Erreur de synchronisation';
          case 'es': return 'Error de sincronización';
          case 'it': return 'Errore di sincronizzazione';
          case 'pt': return 'Erro de sincronização';
          case 'ru': return 'Ошибка синхронизации';
          case 'zh': return '同步失败';
          case 'ja': return '同期エラー';
          case 'ko': return '동기화 오류';
          case 'ar': return 'خطأ في المزامنة';
          case 'hi': return 'सिंक त्रुटि';
          case 'nl': return 'Synchronisatiefout';
          case 'el': return 'Σφάλμα συγχρονισμού';
          case 'sv': return 'Synkroniseringsfel';
          case 'pl': return 'Błąd synchronizacji';
          case 'id': return 'Gagal Sinkronisasi';
          case 'th': return 'เกิดข้อผิดพลาดในการซิงค์';
          case 'vi': return 'Lỗi đồng bộ';
          case 'en':
          default: return 'Sync Error';
        }
    }
  }

  static String itemsSyncedSuccess(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count kayıt bulutla eşitlendi';
      case 'de': return '$count Datensätze mit der Cloud synchronisiert';
      case 'fr': return '$count éléments synchronisés avec le cloud';
      case 'es': return '$count elementos sincronizados con la nube';
      case 'it': return '$count elementi sincronizzati con il cloud';
      case 'pt': return '$count itens sincronizados com a nuvem';
      case 'ru': return '$count записей синхронизировано с облаком';
      case 'zh': return '$count 条记录已同步至云端';
      case 'ja': return '$count 件のデータをクラウドと同期しました';
      case 'ko': return '$count개 항목이 클라우드와 동기화되었습니다';
      case 'ar': return 'تمت مزامنة $count عنصر مع السحابة';
      case 'hi': return '$count आइटम क्लाउड के साथ सिंक किए गए';
      case 'nl': return '$count items gesynchroniseerd met de cloud';
      case 'el': return '$count στοιχεία συγχρονίστηκαν με το cloud';
      case 'sv': return '$count objekt synkroniserade med molnet';
      case 'pl': return 'Zsynchronizowano $count elementów z chmurą';
      case 'id': return '$count item tersinkronisasi dengan cloud';
      case 'th': return 'ซิงค์ $count รายการกับคลาวด์เรียบร้อยแล้ว';
      case 'vi': return 'Đã đồng bộ $count mục với đám mây';
      case 'en':
      default: return '$count ${count == 1 ? "item" : "items"} synchronized with cloud';
    }
  }

  static String neverSynced(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Henüz yapılmadı';
      case 'de': return 'Noch nie synchronisiert';
      case 'fr': return 'Jamais synchronisé';
      case 'es': return 'Nunca sincronizado';
      case 'it': return 'Mai sincronizzato';
      case 'pt': return 'Nunca sincronizado';
      case 'ru': return 'Ни разу не синхронизировано';
      case 'zh': return '尚未同步';
      case 'ja': return '未同期';
      case 'ko': return '동기화된 적 없음';
      case 'ar': return 'لم تتم المزامنة بعد';
      case 'hi': return 'कभी सिंक नहीं हुआ';
      case 'nl': return 'Nog nooit gesynchroniseerd';
      case 'el': return 'Δεν έχει συγχρονιστεί ποτέ';
      case 'sv': return 'Aldrig synkroniserad';
      case 'pl': return 'Nigdy nie synchronizowano';
      case 'id': return 'Belum pernah disinkronkan';
      case 'th': return 'ยังไม่เคยซิงค์';
      case 'vi': return 'Chưa từng đồng bộ';
      case 'en':
      default: return 'Never synced';
    }
  }
}

