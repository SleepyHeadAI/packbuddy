import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/locale_provider.dart';
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
  void dispose() {
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

  void _handleApplePlaceholder(BuildContext context, bool isTr) {
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
                isTr
                    ? 'Apple ile Giriş çok yakında sonraki güncellemede aktif edilecektir!'
                    : 'Sign in with Apple will be available in the upcoming update!',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleForgotPassword(BuildContext context, bool isTr) {
    final emailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(isTr ? 'Şifre Sıfırlama' : 'Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTr
                  ? 'Kayıtlı e-posta adresinizi girin, sıfırlama bağlantısı gönderilecektir.'
                  : 'Enter your registered email address to receive a password reset link.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: isTr ? 'E-posta Adresi' : 'Email Address',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isTr ? 'İptal' : 'Cancel'),
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
                  content: Text(
                    isTr
                        ? 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'
                        : 'Password reset link has been dispatched to your email.',
                  ),
                ),
              );
            },
            child: Text(isTr ? 'Gönder' : 'Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final currentLocale = ref.watch(localeProvider);
    final isTr = currentLocale.languageCode == 'tr';
    final l10n = AppLocalizations.of(context);

    final titleText = isTr ? 'PackBuddy' : 'PackBuddy';
    final subtitleText = _mode == AuthMode.signIn
        ? (isTr
            ? 'Lüks Seyahat Asistanınız • Giriş Yapın'
            : 'Your Luxury Travel Companion • Sign In')
        : (isTr
            ? 'Yeni Bir Maceraya Başlayın • Kayıt Olun'
            : 'Begin a New Journey • Create Account');

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
                    _buildModeSelector(isDark, isTr),
                    const SizedBox(height: 24),

                    // 3. Error Banner (if error exists)
                    if (authState.errorMessage != null) ...[
                      _buildErrorBanner(authState.errorMessage!, isDark),
                      const SizedBox(height: 16),
                    ],

                    // 4. Input Fields Card Container
                    _buildFormCard(context, isDark, isTr, l10n),
                    const SizedBox(height: 20),

                    // 5. Primary Submit Button
                    _buildSubmitButton(authState.isLoading, isDark, isTr),
                    const SizedBox(height: 24),

                    // 6. Modern Divider
                    _buildDivider(isDark, isTr),
                    const SizedBox(height: 20),

                    // 7. Social Login Buttons (Google & Apple)
                    _buildSocialButtons(context, authState.isLoading, isDark, isTr),
                    const SizedBox(height: 28),

                    // 8. Terms & Privacy Notice
                    _buildFooterTerms(isDark, isTr),
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
  Widget _buildModeSelector(bool isDark, bool isTr) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFEDF2F7),
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
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
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
                  isTr ? 'Giriş Yap' : 'Sign In',
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
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
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
                  isTr ? 'Kayıt Ol' : 'Sign Up',
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
  Widget _buildErrorBanner(String message, bool isDark) {
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
              message,
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
    bool isTr,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Label & Field
          Text(
            isTr ? 'E-posta Adresi' : 'Email Address',
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
              hintText: isTr ? 'ornek@packbuddy.com' : 'traveler@packbuddy.com',
              prefixIcon: Icons.alternate_email_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isTr
                    ? 'Lütfen e-posta adresinizi girin.'
                    : 'Please enter your email.';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return isTr
                    ? 'Geçerli bir e-posta adresi yazın.'
                    : 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Password Label & Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTr ? 'Şifre' : 'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.onSurfaceDark : AppColors.primaryLight,
                ),
              ),
              if (_mode == AuthMode.signIn)
                GestureDetector(
                  onTap: () => _handleForgotPassword(context, isTr),
                  child: Text(
                    isTr ? 'Şifremi Unuttum?' : 'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.tertiaryLight,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: _mode == AuthMode.signUp
                ? TextInputAction.next
                : TextInputAction.done,
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
                return isTr
                    ? 'Lütfen şifrenizi girin.'
                    : 'Please enter your password.';
              }
              if (_mode == AuthMode.signUp) {
                final strictRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
                if (!strictRegex.hasMatch(value)) {
                  return isTr
                      ? 'Şifre en az 8 karakter olmalı, büyük/küçük harf ve rakam içermelidir.'
                      : 'Password must be at least 8 characters, containing uppercase, lowercase, and a number.';
                }
              } else {
                if (value.length < 6) {
                  return isTr
                      ? 'Şifre en az 6 karakter olmalıdır.'
                      : 'Password must be at least 6 characters.';
                }
              }
              return null;
            },
          ),

          // Password Requirements Hint (Visible in Sign Up mode)
          if (_mode == AuthMode.signUp) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.onSurfaceVariantLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isTr
                        ? 'En az 8 karakter, büyük harf, küçük harf ve rakam gereklidir.'
                        : 'Min 8 chars, uppercase, lowercase & number required.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ),
              ],
            ),
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
                        isTr ? 'Şifre Tekrarı' : 'Confirm Password',
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
                              return isTr
                                  ? 'Lütfen şifrenizi tekrar girin.'
                                  : 'Please confirm your password.';
                            }
                            if (value != _passwordController.text) {
                              return isTr
                                  ? 'Şifreler birbiriyle eşleşmiyor.'
                                  : 'Passwords do not match.';
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

  /// Unified Modern Input Decoration
  InputDecoration _inputDecoration({
    required bool isDark,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
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
          : const Color(0xFFF8FAFC),
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
  Widget _buildSubmitButton(bool isLoading, bool isDark, bool isTr) {
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
                children: [
                  Text(
                    _mode == AuthMode.signIn
                        ? (isTr ? 'Giriş Yap' : 'Sign In')
                        : (isTr ? 'Hesap Oluştur' : 'Create Account'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.onPrimaryDark : Colors.white,
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
  Widget _buildDivider(bool isDark, bool isTr) {
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
            isTr ? 'veya' : 'or continue with',
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
    bool isTr,
  ) {
    return Column(
      children: [
        // Continue with Google
        BouncyPressable(
          onTap: isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
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
                Text(
                  isTr ? 'Google ile Devam Et' : 'Continue with Google',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.onSurfaceDark : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Continue with Apple (Placeholder)
        BouncyPressable(
          onTap: isLoading ? null : () => _handleApplePlaceholder(context, isTr),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
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
                Text(
                  isTr ? 'Apple ile Devam Et' : 'Continue with Apple',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.onSurfaceDark : Colors.black87,
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
  Widget _buildFooterTerms(bool isDark, bool isTr) {
    return Column(
      children: [
        Text(
          isTr
              ? 'Devam ederek Hizmet Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz.'
              : 'By continuing, you agree to our Terms of Service & Privacy Policy.',
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
                      ? (isTr ? 'Hesabınız yok mu? ' : "Don't have an account? ")
                      : (isTr ? 'Zaten hesabınız var mı? ' : 'Already have an account? '),
                ),
                TextSpan(
                  text: _mode == AuthMode.signIn
                      ? (isTr ? 'Kayıt Olun' : 'Sign Up')
                      : (isTr ? 'Giriş Yapın' : 'Sign In'),
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
