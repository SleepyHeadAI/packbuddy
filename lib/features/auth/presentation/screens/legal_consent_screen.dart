import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/services/legal_consent_localization.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/bouncy_pressable.dart';
import '../../auth_controller.dart';
import '../../legal_consent_provider.dart';

/// Comprehensive, legally binding User Agreement, Privacy Policy, and Data Processing Consent Screen.
///
/// Fully GDPR (Regulation EU 2016/679), KVKK (No. 6698), and Apple/Google Privacy compliant.
/// - In mandatory gate mode: blocks access to the app until explicitly accepted.
/// - In review mode: allows reviewing terms from Settings with verified timestamp.
class LegalConsentScreen extends ConsumerStatefulWidget {
  /// When true, user cannot dismiss or bypass without accepting.
  /// Declining signs out and exits to login.
  final bool isMandatoryGate;

  /// When true, displayed in read-only review mode from Settings
  final bool isReviewMode;

  const LegalConsentScreen({
    super.key,
    this.isMandatoryGate = true,
    this.isReviewMode = false,
  });

  @override
  ConsumerState<LegalConsentScreen> createState() => _LegalConsentScreenState();
}

class _LegalConsentScreenState extends ConsumerState<LegalConsentScreen> {
  int _selectedTabIndex = 0; // 0: Summary & Permissions, 1: Full Legal Text

