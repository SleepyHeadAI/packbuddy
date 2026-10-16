// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final l10nDir = Directory('lib/l10n');
  if (!l10nDir.existsSync()) {
    print('lib/l10n directory not found');
    exit(1);
  }

  final enFile = File('lib/l10n/app_en.arb');
  if (!enFile.existsSync()) {
    print('app_en.arb not found');
    exit(1);
  }

  final enData = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final enKeys = enData.keys.where((k) => !k.startsWith('@')).toSet();
  print('English keys count: ${enKeys.length}');

  final arbFiles = l10nDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'))
      .toList();

  int totalErrors = 0;

  for (final file in arbFiles) {
    final fileName = file.uri.pathSegments.last;
    final locale = fileName.replaceAll('app_', '').replaceAll('.arb', '');
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final keys = data.keys.where((k) => !k.startsWith('@')).toSet();

    final missingInTarget = enKeys.difference(keys);
    final emptyValues = <String>[];
    final placeholderMismatches = <String>[];

    final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

    for (final key in keys) {
      final val = data[key];
      if (val is String && val.trim().isEmpty) {
        emptyValues.add(key);
      }

      if (enData.containsKey(key) && enData[key] is String && val is String) {
        final enPlaceholders = placeholderRegex
            .allMatches(enData[key] as String)
            .map((m) => m.group(1)!)
            .toSet();
        final targetPlaceholders = placeholderRegex
            .allMatches(val)
            .map((m) => m.group(1)!)
            .toSet();

        if (!enPlaceholders.containsAll(targetPlaceholders) ||
            !targetPlaceholders.containsAll(enPlaceholders)) {
          placeholderMismatches.add(
              '$key: en has $enPlaceholders vs $locale has $targetPlaceholders');
        }
      }
    }

    print('[$locale] Keys: ${keys.length} | Missing: ${missingInTarget.length} | Empty: ${emptyValues.length} | Mismatched Placeholders: ${placeholderMismatches.length}');

    if (missingInTarget.isNotEmpty) {
      print('  Missing keys in $locale: ${missingInTarget.take(10).toList()} (total ${missingInTarget.length})');
      totalErrors += missingInTarget.length;
    }
    if (emptyValues.isNotEmpty) {
      print('  Empty keys in $locale: $emptyValues');
      totalErrors += emptyValues.length;
    }
    if (placeholderMismatches.isNotEmpty) {
      print('  Placeholder mismatches in $locale: $placeholderMismatches');
      totalErrors += placeholderMismatches.length;
    }
  }

  print('\n----------------------------------------');
  if (totalErrors == 0) {
    print('AUDIT PASSED! All 20 locales have 100% complete keys, 0 empty strings, and valid placeholders.');
  } else {
    print('AUDIT FAILED with $totalErrors issues.');
    exit(1);
  }
}
