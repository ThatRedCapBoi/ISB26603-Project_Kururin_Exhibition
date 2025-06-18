import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/booth_book.dart'; // booking model

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async =>
      _db ??= await _initDB('eventsphere.db');

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL
      );
    ''');

    // Bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT NOT NULL,
        boothType TEXT NOT NULL,
        additionalItems TEXT,
        date TEXT NOT NULL
      );
    ''');
  }

  // ---------- USERS ----------

  Future<int> insertUser(User u) async {
    final db = await database;
    return await db.insert('users', u.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'phone', 'password'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<int> updateUser(User u) async {
    final db = await database;
    return await db.update(
      'users',
      u.toMap(),
      where: 'id = ?',
      whereArgs: [u.id],
    );
  }

  // ---------- BOOKINGS (booth_book.dart) ----------

  Future<int> insertBooking(Booking b) async {
    final db = await database;
    return await db.insert('bookings', b.toMap());
  }

  Future<List<Booking>> getBookingsByUser(String email) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'userEmail = ?',
      whereArgs: [email],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<int> updateBooking(Booking b) async {
    final db = await database;
    return await db.update(
      'bookings',
      b.toMap(),
      where: 'id = ?',
      whereArgs: [b.id],
    );
  }
}