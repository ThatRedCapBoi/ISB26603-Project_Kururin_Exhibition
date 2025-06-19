import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// import 'package:Project_Kururin_Exhibition/models/booth_book.dart';

class BoothBookServices {
  static Database? _db;
  static final BoothBookServices instance = BoothBookServices._constructor();

  final String tableName = 'bookings';
  final String columnId = 'id';
  final String columnUserEmail = 'userEmail';
  final String columnBoothType = 'boothType';
  final String columnAdditionalItems = 'additionalItems';
  final String columnDate = 'date';

  BoothBookServices._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();
    final dbPath = join(dbDirPath, 'booth_book_database.db');
    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUserEmail TEXT NOT NULL,
            $columnBoothType TEXT NOT NULL,
            $columnAdditionalItems TEXT,
            $columnDate TEXT NOT NULL
          )
        ''');
      },
    );
    return database;
  }
}
