import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/biometric_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import '../../controllers/vault_controller.dart';
import 'vault_pin_recovery_sheet.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_localization.dart';

/// Secure PIN and Biometric authentication gate for Document Vault
class VaultLockView extends ConsumerStatefulWidget {
  final bool isTabMode;

  const VaultLockView({
    super.key,
    this.isTabMode = false,
  });

  @override
  ConsumerState<VaultLockView> createState() => _VaultLockViewState();
}

class _VaultLockViewState extends ConsumerState<VaultLockView> with WidgetsBindingObserver {
  String _enteredPin = '';
  bool _isError = false;
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;
  Timer? _lockoutTimer;
  int _lockoutRemainingSeconds = 0;
  int _remainingAttempts = 5;

  @override
  void initState() {
    super.initState();
    _remainingAttempts = ref.read(vaultControllerProvider.notifier).getRemainingPinAttempts();
    _checkBiometrics();
    _checkLockout();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _checkLockout() {
    final controller = ref.read(vaultControllerProvider.notifier);
    if (controller.isPinLockedOut()) {
      _lockoutRemainingSeconds = controller.getPinLockoutRemainingSeconds();
      _startLockoutCountdown();
    }
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(vaultControllerProvider.notifier).getPinLockoutRemainingSeconds();
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _lockoutRemainingSeconds = 0;
          _isError = false;
        });
      } else {
        setState(() {
          _lockoutRemainingSeconds = remaining;
        });
      }
    });
  }

  String _formatLockoutTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _checkBiometrics() async {
    final available = await BiometricService.instance.isBiometricsAvailable();
    if (!mounted) return;
    setState(() => _canCheckBiometrics = available);

    // STRICT ISOLATION GUARD:
    // Only auto-trigger biometric prompt if user actively opened Vault tab in shell!
    // NEVER auto-trigger on background resume or screen lock/unlock!
    final currentTab = ref.read(mainNavigationIndexProvider);
    final isVaultActive = !widget.isTabMode || currentTab == 3;
    if (!isVaultActive) {
      return;
    }

    final vaultState = ref.read(vaultControllerProvider);
    if (available && vaultState.isBiometricEnabled && vaultState.hasPin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final tabNow = ref.read(mainNavigationIndexProvider);
        final isStillVaultActive = !widget.isTabMode || tabNow == 3;
        if (isStillVaultActive && ref.read(vaultControllerProvider).isLocked) {
          _triggerBiometricAuth();
        }
      });
    }
  }

  Future<void> _triggerBiometricAuth() async {
    if (_isAuthenticating) return;

    // Strict guard: Never prompt biometrics if user is on another page
    final currentTab = ref.read(mainNavigationIndexProvider);
    final isVaultActive = !widget.isTabMode || currentTab == 3;
    if (!isVaultActive) {
      return;
    }

    _isAuthenticating = true;
    try {
      HapticFeedback.mediumImpact();
      final l10n = AppLocalizations.of(context);
      final reason = l10n?.vaultBiometricReason ??
          'Kasanın kilidini açmak için parmak izinizi doğrulayın';
      await ref
          .read(vaultControllerProvider.notifier)
          .authenticateWithBiometrics(reason: reason);
    } finally {
      if (mounted) {
        _isAuthenticating = false;
      }
    }
  }

  void _onDigitPressed(String digit) {
    if (_lockoutRemainingSeconds > 0) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (_enteredPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _isError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_lockoutRemainingSeconds > 0) return;
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _isError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    final controller = ref.read(vaultControllerProvider.notifier);
    if (controller.isPinLockedOut()) {
      _checkLockout();
      return;
    }

    final success = controller.unlockVault(_enteredPin);

    if (success) {
      _lockoutTimer?.cancel();
      _lockoutRemainingSeconds = 0;
      _remainingAttempts = 5;
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
      final remaining = controller.getRemainingPinAttempts();
      setState(() {
        _isError = true;
        _enteredPin = '';
        _remainingAttempts = remaining;
      });

      final lang = Localizations.localeOf(context).languageCode;
      if (controller.isPinLockedOut()) {
        _checkLockout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DashboardLocalization.vaultLockedSnackbar(lang),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        final errorMsg = DashboardLocalization.vaultIncorrectPinBanner(lang, remaining, 5);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showSetPinDialog() {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.setVaultPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createPinToProtect,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.fourDigitPin,
                prefixIcon: const Icon(Icons.pin_rounded),
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
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                await ref.read(vaultControllerProvider.notifier).setPin(pin);
                if (await BiometricService.instance.isBiometricsAvailable()) {
                  await ref.read(vaultControllerProvider.notifier).setBiometricEnabled(true);
                }
                ref.read(vaultControllerProvider.notifier).unlockVault(pin);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              }
            },
            child: Text(l10n.saveAndOpen),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final vaultState = ref.watch(vaultControllerProvider);

    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Shield Lock Icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight,
                border: Border.all(
                  color: _isError
                      ? AppColors.errorPastel
                      : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                  width: 2,
                ),
              ),
              child: Icon(
                _isError ? Icons.lock_clock_rounded : Icons.lock_outline_rounded,
                size: 44,
                color: _isError
                    ? AppColors.errorPastel
                    : (isDark ? AppColors.primaryAmber : AppColors.primaryLight),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              vaultState.hasPin ? l10n.vaultLocked : l10n.vaultPinRequiredTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vaultState.hasPin
                  ? l10n.enterPinToUnlockVault
                  : l10n.vaultPinRequiredDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            if (_lockoutRemainingSeconds > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.errorPastel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.errorPastel.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_rounded, color: AppColors.errorPastel, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          DashboardLocalization.vaultLockedTitle(
                            Localizations.localeOf(context).languageCode,
                            _formatLockoutTime(_lockoutRemainingSeconds),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.errorPastel,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DashboardLocalization.vaultLockedDesc(
                        Localizations.localeOf(context).languageCode,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (vaultState.hasPin) ...[
              // PIN Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? (_isError ? AppColors.errorPastel : theme.colorScheme.primary)
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      border: Border.all(
                        color: _isError
                            ? AppColors.errorPastel
                            : (isFilled ? theme.colorScheme.primary : theme.colorScheme.outline),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Prominently Visible In-Place Warning Banner & Remaining Attempt Counter
              if (_lockoutRemainingSeconds <= 0 && (_isError || _remainingAttempts < 5)) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.errorPastel.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.errorPastel.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.errorPastel,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DashboardLocalization.vaultIncorrectPinBanner(
                          Localizations.localeOf(context).languageCode,
                          _remainingAttempts,
                          5,
                        ),
                        style: const TextStyle(
                          color: AppColors.errorPastel,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                const SizedBox(height: 36),
              ],

              // Number Pad (1-9, 0, Backspace, Biometric)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  children: [
                    _buildKeyRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildKeyRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildKeyRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Biometric / FaceID trigger
                        if (_canCheckBiometrics && vaultState.isBiometricEnabled)
                          _buildActionButton(
                            icon: Icons.fingerprint_rounded,
                            onTap: _triggerBiometricAuth,
                          )
                        else
                          const SizedBox(width: 68, height: 68),
                        _buildNumberKey('0'),
                        // Backspace
                        _buildActionButton(
                          icon: Icons.backspace_outlined,
                          onTap: _onBackspace,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Forgot PIN Action
                    TextButton.icon(
                      key: const Key('forgot_vault_pin_button'),
                      onPressed: () async {
                        final reset = await VaultPinRecoverySheet.show(context);
                        if (reset == true && mounted) {
                          _lockoutTimer?.cancel();
                          setState(() {
                            _lockoutRemainingSeconds = 0;
                            _isError = false;
                            _enteredPin = '';
                          });
                        }
                      },
                      icon: const Icon(Icons.help_outline_rounded, size: 16),
                      label: Text(
                        l10n.forgotPin,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Setup PIN Button (Mandatory - No continue unlocked!)
              FilledButton.icon(
                onPressed: _showSetPinDialog,
                icon: const Icon(Icons.shield_outlined),
                label: Text(l10n.createPinAndProtect),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumberKey(d)).toList(),
    );
  }

  Widget _buildNumberKey(String digit) {
    final theme = Theme.of(context);
    final isLockedOut = _lockoutRemainingSeconds > 0;
    return Opacity(
      opacity: isLockedOut ? 0.35 : 1.0,
      child: InkWell(
        onTap: isLockedOut ? null : () => _onDigitPressed(digit),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isLockedOut = _lockoutRemainingSeconds > 0;
    return Opacity(
      opacity: isLockedOut ? 0.35 : 1.0,
      child: InkWell(
        onTap: isLockedOut ? null : onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 26, color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
