import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';

/// SQLite Database Helper providing offline-first local persistence
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
        is_deleted INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        updated_at INTEGER NOT NULL
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
        is_deleted INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES ${AppConstants.tableTrips}(id) ON DELETE CASCADE
      )
    ''');

    // 3. Document Vault Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableDocuments} (
        id TEXT PRIMARY KEY NOT NULL,
        trip_id TEXT,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        updated_at INTEGER NOT NULL
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

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
