import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/bouncy_pressable.dart';
import 'auth_controller.dart';

/// Authentication Screen Mode (Sign In vs Sign Up)
enum AuthMode {
  signIn,
  signUp,
}

/// A luxury, visually stunning Authentication Wall screen
/// adhering strictly to PackBuddy's modern travel design system.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (_mode == AuthMode.signUp && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
    });
    ref.read(authControllerProvider.notifier).clearError();
  }

  Future<void> _handleSubmit() async {
    ref.read(authControllerProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final controller = ref.read(authControllerProvider.notifier);

    if (_mode == AuthMode.signIn) {
      await controller.signInWithEmail(email: email, password: password);
    } else {
      await controller.signUpWithEmail(email: email, password: password);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    ref.read(authControllerProvider.notifier).clearError();
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  void _handleApplePlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.primaryLight,
        content: Row(
          children: [
            const Icon(Icons.apple, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.authAppleComingSoon,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleForgotPassword(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(l10n.authResetPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.authResetPasswordDescription,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.authEmail,
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.successPastel,
                  content: Text(l10n.authResetLinkSent),
                ),
              );
            },
            child: Text(l10n.authSendLink),
          ),
        ],
      ),
    );
  }

  String _getLocalizedAuthError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'wrong-password':
        return l10n.authErrorWrongPassword;
      case 'invalid-credential':
        return l10n.authErrorInvalidCredential;
      case 'email-already-in-use':
        return l10n.authErrorEmailInUse;
      case 'invalid-email':
        return l10n.authErrorInvalidEmail;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'network-request-failed':
        return l10n.authErrorNetworkFailed;
      case 'google-sign-in-failed':
        return l10n.authErrorGoogleFailed;
      case 'email-verification-failed':
        return l10n.authErrorVerificationFailed;
      default:
        return l10n.authErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    const titleText = 'PackBuddy';
    final subtitleText = _mode == AuthMode.signIn
        ? l10n.authSubtitleSignIn
        : l10n.authSubtitleSignUp;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Luxury Header & App Brand Logo
                    _buildBrandHeader(isDark, titleText, subtitleText),
                    const SizedBox(height: 28),

                    // 2. Mode Selector Pill (Sign In / Sign Up)
                    _buildModeSelector(isDark, l10n),
                    const SizedBox(height: 24),

                    // 3. Error Banner (if error exists)
                    if (authState.errorMessage != null) ...[
                      _buildErrorBanner(authState.errorMessage!, isDark, l10n),
                      const SizedBox(height: 16),
                    ],

                    // 4. Input Fields Card Container
                    _buildFormCard(context, isDark, l10n),
                    const SizedBox(height: 20),

                    // 5. Primary Submit Button
                    _buildSubmitButton(authState.isLoading, isDark, l10n),
                    const SizedBox(height: 24),

                    // 6. Modern Divider
                    _buildDivider(isDark, l10n),
                    const SizedBox(height: 20),

                    // 7. Social Login Buttons (Google & Apple)
                    _buildSocialButtons(context, authState.isLoading, isDark, l10n),
                    const SizedBox(height: 28),

                    // 8. Terms & Privacy Notice
                    _buildFooterTerms(isDark, l10n),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Luxury Header with Glowing Compass/Luggage Badge
  Widget _buildBrandHeader(bool isDark, String title, String subtitle) {
    return Column(
      children: [
        // App Icon Badge
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [AppColors.primaryDark, Color(0xFF1E3A5F)]
                  : const [AppColors.primaryLight, AppColors.passportNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.luggage_rounded,
                size: 38,
                color: isDark ? AppColors.onPrimaryDark : Colors.white,
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.goldAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Brand Title
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: isDark ? AppColors.onSurfaceDark : AppColors.primaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Animated Subtitle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            subtitle,
            key: ValueKey(_mode),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Animated Sliding Segmented Mode Selector
  Widget _buildModeSelector(bool isDark, AppLocalizations l10n) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: BouncyPressable(
              onTap: () => _switchMode(AuthMode.signIn),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _mode == AuthMode.signIn
                      ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _mode == AuthMode.signIn
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  l10n.authSignIn,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _mode == AuthMode.signIn
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _mode == AuthMode.signIn
                        ? (isDark ? AppColors.onSurfaceDark : AppColors.primaryLight)
                        : (isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariantLight),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BouncyPressable(
              onTap: () => _switchMode(AuthMode.signUp),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _mode == AuthMode.signUp
                      ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _mode == AuthMode.signUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  l10n.authSignUp,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _mode == AuthMode.signUp
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _mode == AuthMode.signUp
                        ? (isDark ? AppColors.onSurfaceDark : AppColors.primaryLight)
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

  /// Refined Error Alert Banner
  Widget _buildErrorBanner(String message, bool isDark, AppLocalizations l10n) {
    final localizedMessage = _getLocalizedAuthError(message, l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorPastel.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.errorPastel.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.errorPastel,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizedMessage,
              style: const TextStyle(
                color: AppColors.errorPastel,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ref.read(authControllerProvider.notifier).clearError(),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.errorPastel,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Rounded Input Fields Container
  Widget _buildFormCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Label & Field
          Text(
            l10n.authEmail,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.onSurfaceDark : AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.onSurfaceDark : Colors.black87,
            ),
            decoration: _inputDecoration(
              isDark: isDark,
              hintText: l10n.authEmailHint,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.authEmailRequired;
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return l10n.authEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Password Label & Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.authPassword,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.onSurfaceDark : AppColors.primaryLight,
                  ),
                ),
              ),
              if (_mode == AuthMode.signIn) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: GestureDetector(
                    onTap: () => _handleForgotPassword(context),
                    child: Text(
                      l10n.authForgotPassword,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.tertiaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: _mode == AuthMode.signUp
                ? TextInputAction.next
                : TextInputAction.done,
            onChanged: (_) {
              if (_mode == AuthMode.signUp) {
                setState(() {});
              }
            },
            onFieldSubmitted: (_) {
              if (_mode == AuthMode.signIn) _handleSubmit();
            },
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.onSurfaceDark : Colors.black87,
            ),
            decoration: _inputDecoration(
              isDark: isDark,
              hintText: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.authPasswordRequired;
              }
              if (_mode == AuthMode.signUp) {
                final strictRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
                if (!strictRegex.hasMatch(value)) {
                  return l10n.authPasswordRulesInvalid;
                }
              } else {
                if (value.length < 6) {
                  return l10n.authPasswordMinChars;
                }
              }
              return null;
            },
          ),

          // Password Requirements Checklist (Visible in Sign Up mode)
          if (_mode == AuthMode.signUp) ...[
            _buildPasswordRules(isDark, l10n),
          ],

          // Confirm Password Field (Animated in Sign Up mode)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _mode == AuthMode.signUp
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Text(
                        l10n.authConfirmPassword,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSubmit(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : Colors.black87,
                        ),
                        decoration: _inputDecoration(
                          isDark: isDark,
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_reset_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariantLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (_mode == AuthMode.signUp) {
                            if (value == null || value.isEmpty) {
                              return l10n.authConfirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return l10n.authPasswordsDoNotMatch;
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Modern 4-point Password Requirements Checklist
  Widget _buildPasswordRules(bool isDark, AppLocalizations l10n) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _passwordController,
      builder: (context, value, _) {
        final pwd = value.text;
        final hasMinLength = pwd.length >= 8;
        final hasUppercase = RegExp(r'[A-Z]').hasMatch(pwd);
        final hasLowercase = RegExp(r'[a-z]').hasMatch(pwd);
        final hasDigit = RegExp(r'[0-9]').hasMatch(pwd);

        final rules = [
          (l10n.authRuleMinChars, hasMinLength),
          (l10n.authRuleUppercase, hasUppercase),
          (l10n.authRuleLowercase, hasLowercase),
          (l10n.authRuleDigit, hasDigit),
        ];

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.outlineDark.withValues(alpha: 0.5)
                  : AppColors.outlineLight.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.authPasswordRulesTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...rules.map((rule) {
                final isMet = rule.$2;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isMet
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isMet
                                ? const Color(0xFF10B981)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.22)),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isMet
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rule.$1,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
                            color: isMet
                                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                : (isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariantLight),
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
      },
    );
  }

  /// Unified Modern Input Decoration
  InputDecoration _inputDecoration({
    required bool isDark,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      errorMaxLines: 2,
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark
            ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.6)
            : AppColors.onSurfaceVariantLight.withValues(alpha: 0.6),
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
          : AppColors.surfaceVariantLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.errorPastel,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.errorPastel,
          width: 1.8,
        ),
      ),
    );
  }

  /// Primary Submit Button with Tactile Bouncy Feedback
  Widget _buildSubmitButton(bool isLoading, bool isDark, AppLocalizations l10n) {
    return BouncyPressable(
      onTap: isLoading ? null : _handleSubmit,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [AppColors.primaryDark, Color(0xFF5E8BAE)]
                : const [AppColors.primaryLight, Color(0xFF1F3859)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  .withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.onPrimaryDark : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _mode == AuthMode.signIn
                            ? l10n.authSignIn
                            : l10n.authCreateAccount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isDark ? AppColors.onPrimaryDark : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _mode == AuthMode.signIn
                        ? Icons.arrow_forward_rounded
                        : Icons.auto_awesome_rounded,
                    size: 18,
                    color: isDark ? AppColors.onPrimaryDark : Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  /// Refined Modern Divider
  Widget _buildDivider(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            l10n.authOr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Social Login Buttons (Google & Apple)
  Widget _buildSocialButtons(
    BuildContext context,
    bool isLoading,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Continue with Google
        BouncyPressable(
          onTap: isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGoogleIconBadge(),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.authContinueWithGoogle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.onSurfaceDark : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Continue with Apple (Placeholder)
        BouncyPressable(
          onTap: isLoading ? null : () => _handleApplePlaceholder(context),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apple,
                  size: 22,
                  color: isDark ? AppColors.onSurfaceDark : Colors.black,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.authContinueWithApple,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.onSurfaceDark : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Stylized Google 'G' Icon Badge
  Widget _buildGoogleIconBadge() {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Google Blue
                    Color(0xFF34A853), // Google Green
                    Color(0xFFFBBC05), // Google Yellow
                    Color(0xFFEA4335), // Google Red
                  ],
                  stops: [0.25, 0.5, 0.75, 1.0],
                ).createShader(const Rect.fromLTWH(0, 0, 22, 22)),
            ),
          ),
        ],
      ),
    );
  }

  /// Terms and Privacy Policy Footer
  Widget _buildFooterTerms(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.authTermsNotice,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.7)
                : AppColors.onSurfaceVariantLight.withValues(alpha: 0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _switchMode(
            _mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn,
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Plus Jakarta Sans',
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariantLight,
              ),
              children: [
                TextSpan(
                  text: _mode == AuthMode.signIn
                      ? l10n.authNoAccount
                      : l10n.authAlreadyHaveAccount,
                ),
                TextSpan(
                  text: _mode == AuthMode.signIn
                      ? l10n.authSignUp
                      : l10n.authSignIn,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
