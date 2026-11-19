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

  static String getRequired(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Zorunlu';
      case 'de': return 'Erforderlich';
      case 'es': return 'Obligatorio';
      case 'fr': return 'Obligatoire';
      case 'it': return 'Obbligatorio';
      case 'pt': return 'Obrigatório';
      case 'ru': return 'Обязательно';
      case 'zh': return '必填';
      case 'ja': return '必須';
      case 'ko': return '필수';
      case 'hi': return 'आवश्यक';
      case 'ar': return 'مطلوب';
      case 'nl': return 'Verplicht';
      case 'el': return 'Υποχρεωτικό';
      case 'sv': return 'Obligatorisk';
      case 'pl': return 'Wymagane';
      case 'id': return 'Wajib';
      case 'th': return 'จำเป็น';
      case 'vi': return 'Bắt buộc';
      case 'en':
      default: return 'Required';
    }
  }

  static String getTitleRequired(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Lütfen aktivite başlığı giriniz';
      case 'de': return 'Bitte Aktivitätstitel eingeben';
      case 'es': return 'Por favor ingrese el título de la actividad';
      case 'fr': return 'Veuillez saisir un titre d\'activité';
      case 'it': return 'Inserisci un titolo per l\'attività';
      case 'pt': return 'Por favor insira o título da atividade';
      case 'ru': return 'Пожалуйста, введите название активности';
      case 'zh': return '请输入活动标题';
      case 'ja': return 'アクティビティ名を入力してください';
      case 'ko': return '활동 제목을 입력해주세요';
      case 'hi': return 'कृपया गतिविधि का शीर्षक दर्ज करें';
      case 'ar': return 'يرجى إدخال عنوان النشاط';
      case 'nl': return 'Voer een activiteitstitel in';
      case 'el': return 'Παρακαλώ εισάγετε τίτλο δραστηριότητας';
      case 'sv': return 'Ange aktivitetstitel';
      case 'pl': return 'Wprowadź tytuł aktywności';
      case 'id': return 'Silakan masukkan judul aktivitas';
      case 'th': return 'กรุณาระบุชื่อกิจกรรม';
      case 'vi': return 'Vui lòng nhập tiêu đề hoạt động';
      case 'en':
      default: return 'Please enter an activity title';
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

  static String getStartTime(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Başlangıç / Gidiş';
      case 'de': return 'Startzeit';
      case 'es': return 'Inicio';
      case 'fr': return 'Début';
      case 'it': return 'Inizio';
      case 'pt': return 'Início';
      case 'ru': return 'Начало';
      case 'zh': return '开始时间';
      case 'ja': return '開始';
      case 'ko': return '시작';
      case 'hi': return 'प्रारंभ';
      case 'ar': return 'البدء';
      case 'nl': return 'Start';
      case 'el': return 'Έναρξη';
      case 'sv': return 'Start';
      case 'pl': return 'Początek';
      case 'id': return 'Mulai';
      case 'th': return 'เวลาเริ่ม';
      case 'vi': return 'Bắt đầu';
      case 'en':
      default: return 'Start Time';
    }
  }

  static String getEndTime(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bitiş / Dönüş';
      case 'de': return 'Ende / Rückkehr';
      case 'es': return 'Fin / Regreso';
      case 'fr': return 'Fin / Retour';
      case 'it': return 'Fine / Ritorno';
      case 'pt': return 'Fim / Retorno';
      case 'ru': return 'Окончание';
      case 'zh': return '结束 / 返程';
      case 'ja': return '終了・帰着';
      case 'ko': return '종료 / 복귀';
      case 'hi': return 'समाप्ति';
      case 'ar': return 'الانتهاء / العودة';
      case 'nl': return 'Einde / Terugkeer';
      case 'el': return 'Λήξη / Επιστροφή';
      case 'sv': return 'Slut / Återresa';
      case 'pl': return 'Koniec / Powrót';
      case 'id': return 'Selesai / Pulang';
      case 'th': return 'สิ้นสุด / กลับ';
      case 'vi': return 'Kết thúc / Về';
      case 'en':
      default: return 'End / Return';
    }
  }

  static String getFlexible(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Esnek';
      case 'de': return 'Flexibel';
      case 'es': return 'Flexible';
      case 'fr': return 'Flexible';
      case 'it': return 'Flessibile';
      case 'pt': return 'Flexível';
      case 'ru': return 'Гибко';
      case 'zh': return '灵活';
      case 'ja': return '自由';
      case 'ko': return '자율';
      case 'hi': return 'लचीला';
      case 'ar': return 'مرن';
      case 'nl': return 'Flexibel';
      case 'el': return 'Ευέλικτο';
      case 'sv': return 'Flexibel';
      case 'pl': return 'Elastycznie';
      case 'id': return 'Fleksibel';
      case 'th': return 'ยืดหยุ่น';
      case 'vi': return 'Linh hoạt';
      case 'en':
      default: return 'Flexible';
    }
  }

  static String getOptional(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Opsiyonel';
      case 'de': return 'Optional';
      case 'es': return 'Opcional';
      case 'fr': return 'Optionnel';
      case 'it': return 'Opzionale';
      case 'pt': return 'Opcional';
      case 'ru': return 'Опционально';
      case 'zh': return '可选';
      case 'ja': return '任意';
      case 'ko': return '선택';
      case 'hi': return 'वैकल्पिक';
      case 'ar': return 'اختياري';
      case 'nl': return 'Optioneel';
      case 'el': return 'Προαιρετικό';
      case 'sv': return 'Valfritt';
      case 'pl': return 'Opcjonalnie';
      case 'id': return 'Opsional';
      case 'th': return 'ไม่บังคับ';
      case 'vi': return 'Tùy chọn';
      case 'en':
      default: return 'Optional';
    }
  }

  static String getCost(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Masraf / Bütçe';
      case 'de': return 'Kosten';
      case 'es': return 'Costo';
      case 'fr': return 'Coût';
      case 'it': return 'Costo';
      case 'pt': return 'Custo';
      case 'ru': return 'Стоимость';
      case 'zh': return '费用';
      case 'ja': return '費用';
      case 'ko': return '비용';
      case 'hi': return 'लागत';
      case 'ar': return 'التكلفة';
      case 'nl': return 'Kosten';
      case 'el': return 'Κόστος';
      case 'sv': return 'Kostnad';
      case 'pl': return 'Koszt';
      case 'id': return 'Biaya';
      case 'th': return 'ค่าใช้จ่าย';
      case 'vi': return 'Chi phí';
      case 'en':
      default: return 'Cost / Budget';
    }
  }

  static String getDeleteConfirmTitle(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Aktiviteyi Sil';
      case 'de': return 'Aktivität löschen';
      case 'es': return 'Eliminar actividad';
      case 'fr': return 'Supprimer l\'activité';
      case 'it': return 'Elimina attività';
      case 'pt': return 'Excluir atividade';
      case 'ru': return 'Удалить активность';
      case 'zh': return '删除活动';
      case 'ja': return 'アクティビティを削除';
      case 'ko': return '활동 삭제';
      case 'hi': return 'गतिविधि हटाएं';
      case 'ar': return 'حذف النشاط';
      case 'nl': return 'Activiteit verwijderen';
      case 'el': return 'Διαγραφή δραστηριότητας';
      case 'sv': return 'Ta bort aktivitet';
      case 'pl': return 'Usuń aktywność';
      case 'id': return 'Hapus Aktivitas';
      case 'th': return 'ลบกิจกรรม';
      case 'vi': return 'Xóa hoạt động';
      case 'en':
      default: return 'Delete Activity';
    }
  }

  static String getDeleteConfirmMessage(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bu aktiviteyi silmek istediğinize emin misiniz?';
      case 'de': return 'Möchten Sie diese Aktivität wirklich löschen?';
      case 'es': return '¿Estás seguro de que deseas eliminar esta actividad?';
      case 'fr': return 'Êtes-vous sûr de vouloir supprimer cette activité ?';
      case 'it': return 'Sei sicuro di voler eliminare questa attività?';
      case 'pt': return 'Tem certeza de que deseja excluir esta atividade?';
      case 'ru': return 'Вы уверены, что хотите удалить эту активность?';
      case 'zh': return '您确定要删除此活动吗？';
      case 'ja': return 'このアクティビティを削除してもよろしいですか？';
      case 'ko': return '이 활동을 삭제하시겠습니까?';
      case 'hi': return 'क्या आप वाकई इस गतिविधि को हटाना चाहते हैं?';
      case 'ar': return 'هل أنت متأكد أنك تريد حذف هذا النشاط؟';
      case 'nl': return 'Weet je zeker dat je deze activiteit wilt verwijderen?';
      case 'el': return 'Είστε βέβαιοι ότι θέλετε να διαγράψετε αυτήν τη δραστηριότητα;';
      case 'sv': return 'Är du säker på att du vill ta bort denna aktivitet?';
      case 'pl': return 'Czy na pewno chcesz usunąć tę aktywność?';
      case 'id': return 'Apakah Anda yakin ingin menghapus aktivitas ini?';
      case 'th': return 'คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรมนี้?';
      case 'vi': return 'Bạn có chắc chắn muốn xóa hoạt động này không?';
      case 'en':
      default: return 'Are you sure you want to delete this activity?';
    }
  }

  static String getCancel(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'İptal';
      case 'de': return 'Abbrechen';
      case 'es': return 'Cancelar';
      case 'fr': return 'Annuler';
      case 'it': return 'Annulla';
      case 'pt': return 'Cancelar';
      case 'ru': return 'Отмена';
      case 'zh': return '取消';
      case 'ja': return 'キャンセル';
      case 'ko': return '취소';
      case 'hi': return 'रद्द करें';
      case 'ar': return 'إلغاء';
      case 'nl': return 'Annuleren';
      case 'el': return 'Άκυρο';
      case 'sv': return 'Avbryt';
      case 'pl': return 'Anuluj';
      case 'id': return 'Batal';
      case 'th': return 'ยกเลิก';
      case 'vi': return 'Hủy';
      case 'en':
      default: return 'Cancel';
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
        switch (clean) {
          case 'tr': return 'Yeme & İçme';
          case 'de': return 'Essen & Trinken';
          case 'fr': return 'Restauration & Gastronomie';
          case 'es': return 'Comida y Restaurantes';
          case 'it': return 'Cibo e Ristorazione';
          case 'pt': return 'Alimentação & Gastronomia';
          case 'ru': return 'Еда и напитки';
          case 'zh': return '餐饮美食';
          case 'ja': return '食事・グルメ';
          case 'ko': return '식음료 및 맛집';
          case 'ar': return 'طعام ومشروبات';
          case 'hi': return 'खान-पान';
          case 'nl': return 'Eten & Drinken';
          case 'el': return 'Φαγητό & Ποτό';
          case 'sv': return 'Mat & Dryck';
          case 'pl': return 'Jedzenie i napoje';
          case 'id': return 'Makanan & Kuliner';
          case 'th': return 'อาหารและเครื่องดื่ม';
          case 'vi': return 'Ăn uống & Ẩm thực';
          case 'en':
          default: return 'Food & Dining';
        }
      case 'transit':
        switch (clean) {
          case 'tr': return 'Ulaşım';
          case 'de': return 'Transport & Reisen';
          case 'fr': return 'Transport & Trajet';
          case 'es': return 'Transporte y Tránsito';
          case 'it': return 'Trasporti e Viaggio';
          case 'pt': return 'Transporte & Trânsito';
          case 'ru': return 'Транспорт';
          case 'zh': return '交通出行';
          case 'ja': return '交通・移動';
          case 'ko': return '교통 및 이동';
          case 'ar': return 'المواصلات والتنقل';
          case 'hi': return 'परिवहन और यात्रा';
          case 'nl': return 'Vervoer & Reizen';
          case 'el': return 'Μετακίνηση & Μεταφορές';
          case 'sv': return 'Transport & Resor';
          case 'pl': return 'Transport i dojazd';
          case 'id': return 'Transportasi';
          case 'th': return 'การเดินทางและคมนาคม';
          case 'vi': return 'Giao thông & Di chuyển';
          case 'en':
          default: return 'Transit & Travel';
        }
      case 'activity':
        switch (clean) {
          case 'tr': return 'Aktivite & Doğa';
          case 'de': return 'Aktivität & Natur';
          case 'fr': return 'Activité & Aventure';
          case 'es': return 'Actividad y Aventura';
          case 'it': return 'Attività e Avventura';
          case 'pt': return 'Atividade & Aventura';
          case 'ru': return 'Активности и природа';
          case 'zh': return '户外活动与探险';
          case 'ja': return 'アクティビティ・自然';
          case 'ko': return '액티비티 및 자연';
          case 'ar': return 'أنشطة ومغامرات';
          case 'hi': return 'गतिविधि और रोमांच';
          case 'nl': return 'Activiteit & Natuur';
          case 'el': return 'Δραστηριότητα & Φύση';
          case 'sv': return 'Aktivitet & Natur';
          case 'pl': return 'Aktywność i przygoda';
          case 'id': return 'Aktivitas & Alam';
          case 'th': return 'กิจกรรมและการผจญภัย';
          case 'vi': return 'Hoạt động & Trải nghiệm';
          case 'en':
          default: return 'Activity & Adventure';
        }
      case 'lodging':
        switch (clean) {
          case 'tr': return 'Konaklama';
          case 'de': return 'Unterkunft & Hotel';
          case 'fr': return 'Hébergement & Hôtel';
          case 'es': return 'Alojamiento y Hotel';
          case 'it': return 'Alloggio e Hotel';
          case 'pt': return 'Hospedagem & Hotel';
          case 'ru': return 'Проживание и отель';
          case 'zh': return '住宿酒店';
          case 'ja': return '宿泊・ホテル';
          case 'ko': return '숙소 및 호텔';
          case 'ar': return 'الإقامة والفندق';
          case 'hi': return 'आवास और होटल';
          case 'nl': return 'Accommodatie & Hotel';
          case 'el': return 'Διαμονή & Ξενοδοχείο';
          case 'sv': return 'Boende & Hotell';
          case 'pl': return 'Zakwaterowanie i hotel';
          case 'id': return 'Akomodasi & Hotel';
          case 'th': return 'ที่พักและโรงแรม';
          case 'vi': return 'Lưu trú & Khách sạn';
          case 'en':
          default: return 'Lodging & Hotel';
        }
      case 'shopping':
        switch (clean) {
          case 'tr': return 'Alışveriş';
          case 'de': return 'Einkaufen';
          case 'fr': return 'Shopping';
          case 'es': return 'Compras';
          case 'it': return 'Shopping';
          case 'pt': return 'Compras';
          case 'ru': return 'Шопинг';
          case 'zh': return '购物消费';
          case 'ja': return 'ショッピング';
          case 'ko': return '쇼핑';
          case 'ar': return 'تسوق';
          case 'hi': return 'खरीदारी';
          case 'nl': return 'Winkelen';
          case 'el': return 'Ψώνια';
          case 'sv': return 'Shopping';
          case 'pl': return 'Zakupy';
          case 'id': return 'Belanja';
          case 'th': return 'ช้อปปิ้ง';
          case 'vi': return 'Mua sắm';
          case 'en':
          default: return 'Shopping';
        }
      case 'sightseeing':
      default:
        switch (clean) {
          case 'tr': return 'Gezilecek Yer';
          case 'de': return 'Sehenswürdigkeiten';
          case 'fr': return 'Visites touristiques';
          case 'es': return 'Turismo y Visitas';
          case 'it': return 'Visite e Attrazioni';
          case 'pt': return 'Ponto Turístico';
          case 'ru': return 'Достопримечательности';
          case 'zh': return '观光景点';
          case 'ja': return '観光スポット';
          case 'ko': return '관광 명소';
          case 'ar': return 'معالم سياحية';
          case 'hi': return 'पर्यटन स्थल';
          case 'nl': return 'Bezienswaardigheden';
          case 'el': return 'Αξιοθέατα';
          case 'sv': return 'Sevärdheter';
          case 'pl': return 'Zwiedzanie';
          case 'id': return 'Wisata & Tempat Menarik';
          case 'th': return 'สถานที่ท่องเที่ยว';
          case 'vi': return 'Tham quan & Thắng cảnh';
          case 'en':
          default: return 'Sightseeing';
        }
    }
  }

  static String getActivityTitleHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'örn. Eyfel Kulesi Ziyareti';
      case 'de': return 'z.B. Besuch des Eiffelturms';
      case 'fr': return 'ex. Visite de la Tour Eiffel';
      case 'es': return 'ej. Visita a la Torre Eiffel';
      case 'it': return 'es. Visita alla Torre Eiffel';
      case 'pt': return 'ex: Visita à Torre Eiffel';
      case 'ru': return 'напр. Экскурсия на Эйфелеву башню';
      case 'zh': return '例：参观埃菲尔铁塔';
      case 'ja': return '例：エッフェル塔観光';
      case 'ko': return '예: 에펠탑 방문';
      case 'ar': return 'مثال: زيارة برج إيفل';
      case 'hi': return 'उदा. एफिल टॉवर भ्रमण';
      case 'nl': return 'bijv. Bezoek aan de Eiffeltoren';
      case 'el': return 'π.χ. Επίσκεψη στον Πύργο του Άιφελ';
      case 'sv': return 't.ex. Besök Eiffeltornet';
      case 'pl': return 'np. Wizyta na Wieży Eiffla';
      case 'id': return 'cth. Kunjungan Menara Eiffel';
      case 'th': return 'เช่น ไปเที่ยวหอไอเฟล';
      case 'vi': return 'ví dụ: Tham quan Tháp Eiffel';
      case 'en':
      default: return 'e.g. Visit Eiffel Tower';
    }
  }

  static String getLocationHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Mekan / Adres';
      case 'de': return 'Ort / Adresse';
      case 'fr': return 'Lieu / Adresse';
      case 'es': return 'Lugar / Dirección';
      case 'it': return 'Luogo / Indirizzo';
      case 'pt': return 'Local / Endereço';
      case 'ru': return 'Место / Адрес';
      case 'zh': return '地点 / 地址';
      case 'ja': return '場所 / 住所';
      case 'ko': return '장소 / 주소';
      case 'ar': return 'المكان / العنوان';
      case 'hi': return 'स्थान / पता';
      case 'nl': return 'Locatie / Adres';
      case 'el': return 'Τοποθεσία / Διεύθυνση';
      case 'sv': return 'Plats / Adress';
      case 'pl': return 'Miejsce / Adres';
      case 'id': return 'Lokasi / Alamat';
      case 'th': return 'สถานที่ / ที่อยู่';
      case 'vi': return 'Địa điểm / Địa chỉ';
      case 'en':
      default: return 'Venue / Address';
    }
  }

  static String getCostHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tahmini Tutar (örn. 25)';
      case 'de': return 'Geschätzter Betrag (z.B. 25)';
      case 'fr': return 'Montant estimé (ex. 25)';
      case 'es': return 'Monto estimado (ej. 25)';
      case 'it': return 'Importo stimato (es. 25)';
      case 'pt': return 'Valor estimado (ex: 25)';
      case 'ru': return 'Примерная сумма (напр. 25)';
      case 'zh': return '预估金额（例：25）';
      case 'ja': return '見積金額（例：25）';
      case 'ko': return '예상 금액 (예: 25)';
      case 'ar': return 'المبلغ التقديري (مثال: 25)';
      case 'hi': return 'अनुमानित राशि (उदा. 25)';
      case 'nl': return 'Geschat bedrag (bijv. 25)';
      case 'el': return 'Εκτιμώμενο ποσό (π.χ. 25)';
      case 'sv': return 'Uppskattat belopp (t.ex. 25)';
      case 'pl': return 'Szacowana kwota (np. 25)';
      case 'id': return 'Perkiraan biaya (cth. 25)';
      case 'th': return 'ค่าใช้จ่ายโดยประมาณ (เช่น 25)';
      case 'vi': return 'Chi phí ước tính (ví dụ: 25)';
      case 'en':
      default: return 'Estimated amount (e.g. 25)';
    }
  }

  static String getNotesHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Rezervasyon no, hatırlatma...';
      case 'de': return 'Buchungs-ID, Notizen...';
      case 'fr': return 'N° de réservation, rappel...';
      case 'es': return 'N.º de reserva, recordatorio...';
      case 'it': return 'ID prenotazione, promemoria...';
      case 'pt': return 'Nº da reserva, lembrete...';
      case 'ru': return 'Номер брони, напоминание...';
      case 'zh': return '预订号、备忘提醒...';
      case 'ja': return '予約番号、メモ...';
      case 'ko': return '예약 번호, 메모...';
      case 'ar': return 'رقم الحجز، تذكير...';
      case 'hi': return 'बुकिंग आईडी, रिमाइंडर...';
      case 'nl': return 'Boekingsnummer, herinnering...';
      case 'el': return 'Αρ. κράτησης, υπενθύμιση...';
      case 'sv': return 'Boknings-ID, påminnelse...';
      case 'pl': return 'Nr rezerwacji, notatka...';
      case 'id': return 'No reservasi, pengingat...';
      case 'th': return 'รหัสการจอง, บันทึกเตือนความจำ...';
      case 'vi': return 'Mã đặt chỗ, lời nhắc...';
      case 'en':
      default: return 'Booking ID, reminder...';
    }
  }

  static String completedBadge(String lang, int completed, int total) {
    switch (_cleanLang(lang)) {
      case 'tr': return '$completed / $total tamamlandı';
      case 'de': return '$completed / $total erledigt';
      case 'fr': return '$completed / $total terminés';
      case 'es': return '$completed / $total completados';
      case 'it': return '$completed / $total completati';
      case 'pt': return '$completed / $total concluídos';
      case 'ru': return '$completed / $total выполнено';
      case 'zh': return '$completed / $total 已完成';
      case 'ja': return '$completed / $total 完了';
      case 'ko': return '$completed / $total 완료';
      case 'ar': return '$completed / $total مكتمل';
      case 'hi': return '$completed / $total पूर्ण';
      case 'nl': return '$completed / $total voltooid';
      case 'el': return '$completed / $total ολοκληρώθηκαν';
      case 'sv': return '$completed / $total klara';
      case 'pl': return '$completed / $total ukończono';
      case 'id': return '$completed / $total selesai';
      case 'th': return '$completed / $total เสร็จสิ้น';
      case 'vi': return '$completed / $total hoàn thành';
      case 'en':
      default: return '$completed / $total completed';
    }
  }

  static String itinerarySubtitle(String lang, int count, int completed) {
    final clean = _cleanLang(lang);
    if (count == 0) {
      switch (clean) {
        case 'tr': return 'Gün gün aktiviteleri planlayın';
        case 'de': return 'Plane deine täglichen Aktivitäten';
        case 'fr': return 'Planifiez vos activités jour par jour';
        case 'es': return 'Planifica actividades día a día';
        case 'it': return 'Pianifica le attività giorno per giorno';
        case 'pt': return 'Planeje as atividades dia a dia';
        case 'ru': return 'Планируйте дела по дням';
        case 'zh': return '按天规划每日精彩行程';
        case 'ja': return '日ごとのアクティビティを計画';
        case 'ko': return '일자별 일정을 계획해보세요';
        case 'ar': return 'خطط للأنشطة يوماً بيوم';
        case 'hi': return 'दिन-प्रतिदिन की गतिविधियों की योजना बनाएं';
        case 'nl': return 'Plan activiteiten dag voor dag';
        case 'el': return 'Σχεδιάστε δραστηριότητες ανά ημέρα';
        case 'sv': return 'Planera aktiviteter dag för dag';
        case 'pl': return 'Planuj aktywności dzień po dniu';
        case 'id': return 'Rencanakan kegiatan hari demi hari';
        case 'th': return 'วางแผนกิจกรรมแบบวันต่อวัน';
        case 'vi': return 'Lên lịch trình theo từng ngày';
        case 'en':
        default: return 'Plan activities day by day';
      }
    } else {
      switch (clean) {
        case 'tr': return '$count aktivite planlandı ($completed tamamlandı)';
        case 'de': return '$count Aktivitäten geplant ($completed erledigt)';
        case 'fr': return '$count activités prévues ($completed terminées)';
        case 'es': return '$count actividades planificadas ($completed hechas)';
        case 'it': return '$count attività pianificate ($completed completate)';
        case 'pt': return '$count atividades planejadas ($completed concluídas)';
        case 'ru': return '$count активностей запланировано ($completed выполнено)';
        case 'zh': return '已规划 $count 个活动（已完成 $completed 个）';
        case 'ja': return '$count 件のアクティビティを計画（$completed 件完了）';
        case 'ko': return '$count개 일정 계획됨 ($completed개 완료)';
        case 'ar': return 'تم التخطيط لـ $count نشاط ($completed مكتمل)';
        case 'hi': return '$count गतिविधियां नियोजित ($completed पूर्ण)';
        case 'nl': return '$count activiteiten gepland ($completed voltooid)';
        case 'el': return '$count δραστηριότητες σχεδιάστηκαν ($completed ολοκληρώθηκαν)';
        case 'sv': return '$count aktiviteter planerade ($completed klara)';
        case 'pl': return 'Zaplanowano $count aktywności ($completed ukończono)';
        case 'id': return '$count aktivitas direncanakan ($completed selesai)';
        case 'th': return 'วางแผน $count กิจกรรม (เสร็จสิ้น $completed)';
        case 'vi': return 'Đã lên $count hoạt động ($completed hoàn thành)';
        case 'en':
        default: return '$count activities planned ($completed done)';
      }
    }
  }
}

