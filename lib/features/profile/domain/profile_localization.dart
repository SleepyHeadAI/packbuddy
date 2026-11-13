/// Native localization for Profile screen, editing sheet, and travel statistics across 20 languages
class ProfileLocalization {
  ProfileLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String getTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Profilim';
      case 'de':
        return 'Mein Profil';
      case 'es':
        return 'Mi Perfil';
      case 'fr':
        return 'Mon Profil';
      case 'it':
        return 'Il Mio Profilo';
      case 'pt':
        return 'Meu Perfil';
      case 'ru':
        return 'Мой профиль';
      case 'zh':
        return '个人资料';
      case 'ja':
        return 'プロフィール';
      case 'ko':
        return '내 프로필';
      case 'hi':
        return 'मेरी प्रोफ़ाइल';
      case 'ar':
        return 'ملفي الشخصي';
      case 'nl':
        return 'Mijn Profiel';
      case 'el':
        return 'Το Προφίλ μου';
      case 'sv':
        return 'Min Profil';
      case 'pl':
        return 'Mój Profil';
      case 'id':
        return 'Profil Saya';
      case 'th':
        return 'โปรไฟล์ของฉัน';
      case 'vi':
        return 'Hồ sơ của tôi';
      case 'en':
      default:
        return 'My Profile';
    }
  }

  static String getEditProfile(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Profili Düzenle';
      case 'de':
        return 'Profil bearbeiten';
      case 'es':
        return 'Editar Perfil';
      case 'fr':
        return 'Modifier le Profil';
      case 'it':
        return 'Modifica Profilo';
      case 'pt':
        return 'Editar Perfil';
      case 'ru':
        return 'Редактировать профиль';
      case 'zh':
        return '编辑资料';
      case 'ja':
        return 'プロフィールを編集';
      case 'ko':
        return '프로필 수정';
      case 'hi':
        return 'प्रोफ़ाइल संपादित करें';
      case 'ar':
        return 'تعديل الملف الشخصي';
      case 'nl':
        return 'Profiel bewerken';
      case 'el':
        return 'Επεξεργασία Προφίλ';
      case 'sv':
        return 'Redigera profil';
      case 'pl':
        return 'Edytuj profil';
      case 'id':
        return 'Edit Profil';
      case 'th':
        return 'แก้ไขโปรไฟล์';
      case 'vi':
        return 'Chỉnh sửa hồ sơ';
      case 'en':
      default:
        return 'Edit Profile';
    }
  }

  static String getDisplayName(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Ad Soyad';
      case 'de':
        return 'Vollständiger Name';
      case 'es':
        return 'Nombre Completo';
      case 'fr':
        return 'Nom Complet';
      case 'it':
        return 'Nome e Cognome';
      case 'pt':
        return 'Nome Completo';
      case 'ru':
        return 'Имя и фамилия';
      case 'zh':
        return '姓名';
      case 'ja':
        return '氏名';
      case 'ko':
        return '이름';
      case 'hi':
        return 'पूरा नाम';
      case 'ar':
        return 'الاسم الكامل';
      case 'nl':
        return 'Volledige Naam';
      case 'el':
        return 'Ονοματεπώνυμο';
      case 'sv':
        return 'Fullständigt namn';
      case 'pl':
        return 'Imię i nazwisko';
      case 'id':
        return 'Nama Lengkap';
      case 'th':
        return 'ชื่อ-นามสกุล';
      case 'vi':
        return 'Họ và tên';
      case 'en':
      default:
        return 'Full Name';
    }
  }

  static String getBio(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Biyografi';
      case 'de':
        return 'Biografie';
      case 'es':
        return 'Biografía';
      case 'fr':
        return 'Biographie';
      case 'it':
        return 'Biografia';
      case 'pt':
        return 'Biografia';
      case 'ru':
        return 'О себе';
      case 'zh':
        return '个人简介';
      case 'ja':
        return '自己紹介';
      case 'ko':
        return '소개';
      case 'hi':
        return 'बायो';
      case 'ar':
        return 'نبذة شخصية';
      case 'nl':
        return 'Biografie';
      case 'el':
        return 'Βιογραφικό';
      case 'sv':
        return 'Biografi';
      case 'pl':
        return 'O mnie';
      case 'id':
        return 'Bio';
      case 'th':
        return 'คำแนะนำตัว';
      case 'vi':
        return 'Tiểu sử';
      case 'en':
      default:
        return 'Bio';
    }
  }

  static String getBioHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kendinizden ve seyahat tutkunuzdan kısaca bahsedin...';
      case 'de':
        return 'Erzählen Sie kurz von sich und Ihrer Reiselust...';
      case 'es':
        return 'Cuéntanos brevemente sobre ti y tu pasión por viajar...';
      case 'fr':
        return 'Parlez-nous brièvement de vous et de votre passion du voyage...';
      case 'it':
        return 'Raccontaci qualcosa di te e della tua passione per i viaggi...';
      case 'pt':
        return 'Conte-nos um pouco sobre você e sua paixão por viajar...';
      case 'ru':
        return 'Расскажите немного о себе и своей страсти к путешествиям...';
      case 'zh':
        return '简短介绍一下您自己与旅行梦想...';
      case 'ja':
        return '自己紹介や旅行の目標を簡単に教えてください...';
      case 'ko':
        return '자신과 여행에 대한 이야기를 간단히 적어보세요...';
      case 'hi':
        return 'अपने और अपनी यात्रा के शौक के बारे में कुछ बताएं...';
      case 'ar':
        return 'اكتب نبذة قصيرة عن نفسك وشغفك بالسفر...';
      case 'nl':
        return 'Vertel kort over uzelf en uw reislust...';
      case 'el':
        return 'Πείτε μας λίγα λόγια για εσάς και το πάθος σας για τα ταξίδια...';
      case 'sv':
        return 'Berätta kort om dig själv och din reslust...';
      case 'pl':
        return 'Opowiedz krótko o sobie i swojej pasji podróżowania...';
      case 'id':
        return 'Ceritakan tentang diri Anda dan minat perjalanan Anda...';
      case 'th':
        return 'เล่าเกี่ยวกับตัวคุณและความหลงใหลในการเดินทางสั้นๆ...';
      case 'vi':
        return 'Chia sẻ ngắn gọn về bản thân và niềm đam mê du lịch...';
      case 'en':
      default:
        return 'Tell us briefly about yourself and your travel passion...';
    }
  }

  static String getHomeCountry(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Yaşadığınız Ülke';
      case 'de':
        return 'Heimatland';
      case 'es':
        return 'País de Residencia';
      case 'fr':
        return 'Pays de Résidence';
      case 'it':
        return 'Paese di Residenza';
      case 'pt':
        return 'País de Residência';
      case 'ru':
        return 'Страна проживания';
      case 'zh':
        return '居住国家/地区';
      case 'ja':
        return '居住国';
      case 'ko':
        return '거주 국가';
      case 'hi':
        return 'गृह देश';
      case 'ar':
        return 'بلد الإقامة';
      case 'nl':
        return 'Woonland';
      case 'el':
        return 'Χώρα Διαμονής';
      case 'sv':
        return 'Hemland';
      case 'pl':
        return 'Kraj zamieszkania';
      case 'id':
        return 'Negara Asal';
      case 'th':
        return 'ประเทศที่พำนัก';
      case 'vi':
        return 'Quốc gia cư trú';
      case 'en':
      default:
        return 'Home Country';
    }
  }

  static String getTravelStats(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Seyahat İstatistikleri';
      case 'de':
        return 'Reisestatistiken';
      case 'es':
        return 'Estadísticas de Viaje';
      case 'fr':
        return 'Statistiques de Voyage';
      case 'it':
        return 'Statistiche di Viaggio';
      case 'pt':
        return 'Estatísticas de Viagem';
      case 'ru':
        return 'Статистика путешествий';
      case 'zh':
        return '旅行统计';
      case 'ja':
        return '旅行統計';
      case 'ko':
        return '여행 통계';
      case 'hi':
        return 'यात्रा सांख्यिकी';
      case 'ar':
        return 'إحصائيات السفر';
      case 'nl':
        return 'Reisstatistieken';
      case 'el':
        return 'Στατιστικά Ταξιδιών';
      case 'sv':
        return 'Resestatistik';
      case 'pl':
        return 'Statystyki podróży';
      case 'id':
        return 'Statistik Perjalanan';
      case 'th':
        return 'สถิติการเดินทาง';
      case 'vi':
        return 'Thống kê du lịch';
      case 'en':
      default:
        return 'Travel Statistics';
    }
  }

  static String getTotalTrips(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Seyahat';
      case 'de':
        return 'Reisen';
      case 'es':
        return 'Viajes';
      case 'fr':
        return 'Voyages';
      case 'it':
        return 'Viaggi';
      case 'pt':
        return 'Viagens';
      case 'ru':
        return 'Поездки';
      case 'zh':
        return '旅行次数';
      case 'ja':
        return '旅行';
      case 'ko':
        return '여행';
      case 'hi':
        return 'यात्राएं';
      case 'ar':
        return 'رحلات';
      case 'nl':
        return 'Reizen';
      case 'el':
        return 'Ταξίδια';
      case 'sv':
        return 'Resor';
      case 'pl':
        return 'Podróże';
      case 'id':
        return 'Perjalanan';
      case 'th':
        return 'ทริป';
      case 'vi':
        return 'Chuyến đi';
      case 'en':
      default:
        return 'Trips';
    }
  }

  static String getCountriesVisited(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Gezilen Ülke';
      case 'de':
        return 'Besuchte Länder';
      case 'es':
        return 'Países Visitados';
      case 'fr':
        return 'Pays Visités';
      case 'it':
        return 'Paesi Visitati';
      case 'pt':
        return 'Países Visitados';
      case 'ru':
        return 'Стран посещено';
      case 'zh':
        return '到访国家/地区';
      case 'ja':
        return '訪問国';
      case 'ko':
        return '방문 국가';
      case 'hi':
        return 'देश घूमे';
      case 'ar':
        return 'دول تمت زيارتها';
      case 'nl':
        return 'Bezochte Landen';
      case 'el':
        return 'Χώρες που επισκεφθήκατε';
      case 'sv':
        return 'Besökta länder';
      case 'pl':
        return 'Odwiedzone kraje';
      case 'id':
        return 'Negara Dikunjungi';
      case 'th':
        return 'ประเทศที่เคยไป';
      case 'vi':
        return 'Quốc gia đã đến';
      case 'en':
      default:
        return 'Countries Visited';
    }
  }

  static String getPackingItems(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Bavul Eşyası';
      case 'de':
        return 'Gepäckstücke';
      case 'es':
        return 'Artículos de Equipaje';
      case 'fr':
        return 'Articles de Bagages';
      case 'it':
        return 'Oggetti in Valigia';
      case 'pt':
        return 'Itens de Bagagem';
      case 'ru':
        return 'Вещей в багаже';
      case 'zh':
        return '行李物品';
      case 'ja':
        return '荷物アイテム';
      case 'ko':
        return '짐 목록 아이템';
      case 'hi':
        return 'पैकिंग सामान';
      case 'ar':
        return 'أمتعة محزومة';
      case 'nl':
        return 'Bagage-items';
      case 'el':
        return 'Αντικείμενα Βαλίτσας';
      case 'sv':
        return 'Packade föremål';
      case 'pl':
        return 'Spakowane rzeczy';
      case 'id':
        return 'Item Bawaan';
      case 'th':
        return 'สิ่งของที่จัด';
      case 'vi':
        return 'Đồ đạc mang theo';
      case 'en':
      default:
        return 'Packing Items';
    }
  }

  static String getVaultDocuments(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kasa Belgesi';
      case 'de':
        return 'Tresordokumente';
      case 'es':
        return 'Documentos en Bóveda';
      case 'fr':
        return 'Documents du Coffre';
      case 'it':
        return 'Documenti Cassaforte';
      case 'pt':
        return 'Documentos no Cofre';
      case 'ru':
        return 'Документов в сейфе';
      case 'zh':
        return '保险箱文档';
      case 'ja':
        return '保管ドキュメント';
      case 'ko':
        return '금고 보관 문서';
      case 'hi':
        return 'तिजोरी दस्तावेज़';
      case 'ar':
        return 'وثائق الخزنة';
      case 'nl':
        return 'Kluisdocumenten';
      case 'el':
        return 'Έγγραφα Θυρίδας';
      case 'sv':
        return 'Kassaskåpsdokument';
      case 'pl':
        return 'Dokumenty w sejfie';
      case 'id':
        return 'Dokumen Brankas';
      case 'th':
        return 'เอกสารในตู้นิรภัย';
      case 'vi':
        return 'Tài liệu két an toàn';
      case 'en':
      default:
        return 'Vault Documents';
    }
  }

  static String getMemberSince(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Üyelik Tarihi';
      case 'de':
        return 'Mitglied seit';
      case 'es':
        return 'Miembro desde';
      case 'fr':
        return 'Membre depuis';
      case 'it':
        return 'Membro dal';
      case 'pt':
        return 'Membro desde';
      case 'ru':
        return 'Регистрация';
      case 'zh':
        return '注册时间';
      case 'ja':
        return '登録日';
      case 'ko':
        return '가입일';
      case 'hi':
        return 'सदस्यता तिथि';
      case 'ar':
        return 'عضو منذ';
      case 'nl':
        return 'Lid sinds';
      case 'el':
        return 'Μέλος από';
      case 'sv':
        return 'Medlem sedan';
      case 'pl':
        return 'Użytkownik od';
      case 'id':
        return 'Bergabung sejak';
      case 'th':
        return 'เป็นสมาชิกตั้งแต่';
      case 'vi':
        return 'Thành viên từ';
      case 'en':
      default:
        return 'Member Since';
    }
  }

  static String getAccountSecurity(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Hesap Bilgileri';
      case 'de':
        return 'Kontoinformationen';
      case 'es':
        return 'Información de la Cuenta';
      case 'fr':
        return 'Informations du Compte';
      case 'it':
        return 'Informazioni Account';
      case 'pt':
        return 'Informações da Conta';
      case 'ru':
        return 'Данные учетной записи';
      case 'zh':
        return '账户信息';
      case 'ja':
        return 'アカウント情報';
      case 'ko':
        return '계정 정보';
      case 'hi':
        return 'खाता विवरण';
      case 'ar':
        return 'معلومات الحساب';
      case 'nl':
        return 'Accountinformatie';
      case 'el':
        return 'Πληροφορίες Λογαριασμού';
      case 'sv':
        return 'Kontoinformation';
      case 'pl':
        return 'Informacje o koncie';
      case 'id':
        return 'Informasi Akun';
      case 'th':
        return 'ข้อมูลบัญชี';
      case 'vi':
        return 'Thông tin tài khoản';
      case 'en':
      default:
        return 'Account Information';
    }
  }

  static String getSave(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Kaydet';
      case 'de':
        return 'Speichern';
      case 'es':
        return 'Guardar';
      case 'fr':
        return 'Enregistrer';
      case 'it':
        return 'Salva';
      case 'pt':
        return 'Salvar';
      case 'ru':
        return 'Сохранить';
      case 'zh':
        return '保存';
      case 'ja':
        return '保存';
      case 'ko':
        return '저장';
      case 'hi':
        return 'सहेजें';
      case 'ar':
        return 'حفظ';
      case 'nl':
        return 'Opslaan';
      case 'el':
        return 'Αποθήκευση';
      case 'sv':
        return 'Spara';
      case 'pl':
        return 'Zapisz';
      case 'id':
        return 'Simpan';
      case 'th':
        return 'บันทึก';
      case 'vi':
        return 'Lưu';
      case 'en':
      default:
        return 'Save';
    }
  }

  static String getProfileUpdated(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Profiliniz başarıyla güncellendi ✨';
      case 'de':
        return 'Profil erfolgreich aktualisiert ✨';
      case 'es':
        return 'Perfil actualizado con éxito ✨';
      case 'fr':
        return 'Profil mis à jour avec succès ✨';
      case 'it':
        return 'Profilo aggiornato con successo ✨';
      case 'pt':
        return 'Perfil atualizado com sucesso ✨';
      case 'ru':
        return 'Профиль успешно обновлен ✨';
      case 'zh':
        return '资料已成功更新 ✨';
      case 'ja':
        return 'プロフィールを更新しました ✨';
      case 'ko':
        return '프로필이 성공적으로 업데이트되었습니다 ✨';
      case 'hi':
        return 'प्रोफ़ाइल सफलतापूर्वक अपडेट हो गई ✨';
      case 'ar':
        return 'تم تحديث الملف الشخصي بنجاح ✨';
      case 'nl':
        return 'Profiel succesvol bijgewerkt ✨';
      case 'el':
        return 'Το προφίλ ενημερώθηκε επιτυχώς ✨';
      case 'sv':
        return 'Profilen har uppdaterats ✨';
      case 'pl':
        return 'Profil został zaktualizowany ✨';
      case 'id':
        return 'Profil berhasil diperbarui ✨';
      case 'th':
        return 'อัปเดตโปรไฟล์เรียบร้อยแล้ว ✨';
      case 'vi':
        return 'Cập nhật hồ sơ thành công ✨';
      case 'en':
      default:
        return 'Profile updated successfully ✨';
    }
  }
}

