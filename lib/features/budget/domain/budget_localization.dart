/// Native 20-language localization for Budget Analytics, Multi-Currency Management & Currency Actions
class BudgetLocalization {
  BudgetLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  /// Label for button to set the selected currency as the permanent trip base currency
  static String makeTripCurrency(String lang, String currency) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$currency Gezi Para Birimi Yap';
      case 'de': return '$currency als Reisewährung';
      case 'fr': return 'Définir $currency comme devise';
      case 'es': return 'Hacer $currency moneda base';
      case 'it': return 'Imposta $currency valuta viaggio';
      case 'pt': return 'Tornar $currency moeda da viagem';
      case 'ru': return 'Сделать $currency валютой поездки';
      case 'zh': return '设 $currency 为行程货币';
      case 'ja': return '$currency を旅行通貨にする';
      case 'ko': return '$currency(으)로 여행 통화 설정';
      case 'ar': return 'جعل $currency عملة الرحلة';
      case 'hi': return '$currency को यात्रा मुद्रा बनाएं';
      case 'nl': return 'Maak $currency reisvaluta';
      case 'el': return 'Ορισμός $currency ως νόμισμα';
      case 'sv': return 'Gör $currency till resevaluta';
      case 'pl': return 'Ustaw $currency jako walutę';
      case 'id': return 'Jadikan $currency Mata Uang';
      case 'th': return 'ใช้ $currency เป็นสกุลเงินหลัก';
      case 'vi': return 'Đặt $currency làm tiền tệ';
      case 'en':
      default: return 'Make $currency Trip Currency';
    }
  }

  /// Longer descriptive tooltip / dialog label for setting base currency
  static String setAsBaseCurrency(String lang, String currency) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$currency para birimini gezinin ana para birimi olarak ayarla';
      case 'de': return '$currency als Hauptwährung der Reise festlegen';
      case 'fr': return 'Définir $currency comme devise de base du voyage';
      case 'es': return 'Establecer $currency como la moneda principal del viaje';
      case 'it': return 'Imposta $currency come valuta principale del viaggio';
      case 'pt': return 'Definir $currency como moeda principal da viagem';
      case 'ru': return 'Сделать $currency основной валютой поездки';
      case 'zh': return '将 $currency 设为行程的基础货币';
      case 'ja': return '$currency を旅行の基本通貨として保存';
      case 'ko': return '$currency(으)로 여행의 기본 통화를 저장합니다';
      case 'ar': return 'تعيين $currency كالعملة الأساسية الدائمة للرحلة';
      case 'hi': return '$currency को यात्रा की प्राथमिक मुद्रा बनाएं';
      case 'nl': return 'Stel $currency in als primaire reisvaluta';
      case 'el': return 'Ορισμός του $currency ως κύριο νόμισμα του ταξιδιού';
      case 'sv': return 'Spara $currency som resans basvaluta';
      case 'pl': return 'Ustaw $currency jako główną walutę wyjazdu';
      case 'id': return 'Tetapkan $currency sebagai mata uang utama perjalanan';
      case 'th': return 'ตั้งค่า $currency เป็นสกุลเงินหลักของการเดินทาง';
      case 'vi': return 'Đặt $currency làm tiền tệ gốc chính của chuyến đi';
      case 'en':
      default: return 'Set $currency as the trip base currency';
    }
  }

  /// Confirmation toast message when trip currency is updated
  static String tripCurrencyUpdated(String lang, String currency) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Gezi para birimi $currency olarak güncellendi';
      case 'de': return 'Reisewährung auf $currency aktualisiert';
      case 'fr': return 'Devise du voyage mise à jour en $currency';
      case 'es': return 'Moneda del viaje actualizada a $currency';
      case 'it': return 'Valuta del viaggio aggiornata a $currency';
      case 'pt': return 'Moeda da viagem atualizada para $currency';
      case 'ru': return 'Валюта поездки успешно изменена на $currency';
      case 'zh': return '行程货币已成功更新为 $currency';
      case 'ja': return '旅行の通貨を $currency に更新しました';
      case 'ko': return '여행 통화가 $currency(으)로 업데이트되었습니다';
      case 'ar': return 'تم تحديث عملة الرحلة بنجاح إلى $currency';
      case 'hi': return 'यात्रा मुद्रा सफलतापूर्वक $currency में बदल दी गई';
      case 'nl': return 'Reisvaluta succesvol bijgewerkt naar $currency';
      case 'el': return 'Το νόμισμα του ταξιδιού ενημερώθηκε σε $currency';
      case 'sv': return 'Resans valuta har uppdaterats till $currency';
      case 'pl': return 'Waluta wyjazdu została zaktualizowana na $currency';
      case 'id': return 'Mata uang perjalanan diperbarui menjadi $currency';
      case 'th': return 'อัปเดตสกุลเงินของการเดินทางเป็น $currency สำเร็จ';
      case 'vi': return 'Tiền tệ chuyến đi đã được cập nhật thành $currency';
      case 'en':
      default: return 'Trip currency updated to $currency';
    }
  }

  /// Label showing active viewing currency status
  static String viewingIn(String lang, String currency) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$currency ile görüntüleniyor';
      case 'de': return 'Ansicht in $currency';
      case 'fr': return 'Affichage en $currency';
      case 'es': return 'Viendo en $currency';
      case 'it': return 'Visualizzazione in $currency';
      case 'pt': return 'Visualizando em $currency';
      case 'ru': return 'Отображение в $currency';
      case 'zh': return '以 $currency 显示';
      case 'ja': return '$currency で表示中';
      case 'ko': return '$currency(으)로 표시 중';
      case 'ar': return 'العرض بعملة $currency';
      case 'hi': return '$currency में दिखाया जा रहा है';
      case 'nl': return 'Weergegeven in $currency';
      case 'el': return 'Προβολή σε $currency';
      case 'sv': return 'Visas i $currency';
      case 'pl': return 'Wyświetlanie w $currency';
      case 'id': return 'Ditampilkan dalam $currency';
      case 'th': return 'กำลังแสดงใน $currency';
      case 'vi': return 'Đang hiển thị theo $currency';
      case 'en':
      default: return 'Viewing in $currency';
    }
  }
}
