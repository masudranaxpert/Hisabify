import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../models/habit.dart';

class HabitStatsScreen extends StatelessWidget {
  final Habit habit;
  const HabitStatsScreen({super.key, required this.habit});

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 30-day data
    final last30 = List.generate(30, (i) => today.subtract(Duration(days: 29 - i)));
    final done30 = last30.where((d) => habit.completedDates.contains(_dateKey(d))).length;
    final pct30 = (done30 / 30 * 100).toInt();

    // Monthly data (last 12 months)
    final monthlyData = _getMonthlyData(today);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [habit.color, habit.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(habit.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${DateFormat('d MMM yyyy').format(habit.createdAt)}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatCard(value: '${habit.currentStreak}', label: 'Current Streak', icon: Icons.local_fire_department_rounded, color: const Color(0xFFF59E0B), theme: theme),
              const SizedBox(width: 10),
              _StatCard(value: '${habit.totalCompleted}', label: 'Total Done', icon: Icons.check_circle_outline, color: AppColors.income, theme: theme),
              const SizedBox(width: 10),
              _StatCard(value: '$pct30%', label: '30-Day Rate', icon: Icons.percent_rounded, color: AppColors.primary, theme: theme),
            ],
          ),
          const SizedBox(height: 24),

          // 30-Day Heatmap
          _SectionTitle('Last 30 Days'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Wrap(
                  spacing: 5, runSpacing: 5,
                  children: last30.map((d) {
                    final done = habit.completedDates.contains(_dateKey(d));
                    final isToday = d == today;
                    return Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: done ? habit.color.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isToday ? habit.color : done ? habit.color.withValues(alpha: 0.4) : theme.dividerColor,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: done
                            ? Icon(Icons.check, size: 14, color: habit.color)
                            : Text('${d.day}', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.25))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: habit.color, label: 'Completed', theme: theme),
                    const SizedBox(width: 16),
                    _LegendDot(color: theme.dividerColor, label: 'Missed', theme: theme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Monthly Progress (last 12 months)
          _SectionTitle('Monthly Progress'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: monthlyData.map((m) {
                final pct = m['total'] > 0 ? m['done'] / m['total'] : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(m['label'] as String, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 10,
                            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation(
                              pct >= 1.0 ? AppColors.income : pct >= 0.5 ? habit.color : AppColors.expense.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${m['done']}/${m['total']}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // All-time summary
          _SectionTitle('All Time'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Total Completions', value: '${habit.totalCompleted}', theme: theme),
                _InfoRow(label: 'Current Streak', value: '${habit.currentStreak} days', theme: theme),
                _InfoRow(label: 'Frequency', value: habit.frequency == 'daily' ? 'Every day' : 'Weekly', theme: theme),
                if (habit.reminderTime != null)
                  _InfoRow(
                    label: 'Reminder',
                    value: '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
                    theme: theme,
                  ),
                _InfoRow(label: 'Created', value: DateFormat('d MMM yyyy').format(habit.createdAt), theme: theme, isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> _getMonthlyData(DateTime today) {
    final List<Map<String, dynamic>> months = [];
    for (int m = 11; m >= 0; m--) {
      final month = DateTime(today.year, today.month - m, 1);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final allDays = List.generate(daysInMonth, (i) => DateTime(month.year, month.month, i + 1));
      final pastDays = allDays.where((d) => !d.isAfter(today)).toList();
      final done = pastDays.where((d) => habit.completedDates.contains(_dateKey(d))).length;
      months.add({'label': DateFormat('MMM').format(month), 'done': done, 'total': pastDays.length});
    }
    return months.reversed.toList();
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _StatCard({required this.value, required this.label, required this.icon, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;
  const _LegendDot({required this.color, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isLast;

  const _InfoRow({required this.label, required this.value, required this.theme, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: theme.dividerColor),
      ],
    );
  }
}
