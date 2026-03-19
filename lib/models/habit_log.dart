// Trajuan Smith
// This class represents completion activity for ONE habit on ONE
// specific day.

class HabitLog {
  final int? id;
  final int habitId;
  final String logDate;
  final bool completed;
  final bool usedStreakShield;
  final String? completedAt;

  HabitLog({
    this.id,
    required this.habitId,
    required this.logDate,
    this.completed = true,
    this.usedStreakShield = false,
    this.completedAt,
  });

  // SQLite does not have a built in native boolean so we store
  // completed and used_streak_shield as integers 1 and 0 in 
  // the DataBase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'log_date': logDate,
      'completed': completed ? 1 : 0,
      'used_streak_shield': usedStreakShield ? 1 : 0,
      'completed_at': completedAt,
    };
  }

  // Revert row to habit object
  // For completed and usedStreakShield check integer stored and 
  // revert to boolean.
  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      logDate: map['log_date'],
      completed: map['completed'] == 1,
      usedStreakShield: map['used_streak_shield'] == 1,
      completedAt: map['completed_at'],
    );
  }
}