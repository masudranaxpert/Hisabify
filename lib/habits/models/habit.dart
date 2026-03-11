import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String frequency; // 'daily', 'weekly'
  final TimeOfDay? reminderTime;
  final List<String> completedDates; // List of 'yyyy-MM-dd' strings
  final DateTime createdAt;

  Habit({
    String? id,
    required this.name,
    this.icon = Icons.check_circle_outline,
    this.color = const Color(0xFF7C3AED),
    this.frequency = 'daily',
    this.reminderTime,
    List<String>? completedDates,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool isCompletedToday() {
    final today = _dateKey(DateTime.now());
    return completedDates.contains(today);
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      if (completedDates.contains(_dateKey(day))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalCompleted => completedDates.length;

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Habit copyWith({
    String? name,
    IconData? icon,
    Color? color,
    String? frequency,
    TimeOfDay? reminderTime,
    bool clearReminder = false,
    List<String>? completedDates,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCode': icon.codePoint,
    'colorValue': color.toARGB32(),
    'frequency': frequency,
    'reminderHour': reminderTime?.hour,
    'reminderMinute': reminderTime?.minute,
    'completedDates': completedDates,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    name: json['name'],
    icon: IconData(json['iconCode'] ?? 0xe156, fontFamily: 'MaterialIcons'),
    color: Color(json['colorValue'] ?? 0xFF7C3AED),
    frequency: json['frequency'] ?? 'daily',
    reminderTime: json['reminderHour'] != null
        ? TimeOfDay(hour: json['reminderHour'], minute: json['reminderMinute'] ?? 0)
        : null,
    completedDates: List<String>.from(json['completedDates'] ?? []),
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}
