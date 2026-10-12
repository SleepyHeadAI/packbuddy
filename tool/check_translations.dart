// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('lib/l10n/app_en.arb');
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toList();

  final arbDir = Directory('lib/l10n');
  final arbFiles = arbDir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb')).toList();

  print('Total keys in template: ${enKeys.length}');
  print('Total ARB files found: ${arbFiles.length}');

  final Map<String, List<String>> identicalToEnglish = {};
  final Map<String, List<String>> missingKeys = {};

  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    if (fileName == 'app_en.arb') continue;
    final langCode = fileName.replaceAll('app_', '').replaceAll('.arb', '');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final missing = <String>[];
    final identical = <String>[];

    for (final k in enKeys) {
      if (!data.containsKey(k)) {
        missing.add(k);
      } else {
        final val = data[k].toString();
        final enVal = enJson[k].toString();
        // Skip keys that are naturally in English or universally identical like app name, codes, etc.
        if (val == enVal &&
            k != 'appName' &&
            !enVal.contains('{') &&
            enVal.length > 3 &&
            !['OK', 'PIN', 'PDF', 'TRY', 'EUR', 'USD', 'GBP'].contains(enVal)) {
          identical.add(k);
        }
      }
    }

    if (missing.isNotEmpty) missingKeys[langCode] = missing;
    if (identical.isNotEmpty) identicalToEnglish[langCode] = identical;
  }

  print('\n--- Missing keys report ---');
  if (missingKeys.isEmpty) {
    print('None! All files have 100% key parity.');
  } else {
    missingKeys.forEach((lang, keys) {
      print('$lang missing ${keys.length} keys: $keys');
    });
  }

  print('\n--- Identical to English (potentially untranslated) count per language ---');
  identicalToEnglish.forEach((lang, keys) {
    print('$lang has ${keys.length} keys identical to English.');
  });

  print('tr identical keys: ${identicalToEnglish['tr']}');
}
