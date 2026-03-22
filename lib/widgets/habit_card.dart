import 'package:flutter/material.dart';
import '../models/habits.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final int streak;
  final bool isCompletedToday;
  final VoidCallback onTap;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.isCompletedToday,
    required this.onTap,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final action = await showModalBottomSheet<String>(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.visibility_outlined),
                      title: const Text('View details'),
                      onTap: () => Navigator.pop(context, 'view'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit habit'),
                      onTap: () => Navigator.pop(context, 'edit'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete habit'),
                      onTap: () => Navigator.pop(context, 'delete'),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (action == 'view') onView();
        if (action == 'edit') onEdit();
        if (action == 'delete') onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: scheme.primary.withOpacity(0.15),
        ),
        child: const Icon(Icons.more_horiz),
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompletedToday
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    isCompletedToday ? Icons.check : Icons.circle_outlined,
                    color: isCompletedToday
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${habit.category} • ${habit.frequency} • ${habit.difficulty}',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(label: '🔥 $streak day streak'),
                          _Pill(
                            label: isCompletedToday
                                ? 'Done today'
                                : 'Tap to complete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
