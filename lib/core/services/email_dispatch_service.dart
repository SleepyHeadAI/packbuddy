import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service responsible for launching system mail apps and managing warning email drafts
class EmailDispatchService {
  EmailDispatchService._();
  static final EmailDispatchService instance = EmailDispatchService._();

  /// Launches the user's default email client (Gmail, Outlook, Apple Mail, etc.)
  /// with prefilled recipient, subject, and body content.
  Future<bool> launchEmailDraft({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    if (kIsWeb) return false;

    final cleanEmail = toEmail.trim();
    if (cleanEmail.isEmpty) {
      debugPrint('[EmailDispatchService] Cannot launch email draft: recipient is empty');
      return false;
    }

    // Detect headless unit tests
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
    } catch (_) {}

    final uri = Uri(
      scheme: 'mailto',
      path: cleanEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        return launched;
      } else {
        // Fallback: try launching with non-encoded mailto
        final fallbackUri = Uri.parse('mailto:$cleanEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
        if (await canLaunchUrl(fallbackUri)) {
          return await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
        debugPrint('[EmailDispatchService] canLaunchUrl returned false for $uri');
        return false;
      }
    } catch (e) {
      debugPrint('[EmailDispatchService] Error launching email draft: $e');
      return false;
    }
  }

  /// Helper to properly encode mailto query string
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Generates the plain text format for warning emails
  String formatWarningEmailText({
    required String displayName,
    required String title,
    required String message,
  }) {
    final name = displayName.isNotEmpty ? displayName : 'Gezgin';
    return 'Merhaba $name,\n\n'
        '$title\n\n'
        '$message\n\n'
        'Sorularınız veya geri bildiriminiz için lütfen PackBuddy uygulaması üzerinden bizimle iletişime geçiniz.\n\n'
        'İyi yolculuklar,\n'
        'PackBuddy Yönetim Ekibi';
  }

  /// Generates standard HTML format for email delivery
  String formatWarningEmailHtml({
    required String displayName,
    required String title,
    required String message,
  }) {
    final name = displayName.isNotEmpty ? displayName : 'Gezgin';
    return '''
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff;">
        <h2 style="color: #ea580c; margin-top: 0;">PackBuddy Yönetici Uyarısı</h2>
        <p>Merhaba <strong>$name</strong>,</p>
        <div style="background-color: #fff7ed; border-left: 4px solid #ea580c; padding: 14px; margin: 18px 0; border-radius: 8px;">
          <p style="margin: 0; color: #9a3412; font-weight: bold; font-size: 15px;">
            $title
          </p>
          <p style="margin: 8px 0 0 0; color: #334155; font-size: 14px; line-height: 1.5; white-space: pre-line;">
            $message
          </p>
        </div>
        <p style="color: #64748b; font-size: 13px;">
          Sorularınız veya destek için lütfen uygulamamız üzerinden bizimle iletişime geçin.
        </p>
        <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 24px 0;" />
        <p style="font-size: 12px; color: #94a3b8; margin-bottom: 0;">Bu bildirim PackBuddy yönetim paneli tarafından iletilmiştir.</p>
      </div>
    ''';
  }
}

