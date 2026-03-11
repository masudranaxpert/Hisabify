import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'today_screen.dart';
import 'habits_screen.dart';
import 'timer_screen.dart';
import 'habits_settings_screen.dart';

class HabitsHome extends StatefulWidget {
  const HabitsHome({super.key});

  @override
  State<HabitsHome> createState() => _HabitsHomeState();
}

class _HabitsHomeState extends State<HabitsHome> {
  int _currentIndex = 0;

  final _screens = const [
    HabitsTodayScreen(),
    HabitsScreen(),
    TimerScreen(),
    HabitsSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: _screens[_currentIndex]),

      // Bottom Nav
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (i) {
            final isSelected = _currentIndex == i;
            final icons = [
              [Icons.today_outlined, Icons.today_rounded],
              [Icons.self_improvement_outlined, Icons.self_improvement_rounded],
              [Icons.timer_outlined, Icons.timer_rounded],
              [Icons.settings_outlined, Icons.settings_rounded],
            ];
            final labels = ['Today', 'Habits', 'Timer', 'Settings'];
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? icons[i][1] : icons[i][0],
                      color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
