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
        switch (l) {
          case 'tr': return 'Genel';
          case 'de': return 'Allgemein';
          case 'fr': return 'Général';
          case 'es': return 'General';
          case 'it': return 'Generale';
          case 'pt': return 'Geral';
          case 'ru': return 'Общее';
          case 'zh': return '常规';
          case 'ja': return '一般';
          case 'ko': return '일반';
          case 'ar': return 'عام';
          case 'hi': return 'सामान्य';
          case 'nl': return 'Algemeen';
          case 'el': return 'Γενικά';
          case 'sv': return 'Allmänt';
          case 'pl': return 'Ogólne';
          case 'id': return 'Umum';
          case 'th': return 'ทั่วไป';
          case 'vi': return 'Chung';
          case 'en':
          default: return 'General';
        }
      case 'vault':
        switch (l) {
          case 'tr': return 'Kasa & Güvenlik';
          case 'de': return 'Tresor & Sicherheit';
          case 'fr': return 'Coffre & Sécurité';
          case 'es': return 'Bóveda y Seguridad';
          case 'it': return 'Cassaforte e Sicurezza';
          case 'pt': return 'Cofre & Segurança';
          case 'ru': return 'Сейф и безопасность';
          case 'zh': return '保险箱与安全';
          case 'ja': return '保管庫とセキュリティ';
          case 'ko': return '보관함 및 보안';
          case 'ar': return 'الخزنة والأمان';
          case 'hi': return 'वॉल्ट और सुरक्षा';
          case 'nl': return 'Kluis & Veiligheid';
          case 'el': return 'Θυρίδα & Ασφάλεια';
          case 'sv': return 'Valv & Säkerhet';
          case 'pl': return 'Sejf i bezpieczeństwo';
          case 'id': return 'Brankas & Keamanan';
          case 'th': return 'ตู้นิรภัยและความปลอดภัย';
          case 'vi': return 'Két an toàn & Bảo mật';
          case 'en':
          default: return 'Vault & Security';
        }
      case 'budget':
        switch (l) {
          case 'tr': return 'Seyahat & Bütçe';
          case 'de': return 'Reisen & Budget';
          case 'fr': return 'Voyages & Budget';
          case 'es': return 'Viajes y Presupuesto';
          case 'it': return 'Viaggi e Budget';
          case 'pt': return 'Viagens & Orçamento';
          case 'ru': return 'Поездки и бюджет';
          case 'zh': return '旅行与预算';
          case 'ja': return '旅行と予算';
          case 'ko': return '여행 및 예산';
          case 'ar': return 'الرحلات والميزانية';
          case 'hi': return 'यात्रा और बजट';
          case 'nl': return 'Reizen & Budget';
          case 'el': return 'Ταξίδια & Προϋπολογισμός';
          case 'sv': return 'Resor & Budget';
          case 'pl': return 'Podróże i budżet';
          case 'id': return 'Perjalanan & Anggaran';
          case 'th': return 'การเดินทางและงบประมาณ';
          case 'vi': return 'Chuyến đi & Ngân sách';
          case 'en':
          default: return 'Trips & Budget';
        }
      case 'checklist':
        switch (l) {
          case 'tr': return 'Bavul & Liste';
          case 'de': return 'Gepäck & Packliste';
          case 'fr': return 'Bagages & Valise';
          case 'es': return 'Equipaje y Lista';
          case 'it': return 'Valigia e Lista';
          case 'pt': return 'Bagagem & Lista';
          case 'ru': return 'Багаж и сборы';
          case 'zh': return '行李与清单';
          case 'ja': return '荷物と持ち物リスト';
          case 'ko': return '수하물 및 체크리스트';
          case 'ar': return 'الأمتعة وقائمة التعبئة';
          case 'hi': return 'सामान और पैकिंग सूची';
          case 'nl': return 'Bagage & Inpaklijst';
          case 'el': return 'Αποσκευές & Λίστα';
          case 'sv': return 'Bagage & Packlista';
          case 'pl': return 'Bagaż i lista';
          case 'id': return 'Bagasi & Daftar Bawaan';
          case 'th': return 'สัมภาระและรายการจัดกระเป๋า';
          case 'vi': return 'Hành lý & Danh sách';
          case 'en':
          default: return 'Packing & Baggage';
        }
      case 'sync':
        switch (l) {
          case 'tr': return 'Bulut Eşleme';
          case 'de': return 'Cloud-Synchronisation';
          case 'fr': return 'Synchronisation Cloud';
          case 'es': return 'Sincronización';
          case 'it': return 'Sincronizzazione Cloud';
          case 'pt': return 'Sincronização em Nuvem';
          case 'ru': return 'Облачная синхронизация';
          case 'zh': return '云端同步';
          case 'ja': return 'クラウド同期';
          case 'ko': return '클라우드 동기화';
          case 'ar': return 'المزامنة السحابية';
          case 'hi': return 'क्लाउड सिंक';
          case 'nl': return 'Cloudsynchronisatie';
          case 'el': return 'Συγχρονισμός Cloud';
          case 'sv': return 'Molnsynkronisering';
          case 'pl': return 'Synchronizacja w chmurze';
          case 'id': return 'Sinkronisasi Cloud';
          case 'th': return 'การซิงค์ข้อมูลบนคลาวด์';
          case 'vi': return 'Đồng bộ đám mây';
          case 'en':
          default: return 'Cloud Sync';
        }
      case 'pro':
        return 'PackBuddy Pro';
      case 'account':
        switch (l) {
          case 'tr': return 'Hesap & Gizlilik';
          case 'de': return 'Konto & Datenschutz';
          case 'fr': return 'Compte et Confidentialité';
          case 'es': return 'Cuenta y Privacidad';
          case 'it': return 'Account e Privacy';
          case 'pt': return 'Conta & Privacidade';
          case 'ru': return 'Аккаунт и конфиденциальность';
          case 'zh': return '账户与隐私';
          case 'ja': return 'アカウントとプライバシー';
          case 'ko': return '계정 및 개인정보 보호';
          case 'ar': return 'الحساب والخصوصية';
          case 'hi': return 'खाता और गोपनीयता';
          case 'nl': return 'Account & Privacy';
          case 'el': return 'Λογαριασμός & Απόρρητο';
          case 'sv': return 'Konto & Integritet';
          case 'pl': return 'Konto i prywatność';
          case 'id': return 'Akun & Privasi';
          case 'th': return 'บัญชีและความเป็นส่วนตัว';
          case 'vi': return 'Tài khoản & Quyền riêng tư';
          case 'en':
          default: return 'Account & Privacy';
        }
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
    final clean = _cleanLang(lang);
    switch (id) {
      case 'whatIsPackBuddy':
        switch (clean) {
          case 'tr': return 'PackBuddy nedir ve nasıl çalışır?';
          case 'de': return 'Was ist PackBuddy und wie funktioniert es?';
          case 'fr': return 'Qu\'est-ce que PackBuddy et comment ça marche ?';
          case 'es': return '¿Qué es PackBuddy y cómo funciona?';
          case 'it': return 'Cos\'è PackBuddy e come funziona?';
          case 'pt': return 'O que é o PackBuddy e como funciona?';
          case 'ru': return 'Что такое PackBuddy и как это работает?';
          case 'zh': return '什么是 PackBuddy？它如何运作？';
          case 'ja': return 'PackBuddy とは何ですか？どのように使いますか？';
          case 'ko': return 'PackBuddy는 무엇이며 어떻게 작동하나요?';
          case 'ar': return 'ما هو PackBuddy وكيف يعمل؟';
          case 'hi': return 'PackBuddy क्या है और यह कैसे काम करता है?';
          case 'nl': return 'Wat is PackBuddy en hoe werkt het?';
          case 'el': return 'Τι είναι το PackBuddy και πώς λειτουργεί;';
          case 'sv': return 'Vad är PackBuddy och hur fungerar det?';
          case 'pl': return 'Czym jest PackBuddy i jak działa?';
          case 'id': return 'Apa itu PackBuddy dan bagaimana cara kerjanya?';
          case 'th': return 'PackBuddy คืออะไรและทำงานอย่างไร?';
          case 'vi': return 'PackBuddy là gì và hoạt động như thế nào?';
          case 'en':
          default: return 'What is PackBuddy and how does it work?';
        }
      case 'offlineOperation':
        switch (clean) {
          case 'tr': return 'Uygulama internetsiz (çevrimdışı) çalışır mı?';
          case 'de': return 'Funktioniert die App offline ohne Internet?';
          case 'fr': return 'L\'application fonctionne-t-elle hors ligne sans internet ?';
          case 'es': return '¿Funciona la aplicación sin conexión a internet?';
          case 'it': return 'L\'app funziona offline senza connessione internet?';
          case 'pt': return 'O aplicativo funciona offline sem internet?';
          case 'ru': return 'Работает ли приложение без интернета (офлайн)?';
          case 'zh': return '应用可以在离线无网络状态下正常使用吗？';
          case 'ja': return 'アプリはオフラインでも利用できますか？';
          case 'ko': return '인터넷 없이 오프라인에서도 앱을 사용할 수 있나요?';
          case 'ar': return 'هل يعمل التطبيق دون اتصال بالإنترنت؟';
          case 'hi': return 'क्या ऐप बिना इंटरनेट के ऑफलाइन काम करता है?';
          case 'nl': return 'Werkt de app offline zonder internetverbinding?';
          case 'el': return 'Λειτουργεί η εφαρμογή εκτός σύνδεσης χωρίς διαδίκτυο;';
          case 'sv': return 'Fungerar appen offline utan internetanslutning?';
          case 'pl': return 'Czy aplikacja działa w trybie offline bez internetu?';
          case 'id': return 'Apakah aplikasi dapat berfungsi offline tanpa internet?';
          case 'th': return 'แอปสามารถทำงานแบบออฟไลน์โดยไม่มีอินเทอร์เน็ตได้หรือไม่?';
          case 'vi': return 'Ứng dụng có hoạt động ngoại tuyến khi không có mạng không?';
          case 'en':
          default: return 'Does the app work offline without internet?';
        }
      case 'vaultPinForgot':
        switch (clean) {
          case 'tr': return 'Kasa (Vault) PIN kodumu unutursam ne yapmalıyım?';
          case 'de': return 'Was kann ich tun, wenn ich meine Tresor-PIN vergessen habe?';
          case 'fr': return 'Que faire si j\'oublie mon code PIN du Coffre-fort ?';
          case 'es': return '¿Qué debo hacer si olvido el PIN de mi Bóveda?';
          case 'it': return 'Cosa devo fare se dimentico il PIN della Cassaforte?';
          case 'pt': return 'O que devo fazer se esquecer o PIN do Cofre?';
          case 'ru': return 'Что делать, если я забуду PIN-код от Сейфа?';
          case 'zh': return '如果忘记了保险箱 PIN 码该怎么办？';
          case 'ja': return '保管庫のPINコードを忘れた場合はどうすればよいですか？';
          case 'ko': return '보관함 PIN 번호를 잊어버렸을 때는 어떻게 하나요?';
          case 'ar': return 'ماذا أفعل إذا نسيت رمز PIN الخاص بالخزنة؟';
          case 'hi': return 'यदि मैं अपना वॉल्ट पिन भूल जाऊं तो क्या करूं?';
          case 'nl': return 'Wat moet ik doen als ik mijn Kluis-pincode vergeet?';
          case 'el': return 'Τι πρέπει να κάνω αν ξεχάσω το PIN της Θυρίδας;';
          case 'sv': return 'Vad ska jag göra om jag glömmer min PIN-kod till Valvet?';
          case 'pl': return 'Co zrobić, jeśli zapomnę kodu PIN do Sejfu?';
          case 'id': return 'Apa yang harus dilakukan jika lupa PIN Brankas?';
          case 'th': return 'ควรทำอย่างไรหากลืมรหัส PIN ตู้นิรภัย?';
          case 'vi': return 'Tôi nên làm gì nếu quên mã PIN Két an toàn?';
          case 'en':
          default: return 'What should I do if I forget my Vault PIN?';
        }
      case 'vaultBiometrics':
        switch (clean) {
          case 'tr': return 'Kasa kilidinde parmak izi veya Face ID nasıl kullanılır?';
          case 'de': return 'Wie verwende ich Fingerabdruck oder Face ID für den Tresor?';
          case 'fr': return 'Comment utiliser l\'empreinte digitale ou Face ID pour le Coffre ?';
          case 'es': return '¿Cómo uso huella dactilar o Face ID para la Bóveda?';
          case 'it': return 'Come uso l\'impronta digitale o il Face ID per la Cassaforte?';
          case 'pt': return 'Como usar biometria (impressão digital ou Face ID) no Cofre?';
          case 'ru': return 'Как использовать отпечаток пальца или Face ID для Сейфа?';
          case 'zh': return '如何为保险箱启用指纹或面容识别（Face ID）？';
          case 'ja': return '保管庫で指紋認証や Face ID を使用するには？';
          case 'ko': return '보관함 잠금에 지문 또는 Face ID를 어떻게 사용하나요?';
          case 'ar': return 'كيف أستخدم بصمة الإصبع أو Face ID لقفل الخزنة؟';
          case 'hi': return 'वॉल्ट के लिए फिंगरप्रिंट या फेस आईडी का उपयोग कैसे करें?';
          case 'nl': return 'Hoe gebruik ik vingerafdruk of Face ID voor de Kluis?';
          case 'el': return 'Πώς χρησιμοποιώ δακτυλικό αποτύπωμα ή Face ID για τη Θυρίδα;';
          case 'sv': return 'Hur använder jag fingeravtryck eller Face ID för Valvet?';
          case 'pl': return 'Jak włączyć odcisk palca lub Face ID dla Sejfu?';
          case 'id': return 'Bagaimana cara menggunakan sidik jari atau Face ID untuk Brankas?';
          case 'th': return 'จะใช้ลายนิ้วมือหรือ Face ID สำหรับปลดล็อกตู้นิรภัยได้อย่างไร?';
          case 'vi': return 'Làm thế nào để dùng vân tay hoặc Face ID cho Két an toàn?';
          case 'en':
          default: return 'How do I enable biometric lock (Face ID/fingerprint) for the Vault?';
        }
      case 'collaborativeTrips':
        switch (clean) {
          case 'tr': return 'Ortak seyahat ve arkadaş davet etme nasıl çalışır?';
          case 'de': return 'Wie funktionieren gemeinsame Reisen und Einladungscodes?';
          case 'fr': return 'Comment fonctionnent les voyages partagés et les codes d\'invitation ?';
          case 'es': return '¿Cómo funcionan los viajes compartidos y los códigos de invitación?';
          case 'it': return 'Come funzionano i viaggi condivisi e i codici di invito?';
          case 'pt': return 'Como funcionam as viagens compartilhadas e códigos de convite?';
          case 'ru': return 'Как работают совместные поездки и коды приглашений?';
          case 'zh': return '多人协同旅行与邀请码是如何运作的？';
          case 'ja': return '共同旅行や友達の招待コードはどのように機能しますか？';
          case 'ko': return '동행자와의 공동 여행 및 초대 코드는 어떻게 작동하나요?';
          case 'ar': return 'كيف تعمل الرحلات المشتركة ورموز الدعوة؟';
          case 'hi': return 'साझा यात्राएं और आमंत्रण कोड कैसे काम करते हैं?';
          case 'nl': return 'Hoe werken gedeelde reizen en uitnodigingscodes?';
          case 'el': return 'Πώς λειτουργούν τα κοινά ταξίδια και οι κωδικοί πρόσκλησης;';
          case 'sv': return 'Hur fungerar delade resor och inbjudningskoder?';
          case 'pl': return 'Jak działają wspólne podróże i kody zaproszeń?';
          case 'id': return 'Bagaimana cara kerja perjalanan bersama dan kode undangan?';
          case 'th': return 'ทริปที่แชร์ร่วมกันและรหัสเชิญเพื่อนทำงานอย่างไร?';
          case 'vi': return 'Chuyến đi cộng tác và mã mời hoạt động như thế nào?';
          case 'en':
          default: return 'How do shared collaborative trips and invite codes work?';
        }
      case 'currencyConversion':
        switch (clean) {
          case 'tr': return 'Farklı para birimleriyle harcama nasıl takip edilir?';
          case 'de': return 'Wie funktioniert die Ausgabenverfolgung in verschiedenen Währungen?';
          case 'fr': return 'Comment suivre les dépenses dans différentes devises ?';
          case 'es': return '¿Cómo registrar y convertir gastos en diferentes monedas?';
          case 'it': return 'Come tracciare e convertire le spese in diverse valute?';
          case 'pt': return 'Como rastrear e converter despesas em diferentes moedas?';
          case 'ru': return 'Как отслеживать и конвертировать расходы в разных валютах?';
          case 'zh': return '多币种支出记账与实时换算是如何进行的？';
          case 'ja': return '異なる通貨での支出管理と為替換算はどのように行われますか？';
          case 'ko': return '다양한 통화로 지출을 기록하고 환전하는 방법은 무엇인가요?';
          case 'ar': return 'كيف يتم تتبع المصاريف بعملات متعددة وتحويلها؟';
          case 'hi': return 'विभिन्न मुद्राओं में खर्च कैसे ट्रैक और रूपांतरित किए जाते हैं?';
          case 'nl': return 'Hoe werkt het omrekenen van uitgaven in vreemde valuta?';
          case 'el': return 'Πώς παρακολουθούνται και μετατρέπονται τα έξοδα σε διαφορετικά νομίσματα;';
          case 'sv': return 'Hur fungerar utgiftsspårning och omvandling i olika valutor?';
          case 'pl': return 'Jak działa śledzenie wydatków w różnych walutach i ich przeliczanie?';
          case 'id': return 'Bagaimana cara melacak dan mengonversi pengeluaran dalam berbagai mata uang?';
          case 'th': return 'การติดตามและแปลงค่าใช้จ่ายในสกุลเงินต่างๆ ทำงานอย่างไร?';
          case 'vi': return 'Cách theo dõi chi tiêu và quy đổi theo nhiều loại tiền tệ?';
          case 'en':
          default: return 'How does multi-currency expense tracking and conversion work?';
        }
      case 'smartTemplates':
        switch (clean) {
          case 'tr': return 'Akıllı bavul hazırlık şablonlarını nasıl kullanırım?';
          case 'de': return 'Wie verwende ich smarte Packvorlagen?';
          case 'fr': return 'Comment utiliser les modèles intelligents de bagages ?';
          case 'es': return '¿Cómo uso las plantillas inteligentes de equipaje?';
          case 'it': return 'Come si usano i modelli intelligenti di valigia?';
          case 'pt': return 'Como usar os modelos inteligentes de preparação de bagagem?';
          case 'ru': return 'Как использовать умные шаблоны сборов чемодана?';
          case 'zh': return '如何使用智能行李打包模板？';
          case 'ja': return 'スマート荷造りテンプレートはどのように使いますか？';
          case 'ko': return '스마트 짐 싸기 템플릿은 어떻게 사용하나요?';
          case 'ar': return 'كيف أستخدم قوالب التعبئة الذكية لحقيبة السفر؟';
          case 'hi': return 'स्मार्ट पैकिंग टेम्प्लेट का उपयोग कैसे करें?';
          case 'nl': return 'Hoe gebruik ik slimme inpaktemplates?';
          case 'el': return 'Πώς χρησιμοποιώ τα έξυπνα πρότυπα πακεταρίσματος;';
          case 'sv': return 'Hur använder jag smarta packmallar?';
          case 'pl': return 'Jak korzystać z inteligentnych szablonów pakowania?';
          case 'id': return 'Bagaimana cara menggunakan template pengepakan pintar?';
          case 'th': return 'จะใช้เทมเพลตจัดกระเป๋าอัจฉริยะได้อย่างไร?';
          case 'vi': return 'Làm thế nào để sử dụng các mẫu hành lý thông minh?';
          case 'en':
          default: return 'How do I use smart packing list templates?';
        }
      case 'airlineBaggage':
        switch (clean) {
          case 'tr': return 'Havayolu bagaj kuralları ve boyut sınırları nerede?';
          case 'de': return 'Wo finde ich Gepäckregeln und Freimengen der Fluggesellschaften?';
          case 'fr': return 'Où trouver les franchises bagages et dimensions des compagnies ?';
          case 'es': return '¿Dónde encuentro las reglas y límites de equipaje de las aerolíneas?';
          case 'it': return 'Dove trovo le franchigie bagaglio e le dimensioni delle compagnie?';
          case 'pt': return 'Onde encontro as regras e limites de bagagem das companhias aéreas?';
          case 'ru': return 'Где найти нормы провоза и габариты багажа авиакомпаний?';
          case 'zh': return '在哪里可以查看各航空公司的行李额度与尺寸限制？';
          case 'ja': return '航空会社の受託手荷物許容量やサイズ規定はどこで確認できますか？';
          case 'ko': return '항공사별 수하물 규정 및 크기 제한은 어디서 확인하나요?';
          case 'ar': return 'أين يمكنني العثور على أوزان وأبعاد الأمتعة الخاصة بشركات الطيران؟';
          case 'hi': return 'एयरलाइन सामान के नियम और आकार की सीमाएँ कहाँ मिलेंगी?';
          case 'nl': return 'Waar vind ik de bagageregels en afmetingen van luchtvaartmaatschappijen?';
          case 'el': return 'Πού βρίσκω τα όρια αποσκευών και τις διαστάσεις των αεροπορικών εταιρειών;';
          case 'sv': return 'Var hittar jag flygbolagens bagageregler och måttgränser?';
          case 'pl': return 'Gdzie znajdę limity i wymiary bagażu linii lotniczych?';
          case 'id': return 'Di mana menemukan aturan bagasi dan batas dimensi maskapai penerbangan?';
          case 'th': return 'จะค้นหากฎสัมภาระและขีดจำกัดขนาดของสายการบินได้ที่ไหน?';
          case 'vi': return 'Tìm quy định hành lý và kích thước của các hãng hàng không ở đâu?';
          case 'en':
          default: return 'Where can I find airline baggage allowances and dimensions?';
        }
      case 'twoWaySync':
        switch (clean) {
          case 'tr': return 'Çift yönlü bulut eşleme (Two-Way Sync) ne zaman devreye girer?';
          case 'de': return 'Wann wird die Zwei-Wege-Cloud-Synchronisierung ausgelöst?';
          case 'fr': return 'Quand la synchronisation bidirectionnelle dans le cloud s\'active-t-elle ?';
          case 'es': return '¿Cuándo se activa la sincronización bidireccional en la nube?';
          case 'it': return 'Quando si attiva la sincronizzazione bidirezionale sul cloud?';
          case 'pt': return 'Quando a sincronização bidirecional na nuvem entra em ação?';
          case 'ru': return 'Когда срабатывает двусторонняя синхронизация с облаком?';
          case 'zh': return '双向云端同步何时会自动触发？';
          case 'ja': return '双方向クラウド同期はいつ実行されますか？';
          case 'ko': return '양방향 클라우드 동기화는 언제 실행되나요?';
          case 'ar': return 'متى يتم تفعيل المزامنة السحابية الثنائية الاتجاه؟';
          case 'hi': return 'द्वि-दिशात्मक क्लाउड सिंक कब चालू होता है?';
          case 'nl': return 'Wanneer wordt tweeweg-cloudsynchronisatie geactiveerd?';
          case 'el': return 'Πότε ενεργοποιείται ο αμφίδρομος συγχρονισμός cloud;';
          case 'sv': return 'När utlöses tvåvägs molnsynkronisering?';
          case 'pl': return 'Kiedy uruchamia się dwukierunkowa synchronizacja z chmurą?';
          case 'id': return 'Kapan sinkronisasi dua arah ke cloud aktif?';
          case 'th': return 'การซิงค์ข้อมูลบนคลาวด์แบบสองทางจะทำงานเมื่อใด?';
          case 'vi': return 'Khi nào tính năng đồng bộ hai chiều với đám mây được kích hoạt?';
          case 'en':
          default: return 'When does two-way cloud sync trigger?';
        }
      case 'multiDeviceAccess':
        switch (clean) {
          case 'tr': return 'Aynı hesabı birden fazla cihazda kullanabilir miyim?';
          case 'de': return 'Kann ich dasselbe Konto auf mehreren Geräten verwenden?';
          case 'fr': return 'Puis-je utiliser le même compte sur plusieurs appareils ?';
          case 'es': return '¿Puedo usar la misma cuenta en varios dispositivos?';
          case 'it': return 'Posso usare lo stesso account su più dispositivi?';
          case 'pt': return 'Posso usar a mesma conta em vários dispositivos?';
          case 'ru': return 'Могу ли я использовать один аккаунт на нескольких устройствах?';
          case 'zh': return '我可以在多台设备上登录并使用同一个账户吗？';
          case 'ja': return '同じアカウントを複数の端末で同時に使用できますか？';
          case 'ko': return '동일한 계정을 여러 기기에서 사용할 수 있나요?';
          case 'ar': return 'هل يمكنني استخدام الحساب نفسه على أجهزة متعددة؟';
          case 'hi': return 'क्या मैं एक ही खाते का उपयोग कई उपकरणों पर कर सकता हूँ?';
          case 'nl': return 'Kan ik hetzelfde account op meerdere apparaten gebruiken?';
          case 'el': return 'Μπορώ να χρησιμοποιήσω τον ίδιο λογαριασμό σε πολλές συσκευές;';
          case 'sv': return 'Kan jag använda samma konto på flera enheter?';
          case 'pl': return 'Czy mogę korzystać z tego samego konta na wielu urządzeniach?';
          case 'id': return 'Bisakah saya menggunakan akun yang sama di beberapa perangkat?';
          case 'th': return 'ฉันสามารถใช้บัญชีเดียวกันบนอุปกรณ์หลายเครื่องได้หรือไม่?';
          case 'vi': return 'Tôi có thể sử dụng cùng một tài khoản trên nhiều thiết bị không?';
          case 'en':
          default: return 'Can I use the same account across multiple devices?';
        }
      case 'packBuddyProBenefits':
        switch (clean) {
          case 'tr': return 'PackBuddy Pro aboneliği neleri kapsar?';
          case 'de': return 'Welche Funktionen umfasst das PackBuddy Pro-Abonnement?';
          case 'fr': return 'Quels sont les avantages de l\'abonnement PackBuddy Pro ?';
          case 'es': return '¿Qué funciones incluye la suscripción a PackBuddy Pro?';
          case 'it': return 'Quali funzionalità include l\'abbonamento PackBuddy Pro?';
          case 'pt': return 'Quais recursos estão incluídos na assinatura do PackBuddy Pro?';
          case 'ru': return 'Какие возможности дает подписка PackBuddy Pro?';
          case 'zh': return 'PackBuddy Pro 会员包含哪些专属高级功能？';
          case 'ja': return 'PackBuddy Pro サブスクリプションには何が含まれますか？';
          case 'ko': return 'PackBuddy Pro 멤버십에는 어떤 혜택이 포함되나요?';
          case 'ar': return 'ما هي المزايا المتضمنة في اشتراك PackBuddy Pro؟';
          case 'hi': return 'PackBuddy Pro सदस्यता में क्या सुविधाएं शामिल हैं?';
          case 'nl': return 'Welke functies omvat het PackBuddy Pro-abonnement?';
          case 'el': return 'Τι δυνατότητες περιλαμβάνει η συνδρομή PackBuddy Pro;';
          case 'sv': return 'Vilka funktioner ingår i PackBuddy Pro-prenumerationen?';
          case 'pl': return 'Jakie funkcje obejmuje subskrypcja PackBuddy Pro?';
          case 'id': return 'Fitur apa saja yang termasuk dalam langganan PackBuddy Pro?';
          case 'th': return 'การสมัครสมาชิก PackBuddy Pro ครอบคลุมคุณสมบัติใดบ้าง?';
          case 'vi': return 'Gói đăng ký PackBuddy Pro bao gồm những tính năng nào?';
          case 'en':
          default: return 'What features are included in PackBuddy Pro?';
        }
      case 'restorePurchases':
        switch (clean) {
          case 'tr': return 'Satın aldığım Pro aboneliği yeni cihaza nasıl aktarırım?';
          case 'de': return 'Wie stelle ich mein Pro-Abonnement auf einem neuen Gerät wieder her?';
          case 'fr': return 'Comment restaurer mon abonnement Pro sur un nouvel appareil ?';
          case 'es': return '¿Cómo restauro mi suscripción Pro en un nuevo dispositivo?';
          case 'it': return 'Come ripristino il mio abbonamento Pro su un nuovo dispositivo?';
          case 'pt': return 'Como restaurar minha assinatura Pro em um novo dispositivo?';
          case 'ru': return 'Как восстановить подписку Pro на новом устройстве?';
          case 'zh': return '如何在更换新设备后恢复已购买的 Pro 会员？';
          case 'ja': return '購入した Pro サブスクリプションを新しい端末で復元するには？';
          case 'ko': return '새 기기에서 구매한 Pro 구독을 어떻게 복원하나요?';
          case 'ar': return 'كيف يمكنني استعادة اشتراك Pro على جهاز جديد؟';
          case 'hi': return 'नए डिवाइस पर अपनी Pro सदस्यता कैसे पुनर्स्थापित करें?';
          case 'nl': return 'Hoe herstel ik mijn Pro-abonnement op een nieuw apparaat?';
          case 'el': return 'Πώς επαναφέρω τη συνδρομή Pro σε νέα συσκευή;';
          case 'sv': return 'Hur återställer jag min Pro-prenumeration på en ny enhet?';
          case 'pl': return 'Jak przywrócić subskrypcję Pro na nowym urządzeniu?';
          case 'id': return 'Bagaimana cara memulihkan langganan Pro di perangkat baru?';
          case 'th': return 'จะกู้คืนการสมัครสมาชิก Pro บนอุปกรณ์ใหม่ได้อย่างไร?';
          case 'vi': return 'Làm thế nào để khôi phục gói đăng ký Pro trên thiết bị mới?';
          case 'en':
          default: return 'How do I restore my Pro subscription on a new device?';
        }
      case 'accountDeletion':
        switch (clean) {
          case 'tr': return 'Hesabımı ve verilerimi nasıl silebilirim?';
          case 'de': return 'Wie kann ich mein Konto und meine Daten löschen?';
          case 'fr': return 'Comment supprimer mon compte et mes données ?';
          case 'es': return '¿Cómo puedo solicitar la eliminación de mi cuenta y datos?';
          case 'it': return 'Come posso cancellare il mio account e i miei dati?';
          case 'pt': return 'Como posso excluir minha conta e meus dados?';
          case 'ru': return 'Как удалить мой аккаунт и связанные данные?';
          case 'zh': return '如何申请注销我的账户并删除所有数据？';
          case 'ja': return 'アカウントと関連データを削除するにはどうすればよいですか？';
          case 'ko': return '계정과 모든 데이터를 어떻게 삭제할 수 있나요?';
          case 'ar': return 'كيف يمكنني حذف حسابي وجميع بياناتي؟';
          case 'hi': return 'मैं अपना खाता और डेटा कैसे हटा सकता हूँ?';
          case 'nl': return 'Hoe kan ik mijn account en gegevens verwijderen?';
          case 'el': return 'Πώς μπορώ να διαγράψω τον λογαριασμό και τα δεδομένα μου;';
          case 'sv': return 'Hur tar jag bort mitt konto och alla mina data?';
          case 'pl': return 'Jak usunąć swoje konto i wszystkie powiązane dane?';
          case 'id': return 'Bagaimana cara menghapus akun dan data saya?';
          case 'th': return 'ฉันจะขอลบบัญชีและข้อมูลของฉันได้อย่างไร?';
          case 'vi': return 'Làm cách nào để yêu cầu xóa tài khoản và dữ liệu của tôi?';
          case 'en':
          default: return 'How can I request account and data deletion?';
        }
      case 'dataExportPrivacy':
        switch (clean) {
          case 'tr': return 'Kişisel verilerim ve belgelerim güvende mi?';
          case 'de': return 'Sind meine persönlichen Dokumente und Daten sicher?';
          case 'fr': return 'Mes documents personnels et mes données sont-ils sécurisés ?';
          case 'es': return '¿Están seguros y privados mis documentos y datos personales?';
          case 'it': return 'I miei documenti personali e i miei dati sono al sicuro?';
          case 'pt': return 'Meus documentos pessoais e dados estão seguros e privados?';
          case 'ru': return 'В безопасности ли мои личные документы и данные?';
          case 'zh': return '我的个人证件与隐私数据是否安全？';
          case 'ja': return '個人文書やデータは安全に保護されていますか？';
          case 'ko': return '개인 문서와 데이터는 안전하고 비공개로 보호되나요?';
          case 'ar': return 'هل مستنداتي الشخصية وبياناتي آمنة ومحمية؟';
          case 'hi': return 'क्या मेरे व्यक्तिगत दस्तावेज़ और डेटा सुरक्षित हैं?';
          case 'nl': return 'Zijn mijn persoonlijke documenten en gegevens veilig?';
          case 'el': return 'Είναι τα προσωπικά μου έγγραφα και δεδομένα ασφαλή;';
          case 'sv': return 'Är mina personliga dokument och data säkra och privata?';
          case 'pl': return 'Czy moje prywatne dokumenty i dane są bezpieczne?';
          case 'id': return 'Apakah dokumen dan data pribadi saya aman dan terlindungi?';
          case 'th': return 'เอกสารส่วนตัวและข้อมูลของฉันปลอดภัยและเป็นส่วนตัวหรือไม่?';
          case 'vi': return 'Tài liệu và dữ liệu cá nhân của tôi có an toàn không?';
          case 'en':
          default: return 'Are my personal documents and data safe and private?';
        }
      default:
        return id;
    }
  }

  static String getAnswer(String id, String lang) {
    final clean = _cleanLang(lang);
    switch (id) {
      case 'whatIsPackBuddy':
        switch (clean) {
          case 'tr': return 'PackBuddy, seyahatlerinizi baştan sona planlamanıza yardımcı olan minimalist ve çevrimdışı öncelikli bir seyahat asistanıdır. Seyahat bütçesi yönetimi, bavul hazırlık listesi, şifreli belge kasası ve ziyaret edilen ülkeler haritasını tek bir çatı altında sunar.';
          case 'de': return 'PackBuddy ist ein minimalistischer, offline-fähiger Reisebegleiter, der Ihnen bei der Organisation Ihrer Reisen hilft: Budgetverwaltung, Packlisten, verschlüsselter Dokumentensafe und interaktive Weltreisekarte in einer App.';
          case 'fr': return 'PackBuddy est un compagnon de voyage minimaliste et hors ligne qui vous aide à organiser vos séjours de bout en bout : suivi de budget multidevise, listes de bagages intelligentes, coffre-fort de documents chiffré et carte du monde interactive.';
          case 'es': return 'PackBuddy es un asistente de viajes minimalista y sin conexión que te ayuda a organizar tus viajes: gestión de presupuesto multidivisa, listas de equipaje inteligentes, bóveda segura de documentos y mapa interactivo del mundo.';
          case 'it': return 'PackBuddy è un assistente di viaggio minimalista e offline che ti aiuta a organizzare ogni dettaglio: gestione del budget multivaluta, liste bagagli intelligenti, cassaforte documenti crittografata e mappa del mondo interattiva.';
          case 'pt': return 'O PackBuddy é um assistente de viagens minimalista e offline que ajuda a planejar sua jornada do início ao fim: controle de orçamento multimoeda, listas de bagagem inteligentes, cofre seguro de documentos e mapa-múndi interativo.';
          case 'ru': return 'PackBuddy — это минималистичный офлайн-помощник для путешествий: мультивалютный бюджет, умные списки вещей, зашифрованный сейф для документов и интерактивная карта мира в одном приложении.';
          case 'zh': return 'PackBuddy 是一款简约且支持离线的全能旅行助手：包含多币种预算管理、智能行李打包清单、加密证件保险箱以及互动式世界足迹地图。';
          case 'ja': return 'PackBuddy はオフラインファーストの旅行アシスタントです。複数通貨での予算管理、スマートなパッキングリスト、暗号化された書類保管庫、世界旅行マップを一つにまとめて提供します。';
          case 'ko': return 'PackBuddy는 여행의 시작부터 끝까지 도와주는 미니멀한 오프라인 여행 어시스턴트입니다. 다중 통화 예산 관리, 스마트 패킹 리스트, 암호화된 문서 보관함, 인터랙티브 세계 여행 지도를 한곳에서 제공합니다.';
          case 'ar': return 'PackBuddy هو رفيق سفر بسيط يعمل دون اتصال بالإنترنت لمساعدتك في تنظيم رحلاتك: إدارة الميزانية متعددة العملات، قوائم الأمتعة الذكية، خزنة المستندات المشفرة، وخريطة السفر التفاعلية.';
          case 'hi': return 'PackBuddy एक न्यूनतम और ऑफलाइन-प्रथम यात्रा सहायक है जो आपकी यात्राओं को व्यवस्थित करने में मदद करता है: बहु-मुद्रा बजट, स्मार्ट पैकिंग सूचियां, एन्क्रिप्टेड दस्तावेज़ वॉल्ट और इंटरैक्टिव विश्व मानचित्र।';
          case 'nl': return 'PackBuddy is een minimalistische, offline reisassistent die u helpt bij het organiseren van uw reizen: budgetbeheer in meerdere valuta, slimme inpaklijsten, een versleutelde documentenkluis en een interactieve wereldkaart.';
          case 'el': return 'Το PackBuddy είναι ένας μινιμαλιστικός ταξιδιωτικός βοηθός που λειτουργεί εκτός σύνδεσης: διαχείριση προϋπολογισμού πολλών νομισμάτων, έξυπνες λίστες αποσκευών, κρυπτογραφημένη θυρίδα εγγράφων και διαδραστικός χάρτης.';
          case 'sv': return 'PackBuddy är en minimalistisk reseassistent som fungerar offline och hjälper dig att planera resan: budget med flera valutor, smarta packlistor, krypterat dokumentvalv och interaktiv världskarta.';
          case 'pl': return 'PackBuddy to minimalistyczny asystent podróży offline, który pomaga zaplanować wyjazd od A do Z: budżet wielowalutowy, inteligentne listy pakowania, szyfrowany sejf na dokumenty i interaktywna mapa świata.';
          case 'id': return 'PackBuddy adalah asisten perjalanan minimalis dan offline-first yang membantu merencanakan perjalanan Anda: pelacakan anggaran multi-mata uang, daftar bawaan pintar, brankas dokumen terenkripsi, dan peta dunia interaktif.';
          case 'th': return 'PackBuddy คือผู้ช่วยเดินทางสไตล์มินิมอลที่ทำงานแบบออฟไลน์ได้ ช่วยจัดการงบประมาณหลายสกุลเงิน รายการจัดกระเป๋าอัจฉริยะ ตู้นิรภัยเอกสารที่เข้ารหัส และแผนที่โลกแบบอินเทอร์แอคทีฟ';
          case 'vi': return 'PackBuddy là trợ lý du lịch tối giản hoạt động ngoại tuyến, giúp bạn quản lý ngân sách đa tiền tệ, danh sách đồ đạc thông minh, két an toàn tài liệu mã hóa và bản đồ thế giới tương tác.';
          case 'en':
          default: return 'PackBuddy is a minimalist, offline-first travel companion that helps you organize your journeys from start to finish. It combines multi-currency budget tracking, smart luggage checklists, an encrypted document vault, and an interactive world travel map in one place.';
        }
      case 'offlineOperation':
        switch (clean) {
          case 'tr': return 'Evet! PackBuddy tamamen "Offline-First" (çevrimdışı öncelikli) mimariye sahiptir. Tüm verileriniz yerel SQLite veri tabanında saklanır. İnternetiniz olmadığında da seyahatlerinizi görüntüleyebilir, yeni harcamalar veya bavul maddeleri ekleyebilirsiniz. İnternete bağlandığınızda değişiklikleriniz otomatik olarak bulutla eşitlenir.';
          case 'de': return 'Ja! PackBuddy basiert auf einer Offline-First-Architektur. Alle Reisen, Checklisten und Ausgaben werden lokal in SQLite gespeichert. Sie können die App komplett ohne Internetverbindung nutzen. Sobald Sie wieder online sind, synchronisiert sich alles automatisch mit der Cloud.';
          case 'fr': return 'Oui ! PackBuddy a une architecture entièrement axée sur le hors-ligne. Toutes vos données sont stockées localement dans SQLite. Vous pouvez gérer vos voyages sans aucune connexion internet. Dès que vous vous reconnectez, vos modifications sont automatiquement synchronisées.';
          case 'es': return '¡Sí! PackBuddy tiene una arquitectura orientada a trabajar sin conexión. Todos tus viajes, listas y gastos se guardan localmente en SQLite. Puedes usar la app sin internet; al conectarte, los cambios se sincronizan automáticamente con la nube.';
          case 'it': return 'Sì! PackBuddy è progettato per funzionare offline. Tutti i viaggi, le checklist e le spese sono salvati localmente in SQLite. Puoi gestire tutto senza connessione internet; non appena ti riconnetti, i dati si sincronizzano automaticamente con il cloud.';
          case 'pt': return 'Sim! O PackBuddy possui arquitetura offline-first. Todos os seus dados ficam salvos localmente no SQLite. Você pode gerenciar suas viagens sem nenhuma conexão; ao reconectar, tudo é sincronizado automaticamente com a nuvem.';
          case 'ru': return 'Да! PackBuddy работает по принципу offline-first. Все данные хранятся локально в SQLite. Вы можете использовать приложение без интернета; при подключении изменения автоматически синхронизируются с облаком.';
          case 'zh': return '是的！PackBuddy 采用完全的离线优先架构。所有行程、清单和支出数据均优先保存在本地 SQLite 中。在没有网络时也可以正常使用，重新联网后会自动与云端双向同步。';
          case 'ja': return 'はい！PackBuddy は完全なオフラインファースト設計です。すべてのデータは端末内の SQLite に保存されます。ネット環境がなくても旅行の計画や支出の記録が可能で、再接続時にクラウドと自動同期されます。';
          case 'ko': return '네! PackBuddy는 완전한 오프라인 우선 아키텍처로 구축되었습니다. 모든 데이터는 기기 로컬 SQLite에 안전하게 저장됩니다. 인터넷 연결 없이도 자유롭게 사용 가능하며, 재연결 시 클라우드와 자동 동기화됩니다.';
          case 'ar': return 'نعم! يعمل PackBuddy بهندسة غير متصلة بالإنترنت أولاً. تُحفظ بياناتك محلياً في SQLite. يمكنك إدارة رحلاتك دون إنترنت، وعند الاتصال، تتم مزامنة التغييرات تلقائياً مع السحابة.';
          case 'hi': return 'हाँ! PackBuddy पूरी तरह से ऑफलाइन-फर्स्ट आर्किटेक्चर पर काम करता है। आपका सारा डेटा स्थानीय SQLite में सहेजा जाता है। आप बिना इंटरनेट के ऐप का उपयोग कर सकते हैं; कनेक्ट होने पर यह स्वचालित रूप से क्लाउड से सिंक हो जाता है।';
          case 'nl': return 'Ja! PackBuddy heeft een offline-first architectuur. Al uw reizen, lijsten en uitgaven worden lokaal opgeslagen in SQLite. U kunt de app zonder internet gebruiken; zodra u weer online bent, synchroniseert alles automatisch met de cloud.';
          case 'el': return 'Ναι! Το PackBuddy έχει σχεδιαστεί για λειτουργία εκτός σύνδεσης. Όλα τα δεδομένα αποθηκεύονται τοπικά στο SQLite. Μπορείτε να διαχειρίζεστε τα πάντα χωρίς διαδίκτυο και μόλις συνδεθείτε, συγχρονίζονται αυτόματα με το cloud.';
          case 'sv': return 'Ja! PackBuddy bygger på en offline-först-arkitektur. Alla resor och listor sparas lokalt i SQLite. Du kan använda appen utan internet; så fort du ansluter synkroniseras ändringarna automatiskt med molnet.';
          case 'pl': return 'Tak! PackBuddy działa w architekturze offline-first. Wszystkie Twoje dane są zapisywane lokalnie w SQLite. Możesz swobodnie korzystać z aplikacji bez internetu; po ponownym połączeniu dane automatycznie zsynchronizują się z chmurą.';
          case 'id': return 'Ya! PackBuddy dirancang dengan arsitektur offline-first. Semua data tersimpan secara lokal di SQLite. Anda dapat mengelola perjalanan tanpa internet; saat terhubung kembali, data akan otomatis tersinkronisasi ke cloud.';
          case 'th': return 'ใช่! PackBuddy สร้างขึ้นด้วยสถาปัตยกรรมออฟไลน์เป็นหลัก ข้อมูลทั้งหมดของคุณจะถูกบันทึกไว้ในเครื่องด้วย SQLite คุณสามารถใช้งานได้โดยไม่ต้องมีอินเทอร์เน็ต และเมื่อเชื่อมต่อ ระบบจะซิงค์กับคลาวด์โดยอัตโนมัติ';
          case 'vi': return 'Vâng! PackBuddy có kiến trúc ưu tiên ngoại tuyến. Mọi dữ liệu được lưu cục bộ trong SQLite. Bạn có thể sử dụng bình thường mà không cần mạng; khi có kết nối trở lại, các thay đổi sẽ tự động đồng bộ lên đám mây.';
          case 'en':
          default: return 'Yes! PackBuddy is built with an offline-first architecture. All your trips, checklists, and expenses are saved locally in SQLite first. You can manage your travel without any internet connection. Once you reconnect, changes automatically sync with the cloud.';
        }
      case 'vaultPinForgot':
        switch (clean) {
          case 'tr': return 'Kasa ekranında "PIN\'imi Unuttum" seçeneğine tıklayarak kayıtlı e-posta adresinize sıfırlama talimatı gönderebilirsiniz. Ayrıca Google ile giriş yapan kullanıcılar güvenlik doğrulamasıyla yeni bir PIN belirleyebilir.';
          case 'de': return 'Tippen Sie auf dem Tresor-Bildschirm auf "PIN vergessen", um Anweisungen an Ihre hinterlegte E-Mail-Adresse zu erhalten. Mit Google angemeldete Nutzer können ihre PIN direkt per Identitätsprüfung zurücksetzen.';
          case 'fr': return 'Sur l\'écran du Coffre, appuyez sur "PIN oublié" pour recevoir les instructions de réinitialisation par e-mail. Les utilisateurs connectés avec Google peuvent réinitialiser leur code de manière sécurisée.';
          case 'es': return 'En la pantalla de desbloqueo de la Bóveda, toca "¿Olvidaste el PIN?" para recibir instrucciones en tu correo. Si iniciaste sesión con Google, puedes restablecerlo con confirmación de identidad.';
          case 'it': return 'Nella schermata della Cassaforte, tocca "PIN dimenticato" per avviare il ripristino via e-mail. Gli utenti che hanno effettuato l\'accesso con Google possono reimpostarlo confermando la propria identità.';
          case 'pt': return 'Na tela de desbloqueio do Cofre, toque em "Esqueci o PIN" para receber instruções no seu e-mail cadastrado. Usuários conectados com Google podem redefinir o PIN com segurança via confirmação de identidade.';
          case 'ru': return 'На экране Сейфа нажмите "Забыли PIN-код", чтобы получить инструкции на почту. Пользователи, вошедшие через Google, могут безопасно сбросить PIN-код через подтверждение личности.';
          case 'zh': return '在保险箱解锁界面点击“忘记 PIN 码”，系统将向您的注册邮箱发送重置说明。使用 Google 登录的用户也可以通过安全身份验证直接设置新 PIN 码。';
          case 'ja': return '保管庫のロック画面で「PINコードをお忘れですか？」をタップすると、登録メールアドレスに再設定手順が送信されます。Google ログインをご利用の場合は、本人確認を行って新しいPINを設定できます。';
          case 'ko': return '보관함 잠금 화면에서 "PIN 번호를 잊으셨나요?"를 탭하여 등록된 이메일로 재설정 안내를 받을 수 있습니다. Google 계정으로 로그인한 경우 본인 인증을 통해 새 PIN을 설정할 수 있습니다.';
          case 'ar': return 'في شاشة قفل الخزنة، اضغط على "نسيت رمز PIN" لتلقي تعليمات الاستعادة على بريدك الإلكتروني. يمكن لمستخدمي Google إعادة تعيين الرمز بأمان عبر تأكيد الهوية.';
          case 'hi': return 'वॉल्ट अनलॉक स्क्रीन पर "पिन भूल गए" पर टैप करें। आपके पंजीकृत ईमेल पर रीसेट निर्देश भेजे जाएंगे। Google उपयोगकर्ता पहचान सत्यापन के माध्यम से नया पिन सेट कर सकते हैं।';
          case 'nl': return 'Tik op het Kluisscherm op "PIN vergeten" om instructies op uw e-mailadres te ontvangen. Gebruikers die zijn ingelogd met Google kunnen hun pincode veilig herstellen via identiteitsbevestiging.';
          case 'el': return 'Στην οθόνη της Θυρίδας, πατήστε "Ξέχασα το PIN" για να λάβετε οδηγίες στο email σας. Οι χρήστες που συνδέονται μέσω Google μπορούν να ορίσουν νέο PIN μέσω επαλήθευσης ταυτότητας.';
          case 'sv': return 'Tryck på "Glömt PIN" på Valvskärmen för att få återställningsinstruktioner till din e-post. Användare som är inloggade med Google kan säkert återställa sin PIN-kod via identitetsverifiering.';
          case 'pl': return 'Na ekranie Sejfu dotknij "Nie pamiętam kodu PIN", aby otrzymać instrukcje resetowania na swój adres e-mail. Użytkownicy zalogowani przez Google mogą zresetować kod po weryfikacji tożsamości.';
          case 'id': return 'Di layar Brankas, ketuk "Lupa PIN" untuk mengirim petunjuk pemulihan ke email Anda. Pengguna yang masuk dengan Google dapat menyetel ulang PIN melalui konfirmasi identitas.';
          case 'th': return 'ที่หน้าปลดล็อกตู้นิรภัย ให้แตะ "ลืมรหัส PIN" เพื่อรับคำแนะนำการกู้คืนทางอีเมลที่ลงทะเบียน ผู้ใช้ที่เข้าสู่ระบบด้วย Google สามารถรีเซ็ตรหัส PIN ใหม่ได้อย่างปลอดภัยผ่านการยืนยันตัวตน';
          case 'vi': return 'Trên màn hình Két an toàn, nhấn "Quên mã PIN" để nhận hướng dẫn khôi phục qua email. Người dùng đăng nhập bằng Google có thể đặt lại mã PIN an toàn sau khi xác minh danh tính.';
          case 'en':
          default: return 'On the Vault unlock screen, tap "Forgot PIN" to initiate recovery. If you are signed in via Google or verified email, you can securely reset your PIN through identity confirmation.';
        }
      case 'vaultBiometrics':
        switch (clean) {
          case 'tr': return 'Ayarlar > Güvenlik bölümünden veya Kasa içerisindeki güvenlik butonundan "Biyometrik Kilit" anahtarını açabilirsiniz. Cihazınızın desteklediği Touch ID, Face ID veya parmak izi okuyucusuyla kasayı tek dokunuşla güvenle açabilirsiniz.';
          case 'de': return 'Navigieren Sie zu Einstellungen > Sicherheit oder im Tresor und aktivieren Sie "Biometrische Entsperrung". Sobald aktiviert, können Sie Ihren Tresor nahtlos mit Face ID, Touch ID oder Fingerabdruck öffnen.';
          case 'fr': return 'Allez dans Paramètres > Sécurité ou dans le Coffre, et activez "Déverrouillage biométrique". Vous pourrez ouvrir votre coffre en un geste avec Face ID, Touch ID ou lecteur d\'empreintes.';
          case 'es': return 'Ve a Ajustes > Seguridad o dentro de la Bóveda y activa "Desbloqueo biométrico". Una vez habilitado, podrás abrir tu bóveda cifrada usando Face ID, Touch ID o huella dactilar.';
          case 'it': return 'Vai su Impostazioni > Sicurezza o all\'interno della Cassaforte e attiva lo "Sblocco biometrico". Potrai aprire la tua cassaforte cifrata usando Face ID, Touch ID o impronta digitale.';
          case 'pt': return 'Acesse Configurações > Segurança ou dentro do Cofre e ative o "Desbloqueio Biométrico". Depois de ativado, você poderá abrir seu cofre criptografado com Face ID, Touch ID ou impressão digital.';
          case 'ru': return 'Перейдите в Настройки > Безопасность или внутри Сейфа включите "Биометрическую разблокировку". Вы сможете открывать сейф с помощью Face ID, Touch ID или сканера отпечатков пальцев.';
          case 'zh': return '前往“设置 > 安全”或在保险箱设置中开启“生物识别解锁”。启用后，您可以使用面容识别（Face ID）或指纹一键安全打开加密保险箱。';
          case 'ja': return '「設定 > セキュリティ」または保管庫の設定で「生体認証ロック解除」をオンにしてください。Face ID、Touch ID、または指紋認証を使用して、ワンタップで保管庫を安全に解除できます。';
          case 'ko': return '설정 > 보안 메뉴 또는 보관함 설정에서 "생체 인식 잠금 해제"를 활성화하세요. 설정 후 Face ID, Touch ID 또는 지문 인식을 통해 간편하고 안전하게 보관함을 열 수 있습니다.';
          case 'ar': return 'انتقل إلى الإعدادات > الأمان أو من داخل الخزنة وقم بتفعيل "القفل البيومتري". بمجرد تفعيله، يمكنك فتح الخزنة المشفرة بلمسة واحدة باستخدام Face ID أو بصمة الإصبع.';
          case 'hi': return 'सेटिंग्स > सुरक्षा में जाएं या वॉल्ट के अंदर "बायोमेट्रिक अनलॉक" चालू करें। इसके बाद आप फेस आईडी या फिंगरप्रिंट से अपने वॉल्ट को सुरक्षित रूप से खोल सकते हैं।';
          case 'nl': return 'Ga naar Instellingen > Beveiliging of in de Kluis en schakel "Biometrische ontgrendeling" in. Eenmaal ingeschakeld, opent u uw kluis eenvoudig met Face ID, Touch ID of vingerafdruk.';
          case 'el': return 'Μεταβείτε στις Ρυθμίσεις > Ασφάλεια ή εντός της Θυρίδας και ενεργοποιήστε το "Βιομετρικό ξεκλείδωμα". Μπορείτε να ανοίγετε τη θυρίδα σας με ασφάλεια χρησιμοποιώντας Face ID ή δακτυλικό αποτύπωμα.';
          case 'sv': return 'Gå till Inställningar > Säkerhet eller inne i Valvet och aktivera "Biometrisk upplåsning". Därefter kan du enkelt öppna ditt valv med Face ID, Touch ID eller fingeravtryck.';
          case 'pl': return 'Przejdź do Ustawienia > Bezpieczeństwo lub wewnątrz Sejfu włącz "Odblokowanie biometryczne". Umożliwi to szybkie i bezpieczne otwieranie sejfu za pomocą Face ID, Touch ID lub odcisku palca.';
          case 'id': return 'Buka Pengaturan > Keamanan atau di dalam Brankas dan aktifkan "Buka Kunci Biometrik". Anda dapat membuka brankas dengan mudah menggunakan Face ID, Touch ID, atau sidik jari.';
          case 'th': return 'ไปที่ การตั้งค่า > ความปลอดภัย หรือภายในการตั้งค่าตู้นิรภัย แล้วเปิดใช้งาน "การปลดล็อกด้วยไบโอเมตริก" คุณจะสามารถเปิดตู้นิรภัยได้อย่างง่ายดายด้วย Face ID, Touch ID หรือลายนิ้วมือ';
          case 'vi': return 'Vào Cài đặt > Bảo mật hoặc bên trong Két an toàn và bật "Mở khóa sinh trắc học". Sau khi bật, bạn có thể mở két nhanh chóng và an toàn bằng Face ID, Touch ID hoặc vân tay.';
          case 'en':
          default: return 'Navigate to Settings > Security or inside the Vault settings, and toggle "Biometric Unlock". Once enabled, you can seamlessly open your encrypted vault using Face ID, Touch ID, or fingerprint authentication.';
        }
      case 'collaborativeTrips':
        switch (clean) {
          case 'tr': return 'Bir seyahatin detay sayfasına gidip "Paylaş" butonuna dokunarak benzersiz bir davet kodu (Invite Code) oluşturabilirsiniz. Arkadaşınız bu kodu girdiğinde, seyahat listesini ve harcamaları ortaklaşa canlı olarak düzenleyebilirsiniz.';
          case 'de': return 'Öffnen Sie eine Reise, tippen Sie auf "Teilen" und generieren Sie einen Einladungscode. Wenn Ihre Reisebegleiter diesen Code in PackBuddy eingeben, können Sie Packlisten und Ausgaben gemeinsam in Echtzeit bearbeiten.';
          case 'fr': return 'Ouvrez un voyage, appuyez sur "Partager" et générez un code d\'invitation unique. Lorsque vos compagnons le saisissent dans PackBuddy, vous pouvez collaborer en direct sur les listes et les dépenses.';
          case 'es': return 'Abre cualquier viaje, toca "Compartir" y genera un código de invitación único. Cuando tus compañeros lo ingresen en PackBuddy, podrán colaborar y editar la lista y gastos en tiempo real.';
          case 'it': return 'Apri un viaggio, tocca "Condividi" e genera un codice invito. Quando i tuoi compagni di viaggio inseriscono questo codice in PackBuddy, potrete collaborare in tempo reale su liste e spese.';
          case 'pt': return 'Abra uma viagem, toque em "Compartilhar" e gere um código de convite exclusivo. Quando seus companheiros inserirem esse código no PackBuddy, todos poderão ver e editar a lista e despesas em tempo real.';
          case 'ru': return 'Откройте поездку, нажмите "Поделиться" и создайте код приглашения. Когда попутчик введет этот код в PackBuddy, вы сможете совместно в реальном времени редактировать списки вещей и расходы.';
          case 'zh': return '打开任意行程详情页，点击“分享”按钮即可生成专属邀请码。当您的旅伴在 PackBuddy 中输入该代码后，双方即可实时协同编辑行李清单和旅行支出。';
          case 'ja': return '旅行の詳細画面を開き、「共有」をタップして招待コードを発行します。同行者が PackBuddy でコードを入力すると、持ち物リストや支出をリアルタイムで共同編集できます。';
          case 'ko': return '여행 상세 페이지에서 "공유" 버튼을 눌러 고유 초대 코드를 생성하세요. 동행자가 PackBuddy에 코드를 입력하면 짐 목록과 지출 내역을 실시간으로 함께 관리할 수 있습니다.';
          case 'ar': return 'افتح أي رحلة، واضغط على "مشاركة" لإنشاء رمز دعوة فريد. عندما يدخل رفيق سفرك هذا الرمز في PackBuddy، يمكنكم التعاون في تنظيم قوائم الأمتعة والمصاريف مباشرة.';
          case 'hi': return 'किसी भी यात्रा पर जाएं, "शेयर" पर टैप करें और एक आमंत्रण कोड जनरेट करें। जब आपका साथी इसे PackBuddy में दर्ज करेगा, तो आप रीयल-टाइम में पैकिंग और खर्चों पर मिलकर काम कर सकते हैं।';
          case 'nl': return 'Open een reis, tik op "Delen" en maak een unieke uitnodigingscode aan. Wanneer uw reisgenoot deze code invoert in PackBuddy, kunt u samen in realtime inpaklijsten en uitgaven beheren.';
          case 'el': return 'Ανοίξτε ένα ταξίδι, πατήστε "Κοινοποίηση" και δημιουργήστε έναν κωδικό πρόσκλησης. Οι συνταξιδιώτες σας μπορούν να τον εισαγάγουν και να διαχειρίζεστε μαζί λίστες και έξοδα σε πραγματικό χρόνο.';
          case 'sv': return 'Öppna en resa, tryck på "Dela" och skapa en unik inbjudningskod. När dina reskamrater anger koden i PackBuddy kan ni samarbeta och redigera packlistor och utgifter i realtid.';
          case 'pl': return 'Otwórz wyjazd, dotknij "Udostępnij" i wygeneruj unikalny kod zaproszenia. Gdy towarzysze podróży wpiszą go w PackBuddy, będziecie mogli wspólnie w czasie rzeczywistym edytować listy i wydatki.';
          case 'id': return 'Buka perjalanan apa pun, ketuk "Bagikan" dan buat kode undangan unik. Ketika teman perjalanan memasukkan kode ini di PackBuddy, Anda berdua dapat berkolaborasi secara real-time.';
          case 'th': return 'เปิดการเดินทางใดก็ได้ แตะ "แชร์" และสร้างรหัสเชิญที่ไม่ซ้ำใคร เมื่อเพื่อนร่วมทางป้อนรหัสนี้ใน PackBuddy คุณทั้งสองจะสามารถดูและจัดการรายการสัมภาระและค่าใช้จ่ายร่วมกันได้แบบเรียลไทม์';
          case 'vi': return 'Mở chuyến đi bất kỳ, nhấn "Chia sẻ" và tạo mã mời. Khi bạn đồng hành nhập mã này vào PackBuddy, cả hai có thể cùng nhau quản lý danh sách hành lý và chi tiêu theo thời gian thực.';
          case 'en':
          default: return 'Open any trip, tap the "Share" action, and generate a unique invite code. When your travel companion enters this code in PackBuddy, both of you can view and collaborate on packing lists and expenses in real time.';
        }
      case 'currencyConversion':
        switch (clean) {
          case 'tr': return 'PackBuddy 50\'den fazla dünya para birimini destekler. Her harcama eklediğinizde yerel para birimini seçebilirsiniz; uygulama harcamanızı otomatik olarak seyahatinizin ana para birimine dönüştürür. Döviz kurları internete her bağlandığınızda arka planda güncellenir ve internetsiz ortamda son alınan kurlarla çalışır.';
          case 'de': return 'PackBuddy unterstützt über 50 Währungen. Wählen Sie bei jeder Ausgabe einfach die Landeswährung; die App rechnet sie automatisch in die Basiswährung Ihrer Reise um. Die Wechselkurse werden im Hintergrund aktualisiert und stehen offline bereit.';
          case 'fr': return 'PackBuddy prend en charge plus de 50 devises. Choisissez simplement la devise locale lors de la saisie d\'une dépense ; elle est automatiquement convertie dans la devise de base du voyage selon les taux enregistrés hors ligne.';
          case 'es': return 'PackBuddy admite más de 50 monedas globales. Al registrar un gasto, elige la moneda local y la app lo convertirá automáticamente a la moneda base del viaje con tipos de cambio guardados para uso sin conexión.';
          case 'it': return 'PackBuddy supporta oltre 50 valute mondiali. Quando registri una spesa, scegli la valuta locale; l\'app la convertirà automaticamente nella valuta principale del viaggio usando tassi di cambio memorizzati anche offline.';
          case 'pt': return 'O PackBuddy suporta mais de 50 moedas globais. Ao adicionar uma despesa, basta escolher a moeda local; o aplicativo converte automaticamente para a moeda base da viagem usando taxas atualizadas salvas para uso offline.';
          case 'ru': return 'PackBuddy поддерживает более 50 мировых валют. При добавлении расхода выберите местную валюту, и приложение автоматически пересчитает сумму в базовую валюту поездки по курсам, сохраненным для работы офлайн.';
          case 'zh': return 'PackBuddy 支持全球 50 多种主流货币。记录消费时只需选择消费币种，应用会根据离线缓存的最新汇率，自动将其折算为行程的主基础货币。';
          case 'ja': return 'PackBuddy は50以上の世界通貨に対応しています。支出を追加する際に現地通貨を選択するだけで、旅行の基本通貨に自動換算されます。為替レートはオフラインでも利用可能です。';
          case 'ko': return 'PackBuddy는 50개 이상의 글로벌 통화를 지원합니다. 지출을 추가할 때 현지 통화를 선택하면 앱이 오프라인에 저장된 최신 환율을 사용하여 여행의 기본 통화로 자동 환산해 줍니다.';
          case 'ar': return 'يدعم PackBuddy أكثر من 50 عملة عالمية. عند تسجيل أي مصروف، اختر العملة المحلية وسيقوم التطبيق بتحويلها تلقائياً إلى عملة الرحلة الأساسية باستخدام أسعار صرف مخزنة للاستخدام دون اتصال.';
          case 'hi': return 'PackBuddy 50 से अधिक वैश्विक मुद्राओं का समर्थन करता है। खर्च जोड़ते समय स्थानीय मुद्रा चुनें; ऐप इसे यात्रा की मूल मुद्रा में स्वचालित रूप से बदल देता है।';
          case 'nl': return 'PackBuddy ondersteunt meer dan 50 wereldvaluta\'s. Kies bij een uitgave simpelweg de lokale munteenheid; de app rekent deze automatisch om naar de basisvaluta van de reis via offline opgeslagen wisselkoersen.';
          case 'el': return 'Το PackBuddy υποστηρίζει πάνω από 50 νομίσματα. Επιλέξτε το τοπικό νόμισμα κατά την καταχώριση εξόδου και η εφαρμογή θα το μετατρέψει αυτόματα στο βασικό νόμισμα του ταξιδιού με αποθηκευμένες ισοτιμίες.';
          case 'sv': return 'PackBuddy stöder över 50 globala valutor. Välj bara den lokala valutan när du lägger till en utgift, så omvandlas den automatiskt till resans basvaluta med växelkurser sparade för offlinebruk.';
          case 'pl': return 'PackBuddy obsługuje ponad 50 walut świata. Przy dodawaniu wydatku wybierz walutę transakcji, a aplikacja automatycznie przeliczy ją na walutę bazową wyjazdu w oparciu o kursy zapisane w trybie offline.';
          case 'id': return 'PackBuddy mendukung lebih dari 50 mata uang dunia. Saat mencatat pengeluaran, pilih mata uang lokal; aplikasi akan otomatis mengonversinya ke mata uang utama perjalanan.';
          case 'th': return 'PackBuddy รองรับสกุลเงินทั่วโลกมากกว่า 50 สกุลเงิน เมื่อบันทึกค่าใช้จ่าย ให้เลือกสกุลเงินท้องถิ่น แอปจะแปลงเป็นสกุลเงินหลักของการเดินทางให้โดยอัตโนมัติด้วยอัตราแลกเปลี่ยนที่แคชไว้ใช้งานออฟไลน์';
          case 'vi': return 'PackBuddy hỗ trợ hơn 50 loại tiền tệ trên thế giới. Khi thêm chi tiêu, chỉ cần chọn loại tiền địa phương; ứng dụng sẽ tự động quy đổi về tiền tệ chính của chuyến đi dựa trên tỷ giá lưu ngoại tuyến.';
          case 'en':
          default: return 'PackBuddy supports over 50 global currencies. When recording an expense, simply pick the transaction currency; the app automatically converts it to your trip\'s base currency using live exchange rates cached for offline use.';
        }
      case 'smartTemplates':
        switch (clean) {
          case 'tr': return 'Bavul sekmesinde üst kısımdaki "Şablonlar" butonuna tıklayarak Yaz Tatili, Kış Tatili, İş Gezisi, Kamp, Doğa Yürüyüşü veya Bebekli Seyahat gibi hazır paketleri tek dokunuşla seyahatinize ekleyebilirsiniz.';
          case 'de': return 'Tippen Sie im Gepäck-Tab auf "Vorlagen", um vorgefertigte Packlisten für Sommerurlaub, Skiurlaub, Geschäftsreise, Camping oder Familienreisen mit einem Klick zu importieren.';
          case 'fr': return 'Dans l\'onglet Bagages, appuyez sur "Modèles" pour ajouter en un clic des listes préparées : Vacances d\'été, Ski, Voyage d\'affaires, Camping ou Voyage en famille.';
          case 'es': return 'En la pestaña de Equipaje, toca "Plantillas" para agregar con un toque paquetes listos como Playa de verano, Esquí, Viaje de negocios, Camping o Viaje familiar.';
          case 'it': return 'Nella scheda Valigia, tocca "Modelli" per aggiungere con un tocco pacchetti pronti per Vacanza estiva, Settimana bianca, Viaggio di lavoro, Campeggio o Viaggio in famiglia.';
          case 'pt': return 'Na aba Bagagem, toque no botão "Modelos" para adicionar com um toque listas prontas para Praia no verão, Esqui na neve, Viagem de negócios, Acampamento ou Viagem com bebê.';
          case 'ru': return 'Во вкладке "Багаж" нажмите "Шаблоны", чтобы в один клик добавить готовые списки: Летний отдых, Горные лыжи, Командировка, Кемпинг или Поездка с детьми.';
          case 'zh': return '在行李清单页面顶部点击“智能模板”，即可一键导入海滩度假、冬季滑雪、商务出差、户外露营、背包徒步或亲子出行等精选打包方案。';
          case 'ja': return '荷物タブの上部にある「テンプレート」をタップすると、サマーバケーション、スキー、出張、キャンプ、家族旅行などの厳選されたパッキングリストをワンタップで追加できます。';
          case 'ko': return '체크리스트 탭 상단의 "스마트 템플릿"을 눌러 여름 휴가, 스키 여행, 비즈니스 출장, 캠핑, 가족 여행 등 검증된 짐 목록을 한 번의 터치로 손쉽게 추가하세요.';
          case 'ar': return 'في علامة تبويب الأمتعة، اضغط على "القوالب" لإضافة باقات جاهزة بلمسة واحدة مثل عطلة الصيف، التزلج، رحلة العمل، التخييم، أو السفر مع العائلة.';
          case 'hi': return 'चेकलिस्ट टैब में "टेम्प्लेट" पर टैप करें और ग्रीष्मकालीन अवकाश, स्कीइंग, व्यापार यात्रा, कैंपिंग या पारिवारिक यात्रा के लिए तैयार सूचियां एक टैप में जोड़ें।';
          case 'nl': return 'Tik in het Bagagetabblad op "Templates" om met één tik kant-en-klare lijsten toe te voegen voor strandvakanties, wintersport, zakenreizen, kamperen of gezinsreizen.';
          case 'el': return 'Στην καρτέλα Αποσκευών, πατήστε "Πρότυπα" για να προσθέσετε με ένα άγγιγμα έτοιμες λίστες για καλοκαιρινές διακοπές, σκι, επαγγελματικό ταξίδι ή κάμπινγκ.';
          case 'sv': return 'Under fliken Bagage trycker du på "Mallar" för att med ett tryck lägga till färdiga listor för sommarsemester, skidresa, affärsresa, camping eller familjeresa.';
          case 'pl': return 'W zakładce Bagaż dotknij "Szablony", aby jednym dotknięciem zaimportować gotowe listy na wakacje letnie, narty, wyjazd służbowy, kemping czy podróż z rodziną.';
          case 'id': return 'Di tab Bagasi, ketuk "Template" untuk menambahkan paket siap pakai dengan satu sentuhan seperti Liburan Musim Panas, Ski, Perjalanan Bisnis, atau Berkemah.';
          case 'th': return 'ในแท็บสัมภาระ ให้แตะ "เทมเพลต" เพื่อเพิ่มรายการที่จัดเตรียมไว้แล้วในสัมผัสเดียว เช่น ทริปทะเลฤดูร้อน สกี ทริปธุรกิจ หรือแคมปิ้ง';
          case 'vi': return 'Trong tab Hành lý, nhấn "Mẫu đồ" để thêm ngay các gói chuẩn bị sẵn như Nghỉ mát hè, Trượt tuyết, Công tác, Cắm trại hoặc Du lịch gia đình.';
          case 'en':
          default: return 'In the Checklist tab, tap "Smart Templates" to instantly generate tailored packing lists for Summer Beach, Winter Ski, Business Trip, Camping, Backpacking, or Family Travel.';
        }
      case 'airlineBaggage':
        switch (clean) {
          case 'tr': return 'Bavul sekmesindeki "Havayolu Rehberi" butonuna tıklayarak Türk Hava Yolları, Pegasus, Emirates, Ryanair, Lufthansa gibi 50\'den fazla havayolunun kabin içi, kişisel eşya ve kayıtlı bagaj boyut/ağırlık sınırlarını inceleyebilirsiniz.';
          case 'de': return 'Tippen Sie im Gepäck-Tab auf "Fluggesellschaften-Guide", um Handgepäck, persönliche Gegenstände und Aufgabegepäck-Grenzen von über 50 internationalen Airlines einzusehen.';
          case 'fr': return 'Appuyez sur "Guide des compagnies" dans l\'onglet Bagages pour consulter les dimensions et poids autorisés en cabine et en soute pour plus de 50 compagnies aériennes majeures.';
          case 'es': return 'Toca "Guía de Aerolíneas" en la pestaña de Equipaje para consultar las franquicias, dimensiones y límites de peso de cabina y bodega de más de 50 aerolíneas internacionales.';
          case 'it': return 'Tocca "Guida Compagnie Aeree" nella scheda Valigia per consultare le franchigie, le dimensioni e i limiti di peso per bagaglio a mano e da stiva di oltre 50 compagnie aeree.';
          case 'pt': return 'Toque no botão "Guia de Companhias Aéreas" na aba Bagagem para conferir os limites de peso e dimensões de bagagem de mão, item pessoal e porão de mais de 50 companhias aéreas internacionais.';
          case 'ru': return 'Нажмите кнопку "Авиакомпании" во вкладке "Багаж", чтобы просмотреть нормы провоза ручной клади, личных вещей и зарегистрированного багажа для более чем 50 мировых авиалиний.';
          case 'zh': return '点击行李页面的“航司行李指南”，即可快速查阅包括土耳其航空、阿联酋航空、瑞安航空、汉莎航空等全球 50 多家主要航空公司的手提随身与托运行李规格限制。';
          case 'ja': return '荷物タブの「航空会社ガイド」をタップして、世界50社以上の主要航空会社の機内持ち込み手荷物、身の回り品、受託手荷物の許容重量やサイズ制限を確認できます。';
          case 'ko': return '체크리스트 탭의 "항공사 수하물 가이드"를 탭하여 대한항공, 아시아나, 터키항공, 에미레이트, 루프트한자 등 50개 이상 주요 항공사의 기내 및 위탁 수하물 규격을 확인하세요.';
          case 'ar': return 'اضغط على "دليل شركات الطيران" في علامة تبويب الأمتعة للاطلاع على لوائح وأوزان وأبعاد حقائب المقصورة والأمتعة المسجلة لأكثر من 50 شركة طيران عالمية.';
          case 'hi': return 'चेकलिस्ट टैब में "एयरलाइन गाइड" पर टैप करके 50 से अधिक प्रमुख एयरलाइनों के केबिन, व्यक्तिगत वस्तु और चेक-इन सामान के नियम और आकार सीमाएं देखें।';
          case 'nl': return 'Tik op "Luchtvaartgids" in het Bagagetabblad om afmetingen en gewichtslimieten voor handbagage en ruimbagage van meer dan 50 internationale maatschappijen te bekijken.';
          case 'el': return 'Πατήστε "Οδηγός Αεροπορικών" στην καρτέλα Αποσκευών για να δείτε τα όρια διαστάσεων και βάρους χειραποσκευών και αποσκευών σε περισσότερες από 50 αεροπορικές εταιρείες.';
          case 'sv': return 'Tryck på "Flygbolagsguide" under fliken Bagage för att se vikt- och storleksgränser för handbagage och incheckat bagage hos över 50 internationella flygbolag.';
          case 'pl': return 'Dotknij "Przewodnik po liniach lotniczych" w zakładce Bagaż, aby sprawdzić limity wagowe i wymiary bagażu podręcznego oraz rejestrowanego dla ponad 50 linii lotniczych.';
          case 'id': return 'Ketuk "Panduan Maskapai" di tab Bagasi untuk melihat batas ukuran dan berat bagasi kabin serta bagasi terdaftar untuk lebih dari 50 maskapai penerbangan internasional.';
          case 'th': return 'แตะ "คู่มือสายการบิน" ในแท็บสัมภาระเพื่อดูข้อกำหนด ขนาด และน้ำหนักของสัมภาระถือขึ้นเครื่องและโหลดใต้เครื่องสำหรับสายการบินหลักมากกว่า 50 แห่งทั่วโลก';
          case 'vi': return 'Nhấn vào "Cẩm nang hàng không" trong tab Hành lý để xem quy định kích thước và trọng lượng hành lý xách tay và ký gửi của hơn 50 hãng hàng không quốc tế.';
          case 'en':
          default: return 'Tap "Airline Baggage Guide" in the Checklist tab to browse carry-on, personal item, and checked baggage size/weight regulations for over 50 major international airlines.';
        }
      case 'twoWaySync':
        switch (clean) {
          case 'tr': return 'Uygulama açıldığında, internet bağlantısı geri geldiğinde veya bir veri eklediğinizde sistem otomatik olarak çift yönlü diferansiyel eşleme gerçekleştirir. Birden fazla cihazdaki değişiklikler zaman damgasına göre (Last-Write-Wins) çakışmasız olarak birleştirilir.';
          case 'de': return 'Die Synchronisation wird automatisch ausgelöst, wenn die App geöffnet wird, eine Verbindung besteht oder Daten geändert werden. Änderungen werden anhand von Zeitstempeln verlustfrei zusammengeführt.';
          case 'fr': return 'La synchronisation se déclenche automatiquement à l\'ouverture de l\'application, au rétablissement de la connexion ou à la modification d\'une donnée, fusionnant les changements sans perte.';
          case 'es': return 'La sincronización se activa automáticamente al abrir la app, recuperar conexión o modificar registros. Los cambios entre dispositivos se concilian sin conflictos según marcas de tiempo.';
          case 'it': return 'La sincronizzazione si avvia automaticamente all\'apertura dell\'app, al ripristino della connessione o alla modifica di un dato, unendo i dati senza conflitti in base ai timestamp.';
          case 'pt': return 'A sincronização ocorre automaticamente ao abrir o aplicativo, restabelecer a conexão ou modificar registros. As alterações entre múltiplos dispositivos são mescladas perfeitamente sem conflitos.';
          case 'ru': return 'Синхронизация запускается автоматически при запуске приложения, появлении сети или изменении данных. Изменения бесконфликтно объединяются на основе временных меток.';
          case 'zh': return '当应用启动、网络恢复连接或新增/修改数据时，系统将自动执行双向增量同步。多台设备上的数据将基于精准时间戳无缝合并，确保数据零丢失。';
          case 'ja': return 'アプリ起動時、ネットワーク復帰時、またはデータ追加時に双方向同期が自動的に実行されます。タイムスタンプに基づいて競合なく最新データが統合されます。';
          case 'ko': return '앱이 실행되거나 인터넷이 다시 연결될 때, 또는 데이터가 변경될 때 양방향 차등 동기화가 자동 실행됩니다. 타임스탬프를 기준으로 충돌 없이 안전하게 병합됩니다.';
          case 'ar': return 'تبدأ المزامنة تلقائياً عند فتح التطبيق، أو استعادة الاتصال بالإنترنت، أو تعديل أي سجل، حيث يتم دمج التغييرات بسلاسة دون تعارض.';
          case 'hi': return 'ऐप खुलने, इंटरनेट कनेक्शन वापस आने या डेटा बदलने पर सिस्टम स्वचालित रूप से द्वि-दिशात्मक सिंक करता है।';
          case 'nl': return 'Synchronisatie start automatisch bij het openen van de app, herstel van de verbinding of gegevenswijziging. Wijzigingen worden conflictloos samengevoegd op basis van tijdstempels.';
          case 'el': return 'Ο συγχρονισμός ενεργοποιείται αυτόματα όταν ανοίγει η εφαρμογή, επανέρχεται η σύνδεση ή τροποποιούνται δεδομένα, συνδυάζοντας τις αλλαγές χωρίς συγκρούσεις.';
          case 'sv': return 'Synkroniseringen utlöses automatiskt när appen öppnas, anslutningen återställs eller data ändras, och ändringar slås ihop sömlöst baserat på tidsstämplar.';
          case 'pl': return 'Synchronizacja uruchamia się automatycznie po otwarciu aplikacji, przywróceniu połączenia lub zmianie danych. Zmiany są bezkonfliktowo scalane w oparciu o znaczniki czasu.';
          case 'id': return 'Sinkronisasi berjalan otomatis saat aplikasi dibuka, koneksi pulih, atau data diubah. Perubahan digabungkan secara mulus tanpa konflik berdasarkan stempel waktu.';
          case 'th': return 'การซิงค์จะทำงานโดยอัตโนมัติเมื่อเปิดแอป มีการเชื่อมต่ออินเทอร์เน็ตอีกครั้ง หรือมีการแก้ไขข้อมูล โดยระบบจะรวมข้อมูลที่เปลี่ยนแปลงเข้าด้วยกันอย่างราบรื่น';
          case 'vi': return 'Đồng bộ tự động kích hoạt khi mở ứng dụng, khi có mạng trở lại hoặc khi có thay đổi dữ liệu. Các cập nhật được hợp nhất mượt mà dựa trên mốc thời gian.';
          case 'en':
          default: return 'Sync triggers automatically whenever the app opens, connectivity is restored, or a record is modified. Two-way delta synchronization reconciles local and remote changes based on timestamps without data loss.';
        }
      case 'multiDeviceAccess':
        switch (clean) {
          case 'tr': return 'Evet! Aynı Google veya e-posta hesabınızla hem telefonunuzda hem de tabletinizde giriş yapabilirsiniz. Tüm seyahatleriniz, belgeleriniz ve bavul listeleriniz otomatik olarak senkronize kalır.';
          case 'de': return 'Ja! Melden Sie sich mit demselben Google- oder E-Mail-Konto auf Smartphone und Tablet an; alle Reisen, Dokumente und Packlisten bleiben automatisch synchronisiert.';
          case 'fr': return 'Oui ! Connectez-vous avec le même compte Google ou e-mail sur votre téléphone et votre tablette ; vos voyages, documents et listes restent synchronisés.';
          case 'es': return '¡Sí! Inicia sesión con la misma cuenta de Google o correo en tu teléfono y tableta; todos tus viajes, documentos y listas se mantendrán sincronizados.';
          case 'it': return 'Sì! Accedi con lo stesso account Google o e-mail su smartphone e tablet; tutti i tuoi viaggi, documenti e liste rimarranno perfettamente sincronizzati.';
          case 'pt': return 'Sim! Faça login com a mesma conta do Google ou e-mail no seu smartphone e tablet; todas as suas viagens, documentos seguros e listas de bagagem permanecerão sincronizados.';
          case 'ru': return 'Да! Войдите под одним аккаунтом Google или e-mail на смартфоне и планшете; все ваши поездки, документы и списки будут синхронизированы.';
          case 'zh': return '是的！您可以在手机和平板电脑上使用同一个 Google 或邮箱账户登录。您的所有行程、保险箱证件和行李清单将自动保持多端无缝同步。';
          case 'ja': return 'はい！スマートフォンやタブレットで同じ Google またはメールアカウントでログインすれば、旅行計画、保管庫の書類、持ち物リストがすべて自動で同期されます。';
          case 'ko': return '네! 스마트폰과 태블릿에서 동일한 Google 또는 이메일 계정으로 로그인할 수 있습니다. 모든 여행 일정, 보관함 문서, 짐 목록이 자동으로 완벽하게 동기화됩니다.';
          case 'ar': return 'نعم! سجل الدخول بنفس حساب Google أو البريد الإلكتروني على هاتفك وجهازك اللوحي؛ ستبقى جميع رحلاتك ومستنداتك وقوائمك متزامنة تلقائياً.';
          case 'hi': return 'हाँ! आप अपने फोन और टैबलेट पर एक ही Google या ईमेल खाते से साइन इन कर सकते हैं; आपकी सभी यात्राएं, दस्तावेज़ और सूचियां सिंक रहेंगी।';
          case 'nl': return 'Ja! Log in met hetzelfde Google- of e-mailaccount op uw telefoon en tablet; al uw reizen, documenten en paklijsten blijven automatisch synchroon.';
          case 'el': return 'Ναι! Συνδεθείτε με τον ίδιο λογαριασμό Google ή email στο τηλέφωνο και το tablet σας. Όλα τα ταξίδια, τα έγγραφα και οι λίστες σας παραμένουν συγχρονισμένα.';
          case 'sv': return 'Ja! Logga in med samma Google- eller e-postkonto på telefonen och surfplattan; alla resor, dokument och packlistor hålls automatiskt synkroniserade.';
          case 'pl': return 'Tak! Zaloguj się tym samym kontem Google lub e-mail na telefonie i tablecie; wszystkie Twoje wyjazdy, dokumenty i listy pakowania będą zsynchronizowane.';
          case 'id': return 'Ya! Masuk dengan akun Google atau email yang sama di ponsel dan tablet; semua perjalanan, dokumen, dan daftar bawaan Anda akan tetap tersinkronisasi.';
          case 'th': return 'ใช่! คุณสามารถลงชื่อเข้าใช้ด้วยบัญชี Google หรืออีเมลเดียวกันทั้งบนโทรศัพท์และแท็บเล็ต ทริป เอกสาร และรายการสัมภาระทั้งหมดจะซิงค์กันโดยอัตโนมัติ';
          case 'vi': return 'Vâng! Đăng nhập bằng cùng một tài khoản Google hoặc email trên cả điện thoại và máy tính bảng; mọi chuyến đi, tài liệu và danh sách hành lý sẽ luôn đồng bộ.';
          case 'en':
          default: return 'Yes! Sign in with your registered account on your phone and tablet; your trips, safe documents, and baggage items will seamlessly stay synchronized across all your devices.';
        }
      case 'packBuddyProBenefits':
        switch (clean) {
          case 'tr': return 'PackBuddy Pro; sınırsız seyahat oluşturma, bulut belge kasasında yüksek depolama alanı, ortak seyahat işbirliği, gelişmiş bütçe grafikleri ve havaalanı bagaj hakları rehberinin tamamına sınırsız erişim sağlar.';
          case 'de': return 'PackBuddy Pro bietet: unbegrenzte Reisen, erweiterten Speicher für den Dokumentensafe, Reisekollaboration, erweiterte Budgetanalysen und vollen Zugriff auf den Fluggesellschaften-Gepäckguide.';
          case 'fr': return 'PackBuddy Pro débloque les voyages illimités, un stockage étendu dans le Coffre-fort cloud, la collaboration de voyage, les analyses de budget avancées et l\'accès complet au guide des bagages.';
          case 'es': return 'PackBuddy Pro incluye: viajes ilimitados, gran almacenamiento en la bóveda de la nube, viajes colaborativos compartidos, análisis avanzados de presupuesto y acceso completo a la guía de equipaje de aerolíneas.';
          case 'it': return 'PackBuddy Pro offre: viaggi illimitati, maggiore spazio per la cassaforte cloud, collaborazione nei viaggi, analisi avanzate del budget e accesso completo alla guida bagagli delle compagnie aeree.';
          case 'pt': return 'O PackBuddy Pro oferece: viagens ilimitadas, armazenamento ampliado no cofre em nuvem, colaboração em viagens compartilhadas, gráficos avançados de análise de orçamento e acesso total ao guia de franquias de bagagem aérea.';
          case 'ru': return 'PackBuddy Pro открывает: неограниченное число поездок, расширенное облачное хранилище сейфа, совместное планирование, продвинутую аналитику бюджета и полный доступ к нормам багажа авиакомпаний.';
          case 'zh': return 'PackBuddy Pro 会员享有：无限制创建旅行行程、大容量云端证件保险箱、多人实时协同旅行、深度财务与支出分析图表，以及全球 50 多家航司行李限额完整数据库。';
          case 'ja': return 'PackBuddy Pro では、旅行の無制限作成、大容量クラウド書類保管庫、同行者との共同編集、高度な予算分析チャート、航空会社の手荷物規定ガイドへの完全アクセスが提供されます。';
          case 'ko': return 'PackBuddy Pro는 무제한 여행 생성, 고용량 클라우드 문서 보관함, 동행자와의 실시간 협업, 고급 예산 분석 차트 및 50개 이상 항공사 수하물 규정 전체 조회를 제공합니다.';
          case 'ar': return 'يوفر PackBuddy Pro: إنشاء رحلات غير محدودة، مساحة تخزين سحابية موسعة للخزنة، التعاون في الرحلات، تحليلات الميزانية المتقدمة، والوصول الكامل لدليل أمتعة شركات الطيران.';
          case 'hi': return 'PackBuddy Pro असीमित यात्राएं, उच्च-क्षमता क्लाउड वॉल्ट स्टोरेज, सहयोगी यात्राएं, उन्नत बजट एनालिटिक्स और एयरलाइन बैगेज गाइड तक पूरी पहुंच प्रदान करता है।';
          case 'nl': return 'PackBuddy Pro biedt: onbeperkt reizen aanmaken, ruime cloudopslag voor de kluis, samenwerken aan reizen, geavanceerde budgetgrafieken en volledige toegang tot de bagagegids.';
          case 'el': return 'Το PackBuddy Pro προσφέρει: απεριόριστα ταξίδια, υψηλό αποθηκευτικό χώρο στη θυρίδα cloud, κοινή χρήση ταξιδιών, προηγμένα γραφήματα προϋπολογισμού και πλήρη πρόσβαση στον οδηγό αποσκευών.';
          case 'sv': return 'PackBuddy Pro ger: obegränsat med resor, utökat molnlagringsutrymme för valvet, resesamarbeten, avancerade budgetgrafer och full tillgång till flygbolagens bagageguide.';
          case 'pl': return 'PackBuddy Pro zapewnia: nielimitowane wyjazdy, powiększoną przestrzeń w chmurze na dokumenty, współpracę w podróży, zaawansowane wykresy budżetowe i pełny dostęp do bazy limitów bagażu linii lotniczych.';
          case 'id': return 'PackBuddy Pro membuka: perjalanan tanpa batas, penyimpanan cloud berkapasitas besar untuk brankas, kolaborasi perjalanan, analitik anggaran tingkat lanjut, dan akses penuh ke panduan bagasi maskapai.';
          case 'th': return 'PackBuddy Pro มอบสิทธิ์: สร้างทริปได้ไม่จำกัด พื้นที่เก็บข้อมูลบนคลาวด์ความจุสูงสำหรับตู้นิรภัย การแชร์ทริปเพื่อทำงานร่วมกัน แผนภูมิวิเคราะห์งบประมาณขั้นสูง และการเข้าถึงคู่มือสัมภาระสายการบินอย่างเต็มรูปแบบ';
          case 'vi': return 'PackBuddy Pro mang lại: tạo chuyến đi không giới hạn, dung lượng lưu trữ két an toàn đám mây lớn, cộng tác chuyến đi, biểu đồ phân tích ngân sách chuyên sâu và quyền truy cập đầy đủ hướng dẫn hành lý hàng không.';
          case 'en':
          default: return 'PackBuddy Pro unlocks unlimited trips, high-capacity cloud document storage, collaborative shared lists, advanced budget analytics, and full access to airline baggage specifications.';
        }
      case 'restorePurchases':
        switch (clean) {
          case 'tr': return 'Ayarlar > PackBuddy Pro bölümünde yer alan "Satın Alımları Geri Yükle" seçeneğine tıklayarak mevcut Google Play Store veya Apple App Store aboneliğinizi yeni cihazınıza anında aktarabilirsiniz.';
          case 'de': return 'Öffnen Sie Einstellungen > PackBuddy Pro und tippen Sie auf "Käufe wiederherstellen", um Ihr bestehendes Google Play- oder Apple App Store-Abonnement sofort auf Ihrem neuen Gerät zu aktivieren.';
          case 'fr': return 'Allez dans Paramètres > PackBuddy Pro et appuyez sur "Restaurer les achats" pour réactiver instantanément votre abonnement Google Play ou App Store sur votre nouvel appareil.';
          case 'es': return 'Abre Ajustes > PackBuddy Pro y toca "Restaurar compras" para reactivar de inmediato tu suscripción de Google Play Store o Apple App Store en tu nuevo dispositivo.';
          case 'it': return 'Vai su Impostazioni > PackBuddy Pro e tocca "Ripristina acquisti" per riattivare istantaneamente il tuo abbonamento Google Play o Apple App Store sul nuovo dispositivo.';
          case 'pt': return 'Abra Configurações > PackBuddy Pro e toque em "Restaurar Compras" para transferir e reativar imediatamente sua assinatura da Google Play Store ou App Store no novo dispositivo.';
          case 'ru': return 'Откройте Настройки > PackBuddy Pro и нажмите "Восстановить покупки", чтобы мгновенно перенести подписку из Google Play Store или Apple App Store на новое устройство.';
          case 'zh': return '前往“设置 > PackBuddy Pro”，点击“恢复购买”按钮，即可将您在 Google Play 商店或 Apple App Store 中已购买的有效会员订阅立即同步恢复至当前新设备。';
          case 'ja': return '「設定 > PackBuddy Pro」を開き、「購入を復元」をタップすると、Google Play または Apple App Store の有効なサブスクリプションが新しい端末に即座に復元されます。';
          case 'ko': return '설정 > PackBuddy Pro 메뉴에서 "구매 항목 복원"을 탭하면 Google Play 스토어 또는 Apple App Store의 활성 구독이 새 기기에 즉시 복원됩니다.';
          case 'ar': return 'افتح الإعدادات > PackBuddy Pro واضغط على "استعادة المشتريات" لإعادة تفعيل اشتراكك الحالي من متجر Google Play أو Apple App Store على جهازك الجديد فوراً.';
          case 'hi': return 'सेटिंग्स > PackBuddy Pro खोलें और "खरीदारी पुनर्स्थापित करें" पर टैप करें। आपका सक्रिय Google Play या Apple सदस्यता तुरंत सक्रिय हो जाएगी।';
          case 'nl': return 'Ga naar Instellingen > PackBuddy Pro en tik op "Aankopen herstellen" om uw actieve abonnement via Google Play of de App Store direct over te zetten naar uw nieuwe apparaat.';
          case 'el': return 'Μεταβείτε στις Ρυθμίσεις > PackBuddy Pro και πατήστε "Επαναφορά αγορών" για να ενεργοποιήσετε άμεσα την υπάρχουσα συνδρομή σας από το Google Play ή το App Store στη νέα συσκευή.';
          case 'sv': return 'Gå till Inställningar > PackBuddy Pro och tryck på "Återställ köp" för att omedelbart återaktivera din aktiva prenumeration från Google Play eller App Store på din nya enhet.';
          case 'pl': return 'Przejdź do Ustawienia > PackBuddy Pro i dotknij "Przywróć zakupy", aby natychmiast przenieść aktywną subskrypcję z Google Play lub App Store na nowe urządzenie.';
          case 'id': return 'Buka Pengaturan > PackBuddy Pro dan ketuk "Pulihkan Pembelian" untuk segera mengaktifkan kembali langganan Google Play Store atau Apple App Store di perangkat baru Anda.';
          case 'th': return 'เปิด การตั้งค่า > PackBuddy Pro แล้วแตะ "กู้คืนการซื้อ" การสมัครสมาชิก Google Play Store หรือ Apple App Store ที่ใช้งานอยู่จะเปิดใช้งานบนอุปกรณ์ปัจจุบันของคุณทันที';
          case 'vi': return 'Vào Cài đặt > PackBuddy Pro và nhấn "Khôi phục gói mua" để kích hoạt lại ngay gói đăng ký Google Play hoặc Apple App Store trên thiết bị mới.';
          case 'en':
          default: return 'Open Settings > PackBuddy Pro and tap "Restore Purchases". Your active subscription linked to your Google Play or Apple account will immediately reactivate on your current device.';
        }
      case 'accountDeletion':
        switch (clean) {
          case 'tr': return 'Ayarlar > Güvenlik & Hesap bölümünün en altında yer alan "Hesabımı Sil" seçeneğini kullanabilirsiniz. Hesabınız 15 günlük yasal cayma süresiyle güvenli bir şekilde silinmek üzere planlanır ve tüm bulut verileriniz temizlenir.';
          case 'de': return 'Wählen Sie unter Einstellungen > Sicherheit & Konto ganz unten "Konto löschen". Ihr Konto wird mit einer 15-tägigen Sicherheitsfrist zur dauerhaften Löschung aller Daten eingeplant.';
          case 'fr': return 'Allez dans Paramètres > Sécurité & Compte et sélectionnez "Supprimer le compte". Votre compte est placé dans un délai de grâce de 15 jours avant la suppression définitive de toutes vos données.';
          case 'es': return 'Ve a Ajustes > Seguridad y Cuenta y selecciona "Eliminar cuenta". Tu cuenta entrará en un período de gracia de 15 días tras el cual se borrarán todos tus datos permanentemente.';
          case 'it': return 'Vai su Impostazioni > Sicurezza e Account e seleziona "Elimina account". Il tuo account entrerà in un periodo di grazia di 15 giorni prima della cancellazione permanente di tutti i dati.';
          case 'pt': return 'Acesse Configurações > Segurança & Conta e selecione "Excluir Conta". Sua conta entrará em um período de carência de 15 dias, após o qual todos os dados locais e na nuvem serão excluídos permanentemente.';
          case 'ru': return 'В меню Настройки > Безопасность и аккаунт выберите "Удалить аккаунт". Аккаунт перейдет в 15-дневный период ожидания, после чего все облачные и локальные данные будут навсегда удалены.';
          case 'zh': return '前往“设置 > 账户与安全”，滑动至底部选择“注销账户”。您的账户将进入 15 天安全冷静期，期满后所有云端及本地个人数据将被永久彻底清除。';
          case 'ja': return '「設定 > セキュリティとアカウント」の最下部にある「アカウントを削除」を選択してください。15日間の猶予期間が設けられた後、すべてのクラウドおよびローカルデータが完全に削除されます。';
          case 'ko': return '설정 > 보안 및 계정 메뉴 하단의 "계정 삭제"를 선택하세요. 15일간의 안전 유예 기간이 주어지며, 이후 모든 클라우드 및 로컬 데이터가 영구적으로 완전 파기됩니다.';
          case 'ar': return 'انتقل إلى الإعدادات > الأمان والحساب واختر "حذف الحساب". يدخل حسابك في فترة سماح مدتها 15 يوماً، يتم بعدها مسح جميع سجلاتك السحابية والمحلية نهائياً.';
          case 'hi': return 'सेटिंग्स > सुरक्षा और खाता में जाएं और "खाता हटाएं" चुनें। आपका खाता 15 दिनों की सुरक्षा अवधि में रखा जाएगा, जिसके बाद सभी डेटा स्थायी रूप से मिटा दिया जाएगा।';
          case 'nl': return 'Ga naar Instellingen > Beveiliging & Account en selecteer "Account verwijderen". Uw account krijgt een bedenktijd van 15 dagen, waarna alle gegevens definitief worden gewist.';
          case 'el': return 'Μεταβείτε στις Ρυθμίσεις > Ασφάλεια & Λογαριασμός και επιλέξτε "Διαγραφή λογαριασμού". Ο λογαριασμός τίθεται σε περίοδο χάριτος 15 ημερών, μετά την οποία όλα τα δεδομένα διαγράφονται οριστικά.';
          case 'sv': return 'Gå till Inställningar > Säkerhet & Konto och välj "Radera konto". Kontot placeras i en 15-dagars säkerhetsperiod, varefter alla moln- och lokaldata raderas permanent.';
          case 'pl': return 'Przejdź do Ustawienia > Bezpieczeństwo i konto i wybierz "Usuń konto". Konto zostanie objęte 15-dniowym okresem karencji, po którym wszystkie dane zostaną bezpowrotnie usunięte.';
          case 'id': return 'Buka Pengaturan > Keamanan & Akun dan pilih "Hapus Akun". Akun Anda akan memasuki masa tenggang 15 hari sebelum semua data dihapus secara permanen.';
          case 'th': return 'ไปที่ การตั้งค่า > ความปลอดภัยและบัญชี แล้วเลือก "ลบบัญชี" บัญชีของคุณจะมีระยะเวลาผ่อนผันความปลอดภัย 15 วัน หลังจากนั้นบันทึกทั้งหมดบนคลาวด์และในเครื่องจะถูกลบออกอย่างถาวร';
          case 'vi': return 'Vào Cài đặt > Bảo mật & Tài khoản và chọn "Xóa tài khoản". Tài khoản sẽ có thời gian chờ an toàn 15 ngày, sau đó toàn bộ dữ liệu đám mây và cục bộ sẽ bị xóa vĩnh viễn.';
          case 'en':
          default: return 'Go to Settings > Security & Account and select "Delete Account". Your account is placed in a 15-day safety grace period, after which all personal cloud and local records are permanently wiped.';
        }
      case 'dataExportPrivacy':
        switch (clean) {
          case 'tr': return 'Kişisel kasa belgeleriniz yerel ortamda AES şifrelemesiyle ve Firebase üzerinde kullanıcı bazlı katı güvenlik kurallarıyla korunmaktadır. Verileriniz asla üçüncü taraflarla paylaşılmaz veya reklam amaçlı kullanılmaz.';
          case 'de': return 'Ihre Tresor-Dokumente werden lokal mit AES-Verschlüsselung und über strenge Firestore-Sicherheitsregeln geschützt. Ihre privaten Daten werden niemals an Dritte verkauft oder für Werbung genutzt.';
          case 'fr': return 'Vos documents du coffre sont chiffrés localement en AES et protégés par des règles de sécurité Firestore strictes. Vos données ne sont jamais vendues ni partagées avec des tiers.';
          case 'es': return 'Tus documentos de la bóveda están cifrados localmente con AES y protegidos por estrictas reglas de base de datos en Firestore. Tus datos privados nunca se venden ni se comparten.';
          case 'it': return 'I tuoi documenti della cassaforte sono crittografati localmente con AES e isolati con rigide regole di sicurezza su Firestore. I tuoi dati personali non vengono mai venduti né condivisi.';
          case 'pt': return 'Seus documentos do cofre são criptografados localmente com segurança AES e isolados por regras estritas do banco de dados Firestore. Seus dados privados nunca são vendidos ou compartilhados com terceiros.';
          case 'ru': return 'Документы в сейфе шифруются локально с помощью AES и защищены строгими правилами Firestore. Ваши данные никогда не передаются и не продаются третьим лицам.';
          case 'zh': return '您的保险箱证件在本地采用高强度 AES 加密算法，并在 Firebase 云端通过用户隔离规则严格防护。您的个人隐私数据绝不会被出售、共享或用于任何商业广告。';
          case 'ja': return '保管庫の文書は端末内でAES暗号化され、厳格な Firestore セキュリティルールによって保護されています。個人データが第三者に販売されたり、広告目的で使用されたりすることは一切ありません。';
          case 'ko': return '보관함 문서는 AES 암호화로 기기 내에서 안전하게 보호되며, 엄격한 Firestore 보안 규칙으로 격리됩니다. 귀하의 개인 데이터는 제3자에게 판매되거나 광고 목적으로 사용되지 않습니다.';
          case 'ar': return 'مستنداتك مشفرة محلياً بواسطة AES ومحمية بقواعد بيانات Firestore الصارمة لكل مستخدم. بياناتك الخاصة لا تُباع ولا تُشارك أبداً مع أي طرف ثالث.';
          case 'hi': return 'आपके वॉल्ट दस्तावेज़ AES एन्क्रिप्शन द्वारा स्थानीय रूप से सुरक्षित हैं और Firestore नियमों द्वारा सुरक्षित हैं। आपका डेटा कभी किसी तीसरे पक्ष को नहीं बेचा जाता है।';
          case 'nl': return 'Uw kluisdocumenten zijn lokaal versleuteld met AES en beschermd door strikte Firestore-beveiligingsregels. Uw privégegevens worden nooit verkocht of gedeeld met derden.';
          case 'el': return 'Τα έγγραφά σας είναι κρυπτογραφημένα τοπικά με AES και προστατεύονται από αυστηρούς κανόνες Firestore. Τα προσωπικά σας δεδομένα δεν πωλούνται ούτε κοινοποιούνται ποτέ.';
          case 'sv': return 'Dina valvdokument är krypterade lokalt med AES och skyddade med strikta säkerhetsregler i Firestore. Dina privata data säljs eller delas aldrig med tredje part.';
          case 'pl': return 'Twoje dokumenty w sejfie są szyfrowane lokalnie za pomocą AES i chronione surowymi regułami bazy Firestore. Twoje dane nie są nigdy sprzedawane ani udostępniane podmiotom trzecim.';
          case 'id': return 'Dokumen brankas Anda dienkripsi secara lokal dengan AES dan diisolasi melalui aturan Firestore yang ketat. Data pribadi Anda tidak pernah dijual atau dibagikan ke pihak ketiga.';
          case 'th': return 'เอกสารในตู้นิรภัยของคุณได้รับการเข้ารหัสภายในเครื่องด้วย AES และแยกการเข้าถึงผ่านกฎฐานข้อมูล Firestore ที่เข้มงวด ข้อมูลส่วนตัวของคุณจะไม่ถูกขายหรือแชร์กับบุคคลที่สามอย่างแน่นอน';
          case 'vi': return 'Tài liệu trong két an toàn được mã hóa cục bộ bằng AES và bảo vệ theo quy tắc bảo mật nghiêm ngặt của Firestore. Dữ liệu riêng tư của bạn không bao giờ bị bán hay chia sẻ cho bên thứ ba.';
          case 'en':
          default: return 'Your vault documents are encrypted with AES security and isolated per user via strict Firestore database rules. Your private data is never sold or shared with any third party.';
        }
      default:
        return '';
    }
  }
}