  bool _acceptedTerms = false;
  bool _acceptedDataConsent = false;
  bool _acceptedAnalytics = true;
  bool _showValidationError = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isReviewMode) {
      _acceptedTerms = true;
      _acceptedDataConsent = true;
      _acceptedAnalytics = PreferencesService.instance.isAnalyticsConsentGiven();
    }
  }

  Future<void> _handleAccept() async {
    if (!_acceptedTerms || !_acceptedDataConsent) {
      setState(() {
        _showValidationError = true;
      });
      HapticFeedback.vibrate();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showValidationError = false;
    });

    try {
      await ref.read(legalConsentProvider.notifier).acceptConsent(
            version: PreferencesService.currentLegalConsentVersion,
            analyticsConsent: _acceptedAnalytics,
          );

      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('[LegalConsentScreen] Error saving consent: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleDecline() async {
    final lang = ref.read(localeProvider).languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: Color(0xFFE11D48), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  LegalConsentLocalization.getDeclineDialogTitle(lang),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            LegalConsentLocalization.getDeclineDialogContent(lang),
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                AppLocalizations.of(ctx)?.cancel ?? 'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                LegalConsentLocalization.getDeclineButton(lang),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);
    final lang = locale.languageCode;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;

    return PopScope(
      canPop: !widget.isMandatoryGate,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.isMandatoryGate) {
          _handleDecline();
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top App Bar / Navigation
              _buildTopBar(isDark, lang),

              // Pinned Tab Switcher: "Özet & İzinler" vs "Tam Metin (10 Madde)"
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 14 : 20,
                  vertical: 6,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _buildTabSwitcher(isDark, lang),
                  ),
                ),
              ),

              // 2. Scrollable Body Content
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 14 : 20,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Luxury Header with App Logo & Title
                          _buildHeader(isDark, lang, isSmallScreen),
                          const SizedBox(height: 14),

                          // Verified Review Banner (if in review mode)
                          if (widget.isReviewMode) ...[
                            _buildReviewStatusBanner(isDark, lang),
                            const SizedBox(height: 14),
                          ],

                          // Compliance Badges (GDPR, KVKK, AES-256, PII Masked)
                          _buildComplianceBadges(isDark, isSmallScreen),
                          const SizedBox(height: 14),

                          // Selected Tab View
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _selectedTabIndex == 0
                                ? _buildSummaryView(isDark, lang)
                                : _buildArticlesView(isDark, lang),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Fixed Bottom Action Sheet (Checkboxes & Accept/Decline Buttons)
              _buildBottomActionSheet(isDark, lang, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern Top Navigation Bar
  Widget _buildTopBar(bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.isReviewMode || !widget.isMandatoryGate) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel_rounded,
                size: 20,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LegalConsentLocalization.getTitle(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'v${PreferencesService.currentLegalConsentVersion}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Luxury Brand Header
  Widget _buildHeader(bool isDark, String lang, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: isSmallScreen ? 46 : 54,
                  height: isSmallScreen ? 46 : 54,
                  child: const AppLogo(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PackBuddy Legal & Privacy',
                      style: AppTheme.labelFont(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LegalConsentLocalization.getTitle(lang),
                      style: AppTheme.headlineFont(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            LegalConsentLocalization.getSubtitle(lang),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Verified Review Banner
  Widget _buildReviewStatusBanner(bool isDark, String lang) {
    final date = PreferencesService.instance.getLegalConsentDate();
    final version = PreferencesService.instance.getLegalConsentVersion();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: Color(0xFF10B981), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LegalConsentLocalization.getAcceptedStatus(
                      lang, version, date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Kabul Tarihi / Accepted At: $date',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white70
                          : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Badges: GDPR, KVKK, AES-256, Zero-PII
  Widget _buildComplianceBadges(bool isDark, bool isSmallScreen) {
    final badges = [
      ('GDPR (EU 2016/679)', Icons.verified_user_outlined,
          const Color(0xFF2563EB)),
      ('KVKK (6698 Sayılı)', Icons.policy_outlined,
          const Color(0xFF0D9488)),
      ('AES-256 Şifreleme', Icons.lock_outline_rounded,
          const Color(0xFFD97706)),
      ('Sıfır PII Telemetri', Icons.visibility_off_outlined,
          const Color(0xFF10B981)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBadgeWidth = constraints.maxWidth;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.map((badge) {
            return Container(
              constraints: BoxConstraints(maxWidth: maxBadgeWidth),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badge.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: badge.$3.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badge.$2, size: 14, color: badge.$3),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      badge.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badge.$3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Segmented Tab Switcher
  Widget _buildTabSwitcher(bool isDark, String lang) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  LegalConsentLocalization.getTabSummary(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _selectedTabIndex == 0
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: _selectedTabIndex == 0
                        ? (isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight)
                        : (isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariantLight),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  LegalConsentLocalization.getTabArticles(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _selectedTabIndex == 1
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: _selectedTabIndex == 1
                        ? (isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight)
                        : (isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariantLight),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 0: 8 Data & Permission Summary Cards
  Widget _buildSummaryView(bool isDark, String lang) {
    final categories = LegalConsentLocalization.getCategories(lang);

    return Column(
      children: categories.map((cat) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cat.accentColor
                          .withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(cat.icon, size: 20, color: cat.accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurfaceLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariantLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...cat.bulletPoints.map((bp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: cat.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bp,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: isDark
                                ? AppColors.onSurfaceDark.withValues(alpha: 0.9)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Tab 1: 10 Full Legal Articles
  Widget _buildArticlesView(bool isDark, String lang) {
    final articles = LegalConsentLocalization.getArticles(lang);

    return Column(
      children: articles.map((article) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Madde ${article.number}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                article.content,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Bottom Sticky Action Sheet
  Widget _buildBottomActionSheet(
      bool isDark, String lang, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 20,
        vertical: isSmallScreen ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isReviewMode) ...[
                // Mandatory Checkbox 1: Terms of Service & Privacy Policy
                _buildCheckboxRow(
                  value: _acceptedTerms,
                  isDark: isDark,
                  isSmallScreen: isSmallScreen,
                  onChanged: (val) {
                    setState(() {
                      _acceptedTerms = val ?? false;
                      if (_acceptedTerms && _acceptedDataConsent) {
                        _showValidationError = false;
                      }
                    });
                  },
                  label:
                      LegalConsentLocalization.getMandatoryTermsCheckbox(lang),
                  isMandatory: true,
                ),
                SizedBox(height: isSmallScreen ? 5 : 8),

                // Mandatory Checkbox 2: Explicit Data Processing Consent
                _buildCheckboxRow(
                  value: _acceptedDataConsent,
                  isDark: isDark,
                  isSmallScreen: isSmallScreen,
                  onChanged: (val) {
                    setState(() {
                      _acceptedDataConsent = val ?? false;
                      if (_acceptedTerms && _acceptedDataConsent) {
                        _showValidationError = false;
                      }
                    });
                  },
                  label: LegalConsentLocalization
                      .getMandatoryDataConsentCheckbox(lang),
                  isMandatory: true,
                ),
                SizedBox(height: isSmallScreen ? 5 : 8),

                // Optional Checkbox 3: Telemetry & Analytics
                _buildCheckboxRow(
                  value: _acceptedAnalytics,
                  isDark: isDark,
                  isSmallScreen: isSmallScreen,
                  onChanged: (val) {
                    setState(() {
                      _acceptedAnalytics = val ?? false;
                    });
                  },
                  label:
                      LegalConsentLocalization.getOptionalAnalyticsCheckbox(lang),
                  isMandatory: false,
                ),

                // Validation Error Banner
                if (_showValidationError) ...[
                  const SizedBox(height: 6),
                  Text(
                    LegalConsentLocalization.getValidationMustAccept(lang),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ],
                SizedBox(height: isSmallScreen ? 8 : 14),

                // Primary & Secondary Action Buttons
                Row(
                  children: [
                    // Decline & Exit Button
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _handleDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size(0, isSmallScreen ? 44 : 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: const Color(0xFFE11D48)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            LegalConsentLocalization.getDeclineButton(lang),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Accept & Continue Button
                    Expanded(
                      flex: 6,
                      child: BouncyPressable(
                        onTap: _isSubmitting ? null : _handleAccept,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: isSmallScreen ? 44 : 48,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [
                                      AppColors.primaryDark,
                                      Color(0xFFD4A054)
                                    ]
                                  : const [
                                      AppColors.primaryLight,
                                      Color(0xFF6E5203)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primaryLight)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        LegalConsentLocalization.getAcceptButton(
                                            lang),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12.5 : 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? AppColors.onPrimaryDark
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: isSmallScreen ? 15 : 16,
                                        color: isDark
                                            ? AppColors.onPrimaryDark
                                            : Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Close button in Review Mode
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    foregroundColor:
                        isDark ? AppColors.onPrimaryDark : Colors.white,
                    minimumSize: Size.fromHeight(isSmallScreen ? 44 : 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    LegalConsentLocalization.getCloseButton(lang),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Custom Checkbox Row with Responsive Label
  Widget _buildCheckboxRow({
    required bool value,
    required bool isDark,
    required bool isSmallScreen,
    required ValueChanged<bool?> onChanged,
    required String label,
    required bool isMandatory,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: SizedBox(
              width: isSmallScreen ? 18 : 20,
              height: isSmallScreen ? 18 : 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: isDark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                checkColor:
                    isDark ? AppColors.onPrimaryDark : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                side: BorderSide(
                  color: isDark
                      ? AppColors.outlineDark
                      : AppColors.outlineLight,
                  width: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                height: 1.35,
                fontWeight: isMandatory ? FontWeight.w600 : FontWeight.w400,
                color: isDark
                    ? AppColors.onSurfaceDark
                    : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
