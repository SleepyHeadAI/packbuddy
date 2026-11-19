/// Native 20-language localization for Live Collaborative Trips & Attribution
class CollaborationLocalization {
  CollaborationLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  /// Label for current user ("You" / "Siz")
  static String getYou(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Siz';
      case 'de': return 'Du';
      case 'es': return 'Tú';
      case 'fr': return 'Vous';
      case 'it': return 'Tu';
      case 'pt': return 'Você';
      case 'ru': return 'Вы';
      case 'zh': return '您';
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

  /// Attribution label for items created by someone else ("Added by Alex" / "Ekleyen: Alex")
  static String getAddedBy(String lang, String name) {
    final cleanName = name.trim().isNotEmpty ? name.trim() : getCollaborator(lang);
    switch (_cleanLang(lang)) {
      case 'tr': return 'Ekleyen: $cleanName';
      case 'de': return 'Von $cleanName';
      case 'es': return 'Por $cleanName';
      case 'fr': return 'Par $cleanName';
      case 'it': return 'Da $cleanName';
      case 'pt': return 'Por $cleanName';
      case 'ru': return 'Добавил(а): $cleanName';
      case 'zh': return '由 $cleanName 添加';
      case 'ja': return '$cleanName が追加';
      case 'ko': return '$cleanName님이 추가';
      case 'hi': return '$cleanName द्वारा';
      case 'ar': return 'بواسطة $cleanName';
      case 'nl': return 'Door $cleanName';
      case 'el': return 'Από $cleanName';
      case 'sv': return 'Av $cleanName';
      case 'pl': return 'Przez $cleanName';
      case 'id': return 'Oleh $cleanName';
      case 'th': return 'โดย $cleanName';
      case 'vi': return 'Bởi $cleanName';
      case 'en':
      default: return 'By $cleanName';
    }
  }

  /// Attribution label for items created by the user ("Added by you" / "Siz eklediniz")
  static String getAddedByYou(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Siz eklediniz';
      case 'de': return 'Von dir hinzugefügt';
      case 'es': return 'Añadido por ti';
      case 'fr': return 'Ajouté par vous';
      case 'it': return 'Aggiunto da te';
      case 'pt': return 'Adicionado por você';
      case 'ru': return 'Добавлено вами';
      case 'zh': return '由您添加';
      case 'ja': return 'あなたが追加';
      case 'ko': return '내가 추가함';
      case 'hi': return 'आपके द्वारा जोड़ा गया';
      case 'ar': return 'أضفته أنت';
      case 'nl': return 'Door jou toegevoegd';
      case 'el': return 'Προστέθηκε από εσάς';
      case 'sv': return 'Tillagd av dig';
      case 'pl': return 'Dodane przez Ciebie';
      case 'id': return 'Ditambahkan oleh Anda';
      case 'th': return 'เพิ่มโดยคุณ';
      case 'vi': return 'Do bạn thêm';
      case 'en':
      default: return 'Added by you';
    }
  }

