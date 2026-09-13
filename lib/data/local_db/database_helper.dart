import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/vault/domain/document.dart';

/// SQLite Database Helper providing offline-first local persistence and soft-delete CRUD
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Trips Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTrips} (
        id TEXT PRIMARY KEY NOT NULL,
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

    // 2. Expenses Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableExpenses} (
        id TEXT PRIMARY KEY NOT NULL,
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

    // 3. Document Vault Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableDocuments} (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        local_image_path TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 4. Sync Metadata Table
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
  }

  // ==========================================
  // TRIP CRUD OPERATIONS
  // ==========================================

  /// Inserts a new trip into SQLite
  Future<int> insertTrip(Trip trip) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableTrips,
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves trips. By default only active (non-deleted) trips are returned.
  Future<List<Trip>> getTrips({bool includeDeleted = false}) async {
    final db = await database;
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final result = await db.query(
      AppConstants.tableTrips,
      where: whereClause,
      orderBy: 'start_date DESC',
    );
    return result.map((map) => Trip.fromMap(map)).toList();
  }

  /// Retrieves a single trip by ID
  Future<Trip?> getTripById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableTrips,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Trip.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing trip
  Future<int> updateTrip(Trip trip) async {
    final db = await database;
    final updatedTrip = trip.copyWith(updatedAt: DateTime.now());
    return await db.update(
      AppConstants.tableTrips,
      updatedTrip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  /// Soft Delete: Marks trip as is_deleted = 1 and updates timestamp
  Future<int> deleteTrip(String id) async {
    final db = await database;
    return await db.update(
      AppConstants.tableTrips,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard Delete: Permanently removes trip from SQLite (executed after cloud deletion)
  Future<int> hardDeleteTrip(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableTrips,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all trips marked for deletion (is_deleted == 1) for cloud sync
  Future<List<Trip>> getDeletedTrips() async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableTrips,
      where: 'is_deleted = 1',
    );
    return result.map((map) => Trip.fromMap(map)).toList();
  }

  /// Upsert a trip (insert or update)
  Future<void> upsertTrip(Trip trip) async {
    final db = await database;
    await db.insert(
      AppConstants.tableTrips,
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // EXPENSE CRUD OPERATIONS
  // ==========================================

  /// Inserts a new expense into SQLite
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves expenses. Can be filtered by tripId. Non-deleted by default.
  Future<List<Expense>> getExpenses({
    String? tripId,
    bool includeDeleted = false,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (!includeDeleted) {
      conditions.add('is_deleted = 0');
    }
    if (tripId != null) {
      conditions.add('trip_id = ?');
      args.add(tripId);
    }

    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    final result = await db.query(
      AppConstants.tableExpenses,
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Retrieves a single expense by ID
  Future<Expense?> getExpenseById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
    return await db.update(
      AppConstants.tableExpenses,
      updatedExpense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Soft Delete: Marks expense as is_deleted = 1 and updates timestamp
  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.update(
      AppConstants.tableExpenses,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard Delete: Permanently removes expense from SQLite (executed after cloud deletion)
  Future<int> hardDeleteExpense(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all expenses marked for deletion (is_deleted == 1) for cloud sync
  Future<List<Expense>> getDeletedExpenses() async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableExpenses,
      where: 'is_deleted = 1',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Upsert an expense (insert or update)
  Future<void> upsertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      AppConstants.tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // DOCUMENT VAULT CRUD OPERATIONS
  // ==========================================

  /// Inserts a new document into SQLite
  Future<int> insertDocument(Document document) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableDocuments,
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves documents. By default only active (non-deleted) documents are returned.
  Future<List<Document>> getDocuments({bool includeDeleted = false}) async {
    final db = await database;
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final result = await db.query(
      AppConstants.tableDocuments,
      where: whereClause,
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Document.fromMap(map)).toList();
  }

  /// Retrieves a single document by ID
  Future<Document?> getDocumentById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableDocuments,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Document.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing document
  Future<int> updateDocument(Document document) async {
    final db = await database;
    final updatedDoc = document.copyWith(updatedAt: DateTime.now());
    return await db.update(
      AppConstants.tableDocuments,
      updatedDoc.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  /// Soft Delete: Marks document as is_deleted = 1 and updates timestamp
  Future<int> deleteDocument(String id) async {
    final db = await database;
    return await db.update(
      AppConstants.tableDocuments,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard Delete: Permanently removes document from SQLite (executed after cloud deletion)
  Future<int> hardDeleteDocument(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableDocuments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all documents marked for deletion (is_deleted == 1) for cloud sync
  Future<List<Document>> getDeletedDocuments() async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableDocuments,
      where: 'is_deleted = 1',
    );
    return result.map((map) => Document.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
