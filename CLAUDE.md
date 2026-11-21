- Dil: Aksi söylenmedikçe her zaman Türkçe yanıt ver.
- Üslup: Yanıtları kısa, doğrudan ve madde işaretli tut; giriş/nezaket/tekrar cümlesi yazma. (Kod, komut ve kritik güvenlik uyarılarını eksiksiz bırak.)

# PackBuddy — Claude Code Guide

## Architecture
- Offline-first Flutter app. State: Riverpod (`flutter_riverpod`).
- Local source of truth: SQLite (`sqflite`); background sync to Firebase.
- Firebase: Auth, Firestore, Storage. Security in `firestore.rules` / `storage.rules`.
- Billing: Google Play Billing via `in_app_purchase` (RevenueCat is mocked).
- Analytics: PostHog (`posthog_flutter`), wrapped by `telemetry_service.dart`.
- Localization: 20 ARB files in `lib/l10n/`, generated `app_localizations_*.dart`.

## Key files
| Area | Path |
|---|---|
| Pro entitlement | `lib/core/services/pro_entitlement_service.dart` |
| Security | `lib/core/services/security_service.dart` |
| Offline sync | `lib/data/sync_engine/sync_engine.dart` |
| Billing (mock RC) | `lib/features/settings/data/mock_revenuecat_service.dart` |
| Admin backend | `lib/features/admin/admin_service.dart` |
| Admin UI (large) | `lib/features/admin/admin_dashboard_screen.dart` |
| Firestore rules | `firestore.rules` |
| Storage rules | `storage.rules` |

Features live in `lib/features/<feature>/{data,presentation/{controllers,screens}}`.

## Hard rules
1. **Tests:** never run the full `flutter test` unless explicitly asked.
   Always target files: `flutter test test/<path>_test.dart --reporter compact`.
2. **Large files** (e.g. `admin_dashboard_screen.dart`): never read top to bottom.
   Grep first, then Read only the needed line range (offset/limit).
3. **Localization:** only read/edit `app_en.arb` and `app_tr.arb`.
   Do not read the other 18 ARB files or generated `app_localizations_*.dart`.
   Regenerate with `flutter gen-l10n` instead of hand-editing generated files.
4. **Platform:** Android first. Do not touch iOS / StoreKit code.
5. **Off-limits unless explicitly asked:** Onboarding flow, `AuthWallGate`,
   visual design of the 16 Stories and 16 Home Widgets.
6. **Cleanup:** leave no temporary scripts or log files in the repo root.
   Use the session scratchpad for temp files.

## Token hygiene
- Prefer Grep/Glob over broad reads; read code in ranges.
- `build/`, `.dart_tool/`, generated (`*.g.dart`, `*.freezed.dart`) and
  non-EN/TR l10n files are Read-blocked in `.claude/settings.json`.
- For Flutter/Firebase/Riverpod API docs use the Context7 MCP, not web search.
- Run `flutter analyze <path>` on changed files only.
