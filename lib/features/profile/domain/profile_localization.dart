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
        return 'Hakkımda / Biyografi';
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
        return 'Kendinizden ve seyahat tutkunuzdan bahsedin (en fazla 300 karakter)...';
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

  static String getChangePhoto(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Fotoğrafı Değiştir';
      case 'de':
        return 'Foto ändern';
      case 'es':
        return 'Cambiar Foto';
      case 'fr':
        return 'Changer de photo';
      case 'it':
        return 'Cambia Foto';
      case 'pt':
        return 'Mudar Foto';
      case 'ru':
        return 'Изменить фото';
      case 'zh':
        return '更换头像';
      case 'ja':
        return '写真を変更';
      case 'ko':
        return '사진 변경';
      case 'hi':
        return 'फ़ोटो बदलें';
      case 'ar':
        return 'تغيير الصورة';
      case 'nl':
        return 'Foto wijzigen';
      case 'el':
        return 'Αλλαγή φωτογραφίας';
      case 'sv':
        return 'Ändra foto';
      case 'pl':
        return 'Zmień zdjęcie';
      case 'id':
        return 'Ubah Foto';
      case 'th':
        return 'เปลี่ยนรูปภาพ';
      case 'vi':
        return 'Đổi ảnh';
      case 'en':
      default:
        return 'Change Photo';
    }
  }

  static String getChooseFromGallery(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Galeriden Fotoğraf Seç';
      case 'de':
        return 'Aus Galerie wählen';
      case 'es':
        return 'Elegir de la Galería';
      case 'fr':
        return 'Choisir dans la galerie';
      case 'it':
        return 'Scegli dalla galleria';
      case 'pt':
        return 'Escolher da Galeria';
      case 'ru':
        return 'Выбрать из галереи';
      case 'zh':
        return '从相册选择';
      case 'ja':
        return 'ギャラリーから選択';
      case 'ko':
        return '갤러리에서 선택';
      case 'hi':
        return 'गैलरी से चुनें';
      case 'ar':
        return 'اختر من المعرض';
      case 'nl':
        return 'Kies uit galerij';
      case 'el':
        return 'Επιλογή από τη συλλογή';
      case 'sv':
        return 'Välj från galleri';
      case 'pl':
        return 'Wybierz z galerii';
      case 'id':
        return 'Pilih dari Galeri';
      case 'th':
        return 'เลือกจากแกลเลอรี';
      case 'vi':
        return 'Chọn từ thư viện';
      case 'en':
      default:
        return 'Choose from Gallery';
    }
  }

  static String getRemovePhoto(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Fotoğrafı Kaldır';
      case 'de':
        return 'Foto entfernen';
      case 'es':
        return 'Eliminar Foto';
      case 'fr':
        return 'Supprimer la photo';
      case 'it':
        return 'Rimuovi Foto';
      case 'pt':
        return 'Remover Foto';
      case 'ru':
        return 'Удалить фото';
      case 'zh':
        return '移除头像';
      case 'ja':
        return '写真を削除';
      case 'ko':
        return '사진 제거';
      case 'hi':
        return 'फ़ोटो हटाएं';
      case 'ar':
        return 'إزالة الصورة';
      case 'nl':
        return 'Foto verwijderen';
      case 'el':
        return 'Αφαίρεση φωτογραφίας';
      case 'sv':
        return 'Ta bort foto';
      case 'pl':
        return 'Usuń zdjęcie';
      case 'id':
        return 'Hapus Foto';
      case 'th':
        return 'ลบรูปภาพ';
      case 'vi':
        return 'Xóa ảnh';
      case 'en':
      default:
        return 'Remove Photo';
    }
  }

  static String getCuteAnimalAvatars(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Tatlı Hayvan Avatarları (20 Karakter)';
      case 'de':
        return 'Süße Tier-Avatare (20 Charaktere)';
      case 'es':
        return 'Lindos Avatares de Animales (20 Personajes)';
      case 'fr':
        return 'Avatars d\'animaux mignons (20 Personnages)';
      case 'it':
        return 'Avatar di Animali Carini (20 Personaggi)';
      case 'pt':
        return 'Avatares de Animais Fofos (20 Personagens)';
      case 'ru':
        return 'Милые аватары животных (20 персонажей)';
      case 'zh':
        return '萌宠动物头像 (20款)';
      case 'ja':
        return 'かわいい動物アバター (20種類)';
      case 'ko':
        return '귀여운 동물 아바타 (20종)';
      case 'hi':
        return 'प्यारे पशु अवतार (20 पात्र)';
      case 'ar':
        return 'صور رمزية لحيوانات لطيفة (20 شخصية)';
      case 'nl':
        return 'Schattige Dierenavatars (20 Karakters)';
      case 'el':
        return 'Χαριτωμένα Avatars Ζώων (20 Χαρακτήρες)';
      case 'sv':
        return 'Gulliga djuravatarer (20 Karaktärer)';
      case 'pl':
        return 'Słodkie awatary zwierząt (20 Postaci)';
      case 'id':
        return 'Avatar Hewan Lucu (20 Karakter)';
      case 'th':
        return 'อวาตาร์สัตว์น่ารัก (20 ตัวละคร)';
      case 'vi':
        return 'Ảnh đại diện thú cưng đáng yêu (20 Nhân vật)';
      case 'en':
      default:
        return 'Cute Animal Avatars (20 Characters)';
    }
  }

  static String getSelectAvatar(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Profil Fotoğrafı Seç';
      case 'de':
        return 'Profilfoto auswählen';
      case 'es':
        return 'Seleccionar Foto de Perfil';
      case 'fr':
        return 'Choisir une photo de profil';
      case 'it':
        return 'Seleziona Foto Profilo';
      case 'pt':
        return 'Selecionar Foto de Perfil';
      case 'ru':
        return 'Выбрать фото профиля';
      case 'zh':
        return '选择头像';
      case 'ja':
        return 'プロフィール写真を選択';
      case 'ko':
        return '프로필 사진 선택';
      case 'hi':
        return 'प्रोफ़ाइल फ़ोटो चुनें';
      case 'ar':
        return 'اختر صورة الملف الشخصي';
      case 'nl':
        return 'Kies Profielfoto';
      case 'el':
        return 'Επιλέξτε φωτογραφία προφίλ';
      case 'sv':
        return 'Välj profilfoto';
      case 'pl':
        return 'Wybierz zdjęcie profilowe';
      case 'id':
        return 'Pilih Foto Profil';
      case 'th':
        return 'เลือกรูปโปรไฟล์';
      case 'vi':
        return 'Chọn ảnh đại diện';
      case 'en':
      default:
        return 'Choose Profile Photo';
    }
  }

  static String getPhotoUpdated(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Profil fotoğrafı güncellendi ✨';
      case 'de':
        return 'Profilfoto aktualisiert ✨';
      case 'es':
        return 'Foto de perfil actualizada ✨';
      case 'fr':
        return 'Photo de profil mise à jour ✨';
      case 'it':
        return 'Foto del profilo aggiornata ✨';
      case 'pt':
        return 'Foto de perfil atualizada ✨';
      case 'ru':
        return 'Фото профиля обновлено ✨';
      case 'zh':
        return '头像已更新 ✨';
      case 'ja':
        return 'プロフィール写真を更新しました ✨';
      case 'ko':
        return '프로필 사진이 업데이트되었습니다 ✨';
      case 'hi':
        return 'प्रोफ़ाइल फ़ोटो अपडेट हो गई ✨';
      case 'ar':
        return 'تم تحديث صورة الملف الشخصي ✨';
      case 'nl':
        return 'Profielfoto bijgewerkt ✨';
      case 'el':
        return 'Η φωτογραφία προφίλ ενημερώθηκε ✨';
      case 'sv':
        return 'Profilfoto har uppdaterats ✨';
      case 'pl':
        return 'Zdjęcie profilowe zostało zaktualizowane ✨';
      case 'id':
        return 'Foto profil berhasil diperbarui ✨';
      case 'th':
        return 'อัปเดตรูปโปรไฟล์แล้ว ✨';
      case 'vi':
        return 'Đã cập nhật ảnh đại diện ✨';
      case 'en':
      default:
        return 'Profile photo updated ✨';
    }
  }

  static String getAll(String lang) {
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

  static String getPets(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Evcil';
      case 'de':
        return 'Haustiere';
      case 'es':
        return 'Mascotas';
      case 'fr':
        return 'Domestiques';
      case 'it':
        return 'Domestici';
      case 'pt':
        return 'Animais';
      case 'ru':
        return 'Питомцы';
      case 'zh':
        return '宠物';
      case 'ja':
        return 'ペット';
      case 'ko':
        return '반려동물';
      case 'hi':
        return 'पालतू';
      case 'ar':
        return 'أليفة';
      case 'nl':
        return 'Huisdieren';
      case 'el':
        return 'Κατοικίδια';
      case 'sv':
        return 'Husdjur';
      case 'pl':
        return 'Domowe';
      case 'id':
        return 'Peliharaan';
      case 'th':
        return 'สัตว์เลี้ยง';
      case 'vi':
        return 'Thú cưng';
      case 'en':
      default:
        return 'Pets';
    }
  }

  static String getForest(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Orman';
      case 'de':
        return 'Wald';
      case 'es':
        return 'Bosque';
      case 'fr':
        return 'Forêt';
      case 'it':
        return 'Foresta';
      case 'pt':
        return 'Floresta';
      case 'ru':
        return 'Лес';
      case 'zh':
        return '森林';
      case 'ja':
        return '森';
      case 'ko':
        return '숲';
      case 'hi':
        return 'जंगल';
      case 'ar':
        return 'الغابة';
      case 'nl':
        return 'Bos';
      case 'el':
        return 'Δάσος';
      case 'sv':
        return 'Skog';
      case 'pl':
        return 'Las';
      case 'id':
        return 'Hutan';
      case 'th':
        return 'ป่า';
      case 'vi':
        return 'Rừng';
      case 'en':
      default:
        return 'Forest';
    }
  }

  static String getWild(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Vahşi';
      case 'de':
        return 'Wildtiere';
      case 'es':
        return 'Salvajes';
      case 'fr':
        return 'Sauvages';
      case 'it':
        return 'Selvatici';
      case 'pt':
        return 'Selvagens';
      case 'ru':
        return 'Дикие';
      case 'zh':
        return '野生';
      case 'ja':
        return '野生';
      case 'ko':
        return '야생';
      case 'hi':
        return 'वन्य';
      case 'ar':
        return 'برية';
      case 'nl':
        return 'Wild';
      case 'el':
        return 'Άγρια';
      case 'sv':
        return 'Vilda';
      case 'pl':
        return 'Dzikie';
      case 'id':
        return 'Liar';
      case 'th':
        return 'สัตว์ป่า';
      case 'vi':
        return 'Hoang dã';
      case 'en':
      default:
        return 'Wild';
    }
  }

  static String getSpecial(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Sevimli & Su';
      case 'de':
        return 'Wasser & Süß';
      case 'es':
        return 'Agua y Tiernos';
      case 'fr':
        return 'Aquatique & Mignon';
      case 'it':
        return 'Acquatici e Carini';
      case 'pt':
        return 'Aquático & Fofo';
      case 'ru':
        return 'Водные и милые';
      case 'zh':
        return '水生与萌趣';
      case 'ja':
        return '水生＆キュート';
      case 'ko':
        return '수생 & 귀여움';
      case 'hi':
        return 'जलीय और प्यारा';
      case 'ar':
        return 'مائية ولطيفة';
      case 'nl':
        return 'Water & Schattig';
      case 'el':
        return 'Υδρόβια & Γλυκά';
      case 'sv':
        return 'Vatten & Söta';
      case 'pl':
        return 'Wodne i urocze';
      case 'id':
        return 'Air & Lucu';
      case 'th':
        return 'น้ำและน่ารัก';
      case 'vi':
        return 'Thủy sinh & Dễ thương';
      case 'en':
      default:
        return 'Cute & Aquatic';
    }
  }

  static String getDefaultTravelerName(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'PackBuddy Gezgini';
      case 'de':
        return 'PackBuddy Reisender';
      case 'es':
        return 'Viajero de PackBuddy';
      case 'fr':
        return 'Voyageur PackBuddy';
      case 'it':
        return 'Viaggiatore PackBuddy';
      case 'pt':
        return 'Viajante PackBuddy';
      case 'ru':
        return 'Путешественник PackBuddy';
      case 'zh':
        return 'PackBuddy 旅行者';
      case 'ja':
        return 'PackBuddy 旅行者';
      case 'ko':
        return 'PackBuddy 여행자';
      case 'hi':
        return 'PackBuddy यात्री';
      case 'ar':
        return 'مسافر PackBuddy';
      case 'nl':
        return 'PackBuddy Reiziger';
      case 'el':
        return 'Ταξιδιώτης PackBuddy';
      case 'sv':
        return 'PackBuddy Resenär';
      case 'pl':
        return 'Podróżnik PackBuddy';
      case 'id':
        return 'Penjelajah PackBuddy';
      case 'th':
        return 'นักเดินทาง PackBuddy';
      case 'vi':
        return 'Lữ khách PackBuddy';
      case 'en':
      default:
        return 'PackBuddy Traveler';
    }
  }

  static String getSelectCountry(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Ülke seçin';
      case 'de':
        return 'Land auswählen';
      case 'es':
        return 'Seleccionar país';
      case 'fr':
        return 'Sélectionner un pays';
      case 'it':
        return 'Seleziona paese';
      case 'pt':
        return 'Selecionar país';
      case 'ru':
        return 'Выберите страну';
      case 'zh':
        return '选择国家/地区';
      case 'ja':
        return '国を選択';
      case 'ko':
        return '국가 선택';
      case 'hi':
        return 'देश चुनें';
      case 'ar':
        return 'اختر الدولة';
      case 'nl':
        return 'Land selecteren';
      case 'el':
        return 'Επιλέξτε χώρα';
      case 'sv':
        return 'Välj land';
      case 'pl':
        return 'Wybierz kraj';
      case 'id':
        return 'Pilih negara';
      case 'th':
        return 'เลือกประเทศ';
      case 'vi':
        return 'Chọn quốc gia';
      case 'en':
      default:
        return 'Select country';
    }
  }

  static String getEmailStatus(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'E-posta Durumu';
      case 'de':
        return 'E-Mail-Status';
      case 'es':
        return 'Estado del Correo';
      case 'fr':
        return 'Statut de l\'e-mail';
      case 'it':
        return 'Stato Email';
      case 'pt':
        return 'Status do E-mail';
      case 'ru':
        return 'Статус эл. почты';
      case 'zh':
        return '邮箱状态';
      case 'ja':
        return 'メールステータス';
      case 'ko':
        return '이메일 상태';
      case 'hi':
        return 'ईमेल स्थिति';
      case 'ar':
        return 'حالة البريد الإلكتروني';
      case 'nl':
        return 'E-mailstatus';
      case 'el':
        return 'Κατάσταση Email';
      case 'sv':
        return 'E-poststatus';
      case 'pl':
        return 'Status e-mail';
      case 'id':
        return 'Status Email';
      case 'th':
        return 'สถานะอีเมล';
      case 'vi':
        return 'Trạng thái email';
      case 'en':
      default:
        return 'Email Status';
    }
  }

  static String getVerified(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Doğrulandı';
      case 'de':
        return 'Verifiziert';
      case 'es':
        return 'Verificado';
      case 'fr':
        return 'Vérifié';
      case 'it':
        return 'Verificato';
      case 'pt':
        return 'Verificado';
      case 'ru':
        return 'Подтверждён';
      case 'zh':
        return '已验证';
      case 'ja':
        return '認証済み';
      case 'ko':
        return '인증됨';
      case 'hi':
        return 'सत्यापित';
      case 'ar':
        return 'موثق';
      case 'nl':
        return 'Geverifieerd';
      case 'el':
        return 'Επαληθευμένο';
      case 'sv':
        return 'Verifierad';
      case 'pl':
        return 'Zweryfikowano';
      case 'id':
        return 'Terverifikasi';
      case 'th':
        return 'ยืนยันแล้ว';
      case 'vi':
        return 'Đã xác minh';
      case 'en':
      default:
        return 'Verified';
    }
  }

  static String getUnverified(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Doğrulanmadı';
      case 'de':
        return 'Nicht verifiziert';
      case 'es':
        return 'No verificado';
      case 'fr':
        return 'Non vérifié';
      case 'it':
        return 'Non verificato';
      case 'pt':
        return 'Não verificado';
      case 'ru':
        return 'Не подтверждён';
      case 'zh':
        return '未验证';
      case 'ja':
        return '未認証';
      case 'ko':
        return '인증되지 않음';
      case 'hi':
        return 'असत्यापित';
      case 'ar':
        return 'غير موثق';
      case 'nl':
        return 'Niet geverifieerd';
      case 'el':
        return 'Μη επαληθευμένο';
      case 'sv':
        return 'Ej verifierad';
      case 'pl':
        return 'Niezweryfikowany';
      case 'id':
        return 'Belum diverifikasi';
      case 'th':
        return 'ยังไม่ยืนยัน';
      case 'vi':
        return 'Chưa xác minh';
      case 'en':
      default:
        return 'Unverified';
    }
  }

  static String getSignInMethod(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'Giriş Yöntemi';
      case 'de':
        return 'Anmeldemethode';
      case 'es':
        return 'Método de Inicio de Sesión';
      case 'fr':
        return 'Méthode de connexion';
      case 'it':
        return 'Metodo di Accesso';
      case 'pt':
        return 'Método de Entrada';
      case 'ru':
        return 'Способ входа';
      case 'zh':
        return '登录方式';
      case 'ja':
        return 'ログイン方法';
      case 'ko':
        return '로그인 방식';
      case 'hi':
        return 'लॉग-इन विधि';
      case 'ar':
        return 'طريقة تسجيل الدخول';
      case 'nl':
        return 'Inlogmethode';
      case 'el':
        return 'Μέθοδος Σύνδεσης';
      case 'sv':
        return 'Inloggningsmetod';
      case 'pl':
        return 'Metoda logowania';
      case 'id':
        return 'Metode Masuk';
      case 'th':
        return 'วิธีเข้าสู่ระบบ';
      case 'vi':
        return 'Phương thức đăng nhập';
      case 'en':
      default:
        return 'Sign-in Method';
    }
  }

  static String getEmailAndPassword(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'E-posta ve Şifre';
      case 'de':
        return 'E-Mail & Passwort';
      case 'es':
        return 'Correo y Contraseña';
      case 'fr':
        return 'E-mail et mot de passe';
      case 'it':
        return 'Email e Password';
      case 'pt':
        return 'E-mail e Senha';
      case 'ru':
        return 'Эл. почта и пароль';
      case 'zh':
        return '邮箱与密码';
      case 'ja':
        return 'メールとパスワード';
      case 'ko':
        return '이메일 및 비밀번호';
      case 'hi':
        return 'ईमेल और पासवर्ड';
      case 'ar':
        return 'البريد الإلكتروني وكلمة المرور';
      case 'nl':
        return 'E-mail & Wachtwoord';
      case 'el':
        return 'Email & Κωδικός';
      case 'sv':
        return 'E-post & Lösenord';
      case 'pl':
        return 'E-mail i hasło';
      case 'id':
        return 'Email & Kata Sandi';
      case 'th':
        return 'อีเมลและรหัสผ่าน';
      case 'vi':
        return 'Email & Mật khẩu';
      case 'en':
      default:
        return 'Email & Password';
    }
  }

  static String getPlannedRoutesSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'planlanan rota';
      case 'de':
        return 'geplante Routen';
      case 'es':
        return 'rutas planificadas';
      case 'fr':
        return 'itinéraires prévus';
      case 'it':
        return 'rotte pianificate';
      case 'pt':
        return 'rotas planejadas';
      case 'ru':
        return 'запланир. маршруты';
      case 'zh':
        return '计划行程';
      case 'ja':
        return '予定ルート';
      case 'ko':
        return '계획된 일정';
      case 'hi':
        return 'नियोजित मार्ग';
      case 'ar':
        return 'مسارات مخططة';
      case 'nl':
        return 'geplande routes';
      case 'el':
        return 'σχεδιασμένες διαδρομές';
      case 'sv':
        return 'planerade rutter';
      case 'pl':
        return 'zaplanowane trasy';
      case 'id':
        return 'rute terencana';
      case 'th':
        return 'เส้นทางที่วางแผน';
      case 'vi':
        return 'lộ trình dự kiến';
      case 'en':
      default:
        return 'planned routes';
    }
  }

  static String getWorldShareSubtitle(String lang, String percent) {
    final clean = _cleanLang(lang);
    if (clean == 'tr') return '%$percent (dünya)';
    if (clean == 'de') return '$percent% (Welt)';
    if (clean == 'es') return '$percent% (mundo)';
    if (clean == 'fr') return '$percent% (monde)';
    if (clean == 'it') return '$percent% (mondo)';
    if (clean == 'pt') return '$percent% (mundo)';
    if (clean == 'ru') return '$percent% (мир)';
    if (clean == 'zh') return '$percent% (全球)';
    if (clean == 'ja') return '$percent% (世界)';
    if (clean == 'ko') return '$percent% (전 세계)';
    if (clean == 'hi') return '$percent% (विश्व)';
    if (clean == 'ar') return '$percent% (العالم)';
    if (clean == 'nl') return '$percent% (wereld)';
    if (clean == 'el') return '$percent% (κόσμος)';
    if (clean == 'sv') return '$percent% (världen)';
    if (clean == 'pl') return '$percent% (świat)';
    if (clean == 'id') return '$percent% (dunia)';
    if (clean == 'th') return '$percent% (ทั่วโลก)';
    if (clean == 'vi') return '$percent% (thế giới)';
    return '$percent% (world)';
  }

  static String getLuggageItemsSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'bavul eşyası';
      case 'de':
        return 'Gepäckstücke';
      case 'es':
        return 'artículos de equipaje';
      case 'fr':
        return 'articles de valise';
      case 'it':
        return 'oggetti in valigia';
      case 'pt':
        return 'itens na mala';
      case 'ru':
        return 'предметы багажа';
      case 'zh':
        return '行李物品';
      case 'ja':
        return '荷物アイテム';
      case 'ko':
        return '짐 꾸리기 품목';
      case 'hi':
        return 'सामान की वस्तुएं';
      case 'ar':
        return 'أمتعة محزومة';
      case 'nl':
        return 'bagagestukken';
      case 'el':
        return 'είδη αποσκευών';
      case 'sv':
        return 'bagageartiklar';
      case 'pl':
        return 'przedmioty w bagażu';
      case 'id':
        return 'barang koper';
      case 'th':
        return 'ของในกระเป๋า';
      case 'vi':
        return 'đồ trong hành lý';
      case 'en':
      default:
        return 'luggage items';
    }
  }

  static String getEncryptedDocsSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr':
        return 'şifreli belge';
      case 'de':
        return 'verschlüsselte Dateien';
      case 'es':
        return 'archivos cifrados';
      case 'fr':
        return 'fichiers chiffrés';
      case 'it':
        return 'file crittografati';
      case 'pt':
        return 'arquivos criptografados';
      case 'ru':
        return 'зашифр. файлы';
      case 'zh':
        return '加密文件';
      case 'ja':
        return '暗号化ファイル';
      case 'ko':
        return '암호화된 문서';
      case 'hi':
        return 'एन्क्रिप्टेड दस्तावेज़';
      case 'ar':
        return 'ملفات مشفرة';
      case 'nl':
        return 'versleutelde bestanden';
      case 'el':
        return 'κρυπτογραφημένα αρχεία';
      case 'sv':
        return 'krypterade filer';
      case 'pl':
        return 'zaszyfrowane pliki';
      case 'id':
        return 'berkas terenkripsi';
      case 'th':
        return 'ไฟล์ที่เข้ารหัส';
      case 'vi':
        return 'tài liệu mã hóa';
      case 'en':
      default:
        return 'encrypted files';
    }
  }

  static String getUsername(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kullanıcı Adı (Buddy ID)';
      case 'de': return 'Benutzername (Buddy-ID)';
      case 'es': return 'Nombre de usuario';
      case 'fr': return "Nom d'utilisateur";
      case 'it': return 'Nome utente';
      case 'pt': return 'Nome de usuário';
      case 'ru': return 'Имя пользователя';
      case 'zh': return '用户名 (Buddy ID)';
      case 'ja': return 'ユーザー名 (Buddy ID)';
      case 'ko': return '사용자 이름 (Buddy ID)';
      case 'ar': return 'اسم المستخدم';
      case 'hi': return 'उपयोगकर्ता नाम (Buddy ID)';
      case 'nl': return 'Gebruikersnaam (Buddy-ID)';
      case 'el': return 'Όνομα χρήστη (Buddy ID)';
      case 'sv': return 'Användarnamn (Buddy-ID)';
      case 'pl': return 'Nazwa użytkownika (Buddy ID)';
      case 'id': return 'Nama Pengguna (Buddy ID)';
      case 'th': return 'ชื่อผู้ใช้ (Buddy ID)';
      case 'vi': return 'Tên người dùng (Buddy ID)';
      case 'en':
      default: return 'Username (Buddy ID)';
    }
  }

  static String getUsernameHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'ornek_gezgin (3-20 karakter)';
      case 'de': return 'beispiel_reisender (3-20 Zeichen)';
      case 'es': return 'ejemplo_viajero (3-20 caracteres)';
      case 'fr': return 'exemple_voyageur (3-20 caractères)';
      case 'it': return 'esempio_viaggiatore (3-20 caratteri)';
      case 'pt': return 'exemplo_viajante (3-20 caracteres)';
      case 'ru': return 'primer_putnik (3-20 символов)';
      case 'zh': return 'traveler_name (3-20字符)';
      case 'ja': return 'traveler_name (3-20文字)';
      case 'ko': return 'traveler_name (3-20자)';
      case 'ar': return 'traveler_name (3-20 حرف)';
      case 'hi': return 'traveler_name (3-20 अक्षर)';
      case 'nl': return 'voorbeeld_reiziger (3-20 tekens)';
      case 'el': return 'paradeigma_taksidioti (3-20 χαρακτήρες)';
      case 'sv': return 'exempel_resenar (3-20 tecken)';
      case 'pl': return 'przyklad_podroznik (3-20 znaków)';
      case 'id': return 'contoh_pelancong (3-20 karakter)';
      case 'th': return 'traveler_name (3-20 ตัวอักษร)';
      case 'vi': return 'traveler_name (3-20 ký tự)';
      case 'en':
      default: return 'traveler_name (3-20 characters)';
    }
  }

  static String getUsernameHelper(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Arkadaşlarınız sizi bu isimle arayıp ekleyebilir';
      case 'de': return 'Freunde können dich mit diesem Namen suchen und hinzufügen';
      case 'es': return 'Tus amigos pueden buscarte y agregarte con este nombre';
      case 'fr': return 'Vos amis peuvent vous trouver et vous ajouter avec ce nom';
      case 'it': return 'I tuoi amici possono cercarti e aggiungerti con questo nome';
      case 'pt': return 'Seus amigos podem procurar e adicionar você por este nome';
      case 'ru': return 'Друзья смогут найти вас по этому имени';
      case 'zh': return '好友可以通过此用户名搜索并添加您';
      case 'ja': return '友達はこの名前であなたを検索して追加できます';
      case 'ko': return '친구들이 이 이름으로 당신을 찾아 추가할 수 있습니다';
      case 'hi': return 'मित्र आपको इस नाम से खोज और जोड़ सकते हैं';
      case 'ar': return 'يمكن لأصدقائك البحث عنك وإضافتك بهذا الاسم';
      case 'nl': return 'Vrienden kunnen je met deze naam zoeken en toevoegen';
      case 'el': return 'Οι φίλοι σας μπορούν να σας αναζητήσουν με αυτό το όνομα';
      case 'sv': return 'Vänner kan söka efter och lägga till dig med detta namn';
      case 'pl': return 'Znajomi mogą Cię wyszukać i dodać pod tą nazwą';
      case 'id': return 'Teman dapat mencari dan menambahkan Anda dengan nama ini';
      case 'th': return 'เพื่อนสามารถค้นหาและเพิ่มคุณด้วยชื่อนี้ได้';
      case 'vi': return 'Bạn bè có thể tìm kiếm và thêm bạn bằng tên này';
      case 'en':
      default: return 'Friends can find and add you with this unique handle';
    }
  }

  static String getUsernameInvalid(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Yalnızca küçük harf, rakam ve alt çizgi (3-20 karakter)';
      case 'de': return 'Nur Kleinbuchstaben, Zahlen und Unterstriche (3-20 Zeichen)';
      case 'es': return 'Solo minúsculas, números y guión bajo (3-20 caracteres)';
      case 'fr': return 'Uniquement lettres minuscules, chiffres et tirets bas (3-20 caractères)';
      case 'it': return 'Solo lettere minuscole, numeri e trattini bassi (3-20 caratteri)';
      case 'pt': return 'Apenas letras minúsculas, números e sublinhado (3-20 caracteres)';
      case 'ru': return 'Только строчные буквы, цифры и подчеркивание (3-20 символов)';
      case 'zh': return '仅限小写字母、数字和下划线 (3-20字符)';
      case 'ja': return '英小文字、数字、アンダースコアのみ (3-20文字)';
      case 'ko': return '영문 소문자, 숫자, 밑줄만 사용 가능 (3-20자)';
      case 'hi': return 'केवल छोटे अक्षर, संख्याएं और अंडरस्कोर (3-20 अक्षर)';
      case 'ar': return 'أحرف صغيرة وأرقام وشرطة سفلية فقط (3-20 حرفًا)';
      case 'nl': return 'Alleen kleine letters, cijfers en liggende streepjes (3-20 tekens)';
      case 'el': return 'Μόνο πεζά γράμματα, αριθμοί και κάτω παύλα (3-20 χαρακτήρες)';
      case 'sv': return 'Endast gemener, siffror och understreck (3-20 tecken)';
      case 'pl': return 'Tylko małe litery, cyfry i podkreślenia (3-20 znaków)';
      case 'id': return 'Hanya huruf kecil, angka, dan garis bawah (3-20 karakter)';
      case 'th': return 'เฉพาะตัวพิมพ์เล็ก ตัวเลข และขีดล่างเท่านั้น (3-20 ตัวอักษร)';
      case 'vi': return 'Chỉ chữ thường, số và dấu gạch dưới (3-20 ký tự)';
      case 'en':
      default: return 'Only lowercase letters, numbers, and underscore (3-20 chars)';
    }
  }

  static String getTravelStatus(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Anlık Seyahat Durumu';
      case 'de': return 'Aktueller Reisestatus';
      case 'es': return 'Estado de Viaje';
      case 'fr': return 'Statut de voyage';
      case 'it': return 'Stato di viaggio';
      case 'pt': return 'Status de Viagem';
      case 'ru': return 'Статус путешествия';
      case 'zh': return '当前旅行状态';
      case 'ja': return '現在の旅行ステータス';
      case 'ko': return '현재 여행 상태';
      case 'hi': return 'वर्तमान यात्रा स्थिति';
      case 'ar': return 'حالة السفر الحالية';
      case 'nl': return 'Huidige reisstatus';
      case 'el': return 'Τρέχουσα ταξιδιωτική κατάσταση';
      case 'sv': return 'Aktuell resestatus';
      case 'pl': return 'Aktualny status podróży';
      case 'id': return 'Status Perjalanan Saat Ini';
      case 'th': return 'สถานะการเดินทางปัจจุบัน';
      case 'vi': return 'Trạng thái du lịch hiện tại';
      case 'en':
      default: return 'Travel Status';
    }
  }

  static String getTravelStatusHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Örn: Roma için bavul topluyor 🧳';
      case 'de': return 'Z. B.: Koffer packen für Rom 🧳';
      case 'es': return 'Ej.: Preparando maleta para Roma 🧳';
      case 'fr': return 'Ex : En train de faire les bagages 🧳';
      case 'it': return 'Es.: Facendo i bagagli per Roma 🧳';
      case 'pt': return 'Ex.: Arrumando as malas para Roma 🧳';
      case 'ru': return 'Напр.: Собираю чемодан в Рим 🧳';
      case 'zh': return '例如：正在收拾去罗马的行李 🧳';
      case 'ja': return '例: ローマ行きの荷造り中 🧳';
      case 'ko': return '예: 로마 여행 짐 싸는 중 🧳';
      case 'hi': return 'उदा: रोम के लिए बैग पैक कर रहे हैं 🧳';
      case 'ar': return 'مثال: أحزم الأمتعة لروما 🧳';
      case 'nl': return 'Bijv.: Koffer inpakken voor Rome 🧳';
      case 'el': return 'Π.χ.: Ετοιμάζω βαλίτσες για Ρώμη 🧳';
      case 'sv': return 'T.ex.: Packar resväskan för Rom 🧳';
      case 'pl': return 'Np.: Pakuję walizkę do Rzymu 🧳';
      case 'id': return 'Contoh: Sedang berkemas untuk ke Roma 🧳';
      case 'th': return 'เช่น: กำลังจัดกระเป๋าไปโรม 🧳';
      case 'vi': return 'Ví dụ: Đang chuẩn bị hành lý đi Rome 🧳';
      case 'en':
      default: return 'E.g.: Packing for Rome 🧳';
    }
  }

  static String getTravelStyles(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat Tarzım';
      case 'de': return 'Mein Reisestil';
      case 'es': return 'Mi Estilo de Viaje';
      case 'fr': return 'Mon style de voyage';
      case 'it': return 'Il mio stile di viaggio';
      case 'pt': return 'Meu Estilo de Viagem';
      case 'ru': return 'Мой стиль путешествий';
      case 'zh': return '我的旅行风格';
      case 'ja': return '旅行スタイル';
      case 'ko': return '내 여행 스타일';
      case 'hi': return 'मेरी यात्रा शैली';
      case 'ar': return 'أسلوب سفري';
      case 'nl': return 'Mijn reisstijl';
      case 'el': return 'Το ταξιδιωτικό μου στιλ';
      case 'sv': return 'Min resestil';
      case 'pl': return 'Mój styl podróżowania';
      case 'id': return 'Gaya Perjalanan Saya';
      case 'th': return 'สไตล์การเดินทางของฉัน';
      case 'vi': return 'Phong cách du lịch của tôi';
      case 'en':
      default: return 'Travel Style';
    }
  }

  static String getTravelStylesSubtitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Sizi en iyi tanımlayan en fazla 3 tarz seçin';
      case 'de': return 'Wähle bis zu 3 Stile, die dich am besten beschreiben';
      case 'es': return 'Elige hasta 3 estilos que mejor te describan';
      case 'fr': return "Choisissez jusqu'à 3 styles qui vous correspondent";
      case 'it': return 'Scegli fino a 3 stili che ti descrivono al meglio';
      case 'pt': return 'Escolha até 3 estilos que melhor descrevem você';
      case 'ru': return 'Выберите до 3 стилей, которые лучше всего вас описывают';
      case 'zh': return '选择最多3个最能代表您的旅行风格';
      case 'ja': return 'あなたに最も当てはまるスタイルを3つまで選択してください';
      case 'ko': return '자신을 가장 잘 나타내는 스타일을 최대 3개 선택하세요';
      case 'hi': return 'अधिकतम 3 शैलियों का चयन करें जो आपका सबसे अच्छा वर्णन करती हैं';
      case 'ar': return 'اختر ما يصل إلى 3 أساليب تصفك بأفضل شكل';
      case 'nl': return 'Kies maximaal 3 stijlen die jou het best omschrijven';
      case 'el': return 'Επιλέξτε έως 3 στιλ που σας ταιριάζουν καλύτερα';
      case 'sv': return 'Välj upp till 3 stilar som bäst beskriver dig';
      case 'pl': return 'Wybierz do 3 stylów najlepiej opisujących Twój sposób podróżowania';
      case 'id': return 'Pilih hingga 3 gaya yang paling menggambarkan Anda';
      case 'th': return 'เลือกได้สูงสุด 3 สไตล์ที่อธิบายความเป็นคุณได้ดีที่สุด';
      case 'vi': return 'Chọn tối đa 3 phong cách mô tả đúng nhất về bạn';
      case 'en':
      default: return 'Select up to 3 tags that describe your travel style';
    }
  }

  static String getBadgesAndAchievements(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat Başarıları & Rozetler';
      case 'de': return 'Reise-Erfolge & Abzeichen';
      case 'es': return 'Logros y Medallas de Viaje';
      case 'fr': return 'Succès & Badges de Voyage';
      case 'it': return 'Traguardi e Distintivi di Viaggio';
      case 'pt': return 'Conquistas e Emblemas de Viagem';
      case 'ru': return 'Достижения и значки';
      case 'zh': return '旅行成就与徽章';
      case 'ja': return '旅行の実績とバッジ';
      case 'ko': return '여행 업적 및 뱃지';
      case 'ar': return 'إنجازات وأوسمة السفر';
      case 'hi': return 'यात्रा उपलब्धियां और बैज';
      case 'nl': return 'Reisprestaties & Badges';
      case 'el': return 'Επιτεύγματα & Σήματα Ταξιδιού';
      case 'sv': return 'Reseprestationer & Märken';
      case 'pl': return 'Osiągnięcia i Odznaki Podróżne';
      case 'id': return 'Prestasi & Lencana Perjalanan';
      case 'th': return 'ความสำเร็จและเหรียญตราการเดินทาง';
      case 'vi': return 'Thành Tích & Huy Hiệu Du Lịch';
      case 'en':
      default: return 'Travel Badges & Achievements';
    }
  }

  static String getViewAll(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tümünü Göster';
      case 'de': return 'Alle anzeigen';
      case 'es': return 'Ver todo';
      case 'fr': return 'Tout afficher';
      case 'it': return 'Mostra tutto';
      case 'pt': return 'Ver tudo';
      case 'ru': return 'Показать все';
      case 'zh': return '查看全部';
      case 'ja': return 'すべて表示';
      case 'ko': return '모두 보기';
      case 'ar': return 'عرض الكل';
      case 'hi': return 'सभी देखें';
      case 'nl': return 'Alles weergeven';
      case 'el': return 'Προβολή όλων';
      case 'sv': return 'Visa alla';
      case 'pl': return 'Zobacz wszystko';
      case 'id': return 'Lihat Semua';
      case 'th': return 'ดูทั้งหมด';
      case 'vi': return 'Xem tất cả';
      case 'en':
      default: return 'View All';
    }
  }

  static String getAllBadges(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tüm Rozetler & Başarılar';
      case 'de': return 'Alle Abzeichen & Erfolge';
      case 'es': return 'Todas las Insignias y Logros';
      case 'fr': return 'Tous les Badges et Réussites';
      case 'it': return 'Tutti i Distintivi e Obiettivi';
      case 'pt': return 'Todos os Emblemas e Conquistas';
      case 'ru': return 'Все значки и достижения';
      case 'zh': return '所有徽章与成就';
      case 'ja': return 'すべてのバッジと実績';
      case 'ko': return '모든 배지 및 업적';
      case 'ar': return 'جميع الشارات والإنجازات';
      case 'hi': return 'सभी बैज और उपलब्धियां';
      case 'nl': return 'Alle Badges en Prestaties';
      case 'el': return 'Όλα τα Σήματα και Επιτεύγματα';
      case 'sv': return 'Alla Märken & Prestationer';
      case 'pl': return 'Wszystkie Odznaki i Osiągnięcia';
      case 'id': return 'Semua Lencana & Prestasi';
      case 'th': return 'เหรียญตราและความสำเร็จทั้งหมด';
      case 'vi': return 'Tất Cả Huy Hiệu & Thành Tích';
      case 'en':
      default: return 'All Badges & Achievements';
    }
  }

  static String getAllTab(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tümü';
      case 'de': return 'Alle';
      case 'es': return 'Todos';
      case 'fr': return 'Tous';
      case 'it': return 'Tutti';
      case 'pt': return 'Todos';
      case 'ru': return 'Все';
      case 'zh': return '全部';
      case 'ja': return 'すべて';
      case 'ko': return '전체';
      case 'ar': return 'الكل';
      case 'hi': return 'सभी';
      case 'nl': return 'Alles';
      case 'el': return 'Όλα';
      case 'sv': return 'Alla';
      case 'pl': return 'Wszystkie';
      case 'id': return 'Semua';
      case 'th': return 'ทั้งหมด';
      case 'vi': return 'Tất cả';
      case 'en':
      default: return 'All';
    }
  }

  static String getEarnedTab(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kazanılanlar';
      case 'de': return 'Freigeschaltet';
      case 'es': return 'Desbloqueadas';
      case 'fr': return 'Débloqués';
      case 'it': return 'Sbloccati';
      case 'pt': return 'Desbloqueados';
      case 'ru': return 'Полученные';
      case 'zh': return '已解锁';
      case 'ja': return '獲得済み';
      case 'ko': return '획득한 배지';
      case 'ar': return 'المفتوحة';
      case 'hi': return 'अनलॉक किए गए';
      case 'nl': return 'Ontgrendeld';
      case 'el': return 'Ξεκλείδωτα';
      case 'sv': return 'Upplåsta';
      case 'pl': return 'Odblokowane';
      case 'id': return 'Terbuka';
      case 'th': return 'ปลดล็อกแล้ว';
      case 'vi': return 'Đã mở khóa';
      case 'en':
      default: return 'Unlocked';
    }
  }

  static String getLockedTab(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kilitli';
      case 'de': return 'Gesperrt';
      case 'es': return 'Bloqueadas';
      case 'fr': return 'Verrouillés';
      case 'it': return 'Bloccati';
      case 'pt': return 'Bloqueados';
      case 'ru': return 'Заблокированные';
      case 'zh': return '未解锁';
      case 'ja': return '未獲得';
      case 'ko': return '잠김';
      case 'ar': return 'مغلقة';
      case 'hi': return 'लॉक';
      case 'nl': return 'Vergrendeld';
      case 'el': return 'Κλειδωμένα';
      case 'sv': return 'Låsta';
      case 'pl': return 'Zablokowane';
      case 'id': return 'Terkunci';
      case 'th': return 'ยังล็อกอยู่';
      case 'vi': return 'Đang khóa';
      case 'en':
      default: return 'Locked';
    }
  }

  static String getTapBadgeHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Detayları görmek için rozete dokunun';
      case 'de': return 'Tippe auf ein Abzeichen für Details';
      case 'es': return 'Toca una insignia para ver detalles';
      case 'fr': return 'Appuyez sur un badge pour voir les détails';
      case 'it': return 'Tocca un distintivo per i dettagli';
      case 'pt': return 'Toque em um emblema para ver detalhes';
      case 'ru': return 'Нажмите на значок для подробностей';
      case 'zh': return '点击徽章查看详情';
      case 'ja': return 'バッジをタップして詳細を表示';
      case 'ko': return '상세 정보를 보려면 배지를 탭하세요';
      case 'ar': return 'اضغط على الشارة لعرض التفاصيل';
      case 'hi': return 'विवरण देखने के लिए बैज पर टैप करें';
      case 'nl': return 'Tik op een badge voor details';
      case 'el': return 'Πατήστε ένα σήμα για λεπτομέρειες';
      case 'sv': return 'Tryck på ett märke för detaljer';
      case 'pl': return 'Dotknij odznaki, aby zobaczyć szczegóły';
      case 'id': return 'Ketuk lencana untuk melihat detail';
      case 'th': return 'แตะเหรียญตราเพื่อดูรายละเอียด';
      case 'vi': return 'Nhấn vào huy hiệu để xem chi tiết';
      case 'en':
      default: return 'Tap a badge to view details';
    }
  }

  static String getBadgesUnlockedSummary(String lang, int unlocked, int total) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$unlocked / $total Rozet Açıldı';
      case 'de': return '$unlocked / $total Abzeichen freigeschaltet';
      case 'es': return '$unlocked / $total insignias desbloqueadas';
      case 'fr': return '$unlocked / $total badges débloqués';
      case 'it': return '$unlocked / $total distintivi sbloccati';
      case 'pt': return '$unlocked / $total emblemas desbloqueados';
      case 'ru': return '$unlocked из $total значков открыто';
      case 'zh': return '已解锁 $unlocked / $total 个徽章';
      case 'ja': return '$unlocked / $total バッジ獲得';
      case 'ko': return '$unlocked / $total 배지 획득';
      case 'ar': return 'تم فتح $unlocked من أصل $total شارة';
      case 'hi': return '$unlocked / $total बैज अनलॉक';
      case 'nl': return '$unlocked / $total badges ontgrendeld';
      case 'el': return '$unlocked / $total σήματα ξεκλειδώθηκαν';
      case 'sv': return '$unlocked / $total märken upplåsta';
      case 'pl': return 'Odblokowano $unlocked z $total odznak';
      case 'id': return '$unlocked / $total lencana terbuka';
      case 'th': return 'ปลดล็อกแล้ว $unlocked / $total เหรียญ';
      case 'vi': return 'Đã mở khóa $unlocked / $total huy hiệu';
      case 'en':
      default: return '$unlocked / $total Badges Unlocked';
    }
  }

  static String getProgress(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'İlerleme';
      case 'de': return 'Fortschritt';
      case 'es': return 'Progreso';
      case 'fr': return 'Progression';
      case 'it': return 'Progresso';
      case 'pt': return 'Progresso';
      case 'ru': return 'Прогресс';
      case 'zh': return '进度';
      case 'ja': return '進捗';
      case 'ko': return '진행도';
      case 'ar': return 'التقدم';
      case 'hi': return 'प्रगति';
      case 'nl': return 'Voortgang';
      case 'el': return 'Πρόοδος';
      case 'sv': return 'Framsteg';
      case 'pl': return 'Postęp';
      case 'id': return 'Kemajuan';
      case 'th': return 'ความคืบหน้า';
      case 'vi': return 'Tiến độ';
      case 'en':
      default: return 'Progress';
    }
  }

  static String getRequirement(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Gereksinim';
      case 'de': return 'Anforderung';
      case 'es': return 'Requisito';
      case 'fr': return 'Condition';
      case 'it': return 'Requisito';
      case 'pt': return 'Requisito';
      case 'ru': return 'Требование';
      case 'zh': return '获取要求';
      case 'ja': return '獲得条件';
      case 'ko': return '달성 조건';
      case 'ar': return 'المتطلب';
      case 'hi': return 'आवश्यकता';
      case 'nl': return 'Vereiste';
      case 'el': return 'Απαίτηση';
      case 'sv': return 'Krav';
      case 'pl': return 'Wymaganie';
      case 'id': return 'Persyaratan';
      case 'th': return 'เงื่อนไข';
      case 'vi': return 'Yêu cầu';
      case 'en':
      default: return 'Requirement';
    }
  }

  static String getLocked(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kilitli';
      case 'de': return 'Gesperrt';
      case 'es': return 'Bloqueado';
      case 'fr': return 'Verrouillé';
      case 'it': return 'Bloccato';
      case 'pt': return 'Bloqueado';
      case 'ru': return 'Заблокировано';
      case 'zh': return '未解锁';
      case 'ja': return '未獲得';
      case 'ko': return '잠김';
      case 'ar': return 'مغلق';
      case 'hi': return 'लॉक';
      case 'nl': return 'Vergrendeld';
      case 'el': return 'Κλειδωμένο';
      case 'sv': return 'Låst';
      case 'pl': return 'Zablokowane';
      case 'id': return 'Terkunci';
      case 'th': return 'ล็อก';
      case 'vi': return 'Đã khóa';
      case 'en':
      default: return 'Locked';
    }
  }

  static String getUnlocked(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kazanıldı ✨';
      case 'de': return 'Freigeschaltet ✨';
      case 'es': return 'Desbloqueado ✨';
      case 'fr': return 'Débloqué ✨';
      case 'it': return 'Sbloccato ✨';
      case 'pt': return 'Desbloqueado ✨';
      case 'ru': return 'Получено ✨';
      case 'zh': return '已解锁 ✨';
      case 'ja': return '獲得済み ✨';
      case 'ko': return '획득 완료 ✨';
      case 'ar': return 'تم الفتح ✨';
      case 'hi': return 'अनलॉक ✨';
      case 'nl': return 'Ontgrendeld ✨';
      case 'el': return 'Ξεκλειδώθηκε ✨';
      case 'sv': return 'Upplåst ✨';
      case 'pl': return 'Odblokowane ✨';
      case 'id': return 'Terbuka ✨';
      case 'th': return 'ปลดล็อกแล้ว ✨';
      case 'vi': return 'Đã mở khóa ✨';
      case 'en':
      default: return 'Unlocked ✨';
    }
  }
}

