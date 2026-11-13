/// Native 20-language localization for Day-by-Day Itinerary & Activity Planning
class ItineraryLocalization {
  ItineraryLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String getItineraryTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Gün Gün Plan';
      case 'de': return 'Tagesplaner';
      case 'es': return 'Itinerario Diario';
      case 'fr': return 'Itinéraire';
      case 'it': return 'Itinerario';
      case 'pt': return 'Roteiro Diário';
      case 'ru': return 'План по дням';
      case 'zh': return '每日行程';
      case 'ja': return '日別旅程';
      case 'ko': return '일정표';
      case 'hi': return 'दैनिक यात्रा कार्यक्रम';
      case 'ar': return 'جدول الرحلة اليومي';
      case 'nl': return 'Dagplanning';
      case 'el': return 'Ημερήσιο Πρόγραμμα';
      case 'sv': return 'Dagsplanering';
      case 'pl': return 'Plan Dnia';
      case 'id': return 'Rencana Harian';
      case 'th': return 'แผนการเดินทาง';
      case 'vi': return 'Lịch trình hàng ngày';
      case 'en':
      default: return 'Day-by-Day Itinerary';
    }
  }

  static String getDay(String lang, int dayNumber) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$dayNumber. Gün';
      case 'de': return 'Tag $dayNumber';
      case 'es': return 'Día $dayNumber';
      case 'fr': return 'Jour $dayNumber';
      case 'it': return 'Giorno $dayNumber';
      case 'pt': return 'Dia $dayNumber';
      case 'ru': return 'День $dayNumber';
      case 'zh': return '第 $dayNumber 天';
      case 'ja': return '$dayNumber 日目';
      case 'ko': return '$dayNumber 일차';
      case 'hi': return 'दिन $dayNumber';
      case 'ar': return 'اليوم $dayNumber';
      case 'nl': return 'Dag $dayNumber';
      case 'el': return 'Ημέρα $dayNumber';
      case 'sv': return 'Dag $dayNumber';
      case 'pl': return 'Dzień $dayNumber';
      case 'id': return 'Hari ke-$dayNumber';
      case 'th': return 'วันที่ $dayNumber';
      case 'vi': return 'Ngày $dayNumber';
      case 'en':
      default: return 'Day $dayNumber';
    }
  }

  static String getAddActivity(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Aktivite Ekle';
      case 'de': return 'Aktivität hinzufügen';
      case 'es': return 'Añadir actividad';
      case 'fr': return 'Ajouter une activité';
      case 'it': return 'Aggiungi attività';
      case 'pt': return 'Adicionar atividade';
      case 'ru': return 'Добавить событие';
      case 'zh': return '添加活动';
      case 'ja': return 'アクティビティを追加';
      case 'ko': return '활동 추가';
      case 'hi': return 'गतिविधि जोड़ें';
      case 'ar': return 'إضافة نشاط';
      case 'nl': return 'Activiteit toevoegen';
      case 'el': return 'Προσθήκη δραστηριότητας';
      case 'sv': return 'Lägg till aktivitet';
      case 'pl': return 'Dodaj aktywność';
      case 'id': return 'Tambah Aktivitas';
      case 'th': return 'เพิ่มกิจกรรม';
      case 'vi': return 'Thêm hoạt động';
      case 'en':
      default: return 'Add Activity';
    }
  }

  static String getEditActivity(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Aktiviteyi Düzenle';
      case 'de': return 'Aktivität bearbeiten';
      case 'es': return 'Editar actividad';
      case 'fr': return 'Modifier l\'activité';
      case 'it': return 'Modifica attività';
      case 'pt': return 'Editar atividade';
      case 'ru': return 'Редактировать событие';
      case 'zh': return '编辑活动';
      case 'ja': return 'アクティビティを編集';
      case 'ko': return '활동 편집';
      case 'hi': return 'गतिविधि संपादित करें';
      case 'ar': return 'تعديل النشاط';
      case 'nl': return 'Activiteit bewerken';
      case 'el': return 'Επεξεργασία δραστηριότητας';
      case 'sv': return 'Redigera aktivitet';
      case 'pl': return 'Edytuj aktywność';
      case 'id': return 'Edit Aktivitas';
      case 'th': return 'แก้ไขกิจกรรม';
      case 'vi': return 'Chỉnh sửa hoạt động';
      case 'en':
      default: return 'Edit Activity';
    }
  }

  static String getActivityTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Aktivite Başlığı';
      case 'de': return 'Titel der Aktivität';
      case 'es': return 'Título de la actividad';
      case 'fr': return 'Titre de l\'activité';
      case 'it': return 'Titolo dell\'attività';
      case 'pt': return 'Título da atividade';
      case 'ru': return 'Название события';
      case 'zh': return '活动标题';
      case 'ja': return 'アクティビティ名';
      case 'ko': return '활동 제목';
      case 'hi': return 'गतिविधि का शीर्षक';
      case 'ar': return 'عنوان النشاط';
      case 'nl': return 'Titel van activiteit';
      case 'el': return 'Τίτλος δραστηριότητας';
      case 'sv': return 'Aktivitetsnamn';
      case 'pl': return 'Tytuł aktywności';
      case 'id': return 'Judul Aktivitas';
      case 'th': return 'ชื่อกิจกรรม';
      case 'vi': return 'Tên hoạt động';
      case 'en':
      default: return 'Activity Title';
    }
  }

  static String getTime(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Saat';
      case 'de': return 'Uhrzeit';
      case 'es': return 'Hora';
      case 'fr': return 'Heure';
      case 'it': return 'Ora';
      case 'pt': return 'Hora';
      case 'ru': return 'Время';
      case 'zh': return '时间';
      case 'ja': return '時間';
      case 'ko': return '시간';
      case 'hi': return 'समय';
      case 'ar': return 'الوقت';
      case 'nl': return 'Tijd';
      case 'el': return 'Ώρα';
      case 'sv': return 'Tid';
      case 'pl': return 'Godzina';
      case 'id': return 'Waktu';
      case 'th': return 'เวลา';
      case 'vi': return 'Thời gian';
      case 'en':
      default: return 'Time';
    }
  }

  static String getLocation(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Konum / Mekan';
      case 'de': return 'Ort / Treffpunkt';
      case 'es': return 'Lugar / Ubicación';
      case 'fr': return 'Lieu / Emplacement';
      case 'it': return 'Luogo';
      case 'pt': return 'Localização';
      case 'ru': return 'Место / Локация';
      case 'zh': return '地点 / 位置';
      case 'ja': return '場所・スポット';
      case 'ko': return '장소 / 위치';
      case 'hi': return 'स्थान / पता';
      case 'ar': return 'الموقع';
      case 'nl': return 'Locatie';
      case 'el': return 'Τοποθεσία';
      case 'sv': return 'Plats';
      case 'pl': return 'Lokalizacja';
      case 'id': return 'Lokasi';
      case 'th': return 'สถานที่';
      case 'vi': return 'Địa điểm';
      case 'en':
      default: return 'Location / Venue';
    }
  }

  static String getCategory(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kategori';
      case 'de': return 'Kategorie';
      case 'es': return 'Categoría';
      case 'fr': return 'Catégorie';
      case 'it': return 'Categoria';
      case 'pt': return 'Categoria';
      case 'ru': return 'Категория';
      case 'zh': return '分类';
      case 'ja': return 'カテゴリー';
      case 'ko': return '카테고리';
      case 'hi': return 'श्रेणी';
      case 'ar': return 'الفئة';
      case 'nl': return 'Categorie';
      case 'el': return 'Κατηγορία';
      case 'sv': return 'Kategori';
      case 'pl': return 'Kategoria';
      case 'id': return 'Kategori';
      case 'th': return 'หมวดหมู่';
      case 'vi': return 'Danh mục';
      case 'en':
      default: return 'Category';
    }
  }

  static String getNotes(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Notlar & Açıklama';
      case 'de': return 'Notizen & Beschreibung';
      case 'es': return 'Notas y descripción';
      case 'fr': return 'Notes et détails';
      case 'it': return 'Note e dettagli';
      case 'pt': return 'Notas e descrição';
      case 'ru': return 'Заметки и детали';
      case 'zh': return '备注与说明';
      case 'ja': return 'メモ・詳細';
      case 'ko': return '메모 및 설명';
      case 'hi': return 'विवरण एवं नोट्स';
      case 'ar': return 'ملاحظات وتفاصيل';
      case 'nl': return 'Notities & details';
      case 'el': return 'Σημειώσεις';
      case 'sv': return 'Anteckningar';
      case 'pl': return 'Notatki i opis';
      case 'id': return 'Catatan & Deskripsi';
      case 'th': return 'บันทึกและคำอธิบาย';
      case 'vi': return 'Ghi chú & Mô tả';
      case 'en':
      default: return 'Notes & Details';
    }
  }

  static String getSave(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Kaydet';
      case 'de': return 'Speichern';
      case 'es': return 'Guardar';
      case 'fr': return 'Enregistrer';
      case 'it': return 'Salva';
      case 'pt': return 'Salvar';
      case 'ru': return 'Сохранить';
      case 'zh': return '保存';
      case 'ja': return '保存';
      case 'ko': return '저장';
      case 'hi': return 'सहेजें';
      case 'ar': return 'حفظ';
      case 'nl': return 'Opslaan';
      case 'el': return 'Αποθήκευση';
      case 'sv': return 'Spara';
      case 'pl': return 'Zapisz';
      case 'id': return 'Simpan';
      case 'th': return 'บันทึก';
      case 'vi': return 'Lưu';
      case 'en':
      default: return 'Save';
    }
  }

  static String getDelete(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Sil';
      case 'de': return 'Löschen';
      case 'es': return 'Eliminar';
      case 'fr': return 'Supprimer';
      case 'it': return 'Elimina';
      case 'pt': return 'Excluir';
      case 'ru': return 'Удалить';
      case 'zh': return '删除';
      case 'ja': return '削除';
      case 'ko': return '삭제';
      case 'hi': return 'हटाएं';
      case 'ar': return 'حذف';
      case 'nl': return 'Verwijderen';
      case 'el': return 'Διαγραφή';
      case 'sv': return 'Ta bort';
      case 'pl': return 'Usuń';
      case 'id': return 'Hapus';
      case 'th': return 'ลบ';
      case 'vi': return 'Xóa';
      case 'en':
      default: return 'Delete';
    }
  }

  static String getNoActivities(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bu gün için henüz bir plan eklenmedi';
      case 'de': return 'Noch keine Aktivitäten für diesen Tag geplant';
      case 'es': return 'No hay actividades planificadas para este día';
      case 'fr': return 'Aucune activité planifiée pour ce jour';
      case 'it': return 'Nessuna attività programmata per oggi';
      case 'pt': return 'Nenhuma atividade planejada para este dia';
      case 'ru': return 'На этот день пока нет запланированных событий';
      case 'zh': return '此日尚无计划活动';
      case 'ja': return 'この日の予定はまだありません';
      case 'ko': return '이 날에 계획된 일정이 없습니다';
      case 'hi': return 'इस दिन के लिए कोई योजना नहीं जोड़ी गई';
      case 'ar': return 'لم تتم إضافة أي خطة لهذا اليوم بعد';
      case 'nl': return 'Nog geen activiteiten gepland voor deze dag';
      case 'el': return 'Δεν έχουν προγραμματιστεί δραστηριότητες για αυτήν την ημέρα';
      case 'sv': return 'Inga aktiviteter planerade för den här dagen';
      case 'pl': return 'Brak zaplanowanych aktywności na ten dzień';
      case 'id': return 'Belum ada aktivitas yang direncanakan untuk hari ini';
      case 'th': return 'ยังไม่มีกิจกรรมที่วางแผนไว้สำหรับวันนี้';
      case 'vi': return 'Chưa có hoạt động nào được lên kế hoạch cho ngày này';
      case 'en':
      default: return 'No activities planned yet for this day';
    }
  }

  static String getNoActivitiesHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Aşağıdaki butona dokunarak ilk planınızı oluşturun.';
      case 'de': return 'Tippen Sie unten, um Ihre erste Aktivität zu erstellen.';
      case 'es': return 'Toca el botón para añadir tu primera actividad.';
      case 'fr': return 'Appuyez ci-dessous pour créer votre première étape.';
      case 'it': return 'Tocca il pulsante in basso per iniziare a pianificare.';
      case 'pt': return 'Toque no botão para adicionar sua primeira atividade.';
      case 'ru': return 'Нажмите кнопку ниже, чтобы добавить первую активность.';
      case 'zh': return '点击下方按钮添加您的第一个行程安排。';
      case 'ja': return '下のボタンをタップして最初の予定を追加しましょう。';
      case 'ko': return '아래 버튼을 눌러 첫 번째 일정을 추가해보세요.';
      case 'hi': return 'पहली गतिविधि जोड़ने के लिए नीचे दिए गए बटन पर टैप करें।';
      case 'ar': return 'اضغط على الزر أدناه لإضافة أول خطة لك.';
      case 'nl': return 'Tik op de knop hieronder om je eerste activiteit toe te voegen.';
      case 'el': return 'Πατήστε παρακάτω για να προσθέσετε την πρώτη δραστηριότητα.';
      case 'sv': return 'Tryck nedan för att lägga till din första aktivitet.';
      case 'pl': return 'Dotknij poniższego przycisku, aby dodać pierwszą aktywność.';
      case 'id': return 'Ketuk tombol di bawah untuk membuat aktivitas pertama.';
      case 'th': return 'แตะปุ่มด้านล่างเพื่อเพิ่มกิจกรรมแรกของคุณ';
      case 'vi': return 'Chạm vào nút bên dưới để tạo hoạt động đầu tiên.';
      case 'en':
      default: return 'Tap the button below to add your first activity.';
    }
  }

  static String getCategoryLabel(String category, String lang) {
    final clean = _cleanLang(lang);
    switch (category.toLowerCase()) {
      case 'food':
        return clean == 'tr' ? 'Yeme & İçme' : 'Food & Dining';
      case 'transit':
        return clean == 'tr' ? 'Ulaşım' : 'Transit & Travel';
      case 'activity':
        return clean == 'tr' ? 'Aktivite & Doğa' : 'Activity & Adventure';
      case 'lodging':
        return clean == 'tr' ? 'Konaklama' : 'Lodging & Hotel';
      case 'shopping':
        return clean == 'tr' ? 'Alışveriş' : 'Shopping';
      case 'sightseeing':
      default:
        return clean == 'tr' ? 'Gezilecek Yer' : 'Sightseeing';
    }
  }
}

