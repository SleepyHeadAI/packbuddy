import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../shared/widgets/bouncy_pressable.dart';
import '../../auth_controller.dart';

/// Luxury Email Verification Gate screen ensuring accounts are fully verified
/// before gaining access to PackBuddy travel vaults and cloud sync.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _autoCheckTimer;
  Timer? _cooldownTimer;
  int _resendCooldownSeconds = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Start periodic background verification poller (checks every 4 seconds)
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted) return;
      final isVerified =
          await ref.read(authControllerProvider.notifier).reloadUser();
      if (isVerified) {
        _autoCheckTimer?.cancel();
      }
    });
  }

  Future<void> _handleManualCheck(bool isTr) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final isVerified =
        await ref.read(authControllerProvider.notifier).reloadUser();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.primaryLight,
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isTr
                      ? 'E-postanız henüz doğrulanmadı. Lütfen gelen kutunuzdaki bağlantıya tıklayın.'
                      : 'Email is not verified yet. Please check your inbox and click the link.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleResendLink(bool isTr) async {
    if (_resendCooldownSeconds > 0) return;

    final success =
        await ref.read(authControllerProvider.notifier).sendEmailVerification();

    if (!mounted) return;

    if (success) {
      setState(() => _resendCooldownSeconds = 30);
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_resendCooldownSeconds <= 1) {
          timer.cancel();
          setState(() => _resendCooldownSeconds = 0);
        } else {
          setState(() => _resendCooldownSeconds--);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.successPastel,
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isTr
                      ? 'Doğrulama bağlantısı e-posta adresinize tekrar gönderildi!'
                      : 'Verification email has been resent to your address!',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);
    final isTr = currentLocale.languageCode == 'tr';
    final user = ref.watch(authUserProvider);
    final email = user?.email ?? 'traveler@packbuddy.com';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // 1. Glowing Envelope Icon Badge
                  _buildEnvelopeBadge(isDark),
                  const SizedBox(height: 24),

                  // 2. Title & User Email Pill
                  Text(
                    isTr ? 'E-postanızı Doğrulayın' : 'Verify Your Email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.primaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Recipient Email Capsule
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.primaryContainerLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.outlineDark
                              : AppColors.outlineLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alternate_email_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.primaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Informational Instruction Card
                  _buildInstructionCard(isDark, isTr),
                  const SizedBox(height: 24),

                  // 4. Polling Status Badge
                  _buildPollerIndicator(isDark, isTr),
                  const SizedBox(height: 28),

                  // 5. "Doğrulamayı Kontrol Et" Primary Action
                  BouncyPressable(
                    onTap: () => _handleManualCheck(isTr),
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
                            color: (isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight)
                                .withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isChecking
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
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isTr
                                      ? 'Doğrulamayı Kontrol Et'
                                      : 'Check Verification Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: isDark
                                        ? AppColors.onPrimaryDark
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 6. "Doğrulama Linkini Tekrar Gönder" Action
                  BouncyPressable(
                    onTap: _resendCooldownSeconds > 0
                        ? null
                        : () => _handleResendLink(isTr),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? AppColors.outlineDark
                              : AppColors.outlineLight,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: _resendCooldownSeconds > 0
                                ? (isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariantLight)
                                : (isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _resendCooldownSeconds > 0
                                ? (isTr
                                    ? 'Tekrar Gönder ($_resendCooldownSeconds sn)'
                                    : 'Resend Link ($_resendCooldownSeconds s)')
                                : (isTr
                                    ? 'Doğrulama Linkini Tekrar Gönder'
                                    : 'Resend Verification Link'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: _resendCooldownSeconds > 0
                                  ? (isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariantLight)
                                  : (isDark
                                      ? AppColors.onSurfaceDark
                                      : AppColors.primaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 7. "Giriş Ekranına Dön" Action
                  Center(
                    child: TextButton.icon(
                      onPressed: _handleSignOut,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: Text(
                        isTr ? 'Giriş Ekranına Dön' : 'Back to Sign In',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Stylized Mail Envelope Icon Badge
  Widget _buildEnvelopeBadge(bool isDark) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [AppColors.primaryDark, Color(0xFF1E3A5F)]
                : const [AppColors.primaryLight, AppColors.passportNavy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  .withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_rounded,
              size: 42,
              color: isDark ? AppColors.onPrimaryDark : Colors.white,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: AppColors.goldAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Informational Card Explaining Next Steps
  Widget _buildInstructionCard(bool isDark, bool isTr) {
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr
                          ? 'Gelen Kutunuzu Kontrol Edin'
                          : 'Check Your Inbox',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTr
                          ? 'E-posta adresinize bir doğrulama bağlantısı ilettik. Spam veya Gereksiz klasörünü de kontrol etmeyi unutmayın.'
                          : 'We dispatched a verification link to your inbox. Be sure to check your spam or junk folder as well.',
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successPastel.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync_lock_rounded,
                  size: 20,
                  color: AppColors.successPastel,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr
                          ? 'Otomatik Erişim Açılışı'
                          : 'Instant Unlocking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTr
                          ? 'Bağlantıya tıkladığınız anda seyahat panonuz otomatik olarak açılacaktır.'
                          : 'Once you click the link, your travel dashboard unlocks automatically.',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Live Background Polling Indicator
  Widget _buildPollerIndicator(bool isDark, bool isTr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          isTr
              ? 'Doğrulama bağlantısı bekleniyor...'
              : 'Waiting for verification link click...',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.onSurfaceVariantDark
                : AppColors.onSurfaceVariantLight,
          ),
        ),
      ],
    );
  }
}
