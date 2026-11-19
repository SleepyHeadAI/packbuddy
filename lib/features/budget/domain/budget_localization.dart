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

  /// Segmented Chart Type Selector: Category (Default)
  static String chartTypeCategory(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Harcama Türü';
      case 'de': return 'Kategorie';
      case 'fr': return 'Catégorie';
      case 'es': return 'Categoría';
      case 'it': return 'Categoria';
      case 'pt': return 'Categoria';
      case 'ru': return 'Категории';
      case 'zh': return '支出类别';
      case 'ja': return 'カテゴリ別';
      case 'ko': return '카테고리';
      case 'ar': return 'نوع الإنفاق';
      case 'hi': return 'व्यय श्रेणी';
      case 'nl': return 'Categorie';
      case 'el': return 'Κατηγορία';
      case 'sv': return 'Kategori';
      case 'pl': return 'Kategoria';
      case 'id': return 'Kategori';
      case 'th': return 'หมวดหมู่';
      case 'vi': return 'Hạng mục';
      case 'en':
      default: return 'Category';
    }
  }

  /// Segmented Chart Type Selector: Payment Method
  static String chartTypePayment(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Ödeme Yöntemi';
      case 'de': return 'Zahlungsart';
      case 'fr': return 'Mode de paiement';
      case 'es': return 'Método de pago';
      case 'it': return 'Metodo di pagamento';
      case 'pt': return 'Método de pagamento';
      case 'ru': return 'Способ оплаты';
      case 'zh': return '支付方式';
      case 'ja': return '支払い方法';
      case 'ko': return '결제 수단';
      case 'ar': return 'طريقة الدفع';
      case 'hi': return 'भुगतान विधि';
      case 'nl': return 'Betaalmethode';
      case 'el': return 'Τρόπος πληρωμής';
      case 'sv': return 'Betalningsmetod';
      case 'pl': return 'Metoda płatności';
      case 'id': return 'Metode Pembayaran';
      case 'th': return 'วิธีการชำระเงิน';
      case 'vi': return 'Phương thức trả';
      case 'en':
      default: return 'Payment Method';
    }
  }

  /// Segmented Chart Type Selector: Daily Spend Timeline
  static String chartTypeTimeline(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Günlük Dağılım';
      case 'de': return 'Täglicher Trend';
      case 'fr': return 'Tendance quotidienne';
      case 'es': return 'Tendencia diaria';
      case 'it': return 'Trend giornaliero';
      case 'pt': return 'Tendência diária';
      case 'ru': return 'Дневной тренд';
      case 'zh': return '每日趋势';
      case 'ja': return '日別トレンド';
      case 'ko': return '일일 트렌드';
      case 'ar': return 'التوزيع اليومي';
      case 'hi': return 'दैनिक रुझान';
      case 'nl': return 'Dagelijkse trend';
      case 'el': return 'Ημερήσια τάση';
      case 'sv': return 'Daglig trend';
      case 'pl': return 'Trend dzienny';
      case 'id': return 'Tren Harian';
      case 'th': return 'แนวโน้มรายวัน';
      case 'vi': return 'Xu hướng ngày';
      case 'en':
      default: return 'Daily Trend';
    }
  }

  /// Collapsible Deep Statistics & Insights Title
  static String deepStatsTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Detaylı İstatistikler & Analiz';
      case 'de': return 'Detaillierte Statistiken & Analyse';
      case 'fr': return 'Statistiques détaillées & Analyse';
      case 'es': return 'Estadísticas detalladas y análisis';
      case 'it': return 'Statistiche dettagliate e analisi';
      case 'pt': return 'Estatísticas detalhadas e análise';
      case 'ru': return 'Подробная статистика и анализ';
      case 'zh': return '深度财务统计与分析';
      case 'ja': return '詳細な統計とインサイト';
      case 'ko': return '상세 통계 및 분석';
      case 'ar': return 'إحصائيات تفصيلية وتحليلات';
      case 'hi': return 'विस्तृत आंकड़े और विश्लेषण';
      case 'nl': return 'Gedetailleerde statistieken & analyse';
      case 'el': return 'Λεπτομερή στατιστικά & ανάλυση';
      case 'sv': return 'Detaljerad statistik & analys';
      case 'pl': return 'Szczegółowe statystyki i analiza';
      case 'id': return 'Statistik & Analisis Rinci';
      case 'th': return 'สถิติและข้อมูลเชิงลึกโดยละเอียด';
      case 'vi': return 'Thống kê & Phân tích chi tiết';
      case 'en':
      default: return 'Detailed Analytics & Insights';
    }
  }

  /// Average Transaction Metric
  static String averageTransaction(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Ortalama İşlem';
      case 'de': return 'Durchschnitt';
      case 'fr': return 'Moyenne / achat';
      case 'es': return 'Transacción media';
      case 'it': return 'Spesa media';
      case 'pt': return 'Média / transação';
      case 'ru': return 'Средний чек';
      case 'zh': return '平均每笔';
      case 'ja': return '1回あたり平均';
      case 'ko': return '평균 결제액';
      case 'ar': return 'متوسط المعاملة';
      case 'hi': return 'औसत खर्च';
      case 'nl': return 'Gemiddelde transactie';
      case 'el': return 'Μέση συναλλαγή';
      case 'sv': return 'Genomsnitt';
      case 'pl': return 'Średnia transakcja';
      case 'id': return 'Rata-rata Transaksi';
      case 'th': return 'เฉลี่ยต่อรายการ';
      case 'vi': return 'Trung bình giao dịch';
      case 'en':
      default: return 'Avg. Transaction';
    }
  }

  /// Highest Single Expense Metric
  static String highestExpense(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'En Yüksek Harcama';
      case 'de': return 'Höchste Ausgabe';
      case 'fr': return 'Dépense la plus élevée';
      case 'es': return 'Gasto más alto';
      case 'it': return 'Spesa più alta';
      case 'pt': return 'Maior despesa';
      case 'ru': return 'Наибольший расход';
      case 'zh': return '最高单笔消费';
      case 'ja': return '最高支出額';
      case 'ko': return '최고 지출';
      case 'ar': return 'أعلى مصروف';
      case 'hi': return 'अधिकतम खर्च';
      case 'nl': return 'Hoogste uitgave';
      case 'el': return 'Υψηλότερη δαπάνη';
      case 'sv': return 'Högsta utgift';
      case 'pl': return 'Najwyższy wydatek';
      case 'id': return 'Pengeluaran Tertinggi';
      case 'th': return 'ยอดใช้จ่ายสูงสุด';
      case 'vi': return 'Chi tiêu cao nhất';
      case 'en':
      default: return 'Highest Expense';
    }
  }

  /// Lowest Single Expense Metric
  static String lowestExpense(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'En Düşük Harcama';
      case 'de': return 'Niedrigste Ausgabe';
      case 'fr': return 'Dépense la plus basse';
      case 'es': return 'Gasto más bajo';
      case 'it': return 'Spesa più bassa';
      case 'pt': return 'Menor despesa';
      case 'ru': return 'Наименьший расход';
      case 'zh': return '最低单笔消费';
      case 'ja': return '最低支出額';
      case 'ko': return '최저 지출';
      case 'ar': return 'أقل مصروف';
      case 'hi': return 'न्यूनतम खर्च';
      case 'nl': return 'Laagste uitgave';
      case 'el': return 'Χαμηλότερη δαπάνη';
      case 'sv': return 'Lägsta utgift';
      case 'pl': return 'Najniższy wydatek';
      case 'id': return 'Pengeluaran Terendah';
      case 'th': return 'ยอดใช้จ่ายต่ำสุด';
      case 'vi': return 'Chi tiêu thấp nhất';
      case 'en':
      default: return 'Lowest Expense';
    }
  }

  /// Peak Spend Day Metric
  static String peakSpendDay(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'En Yoğun Harcama Günü';
      case 'de': return 'Spitzentag';
      case 'fr': return 'Jour le plus dépensier';
      case 'es': return 'Día de mayor gasto';
      case 'it': return 'Giorno di picco';
      case 'pt': return 'Dia de maior gasto';
      case 'ru': return 'Пиковый день расходов';
      case 'zh': return '最高开销日';
      case 'ja': return '最多支出日';
      case 'ko': return '최대 지출일';
      case 'ar': return 'أعلى يوم إنفاق';
      case 'hi': return 'अधिकतम व्यय दिवस';
      case 'nl': return 'Piekdag';
      case 'el': return 'Ημέρα κορύφωσης';
      case 'sv': return 'Toppdag';
      case 'pl': return 'Dzień szczytowy';
      case 'id': return 'Hari Paling Boros';
      case 'th': return 'วันที่ใช้จ่ายสูงสุด';
      case 'vi': return 'Ngày chi tiêu đỉnh';
      case 'en':
      default: return 'Peak Spend Day';
    }
  }

  /// Cash vs Card Ratio Metric
  static String cashVsCard(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Nakit / Kart Dengesi';
      case 'de': return 'Bargeld / Karte';
      case 'fr': return 'Espèces / Carte';
      case 'es': return 'Efectivo / Tarjeta';
      case 'it': return 'Contanti / Carta';
      case 'pt': return 'Dinheiro / Cartão';
      case 'ru': return 'Наличные / Карта';
      case 'zh': return '现金 / 电子支付';
      case 'ja': return '現金 / カード比率';
      case 'ko': return '현금 / 카드 비율';
      case 'ar': return 'النقود مقابل البطاقة';
      case 'hi': return 'नकद / कार्ड अनुपात';
      case 'nl': return 'Contant / Kaart';
      case 'el': return 'Μετρητά / Κάρτα';
      case 'sv': return 'Kontant / Kort';
      case 'pl': return 'Gotówka / Karta';
      case 'id': return 'Tunai / Kartu';
      case 'th': return 'เงินสด / บัตร';
      case 'vi': return 'Tiền mặt / Thẻ';
      case 'en':
      default: return 'Cash vs. Card';
    }
  }

  /// Safe Daily Spend Metric
  static String safeDailySpend(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kalan Günlük Güvenli Bütçe';
      case 'de': return 'Sicheres Tagesbudget';
      case 'fr': return 'Budget quotidien restant';
      case 'es': return 'Presupuesto diario seguro';
      case 'it': return 'Budget giornaliero sicuro';
      case 'pt': return 'Orçamento diário seguro';
      case 'ru': return 'Безопасный дневной лимит';
      case 'zh': return '每日安全可用预算';
      case 'ja': return '安全な1日支出枠';
      case 'ko': return '안전한 일일 권장 예산';
      case 'ar': return 'الميزانية اليومية الآمنة';
      case 'hi': return 'सुरक्षित दैनिक बजट';
      case 'nl': return 'Veilig dagbudget';
      case 'el': return 'Ασφαλές ημερήσιο όριο';
      case 'sv': return 'Säker dagsbudget';
      case 'pl': return 'Bezpieczny budżet dzienny';
      case 'id': return 'Batas Aman Harian';
      case 'th': return 'งบประมาณรายวันที่ปลอดภัย';
      case 'vi': return 'Ngân sách an toàn mỗi ngày';
      case 'en':
      default: return 'Safe Daily Budget';
    }
  }

  /// Category Diversity Metric
  static String categoryDiversity(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kategori Çeşitliliği';
      case 'de': return 'Kategoriendiversität';
      case 'fr': return 'Diversité des catégories';
      case 'es': return 'Variedad de categorías';
      case 'it': return 'Varietà di categorie';
      case 'pt': return 'Variedade de categorias';
      case 'ru': return 'Категорий использовано';
      case 'zh': return '支出类别分布';
      case 'ja': return '利用カテゴリ数';
      case 'ko': return '활용 카테고리 수';
      case 'ar': return 'تنوع الفئات';
      case 'hi': return 'श्रेणी विविधता';
      case 'nl': return 'Categorievariatie';
      case 'el': return 'Ποικιλία κατηγοριών';
      case 'sv': return 'Kategoribredd';
      case 'pl': return 'Różnorodność kategorii';
      case 'id': return 'Keragaman Kategori';
      case 'th': return 'ความหลากหลายของหมวดหมู่';
      case 'vi': return 'Số lượng phân loại';
      case 'en':
      default: return 'Category Diversity';
    }
  }

  /// Timeline days count formatting
  static String timelineDays(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '($count gün)';
      case 'de': return '($count ${count == 1 ? "Tag" : "Tage"})';
      case 'fr': return '($count ${count == 1 ? "jour" : "jours"})';
      case 'es': return '($count ${count == 1 ? "día" : "días"})';
      case 'it': return '($count ${count == 1 ? "giorno" : "giorni"})';
      case 'pt': return '($count ${count == 1 ? "dia" : "dias"})';
      case 'ru': return '($count дн.)';
      case 'zh': return '($count天)';
      case 'ja': return '($count日間)';
      case 'ko': return '($count일)';
      case 'ar': return '($count أيام)';
      case 'hi': return '($count दिन)';
      case 'nl': return '($count ${count == 1 ? "dag" : "dagen"})';
      case 'el': return '($count ${count == 1 ? "ημέρα" : "ημέρες"})';
      case 'sv': return '($count ${count == 1 ? "dag" : "dagar"})';
      case 'pl': return '($count ${count == 1 ? "dzień" : "dni"})';
      case 'id': return '($count hari)';
      case 'th': return '($count วัน)';
      case 'vi': return '($count ngày)';
      case 'en':
      default: return '($count ${count == 1 ? "day" : "days"})';
    }
  }

  /// Peak amount header in daily spend chart
  static String peakLabel(String lang, String formattedAmount) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Zirve: $formattedAmount';
      case 'de': return 'Spitze: $formattedAmount';
      case 'fr': return 'Pic : $formattedAmount';
      case 'es': return 'Pico: $formattedAmount';
      case 'it': return 'Picco: $formattedAmount';
      case 'pt': return 'Pico: $formattedAmount';
      case 'ru': return 'Пик: $formattedAmount';
      case 'zh': return '最高: $formattedAmount';
      case 'ja': return 'ピーク: $formattedAmount';
      case 'ko': return '최고: $formattedAmount';
      case 'ar': return 'الذروة: $formattedAmount';
      case 'hi': return 'शिखर: $formattedAmount';
      case 'nl': return 'Piek: $formattedAmount';
      case 'el': return 'Κορυφή: $formattedAmount';
      case 'sv': return 'Topp: $formattedAmount';
      case 'pl': return 'Szczyt: $formattedAmount';
      case 'id': return 'Puncak: $formattedAmount';
      case 'th': return 'สูงสุด: $formattedAmount';
      case 'vi': return 'Đỉnh điểm: $formattedAmount';
      case 'en':
      default: return 'Peak: $formattedAmount';
    }
  }

  /// Deep stats accordion collapse hint
  static String deepStatsCollapse(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Daraltmak için dokunun';
      case 'de': return 'Zum Einklappen tippen';
      case 'fr': return 'Toucher pour réduire';
      case 'es': return 'Toca para contraer';
      case 'it': return 'Tocca per comprimere';
      case 'pt': return 'Toque para recolher';
      case 'ru': return 'Нажмите, чтобы свернуть';
      case 'zh': return '点击收起';
      case 'ja': return 'タップして折りたたむ';
      case 'ko': return '탭하여 접기';
      case 'ar': return 'اضغط للطي';
      case 'hi': return 'छोटा करने के लिए टैप करें';
      case 'nl': return 'Tik om samen te vouwen';
      case 'el': return 'Πατήστε για σύμπτυξη';
      case 'sv': return 'Tryck för att fälla ihop';
      case 'pl': return 'Dotknij, aby zwinąć';
      case 'id': return 'Ketuk untuk menutup';
      case 'th': return 'แตะเพื่อย่อ';
      case 'vi': return 'Chạm để thu gọn';
      case 'en':
      default: return 'Tap to collapse';
    }
  }

  /// Deep stats accordion explore hint
  static String deepStatsExplore(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Detaylı analizleri keşfedin';
      case 'de': return 'Detaillierte Analysen entdecken';
      case 'fr': return 'Explorer les analyses détaillées';
      case 'es': return 'Explorar análisis detallado';
      case 'it': return 'Esplora analisi dettagliate';
      case 'pt': return 'Explorar análises detalhadas';
      case 'ru': return 'Подробный анализ расходов';
      case 'zh': return '探索详细财务分析';
      case 'ja': return '詳細な分析を確認';
      case 'ko': return '상세 분석 살펴보기';
      case 'ar': return 'استكشاف التحليلات التفصيلية';
      case 'hi': return 'विस्तृत विश्लेषण देखें';
      case 'nl': return 'Bekijk gedetailleerde analyses';
      case 'el': return 'Εξερευνήστε αναλυτικά στατιστικά';
      case 'sv': return 'Utforska detaljerade analyser';
      case 'pl': return 'Odkryj szczegółowe analizy';
      case 'id': return 'Jelajahi analisis terperinci';
      case 'th': return 'สำรวจการวิเคราะห์โดยละเอียด';
      case 'vi': return 'Khám phá phân tích chi tiết';
      case 'en':
      default: return 'Explore detailed analytics';
    }
  }

  /// Card vs Cash percentage formatting
  static String formatRatioPercent(String lang, int cardPct, int cashPct) {
    if (_cleanLang(lang) == 'tr') {
      return '%$cardPct / %$cashPct';
    }
    return '$cardPct% / $cashPct%';
  }

  /// Card vs Cash subtitle label
  static String cardVsCashSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kart / Nakit';
      case 'de': return 'Karte / Bargeld';
      case 'fr': return 'Carte / Espèces';
      case 'es': return 'Tarjeta / Efectivo';
      case 'it': return 'Carta / Contanti';
      case 'pt': return 'Cartão / Dinheiro';
      case 'ru': return 'Карта / Наличные';
      case 'zh': return '刷卡 / 现金';
      case 'ja': return 'カード / 現金';
      case 'ko': return '카드 / 현금';
      case 'ar': return 'بطاقة / نقود';
      case 'hi': return 'कार्ड / नकद';
      case 'nl': return 'Kaart / Contant';
      case 'el': return 'Κάρτα / Μετρητά';
      case 'sv': return 'Kort / Kontant';
      case 'pl': return 'Karta / Gotówka';
      case 'id': return 'Kartu / Tunai';
      case 'th': return 'บัตร / เงินสด';
      case 'vi': return 'Thẻ / Tiền mặt';
      case 'en':
      default: return 'Card / Cash';
    }
  }

  /// Category count display (e.g. 2 Categories / 2 Categorias)
  static String formatCategoryCount(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Kategori';
      case 'de': return '$count ${count == 1 ? "Kategorie" : "Kategorien"}';
      case 'fr': return '$count ${count == 1 ? "catégorie" : "catégories"}';
      case 'es': return '$count ${count == 1 ? "categoría" : "categorías"}';
      case 'it': return '$count ${count == 1 ? "categoria" : "categorie"}';
      case 'pt': return '$count ${count == 1 ? "categoria" : "categorias"}';
      case 'ru': return '$count категорий';
      case 'zh': return '$count 个类别';
      case 'ja': return '$count カテゴリ';
      case 'ko': return '$count개 카테고리';
      case 'ar': return '$count فئات';
      case 'hi': return '$count श्रेणियां';
      case 'nl': return '$count ${count == 1 ? "categorie" : "categorieën"}';
      case 'el': return '$count ${count == 1 ? "κατηγορία" : "κατηγορίες"}';
      case 'sv': return '$count ${count == 1 ? "kategori" : "kategorier"}';
      case 'pl': return '$count ${count == 1 ? "kategoria" : "kategorie"}';
      case 'id': return '$count Kategori';
      case 'th': return '$count หมวดหมู่';
      case 'vi': return '$count hạng mục';
      case 'en':
      default: return '$count ${count == 1 ? "Category" : "Categories"}';
    }
  }

  /// Top category subtitle (e.g. Peak: Food / Pico: Alimentação)
  static String formatTopCategory(String lang, String categoryName) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Zirve: $categoryName';
      case 'de': return 'Spitze: $categoryName';
      case 'fr': return 'Top : $categoryName';
      case 'es': return 'Pico: $categoryName';
      case 'it': return 'Picco: $categoryName';
      case 'pt': return 'Pico: $categoryName';
      case 'ru': return 'Топ: $categoryName';
      case 'zh': return '最高: $categoryName';
      case 'ja': return '最多: $categoryName';
      case 'ko': return '최대: $categoryName';
      case 'ar': return 'الذروة: $categoryName';
      case 'hi': return 'शीर्ष: $categoryName';
      case 'nl': return 'Top: $categoryName';
      case 'el': return 'Κορυφή: $categoryName';
      case 'sv': return 'Topp: $categoryName';
      case 'pl': return 'Główna: $categoryName';
      case 'id': return 'Puncak: $categoryName';
      case 'th': return 'สูงสุด: $categoryName';
      case 'vi': return 'Cao nhất: $categoryName';
      case 'en':
      default: return 'Top: $categoryName';
    }
  }

  /// Safe daily spend subtitle per remaining day
  static String perRemainingDay(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kalan gün başına';
      case 'de': return 'Pro verbleibendem Tag';
      case 'fr': return 'Par jour restant';
      case 'es': return 'Por día restante';
      case 'it': return 'Per giorno rimanente';
      case 'pt': return 'Por dia restante';
      case 'ru': return 'В день (на ост. дни)';
      case 'zh': return '剩余每日预算';
      case 'ja': return '残りの1日あたり';
      case 'ko': return '남은 일수 일일 기준';
      case 'ar': return 'لكل يوم متبقي';
      case 'hi': return 'प्रति शेष दिन';
      case 'nl': return 'Per resterende dag';
      case 'el': return 'Ανά ημέρα που απομένει';
      case 'sv': return 'Per återstående dag';
      case 'pl': return 'Na pozostały dzień';
      case 'id': return 'Per sisa hari';
      case 'th': return 'ต่อวันที่เหลือ';
      case 'vi': return 'Mỗi ngày còn lại';
      case 'en':
      default: return 'Per remaining day';
    }
  }

  /// Daily average subtitle
  static String dailyAverage(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Günlük ortalama';
      case 'de': return 'Täglicher Durchschnitt';
      case 'fr': return 'Moyenne quotidienne';
      case 'es': return 'Promedio diario';
      case 'it': return 'Media giornaliera';
      case 'pt': return 'Média diária';
      case 'ru': return 'Среднесуточный расход';
      case 'zh': return '日均消费';
      case 'ja': return '1日の平均';
      case 'ko': return '일일 평균';
      case 'ar': return 'المعدل اليومي';
      case 'hi': return 'दैनिक औसत';
      case 'nl': return 'Dagelijks gemiddelde';
      case 'el': return 'Ημερήσιος μέσος όρος';
      case 'sv': return 'Dagsgenomsnitt';
      case 'pl': return 'Średnia dzienna';
      case 'id': return 'Rata-rata harian';
      case 'th': return 'เฉลี่ยรายวัน';
      case 'vi': return 'Trung bình ngày';
      case 'en':
      default: return 'Daily average';
    }
  }

  /// Emergency guide countries covered count label
  static String countriesCovered(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$count Ülke Kapsanıyor';
      case 'de': return '$count Länder abgedeckt';
      case 'fr': return '$count pays couverts';
      case 'es': return '$count países cubiertos';
      case 'it': return '$count paesi coperti';
      case 'pt': return '$count países cobertos';
      case 'ru': return 'Охватывает $count стран';
      case 'zh': return '涵盖 $count 个国家/地区';
      case 'ja': return '$countカ国をカバー';
      case 'ko': return '$count개국 지원';
      case 'ar': return 'يشمل $count دول';
      case 'hi': return '$count देश शामिल';
      case 'nl': return '$count landen gedekt';
      case 'el': return 'Καλύπτονται $count χώρες';
      case 'sv': return '$count länder omfattas';
      case 'pl': return 'Objęte kraje: $count';
      case 'id': return '$count Negara Dicakup';
      case 'th': return 'ครอบคลุม $count ประเทศ';
      case 'vi': return 'Bao gồm $count quốc gia';
      case 'en':
      default: return '$count Countries Covered';
    }
  }

  /// Emergency guide all trip destinations label
  static String allTripDestinations(String lang, int count) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tüm Seyahat Ülkeleri ($count)';
      case 'de': return 'Alle Reiseziele ($count)';
      case 'fr': return 'Toutes les destinations ($count)';
      case 'es': return 'Todos los destinos del viaje ($count)';
      case 'it': return 'Tutte le destinazioni ($count)';
      case 'pt': return 'Todos os destinos da viagem ($count)';
      case 'ru': return 'Все страны поездки ($count)';
      case 'zh': return '所有旅行目的地 ($count)';
      case 'ja': return 'すべての旅行先 ($count)';
      case 'ko': return '모든 여행 목적지 ($count)';
      case 'ar': return 'جميع وجهات الرحلة ($count)';
      case 'hi': return 'यात्रा के सभी गंतव्य ($count)';
      case 'nl': return 'Alle reisbestemmingen ($count)';
      case 'el': return 'Όλοι οι προορισμοί ταξιδιού ($count)';
      case 'sv': return 'Alla resmål ($count)';
      case 'pl': return 'Wszystkie cele podróży ($count)';
      case 'id': return 'Semua Destinasi Perjalanan ($count)';
      case 'th': return 'จุดหมายปลายทางทั้งหมด ($count)';
      case 'vi': return 'Tất cả điểm đến ($count)';
      case 'en':
      default: return 'All Trip Destinations ($count)';
    }
  }
}
