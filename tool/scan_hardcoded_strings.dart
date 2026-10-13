// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('.system_generated'))
      .where((f) => !f.path.contains('app_localizations'))
      .where((f) => !f.path.contains('tool/'))
      .toList();

  print('Scanning ${dartFiles.length} Dart files for hardcoded strings...\n');

  final patterns = [
    RegExp(r'''Text\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''\?\s*['"]([^'"]+)['"]\s*:\s*['"]([^'"]+)['"]'''), // ternary string : string
    RegExp(r'''title:\s*Text\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''hintText:\s*['"]([^'"]+)['"]'''),
    RegExp(r'''labelText:\s*['"]([^'"]+)['"]'''),
    RegExp(r'''return\s+['"]([^'"]{3,})['"]'''), // return 'string'
  ];

  final ignored = [
    '',
    ' ',
    ' • ',
    ': ',
    '/',
    '-',
    'PackBuddy',
    'PackBuddy Pro',
    'v1.0.0',
    'PackBuddy v1.0.0',
    'Roboto',
    'Inter',
    'Poppins',
  ];

  final findings = <String, List<String>>{};

  for (final file in dartFiles) {
    final lines = file.readAsLinesSync();
    final fileFindings = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Skip comments
      if (line.trim().startsWith('//') || line.trim().startsWith('*')) continue;

      for (final p in patterns) {
        for (final m in p.allMatches(line)) {
          final str = m.group(1)?.trim() ?? '';
          if (str.isEmpty || ignored.contains(str)) continue;
          // Ignore if it's purely numbers, punctuation, currency symbols, or formatting
          if (RegExp(r'^[\d\s\.,\+\-%€\$₺£•()/:_]+$').hasMatch(str)) continue;
          // Ignore SVG/asset paths
          if (str.endsWith('.png') || str.endsWith('.svg') || str.endsWith('.json')) continue;
          // Ignore font families
          if (['Roboto', 'Inter', 'Outfit', 'Plus Jakarta Sans'].contains(str)) continue;

          fileFindings.add('L${i + 1}: "$str" (full line: ${line.trim()})');
        }
      }
    }

    if (fileFindings.isNotEmpty) {
      findings[file.path] = fileFindings;
    }
  }

  print('=== SCAN RESULTS (${findings.length} files with potential hardcoded strings) ===\n');
  findings.forEach((path, list) {
    print('FILE: $path (${list.length} matches)');
    for (final item in list) {
      print('   $item');
    }
    print('');
  });
}
