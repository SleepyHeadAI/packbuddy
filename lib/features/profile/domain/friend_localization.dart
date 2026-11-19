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
      case 'ar': return 'ابحث عبر @اسم_المستخدم...';
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
      case 'ar': return 'إرسال طلب';
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
      case 'ar': return 'تم إرسال الطلب';
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
      case 'ar': return 'قبول';
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
      case 'ar': return 'رفض';
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
      case 'ar': return 'إلغاء الطلب';
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
      case 'ar': return 'إزالة الصديق';
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
      case 'ar': return 'لا يوجد أصدقاء سفر حتى الآن';
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
      default: return 'My QR Code & Invite Link';
    }
  }

  static String getShareInviteLink(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Davet Bağlantısını Paylaş';
      case 'de': return 'Einladungslink teilen';
      case 'es': return 'Compartir Enlace de Invitación';
      case 'fr': return 'Partager le lien d\'invitation';
      case 'it': return 'Condividi link di invito';
      case 'pt': return 'Compartilhar Link de Convite';
      case 'ru': return 'Поделиться ссылкой-приглашением';
      default: return 'Share Invite Link';
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
      default: return 'Link copied to clipboard ✨';
    }
  }

  static String getUserNotFound(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bu kullanıcı adına sahip seyahat sever bulunamadı';
      case 'de': return 'Kein Reisender mit diesem Benutzernamen gefunden';
      case 'es': return 'No se encontró ningún viajero con ese nombre de usuario';
      case 'fr': return 'Aucun voyageur trouvé avec ce nom d\'utilisateur';
      case 'it': return 'Nessun viaggiatore trovato con questo nome utente';
      case 'pt': return 'Nenhum viajante encontrado com este nome de usuário';
      case 'ru': return 'Путешественник с таким именем не найден';
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
      default: return 'You are already travel buddies ✨';
    }
  }

  static String getCannotAddSelf(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kendinizi arkadaş olarak ekleyemezsiniz';
      case 'de': return 'Du kannst dich nicht selbst hinzufügen';
      case 'es': return 'No puedes agregarte a ti mismo';
      case 'fr': return 'Vous ne pouvez pas vous ajouter vous-même';
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
      default: return '$count Mutual Countries Visited ✨';
    }
  }

  static String getNoMutualCountries(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Henüz ortak bir ülkeye gitmediniz. Birlikte bir rota keşfedin! 🗺️';
      case 'de': return 'Noch keine gemeinsamen Länder. Entdeckt zusammen eine neue Route! 🗺️';
      case 'es': return 'Aún no tienen países en común. ¡Descubran una nueva ruta juntos! 🗺️';
      case 'fr': return 'Pas encore de pays en commun. Explorez un nouvel itinéraire ensemble ! 🗺️';
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
      default: return 'Add from Friends';
    }
  }

  static String getAssignedTo(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kim Getirecek?';
      case 'de': return 'Wer bringt das mit?';
      case 'es': return '¿Quién lo lleva?';
      case 'fr': return 'Qui l\'apporte ?';
      case 'it': return 'Chi lo porta?';
      case 'pt': return 'Quem vai levar?';
      case 'ru': return 'Кто возьмет?';
      case 'zh': return '谁来带？';
      case 'ja': return '誰が持参する？';
      case 'ko': return '누가 가져오나요?';
      case 'hi': return 'कौन लाएगा?';
      case 'ar': return 'من سيحضره؟';
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
      default: return 'Invited to $tripTitle! ✈️';
    }
  }
}

/// Helper formatting smart last active presence status ("🟢 Şu an aktif", "🟡 2 saat önce aktifti")
class PresenceFormatter {
  PresenceFormatter._();

  static String format(DateTime? lastActiveAt, String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    if (lastActiveAt == null) {
      return clean == 'tr' ? '⚪ Çevrimdışı' : '⚪ Offline';
    }

    final diff = DateTime.now().difference(lastActiveAt);

    if (diff.inMinutes < 5) {
      return clean == 'tr' ? '🟢 Şu an aktif' : '🟢 Active now';
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return clean == 'tr' ? '🟡 $m dk önce aktifti' : '🟡 Active ${m}m ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return clean == 'tr' ? '🟡 $h saat önce aktifti' : '🟡 Active ${h}h ago';
    }
    if (diff.inDays == 1) {
      return clean == 'tr' ? '⚪ Dün aktifti' : '⚪ Active yesterday';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return clean == 'tr' ? '⚪ $d gün önce aktifti' : '⚪ Active ${d}d ago';
    }
    final w = (diff.inDays / 7).floor();
    return clean == 'tr' ? '⚪ $w hafta önce aktifti' : '⚪ Active ${w}w ago';
  }
}
