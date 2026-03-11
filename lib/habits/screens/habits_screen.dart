import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_card.dart';
import 'habit_stats_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  static const _habitIcons = [
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.self_improvement_rounded,
    Icons.directions_run_rounded,
    Icons.bedtime_rounded,
    Icons.music_note_rounded,
    Icons.code_rounded,
    Icons.brush_rounded,
    Icons.restaurant_rounded,
    Icons.no_drinks_rounded,
    Icons.spa_rounded,
  ];

  static const _habitColors = [
    Color(0xFF7C3AED),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HabitsProvider>();
    final habits = provider.habits;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Habits', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${habits.length} habits tracked', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 20),

            if (habits.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.add_task_rounded, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
                    const SizedBox(height: 12),
                    Text('Create your first habit', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showAddHabit(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Habit'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
              )
            else
              ...habits.map((h) => HabitCard(
                habit: h,
                onToggle: () => provider.toggleHabitToday(h.id),
                onLongPress: () => _showHabitOptions(context, provider, h),
                onStatsTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HabitStatsScreen(habit: h))),
              )),

            const SizedBox(height: 80),
          ],
        ),

        // FAB
        if (habits.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton(
              onPressed: () => _showAddHabit(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }

  /// Show bottom sheet with Edit and Delete options for a habit
  void _showHabitOptions(BuildContext context, HabitsProvider provider, Habit habit) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(habit.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Edit option
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
              ),
              title: const Text('Edit Habit', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Change name, icon, color or reminder', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                _showEditHabit(context, habit);
              },
            ),
            const SizedBox(height: 4),

            // Delete option
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_rounded, color: AppColors.expense, size: 20),
              ),
              title: const Text('Delete Habit', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.expense)),
              subtitle: Text('Remove this habit permanently', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context, provider, habit);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabit(BuildContext context) {
    _showHabitForm(context, null);
  }

  void _showEditHabit(BuildContext context, Habit habit) {
    _showHabitForm(context, habit);
  }

  /// Shared form for both Add and Edit habit
  void _showHabitForm(BuildContext context, Habit? existingHabit) {
    final isEditing = existingHabit != null;
    final nameController = TextEditingController(text: existingHabit?.name ?? '');
    IconData selectedIcon = existingHabit?.icon ?? _habitIcons[0];
    Color selectedColor = existingHabit?.color ?? _habitColors[0];
    TimeOfDay? reminderTime = existingHabit?.reminderTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(isEditing ? 'Edit Habit' : 'New Habit', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // Name
              TextField(
                controller: nameController,
                autofocus: !isEditing,
                decoration: const InputDecoration(hintText: 'Habit name', prefixIcon: Icon(Icons.edit_rounded, size: 20)),
              ),
              const SizedBox(height: 16),

              // Icon picker
              Text('Icon', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _habitIcons.map((icon) => GestureDetector(
                  onTap: () => setModalState(() => selectedIcon = icon),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: selectedIcon == icon ? selectedColor.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selectedIcon == icon ? selectedColor : Theme.of(ctx).dividerColor),
                    ),
                    child: Icon(icon, size: 20, color: selectedIcon == icon ? selectedColor : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // Color picker
              Text('Color', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Row(
                children: _habitColors.map((color) => GestureDetector(
                  onTap: () => setModalState(() => selectedColor = color),
                  child: Container(
                    width: 34, height: 34,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedColor == color ? Colors.white : Colors.transparent, width: 2),
                      boxShadow: selectedColor == color ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)] : null,
                    ),
                    child: selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // Reminder
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: selectedColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.alarm_rounded, color: selectedColor, size: 20),
                ),
                title: const Text('Reminder'),
                subtitle: Text(reminderTime != null
                    ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
                    : 'No reminder set'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reminderTime != null)
                      GestureDetector(
                        onTap: () => setModalState(() => reminderTime = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.expense.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.expense),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: reminderTime ?? TimeOfDay.now(),
                  );
                  if (time != null) setModalState(() => reminderTime = time);
                },
              ),
              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    if (isEditing) {
                      // Update existing habit
                      final updated = existingHabit.copyWith(
                        name: nameController.text.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                        reminderTime: reminderTime,
                        clearReminder: reminderTime == null,
                      );
                      context.read<HabitsProvider>().updateHabit(updated);
                    } else {
                      // Create new habit
                      context.read<HabitsProvider>().addHabit(Habit(
                        name: nameController.text.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                        reminderTime: reminderTime,
                      ));
                    }
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: selectedColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Habit',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HabitsProvider provider, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${habit.name}"?'),
        content: const Text('This will remove the habit and all its data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}
