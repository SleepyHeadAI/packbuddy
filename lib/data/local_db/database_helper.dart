import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/vault/domain/document.dart';
import '../../features/checklist/domain/packing_item.dart';

/// SQLite Database Helper providing offline-first local persistence, multi-tenant security, and soft-delete CRUD
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  /// Resolves current authenticated user UID safely
  String get _currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Trips Table (Multi-tenant with user_id)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTrips} (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        destination TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        default_currency TEXT NOT NULL,
        budget_limit REAL,
        country_code TEXT,
        transport_mode TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Expenses Table (Multi-tenant with user_id)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableExpenses} (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        trip_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        receipt_path TEXT,
        payment_method TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tableTrips}(id) ON DELETE CASCADE
      )
    ''');

    // 3. Document Vault Table (Multi-tenant with user_id)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableDocuments} (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT,
        local_image_path TEXT NOT NULL,
        trip_id TEXT,
        file_type TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 4. Checklist Items Table (Multi-tenant with user_id)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableChecklistItems} (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        trip_id TEXT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        weight_kg REAL NOT NULL DEFAULT 0.5,
        is_packed INTEGER NOT NULL DEFAULT 0,
        tag TEXT NOT NULL DEFAULT 'CARRY-ON',
        compartment TEXT NOT NULL DEFAULT 'Main Cabin',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tableTrips}(id) ON DELETE SET NULL
      )
    ''');

    // 5. Sync Metadata Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSyncMetadata} (
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL,
        last_synced_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableTrips} ADD COLUMN country_code TEXT');
        await db.execute('ALTER TABLE ${AppConstants.tableTrips} ADD COLUMN transport_mode TEXT');
        await db.execute('ALTER TABLE ${AppConstants.tableTrips} ADD COLUMN notes TEXT');
      } catch (_) {}

      try {
        await db.execute('ALTER TABLE ${AppConstants.tableExpenses} ADD COLUMN payment_method TEXT');
        await db.execute('ALTER TABLE ${AppConstants.tableExpenses} ADD COLUMN notes TEXT');
      } catch (_) {}
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN trip_id TEXT');
        await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN file_type TEXT');
        await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN notes TEXT');
      } catch (_) {}
    }

    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${AppConstants.tableChecklistItems} (
            id TEXT PRIMARY KEY NOT NULL,
            user_id TEXT NOT NULL DEFAULT '',
            trip_id TEXT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1,
            weight_kg REAL NOT NULL DEFAULT 0.5,
            is_packed INTEGER NOT NULL DEFAULT 0,
            tag TEXT NOT NULL DEFAULT 'CARRY-ON',
            compartment TEXT NOT NULL DEFAULT 'Main Cabin',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tableTrips}(id) ON DELETE SET NULL
          )
        ''');
      } catch (_) {}
    }

    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN sub_category TEXT');
      } catch (_) {}
    }

    // Version 6: Multi-tenant user_id column migration for security isolation
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableTrips} ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableExpenses} ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableChecklistItems} ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
      } catch (_) {}
    }
  }

  /// Completely wipes all local SQLite tables (useful for sign-outs)
  Future<void> clearAllData() async {
    if (_database == null) {
      try {
        final bindingName = WidgetsBinding.instance.runtimeType.toString();
        if (bindingName.contains('Test')) {
          return;
        }
      } catch (_) {}
    }
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(AppConstants.tableExpenses);
      await txn.delete(AppConstants.tableChecklistItems);
      await txn.delete(AppConstants.tableDocuments);
      await txn.delete(AppConstants.tableTrips);
      await txn.delete(AppConstants.tableSyncMetadata);
    });
  }

  /// Retrieves the last synced timestamp (in milliseconds since epoch) from SQLite
  Future<int?> getLastSyncedAt({String key = 'sync_engine_last_synced_at'}) async {
    final db = await database;
    final results = await db.query(
      AppConstants.tableSyncMetadata,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return (results.first['last_synced_at'] as num?)?.toInt();
    }
    return null;
  }

  /// Sets or updates the last synced timestamp in SQLite
  Future<void> setLastSyncedAt(int timestamp, {String key = 'sync_engine_last_synced_at'}) async {
    final db = await database;
    await db.insert(
      AppConstants.tableSyncMetadata,
      {
        'key': key,
        'value': DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String(),
        'last_synced_at': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // TRIP CRUD OPERATIONS
  // ==========================================

  /// Inserts a new trip into SQLite strictly associating with userId
  Future<int> insertTrip(Trip trip, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (trip.userId.isNotEmpty ? trip.userId : _currentUserId);
    final tripToSave = trip.userId == effectiveUserId ? trip : trip.copyWith(userId: effectiveUserId);
    return await db.insert(
      AppConstants.tableTrips,
      tripToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves trips strictly filtered by userId. By default only active (non-deleted) trips are returned.
  Future<List<Trip>> getTrips({String? userId, bool includeDeleted = false}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final conditions = <String>['user_id = ?'];
    final args = <dynamic>[effectiveUserId];

    if (!includeDeleted) {
      conditions.add('is_deleted = 0');
    }

    final result = await db.query(
      AppConstants.tableTrips,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'start_date DESC',
    );
    return result.map((map) => Trip.fromMap(map)).toList();
  }

  /// Retrieves a single trip by ID strictly filtered by userId
  Future<Trip?> getTripById(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final maps = await db.query(
      AppConstants.tableTrips,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
    if (maps.isNotEmpty) {
      return Trip.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing trip strictly filtered by userId
  Future<int> updateTrip(Trip trip, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (trip.userId.isNotEmpty ? trip.userId : _currentUserId);
    final updatedTrip = trip.copyWith(
      userId: effectiveUserId,
      updatedAt: DateTime.now(),
    );
    return await db.update(
      AppConstants.tableTrips,
      updatedTrip.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [trip.id, effectiveUserId],
    );
  }

  /// Soft Delete: Marks trip as is_deleted = 1 and cascades soft-delete to associated expenses and checklist items
  Future<int> deleteTrip(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Soft-delete associated expenses
    await db.update(
      AppConstants.tableExpenses,
      {
        'is_deleted': 1,
        'updated_at': now,
      },
      where: 'trip_id = ? AND user_id = ? AND is_deleted = 0',
      whereArgs: [id, effectiveUserId],
    );

    // 2. Soft-delete associated checklist items
    await db.update(
      AppConstants.tableChecklistItems,
      {
        'is_deleted': 1,
        'updated_at': now,
      },
      where: 'trip_id = ? AND user_id = ? AND is_deleted = 0',
      whereArgs: [id, effectiveUserId],
    );

    // 3. Soft-delete the trip itself
    return await db.update(
      AppConstants.tableTrips,
      {
        'is_deleted': 1,
        'updated_at': now,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Restores a soft-deleted trip and its child records
  Future<int> restoreTrip(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      AppConstants.tableExpenses,
      {
        'is_deleted': 0,
        'updated_at': now,
      },
      where: 'trip_id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );

    await db.update(
      AppConstants.tableChecklistItems,
      {
        'is_deleted': 0,
        'updated_at': now,
      },
      where: 'trip_id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );

    return await db.update(
      AppConstants.tableTrips,
      {
        'is_deleted': 0,
        'updated_at': now,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Hard Delete: Permanently removes trip from SQLite (executed after cloud deletion)
  Future<int> hardDeleteTrip(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.delete(
      AppConstants.tableTrips,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Retrieves all trips marked for deletion (is_deleted == 1) strictly filtered by userId for cloud sync
  Future<List<Trip>> getDeletedTrips({String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final result = await db.query(
      AppConstants.tableTrips,
      where: 'is_deleted = 1 AND user_id = ?',
      whereArgs: [effectiveUserId],
    );
    return result.map((map) => Trip.fromMap(map)).toList();
  }

  /// Upsert a trip (insert or update)
  Future<void> upsertTrip(Trip trip, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (trip.userId.isNotEmpty ? trip.userId : _currentUserId);
    final tripToSave = trip.userId == effectiveUserId ? trip : trip.copyWith(userId: effectiveUserId);
    await db.insert(
      AppConstants.tableTrips,
      tripToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // EXPENSE CRUD OPERATIONS
  // ==========================================

  /// Inserts a new expense into SQLite strictly associating with userId
  Future<int> insertExpense(Expense expense, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (expense.userId.isNotEmpty ? expense.userId : _currentUserId);
    final expenseToSave = expense.userId == effectiveUserId ? expense : expense.copyWith(userId: effectiveUserId);
    return await db.insert(
      AppConstants.tableExpenses,
      expenseToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves expenses strictly filtered by userId. Can be filtered by tripId. Non-deleted by default.
  Future<List<Expense>> getExpenses({
    String? tripId,
    String? userId,
    bool includeDeleted = false,
  }) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final conditions = <String>['user_id = ?'];
    final args = <dynamic>[effectiveUserId];

    if (!includeDeleted) {
      conditions.add('is_deleted = 0');
    }
    if (tripId != null) {
      conditions.add('trip_id = ?');
      args.add(tripId);
    }

    final result = await db.query(
      AppConstants.tableExpenses,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Retrieves a single expense by ID strictly filtered by userId
  Future<Expense?> getExpenseById(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final maps = await db.query(
      AppConstants.tableExpenses,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing expense strictly filtered by userId
  Future<int> updateExpense(Expense expense, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (expense.userId.isNotEmpty ? expense.userId : _currentUserId);
    final updatedExpense = expense.copyWith(
      userId: effectiveUserId,
      updatedAt: DateTime.now(),
    );
    return await db.update(
      AppConstants.tableExpenses,
      updatedExpense.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [expense.id, effectiveUserId],
    );
  }

  /// Soft Delete: Marks expense as is_deleted = 1 and updates timestamp
  Future<int> deleteExpense(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.update(
      AppConstants.tableExpenses,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Restores a soft-deleted expense
  Future<int> restoreExpense(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.update(
      AppConstants.tableExpenses,
      {
        'is_deleted': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Hard Delete: Permanently removes expense from SQLite (executed after cloud deletion)
  Future<int> hardDeleteExpense(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.delete(
      AppConstants.tableExpenses,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Retrieves all expenses marked for deletion (is_deleted == 1) strictly filtered by userId for cloud sync
  Future<List<Expense>> getDeletedExpenses({String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final result = await db.query(
      AppConstants.tableExpenses,
      where: 'is_deleted = 1 AND user_id = ?',
      whereArgs: [effectiveUserId],
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Upsert an expense (insert or update)
  Future<void> upsertExpense(Expense expense, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (expense.userId.isNotEmpty ? expense.userId : _currentUserId);
    final expenseToSave = expense.userId == effectiveUserId ? expense : expense.copyWith(userId: effectiveUserId);
    await db.insert(
      AppConstants.tableExpenses,
      expenseToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // DOCUMENT VAULT CRUD OPERATIONS
  // ==========================================

  /// Inserts a new document into SQLite strictly associating with userId
  Future<int> insertDocument(Document document, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (document.userId.isNotEmpty ? document.userId : _currentUserId);
    final docToSave = document.userId == effectiveUserId ? document : document.copyWith(userId: effectiveUserId);
    return await db.insert(
      AppConstants.tableDocuments,
      docToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves documents strictly filtered by userId. By default only active (non-deleted) documents are returned.
  Future<List<Document>> getDocuments({
    String? tripId,
    String? userId,
    bool includeDeleted = false,
  }) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final conditions = <String>['user_id = ?'];
    final args = <dynamic>[effectiveUserId];

    if (!includeDeleted) {
      conditions.add('is_deleted = 0');
    }
    if (tripId != null) {
      conditions.add('trip_id = ?');
      args.add(tripId);
    }

    final result = await db.query(
      AppConstants.tableDocuments,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Document.fromMap(map)).toList();
  }

  /// Retrieves a single document by ID strictly filtered by userId
  Future<Document?> getDocumentById(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final maps = await db.query(
      AppConstants.tableDocuments,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
    if (maps.isNotEmpty) {
      return Document.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing document strictly filtered by userId
  Future<int> updateDocument(Document document, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (document.userId.isNotEmpty ? document.userId : _currentUserId);
    final updatedDoc = document.copyWith(
      userId: effectiveUserId,
      updatedAt: DateTime.now(),
    );
    return await db.update(
      AppConstants.tableDocuments,
      updatedDoc.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [document.id, effectiveUserId],
    );
  }

  /// Soft Delete: Marks document as is_deleted = 1 and updates timestamp
  Future<int> deleteDocument(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.update(
      AppConstants.tableDocuments,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Hard Delete: Permanently removes document from SQLite (executed after cloud deletion)
  Future<int> hardDeleteDocument(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.delete(
      AppConstants.tableDocuments,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Retrieves all documents marked for deletion (is_deleted == 1) strictly filtered by userId for cloud sync
  Future<List<Document>> getDeletedDocuments({String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final result = await db.query(
      AppConstants.tableDocuments,
      where: 'is_deleted = 1 AND user_id = ?',
      whereArgs: [effectiveUserId],
    );
    return result.map((map) => Document.fromMap(map)).toList();
  }

  // ==========================================
  // CHECKLIST ITEMS CRUD OPERATIONS
  // ==========================================

  /// Inserts a new packing checklist item strictly associating with userId
  Future<int> insertChecklistItem(PackingItem item, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (item.userId.isNotEmpty ? item.userId : _currentUserId);
    final itemToSave = item.userId == effectiveUserId ? item : item.copyWith(userId: effectiveUserId);
    return await db.insert(
      AppConstants.tableChecklistItems,
      itemToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves checklist items strictly filtered by userId, optionally filtered by tripId
  Future<List<PackingItem>> getChecklistItems({
    String? tripId,
    String? userId,
    bool includeDeleted = false,
  }) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final conditions = <String>['user_id = ?'];
    final args = <dynamic>[effectiveUserId];

    if (!includeDeleted) {
      conditions.add('is_deleted = 0');
    }
    if (tripId != null) {
      conditions.add('trip_id = ?');
      args.add(tripId);
    }

    final result = await db.query(
      AppConstants.tableChecklistItems,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'is_packed ASC, created_at DESC',
    );
    return result.map((map) => PackingItem.fromMap(map)).toList();
  }

  /// Updates an existing checklist item strictly filtered by userId
  Future<int> updateChecklistItem(PackingItem item, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : (item.userId.isNotEmpty ? item.userId : _currentUserId);
    final updatedItem = item.copyWith(
      userId: effectiveUserId,
      updatedAt: DateTime.now(),
    );
    return await db.update(
      AppConstants.tableChecklistItems,
      updatedItem.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [item.id, effectiveUserId],
    );
  }

  /// Soft deletes a checklist item strictly filtered by userId
  Future<int> deleteChecklistItem(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.update(
      AppConstants.tableChecklistItems,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Restores a soft-deleted checklist item strictly filtered by userId
  Future<int> restoreChecklistItem(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.update(
      AppConstants.tableChecklistItems,
      {
        'is_deleted': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Hard deletes a checklist item strictly filtered by userId
  Future<int> hardDeleteChecklistItem(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    return await db.delete(
      AppConstants.tableChecklistItems,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
  }

  /// Retrieves a single checklist item by ID strictly filtered by userId
  Future<PackingItem?> getChecklistItemById(String id, {String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final maps = await db.query(
      AppConstants.tableChecklistItems,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, effectiveUserId],
    );
    if (maps.isNotEmpty) {
      return PackingItem.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all checklist items marked for deletion (is_deleted == 1) strictly filtered by userId for cloud sync
  Future<List<PackingItem>> getDeletedChecklistItems({String? userId}) async {
    final db = await database;
    final effectiveUserId = (userId != null && userId.isNotEmpty) ? userId : _currentUserId;
    final result = await db.query(
      AppConstants.tableChecklistItems,
      where: 'is_deleted = 1 AND user_id = ?',
      whereArgs: [effectiveUserId],
    );
    return result.map((map) => PackingItem.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
