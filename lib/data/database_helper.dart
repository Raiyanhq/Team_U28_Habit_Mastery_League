// Trajuan Smith
// Helper class to manage our SQLite db setup and connection.

import 'package:habit_mastery_league/models/habit_log.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:habit_mastery_league/models/habits.dart';

class DatabaseHelper {
  // Ensure only a single shared helper object 'instance', exists
  // and only ONE database connection, '_database', is maintained.
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<int> unmarkHabitCompleteForDate(int habitId, String date) async {
    final db = await instance.database;
    return await db.delete(
      'habit_logs',
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habitId, date],
    );
  }

  Future<void> resetAllHabitData() async {
    final db = await instance.database;
    await db.delete('habit_logs');
    await db.delete('habits');
  }

  // If db exists return it,
  // if not, open/create it, then return it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habit_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create both the habits and habit_logs tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        reminder_time TEXT,
        notes TEXT,
        streak_shield_enabled INTEGER NOT NULL DEFAULT 0,
        milestone_goal INTEGER NOT NULL DEFAULT 7,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Wrap habit_id and log_date with UNIQUE to prevent duplicate
    // same-day logs.
    //
    // Also using FOREIGN KEY connect relevant habit to its log,
    // Hence on habit deletion its logs are also deleted.
    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1,
        used_streak_shield INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE (habit_id, log_date)
      )
    ''');
  }

  Future<int> insertHabit(Habit habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit.toMap());
  }

  // Get all rows in the habits table, then
  // loop through each row and convert them to
  // Habit Objects, then convert all Habit Objects
  // to a List.
  Future<List<Habit>> getAllHabits() async {
    final db = await instance.database;
    final result = await db.query('habits');
    return result.map((map) => Habit.fromMap(map)).toList();
  }

  // Checks id using Where clause, then
  // if found, 'result.first' should return
  // the first and only element in the list
  // stored in result. If not found return Null.
  Future<Habit?> getHabitById(int id) async {
    final db = await instance.database;

    final result = await db.query('habits', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Habit.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Mark a habit as complete in the habit_logs
  // create and insert a log map into the table
  Future<int> markHabitCompleteForDate(int habitId, String logDate) async {
    final db = await instance.database;

    final log = {
      'habit_id': habitId,
      'log_date': logDate,
      'completed': 1,
      'used_streak_shield': 0,
      'completed_at': DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'habit_logs',
      log,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Returns all completion Logs for a specific Habit.
  // Same conversion as getAllHabits.
  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final db = await instance.database;

    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'log_date DESC',
    );

    return result.map((map) => HabitLog.fromMap(map)).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await instance.database;

    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;

    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}
