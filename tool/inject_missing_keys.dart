// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final Map<String, Map<String, String>> additions = {
    'en': {
      'total': 'Total',
      'totalSpent': 'Total Spent',
      'confirm': 'Confirm',
    },
    'tr': {
      'total': 'Toplam',
      'totalSpent': 'Toplam Harcama',
      'confirm': 'Onayla',
    },
    'de': {
      'total': 'Gesamt',
      'totalSpent': 'Gesamtausgaben',
      'confirm': 'Bestätigen',
    },
    'fr': {
      'total': 'Total',
      'totalSpent': 'Dépenses Totales',
      'confirm': 'Confirmer',
    },
    'es': {
      'total': 'Total',
      'totalSpent': 'Gasto Total',
      'confirm': 'Confirmar',
    },
    'it': {
      'total': 'Totale',
      'totalSpent': 'Spesa Totale',
      'confirm': 'Conferma',
    },
    'pt': {
      'total': 'Total',
      'totalSpent': 'Total Gasto',
      'confirm': 'Confirmar',
    },
    'nl': {
      'total': 'Totaal',
      'totalSpent': 'Totaal Uitgegeven',
      'confirm': 'Bevestigen',
    },
    'ru': {
      'total': 'Всего',
      'totalSpent': 'Всего потрачено',
      'confirm': 'Подтвердить',
    },
    'zh': {
      'total': '总计',
      'totalSpent': '总支出',
      'confirm': '确认',
    },
    'ja': {
      'total': '合計',
      'totalSpent': '総支出',
      'confirm': '確認',
    },
    'ko': {
      'total': '총합',
      'totalSpent': '총 지출',
      'confirm': '확인',
    },
    'ar': {
      'total': 'المجموع',
      'totalSpent': 'إجمالي الإنفاق',
      'confirm': 'تأكيد',
    },
    'hi': {
      'total': 'कुल',
      'totalSpent': 'कुल खर्च',
      'confirm': 'पुष्टि करें',
    },
    'id': {
      'total': 'Total',
      'totalSpent': 'Total Pengeluaran',
      'confirm': 'Konfirmasi',
    },
    'pl': {
      'total': 'Razem',
      'totalSpent': 'Łączne wydatki',
      'confirm': 'Potwierdź',
    },
    'el': {
      'total': 'Σύνολο',
      'totalSpent': 'Συνολική δαπάνη',
      'confirm': 'Επιβεβαίωση',
    },
    'vi': {
      'total': 'Tổng cộng',
      'totalSpent': 'Tổng chi tiêu',
      'confirm': 'Xác nhận',
    },
    'th': {
      'total': 'ยอดรวม',
      'totalSpent': 'ยอดใช้จ่ายทั้งหมด',
      'confirm': 'ยืนยัน',
    },
    'sv': {
      'total': 'Totalt',
      'totalSpent': 'Totalt spenderat',
      'confirm': 'Bekräfta',
    },
  };

  final l10nDir = Directory('lib/l10n');
  final encoder = const JsonEncoder.withIndent('  ');

  for (final entry in additions.entries) {
    final lang = entry.key;
    final file = File('${l10nDir.path}/app_$lang.arb');
    if (!file.existsSync()) {
      print('File not found: ${file.path}');
      continue;
    }

    final content = file.readAsStringSync();
    final Map<String, dynamic> jsonMap = json.decode(content);

    entry.value.forEach((k, v) {
      jsonMap[k] = v;
    });

    file.writeAsStringSync('${encoder.convert(jsonMap)}\n');
    print('Updated ${file.path} with missing keys');
  }

  print('Done injecting missing keys!');
}
