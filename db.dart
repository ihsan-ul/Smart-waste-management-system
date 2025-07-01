import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('waste_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
      await db.execute("DROP TABLE IF EXISTS users");
      await db.execute("DROP TABLE IF EXISTS waste_counts");

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE waste_counts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        recyclable INTEGER,
        organic INTEGER,
        general INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<int> createUser(String username, String password) async {
    final db = await database;
    final userId = await db.insert('users', {'username': username, 'password': password});
    await db.insert('waste_counts', {'user_id': userId, 'recyclable': 0, 'organic': 0, 'general': 0});
    return userId;
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'username = ?',
    whereArgs: [username],
  );
  return result.isNotEmpty ? result.first : null;
}


  Future<void> updateWasteCount(int userId, String wasteType) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE waste_counts
      SET $wasteType = $wasteType + 1
      WHERE user_id = ?
    ''', [userId]);
  }

  Future<Map<String, int>> getWasteCounts(int userId) async {
    final db = await database;
    final results = await db.query(
      'waste_counts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return {
        'recyclable': results.first['recyclable'] as int,
        'organic': results.first['organic'] as int,
        'general': results.first['general'] as int,
      };
    }
    return {'recyclable': 0, 'organic': 0, 'general': 0};
  }
}
