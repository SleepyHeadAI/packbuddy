import 'package:flutter/material.dart';

/// Representation of a summarized data & permission category
class LegalSummaryCategory {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final List<String> bulletPoints;

  const LegalSummaryCategory({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.bulletPoints,
  });
}

/// Representation of a formal legal article
class LegalArticle {
  final int number;
  final String title;
  final String content;

  const LegalArticle({
    required this.number,
    required this.title,
    required this.content,
  });
}

/// Centralized, legally binding multilingual repository for User Agreement,
/// Privacy Policy & Data Processing Explicit Consent (KVKK, GDPR, CCPA/CPRA).
///
/// Fully supports all 20 official PackBuddy languages with fallback.
class LegalConsentLocalization {
  LegalConsentLocalization._();

  static const List<String> supportedLanguages = [
    'tr', 'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
  ];

  static String _cleanLang(String? lang) {
    if (lang == null || lang.isEmpty) return 'en';
    final code = lang.toLowerCase().split('_').first.split('-').first;
    return supportedLanguages.contains(code) ? code : 'en';
  }

  // --- Titles and Subtitles ---
  static String getTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kullanıcı ve İzin Sözleşmesi';
      case 'de':
        return 'Nutzervereinbarung & Datenschutz';
      case 'fr':
        return 'Conditions d\'utilisation & Confidentialité';
      case 'es':
        return 'Términos de uso y Consentimiento';
      case 'it':
        return 'Termini di servizio e Consenso';
      case 'pt':
        return 'Termos de Uso e Consentimento';
      case 'ru':
        return 'Пользовательское соглашение и согласие';
      case 'zh':
        return '用户协议与数据许可';
      case 'ja':
        return '利用規約およびデータ同意';
      case 'ko':
        return '이용약관 및 개인정보 동의';
      case 'ar':
        return 'اتفاقية المستخدم والموافقة على البيانات';
      case 'hi':
        return 'उपयोगकर्ता अनुबंध और डेटा सहमति';
      case 'nl':
        return 'Gebruikersovereenkomst & Toestemming';
      case 'el':
        return 'Συμφωνία Χρήστη & Συναίνεση Δεδομένων';
      case 'sv':
        return 'Användaravtal & Datasamtycke';
      case 'pl':
        return 'Umowa użytkownika i zgoda na dane';
      case 'id':
        return 'Perjanjian Pengguna & Izin Data';
      case 'th':
        return 'ข้อตกลงผู้ใช้และความยินยอมด้านข้อมูล';
      case 'vi':
        return 'Thỏa thuận người dùng & Sự đồng ý dữ liệu';
      case 'en':
      default:
        return 'User Agreement & Privacy Consent';
    }
  }

  static String getSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kişisel verilerinizin toplanması, şifrelenmesi, işlenmesi ve haklarınız hakkında yasal aydınlatma ve açık rıza beyanı.';
      case 'de':
        return 'Rechtliche Aufklärung und Einwilligung zur Erhebung, Verschlüsselung und Verarbeitung Ihrer personenbezogenen Daten.';
      case 'fr':
        return 'Information légale et consentement explicite concernant la collecte, le chiffrement et le traitement de vos données personnelles.';
      case 'es':
        return 'Divulgación legal y consentimiento explícito sobre la recopilación, cifrado y procesamiento de sus datos personales.';
      case 'it':
        return 'Informativa legale e consenso esplicito per la raccolta, la crittografia e il trattamento dei tuoi dati personali.';
      case 'pt':
        return 'Divulgação legal e consentimento explícito sobre a coleta, criptografia e processamento de seus dados pessoais.';
      case 'ru':
        return 'Юридическое уведомление и согласие на сбор, шифрование и обработку ваших персональных данных.';
      case 'zh':
        return '关于收集、加密和处理您个人数据的法律说明与明确同意声明。';
      case 'ja':
        return '個人データの収集、暗号化、処理、およびお客様の権利に関する法的通知と同意書。';
      case 'ko':
        return '개인정보의 수집, 암호화, 처리 및 사용자 권리에 관한 법적 고지 및 명시적 동의서입니다.';
      case 'ar':
        return 'إشعار قانوني وموافقة صريحة بشأن جمع وتشفير ومعالجة بياناتك الشخصية وحقوقك.';
      case 'hi':
        return 'आपके व्यक्तिगत डेटा के संग्रह, एन्क्रिप्शन और प्रसंस्करण के संबंध में कानूनी प्रकटीकरण और सहमति।';
      case 'nl':
        return 'Wettelijke kennisgeving en uitdrukkelijke toestemming voor het verzamelen, versleutelen en verwerken van uw gegevens.';
      case 'el':
        return 'Νομική ενημέρωση και ρητή συγκατάθεση για τη συλλογή, κρυπτογράφηση και επεξεργασία των προσωπικών σας δεδομένων.';
      case 'sv':
        return 'Juridisk information och uttryckligt samtycke gällande insamling, kryptering och behandling av personuppgifter.';
      case 'pl':
        return 'Informacja prawna i wyraźna zgoda na zbieranie, szyfrowanie i przetwarzanie danych osobowych.';
      case 'id':
        return 'Pemberitahuan hukum dan persetujuan eksplisit tentang pengumpulan, enkripsi, dan pemrosesan data pribadi Anda.';
      case 'th':
        return 'การเปิดเผยข้อมูลทางกฎหมายและความยินยอมอย่างชัดแจ้งเกี่ยวกับการรวบรวม การเข้ารหัส และการประมวลผลข้อมูล';
      case 'vi':
        return 'Thông báo pháp lý và sự đồng ý rõ ràng về việc thu thập, mã hóa và xử lý dữ liệu cá nhân của bạn.';
      case 'en':
      default:
        return 'Legal disclosure and explicit consent regarding the collection, encryption, processing, and protection of your personal data.';
    }
  }

  // --- Tabs ---
  static String getTabSummary(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Özet & İzinler';
      case 'de':
        return 'Übersicht & Rechte';
      case 'fr':
        return 'Résumé & Droits';
      case 'es':
        return 'Resumen y Permisos';
      case 'it':
        return 'Riepilogo e Permessi';
      case 'pt':
        return 'Resumo e Permissões';
      case 'ru':
        return 'Обзор и разрешения';
      case 'zh':
        return '概览与权限';
      case 'ja':
        return '概要と権限';
      case 'ko':
        return '요약 및 권한';
      case 'ar':
        return 'الملخص والأذونات';
      case 'hi':
        return 'सारांश और अनुमतियाँ';
      case 'nl':
        return 'Overzicht & Rechten';
      case 'el':
        return 'Σύνοψη & Άδειες';
      case 'sv':
        return 'Sammanfattning';
      case 'pl':
        return 'Podsumowanie i zgody';
      case 'id':
        return 'Ringkasan & Izin';
      case 'th':
        return 'สรุปและสิทธิ์';
      case 'vi':
        return 'Tóm tắt & Quyền';
      case 'en':
      default:
        return 'Summary & Permissions';
    }
  }

  static String getTabArticles(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Tam Hukuki Metin (10 Madde)';
      case 'de':
        return 'Volltext (10 Artikel)';
      case 'fr':
        return 'Texte complet (10 Articles)';
      case 'es':
        return 'Texto legal completo';
      case 'it':
        return 'Testo legale completo';
      case 'pt':
        return 'Texto legal completo';
      case 'ru':
        return 'Полный текст (10 статей)';
      case 'zh':
        return '完整法律条款（共10条）';
      case 'ja':
        return '完全な法的条項（全10条）';
      case 'ko':
        return '전문 약관 (총 10조)';
      case 'ar':
        return 'النص القانوني الكامل (10 بنود)';
      case 'hi':
        return 'पूर्ण कानूनी अनुबंध (10 धाराएं)';
      case 'nl':
        return 'Volledige tekst (10 artikelen)';
      case 'el':
        return 'Πλήρες νομικό κείμενο';
      case 'sv':
        return 'Fullständig lagtext';
      case 'pl':
        return 'Pełny tekst prawny';
      case 'id':
        return 'Teks Hukum Lengkap';
      case 'th':
        return 'ข้อความกฎหมายฉบับเต็ม';
      case 'vi':
        return 'Toàn văn pháp lý (10 Điều)';
      case 'en':
      default:
        return 'Full Legal Text (10 Articles)';
    }
  }

  static String getReviewButtonLabel(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Sözleşmeyi İncele';
      case 'de':
        return 'Vereinbarung prüfen';
      case 'fr':
        return 'Consulter l\'accord';
      case 'es':
        return 'Revisar acuerdo';
      case 'it':
        return 'Vedi accordo';
      case 'pt':
        return 'Revisar termos';
      case 'ru':
        return 'Ознакомиться';
      case 'zh':
        return '查阅协议';
      case 'ja':
        return '規約を確認';
      case 'ko':
        return '약관 검토';
      case 'ar':
        return 'مراجعة الاتفاقية';
      case 'hi':
        return 'अनुबंध देखें';
      case 'nl':
        return 'Overeenkomst bekijken';
      case 'el':
        return 'Έλεγχος συμφωνίας';
      case 'sv':
        return 'Granska avtal';
      case 'pl':
        return 'Sprawdź umowę';
      case 'id':
        return 'Tinjau Perjanjian';
      case 'th':
        return 'ตรวจสอบข้อตกลง';
      case 'vi':
        return 'Xem thỏa thuận';
      case 'en':
      default:
        return 'Review Agreement';
    }
  }

  // --- Checkbox Labels ---
  static String getMandatoryTermsCheckbox(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kullanıcı Sözleşmesi ve Gizlilik Politikasını okudum, anladım ve kabul ediyorum. (Zorunlu)';
      case 'de':
        return 'Ich habe die Nutzervereinbarung und die Datenschutzerklärung gelesen und stimme ihnen zu. (Erforderlich)';
      case 'fr':
        return 'J\'ai lu, compris et j\'accepte les Conditions d\'utilisation et la Politique de confidentialité. (Obligatoire)';
      case 'es':
        return 'He leído, comprendo y acepto los Términos de uso y la Política de privacidad. (Obligatorio)';
      case 'it':
        return 'Ho letto, compreso e accetto i Termini di servizio e l\'Informativa sulla privacy. (Obbligatorio)';
      case 'pt':
        return 'Li, compreendo e concordo com os Termos de Uso e a Política de Privacidade. (Obrigatório)';
      case 'ru':
        return 'Я прочитал(-а) и принимаю Пользовательское соглашение и Политику конфиденциальности. (Обязательно)';
      case 'zh':
        return '我已阅读、理解并同意《用户协议》和《隐私政策》。（必选）';
      case 'ja':
        return '利用規約およびプライバシーポリシーを読み、理解し、同意します。（必須）';
      case 'ko':
        return '이용약관 및 개인정보 처리방침을 읽고 이해했으며 이에 동의합니다. (필수)';
      case 'ar':
        return 'لقد قرأت وفهمت وأوافق على اتفاقية المستخدم وسياسة الخصوصية. (إلزامي)';
      case 'hi':
        return 'मैंने उपयोगकर्ता अनुबंध और गोपनीयता नीति को पढ़ लिया है और सहमति देता हूं। (अनिवार्य)';
      case 'nl':
        return 'Ik heb de Gebruikersovereenkomst en het Privacybeleid gelezen en ga ermee akkoord. (Verplicht)';
      case 'el':
        return 'Διάβασα και αποδέχομαι τη Συμφωνία Χρήστη και την Πολιτική Απορρήτου. (Υποχρεωτικό)';
      case 'sv':
        return 'Jag har läst och godkänner Användaravtalet och Integritetspolicyn. (Obligatoriskt)';
      case 'pl':
        return 'Przeczytałem(-am) i akceptuję Regulamin oraz Politykę prywatności. (Wymagane)';
      case 'id':
        return 'Saya telah membaca, memahami, dan menyetujui Ketentuan Pengguna & Kebijakan Privasi. (Wajib)';
      case 'th':
        return 'ฉันได้อ่าน เข้าใจ และยอมรับข้อตกลงผู้ใช้และนโยบายความเป็นส่วนตัว (จำเป็น)';
      case 'vi':
        return 'Tôi đã đọc, hiểu và đồng ý với Thỏa thuận người dùng và Chính sách quyền riêng tư. (Bắt buộc)';
      case 'en':
      default:
        return 'I have read, understood, and accept the User Agreement and Privacy Policy. (Required)';
    }
  }

  static String getMandatoryDataConsentCheckbox(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kişisel, seyahat, bagaj ve kasa verilerimin yukarıda açıklanan amaçlarla işlenmesine ve saklanmasına açık rıza veriyorum. (Zorunlu)';
      case 'de':
        return 'Ich willige ausdrücklich in die Verarbeitung und sichere Speicherung meiner persönlichen Reise- und Dokumentdaten ein. (Erforderlich)';
      case 'fr':
        return 'Je consens expressément au traitement et au stockage sécurisé de mes données de voyage et documents. (Obligatoire)';
      case 'es':
        return 'Doy mi consentimiento explícito para el procesamiento y almacenamiento seguro de mis datos personales y de viaje. (Obligatorio)';
      case 'it':
        return 'Presto il mio consenso esplicito al trattamento e alla conservazione sicura dei miei dati personali e di viaggio. (Obbligatorio)';
      case 'pt':
        return 'Consinto expressamente com o processamento e armazenamento seguro dos meus dados de viagem e documentos. (Obrigatório)';
      case 'ru':
        return 'Я даю явное согласие на обработку и безопасное хранение моих персональных данных и информации о поездках. (Обязательно)';
      case 'zh':
        return '我明确同意按照上述目的处理和安全存储我的个人行程与保险箱数据。（必选）';
      case 'ja':
        return '上記の目的において、旅行および金庫データの処理と安全な保管に明示的に同意します。（必須）';
      case 'ko':
        return '상기 목적에 따라 본인의 개인정보, 여행 및 금고 데이터를 안전하게 처리하고 저장하는 것에 명시적으로 동의합니다. (필수)';
      case 'ar':
        return 'أوافق صراحةً على معالجة وتخزين بياناتي الشخصية وبيانات السفر والخزنة بشكل آمن. (إلزامي)';
      case 'hi':
        return 'मैं उल्लिखित उद्देश्यों के लिए अपने व्यक्तिगत और यात्रा डेटा के प्रसंस्करण और भंडारण के लिए स्पष्ट सहमति देता हूं। (अनिवार्य)';
      case 'nl':
        return 'Ik geef uitdrukkelijke toestemming voor de verwerking en veilige opslag van mijn reis- en kluisgegevens. (Verplicht)';
      case 'el':
        return 'Δίνω τη ρητή συγκατάθεσή μου για την επεξεργασία και ασφαλή αποθήκευση των δεδομένων μου. (Υποχρεωτικό)';
      case 'sv':
        return 'Jag ger mitt uttryckliga samtycke till behandling och säker lagring av mina personuppgifter. (Obligatoriskt)';
      case 'pl':
        return 'Wyrażam wyraźną zgodę na przetwarzanie i bezpieczne przechowywanie moich danych podróży. (Wymagane)';
      case 'id':
        return 'Saya memberikan persetujuan eksplisit untuk pemrosesan dan penyimpanan aman data saya. (Wajib)';
      case 'th':
        return 'ฉันยินยอมอย่างชัดแจ้งในการประมวลผลและจัดเก็บข้อมูลส่วนบุคคลและการเดินทางของฉันอย่างปลอดภัย (จำเป็น)';
      case 'vi':
        return 'Tôi đồng ý rõ ràng cho việc xử lý và lưu trữ an toàn dữ liệu cá nhân và chuyến đi của tôi. (Bắt buộc)';
      case 'en':
      default:
        return 'I give explicit consent to the processing and secure storage of my personal, travel, and vault data as detailed above. (Required)';
    }
  }

  static String getOptionalAnalyticsCheckbox(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Uygulama deneyimini geliştirmek amacıyla anonim telemetri ve hata raporlarının toplanmasını onaylıyorum. (İsteğe Bağlı)';
      case 'de':
        return 'Ich willige in anonymisierte Telemetrie und Fehlerberichte zur Verbesserung der App-Stabilität ein. (Optional)';
      case 'fr':
        return 'J\'accepte les rapports de télémétrie et d\'erreurs anonymes pour améliorer la stabilité. (Facultatif)';
      case 'es':
        return 'Acepto compartir telemetría anónima e informes de errores para mejorar la aplicación. (Opcional)';
      case 'it':
        return 'Accetto la condivisione di dati anonimi di telemetria e crash per migliorare l\'app. (Facoltativo)';
      case 'pt':
        return 'Concordo com a telemetria anônima e relatórios de falhas para aprimorar a estabilidade. (Opcional)';
      case 'ru':
        return 'Я согласен(-на) на сбор анонимной телеметрии и отчетов об ошибках для улучшения приложения. (Необязательно)';
      case 'zh':
        return '我同意收集匿名遥测与崩溃报告以优化应用性能与稳定性。（可选）';
      case 'ja':
        return 'アプリの安定性向上のため、匿名のテレメトリおよびクラッシュレポートの収集に同意します。（任意）';
      case 'ko':
        return '앱 품질 개선을 위해 익명 진단 및 충돌 보고서 수집에 동의합니다. (선택)';
      case 'ar':
        return 'أوافق على جمع تقارير القياس والأخطاء المجهولة لتحسين استقرار التطبيق. (اختياري)';
      case 'hi':
        return 'मैं ऐप अनुभव को बेहतर बनाने के लिए अनाम टेलीमेट्री और त्रुटि रिपोर्ट के संग्रह की अनुमति देता हूं। (वैकल्पिक)';
      case 'nl':
        return 'Ik ga akkoord met anonieme telemetrie en foutrapporten om de app te verbeteren. (Optioneel)';
      case 'el':
        return 'Συμφωνώ με τη συλλογή ανώνυμων αναφορών σφαλμάτων για τη βελτίωση της εφαρμογής. (Προαιρετικό)';
      case 'sv':
        return 'Jag godkänner anonym telemetri och felrapporter för att förbättra appens stabilitet. (Valfritt)';
      case 'pl':
        return 'Zgadzam się na anonimowe raporty o błędach w celu poprawy stabilności aplikacji. (Opcjonalne)';
      case 'id':
        return 'Saya menyetujui pengumpulan telemetri anonim untuk meningkatkan stabilitas aplikasi. (Opsional)';
      case 'th':
        return 'ฉันยินยอมให้รวบรวมข้อมูลการทำงานและรายงานข้อผิดพลาดแบบไม่ระบุตัวตน (ไม่บังคับ)';
      case 'vi':
        return 'Tôi đồng ý gửi dữ liệu ẩn danh và báo cáo sự cố để nâng cao trải nghiệm ứng dụng. (Tùy chọn)';
      case 'en':
      default:
        return 'I agree to anonymous telemetry and crash reports (PostHog EU) to improve app stability. (Optional)';
    }
  }

  // --- Buttons ---
  static String getAcceptButton(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Onayla ve Devam Et';
      case 'de':
        return 'Zustimmen und Weiter';
      case 'fr':
        return 'Accepter et Continuer';
      case 'es':
        return 'Aceptar y Continuar';
      case 'it':
        return 'Accetta e Continua';
      case 'pt':
        return 'Aceitar e Continuar';
      case 'ru':
        return 'Принять и продолжить';
      case 'zh':
        return '同意并继续';
      case 'ja':
        return '同意して続行';
      case 'ko':
        return '동의하고 계속하기';
      case 'ar':
        return 'الموافقة والمتابعة';
      case 'hi':
        return 'स्वीकार करें और जारी रखें';
      case 'nl':
        return 'Akkoord en Doorgaan';
      case 'el':
        return 'Αποδοχή & Συνέχεια';
      case 'sv':
        return 'Godkänn och Fortsätt';
      case 'pl':
        return 'Akceptuj i kontynuuj';
      case 'id':
        return 'Setujui & Lanjutkan';
      case 'th':
        return 'ยอมรับและดำเนินการต่อ';
      case 'vi':
        return 'Đồng ý & Tiếp tục';
      case 'en':
      default:
        return 'Accept & Continue';
    }
  }

  static String getDeclineButton(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Reddet ve Çıkış Yap';
      case 'de':
        return 'Ablehnen und Beenden';
      case 'fr':
        return 'Refuser et Quitter';
      case 'es':
        return 'Rechazar y Salir';
      case 'it':
        return 'Rifiuta ed Esci';
      case 'pt':
        return 'Recusar e Sair';
      case 'ru':
        return 'Отклонить и выйти';
      case 'zh':
        return '拒绝并退出';
      case 'ja':
        return '拒否して終了';
      case 'ko':
        return '거부하고 종료';
      case 'ar':
        return 'رفض والخروج';
      case 'hi':
        return 'अस्वीकार करें और बाहर निकलें';
      case 'nl':
        return 'Weigeren en Afsluiten';
      case 'el':
        return 'Απόρριψη & Έξοδος';
      case 'sv':
        return 'Avvisa och Avsluta';
      case 'pl':
        return 'Odrzuć i wyjdź';
      case 'id':
        return 'Tolak & Keluar';
      case 'th':
        return 'ปฏิเสธและออก';
      case 'vi':
        return 'Từ chối & Thoát';
      case 'en':
      default:
        return 'Decline & Exit';
    }
  }

  static String getDeclineDialogTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Sözleşmeyi Reddetmek Üzeresiniz';
      case 'de':
        return 'Zustimmung verweigern?';
      case 'fr':
        return 'Refuser les conditions ?';
      case 'es':
        return '¿Rechazar el consentimiento?';
      case 'it':
        return 'Rifiutare il consenso?';
      case 'pt':
        return 'Recusar o consentimento?';
      case 'ru':
        return 'Отклонить соглашение?';
      case 'zh':
        return '确定拒绝协议？';
      case 'ja':
        return '同意を拒否しますか？';
      case 'ko':
        return '동의를 거부하시겠습니까?';
      case 'ar':
        return 'هل تريد رفض الاتفاقية؟';
      case 'hi':
        return 'क्या आप सहमति अस्वीकार करना चाहते हैं?';
      case 'nl':
        return 'Toestemming weigeren?';
      case 'el':
        return 'Απόρριψη συμφωνίας;';
      case 'sv':
        return 'Avvisa villkor?';
      case 'pl':
        return 'Odrzucić zgodę?';
      case 'id':
        return 'Tolak Perjanjian?';
      case 'th':
        return 'ปฏิเสธข้อตกลงหรือไม่?';
      case 'vi':
        return 'Từ chối thỏa thuận?';
      case 'en':
      default:
        return 'Decline Agreement?';
    }
  }

  static String getDeclineDialogContent(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'KVKK ve GDPR mevzuatları uyarınca, veri işleme ve kullanıcı sözleşmesi onaylanmadan PackBuddy uygulaması kullanılamaz. Onay vermediğiniz takdirde oturumunuz kapatılacaktır. Çıkmak istediğinize emin misiniz?';
      case 'de':
        return 'Gemäß DSGVO kann PackBuddy ohne Ihre Zustimmung zur Datenverarbeitung nicht verwendet werden. Wenn Sie ablehnen, werden Sie abgemeldet. Möchten Sie wirklich beenden?';
      case 'fr':
        return 'Conformément au RGPD, PackBuddy ne peut être utilisé sans votre consentement au traitement des données. Vous serez déconnecté. Êtes-vous sûr de vouloir quitter ?';
      case 'es':
        return 'Conforme al RGPD, PackBuddy no puede utilizarse sin aceptar el tratamiento de datos. Se cerrará su sesión. ¿Está seguro de que desea salir?';
      case 'it':
        return 'In conformità al GDPR, PackBuddy non può essere utilizzata senza il consenso al trattamento dei dati. Verrà effettuato il logout. Sei sicuro di voler uscire?';
      case 'pt':
        return 'De acordo com o GDPR/LGPD, o PackBuddy não pode ser utilizado sem consentimento de dados. Você será desconectado. Tem certeza de que deseja sair?';
      case 'ru':
        return 'В соответствии с GDPR, PackBuddy не может использоваться без согласия на обработку данных. Вы выйдете из учетной записи. Вы уверены?';
      case 'zh':
        return '根据 GDPR 及相关隐私法规，未同意用户协议及数据许可前无法使用 PackBuddy。若拒绝，系统将退出登录。确认退出吗？';
      case 'ja':
        return 'GDPR等のプライバシー規程に基づき、同意なしにPackBuddyを利用することはできません。拒否した場合はログアウトされます。終了しますか？';
      case 'ko':
        return 'GDPR 및 개인정보보호법에 따라 데이터 처리 동의 없이는 PackBuddy를 사용할 수 없습니다. 거부 시 로그아웃됩니다. 종료하시겠습니까?';
      case 'ar':
        return 'وفقًا لقوانين حماية البيانات، لا يمكن استخدام PackBuddy دون الموافقة على معالجة البيانات. سيتم تسجيل خروجك. هل أنت متأكد؟';
      case 'hi':
        return 'डेटा सुरक्षा नियमों के अनुसार, डेटा प्रसंस्करण की सहमति के बिना PackBuddy का उपयोग नहीं किया जा सकता है। क्या आप बाहर निकलना चाहते हैं?';
      case 'nl':
        return 'Onder de AVG kan PackBuddy niet worden gebruikt zonder toestemming voor gegevensverwerking. U wordt uitgelogd. Weet u het zeker?';
      case 'el':
        return 'Σύμφωνα με τον GDPR, η εφαρμογή δεν μπορεί να χρησιμοποιηθεί χωρίς συγκατάθεση. Θα αποσυνδεθείτε. Είστε σίγουροι;';
      case 'sv':
        return 'Enligt GDPR kan PackBuddy inte användas utan databehandlingssamtycke. Du kommer att loggas ut. Är du säker?';
      case 'pl':
        return 'Zgodnie z RODO, PackBuddy nie może być używany bez zgody na przetwarzanie danych. Zostaniesz wylogowany(-a). Czy na pewno chcesz wyjść?';
      case 'id':
        return 'Berdasarkan regulasi privasi, PackBuddy tidak dapat digunakan tanpa persetujuan pemrosesan data. Anda akan keluar akun. Anda yakin?';
      case 'th':
        return 'ตามข้อกำหนดความเป็นส่วนตัว PackBuddy ไม่สามารถใช้งานได้หากไม่ได้รับความยินยอม คุณต้องการออกจากระบบหรือไม่?';
      case 'vi':
        return 'Theo quy định bảo vệ dữ liệu, bạn không thể sử dụng PackBuddy nếu không đồng ý. Bạn sẽ bị đăng xuất. Bạn có chắc chắn muốn thoát?';
      case 'en':
      default:
        return 'In accordance with GDPR, KVKK, and privacy regulations, PackBuddy cannot be used without accepting the User Agreement and Data Consent. You will be logged out. Are you sure you want to exit?';
    }
  }

  static String getValidationMustAccept(String? lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Uygulamayı kullanabilmek için lütfen zorunlu onay kutularını işaretleyiniz.';
      case 'de':
        return 'Bitte aktivieren Sie die erforderlichen Kontrollkästchen, um fortzufahren.';
      case 'fr':
        return 'Veuillez cocher les cases obligatoires pour continuer.';
      case 'es':
        return 'Por favor marque las casillas obligatorias para continuar.';
      case 'it':
        return 'Seleziona le caselle obbligatorie per continuare.';
      case 'pt':
        return 'Marque as caixas obrigatórias para continuar.';
      case 'ru':
        return 'Пожалуйста, отметьте обязательные поля для продолжения.';
      case 'zh':
        return '请先勾选必选条款以继续使用。';
      case 'ja':
        return '続行するには必須のチェックボックスをオンにしてください。';
      case 'ko':
        return '계속하려면 필수 항목에 동의해 주세요.';
      case 'ar':
        return 'يرجى تحديد مربعات الاختيار الإلزامية للمتابعة.';
      case 'hi':
        return 'कृपया आगे बढ़ने के लिए अनिवार्य बॉक्स चेक करें।';
      case 'nl':
        return 'Vink de verplichte vakjes aan om door te gaan.';
      case 'el':
        return 'Επιλέξτε τα υποχρεωτικά πλαίσια για να συνεχίσετε.';
      case 'sv':
        return 'Markera de obligatoriska rutorna för att fortsätta.';
      case 'pl':
        return 'Zaznacz wymagane pola, aby kontynuować.';
      case 'id':
        return 'Harap centang kotak wajib untuk melanjutkan.';
      case 'th':
        return 'โปรดทำเครื่องหมายในช่องที่จำเป็นเพื่อดำเนินการต่อ';
      case 'vi':
        return 'Vui lòng đánh dấu vào các ô bắt buộc để tiếp tục.';
      case 'en':
      default:
        return 'Please check the required checkboxes to continue using the application.';
    }
  }

  static String getAcceptedStatus(String? lang, String version, String? dateStr) {
    final clean = _cleanLang(lang);
    if (clean == 'tr') {
      return 'Sözleşme Onaylandı: Sürüm $version';
    }
    return 'Agreement Accepted: Version $version';
  }

  static String getCloseButton(String? lang) {
    final clean = _cleanLang(lang);
    switch (clean) {
      case 'tr':
        return 'Kapat';
      case 'de':
        return 'Schließen';
      case 'fr':
        return 'Fermer';
      case 'es':
        return 'Cerrar';
      case 'it':
        return 'Chiudi';
      case 'pt':
        return 'Fechar';
      case 'ru':
        return 'Закрыть';
      case 'zh':
        return '关闭';
      case 'ja':
        return '閉じる';
      case 'ko':
        return '닫기';
      case 'ar':
        return 'إغلاق';
      default:
        return 'Close';
    }
  }

  // --- 8 Data & Permission Summary Cards ---
  static List<LegalSummaryCategory> getCategories(String? lang) {
    final clean = _cleanLang(lang);

    if (clean == 'tr') {
      return const [
        LegalSummaryCategory(
          icon: Icons.badge_outlined,
          accentColor: Color(0xFF2563EB),
          title: '1. Hesap ve Kimlik Verileri',
          subtitle: 'Kayıt, oturum ve profil yönetimi',
          bulletPoints: [
            'E-posta adresi, ad/soyad, kullanıcı takma adı ve Firebase UID kimliği toplanır.',
            'Oturum süresi, son aktif zamanı ve hesap oluşturma tarihi saklanır.',
            'Parolanız Google Firebase scrypt/PBKDF2 ile kriptografik olarak hashlenir; sistem yöneticileri dahil kimse düz metin parolanızı göremez.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.luggage_outlined,
          accentColor: Color(0xFF0D9488),
          title: '2. Seyahat, Bagaj ve Paketleme Verileri',
          subtitle: 'Kişisel gezi yönetimi ve liste senkronizasyonu',
          bulletPoints: [
            'Oluşturulan geziler, destinasyonlar, gidiş/dönüş tarihleri ve gezi bütçeleri kaydedilir.',
            'Bagaj profilleri (marka, ebat, dara ağırlığı, havayolu limitleri ve bagaj fotoğrafları) saklanır.',
            'Paketleme listeleri, eşya isimleri, miktarları, kategorileri ve özel ağırlıkları Firestore bulutunda yedeklenir.',
            'Ziyaret edilen ülkeler ve seyahat haritanızdaki işaretlemeler profilinize kaydedilir.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.lock_outline_rounded,
          accentColor: Color(0xFFD97706),
          title: '3. Şifreli Belge Kasası (AES-256)',
          subtitle: 'Pasaport, bilet ve rezervasyon belgeleri',
          bulletPoints: [
            'Kasaya eklenen pasaport, biniş kartı, otel rezervasyonu ve sigorta belgeleri cihazınızda yerel olarak AES-256 (PBENC1 standardı) ile şifrelenir.',
            'Kasa PIN kodu yalnızca tuzlanmış kriptografik hash formatında cihaz belleğinde tutulur.',
            'Android FLAG_SECURE özelliği ile Kasa açıkken ekran görüntüsü alınması ve üçüncü parti casus kayıtlar tamamen engellenir.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.fingerprint_rounded,
          accentColor: Color(0xFF10B981),
          title: '4. Biyometrik Kimlik Güvencesi',
          subtitle: 'Parmak izi ve Face ID verisi güvencesi',
          bulletPoints: [
            'Parmak izi veya yüz tanıma verileriniz ASLA sunucularımıza, Firebase\'e veya üçüncü taraflara iletilmez.',
            'Tüm biyometrik doğrulamalar doğrudan cihazınızın donanımsal güvenlik çipinde (Apple Secure Enclave veya Android Hardware Keystore) yerel olarak yürütülür.',
            'Uygulamamıza yalnızca "doğrulama başarılı" ya da "başarısız" bayrağı döner.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.perm_device_information_rounded,
          accentColor: Color(0xFF6366F1),
          title: '5. Cihaz Donanım ve Sistem İzinleri',
          subtitle: 'Kamera, medya, bildirim ve widget yetkileri',
          bulletPoints: [
            'Kamera: Yalnızca bagaj fotoğrafı ekleme ve kasa belgelerini tarama anında kullanıcının açık onayıyla kullanılır. Arka planda asla çalışmaz.',
            'Medya/Depolama: Cihazınızdan yalnızca seçtiğiniz seyahat belgesi veya fotoğrafların aktarılması için kullanılır.',
            'Bildirimler: Uçuş alarmları, paketleme hatırlatıcıları ve hesap güvenlik uyarıları göndermek için yerel ve FCM bildirimleri kullanılır.',
            'Ana Ekran Widget\'ı: Aktif gezi geri sayımı ve canlı kurların kilit ekranında gösterilmesi için sistem widget veri aktarımı kullanılır.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.language_rounded,
          accentColor: Color(0xFF8B5CF6),
          title: '6. Ağ Lokasyonu ve Canlı Para Birimi',
          subtitle: 'IP lokasyonu ile otomatik seyahat kuru',
          bulletPoints: [
            'PackBuddy arka planda sürekli GPS konum takibi YAPMAZ.',
            'Yalnızca seyahat ettiğiniz ülkeye uygun otomatik para birimi ve yerel tavsiyeleri sunmak amacıyla IP adresi üzerinden kaba (şehir/ülke düzeyinde) HTTPS araması yapılır.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.analytics_outlined,
          accentColor: Color(0xFFEC4899),
          title: '7. Analitik, Telemetri ve PostHog (EU Cloud)',
          subtitle: 'Sıkı PII sansürleme ile performans takibi',
          bulletPoints: [
            'Uygulama kararlılığını artırmak ve çökmeleri gidermek için PostHog AB sunucuları (Frankfurt, Almanya) kullanılır.',
            'Sıkı PII Sansürü: maskAllTexts ve maskAllImages bayrakları aktiftir. Özel gezi notlarınız, kasa belgeleriniz veya fotoğraflarınız analitiğe ASLA dahil edilmez.',
            'İsteğe bağlı analitik veri paylaşımını onay ekranından dilediğiniz an kapatabilirsiniz.',
          ],
        ),
        LegalSummaryCategory(
          icon: Icons.security_update_good_rounded,
          accentColor: Color(0xFF059669),
          title: '8. Veri Haklarınız ve Kalıcı Silme',
          subtitle: 'KVKK Madde 11 ve GDPR Madde 15-22 uyumluluğu',
          bulletPoints: [
            'İstediğiniz zaman verilerinizin dökümünü alma ve taşınabilirlik talep etme hakkına sahipsiniz.',
            'Ayarlar menüsünden "Hesabı ve Verileri Sil" seçeneğini kullanarak buluttaki ve cihazdaki tüm seyahat, bagaj ve kasa verilerinizi anında ve kalıcı olarak sildirebilirsiniz (Unutulma Hakkı).',
            'Tüm veritabanı iletişimi TLS 1.3 şifreleme ve Google Cloud Firestore veri merkezi koruması altındadır.',
          ],
        ),
      ];
    }

    // Default English (and universal international fallback)
    return const [
      LegalSummaryCategory(
        icon: Icons.badge_outlined,
        accentColor: Color(0xFF2563EB),
        title: '1. Account & Identity Data',
        subtitle: 'Registration, session, and profile management',
        bulletPoints: [
          'Email address, full name / display name, and Firebase UID identifier are collected.',
          'Active session duration, last active time, and account creation date are recorded.',
          'Passwords are cryptographic hashes (scrypt/PBKDF2); nobody, including platform administrators, can view raw passwords.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.luggage_outlined,
        accentColor: Color(0xFF0D9488),
        title: '2. Travel, Luggage & Packing Data',
        subtitle: 'Trip organization and checklist cloud synchronization',
        bulletPoints: [
          'Created trips, destinations, departure/return dates, and trip budgets are stored.',
          'Luggage profiles (brand, dimensions, tare weight, airline limits, photos) are synced to cloud.',
          'Packing checklists, items, categories, and custom weights are securely stored in Google Cloud Firestore.',
          'Visited countries and pins on your travel map are saved to your account.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.lock_outline_rounded,
        accentColor: Color(0xFFD97706),
        title: '3. Encrypted Document Vault (AES-256)',
        subtitle: 'Passports, boarding passes, and bookings',
        bulletPoints: [
          'Passports, flight tickets, hotel reservations, and private photos added to Vault are encrypted on-device with AES-256 (PBENC1 format).',
          'Vault PIN code is stored solely as a salted cryptographic hash.',
          'Android FLAG_SECURE prevents screenshots and unauthorized third-party spyware recording while Vault is open.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.fingerprint_rounded,
        accentColor: Color(0xFF10B981),
        title: '4. Biometric Authentication Guarantee',
        subtitle: 'Fingerprint and Face ID safety guarantee',
        bulletPoints: [
          'Biometric data (fingerprints, Face ID) is NEVER transmitted to PackBuddy servers, Firebase, or third parties.',
          'Biometric authentication is executed entirely on your local device hardware chip (Apple Secure Enclave or Android Hardware Keystore).',
          'Our application only receives a boolean pass/fail validation token.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.perm_device_information_rounded,
        accentColor: Color(0xFF6366F1),
        title: '5. Hardware & Device Permissions',
        subtitle: 'Camera, media, notification, and widget permissions',
        bulletPoints: [
          'Camera: Used solely for capturing luggage photos or scanning vault documents upon user action. Never runs in background.',
          'Photo Library / Storage: Used solely to select tickets and photos you choose to import.',
          'Notifications: Used for departure alarms, packing reminders, and critical account security alerts via local/FCM channels.',
          'Home Screen Widget: Syncs trip countdowns and exchange rates to lock/home screen widgets via system IPC.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.language_rounded,
        accentColor: Color(0xFF8B5CF6),
        title: '6. Network Geolocation & Live Currency',
        subtitle: 'Coarse IP lookup for automatic travel currencies',
        bulletPoints: [
          'PackBuddy DOES NOT continuously track your precise GPS coordinates in the background.',
          'Coarse IP lookup (city/country level via HTTPS) and system timezone are used exclusively to determine appropriate local currencies and travel advice.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.analytics_outlined,
        accentColor: Color(0xFFEC4899),
        title: '7. Analytics & Telemetry (PostHog EU Cloud)',
        subtitle: 'Strict PII masking and application stability monitoring',
        bulletPoints: [
          'PostHog EU Cloud (Frankfurt, Germany data centers) is used to analyze app stability and prevent crashes.',
          'Strict PII Masking: maskAllTexts and maskAllImages flags are active. Private notes, vault documents, and photos are NEVER captured or visible to telemetry.',
          'You may opt out of non-essential analytics at any time via the consent toggles.',
        ],
      ),
      LegalSummaryCategory(
        icon: Icons.security_update_good_rounded,
        accentColor: Color(0xFF059669),
        title: '8. User Rights & Data Deletion',
        subtitle: 'GDPR Articles 15-22 and KVKK Article 11 compliance',
        bulletPoints: [
          'You have the legal right to request access, rectification, and portability of your stored personal data.',
          'You may permanently erase your account, all trips, luggage, and vault documents at any time via the "Delete Account" option (Right to be Forgotten).',
          'All communications are secured with TLS 1.3 encryption and Google Cloud enterprise storage.',
        ],
      ),
    ];
  }

  // --- 10 Detailed Legal Articles ---
  static List<LegalArticle> getArticles(String? lang) {
    final clean = _cleanLang(lang);

    if (clean == 'tr') {
      return const [
        LegalArticle(
          number: 1,
          title: 'Taraflar, Amaç ve Hukuki Kapsam',
          content: 'Bu Kullanıcı ve İzin Sözleşmesi ("Sözleşme"), PackBuddy uygulaması ("Uygulama", "Platform", "Veri Sorumlusu") ile bu uygulamayı mobil veya web cihazına indiren, kuran, hesap oluşturan veya herhangi bir biçimde kullanan gerçek kişi ("Kullanıcı") arasında akdedilmiştir.\n\nİşbu sözleşme; 6698 Sayılı Kişisel Verilerin Korunması Kanunu (KVKK), Avrupa Birliği Genel Veri Koruma Tüzüğü (GDPR - Regulation EU 2016/679), Kaliforniya Tüketici Gizliliği Yasası (CCPA/CPRA), Apple App Store İnceleme Yönergeleri Madde 5.1 (Veri Gizliliği) ve Google Play Geliştirici Programı Politikaları uyarınca hazırlanmış olup, tarafların yasal hak ve sorumluluklarını bağlayıcı biçimde düzenler.',
        ),
        LegalArticle(
          number: 2,
          title: 'Toplanan, İşlenen ve Saklanan Veri Kategorileri',
          content: 'PackBuddy aşağıdaki veri kategorilerini toplamakta, şifrelemekte ve saklamaktadır:\n\n'
              'a) Hesap ve Kimlik Bilgileri: E-posta adresi, ad-soyad, kullanıcı takma adı, Firebase Authentication benzersiz kullanıcı kimliği (UID), profil avatar bağlantısı, kayıt tarihi, son oturum açma zamanı, aktif oturum süresi ve oturum geçmişi.\n\n'
              'b) Seyahat ve Organizasyon Bilgileri: Gezi adları, hedef ülkeler ve şehirler, kalkış/varış tarihleri, gezi notları, ziyaret edilen ülkeler harita kayıtları.\n\n'
              'c) Bagaj ve Eşya Listeleri: Bagaj modelleri, fiziksel ebatlar, dara (boş) ağırlıkları, havayolu limitleri, bagaj fotoğrafları, paketleme kontrol listeleri, eşya isimleri, miktarları, kategorileri ve özel ağırlıkları.\n\n'
              'd) Harcama ve Bütçe Bilgileri: Seyahat harcamaları, harcama kalemleri, para birimleri, fiş/fatura kur kayıtları.\n\n'
              'e) Gizli Belge Kasası Verileri: Pasaport kopyaları, biniş kartları, bilet PDF\'leri, otel rezervasyon belgeleri ve özel fotoğraflar. Bu veriler cihazda yerel AES-256 (PBENC1 standardı) ile şifrelenir.\n\n'
              'f) Kasa PIN Kodu: Kullanıcı tarafından belirlenen şifre, tuzlanmış kriptografik hash olarak tutulur; düz metin olarak asla kaydedilmez.',
        ),
        LegalArticle(
          number: 3,
          title: 'Verilerin İşlenme Amaçları ve Hukuki Dayanakları',
          content: 'Toplanan veriler aşağıdaki meşru amaçlarla işlenir (GDPR Md. 6, KVKK Md. 5):\n\n'
              '• Kullanıcı hesabının oluşturulması, kimlik doğrulaması ve güvenliğinin sağlanması,\n'
              '• Seyahat, bagaj ve paketleme listelerinin cihazlar arasında senkronize edilmesi,\n'
              '• Havayolu ağırlık limitlerine göre fazla bagaj uyarılarının hesaplanması,\n'
              '• Gizli belgelerin cihazda yüksek güvenlikli şifrelenerek saklanması,\n'
              '• Kullanıcının bulunduğu coğrafi bölgeye göre otomatik canlı döviz kurlarının sunulması,\n'
              '• Kullanıcının açık rızası ve sözleşmenin ifası hukuki sebeplerine dayalı olarak.',
        ),
        LegalArticle(
          number: 4,
          title: 'Biyometrik Verilerin Yerel İşlenmesi ve Yasal Güvence',
          content: 'Kullanıcı, Gizli Kasa kilidini açmak için Parmak İzi (Touch ID / Fingerprint) veya Yüz Tanıma (Face ID / Biometric Prompt) özelliklerini etkinleştirebilir.\n\n'
              'ÖNEMLİ YASAL TAAHHÜT: Biyometrik veriler hiçbir koşulda PackBuddy sunucularına, Firebase\'e veya herhangi bir üçüncü tarafa iletilmez, kopyalanmaz veya saklanmaz. Biyometrik eşleştirme işlemi tamamen kullanıcının kendi cihazının donanımsal güvenlik çipinde (Apple Secure Enclave veya Android Hardware Keystore) yerel olarak yürütülür. PackBuddy işletim sisteminden yalnızca doğrulamanın başarılı veya başarısız olduğuna dair kriptografik bir bayrak alır.',
        ),
        LegalArticle(
          number: 5,
          title: 'Cihaz Donanımı ve Sistem İzinleri',
          content: 'Uygulama aşağıdaki sistem izinlerini yalnızca belirtilen meşru ihtiyaçlar için talep eder:\n\n'
              '• Kamera İzni (android.permission.CAMERA): Yalnızca bagaj fotoğrafı ekleme ve Kasa için seyahat belgelerini fotoğraflama anında kullanıcının açık eylemiyle kullanılır. Arka planda gizli çekim yapılmaz.\n\n'
              '• Fotoğraf ve Depolama İzni (READ_MEDIA_IMAGES / READ_EXTERNAL_STORAGE): Kullanıcının seçtiği bilet PDF\'lerini veya seyahat fotoğraflarını yüklemek için kullanılır. Cihazdaki diğer kişisel dosyalara erişilmez.\n\n'
              '• Bildirim İzni (POST_NOTIFICATIONS): Kalkış geri sayımları, paketleme alarmları ve kritik hesap bildirimlerinin iletilmesi için yerel ve FCM bildirimleri kullanılır.\n\n'
              '• Ağ Durumu ve İnternet (INTERNET, ACCESS_NETWORK_STATE): Firestore bulut yedekleme, döviz kurları sorgulama ve çoklu cihaz senkronizasyonu için zorunludur.\n\n'
              '• Ana Ekran Widget Hizmeti (home_widget): Aktif gezi gün sayacı ve döviz kurlarının sistem widget\'larında gösterilmesi için yerel işletim sistemi IPC kanalı kullanılır.',
        ),
        LegalArticle(
          number: 6,
          title: 'Konum Verileri, IP Geolocation ve Saat Dilimi',
          content: 'PackBuddy, kullanıcının kesin GPS konumunu arka planda sürekli olarak İZLEMEZ veya hareket geçmişi kaydetmez.\n\n'
              'Yalnızca seyahat anında otomatik yerel para birimi tespiti ve ilgili hava durumu/şehir önerileri sunmak amacıyla, kullanıcının internet bağlantı IP adresi üzerinden kaba (şehir/ülke düzeyinde) konum çözümlemesi (HTTPS IP sorgusu ve sistem saat dilimi) yapılır.',
        ),
        LegalArticle(
          number: 7,
          title: 'Analitik, Telemetri ve PostHog (EU Cloud) Güvencesi',
          content: 'Uygulama performansını ölçmek, çökme (crash) ve hataları gidermek amacıyla PostHog analiz platformu (sunucuları Almanya/Frankfurt, Avrupa Birliği sınırları içerisindedir) kullanılır.\n\n'
              'SIKI PII (Kişisel Tanımlanabilir Bilgi) MASKELEME GÜVENCESİ:\n'
              'PackBuddy PostHog SDK yapılandırmasında maskAllTexts = true ve maskAllImages = true bayrakları varsayılan olarak aktiftir. Bu sayede kullanıcının yazdığı hiçbir özel not, eşya ismi, seyahat planı veya kasa fotoğrafı ekran kayıtlarına veya analitik kayıtlarına yansımaz; tüm metinler ve görseller istemci tarafında sansürlenir.\n\n'
              'Kullanıcı, dilediği zaman ayarlar veya onay ekranından isteğe bağlı analitik veri paylaşımını kapatma hakkına sahiptir.',
        ),
        LegalArticle(
          number: 8,
          title: 'Satın Alma, Abonelik ve Finansal Bilgilerin Güvenliği',
          content: 'PackBuddy Pro abonelikleri ve lisansları resmi Google Play Store ve Apple App Store mağaza altyapıları üzerinden satın alınır.\n\n'
              'Kredi kartı numarası, son kullanma tarihi, CVC kodu, banka hesap bilgileri veya fatura ödeme detayları PackBuddy tarafından ASLA talep edilmez, görüntülenemez, sunucularımızda saklanamaz. Tüm finansal işlemler doğrudan Google LLC veya Apple Inc. PCI-DSS uyumlu ödeme ağ geçitleri tarafından korunur. PackBuddy yalnızca satın alma işleminin doğrulanma makbuzunu (purchase token) ve yetkilendirme durumunu işler.',
        ),
        LegalArticle(
          number: 9,
          title: 'Kullanıcının Yasal Hakları ve Veri Silme Güvencesi (GDPR & KVKK)',
          content: 'Kullanıcı, GDPR Md. 15-22 ve KVKK Md. 11 uyarınca;\n\n'
              'a) Kişisel verilerinin işlenip işlenmediğini öğrenme ve bilgi talep etme,\n'
              'b) İşlenen verilerini kopyalama ve dışa aktarma (Veri Taşınabilirliği),\n'
              'c) Eksik veya yanlış işlenen verilerin düzeltilmesini isteme,\n'
              'd) Ayarlar menüsü altındaki "Hesabı ve Tüm Verileri Kalıcı Olarak Sil" seçeneğini kullanarak hesabını, seyahatlerini, kasadaki şifreli belgelerini ve tüm bulut verilerini derhal ve kalıcı olarak sildirme ("Unutulma Hakkı") hakkına sahiptir.\n\n'
              'Hesap silme işlemi onaylandığında hem Google Cloud Firestore üzerindeki veriler hem de yerel cihazdaki veritabanı kayıtları geri döndürülemez biçimde yok edilir.',
        ),
        LegalArticle(
          number: 10,
          title: 'Yürürlük, Değişiklikler ve Yasal İletişim',
          content: 'İşbu sözleşme, Kullanıcı tarafından dijital onay kutuları işaretlenerek "Onayla ve Devam Et" butonuna basıldığı anda yürürlüğe girer.\n\n'
              'Sözleşmenin onaylandığı tarih ve saat, sözleşme sürümü (v1.0.0) ve kullanıcı ID\'si yasal uyumluluk ve delil güvenliği amacıyla kayıt altına alınır. Sözleşme şartlarında esaslı bir değişiklik yapılması halinde, kullanıcılardan güncel sürüm için yeniden onay talep edilecektir.\n\n'
              'Her türlü yasal bildirim ve veri koruma talepleriniz için uygulama içi geri bildirim veya resmi destek kanalları üzerinden veri sorumlusuna başvurabilirsiniz.',
        ),
      ];
    }

    // Default English Articles (International Legal Standard)
    return const [
      LegalArticle(
        number: 1,
        title: 'Parties, Scope & Statutory Framework',
        content: 'This Master User Agreement and Data Consent Agreement ("Agreement") is entered into by and between PackBuddy ("Application", "Platform", "Data Controller") and any individual who downloads, installs, registers with, or accesses the service ("User").\n\nThis Agreement is drafted in compliance with the General Data Protection Regulation (GDPR - Regulation EU 2016/679), the Turkish Personal Data Protection Law (KVKK No. 6698), the California Consumer Privacy Act / California Privacy Rights Act (CCPA/CPRA), Apple App Store Review Guideline 5.1 (Data Privacy), and Google Play User Data Policies, governing mutual legal rights and responsibilities.',
      ),
      LegalArticle(
        number: 2,
        title: 'Categories of Personal Data Collected and Processed',
        content: 'PackBuddy collects, encrypts, and stores the following categories of data:\n\n'
            'a) Identity & Authentication Data: Email address, display name, Firebase Authentication UID, avatar URL, registration timestamp, last active timestamp, session duration, and session count.\n\n'
            'b) Travel & Itinerary Data: Trip names, destinations, departure/return dates, travel notes, visited countries, and world travel map markings.\n\n'
            'c) Luggage & Packing Data: Luggage profiles (brand, dimensions, tare weight, airline allowances, luggage photos), packing checklists, item descriptions, categories, quantities, and custom weights.\n\n'
            'd) Budget & Expense Data: Expenses, expenditure categories, currencies, and exchange rates.\n\n'
            'e) Sensitive Document Vault: Passport copies, flight tickets, hotel reservations, and private photos. These are encrypted on-device via AES-256 (PBENC1 format).\n\n'
            'f) Vault Master PIN: Maintained solely as a salted cryptographic hash; plaintext PIN is never stored.',
      ),
      LegalArticle(
        number: 3,
        title: 'Purposes and Legal Grounds for Processing',
        content: 'Data is processed under GDPR Article 6 and applicable privacy laws for the following legitimate purposes:\n\n'
            '• User identity verification, authentication, and platform security;\n'
            '• Synchronizing itineraries, luggage, and packing checklists across user devices;\n'
            '• Computing luggage allowances and overweight warnings;\n'
            '• Encrypting and protecting sensitive travel documents locally;\n'
            '• Determining applicable local currencies and real-time exchange rates based on network region;\n'
            '• Executing our contractual obligations and explicit user consent.',
      ),
      LegalArticle(
        number: 4,
        title: 'Biometric Data Processing & Local Security Guarantee',
        content: 'The User may elect to enable Fingerprint (Touch ID) or Facial Recognition (Face ID / Biometric Prompt) to unlock the Document Vault.\n\n'
            'STATUTORY GUARANTEE: Biometric identifiers are NEVER transmitted to, stored on, or processed by PackBuddy servers, Google Firebase, or third parties. Biometric matching is handled exclusively by the local hardware security chip of your device (Apple Secure Enclave or Android Hardware Keystore). PackBuddy receives solely a cryptographic boolean pass/fail status token.',
      ),
      LegalArticle(
        number: 5,
        title: 'Hardware & System Permissions',
        content: 'The Application requests system permissions solely when needed for specific user actions:\n\n'
            '• Camera (android.permission.CAMERA): Invoked only upon explicit user action to capture luggage photos or scan documents. Never operates in the background.\n\n'
            '• Media & Storage (READ_MEDIA_IMAGES / READ_EXTERNAL_STORAGE): Used exclusively to import user-selected tickets or photos. Unrelated personal files are never accessed.\n\n'
            '• Notifications (POST_NOTIFICATIONS): Used for departure countdowns, packing reminders, and security alerts via local/FCM channels.\n\n'
            '• Network & Internet (INTERNET, ACCESS_NETWORK_STATE): Essential for Firestore cloud sync and live exchange rates.\n\n'
            '• Home Screen Widget (home_widget): Transfers active countdown and rate data to lock/home screen widgets via secure OS IPC.',
      ),
      LegalArticle(
        number: 6,
        title: 'Location, IP Geolocation & Timezone',
        content: 'PackBuddy DOES NOT continuously track your precise GPS coordinates in the background.\n\n'
            'Coarse IP lookup (city/country level via HTTPS) and system timezone are queried solely to determine appropriate local currencies and travel recommendations at the time of use.',
      ),
      LegalArticle(
        number: 7,
        title: 'Analytics, Telemetry & PostHog (EU Cloud) Safeguards',
        content: 'To maintain application stability and address crashes, PackBuddy utilizes PostHog EU Cloud (Frankfurt, Germany).\n\n'
            'STRICT PII MASKING SAFEGUARD:\n'
            'The PostHog SDK is configured with maskAllTexts = true and maskAllImages = true by default. Private travel notes, checklist items, vault documents, and photos are completely masked on the client side and are never transmitted to analytics servers.\n\n'
            'Users may opt out of non-essential analytics at any time via the consent toggles.',
      ),
      LegalArticle(
        number: 8,
        title: 'Billing, In-App Purchases & Financial Security',
        content: 'PackBuddy Pro subscriptions are processed exclusively through Google Play Billing and Apple App Store in-app purchases.\n\n'
            'Credit card numbers, bank account details, and billing information are NEVER collected, stored, or processed by PackBuddy. All financial transactions are managed under PCI-DSS standards by Google LLC and Apple Inc. PackBuddy handles only receipt tokens and entitlement flags.',
      ),
      LegalArticle(
        number: 9,
        title: 'User Rights & Permanent Data Deletion (GDPR & KVKK)',
        content: 'Under GDPR Articles 15-22 and KVKK Article 11, users possess the right to:\n\n'
            'a) Request information and confirmation regarding their processed personal data;\n'
            'b) Request data portability and export of checklists and trips;\n'
            'c) Rectify incomplete or inaccurate personal data;\n'
            'd) Permanently delete their account and all cloud and local records at any time using the "Delete Account" feature (Right to be Forgotten).\n\n'
            'Upon account deletion, all trips, luggage records, and encrypted vault files are permanently purged from both cloud servers and the local device.',
      ),
      LegalArticle(
        number: 10,
        title: 'Effective Date, Amendments & Legal Contact',
        content: 'This Agreement becomes legally binding upon the User checking the mandatory checkboxes and clicking "Accept & Continue".\n\n'
            'The timestamp of acceptance, agreement version (v1.0.0), and User UID are securely recorded for compliance auditing. In the event of material revisions, renewed consent will be requested.\n\n'
            'For data privacy inquiries or exercising statutory rights, users may contact the Data Controller via in-app feedback or official support channels.',
      ),
    ];
  }
}

