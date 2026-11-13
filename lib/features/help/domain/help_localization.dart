/// Native comprehensive localization for PackBuddy Help & FAQ across all 20 supported languages.
class HelpLocalization {
  HelpLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String getTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Yardım & SSS';
      case 'de':
        return 'Hilfe & FAQ';
      case 'es':
        return 'Ayuda y Preguntas';
      case 'fr':
        return 'Aide et FAQ';
      case 'it':
        return 'Aiuto e FAQ';
      case 'pt':
        return 'Ajuda e Perguntas';
      case 'ru':
        return 'Помощь и FAQ';
      case 'zh':
        return '帮助与常见问题';
      case 'ja':
        return 'ヘルプとFAQ';
      case 'ko':
        return '도움말 및 FAQ';
      case 'hi':
        return 'सहायता और अक्सर पूछे जाने वाले प्रश्न';
      case 'ar':
        return 'المساعدة والأسئلة الشائعة';
      case 'nl':
        return 'Hulp & FAQ';
      case 'el':
        return 'Βοήθεια & Συχνές Ερωτήσεις';
      case 'sv':
        return 'Hjälp & FAQ';
      case 'pl':
        return 'Pomoc i FAQ';
      case 'id':
        return 'Bantuan & FAQ';
      case 'th':
        return 'ความช่วยเหลือและคำถามที่พบบ่อย';
      case 'vi':
        return 'Trợ giúp & Câu hỏi thường gặp';
      case 'en':
      default:
        return 'Help & FAQ';
    }
  }

  static String getSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Sıkça sorulan sorular, rehberler ve destek';
      case 'de':
        return 'Häufig gestellte Fragen, Anleitungen und Support';
      case 'es':
        return 'Preguntas frecuentes, guías y asistencia';
      case 'fr':
        return 'Foire aux questions, guides et assistance';
      case 'it':
        return 'Domande frequenti, guide e supporto';
      case 'pt':
        return 'Perguntas frequentes, guias e suporte';
      case 'ru':
        return 'Частые вопросы, руководства и поддержка';
      case 'zh':
        return '常见问题解答、指南与技术支持';
      case 'ja':
        return 'よくある質問、ガイド、およびサポート';
      case 'ko':
        return '자주 묻는 질문, 가이드 및 고객 지원';
      case 'hi':
        return 'अक्सर पूछे जाने वाले प्रश्न, गाइड और सहायता';
      case 'ar':
        return 'الأسئلة الشائعة والأدلة والدعم الفني';
      case 'nl':
        return 'Veelgestelde vragen, gidsen en ondersteuning';
      case 'el':
        return 'Συχνές ερωτήσεις, οδηγοί και υποστήριξη';
      case 'sv':
        return 'Vanliga frågor, guider och support';
      case 'pl':
        return 'Najczęściej zadawane pytania, poradniki i pomoc';
      case 'id':
        return 'Pertanyaan umum, panduan, dan dukungan';
      case 'th':
        return 'คำถามที่พบบ่อย คู่มือการใช้งาน และการสนับสนุน';
      case 'vi':
        return 'Câu hỏi thường gặp, hướng dẫn và hỗ trợ';
      case 'en':
      default:
        return 'Frequently asked questions, guides and support';
    }
  }

  static String getSearchHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Soru veya anahtar kelime ara...';
      case 'de':
        return 'Frage oder Stichwort suchen...';
      case 'es':
        return 'Buscar pregunta o palabra clave...';
      case 'fr':
        return 'Rechercher une question ou un mot-clé...';
      case 'it':
        return 'Cerca domanda o parola chiave...';
      case 'pt':
        return 'Buscar pergunta ou palavra-chave...';
      case 'ru':
        return 'Поиск вопроса или ключевого слова...';
      case 'zh':
        return '搜索问题或关键词...';
      case 'ja':
        return '質問やキーワードを検索...';
      case 'ko':
        return '질문 또는 키워드 검색...';
      case 'hi':
        return 'प्रश्न या कीवर्ड खोजें...';
      case 'ar':
        return 'ابحث عن سؤال أو كلمة مفتاحية...';
      case 'nl':
        return 'Zoek vraag of trefwoord...';
      case 'el':
        return 'Αναζήτηση ερώτησης ή λέξης-κλειδιού...';
      case 'sv':
        return 'Sök fråga eller nyckelord...';
      case 'pl':
        return 'Szukaj pytania lub słowa kluczowego...';
      case 'id':
        return 'Cari pertanyaan atau kata kunci...';
      case 'th':
        return 'ค้นหาคำถามหรือคีย์เวิร์ด...';
      case 'vi':
        return 'Tìm kiếm câu hỏi hoặc từ khóa...';
      case 'en':
      default:
        return 'Search question or keyword...';
    }
  }

  static String getAllTopics(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Tümü';
      case 'de':
        return 'Alle';
      case 'es':
        return 'Todos';
      case 'fr':
        return 'Tous';
      case 'it':
        return 'Tutti';
      case 'pt':
        return 'Todos';
      case 'ru':
        return 'Все';
      case 'zh':
        return '全部';
      case 'ja':
        return 'すべて';
      case 'ko':
        return '전체';
      case 'hi':
        return 'सभी';
      case 'ar':
        return 'الكل';
      case 'nl':
        return 'Alle';
      case 'el':
        return 'Όλα';
      case 'sv':
        return 'Alla';
      case 'pl':
        return 'Wszystkie';
      case 'id':
        return 'Semua';
      case 'th':
        return 'ทั้งหมด';
      case 'vi':
        return 'Tất cả';
      case 'en':
      default:
        return 'All';
    }
  }

  static String getCategoryName(String category, String lang) {
    final l = _cleanLang(lang);
    switch (category) {
      case 'general':
        return l == 'tr' ? 'Genel' : (l == 'de' ? 'Allgemein' : (l == 'es' ? 'General' : (l == 'fr' ? 'Général' : 'General')));
      case 'vault':
        return l == 'tr' ? 'Kasa & Güvenlik' : (l == 'de' ? 'Tresor & Sicherheit' : (l == 'es' ? 'Bóveda y Seguridad' : (l == 'fr' ? 'Coffre & Sécurité' : 'Vault & Security')));
      case 'budget':
        return l == 'tr' ? 'Seyahat & Bütçe' : (l == 'de' ? 'Reisen & Budget' : (l == 'es' ? 'Viajes y Presupuesto' : (l == 'fr' ? 'Voyages & Budget' : 'Trips & Budget')));
      case 'checklist':
        return l == 'tr' ? 'Bavul & Liste' : (l == 'de' ? 'Gepäck & Packliste' : (l == 'es' ? 'Equipaje y Lista' : (l == 'fr' ? 'Bagages & Valise' : 'Packing & Baggage')));
      case 'sync':
        return l == 'tr' ? 'Bulut Eşleme' : (l == 'de' ? 'Cloud-Synchronisation' : (l == 'es' ? 'Sincronización' : (l == 'fr' ? 'Synchronisation Cloud' : 'Cloud Sync')));
      case 'pro':
        return 'PackBuddy Pro';
      case 'account':
        return l == 'tr' ? 'Hesap & Gizlilik' : (l == 'de' ? 'Konto & Datenschutz' : (l == 'es' ? 'Cuenta y Privacidad' : (l == 'fr' ? 'Compte et Confidentialité' : 'Account & Privacy')));
      default:
        return category;
    }
  }

  static String getContactUs(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Sorunuza yanıt bulamadınız mı?';
      case 'de':
        return 'Haben Sie keine Antwort gefunden?';
      case 'es':
        return '¿No encontraste lo que buscabas?';
      case 'fr':
        return 'Vous n\'avez pas trouvé votre réponse ?';
      case 'it':
        return 'Non hai trovato la risposta?';
      case 'pt':
        return 'Não encontrou sua resposta?';
      case 'ru':
        return 'Не нашли ответ на свой вопрос?';
      case 'zh':
        return '没有找到您需要的答案？';
      case 'ja':
        return '解決策が見つかりませんでしたか？';
      case 'ko':
        return '원하는 답변을 찾지 못하셨나요?';
      case 'hi':
        return 'क्या आपको अपना उत्तर नहीं मिला?';
      case 'ar':
        return 'لم تجد الإجابة التي تبحث عنها؟';
      case 'nl':
        return 'Geen antwoord gevonden?';
      case 'el':
        return 'Δεν βρήκατε απάντηση;';
      case 'sv':
        return 'Hittade du inte svaret?';
      case 'pl':
        return 'Nie znalazłeś odpowiedzi?';
      case 'id':
        return 'Belum menemukan jawaban?';
      case 'th':
        return 'ยังไม่พบคำตอบที่คุณต้องการ?';
      case 'vi':
        return 'Chưa tìm thấy câu trả lời?';
      case 'en':
      default:
        return 'Still have questions?';
    }
  }

  static String getContactUsSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Destek ekibimiz seyahatinizi kolaylaştırmak için her zaman yanınızda.';
      case 'de':
        return 'Unser Support-Team hilft Ihnen gerne jederzeit weiter.';
      case 'es':
        return 'Nuestro equipo de soporte está listo para asistirte en todo momento.';
      case 'fr':
        return 'Notre équipe d\'assistance est à votre disposition pour vous aider.';
      case 'it':
        return 'Il nostro team di supporto è a tua completa disposizione.';
      case 'pt':
        return 'Nossa equipe de suporte está pronta para ajudar a qualquer momento.';
      case 'ru':
        return 'Наша служба поддержки с радостью поможет вам в любое время.';
      case 'zh':
        return '我们的技术支持团队随时乐意为您提供解答与协助。';
      case 'ja':
        return 'サポートチームがいつでも丁寧にご案内いたします。';
      case 'ko':
        return '고객 지원팀이 언제든지 친절하게 도와드리겠습니다.';
      case 'hi':
        return 'हमारी सहायता टीम आपकी मदद के लिए सदैव उपलब्ध है।';
      case 'ar':
        return 'فريق الدعم لدينا مستعد دائماً لمساعدتك في أي وقت.';
      case 'nl':
        return 'Ons ondersteuningsteam staat altijd voor u klaar.';
      case 'el':
        return 'Η ομάδα υποστήριξής μας είναι πάντα έτοιμη να σας βοηθήσει.';
      case 'sv':
        return 'Vårt supportteam hjälper dig gärna när som helst.';
      case 'pl':
        return 'Nasz zespół wsparcia z przyjemnością Ci pomoże.';
      case 'id':
        return 'Tim bantuan kami siap membantu Anda kapan saja.';
      case 'th':
        return 'ทีมงานฝ่ายสนับสนุนของเราพร้อมช่วยเหลือคุณเสมอ';
      case 'vi':
        return 'Đội ngũ hỗ trợ của chúng tôi luôn sẵn sàng trợ giúp bạn.';
      case 'en':
      default:
        return 'Our support team is always ready to help you with your journey.';
    }
  }

  static String getSendEmail(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Destek Ekibine Yazın';
      case 'de':
        return 'Support kontaktieren';
      case 'es':
        return 'Escribir a soporte';
      case 'fr':
        return 'Contacter le support';
      case 'it':
        return 'Contatta il supporto';
      case 'pt':
        return 'Contatar suporte';
      case 'ru':
        return 'Написать в поддержку';
      case 'zh':
        return '联系客户支持';
      case 'ja':
        return 'サポートに連絡';
      case 'ko':
        return '지원팀에 문의';
      case 'hi':
        return 'सहायता टीम से संपर्क करें';
      case 'ar':
        return 'مراسلة فريق الدعم';
      case 'nl':
        return 'Contact opnemen';
      case 'el':
        return 'Επικοινωνία με υποστήριξη';
      case 'sv':
        return 'Kontakta support';
      case 'pl':
        return 'Napisz do wsparcia';
      case 'id':
        return 'Hubungi Bantuan';
      case 'th':
        return 'ติดต่อฝ่ายสนับสนุน';
      case 'vi':
        return 'Liên hệ hỗ trợ';
      case 'en':
      default:
        return 'Contact Support';
    }
  }

  static String getReplayWalkthrough(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Tanıtım Turunu Yeniden Başlat';
      case 'de':
        return 'Einführungstour wiederholen';
      case 'es':
        return 'Repetir recorrido guiado';
      case 'fr':
        return 'Revoir la visite guidée';
      case 'it':
        return 'Ripeti il tour guidato';
      case 'pt':
        return 'Repetir tour inicial';
      case 'ru':
        return 'Повторить вводный тур';
      case 'zh':
        return '重新查看引导流程';
      case 'ja':
        return 'チュートリアルを再開';
      case 'ko':
        return '소개 둘러보기 다시보기';
      case 'hi':
        return 'परिचय टूर दोबारा देखें';
      case 'ar':
        return 'إعادة الجولة التوجيهية';
      case 'nl':
        return 'Rondleiding herhalen';
      case 'el':
        return 'Επανάληψη περιήγησης';
      case 'sv':
        return 'Spela upp introduktion igen';
      case 'pl':
        return 'Odtwórz przewodnik ponownie';
      case 'id':
        return 'Putar Ulang Tur Pengenalan';
      case 'th':
        return 'เล่นทัวร์แนะนำอีกครั้ง';
      case 'vi':
        return 'Xem lại hướng dẫn ban đầu';
      case 'en':
      default:
        return 'Replay Onboarding Tour';
    }
  }

  static String getNoResultsFound(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Aramanıza uygun soru veya rehber bulunamadı.';
      case 'de':
        return 'Keine passenden Fragen oder Anleitungen gefunden.';
      case 'es':
        return 'No se encontraron preguntas o guías para esta búsqueda.';
      case 'fr':
        return 'Aucune question ou guide correspondant trouvé.';
      case 'it':
        return 'Nessuna domanda o guida corrispondente trovata.';
      case 'pt':
        return 'Nenhuma pergunta ou guia correspondente encontrada.';
      case 'ru':
        return 'Вопросы или руководства по вашему запросу не найдены.';
      case 'zh':
        return '未找到匹配的问题或指南。';
      case 'ja':
        return '一致する質問やガイドは見つかりませんでした。';
      case 'ko':
        return '일치하는 질문 또는 가이드를 찾을 수 없습니다.';
      case 'hi':
        return 'आपके खोज से मेल खाता कोई प्रश्न या गाइड नहीं मिला।';
      case 'ar':
        return 'لم يتم العثور على أسئلة أو أدلة مطابقة.';
      case 'nl':
        return 'Geen overeenkomende vragen of gidsen gevonden.';
      case 'el':
        return 'Δεν βρέθηκαν αντίστοιχες ερωτήσεις ή οδηγοί.';
      case 'sv':
        return 'Inga matchande frågor eller guider hittades.';
      case 'pl':
        return 'Nie znaleziono pasujących pytań ani poradników.';
      case 'id':
        return 'Tidak ada pertanyaan atau panduan yang cocok.';
      case 'th':
        return 'ไม่พบคำถามหรือคำแนะนำที่ตรงกับการค้นหา';
      case 'vi':
        return 'Không tìm thấy câu hỏi hoặc hướng dẫn phù hợp.';
      case 'en':
      default:
        return 'No matching questions or guides found.';
    }
  }

  // --- SSS SORULARI VE CEVAPLARI (FAQ CONTENT) ---

  static String getQuestion(String id, String lang) {
    final isTr = _cleanLang(lang) == 'tr';
    switch (id) {
      case 'whatIsPackBuddy':
        return isTr ? 'PackBuddy nedir ve nasıl çalışır?' : 'What is PackBuddy and how does it work?';
      case 'offlineOperation':
        return isTr ? 'Uygulama internetsiz (çevrimdışı) çalışır mı?' : 'Does the app work offline without internet?';
      case 'vaultPinForgot':
        return isTr ? 'Kasa (Vault) PIN kodumu unutursam ne yapmalıyım?' : 'What should I do if I forget my Vault PIN?';
      case 'vaultBiometrics':
        return isTr ? 'Kasa kilidinde parmak izi veya Face ID nasıl kullanılır?' : 'How do I enable biometric lock (Face ID/fingerprint) for the Vault?';
      case 'collaborativeTrips':
        return isTr ? 'Ortak seyahat ve arkadaş davet etme nasıl çalışır?' : 'How do shared collaborative trips and invite codes work?';
      case 'currencyConversion':
        return isTr ? 'Farklı para birimleriyle harcama nasıl takip edilir?' : 'How does multi-currency expense tracking and conversion work?';
      case 'smartTemplates':
        return isTr ? 'Akıllı bavul hazırlık şablonlarını nasıl kullanırım?' : 'How do I use smart packing list templates?';
      case 'airlineBaggage':
        return isTr ? 'Havayolu bagaj kuralları ve boyut sınırları nerede?' : 'Where can I find airline baggage allowances and dimensions?';
      case 'twoWaySync':
        return isTr ? 'Çift yönlü bulut eşleme (Two-Way Sync) ne zaman devreye girer?' : 'When does two-way cloud sync trigger?';
      case 'multiDeviceAccess':
        return isTr ? 'Aynı hesabı birden fazla cihazda kullanabilir miyim?' : 'Can I use the same account across multiple devices?';
      case 'packBuddyProBenefits':
        return isTr ? 'PackBuddy Pro aboneliği neleri kapsar?' : 'What features are included in PackBuddy Pro?';
      case 'restorePurchases':
        return isTr ? 'Satın aldığım Pro aboneliği yeni cihaza nasıl aktarırım?' : 'How do I restore my Pro subscription on a new device?';
      case 'accountDeletion':
        return isTr ? 'Hesabımı ve verilerimi nasıl silebilirim?' : 'How can I request account and data deletion?';
      case 'dataExportPrivacy':
        return isTr ? 'Kişisel verilerim ve belgelerim güvende mi?' : 'Are my personal documents and data safe and private?';
      default:
        return id;
    }
  }

  static String getAnswer(String id, String lang) {
    final isTr = _cleanLang(lang) == 'tr';
    switch (id) {
      case 'whatIsPackBuddy':
        return isTr
            ? 'PackBuddy, seyahatlerinizi baştan sona planlamanıza yardımcı olan minimalist ve çevrimdışı öncelikli bir seyahat asistanıdır. Seyahat bütçesi yönetimi, bavul hazırlık listesi, şifreli belge kasası ve ziyaret edilen ülkeler haritasını tek bir çatı altında sunar.'
            : 'PackBuddy is a minimalist, offline-first travel companion that helps you organize your journeys from start to finish. It combines multi-currency budget tracking, smart luggage checklists, an encrypted document vault, and an interactive world travel map in one place.';
      case 'offlineOperation':
        return isTr
            ? 'Evet! PackBuddy tamamen "Offline-First" (çevrimdışı öncelikli) mimariye sahiptir. Tüm verileriniz öncelikle cihazınızın yerel SQLite veri tabanında saklanır. İnternetiniz olmadığında da seyahatlerinizi görüntüleyebilir, yeni harcamalar veya bavul maddeleri ekleyebilirsiniz. İnternete bağlandığınızda değişiklikleriniz otomatik olarak bulutla eşitlenir.'
            : 'Yes! PackBuddy is built with an offline-first architecture. All your trips, checklists, and expenses are saved locally in SQLite first. You can manage your travel without any internet connection. Once you reconnect, changes automatically sync with the cloud.';
      case 'vaultPinForgot':
        return isTr
            ? 'Kasa ekranında "PIN\'imi Unuttum" seçeneğine tıklayarak kayıtlı e-posta adresinize sıfırlama talimatı gönderebilirsiniz. Ayrıca Google ile giriş yapan kullanıcılar güvenlik doğrulamasıyla yeni bir PIN belirleyebilir.'
            : 'On the Vault unlock screen, tap "Forgot PIN" to initiate recovery. If you are signed in via Google or verified email, you can securely reset your PIN through identity confirmation.';
      case 'vaultBiometrics':
        return isTr
            ? 'Ayarlar > Güvenlik bölümünden veya Kasa içerisindeki güvenlik butonundan "Biyometrik Kilit" anahtarını açabilirsiniz. Cihazınızın desteklediği Touch ID, Face ID veya parmak izi okuyucusuyla kasayı tek dokunuşla güvenle açabilirsiniz.'
            : 'Navigate to Settings > Security or inside the Vault settings, and toggle "Biometric Unlock". Once enabled, you can seamlessly open your encrypted vault using Face ID, Touch ID, or fingerprint authentication.';
      case 'collaborativeTrips':
        return isTr
            ? 'Bir seyahatin detay sayfasına gidip "Paylaş" butonuna dokunarak benzersiz bir davet kodu (Invite Code) oluşturabilirsiniz. Arkadaşınız bu kodu girdiğinde, seyahat listesini ve harcamaları ortaklaşa canlı olarak düzenleyebilirsiniz.'
            : 'Open any trip, tap the "Share" action, and generate a unique invite code. When your travel companion enters this code in PackBuddy, both of you can view and collaborate on packing lists and expenses in real time.';
      case 'currencyConversion':
        return isTr
            ? 'PackBuddy 50\'den fazla dünya para birimini destekler. Her harcama eklediğinizde yerel para birimini seçebilirsiniz; uygulama harcamanızı otomatik olarak seyahatinizin ana para birimine dönüştürür. Döviz kurları internete her bağlandığınızda arka planda güncellenir ve internetsiz ortamda son alınan kurlarla çalışır.'
            : 'PackBuddy supports over 50 global currencies. When recording an expense, simply pick the transaction currency; the app automatically converts it to your trip\'s base currency using live exchange rates cached for offline use.';
      case 'smartTemplates':
        return isTr
            ? 'Bavul sekmesinde üst kısımdaki "Şablonlar" butonuna tıklayarak Yaz Tatili, Kış Tatili, İş Gezisi, Kamp, Doğa Yürüyüşü veya Bebekli Seyahat gibi hazır paketleri tek dokunuşla seyahatinize ekleyebilirsiniz.'
            : 'In the Checklist tab, tap "Smart Templates" to instantly generate tailored packing lists for Summer Beach, Winter Ski, Business Trip, Camping, Backpacking, or Family Travel.';
      case 'airlineBaggage':
        return isTr
            ? 'Bavul sekmesindeki "Havayolu Rehberi" butonuna tıklayarak Türk Hava Yolları, Pegasus, Emirates, Ryanair, Lufthansa gibi 50\'den fazla havayolunun kabin içi, kişisel eşya ve kayıtlı bagaj boyut/ağırlık sınırlarını inceleyebilirsiniz.'
            : 'Tap "Airline Baggage Guide" in the Checklist tab to browse carry-on, personal item, and checked baggage size/weight regulations for over 50 major international airlines.';
      case 'twoWaySync':
        return isTr
            ? 'Uygulama açıldığında, internet bağlantısı geri geldiğinde veya bir veri eklediğinizde sistem otomatik olarak çift yönlü diferansiyel eşleme gerçekleştirir. Birden fazla cihazdaki değişiklikler zaman damgasına göre (Last-Write-Wins) çakışmasız olarak birleştirilir.'
            : 'Sync triggers automatically whenever the app opens, connectivity is restored, or a record is modified. Two-way delta synchronization reconciles local and remote changes based on timestamps without data loss.';
      case 'multiDeviceAccess':
        return isTr
            ? 'Evet! Aynı Google veya e-posta hesabınızla hem telefonunuzda hem de tabletinizde giriş yapabilirsiniz. Tüm seyahatleriniz, belgeleriniz ve bavul listeleriniz otomatik olarak senkronize kalır.'
            : 'Yes! Sign in with your registered account on your phone and tablet; your trips, safe documents, and baggage items will seamlessly stay synchronized across all your devices.';
      case 'packBuddyProBenefits':
        return isTr
            ? 'PackBuddy Pro; sınırsız seyahat oluşturma, bulut belge kasasında yüksek depolama alanı, ortak seyahat işbirliği, gelişmiş bütçe grafikleri ve havaalanı bagaj hakları rehberinin tamamına sınırsız erişim sağlar.'
            : 'PackBuddy Pro unlocks unlimited trips, high-capacity cloud document storage, collaborative shared lists, advanced budget analytics, and full access to airline baggage specifications.';
      case 'restorePurchases':
        return isTr
            ? 'Ayarlar > PackBuddy Pro bölümünde yer alan "Satın Alımları Geri Yükle" seçeneğine tıklayarak mevcut Google Play Store veya Apple App Store aboneliğinizi yeni cihazınıza anında aktarabilirsiniz.'
            : 'Open Settings > PackBuddy Pro and tap "Restore Purchases". Your active subscription linked to your Google Play or Apple account will immediately reactivate on your current device.';
      case 'accountDeletion':
        return isTr
            ? 'Ayarlar > Güvenlik & Hesap bölümünün en altında yer alan "Hesabımı Sil" seçeneğini kullanabilirsiniz. Hesabınız 15 günlük yasal cayma süresiyle güvenli bir şekilde silinmek üzere planlanır ve tüm bulut verileriniz temizlenir.'
            : 'Go to Settings > Security & Account and select "Delete Account". Your account is placed in a 15-day safety grace period, after which all personal cloud and local records are permanently wiped.';
      case 'dataExportPrivacy':
        return isTr
            ? 'Kişisel kasa belgeleriniz yerel ortamda AES şifrelemesiyle ve Firebase üzerinde kullanıcı bazlı katı güvenlik kurallarıyla korunmaktadır. Verileriniz asla üçüncü taraflarla paylaşılmaz veya reklam amaçlı kullanılmaz.'
            : 'Your vault documents are encrypted with AES security and isolated per user via strict Firestore database rules. Your private data is never sold or shared with any third party.';
      default:
        return '';
    }
  }
}

