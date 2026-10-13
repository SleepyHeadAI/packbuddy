// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final arbDir = Directory('lib/l10n');
  final arbFiles = arbDir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb')).toList();

  final trFile = File('lib/l10n/app_tr.arb');
  final trJson = jsonDecode(trFile.readAsStringSync()) as Map<String, dynamic>;

  final enFile = File('lib/l10n/app_en.arb');
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toList();

  print('=== AUDIT REPORT: PACKBUDDY LOCALIZATION ===\n');

  // 1. Placeholder consistency check
  print('1. Checking placeholder consistency across all 20 languages:');
  final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');
  int placeholderErrors = 0;

  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    for (final key in enKeys) {
      final enVal = enJson[key]?.toString() ?? '';
      final targetVal = json[key]?.toString() ?? '';

      final enMatches = placeholderRegex.allMatches(enVal).map((m) => m.group(1)!).toSet();
      final targetMatches = placeholderRegex.allMatches(targetVal).map((m) => m.group(1)!).toSet();

      if (!enMatches.containsAll(targetMatches) || !targetMatches.containsAll(enMatches)) {
        print('  [PLACEHOLDER MISMATCH] $fileName -> $key: Expected $enMatches, found $targetMatches');
        placeholderErrors++;
      }
    }
  }

  if (placeholderErrors == 0) {
    print('  ✓ All placeholders match 100% across all 20 languages!\n');
  } else {
    print('  ✗ Found $placeholderErrors placeholder mismatch(es)!\n');
  }

  // 2. Turkish leakage into non-Turkish files
  print('2. Checking for Turkish language leakage into non-Turkish files:');
  int turkishLeaks = 0;
  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    if (fileName == 'app_tr.arb' || fileName == 'app_en.arb') continue;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final leaks = <String>[];
    json.forEach((k, v) {
      if (v is String && trJson.containsKey(k) && trJson[k] is String) {
        final trVal = trJson[k] as String;
        // Ignore universally identical strings, brand names, and legitimate multilingual cognates
        const cognates = {
          'PackBuddy', 'PackBuddy Pro', 'traveler@packbuddy.com',
          'Elektronik', // Valid in de, id, sv
          'Tema',       // Valid in es, pt, it, id, sv
          'Tren',       // Valid in es
          'Bilet',      // Valid in pl
          'Kategori',   // Valid in id, sv
          'PackBuddy Pro Aktif', // Valid in id (Aktif = active)
        };
        if (v == trVal &&
            trVal.length > 3 &&
            !cognates.contains(trVal)) {
          leaks.add('$k: "$v"');
        }
      }
    });

    if (leaks.isNotEmpty) {
      print('  ✗ $fileName has Turkish leaks:');
      for (final l in leaks) {
        print('      $l');
      }
      turkishLeaks += leaks.length;
    }
  }
  if (turkishLeaks == 0) {
    print('  ✓ 0 Turkish leaks found across all non-Turkish files!\n');
  }

  // 3. English leakage into non-English files
  print('3. Detailed check of English identical keys:');
  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    if (fileName == 'app_en.arb') continue;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final identical = <String>[];
    json.forEach((k, v) {
      if (v is String && enJson.containsKey(k) && enJson[k] is String) {
        final enVal = enJson[k] as String;
        if (v == enVal &&
            !k.startsWith('@') &&
            !['PackBuddy', 'PackBuddy Pro', 'traveler@packbuddy.com', 'OK', 'PIN', 'PDF', 'TRY', 'EUR', 'USD', 'GBP'].contains(enVal) &&
            enVal.length > 3) {
          identical.add('$k: "$v"');
        }
      }
    });

    if (identical.isNotEmpty) {
      print('  $fileName (${identical.length} identical): $identical');
    }
  }

  print('\n=== AUDIT COMPLETE ===');
}
