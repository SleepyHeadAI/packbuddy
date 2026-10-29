// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('lib/l10n/app_en.arb');
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final keys = enJson.keys.where((k) => !k.startsWith('@')).toList();
  keys.sort();

  print('All keys in app_en.arb (${keys.length} total):');
  for (final k in keys) {
    if (k.toLowerCase().contains('apply') ||
        k.toLowerCase().contains('save') ||
        k.toLowerCase().contains('confirm')) {
      print('  $k: ${enJson[k]}');
    }
  }
}
