import '../models/habits.dart';
import '../models/habit_log.dart';
import 'database_helper.dart';

// This will be the layer in between the UI layer and raw databse
class HabitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createHabit(Habit habit) async {
    return await _dbHelper.insertHabit(habit);
  }

  Future<List<Habit>> fetchAllHabits() async {
    return await _dbHelper.getAllHabits();
  }

  Future<Habit?> fetchHabitById(int id) async {
    return await _dbHelper.getHabitById(id);
  }

  Future<int> editHabit(Habit habit) async {
    return await _dbHelper.updateHabit(habit);
  }

  Future<int> removeHabit(int id) async {
    return await _dbHelper.deleteHabit(id);
  }

  Future<int> completeHabitForToday(int habitId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await _dbHelper.markHabitCompleteForDate(habitId, today);
  }

  Future<List<HabitLog>> fetchLogsForHabit(int habitId) async {
    return await _dbHelper.getLogsForHabit(habitId);
  }

  // Returns a list of all non-archived habits
  Future<List<Habit>> fetchActiveHabits() async {
    final habits = await _dbHelper.getAllHabits();
    return habits.where((habit) => !habit.isArchived).toList();
  }
}