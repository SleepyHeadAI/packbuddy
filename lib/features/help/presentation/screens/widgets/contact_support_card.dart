import 'package:flutter/material.dart';
import 'package:packbuddy/core/constants/app_constants.dart';
import 'package:packbuddy/core/services/email_dispatch_service.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';

/// Support and walkthrough action card shown at the bottom of the Help screen
class ContactSupportCard extends StatelessWidget {
  final String languageCode;

  const ContactSupportCard({
    super.key,
    required this.languageCode,
  });

  Future<void> _contactSupport(BuildContext context) async {
    final success = await EmailDispatchService.instance.launchEmailDraft(
      toEmail: 'sleepyheadaitr@gmail.com',
      subject: 'PackBuddy Help & Support [v${AppConstants.appVersion}]',
      body: '\n\n---\nApp Version: ${AppConstants.appVersion}\nLocale: $languageCode\nPlatform: Mobile',
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email: sleepyheadaitr@gmail.com'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(18),
          borderRadius: 22,
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainer
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          border: BorderSide(
            color: isDark
                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.25)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HelpLocalization.getContactUs(languageCode),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          HelpLocalization.getContactUsSubtitle(languageCode),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: const Icon(Icons.mail_outline_rounded, size: 18),
                  label: Text(
                    HelpLocalization.getSendEmail(languageCode),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(isReplay: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: Text(
                    HelpLocalization.getReplayWalkthrough(languageCode),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
