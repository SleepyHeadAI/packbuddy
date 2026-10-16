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
import 'features/auth/auth_service.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_screen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'core/services/telemetry_service.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/auth/presentation/screens/banned_screen.dart';
import 'features/admin/user_moderation_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'data/sync_engine/sync_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with current platform options (must execute before preferences/currency services)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase] Initialization notice: $e');
  }

  // Initialize PostHog EU Cloud with Session Replay & PII text masking
  try {
    await TelemetryService.instance.init();
  } catch (_) {}

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

  runApp(
    const ProviderScope(
      child: PackBuddyApp(),
    ),
  );
}

class PackBuddyApp extends ConsumerStatefulWidget {
  const PackBuddyApp({super.key});

  @override
  ConsumerState<PackBuddyApp> createState() => _PackBuddyAppState();
}

class _PackBuddyAppState extends ConsumerState<PackBuddyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final user = ref.read(authUserProvider);
      final isVerified = ref.read(isEmailVerifiedProvider);
      final isPassword = ref.read(authControllerProvider).isPasswordProvider;
      if (user != null) {
        ref.read(authServiceProvider).updateLastActive(user.uid).catchError((_) {});
        if (isVerified || !isPassword) {
          ref.read(syncEngineProvider.notifier).performSync().catchError((_) {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      navigatorObservers: [
        PosthogObserver(),
      ],
      home: const AuthWallGate(),
    );
  }
}

/// Authentication Wall Gate (Zorunlu Giriş & E-posta Doğrulama Duvarı)
/// - If user is null: strictly [AuthScreen]
/// - If user is banned: strictly [BannedScreen]
/// - If user != null BUT emailVerified == false (password provider): strictly [EmailVerificationScreen]
/// - If user != null AND emailVerified == true: [DashboardScreen]
class AuthWallGate extends ConsumerWidget {
  const AuthWallGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final moderation = ref.watch(userModerationProvider);

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
      child: _buildGatedScreen(user, moderation),
    );
  }

  Widget _buildGatedScreen(User? user, UserModerationState moderation) {
    // 1. Unauthenticated -> strictly AuthScreen
    if (user == null) {
      return const AuthScreen(key: ValueKey('unauthenticated_auth_wall'));
    }

    // 2. Real-Time Ban Enforcement -> strictly BannedScreen
    if (moderation.isCurrentlyBanned) {
      return BannedScreen(
        key: const ValueKey('banned_lock_screen'),
        moderation: moderation,
      );
    }

    // 3. Check provider (password vs social OAuth like Google)
    final isPasswordProvider = user.providerData.isEmpty ||
        user.providerData.any((p) => p.providerId == 'password');

    // 4. Unverified email for password accounts -> strictly EmailVerificationScreen
    if (!user.emailVerified && isPasswordProvider) {
      return const EmailVerificationScreen(
        key: ValueKey('email_verification_wall'),
      );
    }

    // 5. Fully authenticated and verified -> DashboardScreen
    return const DashboardScreen(
      key: ValueKey('authenticated_dashboard'),
    );
  }
}
