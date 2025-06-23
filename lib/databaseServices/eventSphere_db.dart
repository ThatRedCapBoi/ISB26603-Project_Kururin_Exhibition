import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';

class EventSphereDB {
  static final EventSphereDB instance = EventSphereDB._init();
  static Database? _db;

  EventSphereDB._init();

  Future<Database> get database async =>
      _db ??= await _initDB('eventsphere.db');

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    // Users table - Corrected to match User model properties
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
        bookID $idType,
        userEmail TEXT NOT NULL,
        boothType TEXT NOT NULL,
        additionalItems TEXT,
        date TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE admins (
        adminID $idType,
        adminName TEXT NOT NULL,
        adminPassword TEXT NOT NULL,
        adminEmail TEXT NOT NULL
      );
    ''');
  }

  // ---------- USERS ----------

  Future<int> insertUser(User u) async {
    final db = await database;
    // Keys in u.toMap() ('id', 'name', 'email', 'phone', 'password') now directly match table columns
    return await db.insert(
      'users',
      u.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      // Ensure these column names match the table and User.fromMap
      columns: ['id', 'name', 'email', 'phone', 'password'],
      where: 'email = ?',
      whereArgs: [email],
    );
    // User.fromMap will correctly map these columns to User object properties
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<int> updateUser(User u) async {
    final db = await database;
    return await db.update(
      'users',
      u.toMap(), // Uses correct column names from User.toMap()
      where: 'id = ?',
      whereArgs: [u.id],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'phone'],
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- BOOKINGS (booth_book.dart) ----------

  Future<int> insertBooking(Booking b) async {
    final db = await database;
    return await db.insert(
      'bookings',
      b.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
      where: 'bookID = ?',
      whereArgs: [b.bookID],
    );
  }

  Future<int> deleteBooking(int bookID) async {
    final db = await database;
    return await db.delete(
      'bookings',
      where: 'bookID = ?',
      whereArgs: [bookID],
    );
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      columns: ['bookID', 'userEmail', 'boothType', 'additionalItems', 'date'],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  // ---------- ADMINS (admin.dart) ----------

  Future<int> insertAdmin(Admin a) async {
    final db = await database;
    // Insert with id if provided, otherwise let it autoincrement
    final data = {
      'adminID': a.id,
      'adminName': a.name,
      'adminEmail': a.email,
      'adminPassword': a.password,
    };
    return await db.insert(
      'admins',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Admin?> getAdminByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'admins',
      columns: ['adminID', 'adminName', 'adminEmail', 'adminPassword'],
      where: 'adminEmail = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? Admin.fromMap(maps.first) : null;
  }

  Future<int> updateAdmin(Admin a) async {
    final db = await database;
    return await db.update(
      'admins',
      a.toMap(),
      where: 'adminID = ?',
      whereArgs: [a.id],
    );
  }

  Future<int> deleteAdmin(int id) async {
    final db = await database;
    return await db.delete('admins', where: 'adminID = ?', whereArgs: [id]);
  }

  Future<List<Admin>> getAllAdmins() async {
    final db = await database;
    final maps = await db.query('admins');
    return maps.map((map) => Admin.fromMap(map)).toList();
  }
}
