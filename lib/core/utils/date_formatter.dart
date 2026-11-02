import 'package:intl/intl.dart';

/// Resilient, fail-safe date formatter utility that prevents LocaleDataExceptions
/// across all 20+ supported languages in PackBuddy.
class AppDateFormatter {
  /// Safely formats a date using MMMd (e.g., '14 Eyl' or 'Sep 14')
  static String formatMMMd(DateTime date, {String? locale}) {
    try {
      final loc = (locale != null && locale.isNotEmpty) ? locale : (Intl.defaultLocale ?? 'en');
      return DateFormat.MMMd(loc).format(date);
    } catch (_) {
      try {
        return DateFormat.MMMd('en').format(date);
      } catch (_) {
        return '${date.day}.${date.month}';
      }
    }
  }

  /// Safely formats a date using yMMMd (e.g., '14 Eyl 2026' or 'Sep 14, 2026')
  static String formatYMMMd(DateTime date, {String? locale}) {
    try {
      final loc = (locale != null && locale.isNotEmpty) ? locale : (Intl.defaultLocale ?? 'en');
      return DateFormat.yMMMd(loc).format(date);
    } catch (_) {
      try {
        return DateFormat.yMMMd('en').format(date);
      } catch (_) {
        return '${date.day}.${date.month}.${date.year}';
      }
    }
  }

  /// Safely formats a date range (e.g., '14 Eyl - 19 Eyl' or '14 Eyl 2026 - 19 Eyl 2026')
  static String formatDateRange(DateTime start, DateTime end, {String? locale, bool includeYear = false}) {
    if (includeYear) {
      return '${formatYMMMd(start, locale: locale)} - ${formatYMMMd(end, locale: locale)}';
    }
    return '${formatMMMd(start, locale: locale)} - ${formatMMMd(end, locale: locale)}';
  }

  /// Safely formats a datetime with hour and minute (e.g. '14.09.2026 15:30')
  static String formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    } catch (_) {
      final d = dateTime.day.toString().padLeft(2, '0');
      final m = dateTime.month.toString().padLeft(2, '0');
      final y = dateTime.year.toString();
      final hr = dateTime.hour.toString().padLeft(2, '0');
      final min = dateTime.minute.toString().padLeft(2, '0');
      return '$d.$m.$y $hr:$min';
    }
  }

  /// Safely formats a datetime relative to now (e.g. '2 saat önce', '5 gün önce', '5 ay önce (152 gün)')
  static String formatRelativeTime(DateTime dateTime, {String? locale}) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return locale == 'tr' ? 'Bilinmiyor' : 'Unknown';
    }
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    final isTr = locale == 'tr' || (locale == null && Intl.defaultLocale?.startsWith('tr') == true);

    if (diff.isNegative || diff.inMinutes < 1) {
      return isTr ? 'Az önce' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      return isTr ? '${diff.inMinutes} dk. önce' : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return isTr ? '${diff.inHours} saat önce' : '${diff.inHours}h ago';
    }
    if (diff.inDays < 30) {
      return isTr ? '${diff.inDays} gün önce' : '${diff.inDays}d ago';
    }
    if (diff.inDays < 365) {
      final months = diff.inDays ~/ 30;
      return isTr ? '$months ay önce (${diff.inDays} gün)' : '$months mo ago (${diff.inDays}d)';
    }
    final years = diff.inDays ~/ 365;
    return isTr ? '$years yıl önce' : '$years yr ago';
  }
}
