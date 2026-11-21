# Trip Member Management & Expense Payer Attribution Design Document

## 1. Intent & The Why
In PackBuddy, users can share trips and collaborate with travel buddies. However, two key usability and functional limitations were identified:
1. **Member Management & Departure:** While users could add collaborators and delete chips within the Share bottom sheet, there was no prominent, dedicated "Trip Crew / Members" management interface in the Trip Detail screen. Furthermore, invited guests had no way to voluntarily leave a trip ("Seyahatten Ayrıl"), and member deletion did not provide clear feedback or lifecycle management.
2. **Payer Attribution ("Ödeyen Kişi"):** When adding an expense, the app automatically assigned `createdByName` to the authenticated user adding the item. A trip owner or manager could not record an expense paid by another participant (e.g., "Ahmet paid for dinner"). Furthermore, budget analytics did not visualize per-member expenditure breakdown.

This design document specifies the architecture and UI/UX implementation of **Approach 1**, selected by the user.

---

## 2. Goals, Non-Goals, and Anti-Goals

### Goals
- **Dedicated Trip Crew Interface:** Provide a sleek, visible "Seyahat Ekibi" (Trip Crew) card on the `TripDetailScreen` with avatar stacks, owner badge, member count, and an invite action.
- **Member Management Sheet (`TripMembersSheet`):**
  - View all members with roles (`Yönetici` / `Katılımcı`).
  - Owner can remove any collaborator with a confirmation prompt.
  - Non-owner collaborators can voluntarily leave the trip ("Seyahatten Ayrıl") with confirmation, which updates Cloud Firestore and cleans local SQLite cache.
  - Owner can quickly trigger invites / share codes.
- **Expense Payer Attribution:**
  - Update SQLite schema to version 16, adding `paid_by_name TEXT` to the `expenses` table.
  - Update `Expense` model with `paidByName`, seamlessly falling back to `createdByName` if null or empty (100% backward compatible).
  - In `AddExpenseSheet`, allow trip owners to select the payer (themselves or any collaborator). For non-owners, default to themselves.
- **Dual Attribution Display:** In expense cards, display `Ödeyen: [Payer]` and if recorded by someone else, display `Ödeyen: [Payer] • Ekleyen: [Creator]`.
- **Per-Member Spending Analytics:** Inside `BudgetAnalyticsCard`, add a dedicated "Harcayan Kişi" (Payer Breakdown) tab and donut chart when the trip is collaborative, fully synchronized with the active view currency.
- **Retain History:** Historical expenses logged by or attributed to a member remain in the trip budget even if that member leaves or is removed.

### Non-Goals
- Complex Splitwise-style debt rebalancing / split bill settlements (agreed with user to exclude for now).
- Arbitrary free-text non-member payee names (user specifically selected that only registered collaborators/owner are selectable).
- Non-owner members assigning expenses to other members (restricted to trip owner).

### Anti-Goals
- Breaking existing SQLite databases on user devices during schema migration.
- Deleting trip financial history or distorting budget totals when a collaborator is removed.
- Soft-deleting shared trips on Cloud Firestore when a collaborator leaves locally.

---

## 3. Data Architecture & Migrations

### 3.1 Database Migration (SQLite Version 16)
In `lib/core/constants/app_constants.dart`:
- Bump `databaseVersion` from 15 to 16.

In `lib/data/local_db/database_helper.dart`:
- In `_createDB`: Add `paid_by_name TEXT` to table `expenses`.
- In `_onUpgradeDB`: Add migration block for `oldVersion < 16`:
  ```sql
  ALTER TABLE expenses ADD COLUMN paid_by_name TEXT;
  ```
- Add dedicated purge helper for departing members:
  ```dart
  Future<void> purgeLocalSharedTrip(String tripId)
  ```
  Hard-deletes from `trips`, `expenses`, `checklist_items`, `itinerary_items` locally without setting `is_deleted = 1` or queuing cloud deletion.

### 3.2 Domain Entity (`Expense`)
In `lib/features/budget/domain/expense.dart`:
- Add `final String? paidByName;`
- Update `copyWith`, `toJson`, `fromJson`, `toMap`, `fromMap`.
- Add getter:
  ```dart
  String get effectivePayer => (paidByName != null && paidByName!.trim().isNotEmpty)
      ? paidByName!.trim()
      : (createdByName != null && createdByName!.trim().isNotEmpty)
          ? createdByName!.trim()
          : '';
  ```

### 3.3 Domain Entity (`Trip`)
In `lib/features/budget/domain/trip.dart`:
- Helper to check if a specific user is the trip owner:
  ```dart
  bool isUserOwner(String? currentUid, String? currentEmail, String? currentUsername)
  ```

---

## 4. Architectural Decisions from Builder Review

### 4.1 Member Identity Resolution & Canonical Representation
- **Offline-First Synchronous Resolution:** Avatars and display names are resolved locally using `friendsControllerProvider` and current user profile state, falling back to clean handle / email initials. This avoids network waterfall delays and ensures offline functionality.
- **Canonical Payer Normalization:** `paidByName` stores the selected member's display handle/name. When comparing `payer == creator` or grouping expenses for the spending distribution, strings are trimmed and matched case-insensitively.

