import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import '../../controllers/vault_controller.dart';

/// Secure PIN and Biometric authentication gate for Document Vault
class VaultLockView extends ConsumerStatefulWidget {
  const VaultLockView({super.key});

  @override
  ConsumerState<VaultLockView> createState() => _VaultLockViewState();
}

class _VaultLockViewState extends ConsumerState<VaultLockView> {
  String _enteredPin = '';
  bool _isError = false;

  void _onDigitPressed(String digit) {
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
    final success = controller.unlockVault(_enteredPin);

    if (success) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
      final l10n = AppLocalizations.of(context)!;
      final errorMsg = l10n.wrongPinTryAgain;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: AppColors.errorPastel,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                ref.read(vaultControllerProvider.notifier).setPin(pin);
                ref.read(vaultControllerProvider.notifier).unlockVault(pin);
                Navigator.of(ctx).pop();
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
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _isError ? AppColors.errorPastel : theme.colorScheme.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                _isError ? Icons.lock_clock_rounded : Icons.lock_outline_rounded,
                size: 44,
                color: _isError ? AppColors.errorPastel : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              l10n.vaultLocked,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vaultState.hasPin
                  ? l10n.enterPinToUnlockVault
                  : l10n.vaultNotProtectedWithPin,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

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
              const SizedBox(height: 36),

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
                        _buildActionButton(
                          icon: Icons.fingerprint_rounded,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(vaultControllerProvider.notifier).authenticateWithBiometrics();
                          },
                        ),
                        _buildNumberKey('0'),
                        // Backspace
                        _buildActionButton(
                          icon: Icons.backspace_outlined,
                          onTap: _onBackspace,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Setup PIN Button
              FilledButton.icon(
                onPressed: _showSetPinDialog,
                icon: const Icon(Icons.shield_outlined),
                label: Text(l10n.createPinAndProtect),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(vaultControllerProvider.notifier).unlockVault('');
                },
                child: Text(l10n.continueUnlocked),
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
    return InkWell(
      onTap: () => _onDigitPressed(digit),
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
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
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
    );
  }
}
