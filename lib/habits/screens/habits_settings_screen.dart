import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/habits_provider.dart';

class HabitsSettingsScreen extends StatelessWidget {
  const HabitsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HabitsProvider>();
    final notificationsEnabled = provider.notificationsEnabled;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Settings', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),

        // Notifications
        _SectionLabel('NOTIFICATIONS'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: SwitchListTile(
            value: notificationsEnabled,
            onChanged: (v) => provider.setNotificationsEnabled(v),
            title: const Text('Habit Reminders', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              notificationsEnabled ? 'Notifications are enabled' : 'Notifications are disabled',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
            secondary: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: (notificationsEnabled ? AppColors.primary : theme.colorScheme.onSurface).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                notificationsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                color: notificationsEnabled ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
            ),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.primary;
              return theme.colorScheme.onSurface.withValues(alpha: 0.15);
            }),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 24),

        // General
        _SectionLabel('GENERAL'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
                ),
                title: const Text('Reset Today', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Unmark all habits for today', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _confirmResetToday(context, provider),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
              ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.expense.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.delete_sweep_rounded, color: AppColors.expense, size: 20),
                ),
                title: const Text('Clear All Habits', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Remove all habits and data', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _confirmClearAll(context, provider),
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  void _confirmResetToday(BuildContext context, HabitsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Today?'),
        content: const Text('This will unmark all habits completed today.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              for (final h in provider.habits) {
                if (h.isCompletedToday()) {
                  provider.toggleHabitToday(h.id);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, HabitsProvider provider) {
    if (provider.habits.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All?'),
        content: const Text('This will delete all habits permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              for (final h in List.from(provider.habits)) {
                provider.deleteHabit(h.id);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
    ));
  }
}
