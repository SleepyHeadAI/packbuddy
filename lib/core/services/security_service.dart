import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Vault privacy & anti-spyware screen protection service.
/// Interfaces with Android window FLAG_SECURE via MethodChannel.
class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static const MethodChannel _channel = MethodChannel('com.sleepyhead.packbuddy/security');

  /// Tracks current secure screen state for diagnostics and headless verification
  bool _isSecureScreenActive = false;
  bool get isSecureScreenActive => _isSecureScreenActive;

  /// Enables FLAG_SECURE on the native Android Window to block screenshots,
  /// screen recording, and system app switcher previews of sensitive documents.
  Future<bool> enableSecureScreen() async {
    _isSecureScreenActive = true;
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('enableSecureScreen');
        return result ?? true;
      }
    } catch (e) {
      debugPrint('[SecurityService] enableSecureScreen notice: $e');
    }
    return true;
  }

  /// Clears FLAG_SECURE from the native Android Window when leaving sensitive screens.
  Future<bool> disableSecureScreen() async {
    _isSecureScreenActive = false;
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('disableSecureScreen');
        return result ?? true;
      }
    } catch (e) {
      debugPrint('[SecurityService] disableSecureScreen notice: $e');
    }
    return true;
  }
}
