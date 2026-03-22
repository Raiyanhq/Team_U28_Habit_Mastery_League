import 'package:flutter/material.dart';

import '../data/habit_repository.dart';
import '../models/habits.dart';
import '../widgets/info_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _repository = HabitRepository();

  bool _isLoading = true;
  List<Habit> _habits = [];
  Map<int, double> _weeklyRates = {};
  List<int> _trend = [];
  List<Map<String, dynamic>> _leaderboard = [];
  List<String> _insights = [];
  String _reflection = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final habits = await _repository.fetchActiveHabits();
    final rates = <int, double>{};
    for (final habit in habits) {
      rates[habit.id!] = await _repository.getWeeklyCompletionRate(habit.id!);
    }
    _habits = habits;
    _weeklyRates = rates;
    _trend = await _repository.getWeeklyCompletionTrend();
    _leaderboard = await _repository.getHabitLeaderboard();
    _insights = await _repository.getStatisticsInsights();
    _reflection = await _repository.getWeeklyReflection();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No habit data available yet. Create habits and start tracking progress to view statistics.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoCard(
              title: 'Weekly Habit Score',
              child: Column(
                children: _habits.map((habit) {
                  final percent = ((_weeklyRates[habit.id] ?? 0) * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(habit.name), Text('$percent%')],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_weeklyRates[habit.id] ?? 0),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            InfoCard(
              title: 'Weekly Completion Trend',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = _trend[index];
                  final barHeight = value == 0 ? 12.0 : (value * 18).toDouble();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$value'),
                      const SizedBox(height: 6),
                      Container(
                        width: 22,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(labels[index]),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            InfoCard(
              title: 'Streak Leaderboard',
              child: Column(
                children: _leaderboard.asMap().entries.map((entry) {
                  final index = entry.key;
                  final habit = entry.value['habit'] as Habit;
                  final streak = entry.value['streak'] as int;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(habit.name),
                    trailing: Text('$streak days'),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            InfoCard(
              title: 'Habit Insights',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _insights
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $item'),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            InfoCard(title: 'Weekly Reflection', child: Text(_reflection)),
          ],
        ),
      ),
    );
  }
}
