// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('lib/l10n/app_en.arb');
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

  final Map<String, String> newEnKeys = {
    'authContinueWithApple': 'Continue with Apple',
    'authNoAccount': "Don't have an account? ",
    'authAlreadyHaveAccount': 'Already have an account? ',
    'accountAndSession': 'Account & Session',
    'categorySpendingAnalysis': 'Category Spending Breakdown',
    'topSpendingCategory': 'Top: {category} ({percentage}%)',
    'expenseCount': '{count} Expenses',
    'boardingPassPassenger': 'PASSENGER',
    'boardingPassGate': 'GATE',
    'boardingPassSampleTraveler': 'PACKBUDDY TRAVELER',
    'notification48hTitle': 'PackBuddy: Trip to {destination} in 2 days! 🧳',
    'notification48hBody': 'Only 48 hours left until your trip to {destination}! Have you started packing your travel essentials?',
    'notification24hTitle': "PackBuddy: You're Leaving Tomorrow! ✈️",
    'notification24hBody': 'Final packing check! Double-check your passport, tickets, and travel essentials for {destination}.',
  };

  final Map<String, dynamic> newMetadata = {
    '@authContinueWithApple': {'description': 'Button to continue with Apple ID'},
    '@authNoAccount': {'description': 'Prompt asking if traveler needs to register'},
    '@authAlreadyHaveAccount': {'description': 'Prompt asking if traveler already has an account'},
    '@accountAndSession': {'description': 'Header for account and session section in settings'},
    '@categorySpendingAnalysis': {'description': 'Title for category expense breakdown analytics card'},
    '@topSpendingCategory': {
      'description': 'Highlight showing highest spending category and percentage',
      'placeholders': {
        'category': {'type': 'String', 'example': 'Food & Dining'},
        'percentage': {'type': 'String', 'example': '42'}
      }
    },
    '@expenseCount': {
      'description': 'Badge showing total count of expenses',
      'placeholders': {
        'count': {'type': 'int', 'example': '12'}
      }
    },
    '@boardingPassPassenger': {'description': 'Passenger label on boarding pass simulation'},
    '@boardingPassGate': {'description': 'Gate label on boarding pass simulation'},
    '@boardingPassSampleTraveler': {'description': 'Sample traveler name on boarding pass simulation'},
    '@notification48hTitle': {
      'description': 'Notification title sent 48 hours before trip departure',
      'placeholders': {
        'destination': {'type': 'String', 'example': 'Tokyo'}
      }
    },
    '@notification48hBody': {
      'description': 'Notification body sent 48 hours before trip departure',
      'placeholders': {
        'destination': {'type': 'String', 'example': 'Tokyo'}
      }
    },
    '@notification24hTitle': {
      'description': 'Notification title sent 24 hours before trip departure',
    },
    '@notification24hBody': {
      'description': 'Notification body sent 24 hours before trip departure',
      'placeholders': {
        'destination': {'type': 'String', 'example': 'Tokyo'}
      }
    },
  };

  newEnKeys.forEach((k, v) {
    enJson[k] = v;
    if (newMetadata.containsKey('@$k')) {
      enJson['@$k'] = newMetadata['@$k'];
    }
  });

  const encoder = JsonEncoder.withIndent('  ');
  enFile.writeAsStringSync(encoder.convert(enJson));
  print('Updated app_en.arb with 14 new keys!');

  final Map<String, Map<String, String>> translations = {
    'tr': {
      'authContinueWithApple': 'Apple ile Devam Et',
      'authNoAccount': 'Hesabınız yok mu? ',
      'authAlreadyHaveAccount': 'Zaten bir hesabınız var mı? ',
      'accountAndSession': 'Hesap & Oturum',
      'categorySpendingAnalysis': 'Kategori Harcama Analizi',
      'topSpendingCategory': 'En çok: {category} (%{percentage})',
      'expenseCount': '{count} Harcama',
      'boardingPassPassenger': 'YOLCU',
      'boardingPassGate': 'KAPI',
      'boardingPassSampleTraveler': 'PACKBUDDY GEZGİNİ',
      'notification48hTitle': 'PackBuddy: {destination} Seyahati Yaklaşıyor! 🧳',
      'notification48hBody': '{destination} seyahatinize 48 saat kaldı! Eksiklerinizi kontrol edip bavulunuzu hazırlamaya başladınız mı?',
      'notification24hTitle': 'PackBuddy: Yarın Yola Çıkıyorsunuz! ✈️',
      'notification24hBody': 'Son kontroller! {destination} seyahatiniz yarın başlıyor. Pasaport, bilet ve seyahat eşyalarınızı aldınız mı?',
    },
    'de': {
      'authContinueWithApple': 'Mit Apple fortfahren',
      'authNoAccount': 'Noch kein Konto? ',
      'authAlreadyHaveAccount': 'Bereits ein Konto vorhanden? ',
      'accountAndSession': 'Konto & Sitzung',
      'categorySpendingAnalysis': 'Kategorie-Ausgabenanalyse',
      'topSpendingCategory': 'Höchste: {category} ({percentage}%)',
      'expenseCount': '{count} Ausgaben',
      'boardingPassPassenger': 'PASSAGIER',
      'boardingPassGate': 'GATE',
      'boardingPassSampleTraveler': 'PACKBUDDY REISENDER',
      'notification48hTitle': 'PackBuddy: Reise nach {destination} in 2 Tagen! 🧳',
      'notification48hBody': 'Nur noch 48 Stunden bis zu deiner Reise nach {destination}! Hast du schon mit dem Packen begonnen?',
      'notification24hTitle': 'PackBuddy: Du reist morgen ab! ✈️',
      'notification24hBody': 'Letzter Pack-Check! Überprüfe deinen Reisepass, Tickets und Reiseutensilien für {destination}.',
    },
    'es': {
      'authContinueWithApple': 'Continuar con Apple',
      'authNoAccount': '¿No tienes una cuenta? ',
      'authAlreadyHaveAccount': '¿Ya tienes una cuenta? ',
      'accountAndSession': 'Cuenta y sesión',
      'categorySpendingAnalysis': 'Desglose de gastos por categoría',
      'topSpendingCategory': 'Principal: {category} ({percentage}%)',
      'expenseCount': '{count} Gastos',
      'boardingPassPassenger': 'PASAJERO',
      'boardingPassGate': 'PUERTA',
      'boardingPassSampleTraveler': 'VIAJERO DE PACKBUDDY',
      'notification48hTitle': 'PackBuddy: ¡Viaje a {destination} en 2 días! 🧳',
      'notification48hBody': '¡Solo quedan 48 horas para tu viaje a {destination}! ¿Has empezado a preparar tu equipaje?',
      'notification24hTitle': 'PackBuddy: ¡Te vas mañana! ✈️',
      'notification24hBody': '¡Control final de equipaje! Revisa tu pasaporte, billetes y artículos esenciales para {destination}.',
    },
    'fr': {
      'authContinueWithApple': 'Continuer avec Apple',
      'authNoAccount': "Vous n'avez pas de compte ? ",
      'authAlreadyHaveAccount': 'Vous avez déjà un compte ? ',
      'accountAndSession': 'Compte & Session',
      'categorySpendingAnalysis': 'Répartition des dépenses par catégorie',
      'topSpendingCategory': 'Principal : {category} ({percentage}%)',
      'expenseCount': '{count} Dépenses',
      'boardingPassPassenger': 'PASSAGER',
      'boardingPassGate': 'PORTE',
      'boardingPassSampleTraveler': 'VOYAGEUR PACKBUDDY',
      'notification48hTitle': 'PackBuddy : Voyage vers {destination} dans 2 jours ! 🧳',
      'notification48hBody': 'Plus que 48 heures avant votre voyage à {destination} ! Avez-vous commencé à faire vos valises ?',
      'notification24hTitle': 'PackBuddy : Vous partez demain ! ✈️',
      'notification24hBody': 'Dernière vérification des bagages ! Vérifiez votre passeport, vos billets et vos affaires pour {destination}.',
    },
    'it': {
      'authContinueWithApple': 'Continua con Apple',
      'authNoAccount': 'Non hai un account? ',
      'authAlreadyHaveAccount': 'Hai già un account? ',
      'accountAndSession': 'Account e sessione',
      'categorySpendingAnalysis': 'Analisi delle spese per categoria',
      'topSpendingCategory': 'Principale: {category} ({percentage}%)',
      'expenseCount': '{count} Spese',
      'boardingPassPassenger': 'PASSEGGERO',
      'boardingPassGate': 'GATE',
      'boardingPassSampleTraveler': 'VIAGGIATORE PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Viaggio a {destination} tra 2 giorni! 🧳',
      'notification48hBody': 'Mancano solo 48 ore al tuo viaggio a {destination}! Hai iniziato a preparare la valigia?',
      'notification24hTitle': 'PackBuddy: Si parte domani! ✈️',
      'notification24hBody': 'Controllo finale dei bagagli! Ricontrolla passaporto, biglietti ed elementi essenziali per {destination}.',
    },
    'pt': {
      'authContinueWithApple': 'Continuar com a Apple',
      'authNoAccount': 'Não tem uma conta? ',
      'authAlreadyHaveAccount': 'Já tem uma conta? ',
      'accountAndSession': 'Conta e Sessão',
      'categorySpendingAnalysis': 'Distribuição de despesas por categoria',
      'topSpendingCategory': 'Principal: {category} ({percentage}%)',
      'expenseCount': '{count} Despesas',
      'boardingPassPassenger': 'PASSAGEIRO',
      'boardingPassGate': 'PORTÃO',
      'boardingPassSampleTraveler': 'VIAJANTE PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Viagem para {destination} em 2 dias! 🧳',
      'notification48hBody': 'Faltam apenas 48 horas para sua viagem para {destination}! Já começou a arrumar suas malas?',
      'notification24hTitle': 'PackBuddy: Você viaja amanhã! ✈️',
      'notification24hBody': 'Verificação final das malas! Confira seu passaporte, passagens e itens essenciais para {destination}.',
    },
    'nl': {
      'authContinueWithApple': 'Doorgaan met Apple',
      'authNoAccount': 'Nog geen account? ',
      'authAlreadyHaveAccount': 'Al een account? ',
      'accountAndSession': 'Account & Sessie',
      'categorySpendingAnalysis': 'Uitgaven per categorie',
      'topSpendingCategory': 'Hoogste: {category} ({percentage}%)',
      'expenseCount': '{count} Uitgaven',
      'boardingPassPassenger': 'PASSAGIER',
      'boardingPassGate': 'GATE',
      'boardingPassSampleTraveler': 'PACKBUDDY REIZIGER',
      'notification48hTitle': 'PackBuddy: Reis naar {destination} over 2 dagen! 🧳',
      'notification48hBody': 'Nog maar 48 uur tot je reis naar {destination}! Ben je al begonnen met inpakken?',
      'notification24hTitle': 'PackBuddy: Je vertrekt morgen! ✈️',
      'notification24hBody': 'Laatste inpakcontrole! Controleer je paspoort, tickets en reisbenodigdheden voor {destination}.',
    },
    'ru': {
      'authContinueWithApple': 'Продолжить с Apple',
      'authNoAccount': 'Нет аккаунта? ',
      'authAlreadyHaveAccount': 'Уже есть аккаунт? ',
      'accountAndSession': 'Аккаунт и сессия',
      'categorySpendingAnalysis': 'Анализ расходов по категориям',
      'topSpendingCategory': 'Больше всего: {category} ({percentage}%)',
      'expenseCount': '{count} Расходов',
      'boardingPassPassenger': 'ПАССАЖИР',
      'boardingPassGate': 'ВЫХОД',
      'boardingPassSampleTraveler': 'ПУТЕШЕСТВЕННИК PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Поездка в {destination} через 2 дня! 🧳',
      'notification48hBody': 'Осталось всего 48 часов до поездки в {destination}! Вы уже начали собирать чемодан?',
      'notification24hTitle': 'PackBuddy: Вы отправляетесь завтра! ✈️',
      'notification24hBody': 'Финальная проверка багажа! Проверьте паспорт, билеты и всё необходимое для поездки в {destination}.',
    },
    'pl': {
      'authContinueWithApple': 'Kontynuuj z Apple',
      'authNoAccount': 'Nie masz konta? ',
      'authAlreadyHaveAccount': 'Masz już konto? ',
      'accountAndSession': 'Konto i sesja',
      'categorySpendingAnalysis': 'Analiza wydatków wg kategorii',
      'topSpendingCategory': 'Najwięcej: {category} ({percentage}%)',
      'expenseCount': '{count} Wydatków',
      'boardingPassPassenger': 'PASAŻER',
      'boardingPassGate': 'BRAMKA',
      'boardingPassSampleTraveler': 'PODRÓŻNIK PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Podróż do {destination} za 2 dni! 🧳',
      'notification48hBody': 'Zostało tylko 48 godzin do podróży do {destination}! Czy zacząłeś już pakować najważniejsze rzeczy?',
      'notification24hTitle': 'PackBuddy: Wylatujesz jutro! ✈️',
      'notification24hBody': 'Ostateczne sprawdzenie bagażu! Upewnij się, że masz paszport, bilety i niezbędne rzeczy do {destination}.',
    },
    'sv': {
      'authContinueWithApple': 'Fortsätt med Apple',
      'authNoAccount': 'Har du inget konto? ',
      'authAlreadyHaveAccount': 'Har du redan ett konto? ',
      'accountAndSession': 'Konto & Session',
      'categorySpendingAnalysis': 'Kategoriutgiftsanalys',
      'topSpendingCategory': 'Mest: {category} ({percentage}%)',
      'expenseCount': '{count} Utgifter',
      'boardingPassPassenger': 'PASSAGERARE',
      'boardingPassGate': 'GATE',
      'boardingPassSampleTraveler': 'PACKBUDDY RESENÄR',
      'notification48hTitle': 'PackBuddy: Resa till {destination} om 2 dagar! 🧳',
      'notification48hBody': 'Bara 48 timmar kvar till din resa till {destination}! Har du börjat packa dina resesaker?',
      'notification24hTitle': 'PackBuddy: Du åker imorgon! ✈️',
      'notification24hBody': 'Sista packningskontrollen! Dubbelkolla pass, biljetter och det viktigaste för {destination}.',
    },
    'el': {
      'authContinueWithApple': 'Συνέχεια με την Apple',
      'authNoAccount': 'Δεν έχετε λογαριασμό; ',
      'authAlreadyHaveAccount': 'Έχετε ήδη λογαριασμό; ',
      'accountAndSession': 'Λογαριασμός & Συνεδρία',
      'categorySpendingAnalysis': 'Ανάλυση δαπανών ανά κατηγορία',
      'topSpendingCategory': 'Κορυφαία: {category} ({percentage}%)',
      'expenseCount': '{count} Έξοδα',
      'boardingPassPassenger': 'ΕΠΙΒΑΤΗΣ',
      'boardingPassGate': 'ΠΥΛΗ',
      'boardingPassSampleTraveler': 'ΤΑΞΙΔΙΩΤΗΣ PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Ταξίδι προς {destination} σε 2 ημέρες! 🧳',
      'notification48hBody': 'Μόλις 48 ώρες απομένουν για το ταξίδι σας προς {destination}! Ξεκινήσατε να φτιάχνετε τη βαλίτσα σας;',
      'notification24hTitle': 'PackBuddy: Φεύγετε αύριο! ✈️',
      'notification24hBody': 'Τελικός έλεγχος αποσκευών! Ελέγξτε ξανά το διαβατήριο, τα εισιτήρια και τα απαραίτητα για {destination}.',
    },
    'ar': {
      'authContinueWithApple': 'المتابعة باستخدام Apple',
      'authNoAccount': 'ليس لديك حساب؟ ',
      'authAlreadyHaveAccount': 'هل لديك حساب بالفعل؟ ',
      'accountAndSession': 'الحساب والجلسة',
      'categorySpendingAnalysis': 'تحليل إنفاق الفئات',
      'topSpendingCategory': 'الأعلى: {category} ({percentage}%)',
      'expenseCount': '{count} مصروفات',
      'boardingPassPassenger': 'المسافر',
      'boardingPassGate': 'البوابة',
      'boardingPassSampleTraveler': 'مسافر PACKBUDDY',
      'notification48hTitle': 'PackBuddy: رحلة إلى {destination} خلال يومين! 🧳',
      'notification48hBody': 'بقي 48 ساعة فقط على رحلتك إلى {destination}! هل بدأت بحزم أساسيات سفرك؟',
      'notification24hTitle': 'PackBuddy: ستغادر غدًا! ✈️',
      'notification24hBody': 'الفحص النهائي للحقيبة! تأكد من جواز سفرك وتذاكرك وأساسيات سفرك إلى {destination}.',
    },
    'ja': {
      'authContinueWithApple': 'Appleで続ける',
      'authNoAccount': 'アカウントをお持ちでないですか？ ',
      'authAlreadyHaveAccount': 'すでにアカウントをお持ちですか？ ',
      'accountAndSession': 'アカウントとセッション',
      'categorySpendingAnalysis': 'カテゴリー別支出の内訳',
      'topSpendingCategory': '最多: {category} ({percentage}%)',
      'expenseCount': '{count}件の支出',
      'boardingPassPassenger': '乗客',
      'boardingPassGate': '搭乗口',
      'boardingPassSampleTraveler': 'PACKBUDDY トラベラー',
      'notification48hTitle': 'PackBuddy: {destination}への旅行まであと2日！ 🧳',
      'notification48hBody': '{destination}への旅行まであと48時間です！持ち物のパッキングは始めましたか？',
      'notification24hTitle': 'PackBuddy: いよいよ明日出発です！ ✈️',
      'notification24hBody': '最終パッキングチェック！{destination}のパスポート、チケット、必需品を再確認してください。',
    },
    'ko': {
      'authContinueWithApple': 'Apple로 계속하기',
      'authNoAccount': '계정이 없으신가요? ',
      'authAlreadyHaveAccount': '이미 계정이 있으신가요? ',
      'accountAndSession': '계정 및 세션',
      'categorySpendingAnalysis': '카테고리별 지출 분석',
      'topSpendingCategory': '최다: {category} ({percentage}%)',
      'expenseCount': '{count}건의 지출',
      'boardingPassPassenger': '승객',
      'boardingPassGate': '탑승구',
      'boardingPassSampleTraveler': 'PACKBUDDY 여행자',
      'notification48hTitle': 'PackBuddy: {destination} 여행까지 2일 남았습니다! 🧳',
      'notification48hBody': '{destination} 여행까지 48시간 남았습니다! 여행 필수품 챙기기를 시작하셨나요?',
      'notification24hTitle': 'PackBuddy: 내일 출발합니다! ✈️',
      'notification24hBody': '최종 짐 확인! {destination} 여행을 위한 여권, 티켓, 필수품을 다시 한번 확인하세요.',
    },
    'zh': {
      'authContinueWithApple': '通过 Apple 继续',
      'authNoAccount': '还没有账户？ ',
      'authAlreadyHaveAccount': '已有账户？ ',
      'accountAndSession': '账户与会话',
      'categorySpendingAnalysis': '类别支出明细',
      'topSpendingCategory': '最多：{category}（{percentage}%）',
      'expenseCount': '{count} 笔支出',
      'boardingPassPassenger': '乘客',
      'boardingPassGate': '登机口',
      'boardingPassSampleTraveler': 'PACKBUDDY 旅行者',
      'notification48hTitle': 'PackBuddy：距离前往 {destination} 的行程还有2天！🧳',
      'notification48hBody': '距离前往 {destination} 的旅行仅剩 48 小时！您开始收拾行李了吗？',
      'notification24hTitle': 'PackBuddy：明天就要出发了！✈️',
      'notification24hBody': '最后的行李检查！请再次确认前往 {destination} 的护照、机票和旅行必需品。',
    },
    'hi': {
      'authContinueWithApple': 'Apple के साथ जारी रखें',
      'authNoAccount': 'खाता नहीं है? ',
      'authAlreadyHaveAccount': 'पहले से ही एक खाता है? ',
      'accountAndSession': 'खाता और सत्र',
      'categorySpendingAnalysis': 'श्रेणी व्यय विश्लेषण',
      'topSpendingCategory': 'शीर्ष: {category} ({percentage}%)',
      'expenseCount': '{count} खर्च',
      'boardingPassPassenger': 'यात्री',
      'boardingPassGate': 'गेट',
      'boardingPassSampleTraveler': 'PACKBUDDY यात्री',
      'notification48hTitle': 'PackBuddy: 2 दिनों में {destination} की यात्रा! 🧳',
      'notification48hBody': '{destination} की आपकी यात्रा में केवल 48 घंटे बचे हैं! क्या आपने सामान पैक करना शुरू कर दिया है?',
      'notification24hTitle': 'PackBuddy: आप कल रवाना हो रहे हैं! ✈️',
      'notification24hBody': 'अंतिम पैकिंग जांच! {destination} के लिए अपने पासपोर्ट, टिकट और यात्रा आवश्यक वस्तुओं की दोबारा जांच करें।',
    },
    'id': {
      'authContinueWithApple': 'Lanjutkan dengan Apple',
      'authNoAccount': 'Belum punya akun? ',
      'authAlreadyHaveAccount': 'Sudah memiliki akun? ',
      'accountAndSession': 'Akun & Sesi',
      'categorySpendingAnalysis': 'Analisis Pengeluaran Kategori',
      'topSpendingCategory': 'Terbanyak: {category} ({percentage}%)',
      'expenseCount': '{count} Pengeluaran',
      'boardingPassPassenger': 'PENUMPANG',
      'boardingPassGate': 'PINTU',
      'boardingPassSampleTraveler': 'PENJELAJAH PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Perjalanan ke {destination} dalam 2 hari! 🧳',
      'notification48hBody': 'Hanya tersisa 48 jam sebelum perjalanan Anda ke {destination}! Sudah mulai mengemas barang bawaan?',
      'notification24hTitle': 'PackBuddy: Anda Berangkat Besok! ✈️',
      'notification24hBody': 'Pemeriksaan persiapan terakhir! Periksa kembali paspor, tiket, dan barang penting untuk {destination}.',
    },
    'th': {
      'authContinueWithApple': 'ดำเนินการต่อด้วย Apple',
      'authNoAccount': 'ยังไม่มีบัญชีใช่ไหม? ',
      'authAlreadyHaveAccount': 'มีบัญชีอยู่แล้วใช่ไหม? ',
      'accountAndSession': 'บัญชีและเซสชัน',
      'categorySpendingAnalysis': 'การวิเคราะห์การใช้จ่ายตามหมวดหมู่',
      'topSpendingCategory': 'สูงสุด: {category} ({percentage}%)',
      'expenseCount': '{count} รายการใช้จ่าย',
      'boardingPassPassenger': 'ผู้โดยสาร',
      'boardingPassGate': 'ประตูขึ้นเครื่อง',
      'boardingPassSampleTraveler': 'นักเดินทาง PACKBUDDY',
      'notification48hTitle': 'PackBuddy: การเดินทางไป {destination} ในอีก 2 วัน! 🧳',
      'notification48hBody': 'เหลือเวลาอีกเพียง 48 ชั่วโมงก่อนการเดินทางไป {destination}! เริ่มจัดกระเป๋าแล้วหรือยัง?',
      'notification24hTitle': 'PackBuddy: คุณจะออกเดินทางในวันพรุ่งนี้! ✈️',
      'notification24hBody': 'ตรวจสอบการจัดกระเป๋าครั้งสุดท้าย! ตรวจสอบหนังสือเดินทาง ตั๋ว และของใช้จำเป็นสำหรับ {destination} อีกครั้ง',
    },
    'vi': {
      'authContinueWithApple': 'Tiếp tục với Apple',
      'authNoAccount': 'Chưa có tài khoản? ',
      'authAlreadyHaveAccount': 'Đã có tài khoản? ',
      'accountAndSession': 'Tài khoản & Phiên',
      'categorySpendingAnalysis': 'Phân tích chi tiêu theo danh mục',
      'topSpendingCategory': 'Nhiều nhất: {category} ({percentage}%)',
      'expenseCount': '{count} Khoản chi',
      'boardingPassPassenger': 'HÀNH KHÁCH',
      'boardingPassGate': 'CỔNG',
      'boardingPassSampleTraveler': 'DU KHÁCH PACKBUDDY',
      'notification48hTitle': 'PackBuddy: Chuyến đi đến {destination} sau 2 ngày nữa! 🧳',
      'notification48hBody': 'Chỉ còn 48 giờ nữa là đến chuyến đi {destination}! Bạn đã bắt đầu xếp hành lý chưa?',
      'notification24hTitle': 'PackBuddy: Bạn sẽ khởi hành vào ngày mai! ✈️',
      'notification24hBody': 'Kiểm tra hành lý lần cuối! Hãy kiểm tra lại hộ chiếu, vé và đồ dùng cần thiết cho {destination}.',
    },
  };

  translations.forEach((lang, dict) {
    final file = File('lib/l10n/app_$lang.arb');
    if (file.existsSync()) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      dict.forEach((k, v) {
        json[k] = v;
      });
      file.writeAsStringSync(encoder.convert(json));
      print('Updated app_$lang.arb with supplemental keys (${json.length} keys total)');
    }
  });

  print('\nAll supplemental keys injected successfully!');
}
