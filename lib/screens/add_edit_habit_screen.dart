import 'package:flutter/material.dart';

import '../models/habits.dart';
import '../services/preferences_service.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _preferencesService = PreferencesService();

  final List<String> _categories = [
    'Academics',
    'Fitness',
    'Health',
    'Productivity',
    'Personal Development',
    'Other',
  ];
  final List<String> _frequencies = [
    'Daily',
    'Weekdays',
    'Weekends',
    'Custom Schedule',
  ];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _times = [
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '12:00 PM',
    '5:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
  ];
  final List<int> _milestones = [3, 7, 14, 30];

  String _category = 'Academics';
  String _frequency = 'Daily';
  String _difficulty = 'Medium';
  String _reminderTime = '7:00 PM';
  int _milestoneGoal = 7;
  bool _streakShieldEnabled = false;

  bool get _isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    if (_isEditMode) {
      final habit = widget.habit!;
      _nameController.text = habit.name;
      _notesController.text = habit.notes ?? '';
      _category = habit.category;
      _frequency = habit.frequency;
      _difficulty = habit.difficulty;
      _reminderTime = habit.reminderTime ?? _reminderTime;
      _milestoneGoal = habit.milestoneGoal;
      _streakShieldEnabled = habit.streakShieldEnabled;
      if (mounted) setState(() {});
      return;
    }

    _reminderTime = await _preferencesService.getDefaultReminderTime();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now().toIso8601String();

    final habit = Habit(
      id: widget.habit?.id,
      name: _nameController.text.trim(),
      category: _category,
      frequency: _frequency,
      difficulty: _difficulty,
      reminderTime: _reminderTime,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      streakShieldEnabled: _streakShieldEnabled,
      milestoneGoal: _milestoneGoal,
      createdAt: widget.habit?.createdAt ?? now,
      updatedAt: now,
      isArchived: widget.habit?.isArchived ?? false,
    );

    Navigator.pop(context, habit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Habit' : 'Add Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Habit Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Habit name cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: _frequencies
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _frequency = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty / Goal Level',
                ),
                items: _difficulties
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _difficulty = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _times.contains(_reminderTime)
                    ? _reminderTime
                    : _times.first,
                decoration: const InputDecoration(labelText: 'Reminder Time'),
                items: _times
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _reminderTime = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes / Motivation',
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Streak Shield Enabled'),
                value: _streakShieldEnabled,
                onChanged: (value) =>
                    setState(() => _streakShieldEnabled = value),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _milestones.contains(_milestoneGoal)
                    ? _milestoneGoal
                    : 7,
                decoration: const InputDecoration(
                  labelText: 'Milestone Badge Goal',
                ),
                items: _milestones
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text('$item days'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _milestoneGoal = value!),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(_isEditMode ? 'Save Changes' : 'Save Habit'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_isEditMode ? 'Cancel' : 'Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
