import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/history_record.dart';

/// Local SQLite storage for saved calculations. Works fully offline.
class HistoryDatabase {
  HistoryDatabase._();

  static final HistoryDatabase instance = HistoryDatabase._();

  static const String _table = 'calculations';
  Database? _db;

  Future<Database> _database() async {
    final existing = _db;
    if (existing != null) return existing;
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'installment_history.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT NOT NULL,
            type TEXT NOT NULL,
            cash_price REAL NOT NULL,
            down_payment REAL NOT NULL,
            months INTEGER NOT NULL,
            monthly_installment REAL NOT NULL,
            total_amount REAL NOT NULL
          )
        ''');
      },
    );
    _db = db;
    return db;
  }

  Future<int> insert(HistoryRecord record) async {
    final db = await _database();
    return db.insert(_table, record.toMap());
  }

  /// Newest first.
  Future<List<HistoryRecord>> all() async {
    final db = await _database();
    final rows = await db.query(_table, orderBy: 'created_at DESC, id DESC');
    return rows.map(HistoryRecord.fromMap).toList();
  }

  Future<void> delete(int id) async {
    final db = await _database();
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _database();
    await db.delete(_table);
  }
}
