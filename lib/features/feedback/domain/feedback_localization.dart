/// Native localization for Feedback & Suggestions across all 20 languages
class FeedbackL10n {
  FeedbackL10n._();

  static String getTitle(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Öneri & Geri Bildirim';
      case 'de':
        return 'Feedback & Vorschläge';
      case 'es':
        return 'Sugerencias y Comentarios';
      case 'fr':
        return 'Suggestions et Retours';
      case 'it':
        return 'Suggerimenti e Feedback';
      case 'pt':
        return 'Sugestões e Feedback';
      case 'ru':
        return 'Отзывы и предложения';
      case 'zh':
        return '意见与建议';
      case 'ja':
        return 'ご意見・改善提案';
      case 'ko':
        return '의견 및 피드백';
      case 'hi':
        return 'सुझाव और प्रतिक्रिया';
      case 'ar':
        return 'الاقتراحات والملاحظات';
      case 'nl':
        return 'Feedback & suggesties';
      case 'el':
        return 'Προτάσεις & Σχόλια';
      case 'sv':
        return 'Feedback & förslag';
      case 'pl':
        return 'Sugestie i opinie';
      case 'id':
        return 'Saran & Masukan';
      case 'th':
        return 'ข้อเสนอแนะและความคิดเห็น';
      case 'vi':
        return 'Góp ý & phản hồi';
      case 'en':
      default:
        return 'Feedback & Suggestions';
    }
  }

  static String getSubtitle(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'PackBuddy\'yi geliştirmemize yardımcı olun. Fikir ve geri bildirimlerinizi bizimle paylaşın.';
      case 'de':
        return 'Helfen Sie uns, PackBuddy zu verbessern. Teilen Sie Ihre Ideen und Ihr Feedback mit uns.';
      case 'es':
        return 'Ayúdanos a mejorar PackBuddy. Comparte tus ideas y comentarios con nosotros.';
      case 'fr':
        return 'Aidez-nous à améliorer PackBuddy. Partagez vos idées et vos remarques.';
      case 'it':
        return 'Aiutaci a migliorare PackBuddy. Condividi con noi le tue idee e opinioni.';
      case 'pt':
        return 'Ajude-nos a melhorar o PackBuddy. Compartilhe suas ideias e opiniões conosco.';
      case 'ru':
        return 'Помогите нам сделать PackBuddy лучше. Поделитесь своими идеями и отзывами.';
      case 'zh':
        return '帮助我们改进 PackBuddy。与我们分享您的宝贵想法和建议。';
      case 'ja':
        return 'PackBuddyの改善にご協力ください。ご意見やアイデアをぜひお寄せください。';
      case 'ko':
        return 'PackBuddy 개선에 동참해 주세요. 아이디어와 의견을 자유롭게 공유해 주세요.';
      case 'hi':
        return 'PackBuddy को बेहतर बनाने में हमारी मदद करें। अपने विचार और सुझाव हमारे साथ साझा करें।';
      case 'ar':
        return 'ساعدنا في تحسين PackBuddy. شارك أفكارك وملاحظاتك معنا.';
      case 'nl':
        return 'Help ons PackBuddy te verbeteren. Deel je ideeën en feedback met ons.';
      case 'el':
        return 'Βοηθήστε μας να βελτιώσουμε το PackBuddy. Μοιραστείτε τις ιδέες και τα σχόλιά σας.';
      case 'sv':
        return 'Hjälp oss göra PackBuddy ännu bättre. Dela dina idéer och synpunkter med oss.';
      case 'pl':
        return 'Pomóż nam ulepszać PackBuddy. Podziel się swoimi pomysłami i uwagami.';
      case 'id':
        return 'Bantu kami menyempurnakan PackBuddy. Bagikan ide dan masukan Anda kepada kami.';
      case 'th':
        return 'ช่วยเราพัฒนา PackBuddy ร่วมแบ่งปันไอเดียและข้อเสนอแนะของคุณกับเรา';
      case 'vi':
        return 'Hãy giúp chúng tôi cải thiện PackBuddy. Chia sẻ ý kiến và đóng góp của bạn.';
      case 'en':
      default:
        return 'Help us improve PackBuddy. Share your ideas, bug reports, and suggestions.';
    }
  }

  static String getInputHint(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Önerinizi veya yaşadığınız deneyimi buraya yazın (en fazla 1000 karakter)...';
      case 'de':
        return 'Schreiben Sie hier Ihren Vorschlag oder Ihre Erfahrung (max. 1000 Zeichen)...';
      case 'es':
        return 'Escribe aquí tu sugerencia o experiencia (máximo 1000 caracteres)...';
      case 'fr':
        return 'Écrivez ici votre suggestion ou remarque (1000 caractères max)...';
      case 'it':
        return 'Scrivi qui il tuo suggerimento o feedback (massimo 1000 caratteri)...';
      case 'pt':
        return 'Escreva aqui sua sugestão ou experiência (máximo 1000 caracteres)...';
      case 'ru':
        return 'Напишите ваше предложение или отзыв здесь (максимум 1000 символов)...';
      case 'zh':
        return '请在此输入您的建议或使用体验（最多 1000 字）...';
      case 'ja':
        return 'ご提案や体験談をここに入力してください（最大1000文字）...';
      case 'ko':
        return '제안 사항이나 경험을 여기에 작성해 주세요 (최대 1000자)...';
      case 'hi':
        return 'यहाँ अपना सुझाव या अनुभव लिखें (अधिकतम 1000 अक्षर)...';
      case 'ar':
        return 'اكتب اقتراحك أو تجربتك هنا (بحد أقصى 1000 حرف)...';
      case 'nl':
        return 'Typ hier je suggestie of ervaring (max. 1000 tekens)...';
      case 'el':
        return 'Γράψτε εδώ την πρόταση ή την εμπειρία σας (έως 1000 χαρακτήρες)...';
      case 'sv':
        return 'Skriv ditt förslag eller din upplevelse här (max 1000 tecken)...';
      case 'pl':
        return 'Wpisz tutaj swoją sugestię lub opinię (maks. 1000 znaków)...';
      case 'id':
        return 'Tulis saran atau pengalaman Anda di sini (maks. 1000 karakter)...';
      case 'th':
        return 'พิมพ์ข้อเสนอแนะหรือประสบการณ์ของคุณที่นี่ (สูงสุด 1000 ตัวอักษร)...';
      case 'vi':
        return 'Nhập đề xuất hoặc trải nghiệm của bạn tại đây (tối đa 1000 ký tự)...';
      case 'en':
      default:
        return 'Type your suggestion or feedback here (max 1000 characters)...';
    }
  }

  static String getAttachImage(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Görsel Ekle (Opsiyonel)';
      case 'de':
        return 'Bild anhängen (Optional)';
      case 'es':
        return 'Adjuntar imagen (Opcional)';
      case 'fr':
        return 'Joindre une image (Optionnel)';
      case 'it':
        return 'Allega immagine (Opzionale)';
      case 'pt':
        return 'Anexar imagem (Opcional)';
      case 'ru':
        return 'Прикрепить скриншот (Необязательно)';
      case 'zh':
        return '添加截图/图片（可选）';
      case 'ja':
        return '画像・スクリーンショットを添付（任意）';
      case 'ko':
        return '이미지 첨부 (선택 사항)';
      case 'hi':
        return 'तस्वीर जोड़ें (वैकल्पिक)';
      case 'ar':
        return 'إرفاق صورة (اختياري)';
      case 'nl':
        return 'Afbeelding bijvoegen (Optioneel)';
      case 'el':
        return 'Επισύναψη εικόνας (Προαιρετικό)';
      case 'sv':
        return 'Bifoga bild (Valfritt)';
      case 'pl':
        return 'Załącz zrzut ekranu (Opcjonalnie)';
      case 'id':
        return 'Lampirkan gambar (Opsional)';
      case 'th':
        return 'แนบรูปภาพ (ทางเลือก)';
      case 'vi':
        return 'Đính kèm hình ảnh (Tùy chọn)';
      case 'en':
      default:
        return 'Attach Image (Optional)';
    }
  }

  static String getSubmit(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Öneriyi Gönder';
      case 'de':
        return 'Feedback senden';
      case 'es':
        return 'Enviar sugerencia';
      case 'fr':
        return 'Envoyer la suggestion';
      case 'it':
        return 'Invia suggerimento';
      case 'pt':
        return 'Enviar sugestão';
      case 'ru':
        return 'Отправить отзыв';
      case 'zh':
        return '提交建议';
      case 'ja':
        return '送信する';
      case 'ko':
        return '피드백 제출';
      case 'hi':
        return 'सुझाव भेजें';
      case 'ar':
        return 'إرسال الاقتراح';
      case 'nl':
        return 'Verstuur suggestie';
      case 'el':
        return 'Υποβολή πρότασης';
      case 'sv':
        return 'Skicka förslag';
      case 'pl':
        return 'Wyślij opinię';
      case 'id':
        return 'Kirim Saran';
      case 'th':
        return 'ส่งข้อเสนอแนะ';
      case 'vi':
        return 'Gửi phản hồi';
      case 'en':
      default:
        return 'Submit Feedback';
    }
  }

  static String getSuccess(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Öneriniz başarıyla iletildi. Katkınız için çok teşekkür ederiz!';
      case 'de':
        return 'Ihr Feedback wurde erfolgreich übermittelt. Vielen Dank für Ihren Beitrag!';
      case 'es':
        return '¡Tu sugerencia se ha enviado con éxito. Muchas gracias por tu ayuda!';
      case 'fr':
        return 'Votre suggestion a été envoyée avec succès. Merci pour votre aide !';
      case 'it':
        return 'Il tuo feedback è stato inviato con successo. Grazie per il tuo contributo!';
      case 'pt':
        return 'Sua sugestão foi enviada com sucesso. Muito obrigado pela sua ajuda!';
      case 'ru':
        return 'Ваш отзыв успешно отправлен. Большое спасибо за ваш вклад!';
      case 'zh':
        return '您的建议已成功提交，非常感谢您的宝贵反馈！';
      case 'ja':
        return 'ご意見を送信しました。ご協力いただき誠にありがとうございます！';
      case 'ko':
        return '피드백이 성공적으로 전송되었습니다. 소중한 의견 감사합니다!';
      case 'hi':
        return 'आपका सुझाव सफलतापूर्वक भेज दिया गया है। धन्यवाद!';
      case 'ar':
        return 'تم إرسال اقتراحك بنجاح. شكراً جزيلاً لمساهمتك!';
      case 'nl':
        return 'Je feedback is succesvol verzonden. Hartelijk dank voor je bijdrage!';
      case 'el':
        return 'Η πρότασή σας υποβλήθηκε με επιτυχία. Σας ευχαριστούμε πολύ!';
      case 'sv':
        return 'Ditt förslag har skickats. Tack så mycket för din feedback!';
      case 'pl':
        return 'Twoja opinia została pomyślnie przesłana. Dziękujemy!';
      case 'id':
        return 'Saran Anda berhasil dikirim. Terima kasih atas masukan Anda!';
      case 'th':
        return 'ส่งข้อเสนอแนะของคุณเรียบร้อยแล้ว ขอบคุณสำหรับความคิดเห็นของคุณ!';
      case 'vi':
        return 'Đóng góp của bạn đã được gửi thành công. Cảm ơn bạn rất nhiều!';
      case 'en':
      default:
        return 'Your feedback has been submitted successfully. Thank you for your contribution!';
    }
  }

  static String getEmptyError(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Lütfen göndermeden önce bir öneri metni yazın.';
      case 'de':
        return 'Bitte geben Sie vor dem Absenden einen Text ein.';
      case 'es':
        return 'Por favor escribe tu sugerencia antes de enviar.';
      case 'fr':
        return 'Veuillez saisir votre suggestion avant de l\'envoyer.';
      case 'it':
        return 'Inserisci un testo prima di inviare.';
      case 'pt':
        return 'Por favor, escreva uma sugestão antes de enviar.';
      case 'ru':
        return 'Пожалуйста, напишите текст перед отправкой.';
      case 'zh':
        return '请在提交前输入您的建议内容。';
      case 'ja':
        return '送信する前に内容を入力してください。';
      case 'ko':
        return '제출하기 전에 의견을 입력해 주세요.';
      case 'hi':
        return 'कृपया सबमिट करने से पहले कुछ लिखें।';
      case 'ar':
        return 'يرجى كتابة نص الاقتراح قبل الإرسال.';
      case 'nl':
        return 'Voer een tekst in voordat u verzendt.';
      case 'el':
        return 'Παρακαλώ εισάγετε κείμενο πριν την υποβολή.';
      case 'sv':
        return 'Vänligen ange en text innan du skickar.';
      case 'pl':
        return 'Przed wysłaniem wpisz treść opinii.';
      case 'id':
        return 'Harap masukkan teks sebelum mengirim.';
      case 'th':
        return 'กรุณากรอกข้อความก่อนส่ง';
      case 'vi':
        return 'Vui lòng nhập nội dung trước khi gửi.';
      case 'en':
      default:
        return 'Please enter your feedback text before submitting.';
    }
  }

  static String getAdminTitle(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Kullanıcı Önerileri';
      case 'de':
        return 'Benutzervorschläge';
      case 'es':
        return 'Sugerencias de Usuarios';
      case 'fr':
        return 'Suggestions des Utilisateurs';
      case 'it':
        return 'Suggerimenti Utenti';
      case 'pt':
        return 'Sugestões de Usuários';
      case 'ru':
        return 'Предложения пользователей';
      case 'zh':
        return '用户反馈与建议';
      case 'ja':
        return 'ユーザーからの改善要望';
      case 'ko':
        return '사용자 제안 및 피드백';
      case 'hi':
        return 'उपयोगकर्ता सुझाव';
      case 'ar':
        return 'اقتراحات المستخدمين';
      case 'nl':
        return 'Gebruikerssuggesties';
      case 'el':
        return 'Προτάσεις Χρηστών';
      case 'sv':
        return 'Användarförslag';
      case 'pl':
        return 'Sugestie użytkowników';
      case 'id':
        return 'Saran Pengguna';
      case 'th':
        return 'ข้อเสนอแนะจากผู้ใช้';
      case 'vi':
        return 'Đề xuất từ người dùng';
      case 'en':
      default:
        return 'User Suggestions & Feedback';
    }
  }

  static String getAdminNoFeedback(String lang) {
    switch (lang.toLowerCase().split('_').first) {
      case 'tr':
        return 'Henüz hiç kullanıcı önerisi bulunmuyor.';
      case 'de':
        return 'Es liegen noch keine Benutzervorschläge vor.';
      case 'es':
        return 'Aún no hay sugerencias de usuarios.';
      case 'fr':
        return 'Aucune suggestion d\'utilisateur pour le moment.';
      case 'it':
        return 'Nessun suggerimento ricevuto finora.';
      case 'pt':
        return 'Nenhuma sugestão recebida até o momento.';
      case 'ru':
        return 'Предложений от пользователей пока нет.';
      case 'zh':
        return '暂无用户提交的建议。';
      case 'ja':
        return '現在、ユーザーからの提案はありません。';
      case 'ko':
        return '아직 접수된 사용자 제안이 없습니다.';
      case 'hi':
        return 'अभी तक कोई सुझाव प्राप्त नहीं हुआ है।';
      case 'ar':
        return 'لا توجد اقتراحات من المستخدمين حتى الآن.';
      case 'nl':
        return 'Er zijn nog geen suggesties ontvangen.';
      case 'el':
        return 'Δεν υπάρχουν προτάσεις χρηστών ακόμα.';
      case 'sv':
        return 'Inga användarförslag har inkommit ännu.';
      case 'pl':
        return 'Brak nadesłanych sugestii.';
      case 'id':
        return 'Belum ada saran dari pengguna.';
      case 'th':
        return 'ยังไม่มีข้อเสนอแนะจากผู้ใช้';
      case 'vi':
        return 'Chưa có đề xuất nào từ người dùng.';
      case 'en':
      default:
        return 'No user suggestions have been submitted yet.';
    }
  }
}

