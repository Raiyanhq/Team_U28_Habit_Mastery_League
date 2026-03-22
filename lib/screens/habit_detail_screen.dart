import 'package:flutter/material.dart';

import '../data/habit_repository.dart';
import '../models/habits.dart';
import '../widgets/info_card.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _repository = HabitRepository();
  bool _isLoading = true;
  int _streak = 0;
  int _completionCount = 0;
  List<bool> _week = const [];
  String _insight = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _streak = await _repository.getCurrentStreak(widget.habit.id!);
    _completionCount = await _repository.getCompletionCount(widget.habit.id!);
    _week = await _repository.getLast7DaysCompletion(widget.habit.id!);
    _insight = await _repository.getHabitInsight(widget.habit);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = (_completionCount / widget.habit.milestoneGoal)
        .clamp(0, 1)
        .toDouble();
    final weekLabels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Habit Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Habit: ${widget.habit.name}'),
                Text('Category: ${widget.habit.category}'),
                Text('Frequency: ${widget.habit.frequency}'),
                Text('Difficulty: ${widget.habit.difficulty}'),
                const SizedBox(height: 10),
                Text('Current streak: $_streak days'),
                Text(
                  'Streak shield: ${widget.habit.streakShieldEnabled ? 'Enabled' : 'Off'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(
            title: 'Completion Heatmap',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final complete = _week.isNotEmpty ? _week[index] : false;
                return Column(
                  children: [
                    Text(weekLabels[index]),
                    const SizedBox(height: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: complete
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      ),
                      child: complete
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(
            title: 'Milestone Progress',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next badge: ${widget.habit.milestoneGoal} Day Streak'),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 10),
                Text(
                  'Progress: $_completionCount / ${widget.habit.milestoneGoal} completions',
                ),
                const SizedBox(height: 8),
                Text(
                  _completionCount >= widget.habit.milestoneGoal
                      ? 'Badge earned!'
                      : 'No badge earned yet. Complete your habit consistently to unlock achievements.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(title: 'Habit Insights', child: Text(_insight)),
        ],
      ),
    );
  }
}
