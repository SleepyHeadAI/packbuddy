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

  /// Safely formats a datetime relative to now across all 20 supported languages
  static String formatRelativeTime(DateTime dateTime, {String? locale}) {
    final lang = (locale ?? Intl.defaultLocale ?? 'en').toLowerCase().split('_').first.split('-').first;
    if (dateTime.millisecondsSinceEpoch == 0) {
      switch (lang) {
        case 'tr': return 'Bilinmiyor';
        case 'de': return 'Unbekannt';
        case 'fr': return 'Inconnu';
        case 'es': return 'Desconocido';
        case 'it': return 'Sconosciuto';
        case 'pt': return 'Desconhecido';
        case 'ru': return 'Неизвестно';
        case 'zh': return '未知';
        case 'ja': return '不明';
        case 'ko': return '알 수 없음';
        case 'ar': return 'غير معروف';
        case 'hi': return 'अज्ञात';
        case 'nl': return 'Onbekend';
        case 'el': return 'Άγνωστο';
        case 'sv': return 'Okänd';
        case 'pl': return 'Nieznany';
        case 'id': return 'Tidak diketahui';
        case 'th': return 'ไม่ทราบ';
        case 'vi': return 'Không xác định';
        case 'en':
        default: return 'Unknown';
      }
    }
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative || diff.inMinutes < 1) {
      switch (lang) {
        case 'tr': return 'Az önce';
        case 'de': return 'Gerade eben';
        case 'fr': return 'À l\'instant';
        case 'es': return 'Hace un momento';
        case 'it': return 'Proprio ora';
        case 'pt': return 'Agora mesmo';
        case 'ru': return 'Только что';
        case 'zh': return '刚刚';
        case 'ja': return 'たった今';
        case 'ko': return '방금 전';
        case 'ar': return 'الآن';
        case 'hi': return 'अभी-अभी';
        case 'nl': return 'Zojuist';
        case 'el': return 'Μόλις τώρα';
        case 'sv': return 'Just nu';
        case 'pl': return 'Przed chwilą';
        case 'id': return 'Baru saja';
        case 'th': return 'เมื่อสักครู่';
        case 'vi': return 'Vừa xong';
        case 'en':
        default: return 'Just now';
      }
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      switch (lang) {
        case 'tr': return '$m dk. önce';
        case 'de': return 'vor $m Min.';
        case 'fr': return 'il y a $m min';
        case 'es': return 'hace $m min';
        case 'it': return '$m min fa';
        case 'pt': return 'há $m min';
        case 'ru': return '$m мин. назад';
        case 'zh': return '$m分钟前';
        case 'ja': return '$m分前';
        case 'ko': return '$m분 전';
        case 'ar': return 'منذ $m دقيقة';
        case 'hi': return '$m मिनट पहले';
        case 'nl': return '$m min geleden';
        case 'el': return 'πριν $m λεπτά';
        case 'sv': return 'för $m min sedan';
        case 'pl': return '$m min temu';
        case 'id': return '$m mnt lalu';
        case 'th': return '$m นาทีที่แล้ว';
        case 'vi': return '$m phút trước';
        case 'en':
        default: return '${m}m ago';
      }
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      switch (lang) {
        case 'tr': return '$h saat önce';
        case 'de': return 'vor $h Std.';
        case 'fr': return 'il y a $h h';
        case 'es': return 'hace $h h';
        case 'it': return '$h ore fa';
        case 'pt': return 'há $h h';
        case 'ru': return '$h ч. назад';
        case 'zh': return '$h小时前';
        case 'ja': return '$h時間前';
        case 'ko': return '$h시간 전';
        case 'ar': return 'منذ $h ساعة';
        case 'hi': return '$h घंटे पहले';
        case 'nl': return '$h uur geleden';
        case 'el': return 'πριν $h ώρες';
        case 'sv': return 'för $h tim sedan';
        case 'pl': return '$h godz. temu';
        case 'id': return '$h jam lalu';
        case 'th': return '$h ชม. ที่แล้ว';
        case 'vi': return '$h giờ trước';
        case 'en':
        default: return '${h}h ago';
      }
    }
    if (diff.inDays < 30) {
      final d = diff.inDays;
      switch (lang) {
        case 'tr': return '$d gün önce';
        case 'de': return 'vor $d Tagen';
        case 'fr': return 'il y a $d j';
        case 'es': return 'hace $d d';
        case 'it': return '$d giorni fa';
        case 'pt': return 'há $d dias';
        case 'ru': return '$d дн. назад';
        case 'zh': return '$d天前';
        case 'ja': return '$d日前';
        case 'ko': return '$d일 전';
        case 'ar': return 'منذ $d يوم';
        case 'hi': return '$d दिन पहले';
        case 'nl': return '$d dagen geleden';
        case 'el': return 'πριν $d ημέρες';
        case 'sv': return 'för $d dagar sedan';
        case 'pl': return '$d dni temu';
        case 'id': return '$d hari lalu';
        case 'th': return '$d วันที่แล้ว';
        case 'vi': return '$d ngày trước';
        case 'en':
        default: return '${d}d ago';
      }
    }
    if (diff.inDays < 365) {
      final months = diff.inDays ~/ 30;
      final d = diff.inDays;
      switch (lang) {
        case 'tr': return '$months ay önce ($d gün)';
        case 'de': return 'vor $months Mon. ($d T.)';
        case 'fr': return 'il y a $months mois ($d j)';
        case 'es': return 'hace $months m ($d d)';
        case 'it': return '$months mesi fa ($d gg)';
        case 'pt': return 'há $months meses ($d d)';
        case 'ru': return '$months мес. назад ($d дн.)';
        case 'zh': return '$months个月前 ($d天)';
        case 'ja': return '$monthsヶ月前 ($d日前)';
        case 'ko': return '$months개월 전 ($d일)';
        case 'ar': return 'منذ $months شهر ($d يوم)';
        case 'hi': return '$months माह पहले ($d दिन)';
        case 'nl': return '$months mnd geleden ($d d)';
        case 'el': return 'πριν $months μήνες ($d ημ)';
        case 'sv': return 'för $months mån sedan ($d d)';
        case 'pl': return '$months mies. temu ($d dni)';
        case 'id': return '$months bln lalu ($d hari)';
        case 'th': return '$months เดือนที่แล้ว ($d วัน)';
        case 'vi': return '$months tháng trước ($d ngày)';
        case 'en':
        default: return '$months mo ago (${d}d)';
      }
    }
    final years = diff.inDays ~/ 365;
    switch (lang) {
      case 'tr': return '$years yıl önce';
      case 'de': return 'vor $years Jahren';
      case 'fr': return 'il y a $years ans';
      case 'es': return 'hace $years años';
      case 'it': return '$years anni fa';
      case 'pt': return 'há $years anos';
      case 'ru': return '$years г. назад';
      case 'zh': return '$years年前';
      case 'ja': return '$years年前';
      case 'ko': return '$years년 전';
      case 'ar': return 'منذ $years سنة';
      case 'hi': return '$years वर्ष पहले';
      case 'nl': return '$years jaar geleden';
      case 'el': return 'πριν $years χρόνια';
      case 'sv': return 'för $years år sedan';
      case 'pl': return '$years lat temu';
      case 'id': return '$years thn lalu';
      case 'th': return '$years ปีที่แล้ว';
      case 'vi': return '$years năm trước';
      case 'en':
      default: return '$years yr ago';
    }
  }
}
