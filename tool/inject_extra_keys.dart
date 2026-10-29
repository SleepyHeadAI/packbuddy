// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final l10nDir = Directory('lib/l10n');
  if (!l10nDir.existsSync()) {
    print('lib/l10n does not exist');
    exit(1);
  }

  final metadata = {
    'planTripToCountry': {
      'description': 'Button label to plan a trip to selected country',
      'placeholders': {
        'country': {'type': 'String'}
      }
    },
    'noVisitedCountriesYet': {
      'description': 'Empty state message when no countries have been visited'
    },
  };

  final Map<String, Map<String, String>> translations = {
    'en': {
      'planTripToCountry': 'Plan Trip to {country}',
      'noVisitedCountriesYet': 'No visited countries marked yet. Tap countries on the map or list below to fill them with color!',
    },
    'tr': {
      'planTripToCountry': '{country} Seyahati Planla',
      'noVisitedCountriesYet': 'Henüz gezdiğin bir ülke işaretlemedin. Haritadan veya aşağıdaki listeden dokunarak hemen renklendir!',
    },
    'de': {
      'planTripToCountry': 'Reise nach {country} planen',
      'noVisitedCountriesYet': 'Noch keine besuchten Länder markiert. Tippe auf Länder auf der Karte oder der Liste unten, um sie einzufärben!',
    },
    'fr': {
      'planTripToCountry': 'Planifier un voyage en {country}',
      'noVisitedCountriesYet': 'Aucun pays visité marqué pour le moment. Appuyez sur la carte ou la liste ci-dessous pour les colorer !',
    },
    'es': {
      'planTripToCountry': 'Planificar viaje a {country}',
      'noVisitedCountriesYet': '¡Aún no has marcado países visitados! Toca países en el mapa o en la lista inferior para colorearlos.',
    },
    'it': {
      'planTripToCountry': 'Pianifica viaggio in {country}',
      'noVisitedCountriesYet': 'Nessun paese visitato contrassegnato finora. Tocca i paesi sulla mappa o nell\'elenco in basso per colorarli!',
    },
    'pt': {
      'planTripToCountry': 'Planejar viagem para {country}',
      'noVisitedCountriesYet': 'Nenhum país visitado marcado ainda. Toque nos países no mapa ou na lista abaixo para colori-los!',
    },
    'nl': {
      'planTripToCountry': 'Reis naar {country} plannen',
      'noVisitedCountriesYet': 'Nog geen bezochte landen gemarkeerd. Tik op landen op de kaart of lijst hieronder om ze in te kleuren!',
    },
    'sv': {
      'planTripToCountry': 'Planera resa till {country}',
      'noVisitedCountriesYet': 'Inga besökta länder markerade än. Tryck på länder på kartan eller listan nedan för att färglägga dem!',
    },
    'pl': {
      'planTripToCountry': 'Zaplanuj podróż do {country}',
      'noVisitedCountriesYet': 'Nie zaznaczono jeszcze odwiedzonych krajów. Dotknij krajów na mapie lub poniższej liście, aby je pokolorować!',
    },
    'ru': {
      'planTripToCountry': 'Спланировать поездку в {country}',
      'noVisitedCountriesYet': 'Посещённые страны ещё не отмечены. Нажмите на страны на карте или в списке ниже, чтобы раскрасить их!',
    },
    'el': {
      'planTripToCountry': 'Σχεδιάστε ταξίδι σε {country}',
      'noVisitedCountriesYet': 'Δεν έχουν επισημανθεί ακόμη χώρες που επισκεφτήκατε. Πατήστε χώρες στον χάρτη ή στην παρακάτω λίστα για να τις χρωματίσετε!',
    },
    'hi': {
      'planTripToCountry': '{country} की यात्रा की योजना बनाएं',
      'noVisitedCountriesYet': 'अभी तक कोई देखा गया देश चिह्नित नहीं है। उन्हें रंगने के लिए मानचित्र या नीचे दी गई सूची पर देशों पर टैप करें!',
    },
    'id': {
      'planTripToCountry': 'Rencanakan Perjalanan ke {country}',
      'noVisitedCountriesYet': 'Belum ada negara yang ditandai telah dikunjungi. Ketuk negara pada peta atau daftar di bawah untuk mewarnainya!',
    },
    'ja': {
      'planTripToCountry': '{country}への旅行を計画',
      'noVisitedCountriesYet': 'まだ訪れた国が登録されていません。地図または下のリストから国をタップして色を塗りましょう！',
    },
    'ko': {
      'planTripToCountry': '{country} 여행 계획',
      'noVisitedCountriesYet': '아직 방문한 국가가 표시되지 않았습니다. 지도나 아래 목록에서 국가를 탭하여 색칠하세요!',
    },
    'th': {
      'planTripToCountry': 'วางแผนการเดินทางไป{country}',
      'noVisitedCountriesYet': 'ยังไม่มีการทำเครื่องหมายประเทศที่เคยไป แตะประเทศบนแผนที่หรือรายการด้านล่างเพื่อระบายสี!',
    },
    'vi': {
      'planTripToCountry': 'Lên kế hoạch du lịch đến {country}',
      'noVisitedCountriesYet': 'Chưa đánh dấu quốc gia đã đến. Nhấn vào các quốc gia trên bản đồ hoặc danh sách bên dưới để tô màu!',
    },
    'zh': {
      'planTripToCountry': '规划前往{country}的行程',
      'noVisitedCountriesYet': '尚未标记任何去过的国家。点击地图或下方列表中的国家即可涂色！',
    },
    'ar': {
      'planTripToCountry': 'خطط لرحلة إلى {country}',
      'noVisitedCountriesYet': 'لم يتم تحديد أي بلدان تمت زيارتها بعد. اضغط على البلدان على الخريطة أو القائمة أدناه لتلوينها!',
    },
  };

  const encoder = JsonEncoder.withIndent('  ');

  for (final entry in translations.entries) {
    final lang = entry.key;
    final file = File('lib/l10n/app_$lang.arb');
    if (!file.existsSync()) {
      print('File not found: ${file.path}');
      continue;
    }

    final Map<String, dynamic> data = jsonDecode(file.readAsStringSync());

    for (final keyEntry in entry.value.entries) {
      final key = keyEntry.key;
      final val = keyEntry.value;
      data[key] = val;
      if (lang == 'en' && metadata.containsKey(key)) {
        data['@$key'] = metadata[key];
      }
    }

    file.writeAsStringSync('${encoder.convert(data)}\n');
    print('Updated ${file.path} with 2 extra keys');
  }

  print('Done injecting extra keys.');
}
