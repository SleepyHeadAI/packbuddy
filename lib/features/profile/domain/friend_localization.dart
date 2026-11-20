/// Complete 20-language native localization for Travel Buddies (Friends) ecosystem
class FriendLocalization {
  FriendLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String getFriends(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat Arkadaşları';
      case 'de': return 'Reisefreunde';
      case 'es': return 'Amigos de Viaje';
      case 'fr': return 'Compagnons de voyage';
      case 'it': return 'Amici di viaggio';
      case 'pt': return 'Amigos de Viagem';
      case 'ru': return 'Друзья по поездкам';
      case 'zh': return '旅行同伴';
      case 'ja': return '旅行仲間';
      case 'ko': return '여행 친구';
      case 'hi': return 'यात्रा मित्र';
      case 'ar': return 'أصدقاء السفر';
      case 'nl': return 'Reismaatjes';
      case 'el': return 'Ταξιδιωτικοί Φίλοι';
      case 'sv': return 'Reskompisar';
      case 'pl': return 'Towarzysze podróży';
      case 'id': return 'Teman Perjalanan';
      case 'th': return 'เพื่อนร่วมทาง';
      case 'vi': return 'Bạn đồng hành';
      case 'en':
      default: return 'Travel Buddies';
    }
  }

  static String getFriendRequests(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'İstekler';
      case 'de': return 'Anfragen';
      case 'es': return 'Solicitudes';
      case 'fr': return 'Demandes';
      case 'it': return 'Richieste';
      case 'pt': return 'Pedidos';
      case 'ru': return 'Запросы';
      case 'zh': return '好友请求';
      case 'ja': return 'リクエスト';
      case 'ko': return '친구 요청';
      case 'hi': return 'अनुरोध';
      case 'ar': return 'طلبات الصداقة';
      case 'nl': return 'Verzoeken';
      case 'el': return 'Αιτήματα';
      case 'sv': return 'Förfrågningar';
      case 'pl': return 'Zaproszenia';
      case 'id': return 'Permintaan';
      case 'th': return 'คำขอ';
      case 'vi': return 'Lời mời';
      case 'en':
      default: return 'Requests';
    }
  }

  static String getAddFriend(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Arkadaş Ekle';
      case 'de': return 'Freund hinzufügen';
      case 'es': return 'Añadir Amigo';
      case 'fr': return 'Ajouter un ami';
      case 'it': return 'Aggiungi amico';
      case 'pt': return 'Adicionar Amigo';
      case 'ru': return 'Добавить друга';
      case 'zh': return '添加好友';
      case 'ja': return '友達を追加';
      case 'ko': return '친구 추가';
      case 'hi': return 'मित्र जोड़ें';
      case 'ar': return 'إضافة صديق';
      case 'nl': return 'Vriend toevoegen';
      case 'el': return 'Προσθήκη Φίλου';
      case 'sv': return 'Lägg till vän';
      case 'pl': return 'Dodaj znajomego';
      case 'id': return 'Tambah Teman';
      case 'th': return 'เพิ่มเพื่อน';
      case 'vi': return 'Thêm bạn';
      case 'en':
      default: return 'Add Buddy';
    }
  }

  static String getSearchHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return '@kullaniciadi ile ara...';
      case 'de': return 'Suche nach @benutzername...';
      case 'es': return 'Buscar por @usuario...';
      case 'fr': return 'Rechercher par @nom...';
      case 'it': return 'Cerca per @nomeutente...';
      case 'pt': return 'Buscar por @usuario...';
      case 'ru': return 'Поиск по @имени...';
      case 'zh': return '通过 @用户名 搜索...';
      case 'ja': return '@ユーザー名で検索...';
      case 'ko': return '@사용자이름 으로 검색...';
      case 'hi': return '@यूज़रनेम से खोजें...';
      case 'ar': return 'ابحث عبر @اسم_المستخدم...';
      case 'nl': return 'Zoek op @gebruikersnaam...';
      case 'el': return 'Αναζήτηση με @όνομα...';
      case 'sv': return 'Sök med @användarnamn...';
      case 'pl': return 'Szukaj po @nazwa_użytkownika...';
      case 'id': return 'Cari dengan @nama_pengguna...';
      case 'th': return 'ค้นหาด้วย @ชื่อผู้ใช้...';
      case 'vi': return 'Tìm kiếm theo @tên_người_dùng...';
      case 'en':
      default: return 'Search by @username...';
    }
  }

  static String getSendRequest(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'İstek Gönder';
      case 'de': return 'Anfrage senden';
      case 'es': return 'Enviar Solicitud';
      case 'fr': return 'Envoyer une demande';
      case 'it': return 'Invia richiesta';
      case 'pt': return 'Enviar Pedido';
      case 'ru': return 'Отправить запрос';
      case 'zh': return '发送请求';
      case 'ja': return 'リクエストを送信';
      case 'ko': return '요청 보내기';
      case 'hi': return 'अनुरोध भेजें';
      case 'ar': return 'إرسال طلب';
      case 'nl': return 'Verzoek sturen';
      case 'el': return 'Αποστολή αιτήματος';
      case 'sv': return 'Skicka förfrågan';
      case 'pl': return 'Wyślij zaproszenie';
      case 'id': return 'Kirim Permintaan';
      case 'th': return 'ส่งคำขอ';
      case 'vi': return 'Gửi lời mời';
      case 'en':
      default: return 'Send Request';
    }
  }

  static String getRequestSent(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'İstek Gönderildi';
      case 'de': return 'Anfrage gesendet';
      case 'es': return 'Solicitud Enviada';
      case 'fr': return 'Demande envoyée';
      case 'it': return 'Richiesta inviata';
      case 'pt': return 'Pedido Enviado';
      case 'ru': return 'Запрос отправлен';
      case 'zh': return '已发送请求';
      case 'ja': return '送信済み';
      case 'ko': return '요청됨';
      case 'hi': return 'अनुरोध भेजा गया';
      case 'ar': return 'تم إرسال الطلب';
      case 'nl': return 'Verzoek verzonden';
      case 'el': return 'Το αίτημα στάλθηκε';
      case 'sv': return 'Förfrågan skickad';
      case 'pl': return 'Wysłano zaproszenie';
      case 'id': return 'Permintaan Terkirim';
      case 'th': return 'ส่งคำขอแล้ว';
      case 'vi': return 'Đã gửi lời mời';
      case 'en':
      default: return 'Request Sent';
    }
  }

  static String getAccept(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kabul Et';
      case 'de': return 'Annehmen';
      case 'es': return 'Aceptar';
      case 'fr': return 'Accepter';
      case 'it': return 'Accetta';
      case 'pt': return 'Aceitar';
      case 'ru': return 'Принять';
      case 'zh': return '接受';
      case 'ja': return '承認';
      case 'ko': return '수락';
      case 'hi': return 'स्वीकार करें';
      case 'ar': return 'قبول';
      case 'nl': return 'Accepteren';
      case 'el': return 'Αποδοχή';
      case 'sv': return 'Acceptera';
      case 'pl': return 'Zaakceptuj';
      case 'id': return 'Terima';
      case 'th': return 'ยอมรับ';
      case 'vi': return 'Chấp nhận';
      case 'en':
      default: return 'Accept';
    }
  }

  static String getDecline(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Reddet';
      case 'de': return 'Ablehnen';
      case 'es': return 'Rechazar';
      case 'fr': return 'Refuser';
      case 'it': return 'Rifiuta';
      case 'pt': return 'Recusar';
      case 'ru': return 'Отклонить';
      case 'zh': return '拒绝';
      case 'ja': return '拒否';
      case 'ko': return '거절';
      case 'hi': return 'अस्वीकार करें';
      case 'ar': return 'رفض';
      case 'nl': return 'Weigeren';
      case 'el': return 'Απόρριψη';
      case 'sv': return 'Avvisa';
      case 'pl': return 'Odrzuć';
      case 'id': return 'Tolak';
      case 'th': return 'ปฏิเสธ';
      case 'vi': return 'Từ chối';
      case 'en':
      default: return 'Decline';
    }
  }

  static String getCancelRequest(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'İsteği İptal Et';
      case 'de': return 'Anfrage abbrechen';
      case 'es': return 'Cancelar Solicitud';
      case 'fr': return 'Annuler la demande';
      case 'it': return 'Annulla richiesta';
      case 'pt': return 'Cancelar Pedido';
      case 'ru': return 'Отменить запрос';
      case 'zh': return '取消请求';
      case 'ja': return 'リクエストを取消';
      case 'ko': return '요청 취소';
      case 'hi': return 'अनुरोध रद्द करें';
      case 'ar': return 'إلغاء الطلب';
      case 'nl': return 'Verzoek annuleren';
      case 'el': return 'Ακύρωση αιτήματος';
      case 'sv': return 'Avbryt förfrågan';
      case 'pl': return 'Anuluj zaproszenie';
      case 'id': return 'Batalkan Permintaan';
      case 'th': return 'ยกเลิกคำขอ';
      case 'vi': return 'Hủy lời mời';
      case 'en':
      default: return 'Cancel Request';
    }
  }

  static String getRemoveFriend(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Arkadaşlıktan Çıkar';
      case 'de': return 'Freund entfernen';
      case 'es': return 'Eliminar de Amigos';
      case 'fr': return 'Retirer des amis';
      case 'it': return 'Rimuovi dagli amici';
      case 'pt': return 'Remover Amigo';
      case 'ru': return 'Удалить из друзей';
      case 'zh': return '删除好友';
      case 'ja': return '友達を解除';
      case 'ko': return '친구 삭제';
      case 'hi': return 'मित्र हटाएं';
      case 'ar': return 'إزالة الصديق';
      case 'nl': return 'Vriend verwijderen';
      case 'el': return 'Αφαίρεση φίλου';
      case 'sv': return 'Ta bort vän';
      case 'pl': return 'Usuń znajomego';
      case 'id': return 'Hapus Teman';
      case 'th': return 'ลบเพื่อน';
      case 'vi': return 'Xóa bạn';
      case 'en':
      default: return 'Remove Buddy';
    }
  }

  static String getNoFriendsTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Henüz Seyahat Arkadaşınız Yok';
      case 'de': return 'Noch keine Reisefreunde';
      case 'es': return 'Aún no tienes amigos de viaje';
      case 'fr': return 'Pas encore de compagnons';
      case 'it': return 'Nessun amico di viaggio';
      case 'pt': return 'Ainda sem amigos de viagem';
      case 'ru': return 'Пока нет друзей по поездкам';
      case 'zh': return '暂无旅行同伴';
      case 'ja': return 'まだ旅行仲間がいません';
      case 'ko': return '아직 여행 친구가 없습니다';
      case 'hi': return 'अभी कोई यात्रा मित्र नहीं है';
      case 'ar': return 'لا يوجد أصدقاء سفر حتى الآن';
      case 'nl': return 'Nog geen reismaatjes';
      case 'el': return 'Δεν υπάρχουν ακόμη ταξιδιωτικοί φίλοι';
      case 'sv': return 'Inga reskompisar än';
      case 'pl': return 'Brak towarzyszy podróży';
      case 'id': return 'Belum ada teman perjalanan';
      case 'th': return 'ยังไม่มีเพื่อนร่วมทาง';
      case 'vi': return 'Chưa có bạn đồng hành';
      case 'en':
      default: return 'No Travel Buddies Yet';
    }
  }

  static String getNoFriendsSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Arkadaşlarınızı kullanıcı adıyla arayabilir veya kişisel QR kodunuzu paylaşabilirsiniz.';
      case 'de': return 'Suche Freunde mit ihrem Benutzernamen oder teile deinen persönlichen QR-Code.';
      case 'es': return 'Busca amigos con su nombre de usuario o comparte tu código QR personal.';
      case 'fr': return 'Recherchez vos amis par leur nom ou partagez votre code QR personnel.';
      case 'it': return 'Cerca amici per nome utente o condividi il tuo codice QR personale.';
      case 'pt': return 'Pesquise amigos pelo nome de usuário ou compartilhe seu código QR pessoal.';
      case 'ru': return 'Ищите друзей по имени пользователя или поделитесь своим QR-кодом.';
      case 'zh': return '通过用户名搜索好友，或分享您的个人二维码。';
      case 'ja': return 'ユーザー名で友達を検索するか、個人のQRコードを共有してください。';
      case 'ko': return '사용자 이름으로 친구를 찾거나 개인 QR 코드를 공유하세요.';
      case 'hi': return 'उपयोगकर्ता नाम से मित्रों को खोजें या अपना व्यक्तिगत क्यूआर कोड साझा करें।';
      case 'ar': return 'ابحث عن أصدقائك باسم المستخدم أو شارك رمز QR الشخصي الخاص بك.';
      case 'nl': return 'Zoek vrienden op gebruikersnaam of deel je persoonlijke QR-code.';
      case 'el': return 'Αναζητήστε φίλους με το όνομα χρήστη ή κοινοποιήστε τον κωδικό QR σας.';
      case 'sv': return 'Sök efter vänner med användarnamn eller dela din personliga QR-kod.';
      case 'pl': return 'Wyszukaj znajomych po nazwie użytkownika lub udostępnij swój kod QR.';
      case 'id': return 'Cari teman dengan nama pengguna atau bagikan kode QR pribadi Anda.';
      case 'th': return 'ค้นหาเพื่อนด้วยชื่อผู้ใช้หรือแชร์คิวอาร์โค้ดส่วนตัวของคุณ';
      case 'vi': return 'Tìm bạn bè theo tên người dùng hoặc chia sẻ mã QR cá nhân của bạn.';
      case 'en':
      default: return 'Search for friends with their @username or share your personal invite QR code.';
    }
  }

  static String getNoRequests(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bekleyen arkadaşlık isteği yok';
      case 'de': return 'Keine ausstehenden Anfragen';
      case 'es': return 'No hay solicitudes pendientes';
      case 'fr': return 'Aucune demande en attente';
      case 'it': return 'Nessuna richiesta in sospeso';
      case 'pt': return 'Nenhum pedido pendente';
      case 'ru': return 'Нет ожидающих запросов';
      case 'zh': return '没有待处理的好友请求';
      case 'ja': return '保留中のリクエストはありません';
      case 'ko': return '대기 중인 친구 요청이 없습니다';
      case 'hi': return 'कोई लंबित अनुरोध नहीं';
      case 'ar': return 'لا توجد طلبات معلقة';
      case 'nl': return 'Geen openstaande verzoeken';
      case 'el': return 'Δεν υπάρχουν εκκρεμή αιτήματα';
      case 'sv': return 'Inga väntande förfrågningar';
      case 'pl': return 'Brak oczekujących zaproszeń';
      case 'id': return 'Tidak ada permintaan tertunda';
      case 'th': return 'ไม่มีคำขอที่รอดำเนินการ';
      case 'vi': return 'Không có lời mời nào đang chờ';
      case 'en':
      default: return 'No pending friend requests';
    }
  }

  static String getIncomingRequests(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Gelen İstekler';
      case 'de': return 'Eingehende Anfragen';
      case 'es': return 'Solicitudes Recibidas';
      case 'fr': return 'Demandes reçues';
      case 'it': return 'Richieste ricevute';
      case 'pt': return 'Pedidos Recebidos';
      case 'ru': return 'Входящие запросы';
      case 'zh': return '收到的请求';
      case 'ja': return '受信したリクエスト';
      case 'ko': return '받은 요청';
      case 'hi': return 'प्राप्त अनुरोध';
      case 'ar': return 'الطلبات الواردة';
      case 'nl': return 'Inkomende verzoeken';
      case 'el': return 'Εισερχόμενα αιτήματα';
      case 'sv': return 'Inkommande förfrågningar';
      case 'pl': return 'Otrzymane zaproszenia';
      case 'id': return 'Permintaan Masuk';
      case 'th': return 'คำขอที่ได้รับ';
      case 'vi': return 'Lời mời đã nhận';
      case 'en':
      default: return 'Incoming Requests';
    }
  }

  static String getOutgoingRequests(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Gönderilen İstekler';
      case 'de': return 'Gesendete Anfragen';
      case 'es': return 'Solicitudes Enviadas';
      case 'fr': return 'Demandes envoyées';
      case 'it': return 'Richieste inviate';
      case 'pt': return 'Pedidos Enviados';
      case 'ru': return 'Исходящие запросы';
      case 'zh': return '已发出的请求';
      case 'ja': return '送信したリクエスト';
      case 'ko': return '보낸 요청';
      case 'hi': return 'भेजे गए अनुरोध';
      case 'ar': return 'الطلبات الصادرة';
      case 'nl': return 'Verzonden verzoeken';
      case 'el': return 'Απεσταλμένα αιτήματα';
      case 'sv': return 'Skickade förfrågningar';
      case 'pl': return 'Wysłane zaproszenia';
      case 'id': return 'Permintaan Terkirim';
      case 'th': return 'คำขอที่ส่งแล้ว';
      case 'vi': return 'Lời mời đã gửi';
      case 'en':
      default: return 'Outgoing Requests';
    }
  }

  static String getMyQrCode(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'QR Kodum & Davet Linki';
      case 'de': return 'Mein QR-Code & Einladungslink';
      case 'es': return 'Mi Código QR & Enlace';
      case 'fr': return 'Mon QR Code & Lien';
      case 'it': return 'Il mio codice QR & Link';
      case 'pt': return 'Meu Código QR & Link';
      case 'ru': return 'Мой QR-код и ссылка';
      case 'zh': return '我的二维码和邀请链接';
      case 'ja': return 'マイQRコード & 招待リンク';
      case 'ko': return '내 QR 코드 및 초대 링크';
      case 'hi': return 'मेरा क्यूआर कोड और लिंक';
      case 'ar': return 'رمز QR ورابط الدعوة';
      case 'nl': return 'Mijn QR-code & uitnodigingslink';
      case 'el': return 'Ο QR κωδικός & ο σύνδεσμός μου';
      case 'sv': return 'Min QR-kod & inbjudningslänk';
      case 'pl': return 'Mój kod QR i link';
      case 'id': return 'Kode QR & Tautan Saya';
      case 'th': return 'คิวอาร์โค้ด & ลิงก์ของฉัน';
      case 'vi': return 'Mã QR & Liên kết của tôi';
      case 'en':
      default: return 'My QR Code & Invite Link';
    }
  }

  static String getShareInviteLink(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Davet Bağlantısını Paylaş';
      case 'de': return 'Einladungslink teilen';
      case 'es': return 'Compartir Enlace de Invitación';
      case 'fr': return "Partager le lien d'invitation";
      case 'it': return 'Condividi link di invito';
      case 'pt': return 'Compartilhar Link de Convite';
      case 'ru': return 'Поделиться ссылкой-приглашением';
      case 'zh': return '分享邀请链接';
      case 'ja': return '招待リンクを共有';
      case 'ko': return '초대 링크 공유';
      case 'hi': return 'आमंत्रण लिंक साझा करें';
      case 'ar': return 'مشاركة رابط الدعوة';
      case 'nl': return 'Uitnodigingslink delen';
      case 'el': return 'Κοινοποίηση συνδέσμου';
      case 'sv': return 'Dela inbjudningslänk';
      case 'pl': return 'Udostępnij link z zaproszeniem';
      case 'id': return 'Bagikan Tautan Undangan';
      case 'th': return 'แชร์ลิงก์คำเชิญ';
      case 'vi': return 'Chia sẻ liên kết mời';
      case 'en':
      default: return 'Share Invite Link';
    }
  }

  static String getCopy(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kopyala';
      case 'de': return 'Kopieren';
      case 'es': return 'Copiar';
      case 'fr': return 'Copier';
      case 'it': return 'Copia';
      case 'pt': return 'Copiar';
      case 'ru': return 'Копировать';
      case 'zh': return '复制';
      case 'ja': return 'コピー';
      case 'ko': return '복사';
      case 'hi': return 'कॉपी करें';
      case 'ar': return 'نسخ';
      case 'nl': return 'Kopiëren';
      case 'el': return 'Αντιγραφή';
      case 'sv': return 'Kopiera';
      case 'pl': return 'Kopiuj';
      case 'id': return 'Salin';
      case 'th': return 'คัดลอก';
      case 'vi': return 'Sao chép';
      case 'en':
      default: return 'Copy';
    }
  }

  static String getShare(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Paylaş';
      case 'de': return 'Teilen';
      case 'es': return 'Compartir';
      case 'fr': return 'Partager';
      case 'it': return 'Condividi';
      case 'pt': return 'Compartilhar';
      case 'ru': return 'Поделиться';
      case 'zh': return '分享';
      case 'ja': return '共有';
      case 'ko': return '공유';
      case 'hi': return 'साझा करें';
      case 'ar': return 'مشاركة';
      case 'nl': return 'Delen';
      case 'el': return 'Κοινοποίηση';
      case 'sv': return 'Dela';
      case 'pl': return 'Udostępnij';
      case 'id': return 'Bagikan';
      case 'th': return 'แชร์';
      case 'vi': return 'Chia sẻ';
      case 'en':
      default: return 'Share';
    }
  }

  static String getCopyLink(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Linki Kopyala';
      case 'de': return 'Link kopieren';
      case 'es': return 'Copiar enlace';
      case 'fr': return 'Copier le lien';
      case 'it': return 'Copia link';
      case 'pt': return 'Copiar Link';
      case 'ru': return 'Копировать ссылку';
      case 'zh': return '复制链接';
      case 'ja': return 'リンクをコピー';
      case 'ko': return '링크 복사';
      case 'hi': return 'लिंक कॉपी करें';
      case 'ar': return 'نسخ الرابط';
      case 'nl': return 'Link kopiëren';
      case 'el': return 'Αντιγραφή συνδέσμου';
      case 'sv': return 'Kopiera länk';
      case 'pl': return 'Kopiuj link';
      case 'id': return 'Salin Tautan';
      case 'th': return 'คัดลอกลิงก์';
      case 'vi': return 'Sao chép liên kết';
      case 'en':
      default: return 'Copy Link';
    }
  }

  static String getShareLink(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Linki Paylaş';
      case 'de': return 'Link teilen';
      case 'es': return 'Compartir enlace';
      case 'fr': return 'Partager le lien';
      case 'it': return 'Condividi link';
      case 'pt': return 'Compartilhar Link';
      case 'ru': return 'Поделиться ссылкой';
      case 'zh': return '分享链接';
      case 'ja': return 'リンクを共有';
      case 'ko': return '링크 공유';
      case 'hi': return 'लिंक साझा करें';
      case 'ar': return 'مشاركة الرابط';
      case 'nl': return 'Link delen';
      case 'el': return 'Κοινοποίηση συνδέσμου';
      case 'sv': return 'Dela länk';
      case 'pl': return 'Udostępnij link';
      case 'id': return 'Bagikan Tautan';
      case 'th': return 'แชร์ลิงก์';
      case 'vi': return 'Chia sẻ liên kết';
      case 'en':
      default: return 'Share Link';
    }
  }

  static String getCopiedToClipboard(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bağlantı panoya kopyalandı ✨';
      case 'de': return 'Link in Zwischenablage kopiert ✨';
      case 'es': return 'Enlace copiado al portapapeles ✨';
      case 'fr': return 'Lien copié dans le presse-papiers ✨';
      case 'it': return 'Link copiato negli appunti ✨';
      case 'pt': return 'Link copiado para a área de transferência ✨';
      case 'ru': return 'Ссылка скопирована в буфер ✨';
      case 'zh': return '链接已复制到剪贴板 ✨';
      case 'ja': return 'リンクをクリップボードにコピーしました ✨';
      case 'ko': return '링크가 클립보드에 복사되었습니다 ✨';
      case 'hi': return 'लिंक क्लिपबोर्ड पर कॉपी किया गया ✨';
      case 'ar': return 'تم نسخ الرابط إلى الحافظة ✨';
      case 'nl': return 'Link gekopieerd naar klembord ✨';
      case 'el': return 'Ο σύνδεσμος αντιγράφηκε ✨';
      case 'sv': return 'Länk kopierad till urklipp ✨';
      case 'pl': return 'Skopiowano link do schowka ✨';
      case 'id': return 'Tautan disalin ke papan klip ✨';
      case 'th': return 'คัดลอกลิงก์ไปยังคลิปบอร์ดแล้ว ✨';
      case 'vi': return 'Đã sao chép liên kết vào khay nhớ tạm ✨';
      case 'en':
      default: return 'Link copied to clipboard ✨';
    }
  }

  static String getUserNotFound(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bu kullanıcı adına sahip seyahat sever bulunamadı';
      case 'de': return 'Kein Reisender mit diesem Benutzernamen gefunden';
      case 'es': return 'No se encontró ningún viajero con ese nombre de usuario';
      case 'fr': return "Aucun voyageur trouvé avec ce nom d'utilisateur";
      case 'it': return 'Nessun viaggiatore trovato con questo nome utente';
      case 'pt': return 'Nenhum viajante encontrado com este nome de usuário';
      case 'ru': return 'Путешественник с таким именем не найден';
      case 'zh': return '未找到该用户名的旅行者';
      case 'ja': return 'そのユーザー名の旅行者が見つかりません';
      case 'ko': return '해당 사용자 이름의 여행자를 찾을 수 없습니다';
      case 'hi': return 'इस यूज़रनेम वाला कोई यात्री नहीं मिला';
      case 'ar': return 'لم يتم العثور على مسافر بهذا الاسم';
      case 'nl': return 'Geen reiziger gevonden met deze gebruikersnaam';
      case 'el': return 'Δεν βρέθηκε ταξιδιώτης με αυτό το όνομα χρήστη';
      case 'sv': return 'Ingen resenär hittades med det användarnamnet';
      case 'pl': return 'Nie znaleziono podróżnika o tej nazwie';
      case 'id': return 'Tidak ada wisatawan dengan nama pengguna ini';
      case 'th': return 'ไม่พบผู้เดินทางด้วยชื่อผู้ใช้นี้';
      case 'vi': return 'Không tìm thấy người dùng nào có tên này';
      case 'en':
      default: return 'No traveler found with that @username';
    }
  }

  static String getAlreadyFriends(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Zaten seyahat arkadaşısınız ✨';
      case 'de': return 'Ihr seid bereits Reisefreunde ✨';
      case 'es': return 'Ya son amigos de viaje ✨';
      case 'fr': return 'Vous êtes déjà compagnons de voyage ✨';
      case 'it': return 'Siete già amici di viaggio ✨';
      case 'pt': return 'Vocês já são amigos de viagem ✨';
      case 'ru': return 'Вы уже друзья по поездкам ✨';
      case 'zh': return '你们已经是旅行同伴了 ✨';
      case 'ja': return 'すでに旅行仲間です ✨';
      case 'ko': return '이미 여행 친구입니다 ✨';
      case 'hi': return 'आप पहले से ही यात्रा मित्र हैं ✨';
      case 'ar': return 'أنتم بالفعل أصدقاء سفر ✨';
      case 'nl': return 'Jullie zijn al reismaatjes ✨';
      case 'el': return 'Είστε ήδη ταξιδιωτικοί φίλοι ✨';
      case 'sv': return 'Ni är redan reskompisar ✨';
      case 'pl': return 'Już jesteście towarzyszami podróży ✨';
      case 'id': return 'Anda sudah menjadi teman perjalanan ✨';
      case 'th': return 'คุณเป็นเพื่อนร่วมทางกันอยู่แล้ว ✨';
      case 'vi': return 'Các bạn đã là bạn đồng hành ✨';
      case 'en':
      default: return 'You are already travel buddies ✨';
    }
  }

  static String getCannotAddSelf(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kendinizi arkadaş olarak ekleyemezsiniz';
      case 'de': return 'Du kannst dich nicht selbst hinzufügen';
      case 'es': return 'No puedes agregarte a ti mismo';
      case 'fr': return 'Vous ne pouvez pas vous ajouter vous-même';
      case 'it': return 'Non puoi aggiungere te stesso';
      case 'pt': return 'Você não pode adicionar a si mesmo';
      case 'ru': return 'Вы не можете добавить себя в друзья';
      case 'zh': return '您不能添加自己为好友';
      case 'ja': return '自分自身を友達に追加することはできません';
      case 'ko': return '자신을 친구로 추가할 수 없습니다';
      case 'hi': return 'आप स्वयं को मित्र के रूप में नहीं जोड़ सकते';
      case 'ar': return 'لا يمكنك إضافة نفسك كصدیق';
      case 'nl': return 'Je kunt jezelf niet toevoegen';
      case 'el': return 'Δεν μπορείτε να προσθέσετε τον εαυτό σας';
      case 'sv': return 'Du kan inte lägga till dig själv';
      case 'pl': return 'Nie możesz dodać siebie do znajomych';
      case 'id': return 'Anda tidak dapat menambahkan diri sendiri';
      case 'th': return 'คุณไม่สามารถเพิ่มตัวเองเป็นเพื่อนได้';
      case 'vi': return 'Bạn không thể tự kết bạn với chính mình';
      case 'en':
      default: return 'You cannot add yourself as a buddy';
    }
  }

  static String getDashboardBuddiesCardTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat Arkadaşları';
      case 'de': return 'Reise-Buddies';
      case 'es': return 'Compañeros de Viaje';
      case 'fr': return 'Compagnons de Route';
      case 'it': return 'Amici di Viaggio';
      case 'pt': return 'Companheiros de Viagem';
      case 'ru': return 'Попутчики';
      case 'zh': return '旅行同伴';
      case 'ja': return '旅の仲間';
      case 'ko': return '여행 버디';
      case 'hi': return 'यात्रा मित्र';
      case 'ar': return 'أصدقاء السفر';
      case 'nl': return 'Reismaatjes';
      case 'el': return 'Ταξιδιωτικοί Φίλοι';
      case 'sv': return 'Reskompisar';
      case 'pl': return 'Towarzysze Podróży';
      case 'id': return 'Teman Perjalanan';
      case 'th': return 'เพื่อนร่วมทาง';
      case 'vi': return 'Bạn đồng hành';
      case 'en':
      default: return 'Travel Buddies';
    }
  }

  static String getMutualCountries(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Ortak Ülke Gezdiniz ✨';
      case 'de': return '$count gemeinsame Länder bereist ✨';
      case 'es': return '$count países visitados en común ✨';
      case 'fr': return '$count pays visités en commun ✨';
      case 'it': return '$count paesi visitati in comune ✨';
      case 'pt': return '$count países visitados em comum ✨';
      case 'ru': return '$count общих посещенных стран ✨';
      case 'zh': return '共同访问了 $count 个国家 ✨';
      case 'ja': return '共通して訪れた国 $count カ国 ✨';
      case 'ko': return '공통 방문 국가 $count개 ✨';
      case 'hi': return '$count साझा देशों की यात्रा की ✨';
      case 'ar': return '$count دول مشتركة قمتما بزيارتها ✨';
      case 'nl': return '$count gemeenschappelijke landen bezocht ✨';
      case 'el': return '$count κοινές χώρες που επισκεφτήκατε ✨';
      case 'sv': return '$count gemensamma länder besökta ✨';
      case 'pl': return '$count wspólnie odwiedzonych krajów ✨';
      case 'id': return '$count negara bersama telah dikunjungi ✨';
      case 'th': return 'เที่ยวประเทศร่วมกัน $count ประเทศ ✨';
      case 'vi': return 'Đã cùng đến $count quốc gia ✨';
      case 'en':
      default: return '$count Mutual Countries Visited ✨';
    }
  }

  static String getNoMutualCountries(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Henüz ortak bir ülkeye gitmediniz. Birlikte bir rota keşfedin! 🗺️';
      case 'de': return 'Noch keine gemeinsamen Länder. Entdeckt zusammen eine neue Route! 🗺️';
      case 'es': return 'Aún no tienen países en común. ¡Descubran una nueva ruta juntos! 🗺️';
      case 'fr': return 'Pas encore de pays en commun. Explorez un nouvel itinéraire ensemble ! 🗺️';
      case 'it': return 'Nessun paese in comune ancora. Scoprite una nuova rotta insieme! 🗺️';
      case 'pt': return 'Ainda não têm países em comum. Descubram um novo roteiro juntos! 🗺️';
      case 'ru': return 'Пока нет общих стран. Откройте новый маршрут вместе! 🗺️';
      case 'zh': return '目前还没有共同去过的国家。一起开启一段新旅程吧！🗺️';
      case 'ja': return '共通の旅行先はまだありません。一緒に新しいルートを見つけましょう！🗺️';
      case 'ko': return '아직 공통으로 방문한 국가가 없습니다. 함께 새로운 여정을 떠나보세요! 🗺️';
      case 'hi': return 'अभी कोई साझा देश नहीं है। एक साथ नया मार्ग खोजें! 🗺️';
      case 'ar': return 'لا توجد دول مشتركة حتى الآن. خططا لرحلة معًا! 🗺️';
      case 'nl': return 'Nog geen gemeenschappelijke landen. Verken samen een nieuwe route! 🗺️';
      case 'el': return 'Δεν υπάρχουν ακόμη κοινές χώρες. Εξερευνήστε μια διαδρομή μαζί! 🗺️';
      case 'sv': return 'Inga gemensamma länder än. Planera en resa tillsammans! 🗺️';
      case 'pl': return 'Brak wspólnych krajów. Zaplanujcie wspólną podróż! 🗺️';
      case 'id': return 'Belum ada negara yang sama. Rencanakan perjalanan bersama! 🗺️';
      case 'th': return 'ยังไม่มีประเทศร่วมกัน วางแผนการเดินทางด้วยกันเลย! 🗺️';
      case 'vi': return 'Chưa có quốc gia chung nào. Hãy cùng lên kế hoạch cho một hành trình mới! 🗺️';
      case 'en':
      default: return 'No mutual countries yet. Plan a journey together! 🗺️';
    }
  }

  static String getInviteToTrip(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahate Davet Et';
      case 'de': return 'Zu Reise einladen';
      case 'es': return 'Invitar a un Viaje';
      case 'fr': return 'Inviter à un voyage';
      case 'it': return 'Invita a un viaggio';
      case 'pt': return 'Convidar para Viagem';
      case 'ru': return 'Пригласить в поездку';
      case 'zh': return '邀请加入行程';
      case 'ja': return '旅行に招待';
      case 'ko': return '여행에 초대';
      case 'hi': return 'यात्रा में आमंत्रित करें';
      case 'ar': return 'دعوة إلى الرحلة';
      case 'nl': return 'Uitnodigen voor reis';
      case 'el': return 'Πρόσκληση σε ταξίδι';
      case 'sv': return 'Bjud in till resa';
      case 'pl': return 'Zaproś do podróży';
      case 'id': return 'Undang ke Perjalanan';
      case 'th': return 'เชิญเข้าร่วมทริป';
      case 'vi': return 'Mời vào chuyến đi';
      case 'en':
      default: return 'Invite to Trip';
    }
  }

  static String getTravelAffinity(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat Uyumu & Ortak Noktalar';
      case 'de': return 'Reise-Affinität & Gemeinsamkeiten';
      case 'es': return 'Afinidad y Puntos en Común';
      case 'fr': return 'Affinité de voyage & Points communs';
      case 'it': return 'Affinità di viaggio e Punti in comune';
      case 'pt': return 'Afinidade de Viagem & Pontos em Comum';
      case 'ru': return 'Совместимость и общие места';
      case 'zh': return '旅行契合度与共同点';
      case 'ja': return '旅行の親和性と共通点';
      case 'ko': return '여행 궁합 & 공통점';
      case 'hi': return 'यात्रा तालमेल और समानताएं';
      case 'ar': return 'توافق السفر والنقاط المشتركة';
      case 'nl': return 'Reisaffiniteit & raakvlakken';
      case 'el': return 'Ταξιδιωτική συμβατότητα & κοινά σημεία';
      case 'sv': return 'Reskompatibilitet & gemensamma intressen';
      case 'pl': return 'Dopasowanie w podróży i cechy wspólne';
      case 'id': return 'Afinitas Perjalanan & Kesamaan';
      case 'th': return 'ความเข้ากันได้ในการเดินทางและจุดร่วม';
      case 'vi': return 'Mức độ hợp gu du lịch & điểm chung';
      case 'en':
      default: return 'Travel Affinity & Mutuals';
    }
  }

  static String getAddFromFriends(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Arkadaşlarımdan Ekle';
      case 'de': return 'Aus Freunden hinzufügen';
      case 'es': return 'Añadir de Amigos';
      case 'fr': return 'Ajouter depuis les amis';
      case 'it': return 'Aggiungi da amici';
      case 'pt': return 'Adicionar de Amigos';
      case 'ru': return 'Добавить из друзей';
      case 'zh': return '从好友中添加';
      case 'ja': return '友達から追加';
      case 'ko': return '친구 목록에서 추가';
      case 'hi': return 'मित्रों से जोड़ें';
      case 'ar': return 'إضافة من الأصدقاء';
      case 'nl': return 'Toevoegen via vrienden';
      case 'el': return 'Προσθήκη από φίλους';
      case 'sv': return 'Lägg till från vänner';
      case 'pl': return 'Dodaj ze znajomych';
      case 'id': return 'Tambah dari Teman';
      case 'th': return 'เพิ่มจากเพื่อน';
      case 'vi': return 'Thêm từ danh sách bạn';
      case 'en':
      default: return 'Add from Friends';
    }
  }

  static String getAssignedTo(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kim Getirecek?';
      case 'de': return 'Wer bringt das mit?';
      case 'es': return '¿Quién lo lleva?';
      case 'fr': return "Qui l'apporte ?";
      case 'it': return 'Chi lo porta?';
      case 'pt': return 'Quem vai levar?';
      case 'ru': return 'Кто возьмет?';
      case 'zh': return '谁来带？';
      case 'ja': return '誰が持参する？';
      case 'ko': return '누가 가져오나요?';
      case 'hi': return 'कौन लाएगा?';
      case 'ar': return 'من سيحضره؟';
      case 'nl': return 'Wie neemt dit mee?';
      case 'el': return 'Ποιος θα το φέρει;';
      case 'sv': return 'Vem tar med detta?';
      case 'pl': return 'Kto to przyniesie?';
      case 'id': return 'Siapa yang membawa ini?';
      case 'th': return 'ใครจะเป็นคนนำมา?';
      case 'vi': return 'Ai sẽ mang theo?';
      case 'en':
      default: return 'Who brings this?';
    }
  }

  static String getUnassigned(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Atanmamış';
      case 'de': return 'Nicht zugewiesen';
      case 'es': return 'Sin asignar';
      case 'fr': return 'Non assigné';
      case 'it': return 'Non assegnato';
      case 'pt': return 'Não atribuído';
      case 'ru': return 'Не назначено';
      case 'zh': return '未分配';
      case 'ja': return '未割り当て';
      case 'ko': return '미지정';
      case 'hi': return 'अनिर्दिष्ट';
      case 'ar': return 'غير محدد';
      case 'nl': return 'Niet toegewezen';
      case 'el': return 'Μη ανατεθειμένο';
      case 'sv': return 'Ej tilldelad';
      case 'pl': return 'Nieprzypisane';
      case 'id': return 'Belum Ditugaskan';
      case 'th': return 'ยังไม่ได้มอบหมาย';
      case 'vi': return 'Chưa phân công';
      case 'en':
      default: return 'Unassigned';
    }
  }

  static String getInvitedToTrip(String lang, String tripTitle) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$tripTitle seyahatine davet edildi! ✈️';
      case 'de': return 'Zu $tripTitle eingeladen! ✈️';
      case 'es': return '¡Invitado a $tripTitle! ✈️';
      case 'fr': return 'Invité à $tripTitle ! ✈️';
      case 'it': return 'Invitato a $tripTitle! ✈️';
      case 'pt': return 'Convidado para $tripTitle! ✈️';
      case 'ru': return 'Приглашен в $tripTitle! ✈️';
      case 'zh': return '已邀请加入 $tripTitle！✈️';
      case 'ja': return '$tripTitle に招待しました！✈️';
      case 'ko': return '$tripTitle 여행에 초대되었습니다! ✈️';
      case 'hi': return '$tripTitle यात्रा में आमंत्रित किया गया! ✈️';
      case 'ar': return 'تمت الدعوة إلى رحلة $tripTitle! ✈️';
      case 'nl': return 'Uitgenodigd voor $tripTitle! ✈️';
      case 'el': return 'Προσκλήθηκε στο ταξίδι $tripTitle! ✈️';
      case 'sv': return 'Inbjuden till resan $tripTitle! ✈️';
      case 'pl': return 'Zaproszono do podróży $tripTitle! ✈️';
      case 'id': return 'Diundang ke perjalanan $tripTitle! ✈️';
      case 'th': return 'ได้รับเชิญเข้าร่วมทริป $tripTitle! ✈️';
      case 'vi': return 'Đã mời vào chuyến đi $tripTitle! ✈️';
      case 'en':
      default: return 'Invited to $tripTitle! ✈️';
    }
  }

  static String getYou(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Siz';
      case 'de': return 'Du';
      case 'es': return 'Tú';
      case 'fr': return 'Vous';
      case 'it': return 'Tu';
      case 'pt': return 'Você';
      case 'ru': return 'Вы';
      case 'zh': return '你';
      case 'ja': return 'あなた';
      case 'ko': return '나';
      case 'hi': return 'आप';
      case 'ar': return 'أنت';
      case 'nl': return 'Jij';
      case 'el': return 'Εσείς';
      case 'sv': return 'Du';
      case 'pl': return 'Ty';
      case 'id': return 'Anda';
      case 'th': return 'คุณ';
      case 'vi': return 'Bạn';
      case 'en':
      default: return 'You';
    }
  }

  static String getBuddy(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Arkadaş';
      case 'de': return 'Freund';
      case 'es': return 'Amigo';
      case 'fr': return 'Ami';
      case 'it': return 'Amico';
      case 'pt': return 'Amigo';
      case 'ru': return 'Друг';
      case 'zh': return '好友';
      case 'ja': return '友達';
      case 'ko': return '친구';
      case 'hi': return 'मित्र';
      case 'ar': return 'صديق';
      case 'nl': return 'Vriend';
      case 'el': return 'Φίλος';
      case 'sv': return 'Vän';
      case 'pl': return 'Znajomy';
      case 'id': return 'Teman';
      case 'th': return 'เพื่อน';
      case 'vi': return 'Bạn bè';
      case 'en':
      default: return 'Buddy';
    }
  }

  static String getCancel(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Vazgeç';
      case 'de': return 'Abbrechen';
      case 'es': return 'Cancelar';
      case 'fr': return 'Annuler';
      case 'it': return 'Annulla';
      case 'pt': return 'Cancelar';
      case 'ru': return 'Отмена';
      case 'zh': return '取消';
      case 'ja': return 'キャンセル';
      case 'ko': return '취소';
      case 'hi': return 'रद्द करें';
      case 'ar': return 'إلغاء';
      case 'nl': return 'Annuleren';
      case 'el': return 'Άκυρο';
      case 'sv': return 'Avbryt';
      case 'pl': return 'Anuluj';
      case 'id': return 'Batal';
      case 'th': return 'ยกเลิก';
      case 'vi': return 'Hủy';
      case 'en':
      default: return 'Cancel';
    }
  }

  static String getRemoveFriendConfirm(String lang, String? name) {
    final friendName = (name != null && name.trim().isNotEmpty) ? name.trim() : null;
    switch (_cleanLang(lang)) {
      case 'tr': return '${friendName ?? "Bu gezgin"} seyahat arkadaşlarınızdan çıkarılsın mı?';
      case 'de': return 'Möchtest du ${friendName ?? "diesen Reisenden"} aus deinen Reisefreunden entfernen?';
      case 'es': return '¿Deseas eliminar a ${friendName ?? "este viajero"} de tus amigos de viaje?';
      case 'fr': return 'Voulez-vous retirer ${friendName ?? "ce voyageur"} de vos compagnons de voyage ?';
      case 'it': return 'Vuoi rimuovere ${friendName ?? "questo viaggiatore"} dai tuoi compagni di viaggio?';
      case 'pt': return 'Deseja remover ${friendName ?? "este viajante"} dos seus amigos de viagem?';
      case 'ru': return 'Удалить ${friendName ?? "этого путешественника"} из попутчиков?';
      case 'zh': return '确定要将 ${friendName ?? "此旅行者"} 从旅行同伴中移除吗？';
      case 'ja': return '${friendName ?? "この旅行者"} を旅行仲間から削除しますか？';
      case 'ko': return '${friendName ?? "이 여행자"}님을 여행 친구에서 삭제하시겠습니까?';
      case 'hi': return 'क्या आप ${friendName ?? "इस यात्री"} को अपने यात्रा मित्रों से हटाना चाहते हैं?';
      case 'ar': return 'هل تريد إزالة ${friendName ?? "هذا المسافر"} من قائمة أصدقاء السفر؟';
      case 'nl': return 'Wil je ${friendName ?? "deze reiziger"} verwijderen uit je reismaatjes?';
      case 'el': return 'Θέλετε να αφαιρέσετε τον ${friendName ?? "ταξιδιώτη"} από τους φίλους σας;';
      case 'sv': return 'Vill du ta bort ${friendName ?? "denna resenär"} från dina reskompisar?';
      case 'pl': return 'Czy na pewno chcesz usunąć użytkownika ${friendName ?? "tego podróżnika"} ze znajomych?';
      case 'id': return 'Hapus ${friendName ?? "wisatawan ini"} dari teman perjalanan Anda?';
      case 'th': return 'ต้องการลบ ${friendName ?? "ผู้เดินทางนี้"} ออกจากเพื่อนร่วมทางหรือไม่?';
      case 'vi': return 'Bạn có muốn xóa ${friendName ?? "người này"} khỏi danh sách bạn đồng hành?';
      case 'en':
      default: return 'Remove ${friendName ?? "this traveler"} from your travel buddies?';
    }
  }

  static String getNoPlannedTrips(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Henüz planlanmış bir seyahatiniz yok. Önce bir seyahat oluşturun! ✈️';
      case 'de': return 'Du hast noch keine geplanten Reisen. Erstelle zuerst eine Reise! ✈️';
      case 'es': return 'Aún no tienes viajes planificados. ¡Crea un viaje primero! ✈️';
      case 'fr': return "Vous n'avez pas encore de voyage planifié. Créez un voyage d'abord ! ✈️";
      case 'it': return 'Non hai ancora viaggi pianificati. Crea prima un viaggio! ✈️';
      case 'pt': return 'Você ainda não tem viagens planejadas. Crie uma viagem primeiro! ✈️';
      case 'ru': return 'У вас пока нет запланированных поездок. Сначала создайте поездку! ✈️';
      case 'zh': return '您还没有计划的行程。请先创建一个行程！✈️';
      case 'ja': return '予定されている旅行はまだありません。まず旅行を作成してください！✈️';
      case 'ko': return '아직 계획된 여행이 없습니다. 먼저 여행을 생성해 보세요! ✈️';
      case 'hi': return 'आपकी अभी कोई नियोजित यात्रा नहीं है। पहले एक यात्रा बनाएं! ✈️';
      case 'ar': return 'ليس لديك أي رحلات مخططة بعد. أنشئ رحلة أولاً! ✈️';
      case 'nl': return 'Je hebt nog geen geplande reizen. Maak eerst een reis aan! ✈️';
      case 'el': return 'Δεν έχετε προγραμματισμένα ταξίδια. Δημιουργήστε ένα ταξίδι πρώτα! ✈️';
      case 'sv': return 'Du har inga planerade resor än. Skapa en resa först! ✈️';
      case 'pl': return 'Nie masz jeszcze zaplanowanych podróży. Najpierw utwórz podróż! ✈️';
      case 'id': return 'Anda belum memiliki rencana perjalanan. Buat perjalanan terlebih dahulu! ✈️';
      case 'th': return 'คุณยังไม่มีทริปที่วางแผนไว้ สร้างทริปก่อนเลย! ✈️';
      case 'vi': return 'Bạn chưa có chuyến đi nào được lên kế hoạch. Hãy tạo chuyến đi trước! ✈️';
      case 'en':
      default: return 'You have no planned trips yet. Create a trip first! ✈️';
    }
  }

  static String getSelectTripToInvite(String lang, String? name) {
    final friendName = (name != null && name.trim().isNotEmpty) ? name.trim() : null;
    switch (_cleanLang(lang)) {
      case 'tr': return '${friendName ?? "Arkadaşınızı"} Hangi Seyahate Davet Etmek İstersiniz?';
      case 'de': return 'Zu welcher Reise möchtest du ${friendName ?? "deinen Freund"} einladen?';
      case 'es': return '¿A qué viaje te gustaría invitar a ${friendName ?? "tu amigo"}?';
      case 'fr': return 'À quel voyage souhaitez-vous inviter ${friendName ?? "votre ami"} ?';
      case 'it': return 'A quale viaggio vorresti invitare ${friendName ?? "il tuo amico"}?';
      case 'pt': return 'A qual viagem você deseja convidar ${friendName ?? "seu amigo"}?';
      case 'ru': return 'В какую поездку вы хотите пригласить ${friendName ?? "друга"}?';
      case 'zh': return '您想邀请 ${friendName ?? "好友"} 参加哪个行程？';
      case 'ja': return '${friendName ?? "友達"} をどの旅行に招待しますか？';
      case 'ko': return '${friendName ?? "친구"}님을 어떤 여행에 초대하시겠습니까?';
      case 'hi': return 'आप ${friendName ?? "अपने मित्र"} को किस यात्रा में आमंत्रित करना चाहते हैं?';
      case 'ar': return 'إلى أي رحلة ترغب في دعوة ${friendName ?? "صديقك"}؟';
      case 'nl': return 'Voor welke reis wil je ${friendName ?? "je vriend"} uitnodigen?';
      case 'el': return 'Σε ποιο ταξίδι θέλετε να προσκαλέσετε τον ${friendName ?? "φίλο σας"};';
      case 'sv': return 'Vilken resa vill du bjuda in ${friendName ?? "din vän"} till?';
      case 'pl': return 'Do której podróży chcesz zaprosić użytkownika ${friendName ?? "znajomego"}?';
      case 'id': return 'Perjalanan mana yang ingin Anda undang untuk ${friendName ?? "teman Anda"}?';
      case 'th': return 'คุณต้องการเชิญ ${friendName ?? "เพื่อนของคุณ"} เข้าร่วมทริปไหน?';
      case 'vi': return 'Bạn muốn mời ${friendName ?? "bạn bè"} tham gia chuyến đi nào?';
      case 'en':
      default: return 'Which trip would you like to invite ${friendName ?? "your buddy"} to?';
    }
  }

  static String getShareInviteText(String lang, String name, String url) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$name ile PackBuddy\'de seyahat arkadaşı ol! 🧳✈️\n$url';
      case 'de': return 'Werde Reisefreund auf PackBuddy mit $name! 🧳✈️\n$url';
      case 'es': return '¡Sé mi compañero de viaje en PackBuddy con $name! 🧳✈️\n$url';
      case 'fr': return 'Devenez compagnon de voyage sur PackBuddy avec $name ! 🧳✈️\n$url';
      case 'it': return 'Diventa compagno di viaggio su PackBuddy con $name! 🧳✈️\n$url';
      case 'pt': return 'Seja companheiro de viagem no PackBuddy com $name! 🧳✈️\n$url';
      case 'ru': return 'Станьте попутчиком в PackBuddy с $name! 🧳✈️\n$url';
      case 'zh': return '在 PackBuddy 上与 $name 成为旅行同伴吧！🧳✈️\n$url';
      case 'ja': return 'PackBuddy で $name と旅行仲間になりましょう！🧳✈️\n$url';
      case 'ko': return 'PackBuddy에서 $name님과 여행 친구가 되어보세요! 🧳✈️\n$url';
      case 'hi': return 'PackBuddy पर $name के साथ यात्रा मित्र बनें! 🧳✈️\n$url';
      case 'ar': return 'كن رفيق سفر على PackBuddy مع $name! 🧳✈️\n$url';
      case 'nl': return 'Word reismaatje op PackBuddy met $name! 🧳✈️\n$url';
      case 'el': return 'Γίνετε ταξιδιωτικός φίλος στο PackBuddy με τον $name! 🧳✈️\n$url';
      case 'sv': return 'Bli reskompis på PackBuddy med $name! 🧳✈️\n$url';
      case 'pl': return 'Zostań towarzyszem podróży w PackBuddy z $name! 🧳✈️\n$url';
      case 'id': return 'Jadilah teman perjalanan di PackBuddy bersama $name! 🧳✈️\n$url';
      case 'th': return 'มาเป็นเพื่อนร่วมทางใน PackBuddy กับ $name กันเถอะ! 🧳✈️\n$url';
      case 'vi': return 'Trở thành bạn đồng hành trên PackBuddy cùng $name! 🧳✈️\n$url';
      case 'en':
      default: return 'Become travel buddies on PackBuddy with $name! 🧳✈️\n$url';
    }
  }

  static String getShareInviteSubject(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'PackBuddy Seyahat Daveti';
      case 'de': return 'PackBuddy Reiseeinladung';
      case 'es': return 'Invitación de Viaje PackBuddy';
      case 'fr': return 'Invitation de voyage PackBuddy';
      case 'it': return 'Invito di viaggio PackBuddy';
      case 'pt': return 'Convite de Viagem PackBuddy';
      case 'ru': return 'Приглашение в поездку PackBuddy';
      case 'zh': return 'PackBuddy 旅行邀请';
      case 'ja': return 'PackBuddy 旅行の招待';
      case 'ko': return 'PackBuddy 여행 초대';
      case 'hi': return 'PackBuddy यात्रा आमंत्रण';
      case 'ar': return 'دعوة سفر PackBuddy';
      case 'nl': return 'PackBuddy Reisuitnodiging';
      case 'el': return 'Πρόσκληση ταξιδιού PackBuddy';
      case 'sv': return 'PackBuddy Reseinbjudan';
      case 'pl': return 'Zaproszenie do podróży PackBuddy';
      case 'id': return 'Undangan Perjalanan PackBuddy';
      case 'th': return 'คำเชิญเดินทาง PackBuddy';
      case 'vi': return 'Lời mời du lịch PackBuddy';
      case 'en':
      default: return 'PackBuddy Travel Invitation';
    }
  }
}

