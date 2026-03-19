// Trajuan Smith

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

  Future<bool> isHabitCompletedOnDate(int habitId, String date) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    return logs.any((log) => log.logDate == date && log.completed);
  }

  Future<int> getCurrentStreak(int habitId) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    if(logs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (var log in logs) {
      final logDate = DateTime.parse(log.logDate);
      final differenceInDays = currentDate.difference(logDate).inDays;

      if (differenceInDays == 0 || differenceInDays == 1) {
        if (log.completed) {
          streak++;
          currentDate = logDate;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    return streak;
  }

  // Creates a updated copy of the habit where isArchived is true,
  // turning tbe habit inactive.
  // This allows soft deletion, where we can later restore the habit 
  // if needed.
  Future<int> archiveHabit(Habit habit) async {
    final archivedHabit = Habit(
      id: habit.id,
      name: habit.name, 
      category: habit.category, 
      frequency: habit.frequency, 
      difficulty: habit.difficulty,
      reminderTime: habit.reminderTime,
      notes: habit.notes,
      streakShieldEnabled: habit.streakShieldEnabled,
      milestoneGoal: habit.milestoneGoal, 
      createdAt: habit.createdAt, 
      updatedAt: DateTime.now().toIso8601String(),
      isArchived: true,
    );

    return await _dbHelper.updateHabit(archivedHabit);
  }

  Future<int> getCompletionCount(int habitId) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    return logs.where((log) => log.completed).length;
  }

  // Returns a 7-day list of whether the habit was completed each day
  Future<List<bool>> getLast7DaysCompletion(int habitId) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    final today = DateTime.now();
    List<bool> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateString = date.toIso8601String().split('T')[0];
      
      final completed = logs.any(
        (log) => log.logDate == dateString && log.completed,
      );
      result.add(completed);
    }
    return result;
  }

  // Check how many of the last 7 days were completed, then
  // return it as a fraction out of 7.
  Future<double> getWeeklyCompletionRate(int habitId) async {
    final last7Days = await getLast7DaysCompletion(habitId);
    final completedCount = last7Days.where((day) => day).length;

    return completedCount / 7;
  }
}