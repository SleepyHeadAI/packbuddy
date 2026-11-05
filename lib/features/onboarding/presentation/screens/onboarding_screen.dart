import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/l10n/l10n.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/l10n/language_selector_sheet.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String titleKey;
  final String descKey;
  final String defaultTitle;
  final String defaultDesc;

  const OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.titleKey,
    required this.descKey,
    required this.defaultTitle,
    required this.defaultDesc,
  });
}

/// Interactive First-Time Walkthrough & App Tour (Feature F-13)
class OnboardingScreen extends ConsumerStatefulWidget {
  final bool isReplay;
  final VoidCallback? onCompleted;

  const OnboardingScreen({
    super.key,
    this.isReplay = false,
    this.onCompleted,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.flight_takeoff_rounded,
      iconColor: AppColors.primaryAmber,
      titleKey: 'onboardingTitle1',
      descKey: 'onboardingDesc1',
      defaultTitle: 'Plan Trips Effortlessly',
      defaultDesc:
          'Organize multi-currency travel budgets and track daily expenses anywhere in the world.',
    ),
    OnboardingPageData(
      icon: Icons.checklist_rtl_rounded,
      iconColor: AppColors.secondaryLight,
      titleKey: 'onboardingTitle2',
      descKey: 'onboardingDesc2',
      defaultTitle: 'Smart Packing Checklists',
      defaultDesc:
          'Airline baggage guidelines and smart category templates ensure you never forget essentials.',
    ),
    OnboardingPageData(
      icon: Icons.groups_rounded,
      iconColor: AppColors.tertiaryLight,
      titleKey: 'onboardingTitle3',
      descKey: 'onboardingDesc3',
      defaultTitle: 'Collaborate in Real-Time',
      defaultDesc:
          'Share your trip plans and checklists with friends and family with simple 6-digit invite codes.',
    ),
    OnboardingPageData(
      icon: Icons.lock_person_rounded,
      iconColor: AppColors.actionGold,
      titleKey: 'onboardingTitle4',
      descKey: 'onboardingDesc4',
      defaultTitle: 'Offline Travel Vault',
      defaultDesc:
          'Keep passports, boarding passes, and vouchers encrypted and accessible without internet.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    await PreferencesService.instance.setOnboardingCompleted(true);
    if (!mounted) return;

    widget.onCompleted?.call();

    if (widget.isReplay) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  String _resolveTitle(OnboardingPageData page, AppLocalizations? l10n) {
    switch (page.titleKey) {
      case 'onboardingTitle1':
        return l10n?.onboardingTitle1 ?? page.defaultTitle;
      case 'onboardingTitle2':
        return l10n?.onboardingTitle2 ?? page.defaultTitle;
      case 'onboardingTitle3':
        return l10n?.onboardingTitle3 ?? page.defaultTitle;
      case 'onboardingTitle4':
        return l10n?.onboardingTitle4 ?? page.defaultTitle;
      default:
        return page.defaultTitle;
    }
  }

  String _resolveDesc(OnboardingPageData page, AppLocalizations? l10n) {
    switch (page.descKey) {
      case 'onboardingDesc1':
        return l10n?.onboardingDesc1 ?? page.defaultDesc;
      case 'onboardingDesc2':
        return l10n?.onboardingDesc2 ?? page.defaultDesc;
      case 'onboardingDesc3':
        return l10n?.onboardingDesc3 ?? page.defaultDesc;
      case 'onboardingDesc4':
        return l10n?.onboardingDesc4 ?? page.defaultDesc;
      default:
        return page.defaultDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(localeProvider);

    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with App Branding, Language Selector Pill and Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // App branding badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.luggage_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'PackBuddy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Language Selector Pill
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => showLanguageSelectorSheet(context, ref, activeLocale),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            L10n.getLanguageFlag(activeLocale.languageCode),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activeLocale.languageCode.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 82),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        visualDensity: VisualDensity.compact,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n?.skip ?? 'Skip',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final title = _resolveTitle(page, l10n);
                  final desc = _resolveDesc(page, l10n);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final iconSize = (constraints.maxHeight < 400) ? 108.0 : 136.0;
                      final spacing = (constraints.maxHeight < 400) ? 20.0 : 32.0;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 16,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Stylized Illustration Frame
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      page.iconColor.withValues(alpha: 0.22),
                                      page.iconColor.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: page.iconColor.withValues(alpha: 0.35),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.iconColor.withValues(alpha: 0.20),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    page.icon,
                                    size: iconSize * 0.46,
                                    color: page.iconColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing),

                              // Title
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                desc,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Navigation Row
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(_pages.length, (idx) {
                      final isActive = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started Button
                  Flexible(
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              isLastPage ? (l10n?.getStarted ?? 'Get Started') : (l10n?.next ?? 'Next'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
