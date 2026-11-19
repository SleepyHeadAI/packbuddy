/// Localization helpers for Vault features across all 20 languages.
class VaultLocalization {
  VaultLocalization._();

  static String _cleanLang(String lang) {
    final lower = lang.toLowerCase();
    if (lower.contains('_')) return lower.split('_')[0];
    if (lower.contains('-')) return lower.split('-')[0];
    return lower;
  }

  /// Label for reloading a document file from cloud storage
  static String reloadFromCloud(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Buluttan Tekrar İndir';
      case 'de': return 'Aus Cloud neu laden';
      case 'fr': return 'Recharger depuis le cloud';
      case 'es': return 'Recargar desde la nube';
      case 'it': return 'Ricarica dal cloud';
      case 'pt': return 'Recarregar da nuvem';
      case 'ru': return 'Перезагрузить из облака';
      case 'zh': return '从云端重新加载';
      case 'ja': return 'クラウドから再読み込み';
      case 'ko': return '클라우드에서 다시 로드';
      case 'ar': return 'إعادة التحميل من السحابة';
      case 'hi': return 'क्लाउड से फिर से लोड करें';
      case 'nl': return 'Opnieuw laden vanuit de cloud';
      case 'el': return 'Επαναφόρτωση από το cloud';
      case 'sv': return 'Ladda om från molnet';
      case 'pl': return 'Pobierz ponownie z chmury';
      case 'id': return 'Muat Ulang dari Cloud';
      case 'th': return 'โหลดซ้ำจากคลาวด์';
      case 'vi': return 'Tải lại từ đám mây';
      case 'en':
      default: return 'Reload from Cloud';
    }
  }

  /// Error message when document image fails to render
  static String imageLoadFailed(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Görsel yüklenemedi';
      case 'de': return 'Bild konnte nicht geladen werden';
      case 'fr': return 'Impossible de charger l\'image';
      case 'es': return 'No se pudo cargar la imagen';
      case 'it': return 'Impossibile caricare l\'immagine';
      case 'pt': return 'Não foi possível carregar a imagem';
      case 'ru': return 'Не удалось загрузить изображение';
      case 'zh': return '无法加载图像';
      case 'ja': return '画像を読み込めませんでした';
      case 'ko': return '이미지를 로드할 수 없습니다';
      case 'ar': return 'تعذر تحميل الصورة';
      case 'hi': return 'छवि लोड नहीं हो सकी';
      case 'nl': return 'Afbeelding kon niet worden geladen';
      case 'el': return 'Δεν ήταν δυνατή η φόρτωση της εικόνας';
      case 'sv': return 'Bilden kunde inte laddas';
      case 'pl': return 'Nie udało się załadować obrazu';
      case 'id': return 'Gambar gagal dimuat';
      case 'th': return 'ไม่สามารถโหลดรูปภาพได้';
      case 'vi': return 'Không thể tải hình ảnh';
      case 'en':
      default: return 'Image could not be loaded';
    }
  }

  /// Compact button label to fetch image file from cloud
  static String reloadCloud(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Buluttan İndir';
      case 'de': return 'Aus Cloud laden';
      case 'fr': return 'Télécharger du cloud';
      case 'es': return 'Cargar de la nube';
      case 'it': return 'Scarica dal cloud';
      case 'pt': return 'Baixar da nuvem';
      case 'ru': return 'Загрузить из облака';
      case 'zh': return '从云端加载';
      case 'ja': return 'クラウドからダウンロード';
      case 'ko': return '클라우드에서 다운로드';
      case 'ar': return 'تنزيل من السحابة';
      case 'hi': return 'क्लाउड से लोड करें';
      case 'nl': return 'Downloaden uit cloud';
      case 'el': return 'Λήψη από το cloud';
      case 'sv': return 'Ladda från molnet';
      case 'pl': return 'Pobierz z chmury';
      case 'id': return 'Unduh dari Cloud';
      case 'th': return 'ดาวน์โหลดจากคลาวด์';
      case 'vi': return 'Tải từ đám mây';
      case 'en':
      default: return 'Reload Cloud';
    }
  }
}
