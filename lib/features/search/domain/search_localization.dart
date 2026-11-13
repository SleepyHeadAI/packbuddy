/// Native 20-language localization for PackBuddy Global Search
class SearchLocalization {
  SearchLocalization._();

  static String _cleanLang(String lang) {
    return lang.toLowerCase().split('_').first.split('-').first;
  }

  static String getSearch(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Global Arama';
      case 'de': return 'Suche';
      case 'es': return 'Buscar';
      case 'fr': return 'Rechercher';
      case 'it': return 'Cerca';
      case 'pt': return 'Pesquisar';
      case 'ru': return 'Поиск';
      case 'zh': return '搜索';
      case 'ja': return '検索';
      case 'ko': return '검색';
      case 'hi': return 'खोजें';
      case 'ar': return 'بحث';
      case 'nl': return 'Zoeken';
      case 'el': return 'Αναζήτηση';
      case 'sv': return 'Sök';
      case 'pl': return 'Szukaj';
      case 'id': return 'Cari';
      case 'th': return 'ค้นหา';
      case 'vi': return 'Tìm kiếm';
      case 'en':
      default: return 'Global Search';
    }
  }

  static String getSearchHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahat, bavul eşyası, belge veya harcama ara...';
      case 'de': return 'Reisen, Packliste, Dokumente, Ausgaben suchen...';
      case 'es': return 'Buscar viajes, equipaje, documentos, gastos...';
      case 'fr': return 'Voyages, bagages, documents, dépenses...';
      case 'it': return 'Cerca viaggi, valigia, documenti, spese...';
      case 'pt': return 'Buscar viagens, bagagem, documentos, despesas...';
      case 'ru': return 'Поиск поездок, вещей, документов, расходов...';
      case 'zh': return '搜索行程、行李清单、证件或支出...';
      case 'ja': return '旅行、持ち物、書類、支出を検索...';
      case 'ko': return '여행, 짐 목록, 문서, 지출 검색...';
      case 'hi': return 'यात्राएं, पैकिंग, दस्तावेज़, खर्च खोजें...';
      case 'ar': return 'ابحث في الرحلات، الأمتعة، المستندات، المصاريف...';
      case 'nl': return 'Zoek reizen, bagage, documenten, uitgaven...';
      case 'el': return 'Αναζήτηση ταξιδιών, αποσκευών, εγγράφων, εξόδων...';
      case 'sv': return 'Sök resor, packning, dokument, utgifter...';
      case 'pl': return 'Szukaj podróży, bagażu, dokumentów, wydatków...';
      case 'id': return 'Cari perjalanan, barang bawaan, dokumen, pengeluaran...';
      case 'th': return 'ค้นหาทริป, ของในกระเป๋า, เอกสาร, ค่าใช้จ่าย...';
      case 'vi': return 'Tìm chuyến đi, đồ hành lý, tài liệu, chi tiêu...';
      case 'en':
      default: return 'Search trips, packing items, documents, expenses...';
    }
  }

  static String getFilterAll(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tümü';
      case 'de': return 'Alle';
      case 'es': return 'Todos';
      case 'fr': return 'Tous';
      case 'it': return 'Tutti';
      case 'pt': return 'Tudo';
      case 'ru': return 'Все';
      case 'zh': return '全部';
      case 'ja': return 'すべて';
      case 'ko': return '전체';
      case 'hi': return 'सभी';
      case 'ar': return 'الكل';
      case 'nl': return 'Alles';
      case 'el': return 'Όλα';
      case 'sv': return 'Alla';
      case 'pl': return 'Wszystko';
      case 'id': return 'Semua';
      case 'th': return 'ทั้งหมด';
      case 'vi': return 'Tất cả';
      case 'en':
      default: return 'All';
    }
  }

  static String getFilterTrips(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Seyahatler';
      case 'de': return 'Reisen';
      case 'es': return 'Viajes';
      case 'fr': return 'Voyages';
      case 'it': return 'Viaggi';
      case 'pt': return 'Viagens';
      case 'ru': return 'Поездки';
      case 'zh': return '行程';
      case 'ja': return '旅行';
      case 'ko': return '여행';
      case 'hi': return 'यात्राएं';
      case 'ar': return 'الرحلات';
      case 'nl': return 'Reizen';
      case 'el': return 'Ταξίδια';
      case 'sv': return 'Resor';
      case 'pl': return 'Podróże';
      case 'id': return 'Perjalanan';
      case 'th': return 'ทริป';
      case 'vi': return 'Chuyến đi';
      case 'en':
      default: return 'Trips';
    }
  }

  static String getFilterPacking(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Bavul Eşyaları';
      case 'de': return 'Packliste';
      case 'es': return 'Equipaje';
      case 'fr': return 'Bagages';
      case 'it': return 'Valigia';
      case 'pt': return 'Bagagem';
      case 'ru': return 'Вещи';
      case 'zh': return '行李清单';
      case 'ja': return '持ち物';
      case 'ko': return '짐 목록';
      case 'hi': return 'पैकिंग सामान';
      case 'ar': return 'الأمتعة';
      case 'nl': return 'Bagagestukken';
      case 'el': return 'Αποσκευές';
      case 'sv': return 'Packning';
      case 'pl': return 'Bagaż';
      case 'id': return 'Barang Bawaan';
      case 'th': return 'สัมภาระ';
      case 'vi': return 'Hành lý';
      case 'en':
      default: return 'Packing Items';
    }
  }

  static String getFilterDocuments(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Belgeler';
      case 'de': return 'Dokumente';
      case 'es': return 'Documentos';
      case 'fr': return 'Documents';
      case 'it': return 'Documenti';
      case 'pt': return 'Documentos';
      case 'ru': return 'Документы';
      case 'zh': return '证件文档';
      case 'ja': return '書類';
      case 'ko': return '문서';
      case 'hi': return 'दस्तावेज़';
      case 'ar': return 'المستندات';
      case 'nl': return 'Documenten';
      case 'el': return 'Έγγραφα';
      case 'sv': return 'Dokument';
      case 'pl': return 'Dokumenty';
      case 'id': return 'Dokumen';
      case 'th': return 'เอกสาร';
      case 'vi': return 'Tài liệu';
      case 'en':
      default: return 'Documents';
    }
  }

  static String getFilterExpenses(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Harcamalar';
      case 'de': return 'Ausgaben';
      case 'es': return 'Gastos';
      case 'fr': return 'Dépenses';
      case 'it': return 'Spese';
      case 'pt': return 'Despesas';
      case 'ru': return 'Расходы';
      case 'zh': return '支出';
      case 'ja': return '支出';
      case 'ko': return '지출';
      case 'hi': return 'खर्च';
      case 'ar': return 'المصاريف';
      case 'nl': return 'Uitgaven';
      case 'el': return 'Έξοδα';
      case 'sv': return 'Utgifter';
      case 'pl': return 'Wydatki';
      case 'id': return 'Pengeluaran';
      case 'th': return 'ค่าใช้จ่าย';
      case 'vi': return 'Chi tiêu';
      case 'en':
      default: return 'Expenses';
    }
  }

  static String getRecentSearches(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Son Aramalar';
      case 'de': return 'Letzte Suchanfragen';
      case 'es': return 'Búsquedas recientes';
      case 'fr': return 'Recherches récentes';
      case 'it': return 'Ricerche recenti';
      case 'pt': return 'Pesquisas recentes';
      case 'ru': return 'Недавние поиски';
      case 'zh': return '最近搜索';
      case 'ja': return '最近の検索';
      case 'ko': return '최근 검색어';
      case 'hi': return 'हाल की खोजें';
      case 'ar': return 'عمليات البحث الأخيرة';
      case 'nl': return 'Recente zoekopdrachten';
      case 'el': return 'Πρόσφατες αναζητήσεις';
      case 'sv': return 'Senaste sökningar';
      case 'pl': return 'Ostatnie wyszukiwania';
      case 'id': return 'Pencarian Terkini';
      case 'th': return 'การค้นหาล่าสุด';
      case 'vi': return 'Tìm kiếm gần đây';
      case 'en':
      default: return 'Recent Searches';
    }
  }

  static String getClear(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Temizle';
      case 'de': return 'Löschen';
      case 'es': return 'Borrar';
      case 'fr': return 'Effacer';
      case 'it': return 'Cancella';
      case 'pt': return 'Limpar';
      case 'ru': return 'Очистить';
      case 'zh': return '清除';
      case 'ja': return 'クリア';
      case 'ko': return '지우기';
      case 'hi': return 'साफ़ करें';
      case 'ar': return 'مسح';
      case 'nl': return 'Wissen';
      case 'el': return 'Εκκαθάριση';
      case 'sv': return 'Rensa';
      case 'pl': return 'Wyczyść';
      case 'id': return 'Hapus';
      case 'th': return 'ล้าง';
      case 'vi': return 'Xóa';
      case 'en':
      default: return 'Clear';
    }
  }

  static String getNoResults(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Sonuç bulunamadı';
      case 'de': return 'Keine Ergebnisse gefunden';
      case 'es': return 'No se encontraron resultados';
      case 'fr': return 'Aucun résultat trouvé';
      case 'it': return 'Nessun risultato trovato';
      case 'pt': return 'Nenhum resultado encontrado';
      case 'ru': return 'Ничего не найдено';
      case 'zh': return '未找到结果';
      case 'ja': return '見つかりませんでした';
      case 'ko': return '검색 결과가 없습니다';
      case 'hi': return 'कोई परिणाम नहीं मिला';
      case 'ar': return 'لم يتم العثور على نتائج';
      case 'nl': return 'Geen resultaten gevonden';
      case 'el': return 'Δεν βρέθηκαν αποτελέσματα';
      case 'sv': return 'Inga resultat hittades';
      case 'pl': return 'Nie znaleziono wyników';
      case 'id': return 'Tidak ada hasil ditemukan';
      case 'th': return 'ไม่พบผลลัพธ์';
      case 'vi': return 'Không tìm thấy kết quả';
      case 'en':
      default: return 'No results found';
    }
  }

  static String getNoResultsHint(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Farklı bir anahtar kelime veya filtre seçeneği deneyin.';
      case 'de': return 'Versuchen Sie es mit einem anderen Begriff oder Filter.';
      case 'es': return 'Pruebe con una palabra clave o filtro diferente.';
      case 'fr': return 'Essayez avec un mot-clé ou un filtre différent.';
      case 'it': return 'Prova con una parola chiave o un filtro diverso.';
      case 'pt': return 'Tente outra palavra-chave ou filtro.';
      case 'ru': return 'Попробуйте изменить поисковый запрос или фильтр.';
      case 'zh': return '请尝试使用其他关键字或筛选条件。';
      case 'ja': return '別のキーワードやフィルターをお試しください。';
      case 'ko': return '다른 키워드나 필터를 사용해 보세요.';
      case 'hi': return 'कोई अन्य शब्द या फ़िल्टर आज़माएं।';
      case 'ar': return 'جرب كلمة بحث أخرى أو قم بتغيير الفلتر.';
      case 'nl': return 'Probeer een ander trefwoord of filter.';
      case 'el': return 'Δοκιμάστε μια άλλη λέξη-κλειδί ή φίλτρο.';
      case 'sv': return 'Prova ett annat sökord eller filter.';
      case 'pl': return 'Spróbuj użyć innego słowa kluczowego lub filtra.';
      case 'id': return 'Coba kata kunci atau filter lain.';
      case 'th': return 'ลองใช้คำค้นหาหรือตัวกรองอื่น';
      case 'vi': return 'Thử từ khóa hoặc bộ lọc khác.';
      case 'en':
      default: return 'Try a different keyword or filter.';
    }
  }

  static String getStartTyping(String lang) {
    switch (_cleanLang(lang)) {
      case 'tr': return 'Tüm seyahat ve eşyalarınızda aramak için yazmaya başlayın';
      case 'de': return 'Tippen Sie, um alle Reisen und Gegenstände zu durchsuchen';
      case 'es': return 'Comience a escribir para buscar en sus viajes y pertenencias';
      case 'fr': return 'Commencez à taper pour rechercher dans vos voyages';
      case 'it': return 'Inizia a digitare per cercare tra i tuoi viaggi e oggetti';
      case 'pt': return 'Comece a digitar para pesquisar em suas viagens e itens';
      case 'ru': return 'Начните вводить текст для поиска по всем путешествиям';
      case 'zh': return '开始输入以搜索您的所有行程与物品';
      case 'ja': return '入力して旅行や持ち物を検索します';
      case 'ko': return '검색어를 입력하여 여행 및 짐을 찾아보세요';
      case 'hi': return 'सभी यात्राओं और वस्तुओं में खोजने के लिए टाइप करें';
      case 'ar': return 'ابدأ بالكتابة للبحث في جميع رحلاتك وأغراضك';
      case 'nl': return 'Begin met typen om al je reizen en items te doorzoeken';
      case 'el': return 'Πληκτρολογήστε για αναζήτηση στα ταξίδια και τα αντικείμενά σας';
      case 'sv': return 'Börja skriva för att söka bland alla dina resor och saker';
      case 'pl': return 'Zacznij pisać, aby przeszukać podróże i przedmioty';
      case 'id': return 'Mulai mengetik untuk mencari di semua perjalanan dan barang';
      case 'th': return 'เริ่มพิมพ์เพื่อค้นหาในทุกทริปและสิ่งของของคุณ';
      case 'vi': return 'Bắt đầu nhập để tìm kiếm trong tất cả chuyến đi và đồ đạc';
      case 'en':
      default: return 'Start typing to search across all your trips and belongings';
    }
  }
}

