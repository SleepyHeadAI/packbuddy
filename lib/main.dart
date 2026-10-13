import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/currency_service.dart';
import 'core/services/preferences_service.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting();
  } catch (_) {}
  try {
    await PreferencesService.init();
  } catch (_) {}
  try {
    await CurrencyService.init();
    // Non-blocking background sync when online
    CurrencyService.syncRates();
  } catch (_) {}

  // Initialize Firebase with current platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase] Initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: PackBuddyApp(),
    ),
  );
}

class PackBuddyApp extends ConsumerWidget {
  const PackBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'PackBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: activeThemeMode,
      locale: activeLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthWallGate(),
    );
  }
}

/// Authentication Wall Gate (Zorunlu Giriş & E-posta Doğrulama Duvarı)
/// - If user is null: strictly [AuthScreen]
/// - If user != null BUT emailVerified == false (password provider): strictly [EmailVerificationScreen]
/// - If user != null AND emailVerified == true: [DashboardScreen]
class AuthWallGate extends ConsumerWidget {
  const AuthWallGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildGatedScreen(user),
    );
  }

  Widget _buildGatedScreen(User? user) {
    // 1. Unauthenticated -> strictly AuthScreen
    if (user == null) {
      return const AuthScreen(key: ValueKey('unauthenticated_auth_wall'));
    }

    // 2. Check provider (password vs social OAuth like Google)
    final isPasswordProvider = user.providerData.isEmpty ||
        user.providerData.any((p) => p.providerId == 'password');

    // 3. Unverified email for password accounts -> strictly EmailVerificationScreen
    if (!user.emailVerified && isPasswordProvider) {
      return const EmailVerificationScreen(
        key: ValueKey('email_verification_wall'),
      );
    }

    // 4. Fully authenticated and verified -> DashboardScreen
    return const DashboardScreen(
      key: ValueKey('authenticated_dashboard'),
    );
  }
}
