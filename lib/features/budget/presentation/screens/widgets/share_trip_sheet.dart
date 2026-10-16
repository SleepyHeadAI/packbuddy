import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/share_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Interactive Sheet for Collaborative Trip Sharing (F-1) & Social Sharing (F-8)
class ShareTripSheet extends ConsumerStatefulWidget {
  final Trip trip;

  const ShareTripSheet({super.key, required this.trip});

  static Future<void> show(BuildContext context, Trip trip) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: ShareTripSheet(trip: trip),
      ),
    );
  }

  @override
  ConsumerState<ShareTripSheet> createState() => _ShareTripSheetState();
}

class _ShareTripSheetState extends ConsumerState<ShareTripSheet> {
  final TextEditingController _collabController = TextEditingController();
  String? _inviteCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inviteCode = widget.trip.inviteCode;
    if (_inviteCode == null || _inviteCode!.isEmpty) {
      _initInviteCode();
    }
  }

  @override
  void dispose() {
    _collabController.dispose();
    super.dispose();
  }

  Future<void> _initInviteCode() async {
    setState(() => _isLoading = true);
    final code = await ref.read(tripControllerProvider.notifier).generateInviteCode(widget.trip.id);
    if (mounted) {
      setState(() {
        _inviteCode = code;
        _isLoading = false;
      });
    }
  }

  Future<void> _addCollaborator() async {
    final text = _collabController.text.trim();
    if (text.isEmpty) return;

    await ref.read(tripControllerProvider.notifier).addCollaborator(widget.trip.id, text);
    _collabController.clear();
    setState(() {});
  }

  Future<void> _removeCollaborator(String email) async {
    await ref.read(tripControllerProvider.notifier).removeCollaborator(widget.trip.id, email);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Watch updated trip from provider
    final trips = ref.watch(tripControllerProvider).trips;
    final currentTrip = trips.firstWhere((t) => t.id == widget.trip.id, orElse: () => widget.trip);
    final code = _inviteCode ?? currentTrip.inviteCode ?? '...';

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.share_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.shareTrip ?? 'Share & Collaborate',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          currentTrip.title.isNotEmpty ? currentTrip.title : currentTrip.destination,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Feature F-1: Invite Code Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.inviteCode ?? 'Collaborator Invite Code',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            code,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: l10n?.copyCode ?? 'Copy Code',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n?.codeCopied ?? 'Invite code copied to clipboard',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          icon: const Icon(Icons.send_rounded, size: 18),
                          tooltip: l10n?.shareTripInvite ?? 'Send Invite',
                          onPressed: () {
                            ShareService.shareInviteCode(
                              trip: currentTrip,
                              inviteCode: code,
                              l10n: l10n,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Collaborators List
              Text(
                '${l10n?.collaborators ?? 'Collaborators'} (${currentTrip.collaborators.length})',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Collaborator input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _collabController,
                      decoration: InputDecoration(
                        hintText: 'alex@example.com / Name',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _addCollaborator(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _addCollaborator,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Icon(Icons.person_add_rounded, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Collaborator chips
              if (currentTrip.collaborators.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: currentTrip.collaborators.map((email) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Text(
                          email.isNotEmpty ? email[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      label: Text(
                        email,
                        style: const TextStyle(fontSize: 11),
                      ),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () => _removeCollaborator(email),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 18),

              // Social Sharing Options (F-8)
              Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text(
                l10n?.shareTrip ?? 'Share Itinerary & Checklist',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.text_snippet_rounded, size: 18),
                      label: Text(
                        l10n?.shareTrip ?? 'Itinerary',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final expenses = ref.read(expenseControllerProvider(currentTrip.id)).expenses;
                        final items = ref.read(checklistControllerProvider).items;
                        ShareService.shareTripSummary(
                          trip: currentTrip,
                          expenses: expenses.where((e) => e.tripId == currentTrip.id).toList(),
                          items: items.where((i) => i.tripId == currentTrip.id).toList(),
                          l10n: l10n,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.checklist_rounded, size: 18),
                      label: Text(
                        l10n?.shareChecklist ?? 'Checklist',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final items = ref.read(checklistControllerProvider).items;
                        ShareService.shareChecklist(
                          tripTitle: currentTrip.title.isNotEmpty ? currentTrip.title : currentTrip.destination,
                          items: items.where((i) => i.tripId == currentTrip.id).toList(),
                          l10n: l10n,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for joining a trip with 6-digit invite code (F-1)
class JoinTripDialog extends StatefulWidget {
  const JoinTripDialog({super.key});

  static Future<Trip?> show(BuildContext context) {
    return showDialog<Trip>(
      context: context,
      builder: (ctx) => const JoinTripDialog(),
    );
  }

  @override
  State<JoinTripDialog> createState() => _JoinTripDialogState();
}

class _JoinTripDialogState extends State<JoinTripDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Consumer(
      builder: (context, ref, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.group_add_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.joinSharedTrip ?? 'Join Shared Trip',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.enterInviteCode ?? 'Enter the 6-character code shared by the trip organizer:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. PB-A1B2C',
                  errorText: _error,
                  prefixIcon: const Icon(Icons.vpn_key_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final code = _codeController.text.trim();
                      if (code.isEmpty) return;

                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });

                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      final joined = await ref
                          .read(tripControllerProvider.notifier)
                          .joinTripByInviteCode(code);

                      if (!mounted) return;

                      if (joined != null) {
                        nav.pop(joined);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.joinSuccess ?? 'Successfully joined trip!',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.successPastel,
                          ),
                        );
                      } else {
                        setState(() {
                          _isLoading = false;
                          _error = l10n?.invalidInviteCode ?? 'Invalid or expired invite code';
                        });
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n?.confirm ?? 'Join'),
            ),
          ],
        );
      },
    );
  }
}
