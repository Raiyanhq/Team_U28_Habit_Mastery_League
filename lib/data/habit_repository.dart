// Trajuan Smith

import '../models/habit_log.dart';
import '../models/habits.dart';
import 'database_helper.dart';

class HabitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createHabit(Habit habit) => _dbHelper.insertHabit(habit);
  Future<List<Habit>> fetchAllHabits() => _dbHelper.getAllHabits();
  Future<Habit?> fetchHabitById(int id) => _dbHelper.getHabitById(id);
  Future<int> editHabit(Habit habit) => _dbHelper.updateHabit(habit);
  Future<int> removeHabit(int id) => _dbHelper.deleteHabit(id);
  Future<List<HabitLog>> fetchLogsForHabit(int habitId) =>
      _dbHelper.getLogsForHabit(habitId);
  Future<void> resetAllHabitData() => _dbHelper.resetAllHabitData();

  Future<List<Habit>> fetchActiveHabits() async {
    final habits = await _dbHelper.getAllHabits();
    return habits.where((habit) => !habit.isArchived).toList();
  }

  Future<int> completeHabitForToday(int habitId) async {
    final today = _dateOnly(DateTime.now());
    return _dbHelper.markHabitCompleteForDate(habitId, today);
  }

  Future<int> toggleHabitCompletionForToday(int habitId) async {
    final today = _dateOnly(DateTime.now());
    final isCompleted = await isHabitCompletedOnDate(habitId, today);
    if (isCompleted) {
      return _dbHelper.unmarkHabitCompleteForDate(habitId, today);
    }
    return _dbHelper.markHabitCompleteForDate(habitId, today);
  }

  Future<bool> isHabitCompletedOnDate(int habitId, String date) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    return logs.any((log) => log.logDate == date && log.completed);
  }

  Future<int> getCurrentStreak(int habitId) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    if (logs.isEmpty) return 0;

    final completedDates =
        logs
            .where((log) => log.completed)
            .map((log) => DateTime.parse(log.logDate))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (completedDates.isEmpty) return 0;

    int streak = 0;
    DateTime cursor = DateTime.now();
    final today = DateTime(cursor.year, cursor.month, cursor.day);

    final hasToday = completedDates.any((date) => _sameDay(date, today));
    if (!hasToday) {
      cursor = today.subtract(const Duration(days: 1));
    } else {
      cursor = today;
    }

    while (completedDates.any((date) => _sameDay(date, cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<int> getCompletionCount(int habitId) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    return logs.where((log) => log.completed).length;
  }

  Future<List<bool>> getLast7DaysCompletion(int habitId) async {
    final logs = await _dbHelper.getLogsForHabit(habitId);
    final today = DateTime.now();
    final result = <bool>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateString = _dateOnly(date);
      final completed = logs.any(
        (log) => log.logDate == dateString && log.completed,
      );
      result.add(completed);
    }
    return result;
  }

  Future<double> getWeeklyCompletionRate(int habitId) async {
    final last7Days = await getLast7DaysCompletion(habitId);
    final completedCount = last7Days.where((day) => day).length;
    return completedCount / 7;
  }

  Future<List<Map<String, dynamic>>> getHabitLeaderboard() async {
    final habits = await fetchActiveHabits();
    final leaderboard = <Map<String, dynamic>>[];

    for (final habit in habits) {
      final streak = await getCurrentStreak(habit.id!);
      leaderboard.add({'habit': habit, 'streak': streak});
    }

    leaderboard.sort(
      (a, b) => (b['streak'] as int).compareTo(a['streak'] as int),
    );
    return leaderboard;
  }

  Future<List<int>> getWeeklyCompletionTrend() async {
    final habits = await fetchActiveHabits();
    final today = DateTime.now();
    final trend = List<int>.filled(7, 0);

    for (final habit in habits) {
      final logs = await _dbHelper.getLogsForHabit(habit.id!);
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateString = _dateOnly(date);
        final completed = logs.any(
          (log) => log.logDate == dateString && log.completed,
        );
        if (completed) {
          trend[6 - i] += 1;
        }
      }
    }
    return trend;
  }

  Future<String> getDashboardBuddyMessage() async {
    final habits = await fetchActiveHabits();
    if (habits.isEmpty) {
      return 'Start strong — create your first habit and build momentum.';
    }

    Habit? closestHabit;
    int closestGap = 99999;

    for (final habit in habits) {
      final streak = await getCurrentStreak(habit.id!);
      final gap = habit.milestoneGoal - streak;
      if (gap > 0 && gap < closestGap) {
        closestGap = gap;
        closestHabit = habit;
      }
    }

    if (closestHabit != null && closestGap == 1) {
      return 'You are one day away from your ${closestHabit.milestoneGoal}-day badge in ${closestHabit.name}.';
    }

    final completedToday = await _getCompletedTodayCount(habits);
    if (completedToday == habits.length) {
      return 'Perfect day — you completed every habit for today.';
    }

    return 'Stay consistent today. Small wins turn into big streaks.';
  }

  Future<String> getHabitInsight(Habit habit) async {
    final weeklyRate = await getWeeklyCompletionRate(habit.id!);
    final streak = await getCurrentStreak(habit.id!);

    if (weeklyRate >= 0.8) {
      return 'You complete this habit very consistently.';
    }
    if (streak >= 3) {
      return 'Nice streak. Keep the momentum going.';
    }
    if (weeklyRate == 0) {
      return 'No completions yet. Start today to unlock progress.';
    }
    return 'You complete this habit most often on some days but still have room to improve.';
  }

  Future<List<String>> getStatisticsInsights() async {
    final habits = await fetchActiveHabits();
    if (habits.isEmpty) {
      return ['Create your first habit to unlock weekly insights.'];
    }

    final leaderboard = await getHabitLeaderboard();
    final trend = await getWeeklyCompletionTrend();
    final totalPossible = habits.length * 7;
    final totalCompleted = trend.fold<int>(0, (sum, item) => sum + item);
    final averageRate = totalPossible == 0
        ? 0
        : ((totalCompleted / totalPossible) * 100).round();

    final insights = <String>[];
    final top = leaderboard.isNotEmpty ? leaderboard.first : null;
    if (top != null) {
      insights.add(
        'Your most consistent habit is ${(top['habit'] as Habit).name}.',
      );
    }

    final weekdayTotal = trend.take(5).fold<int>(0, (sum, item) => sum + item);
    final weekendTotal = trend.skip(5).fold<int>(0, (sum, item) => sum + item);
    if (weekdayTotal >= weekendTotal) {
      insights.add('You complete more habits on weekdays.');
    } else {
      insights.add('You are stronger on weekends right now.');
    }

    insights.add('Average weekly completion rate: $averageRate%.');
    return insights;
  }

  Future<String> getWeeklyReflection() async {
    final habits = await fetchActiveHabits();
    if (habits.isEmpty) {
      return 'No data yet. Add habits to start tracking weekly progress.';
    }

    final trend = await getWeeklyCompletionTrend();
    final thisWeek = trend.fold<int>(0, (sum, item) => sum + item);
    final possible = habits.length * 7;
    final percent = possible == 0 ? 0 : ((thisWeek / possible) * 100).round();

    if (percent >= 80) {
      return 'Excellent week. Your consistency is building real momentum.';
    }
    if (percent >= 50) {
      return 'Solid progress this week. A few more check-ins can push you higher.';
    }
    return 'This week is still recoverable. Focus on one habit at a time tomorrow.';
  }

  Future<int> _getCompletedTodayCount(List<Habit> habits) async {
    int count = 0;
    final today = _dateOnly(DateTime.now());
    for (final habit in habits) {
      if (await isHabitCompletedOnDate(habit.id!, today)) {
        count++;
      }
    }
    return count;
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
