import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart'; // Get the Admin data model

class AdminServices {
  static Database? _db;
  static final AdminServices instance = AdminServices._constructor();

  final String tableName = 'admins';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnPassword = 'password';
  final String columnEmail = 'email';

  AdminServices._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();
    final dbPath = join(dbDirPath, 'admin_database.db');
    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            $columnId TEXT PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnEmail TEXT NOT NULL
          )
        ''');
      },
    );
    return database;
  }

  Future<List<Admin>> getAdmins() async {
    final db = await database;

    final List<Map<String, dynamic>> admins = await db.query(tableName);
    return List.generate(admins.length, (i) {
      return Admin(
        id: admins[i][columnId] as int?,
        name: admins[i][columnName] as String,
        password: admins[i][columnPassword] as String,
        email: admins[i][columnEmail] as String,
      );
    });
  }
}
