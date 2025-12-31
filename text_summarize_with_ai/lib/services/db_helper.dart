import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'ozet_gecmisi.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE ozetler(id INTEGER PRIMARY KEY AUTOINCREMENT, orijinal TEXT, ozet TEXT, tarih TEXT)",
        );
      },
    );
  }

  static Future<void> ozetKaydet(String orijinal, String ozet) async {
    final db = await database;
    await db.insert('ozetler', {
      'orijinal': orijinal,
      'ozet': ozet,
      'tarih': DateTime.now().toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> gecmisiGetir() async {
    final db = await database;
    return await db.query('ozetler', orderBy: "id DESC");
  }

  static Future<void> ozetSil(int id) async {
    final db = await database;
    await db.delete('ozetler', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> gecmisiAra(String kelime) async {
    final db = await database;
    return await db.query(
      'ozetler',
      where: 'orijinal LIKE ? OR ozet LIKE ?',
      whereArgs: ['%$kelime%', '%$kelime%'],
      orderBy: "id DESC",
    );
  }
}
