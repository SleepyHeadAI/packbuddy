import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/email_dispatch_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_localization.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Interactive modal sheet guiding users through Email Verification and Vault PIN Reset
class VaultPinRecoverySheet extends ConsumerStatefulWidget {
  final String? testVerificationCode;

  const VaultPinRecoverySheet({
    super.key,
    this.testVerificationCode,
  });

  static Future<bool?> show(BuildContext context, {String? testVerificationCode}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VaultPinRecoverySheet(testVerificationCode: testVerificationCode),
    );
  }

  @override
  ConsumerState<VaultPinRecoverySheet> createState() => _VaultPinRecoverySheetState();
}

class _VaultPinRecoverySheetState extends ConsumerState<VaultPinRecoverySheet> {
  int _currentStep = 0; // 0: Email, 1: 6-digit Code, 2: New PIN

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String? _generatedCode;
  String? _errorMessage;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authUserProvider);
    if (authUser?.email != null && authUser!.email!.isNotEmpty) {
      _emailController.text = authUser.email!;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _resendCountdown = 0);
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = l10n.invalidEmail);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSending = true;
    });

    final code = widget.testVerificationCode ?? (100000 + Random().nextInt(900000)).toString();
    _generatedCode = code;

    // 1. Dispatch instant heads-up notification to device
    try {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        await LocalNotificationService().showInstantNotification(
          id: 998877,
          title: 'PackBuddy - ${l10n.resetVaultPinTitle}',
          body: '${l10n.verificationCode}: $code',
        );
      }
    } catch (_) {}

    // 2. Dispatch email draft via system client (non-blocking fallback)
    try {
      await EmailDispatchService.instance.launchEmailDraft(
        toEmail: email,
        subject: 'PackBuddy - ${l10n.resetVaultPinTitle}',
        body: '${l10n.verificationCode}: $code\n\n${l10n.enterVerificationCodeDesc}',
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSending = false;
        _currentStep = 1;
      });
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.codeResent} ($code)'),
          backgroundColor: AppColors.successPastel,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _verifyCode() {
    final l10n = AppLocalizations.of(context)!;
    final entered = _codeController.text.trim();

    if (entered.isEmpty || entered.length != 6 || (_generatedCode != null && entered != _generatedCode)) {
      HapticFeedback.heavyImpact();
      setState(() => _errorMessage = l10n.invalidVerificationCode);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _errorMessage = null;
      _currentStep = 2;
    });
  }

  Future<void> _saveNewPin() async {
    final l10n = AppLocalizations.of(context)!;
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(newPin)) {
      setState(() => _errorMessage = l10n.fourDigitPin);
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorMessage = l10n.pinsDoNotMatch);
      return;
    }

    setState(() => _errorMessage = null);

    // Persist new PIN and unlock vault
    await ref.read(vaultControllerProvider.notifier).setPin(newPin);
    ref.read(vaultControllerProvider.notifier).unlockVault(newPin);

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.vaultPinResetSuccess)),
            ],
          ),
          backgroundColor: AppColors.successPastel,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentStep == 0
                        ? Icons.mark_email_read_rounded
                        : (_currentStep == 1 ? Icons.pin_rounded : Icons.lock_reset_rounded),
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentStep == 2 ? l10n.setNewVaultPin : l10n.resetVaultPinTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error banner if any
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.errorPastel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.errorPastel.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.errorPastel, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.errorPastel, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Step Content
            if (_currentStep == 0) _buildEmailStep(l10n, theme),
            if (_currentStep == 1) _buildCodeStep(l10n, theme),
            if (_currentStep == 2) _buildNewPinStep(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.resetVaultPinEmailDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('recovery_email_field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.enterYourEmail,
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('send_recovery_code_button'),
          onPressed: _isSending ? null : _sendCode,
          icon: _isSending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded),
          label: Text(l10n.sendVerificationCode),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep(AppLocalizations l10n, ThemeData theme) {
    final email = _emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.enterVerificationCodeDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 14),
        if (_generatedCode != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mark_email_read_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.verificationCode}:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _generatedCode!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  key: const Key('autofill_recovery_code_button'),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _codeController.text = _generatedCode!;
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 5),
                        Text(
                          DashboardLocalization.vaultAutofillCode(
                            Localizations.localeOf(context).languageCode,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          key: const Key('recovery_verification_code_field'),
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _resendCountdown == 0 ? _sendCode : null,
              child: Text(
                _resendCountdown > 0
                    ? '${l10n.resendCode} (${_resendCountdown}s)'
                    : l10n.resendCode,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _currentStep = 0;
                _errorMessage = null;
              }),
              child: Text(l10n.cancel, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton(
          key: const Key('verify_recovery_code_button'),
          onPressed: _verifyCode,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(l10n.verifyAndContinue),
        ),
      ],
    );
  }

  Widget _buildNewPinStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.vaultPinRequiredDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('new_vault_pin_field'),
          controller: _newPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.newPin,
            prefixIcon: const Icon(Icons.pin_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('confirm_vault_pin_field'),
          controller: _confirmPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.confirmNewPin,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('save_new_vault_pin_button'),
          onPressed: _saveNewPin,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(l10n.saveNewPinAndUnlock),
        ),
      ],
    );
  }
}

