import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/l10n/l10n.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Displays the interactive modal bottom sheet to switch between the 20 supported languages
void showLanguageSelectorSheet(BuildContext context, WidgetRef ref, Locale currentLocale) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      reverseDuration: Duration(milliseconds: 200),
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final l10n = AppLocalizations.of(ctx);
      final sortedLocales = L10n.getSortedLocales(currentLocale.languageCode);

      return RepaintBoundary(
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.translate_rounded, size: 20, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n?.language ?? 'Dil / Language',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${sortedLocales.length} ${l10n?.language ?? "Dil"}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sortedLocales.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                  itemBuilder: (context, index) {
                    final locale = sortedLocales[index];
                    final isSelected = locale.languageCode == currentLocale.languageCode;
                    final displayName = L10n.getLanguageDisplayName(
                      locale.languageCode,
                      currentLocale.languageCode,
                    );

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                      leading: Text(
                        L10n.getLanguageFlag(locale.languageCode),
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        displayName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                          : null,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(locale);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}
