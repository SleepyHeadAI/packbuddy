import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/help/data/faq_data.dart';
import 'package:packbuddy/features/help/domain/faq_item.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';
import 'package:packbuddy/features/help/presentation/screens/widgets/contact_support_card.dart';
import 'package:packbuddy/features/help/presentation/screens/widgets/faq_expansion_tile.dart';
import 'package:packbuddy/features/help/presentation/screens/widgets/help_topic_card.dart';

/// Serene Voyage Help & FAQ screen providing instant answers,
/// topic-based categorization, interactive keyword search, and direct support dispatch.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> _getFilteredItems(String languageCode) {
    var items = _selectedCategory == 'all'
        ? FaqData.allItems
        : FaqData.getByCategory(_selectedCategory);

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((item) {
        final question = HelpLocalization.getQuestion(item.id, languageCode).toLowerCase();
        final answer = HelpLocalization.getAnswer(item.id, languageCode).toLowerCase();
        final cat = HelpLocalization.getCategoryName(item.category, languageCode).toLowerCase();
        return question.contains(q) || answer.contains(q) || cat.contains(q);
      }).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final title = HelpLocalization.getTitle(langCode);
    final subtitle = HelpLocalization.getSubtitle(langCode);
    final filteredItems = _getFilteredItems(langCode);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_center_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Subtitle / Introductory banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: HelpLocalization.getSearchHint(langCode),
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 13.5,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Topic Selector
          HelpTopicSelector(
            selectedCategory: _selectedCategory,
            languageCode: langCode,
            onCategorySelected: (cat) {
              setState(() {
                _selectedCategory = cat;
              });
            },
          ),
          const SizedBox(height: 18),

          // FAQ List or Empty State
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: filteredItems.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          HelpLocalization.getNoResultsFound(langCode),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: filteredItems
                        .map((item) => FaqExpansionTile(
                              key: ValueKey(item.id),
                              item: item,
                              languageCode: langCode,
                            ))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),

          // Contact Support & Walkthrough Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ContactSupportCard(languageCode: langCode),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
