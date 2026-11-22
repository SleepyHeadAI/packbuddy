import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../../l10n/app_localizations.dart';
import '../l10n/app_l10n_lookup.dart';
import '../utils/currency_formatter.dart';
import 'package:packbuddy/core/constants/app_constants.dart';

/// Social & Itinerary Sharing Service (Feature F-8 & F-1)
class ShareService {
  ShareService._();

  /// Formats and shares a complete travel trip itinerary and budget summary
  static Future<bool> shareTripSummary({
    required Trip trip,
    List<Expense> expenses = const [],
    List<PackingItem> items = const [],
    AppLocalizations? l10n,
  }) async {
    final t = l10n ?? appL10nFor();
    final title = trip.title.isNotEmpty ? trip.title : trip.destination;
    final totalSpent = expenses.where((e) => !e.isDeleted).fold<double>(
          0.0,
          (sum, e) => sum + e.amount,
        );
    final packedCount = items.where((i) => i.isPacked && !i.isDeleted).length;
    final totalItems = items.where((i) => !i.isDeleted).length;

    final buffer = StringBuffer();
    buffer.writeln('✈️ $title');
    buffer.writeln('📍 ${trip.destination}');
    buffer.writeln('📅 ${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} - ${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}');
    buffer.writeln('');
    final budgetLabel = t.budget;
    final spentLabel = t.spent;
    buffer.writeln('💰 $budgetLabel: ${trip.budgetLimit != null ? CurrencyFormatter.format(trip.budgetLimit!, currency: trip.defaultCurrency) : t.shareNotSpecified}');
    buffer.writeln('💳 $spentLabel: ${CurrencyFormatter.format(totalSpent, currency: trip.defaultCurrency)}');
    if (totalItems > 0) {
      final checklistLabel = t.shareChecklist;
      final pct = ((packedCount / totalItems) * 100).toInt();
      buffer.writeln('🎒 $checklistLabel: $packedCount / $totalItems ($pct%)');
    }

    if (AppConstants.kInviteCodeJoinEnabled && trip.inviteCode != null && trip.inviteCode!.isNotEmpty) {
      buffer.writeln('');
      final joinTripLabel = t.joinSharedTrip;
      buffer.writeln('🤝 $joinTripLabel: ${trip.inviteCode}');
    }

    buffer.writeln('');
    buffer.writeln(t.shareFooterTagline);

    return await _shareText(buffer.toString(), subject: t.shareTripSubject(title));
  }

  /// Formats and shares packing checklist
  static Future<bool> shareChecklist({
    required String tripTitle,
    required List<PackingItem> items,
    AppLocalizations? l10n,
  }) async {
    final t = l10n ?? appL10nFor();
    final buffer = StringBuffer();
    final checklistTitle = t.shareChecklist;
    buffer.writeln('🎒 $checklistTitle: $tripTitle');
    buffer.writeln('');

    // Group items by category
    final grouped = <String, List<PackingItem>>{};
    for (final item in items.where((i) => !i.isDeleted)) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    for (final entry in grouped.entries) {
      buffer.writeln('📁 ${entry.key}:');
      for (final item in entry.value) {
        final box = item.isPacked ? '[x]' : '[ ]';
        final qty = item.quantity > 1 ? ' (x${item.quantity})' : '';
        final assignee = item.assignedTo != null ? ' [@${item.assignedTo}]' : '';
        buffer.writeln('  $box ${item.name}$qty$assignee');
      }
      buffer.writeln('');
    }

    buffer.writeln(t.shareFooterShort);
    return await _shareText(buffer.toString(), subject: t.shareChecklistSubject(tripTitle));
  }

  /// Shares collaboration invite code for a trip
  static Future<bool> shareInviteCode({
    required Trip trip,
    required String inviteCode,
    AppLocalizations? l10n,
  }) async {
    final title = trip.title.isNotEmpty ? trip.title : trip.destination;
    final t = l10n ?? appL10nFor();
    final text = '${t.shareInviteText(title)}\n\n'
        '${t.inviteCode}: $inviteCode\n\n'
        '${t.shareInviteHowTo}';
    return await _shareText(text, subject: t.shareInviteSubject(title));
  }

  /// Public helper to share arbitrary text across channels with clipboard fallback
  static Future<bool> shareText({required String text, String? subject}) async {
    return _shareText(text, subject: subject);
  }

  static Future<bool> _shareText(String text, {String? subject}) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
        ),
      );
      return result.status == ShareResultStatus.success;
    } catch (_) {
      // Graceful fallback to clipboard
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    }
  }
}
