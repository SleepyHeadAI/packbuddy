import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/checklist/domain/packing_templates.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';

void main() {
  test('Check all template items localization across all 20 languages', () {
    final templates = PackingTemplatesRepository.all;
    final unmapped = <String>[];
    final failedTranslations = <String, List<String>>{};

    const all20Languages = [
      'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
      'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi'
    ];

    for (final template in templates) {
      for (final item in template.items) {
        final key = CanonicalPackingCatalog.resolveCanonicalKey(item.name);
        if (key == null) {
          unmapped.add('[${template.id}] "${item.name}"');
        } else {
          for (final lang in all20Languages) {
            final localized = CanonicalPackingCatalog.getLocalizedItemName(item.name, lang);
            if (localized.isEmpty) {
              failedTranslations.putIfAbsent(lang, () => []).add('${item.name} is empty for $lang');
            }
            if (lang != 'tr' && localized == item.name) {
              failedTranslations.putIfAbsent(lang, () => []).add('${item.name} fell back to Turkish for $lang');
            }
          }
        }
      }
    }

    expect(unmapped, isEmpty, reason: 'Every template item must map to a canonical key');
    expect(failedTranslations, isEmpty, reason: 'Every template item must have non-Turkish localized names for non-TR languages');
  });
}
