# Flutter ProGuard / R8 Obfuscation Rules for PackBuddy Production Release

# Keep Flutter engine & framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-dontwarn io.flutter.**

# Keep Firebase Native SDKs
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep PostHog Analytics
-keep class com.posthog.** { *; }
-dontwarn com.posthog.**

# Keep In-App Purchase & Billing SDK bridges
-keep class com.android.billingclient.** { *; }
-keep class com.dooboolab.flutterinapppurchase.** { *; }
-keep class io.flutter.plugins.inapppurchase.** { *; }
-dontwarn com.android.billingclient.**

# Keep SQLite and Database bridges
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Keep Local Notifications & Timezone bridges
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# General anti-tamper obfuscation settings
-repackageclasses
-allowaccessmodification
