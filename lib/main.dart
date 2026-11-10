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
import 'package:home_widget/home_widget.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'core/services/app_widget_service.dart';
import 'core/services/telemetry_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/auth/presentation/screens/banned_screen.dart';
import 'features/admin/user_moderation_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/dashboard/presentation/main_shell_scaffold.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
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

  // 120 FPS performance optimizations: boost image cache for smooth fling scrolling
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100 MB

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
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final notifService = ref.read(notificationServiceProvider);
        notifService.initialize();
        notifService.requestPermissions();
        PushNotificationService.instance.initialize();
      } catch (e) {
        debugPrint('[PackBuddyApp] notification service warmup notice: $e');
      }

      // Check for cold-start launch via home screen widget tap
      try {
        HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? uri) {
          if (uri != null) {
            AppWidgetService.handleWidgetUri(uri, ref);
          }
        });
        // Listen for warm clicks from home screen widget while app is alive
        HomeWidget.widgetClicked.listen((Uri? uri) {
          if (uri != null) {
            AppWidgetService.handleWidgetUri(uri, ref);
          }
        });
      } catch (e) {
        debugPrint('[PackBuddyApp] HomeWidget deep link listener notice: $e');
      }
    });
  }

  @override
  void dispose() {
    _recordActiveSession();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _recordActiveSession() {
    if (!mounted) return;
    if (_sessionStartTime != null) {
      final elapsed = DateTime.now().difference(_sessionStartTime!).inSeconds;
      _sessionStartTime = null;
      if (elapsed >= 2) {
        try {
          final user = ref.read(authUserProvider);
          if (user != null) {
            ref.read(authServiceProvider).recordSessionDuration(user.uid, elapsed).catchError((_) {});
          }
        } catch (_) {}
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sessionStartTime = DateTime.now();
      final user = ref.read(authUserProvider);
      final isVerified = ref.read(isEmailVerifiedProvider);
      final isPassword = ref.read(authControllerProvider).isPasswordProvider;
      if (user != null) {
        ref.read(authServiceProvider).updateLastActive(user.uid).catchError((_) {});
        PushNotificationService.instance.syncUserFcmToken(user.uid).catchError((_) {});
        if (isVerified || !isPassword) {
          ref.read(syncEngineProvider.notifier).performSync().catchError((_) {});
        }
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _recordActiveSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: AppWidgetService.navigatorKey,
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

/// Notifier managing onboarding tour completion state
class OnboardingCompletedNotifier extends StateNotifier<bool> {
  OnboardingCompletedNotifier()
      : super(PreferencesService.instance.isOnboardingCompleted());

  Future<void> complete() async {
    await PreferencesService.instance.setOnboardingCompleted(true);
    state = true;
  }
}

/// Provider exposing whether user has completed or skipped the first-time onboarding tour
final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletedNotifier, bool>((ref) {
  return OnboardingCompletedNotifier();
});

/// Authentication Wall Gate (Zorunlu Giriş & E-posta Doğrulama Duvarı)
/// - If first install & unauthenticated: [OnboardingScreen] interactive tour
/// - If unauthenticated: strictly [AuthScreen]
/// - If user is banned: strictly [BannedScreen]
/// - If user != null BUT emailVerified == false (password provider): strictly [EmailVerificationScreen]
/// - If user != null AND emailVerified == true: [DashboardScreen]
class AuthWallGate extends ConsumerWidget {
  const AuthWallGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final moderation = ref.watch(userModerationProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

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
      child: _buildGatedScreen(user, moderation, onboardingCompleted, ref),
    );
  }

  Widget _buildGatedScreen(
    User? user,
    UserModerationState moderation,
    bool onboardingCompleted,
    WidgetRef ref,
  ) {
    // 1. First-time app open: show interactive onboarding walkthrough before login
    if (!onboardingCompleted && user == null) {
      return OnboardingScreen(
        key: const ValueKey('first_time_onboarding_tour'),
        onCompleted: () {
          ref.read(onboardingCompletedProvider.notifier).complete();
        },
      );
    }

    // 2. Unauthenticated -> strictly AuthScreen
    if (user == null) {
      return const AuthScreen(key: ValueKey('unauthenticated_auth_wall'));
    }

    // 3. Real-Time Ban Enforcement -> strictly BannedScreen
    if (moderation.isCurrentlyBanned) {
      return BannedScreen(
        key: const ValueKey('banned_lock_screen'),
        moderation: moderation,
      );
    }

    // 4. Check provider (password vs social OAuth like Google)
    final isPasswordProvider = user.providerData.isEmpty ||
        user.providerData.any((p) => p.providerId == 'password');

    // 5. Unverified email for password accounts -> strictly EmailVerificationScreen
    if (!user.emailVerified && isPasswordProvider) {
      return const EmailVerificationScreen(
        key: ValueKey('email_verification_wall'),
      );
    }

    // 6. Fully authenticated and verified -> Main Navigation Shell (Persistent Scaffold)
    return const MainShellScaffold(
      key: ValueKey('authenticated_shell'),
    );
  }
}
