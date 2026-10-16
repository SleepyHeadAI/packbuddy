import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Platform Permission Types used by PackBuddy features
enum AppPermissionType {
  camera,
  photoLibrary,
  microphone,
  storage,
}

/// Abstract contract for runtime permission management
abstract class IPermissionService {
  Future<bool> hasPermission(AppPermissionType permission);
  Future<bool> requestPermission(AppPermissionType permission);
}

/// Core implementation for platform permissions with platform checks and permission_handler
class PermissionService implements IPermissionService {
  Permission _mapPermission(AppPermissionType permission) {
    switch (permission) {
      case AppPermissionType.camera:
        return Permission.camera;
      case AppPermissionType.photoLibrary:
        return Platform.isIOS ? Permission.photos : Permission.storage;
      case AppPermissionType.microphone:
        return Permission.microphone;
      case AppPermissionType.storage:
        return Permission.storage;
    }
  }

  @override
  Future<bool> hasPermission(AppPermissionType permission) async {
    // Web / Desktop fallback
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    try {
      final p = _mapPermission(permission);
      final status = await p.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      debugPrint('[PermissionService] hasPermission check error: $e');
      return true;
    }
  }

  @override
  Future<bool> requestPermission(AppPermissionType permission) async {
    // Web / Desktop fallback
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    try {
      final p = _mapPermission(permission);
      final status = await p.request();
      return status.isGranted || status.isLimited;
    } catch (e) {
      debugPrint('[PermissionService] requestPermission error: $e');
      return true;
    }
  }
}
