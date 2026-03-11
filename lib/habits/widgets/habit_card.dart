import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import 'habit_widgets.dart';

/// Full habit card with weekly calendar - used in Habits tab
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;
  final VoidCallback? onStatsTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onLongPress,
    this.onStatsTap,
  });

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final weekCompleted = days.where((d) => habit.completedDates.contains(_dateKey(d))).length;
    final weekPct = (weekCompleted / 7 * 100).toInt();

    return GestureDetector(
      onTap: onToggle,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(
                        habit.frequency == 'daily' ? 'Every day' : 'Weekly',
                        style: TextStyle(fontSize: 12, color: habit.color, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: habit.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Weekly calendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((d) {
                final dayLabel = DateFormat('E').format(d).substring(0, 3);
                final isCompleted = habit.completedDates.contains(_dateKey(d));
                final isToday = d == today;
                return Column(
                  children: [
                    Text(dayLabel, style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday ? theme.colorScheme.onSurface.withValues(alpha: 0.8) : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    )),
                    const SizedBox(height: 6),
                    DayCircle(day: d.day, isCompleted: isCompleted, isToday: isToday, color: habit.color),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Bottom row
            Row(
              children: [
                StatBadge(icon: Icons.link_rounded, text: '$weekCompleted', color: habit.color),
                const SizedBox(width: 12),
                StatBadge(icon: Icons.check_circle_outline, text: '$weekPct%', color: habit.color),
                const Spacer(),
                if (habit.reminderTime != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: StatBadge(
                      icon: Icons.alarm_rounded,
                      text: '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
                      color: habit.color,
                    ),
                  ),
                CardIconBtn(icon: Icons.bar_chart_rounded, onTap: onStatsTap),
                const SizedBox(width: 4),
                CardIconBtn(icon: Icons.more_vert_rounded, onTap: onLongPress),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
