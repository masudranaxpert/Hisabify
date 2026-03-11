import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_tile.dart';

class HabitsTodayScreen extends StatelessWidget {
  const HabitsTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HabitsProvider>();
    final habits = provider.todayHabits;
    final completed = provider.completedToday;
    final total = habits.length;
    final progress = provider.todayProgress;

    // Best streak
    final bestStreak = habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).fold(0, (a, b) => a > b ? a : b);
    final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.totalCompleted);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 16),

        // Progress card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today's Progress", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$completed / $total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              if (progress >= 1)
                Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('All done! Great job!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                )
              else
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            _MiniStat(icon: Icons.local_fire_department_rounded, value: '$bestStreak', label: 'Best Streak', color: const Color(0xFFF59E0B), theme: theme),
            const SizedBox(width: 10),
            _MiniStat(icon: Icons.check_circle_outline, value: '$totalCompletions', label: 'Total Done', color: AppColors.income, theme: theme),
            const SizedBox(width: 10),
            _MiniStat(icon: Icons.list_alt_rounded, value: '$total', label: 'Habits', color: AppColors.primary, theme: theme),
          ],
        ),
        const SizedBox(height: 24),

        // Habits list
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Habits", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text('$total habits', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(height: 12),

        if (habits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.self_improvement_rounded, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
                const SizedBox(height: 12),
                Text('No habits yet', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                const SizedBox(height: 4),
                Text('Go to Habits tab to create one', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
              ],
            ),
          )
        else
          ...habits.map((h) => HabitTile(
            habit: h,
            onToggle: () => provider.toggleHabitToday(h.id),
          )),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const _MiniStat({required this.icon, required this.value, required this.label, required this.color, required this.theme});

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
            Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          ],
        ),
      ),
    );
  }
}