/// Helper formatting smart last active presence status across 20 languages
class PresenceFormatter {
  PresenceFormatter._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String format(DateTime? lastActiveAt, String lang) {
    final clean = _cleanLang(lang);
    if (lastActiveAt == null) {
      switch (clean) {
        case 'tr': return '⚪ Çevrimdışı';
        case 'de': return '⚪ Offline';
        case 'es': return '⚪ Desconectado';
        case 'fr': return '⚪ Hors ligne';
        case 'it': return '⚪ Non in linea';
        case 'pt': return '⚪ Offline';
        case 'ru': return '⚪ Не в сети';
        case 'zh': return '⚪ 离线';
        case 'ja': return '⚪ オフライン';
        case 'ko': return '⚪ 오프라인';
        case 'hi': return '⚪ ऑफ़लाइन';
        case 'ar': return '⚪ غير متصل';
        case 'nl': return '⚪ Offline';
        case 'el': return '⚪ Εκτός σύνδεσης';
        case 'sv': return '⚪ Frånkopplad';
        case 'pl': return '⚪ Niedostępny';
        case 'id': return '⚪ Offline';
        case 'th': return '⚪ ออฟไลน์';
        case 'vi': return '⚪ Ngoại tuyến';
        case 'en':
        default: return '⚪ Offline';
      }
    }

    final diff = DateTime.now().difference(lastActiveAt);

    if (diff.inMinutes < 5) {
      switch (clean) {
        case 'tr': return '🟢 Şu an aktif';
        case 'de': return '🟢 Jetzt aktiv';
        case 'es': return '🟢 Activo ahora';
        case 'fr': return '🟢 En ligne';
        case 'it': return '🟢 Attivo ora';
        case 'pt': return '🟢 Ativo agora';
        case 'ru': return '🟢 Сейчас в сети';
        case 'zh': return '🟢 当前在线';
        case 'ja': return '🟢 オンライン';
        case 'ko': return '🟢 현재 활동 중';
        case 'hi': return '🟢 अभी सक्रिय';
        case 'ar': return '🟢 نشط الآن';
        case 'nl': return '🟢 Nu actief';
        case 'el': return '🟢 Ενεργός τώρα';
        case 'sv': return '🟢 Aktiv nu';
        case 'pl': return '🟢 Teraz aktywny';
        case 'id': return '🟢 Aktif sekarang';
        case 'th': return '🟢 กำลังใช้งาน';
        case 'vi': return '🟢 Đang hoạt động';
        case 'en':
        default: return '🟢 Active now';
      }
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      switch (clean) {
        case 'tr': return '🟡 $m dk önce aktifti';
        case 'de': return '🟡 Vor ${m}m aktiv';
        case 'es': return '🟡 Activo hace ${m}m';
        case 'fr': return '🟡 Actif il y a ${m}min';
        case 'it': return '🟡 Attivo ${m}m fa';
        case 'pt': return '🟡 Ativo há ${m}m';
        case 'ru': return '🟡 Был(а) $m мин назад';
        case 'zh': return '🟡 $m分钟前活跃';
        case 'ja': return '🟡 $m分前';
        case 'ko': return '🟡 $m분 전 활동';
        case 'hi': return '🟡 $m मिनट पहले सक्रिय';
        case 'ar': return '🟡 نشط منذ $m دقيقة';
        case 'nl': return '🟡 ${m}m geleden';
        case 'el': return '🟡 Ενεργός πριν $mλ';
        case 'sv': return '🟡 Aktiv för ${m}m sedan';
        case 'pl': return '🟡 Aktywny ${m}m temu';
        case 'id': return '🟡 Aktif ${m}m lalu';
        case 'th': return '🟡 ใช้งานเมื่อ $m น. ที่แล้ว';
        case 'vi': return '🟡 Hoạt động $m phút trước';
        case 'en':
        default: return '🟡 Active ${m}m ago';
      }
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      switch (clean) {
        case 'tr': return '🟡 $h saat önce aktifti';
        case 'de': return '🟡 Vor ${h}h aktiv';
        case 'es': return '🟡 Activo hace ${h}h';
        case 'fr': return '🟡 Actif il y a ${h}h';
        case 'it': return '🟡 Attivo ${h}h fa';
        case 'pt': return '🟡 Ativo há ${h}h';
        case 'ru': return '🟡 Был(а) $h ч назад';
        case 'zh': return '🟡 $h小时前活跃';
        case 'ja': return '🟡 $h時間前';
        case 'ko': return '🟡 $h시간 전 활동';
        case 'hi': return '🟡 $h घंटे पहले सक्रिय';
        case 'ar': return '🟡 نشط منذ $h ساعة';
        case 'nl': return '🟡 ${h}u geleden';
        case 'el': return '🟡 Ενεργός πριν $hω';
        case 'sv': return '🟡 Aktiv för ${h}t sedan';
        case 'pl': return '🟡 Aktywny ${h}g temu';
        case 'id': return '🟡 Aktif ${h}j lalu';
        case 'th': return '🟡 ใช้งานเมื่อ $h ชม. ที่แล้ว';
        case 'vi': return '🟡 Hoạt động $h giờ trước';
        case 'en':
        default: return '🟡 Active ${h}h ago';
      }
    }
    if (diff.inDays == 1) {
      switch (clean) {
        case 'tr': return '⚪ Dün aktifti';
        case 'de': return '⚪ Gestern aktiv';
        case 'es': return '⚪ Activo ayer';
        case 'fr': return '⚪ Actif hier';
        case 'it': return '⚪ Attivo ieri';
        case 'pt': return '⚪ Ativo ontem';
        case 'ru': return '⚪ Был(а) вчера';
        case 'zh': return '⚪ 昨天活跃';
        case 'ja': return '⚪ 昨日アクティブ';
        case 'ko': return '⚪ 어제 활동';
        case 'hi': return '⚪ कल सक्रिय';
        case 'ar': return '⚪ كان نشطًا بالأمس';
        case 'nl': return '⚪ Gisteren actief';
        case 'el': return '⚪ Ενεργός εχθές';
        case 'sv': return '⚪ Aktiv igår';
        case 'pl': return '⚪ Aktywny wczoraj';
        case 'id': return '⚪ Aktif kemarin';
        case 'th': return '⚪ ใช้งานเมื่อวานนี้';
        case 'vi': return '⚪ Hoạt động hôm qua';
        case 'en':
        default: return '⚪ Active yesterday';
      }
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      switch (clean) {
        case 'tr': return '⚪ $d gün önce aktifti';
        case 'de': return '⚪ Vor $d Tagen aktiv';
        case 'es': return '⚪ Activo hace ${d}d';
        case 'fr': return '⚪ Actif il y a ${d}j';
        case 'it': return '⚪ Attivo ${d}g fa';
        case 'pt': return '⚪ Ativo há ${d}d';
        case 'ru': return '⚪ Был(а) $d дн назад';
        case 'zh': return '⚪ $d天前活跃';
        case 'ja': return '⚪ $d日前';
        case 'ko': return '⚪ $d일 전 활동';
        case 'hi': return '⚪ $d दिन पहले सक्रिय';
        case 'ar': return '⚪ نشط منذ $d يوم';
        case 'nl': return '⚪ ${d}d geleden';
        case 'el': return '⚪ Ενεργός πριν $dημ';
        case 'sv': return '⚪ Aktiv för ${d}d sedan';
        case 'pl': return '⚪ Aktywny $d dni temu';
        case 'id': return '⚪ Aktif ${d}h lalu';
        case 'th': return '⚪ ใช้งานเมื่อ $d วันที่แล้ว';
        case 'vi': return '⚪ Hoạt động $d ngày trước';
        case 'en':
        default: return '⚪ Active ${d}d ago';
      }
    }
    final w = (diff.inDays / 7).floor();
    switch (clean) {
      case 'tr': return '⚪ $w hafta önce aktifti';
      case 'de': return '⚪ Vor $w Wochen aktiv';
      case 'es': return '⚪ Activo hace $w sem';
      case 'fr': return '⚪ Actif il y a $w sem';
      case 'it': return '⚪ Attivo $w sett fa';
      case 'pt': return '⚪ Ativo há $w sem';
      case 'ru': return '⚪ Был(а) $w нед назад';
      case 'zh': return '⚪ $w周前活跃';
      case 'ja': return '⚪ $w週間前';
      case 'ko': return '⚪ $w주 전 활동';
      case 'hi': return '⚪ $w सप्ताह पहले सक्रिय';
      case 'ar': return '⚪ نشط منذ $w أسبوع';
      case 'nl': return '⚪ ${w}w geleden';
      case 'el': return '⚪ Ενεργός πριν $wεβδ';
      case 'sv': return '⚪ Aktiv för ${w}v sedan';
      case 'pl': return '⚪ Aktywny $w tyg. temu';
      case 'id': return '⚪ Aktif ${w}mgg lalu';
      case 'th': return '⚪ ใช้งานเมื่อ $w สัปดาห์ที่แล้ว';
      case 'vi': return '⚪ Hoạt động $w tuần trước';
      case 'en':
      default: return '⚪ Active ${w}w ago';
    }
  }
}
