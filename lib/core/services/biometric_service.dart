import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Real Hardware Biometric Authentication Service (Fingerprint / FaceID)
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Whether biometric authentication is supported and enrolled on this device.
  Future<bool> isBiometricsAvailable() async {
    if (kIsWeb) return false;

    // Detect headless unit tests
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    } catch (_) {}

    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!isSupported || !canCheck) return false;

      final enrolled = await _localAuth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] isBiometricsAvailable platform exception: $e');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] isBiometricsAvailable error: $e');
      return false;
    }
  }

  /// Authenticates using device biometrics (Fingerprint / Face ID).
  /// Returns `true` if authentication succeeded, `false` otherwise.
  Future<bool> authenticate({required String localizedReason}) async {
    if (kIsWeb) return false;

    // Detect headless unit tests
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    } catch (_) {}

    try {
      final available = await isBiometricsAvailable();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
      );
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] authenticate platform exception: $e');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] authenticate error: $e');
      return false;
    }
  }
}
