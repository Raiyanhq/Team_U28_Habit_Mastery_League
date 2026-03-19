// Trajuan Smith
// This is the data model for each habit created, so
// represensts ONE row from the 'habits' table.

class Habit {
  final int? id;
  final String name;
  final String category;
  final String frequency;
  final String difficulty;
  final String? reminderTime;
  final String? notes;
  final bool streakShieldEnabled;
  final int milestoneGoal;
  final String createdAt;
  final String updatedAt;
  final bool isArchived;

  Habit({
    this.id,
    required this.name,
    required this.category,
    required this.frequency,
    required this.difficulty,
    this.reminderTime,
    this.notes,
    this.streakShieldEnabled = false,
    this.milestoneGoal = 7,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  // SQLite does not have a built in native boolean so we store
  // streak_shield_enabled and is_archived as integers 1 and 0 in 
  // the DataBase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'frequency': frequency,
      'difficulty': difficulty,
      'reminder_time': reminderTime,
      'notes': notes,
      'streak_shield_enabled': streakShieldEnabled ? 1 : 0,
      'milestone_goal': milestoneGoal,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_archived': isArchived ? 1 : 0,
    };
  }

  // Revert row to habit object
  // For streakShieldEnabled and isArchived check integer stored and 
  // revert to boolean.
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      frequency: map['frequency'],
      difficulty: map['difficulty'],
      reminderTime: map['reminder_time'],
      notes: map['notes'],
      streakShieldEnabled: map['streak_shield_enabled'] == 1,
      milestoneGoal: map['milestone_goal'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      isArchived: map['is_archived'] == 1,
    );
  }
}