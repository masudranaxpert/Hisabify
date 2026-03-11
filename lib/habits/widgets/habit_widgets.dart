import 'package:flutter/material.dart';

/// Small circle with day number - for weekly calendar in habit cards
class DayCircle extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final Color color;

  const DayCircle({
    super.key,
    required this.day,
    this.isCompleted = false,
    this.isToday = false,
    this.color = const Color(0xFFF59E0B),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(
          color: isCompleted
              ? color
              : isToday
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          width: isToday ? 2 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCompleted || isToday ? FontWeight.w700 : FontWeight.w400,
            color: isCompleted
                ? color
                : isToday
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

/// Small icon button used in cards
class CardIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const CardIconBtn({super.key, required this.icon, this.onTap, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: size, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// Stat badge (e.g. "🔥 5" or "✅ 15%")
class StatBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const StatBadge({super.key, required this.icon, required this.text, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      ],
    );
  }
}