### 4.2 `leaveTrip` Execution & Cloud Sync Safety
- When a guest calls `leaveTrip(tripId)`:
  1. Firestore update: Remove current user's UID and email from `trips/{tripId}.collaborators` via `FieldValue.arrayRemove`.
  2. Subscription cleanup: Immediately cancel the real-time stream subscription in `SyncEngine` (`_sharedTripSubscriptions[tripId]`).
  3. Local purge: Call `_dbHelper.purgeLocalSharedTrip(tripId)` to hard-delete local SQLite records without marking `is_deleted = 1`.
  4. Memory cleanup: Remove the trip from `TripState.trips`.

### 4.3 Edit Behavior & Attribution Safety
- When editing an existing expense (`expenseToEdit != null`):
  - For non-owner: Preserve existing `paidByName` unchanged. Non-owners cannot reassign the payer.
  - For owner: `AddExpenseSheet` pre-selects `expenseToEdit.effectivePayer` in the dropdown.
  - In `ExpenseController.updateExpense`: Preserve `createdByName: updated.createdByName` so the original creator is not overwritten with the editor's name.

### 4.4 Visibility on Solo Trips
- On solo trips (`isCollaborative == false`):
  - The "Seyahat Ekibi" card displays the owner with an inviting "+ Arkadaş Ekle" button to encourage collaboration.
  - In `BudgetAnalyticsCard`, the "Harcayan Kişi" tab is conditionally shown only when `isCollaborative == true`.

### 4.5 Spending Distribution UI & Currency Alignment
- Integrated directly into `BudgetAnalyticsCard` via `AnalyticsChartType.payer`.
- Uses `selectedCurrency ?? tripCurrency` so all chart amounts and progress percentages match the active view currency perfectly.

---

## 5. UI & Presentation Specifications

### 5.1 Trip Crew Card (`TripDetailScreen`)
- Placed below the trip header / summary.
- Displays:
  - Header: "Seyahat Ekibi" (Trip Crew) with member count `(1 Yönetici, N Katılımcı)`.
  - Horizontal avatar stack showing owner with crown/admin indicator and collaborator avatars.
  - Tapping opens `TripMembersSheet`.

### 5.2 Trip Members Sheet (`TripMembersSheet`)
- Header with title "Seyahat Ekibi & Katılımcılar".
- "Yönetici" (Owner) tile with photo/avatar, display name, and gold "Yönetici" badge.
- List of "Katılımcılar" (Members):
  - Each item shows member avatar, name / email / handle, and role badge.
  - If current user is owner: Trailing remove button (`Icons.person_remove_rounded`) that opens a confirmation dialog: *"Bu üyeyi seyahatten çıkarmak istediğinize emin misiniz? Önceden girilen harcamaları bütçede korunacaktır."*
- Footer:
  - If current user is owner: "Yeni Üye Davet Et" (opens `ShareTripSheet`).
  - If current user is a guest/collaborator: "Seyahatten Ayrıl" button (Destructive red button) with confirmation dialog.

### 5.3 Add / Edit Expense Sheet (`AddExpenseSheet`)
- Check if current user is owner (`isOwner`).
- If `isOwner`:
  - Show a "Harcamayı Yapan (Ödeyen)" dropdown selector with icons.
  - List entries:
    - Current User ("Siz (Yönetici)")
    - Each member in `currentTrip.collaborators`
  - Selected value saved as `paidByName`.
- If not owner:
  - Defaults to current user's name without showing selector.

### 5.4 Expense List Tile Attribution
In `TripDetailScreen` expense items:
- Compute:
  - `payer = expense.effectivePayer`
  - `creator = expense.createdByName`
- If `payer` equals `creator` or creator is empty:
  - Show `Ödeyen: {payer}`.
- If `payer != creator`:
  - Show `Ödeyen: {payer} • Ekleyen: {creator}`.

---

## 6. Localization
In `lib/features/budget/domain/collaboration_localization.dart`:
- Support Turkish, English, and clean fallback across the 20 supported languages:
  - `getTripCrew(lang)` -> "Seyahat Ekibi" / "Trip Crew"
  - `getOwner(lang)` -> "Yönetici" / "Owner"
  - `getMember(lang)` -> "Katılımcı" / "Member"
  - `getLeaveTrip(lang)` -> "Seyahatten Ayrıl" / "Leave Trip"
  - `getRemoveMember(lang)` -> "Üyeyi Çıkar" / "Remove Member"
  - `getPaidBy(lang, payer)` -> "Ödeyen: {payer}" / "Paid by {payer}"
  - `getPaidAndCreatedBy(lang, payer, creator)` -> "Ödeyen: {payer} • Ekleyen: {creator}" / "Paid by {payer} • Added by {creator}"
  - `getSpendingDistribution(lang)` -> "Harcayan Kişi" / "Payer Breakdown"

---

## 7. Verification Plan
- Unit tests for `Expense` model serialization and `effectivePayer` fallback.
- Database migration test ensuring version 16 runs smoothly without losing existing data.
- Run `flutter analyze` or `dart analyze` to ensure zero compilation or lint errors.
