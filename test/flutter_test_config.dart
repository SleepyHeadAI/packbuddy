import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Global test bootstrap (picked up automatically by `flutter test` for every file in test/).
///
/// The vault PIN (VaultPinService) and Pro entitlement now live exclusively in
/// FlutterSecureStorage. Without a mock, platform-channel calls never complete inside
/// widget tests' fake-async zone, so an in-memory secure storage is installed for all tests.
/// Individual tests may still call `FlutterSecureStorage.setMockInitialValues` to seed values.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  FlutterSecureStorage.setMockInitialValues({});
  await testMain();
}
