import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;
  final VoidCallback? onStatsTap;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onLongPress,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = habit.isCompletedToday();

    return GestureDetector(
      onTap: onToggle,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? habit.color.withValues(alpha: 0.06) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? habit.color.withValues(alpha: 0.25) : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            // Check circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isDone ? habit.color : habit.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : habit.icon,
                color: isDone ? Colors.white : habit.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Name + streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, size: 13, color: habit.color.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        '${habit.currentStreak} day streak',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats button
            if (onStatsTap != null)
              GestureDetector(
                onTap: onStatsTap,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.bar_chart_rounded, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
              ),

            // Done badge
            if (isDone)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Done', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: habit.color)),
              ),
          ],
        ),
      ),
    );
  }
}
