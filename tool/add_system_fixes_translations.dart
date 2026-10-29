// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final Map<String, Map<String, String>> newTranslations = {
    'en': {
      'vaultBiometricReason': 'Verify your fingerprint or face to unlock your travel vault',
      'biometricsFailed': 'Biometric verification failed or was cancelled.',
      'customBaggageLimitPrompt': 'Set custom limit (kg)',
      'testNotificationSent': 'Test notification sent to your device.',
      'pinWidgetSuccess': 'Widget added to home screen.',
      'pinWidgetGuide': 'Long-press your home screen and choose Widgets > PackBuddy to add.',
    },
    'tr': {
      'vaultBiometricReason': 'Seyahat kasanızın kilidini açmak için parmak izinizi veya yüzünüzü doğrulayın',
      'biometricsFailed': 'Biyometrik doğrulama başarısız oldu veya iptal edildi.',
      'customBaggageLimitPrompt': 'Özel limit belirle (kg)',
      'testNotificationSent': 'Test bildirimi cihazınıza gönderildi.',
      'pinWidgetSuccess': 'Araç takımı ana ekrana eklendi.',
      'pinWidgetGuide': 'Ana ekrana uzun basarak "Araç Takımları (Widget)" menüsünden PackBuddy\'yi ekleyebilirsiniz.',
    },
    'de': {
      'vaultBiometricReason': 'Bestätigen Sie Ihren Fingerabdruck oder Ihr Gesicht, um den Tresor zu entsperren',
      'biometricsFailed': 'Biometrische Überprüfung fehlgeschlagen oder abgebrochen.',
      'customBaggageLimitPrompt': 'Eigenes Limit festlegen (kg)',
      'testNotificationSent': 'Testbenachrichtigung an Ihr Gerät gesendet.',
      'pinWidgetSuccess': 'Widget zum Startbildschirm hinzugefügt.',
      'pinWidgetGuide': 'Lange auf den Startbildschirm drücken und Widgets > PackBuddy wählen.',
    },
    'fr': {
      'vaultBiometricReason': 'Vérifiez votre empreinte ou votre visage pour déverrouiller le coffre-fort',
      'biometricsFailed': 'La vérification biométrique a échoué ou a été annulée.',
      'customBaggageLimitPrompt': 'Définir une limite personnalisée (kg)',
      'testNotificationSent': 'Notification de test envoyée à votre appareil.',
      'pinWidgetSuccess': 'Widget ajouté à l\'écran d\'accueil.',
      'pinWidgetGuide': 'Appuyez longuement sur l\'écran d\'accueil et choisissez Widgets > PackBuddy.',
    },
    'es': {
      'vaultBiometricReason': 'Verifica tu huella o rostro para desbloquear tu bóveda de viaje',
      'biometricsFailed': 'La verificación biométrica falló o fue cancelada.',
      'customBaggageLimitPrompt': 'Establecer límite personalizado (kg)',
      'testNotificationSent': 'Notificación de prueba enviada a tu dispositivo.',
      'pinWidgetSuccess': 'Widget añadido a la pantalla de inicio.',
      'pinWidgetGuide': 'Mantén presionada la pantalla de inicio y elige Widgets > PackBuddy.',
    },
    'it': {
      'vaultBiometricReason': 'Verifica la tua impronta digitale o il volto per sbloccare la cassaforte',
      'biometricsFailed': 'Verifica biometrica fallita o annullata.',
      'customBaggageLimitPrompt': 'Imposta limite personalizzato (kg)',
      'testNotificationSent': 'Notifica di test inviata al tuo dispositivo.',
      'pinWidgetSuccess': 'Widget aggiunto alla schermata iniziale.',
      'pinWidgetGuide': 'Tieni premuta la schermata iniziale e seleziona Widget > PackBuddy.',
    },
    'pt': {
      'vaultBiometricReason': 'Verifique sua impressão digital ou rosto para desbloquear seu cofre de viagem',
      'biometricsFailed': 'A verificação biométrica falhou ou foi cancelada.',
      'customBaggageLimitPrompt': 'Definir limite personalizado (kg)',
      'testNotificationSent': 'Notificação de teste enviada para o seu dispositivo.',
      'pinWidgetSuccess': 'Widget adicionado à tela inicial.',
      'pinWidgetGuide': 'Pressione e segure a tela inicial e escolha Widgets > PackBuddy.',
    },
    'ru': {
      'vaultBiometricReason': 'Подтвердите отпечаток пальца или лицо для разблокировки сейфа',
      'biometricsFailed': 'Биометрическая проверка не удалась или была отменена.',
      'customBaggageLimitPrompt': 'Указать свой лимит (кг)',
      'testNotificationSent': 'Тестовое уведомление отправлено на ваше устройство.',
      'pinWidgetSuccess': 'Виджет добавлен на главный экран.',
      'pinWidgetGuide': 'Удерживайте палец на главном экране и выберите Виджеты > PackBuddy.',
    },
    'zh': {
      'vaultBiometricReason': '验证指纹或面容以解锁旅行保险箱',
      'biometricsFailed': '生物识别验证失败或已取消。',
      'customBaggageLimitPrompt': '设置自定义限制 (kg)',
      'testNotificationSent': '测试通知已发送至您的设备。',
      'pinWidgetSuccess': '小组件已添加到主屏幕。',
      'pinWidgetGuide': '长按主屏幕并选择 小组件 > PackBuddy 添加。',
    },
    'ja': {
      'vaultBiometricReason': 'トラベル保管庫のロックを解除するには指紋または顔を認証してください',
      'biometricsFailed': '生体認証に失敗したか、キャンセルされました。',
      'customBaggageLimitPrompt': 'カスタム制限を設定 (kg)',
      'testNotificationSent': 'テスト通知をお使いのデバイスに送信しました。',
      'pinWidgetSuccess': 'ウィジェットがホーム画面に追加されました。',
      'pinWidgetGuide': 'ホーム画面を長押しして「ウィジェット > PackBuddy」を選択してください。',
    },
    'ko': {
      'vaultBiometricReason': '여행 보관함의 잠금을 해제하려면 지문 또는 얼굴을 인증하세요',
      'biometricsFailed': '생체 인증에 실패했거나 취소되었습니다.',
      'customBaggageLimitPrompt': '사용자 지정 한도 설정 (kg)',
      'testNotificationSent': '테스트 알림이 기기로 전송되었습니다.',
      'pinWidgetSuccess': '위젯이 홈 화면에 추가되었습니다.',
      'pinWidgetGuide': '홈 화면을 길게 누르고 위젯 > PackBuddy를 선택하세요.',
    },
    'ar': {
      'vaultBiometricReason': 'تحقق من بصمة إصبعك أو وجهك لإلغاء قفل خزانة السفر',
      'biometricsFailed': 'فشل التحقق البيومتري أو تم إلغاؤه.',
      'customBaggageLimitPrompt': 'تعيين حد مخصص (كجم)',
      'testNotificationSent': 'تم إرسال إشعار تجريبي إلى جهازك.',
      'pinWidgetSuccess': 'تمت إضافة الأداة إلى الشاشة الرئيسية.',
      'pinWidgetGuide': 'اضغط مطولاً على الشاشة الرئيسية واختر الأدوات > PackBuddy.',
    },
    'hi': {
      'vaultBiometricReason': 'अपनी यात्रा तिजोरी को अनलॉक करने के लिए फ़िंगरप्रिंट या चेहरे की पुष्टि करें',
      'biometricsFailed': 'बायोमेट्रिक सत्यापन विफल रहा या रद्द कर दिया गया।',
      'customBaggageLimitPrompt': 'कस्टम सीमा सेट करें (किग्रा)',
      'testNotificationSent': 'आपके डिवाइस पर परीक्षण सूचना भेजी गई।',
      'pinWidgetSuccess': 'विजेट होम स्क्रीन में जोड़ा गया।',
      'pinWidgetGuide': 'होम स्क्रीन को दबाकर रखें और विजेट्स > PackBuddy चुनें।',
    },
    'id': {
      'vaultBiometricReason': 'Verifikasi sidik jari atau wajah Anda untuk membuka brankas perjalanan',
      'biometricsFailed': 'Verifikasi biometrik gagal atau dibatalkan.',
      'customBaggageLimitPrompt': 'Atur batas kustom (kg)',
      'testNotificationSent': 'Notifikasi uji coba dikirim ke perangkat Anda.',
      'pinWidgetSuccess': 'Widget ditambahkan ke layar utama.',
      'pinWidgetGuide': 'Tekan lama layar utama lalu pilih Widget > PackBuddy.',
    },
    'nl': {
      'vaultBiometricReason': 'Verifieer uw vingerafdruk of gezicht om uw reissluis te ontgrendelen',
      'biometricsFailed': 'Biometrische verificatie mislukt of geannuleerd.',
      'customBaggageLimitPrompt': 'Aangepaste limiet instellen (kg)',
      'testNotificationSent': 'Testmelding verzonden naar uw apparaat.',
      'pinWidgetSuccess': 'Widget toegevoegd aan het startscherm.',
      'pinWidgetGuide': 'Houd het startscherm ingedrukt en kies Widgets > PackBuddy.',
    },
    'pl': {
      'vaultBiometricReason': 'Zweryfikuj odcisk palca lub twarz, aby odblokować sejf podróżny',
      'biometricsFailed': 'Weryfikacja biometryczna nie powiodła się lub została anulowana.',
      'customBaggageLimitPrompt': 'Ustaw własny limit (kg)',
      'testNotificationSent': 'Powiadomienie testowe wysłane na Twoje urządzenie.',
      'pinWidgetSuccess': 'Widżet dodany do ekranu głównego.',
      'pinWidgetGuide': 'Przytrzymaj ekran główny i wybierz Widżety > PackBuddy.',
    },
    'sv': {
      'vaultBiometricReason': 'Verifiera fingeravtryck eller ansikte för att låsa upp ditt resvalv',
      'biometricsFailed': 'Biometrisk verifiering misslyckades eller avbröts.',
      'customBaggageLimitPrompt': 'Ange anpassad gräns (kg)',
      'testNotificationSent': 'Testavisering skickad till din enhet.',
      'pinWidgetSuccess': 'Widget lades till på hemskärmen.',
      'pinWidgetGuide': 'Tryck länge på hemskärmen och välj Widgets > PackBuddy.',
    },
    'th': {
      'vaultBiometricReason': 'ยืนยันลายนิ้วมือหรือใบหน้าเพื่อปลดล็อกตู้นิรภัยการเดินทางของคุณ',
      'biometricsFailed': 'การยืนยันตัวตนทางชีวมิติไม่สำเร็จหรือถูกยกเลิก',
      'customBaggageLimitPrompt': 'กำหนดขีดจำกัดเอง (กก.)',
      'testNotificationSent': 'ส่งการแจ้งเตือนทดสอบไปยังอุปกรณ์ของคุณแล้ว',
      'pinWidgetSuccess': 'เพิ่มวิดเจ็ตลงในหน้าจอหลักแล้ว',
      'pinWidgetGuide': 'แตะหน้าจอหลักค้างไว้แล้วเลือก วิดเจ็ต > PackBuddy',
    },
    'vi': {
      'vaultBiometricReason': 'Xác minh vân tay hoặc khuôn mặt để mở khóa kho lưu trữ du lịch của bạn',
      'biometricsFailed': 'Xác minh sinh trắc học thất bại hoặc đã bị hủy.',
      'customBaggageLimitPrompt': 'Đặt giới hạn tùy chỉnh (kg)',
      'testNotificationSent': 'Thông báo thử nghiệm đã gửi đến thiết bị của bạn.',
      'pinWidgetSuccess': 'Tiện ích đã được thêm vào màn hình chính.',
      'pinWidgetGuide': 'Nhấn giữ màn hình chính và chọn Tiện ích > PackBuddy.',
    },
    'el': {
      'vaultBiometricReason': 'Επαληθεύστε το δακτυλικό αποτύπωμα ή το πρόσωπό σας για να ξεκλειδώσετε το ταξιδιωτικό σας θησαυροφυλάκιο',
      'biometricsFailed': 'Η βιομετρική επαλήθευση απέτυχε ή ακυρώθηκε.',
      'customBaggageLimitPrompt': 'Ορισμός προσαρμοσμένου ορίου (kg)',
      'testNotificationSent': 'Η δοκιμαστική ειδοποίηση στάλθηκε στη συσκευή σας.',
      'pinWidgetSuccess': 'Το γραφικό στοιχείο προστέθηκε στην αρχική οθόνη.',
      'pinWidgetGuide': 'Πατήστε παρατεταμένα στην αρχική οθόνη και επιλέξτε Γραφικά στοιχεία > PackBuddy.',
    },
  };

  final arbDir = Directory('lib/l10n');
  final arbFiles = arbDir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb')).toList();

  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    final langCode = fileName.replaceAll('app_', '').replaceAll('.arb', '');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final langTranslations = newTranslations[langCode] ?? newTranslations['en']!;
    var added = 0;

    for (final entry in langTranslations.entries) {
      if (!data.containsKey(entry.key)) {
        data[entry.key] = entry.value;
        added++;
      }
    }

    if (added > 0) {
      const encoder = JsonEncoder.withIndent('  ');
      file.writeAsStringSync('${encoder.convert(data)}\n');
      print('Added $added keys to $fileName');
    } else {
      print('No new keys needed for $fileName');
    }
  }

  print('Translation update finished successfully!');
}
