import 'package:flutter/material.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
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
class OnboardingScreen extends StatefulWidget {
  final bool isReplay;

  const OnboardingScreen({super.key, this.isReplay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.flight_takeoff_rounded,
      iconColor: Color(0xFF0284C7),
      titleKey: 'onboardingTitle1',
      descKey: 'onboardingDesc1',
      defaultTitle: 'Plan Trips Effortlessly',
      defaultDesc:
          'Organize multi-currency travel budgets and track daily expenses anywhere in the world.',
    ),
    OnboardingPageData(
      icon: Icons.checklist_rtl_rounded,
      iconColor: Color(0xFF10B981),
      titleKey: 'onboardingTitle2',
      descKey: 'onboardingDesc2',
      defaultTitle: 'Smart Packing Checklists',
      defaultDesc:
          'Airline baggage guidelines and smart category templates ensure you never forget essentials.',
    ),
    OnboardingPageData(
      icon: Icons.groups_rounded,
      iconColor: Color(0xFF8B5CF6),
      titleKey: 'onboardingTitle3',
      descKey: 'onboardingDesc3',
      defaultTitle: 'Collaborate in Real-Time',
      defaultDesc:
          'Share your trip plans and checklists with friends and family with simple 6-digit invite codes.',
    ),
    OnboardingPageData(
      icon: Icons.lock_person_rounded,
      iconColor: Color(0xFFEC4899),
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

    if (widget.isReplay) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
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
    final l10n = AppLocalizations.of(context);

    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App branding badge
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
                      Text(
                        'PackBuddy',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      l10n?.skip ?? 'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
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

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stylized Illustration Frame
                        Container(
                          width: 140,
                          height: 140,
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
                              size: 64,
                              color: page.iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),

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