  /// Live Shared Trip badge ("Live Shared Trip" / "Çevrimiçi Paylaşılan Seyahat")
  static String getLiveSharedTrip(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Çevrimiçi Paylaşılan Seyahat';
      case 'de': return 'Live Geteilte Reise';
      case 'es': return 'Viaje Compartido en Vivo';
      case 'fr': return 'Voyage Partagé en Direct';
      case 'it': return 'Viaggio Condiviso dal Vivo';
      case 'pt': return 'Viagem Compartilhada ao Vivo';
      case 'ru': return 'Общая онлайн-поездка';
      case 'zh': return '实时协作行程';
      case 'ja': return 'リアルタイム共有旅程';
      case 'ko': return '실시간 공유 여행';
      case 'hi': return 'लाइव साझा यात्रा';
      case 'ar': return 'رحلة مشتركة مباشرة';
      case 'nl': return 'Live Gedeelde Reis';
      case 'el': return 'Ζωντανό Κοινόχρηστο Ταξίδι';
      case 'sv': return 'Live Delad Resa';
      case 'pl': return 'Współdzielona Podróż Live';
      case 'id': return 'Perjalanan Berbagi Langsung';
      case 'th': return 'ทริปที่แชร์แบบเรียลไทม์';
      case 'vi': return 'Chuyến đi chia sẻ trực tiếp';
      case 'en':
      default: return 'Live Shared Trip';
    }
  }

  /// General collaborator term ("Collaborator" / "Katılımcı")
  static String getCollaborator(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Katılımcı';
      case 'de': return 'Teilnehmer';
      case 'es': return 'Colaborador';
      case 'fr': return 'Collaborateur';
      case 'it': return 'Collaboratore';
      case 'pt': return 'Colaborador';
      case 'ru': return 'Участник';
      case 'zh': return '协作者';
      case 'ja': return '参加者';
      case 'ko': return '참여자';
      case 'hi': return 'सहयोगी';
      case 'ar': return 'مشارك';
      case 'nl': return 'Mede-reiziger';
      case 'el': return 'Συνεργάτης';
      case 'sv': return 'Medresenär';
      case 'pl': return 'Współpracownik';
      case 'id': return 'Kolaborator';
      case 'th': return 'ผู้ร่วมทริป';
      case 'vi': return 'Cộng tác viên';
      case 'en':
      default: return 'Collaborator';
    }
  }

  /// Plural collaborators count ("3 Collaborators" / "3 Katılımcı")
  static String getCollaboratorsCount(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Katılımcı';
      case 'de': return '$count Teilnehmer';
      case 'es': return '$count colaboradores';
      case 'fr': return '$count collaborateurs';
      case 'it': return '$count collaboratori';
      case 'pt': return '$count colaboradores';
      case 'ru': return '$count участников';
      case 'zh': return '$count 位协作者';
      case 'ja': return '$count 人の参加者';
      case 'ko': return '참여자 $count명';
      case 'hi': return '$count सहयोगी';
      case 'ar': return '$count مشاركين';
      case 'nl': return '$count deelnemers';
      case 'el': return '$count συνεργάτες';
      case 'sv': return '$count deltagare';
      case 'pl': return '$count uczestników';
      case 'id': return '$count kolaborator';
      case 'th': return '$count ผู้ร่วมทริป';
      case 'vi': return '$count người tham gia';
      case 'en':
      default: return '$count collaborators';
    }
  }

  /// Trip Owner ("Trip Owner" / "Seyahat Sahibi")
  static String getOwner(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat Sahibi';
      case 'de': return 'Reiseinhaber';
      case 'es': return 'Organizador';
      case 'fr': return 'Créateur du voyage';
      case 'it': return 'Organizzatore';
      case 'pt': return 'Criador da viagem';
      case 'ru': return 'Организатор';
      case 'zh': return '行程创建者';
      case 'ja': return '作成者';
      case 'ko': return '여행 주최자';
      case 'hi': return 'यात्रा आयोजक';
      case 'ar': return 'منشئ الرحلة';
      case 'nl': return 'Reiseigenaar';
      case 'el': return 'Διοργανωτής';
      case 'sv': return 'Resans skapare';
      case 'pl': return 'Właściciel podróży';
      case 'id': return 'Pemilik Perjalanan';
      case 'th': return 'เจ้าของทริป';
      case 'vi': return 'Chủ chuyến đi';
      case 'en':
      default: return 'Trip Owner';
    }
  }

  /// Formats attribution:
  /// If [isMe] is true, returns "You" / "Siz".
  /// If [isMe] is false:
  ///   If [createdByName] is provided and non-empty, returns "By [name]" / "Ekleyen: [name]".
  ///   Else returns "Collaborator" / "Katılımcı".
  static String formatAddedBy(
    String? createdByName, {
    required bool isMe,
    required String languageCode,
  }) {
    if (isMe) {
      return getYou(languageCode);
    }
    if (createdByName != null && createdByName.trim().isNotEmpty) {
      return getAddedBy(languageCode, createdByName.trim());
    }
    return getCollaborator(languageCode);
  }
}
