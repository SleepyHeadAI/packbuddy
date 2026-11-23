import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Guards the hand-wired Android branding: an icon generator re-run must not
/// silently drop the themed-icon layer, the notification icon or the splash.
void main() {
  const res = 'android/app/src/main/res';
  String read(String path) => File(path).readAsStringSync();

  test('adaptive launcher icon has background, foreground and monochrome layers', () {
    final xml = read('$res/mipmap-anydpi-v26/ic_launcher.xml');
    expect(xml, contains('<background android:drawable="@color/ic_launcher_background"'));
    expect(xml, contains('<foreground android:drawable="@mipmap/ic_launcher_foreground"'));
    expect(xml, contains('<monochrome android:drawable="@drawable/ic_launcher_monochrome"'));
    expect(read('$res/values/colors.xml'), contains('<color name="ic_launcher_background">#101010</color>'));
    expect(File('$res/drawable/ic_launcher_monochrome.xml').existsSync(), isTrue);
  });

  test('FCM defaults use the white notification vector and the brand accent', () {
    final manifest = read('android/app/src/main/AndroidManifest.xml');
    expect(manifest, contains('android:resource="@drawable/ic_notification"'));
    expect(manifest, contains('android:resource="@color/notification_accent"'));
    final vector = read('$res/drawable/ic_notification.xml');
    expect(vector, contains('android:width="24dp"'));
    expect(vector, contains('android:fillColor="#FFFFFFFF"'));
  });

  test('light and dark splash share the brand colours on every Android version', () {
    expect(read('$res/values/colors.xml'), contains('<color name="splash_background">#FBFAF8</color>'));
    expect(read('$res/values-night/colors.xml'), contains('<color name="splash_background">#101010</color>'));
    for (final dir in ['values-v31', 'values-night-v31']) {
      final styles = read('$res/$dir/styles.xml');
      expect(styles, contains('android:windowSplashScreenBackground">@color/splash_background'), reason: dir);
      expect(styles, contains('android:windowSplashScreenAnimatedIcon">@drawable/splash_logo'), reason: dir);
    }
    expect(read('$res/drawable/launch_background.xml'), contains('@drawable/splash_logo'));
    expect(File('$res/drawable-night/splash_logo.xml').existsSync(), isTrue);
  });
}
