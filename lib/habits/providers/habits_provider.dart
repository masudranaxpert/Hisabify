import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import '../models/habit.dart';

class HabitsProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _notificationsEnabled = true;
  final NotificationService _notificationService = NotificationService();

  List<Habit> get habits => _habits;
  bool get notificationsEnabled => _notificationsEnabled;

  List<Habit> get todayHabits => _habits.where((h) => h.frequency == 'daily').toList();

  int get completedToday => _habits.where((h) => h.isCompletedToday()).length;

  double get todayProgress {
    if (_habits.isEmpty) return 0;
    return completedToday / _habits.length;
  }

  HabitsProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load notification preference
    _notificationsEnabled = prefs.getBool('habits_notifications_enabled') ?? true;

    final data = prefs.getString('habits');
    if (data != null) {
      final List<dynamic> list = jsonDecode(data);
      _habits = list.map((e) => Habit.fromJson(e)).toList();

      // Re-schedule all reminders on app start only if notifications are enabled
      if (_notificationsEnabled) {
        for (final habit in _habits) {
          if (habit.reminderTime != null) {
            _notificationService.scheduleHabitReminder(
              habitId: habit.id,
              habitName: habit.name,
              time: habit.reminderTime!,
            );
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', data);
  }

  /// Toggle notifications on/off and persist the setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('habits_notifications_enabled', enabled);

    if (enabled) {
      // Re-schedule all reminders
      for (final habit in _habits) {
        if (habit.reminderTime != null) {
          _notificationService.scheduleHabitReminder(
            habitId: habit.id,
            habitName: habit.name,
            time: habit.reminderTime!,
          );
        }
      }
    } else {
      // Cancel all notifications
      _notificationService.cancelAll();
    }

    notifyListeners();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveData();

    // Schedule notification if reminder is set and notifications are enabled
    if (habit.reminderTime != null && _notificationsEnabled) {
      _notificationService.scheduleHabitReminder(
        habitId: habit.id,
        habitName: habit.name,
        time: habit.reminderTime!,
      );
    }

    notifyListeners();
  }

  void deleteHabit(String id) {
    // Cancel notification before deleting
    _notificationService.cancelHabitReminder(id);

    _habits.removeWhere((h) => h.id == id);
    _saveData();
    notifyListeners();
  }

  void toggleHabitToday(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final today = _dateKey(DateTime.now());
    final completed = List<String>.from(habit.completedDates);

    if (completed.contains(today)) {
      completed.remove(today);
    } else {
      completed.add(today);
    }

    _habits[index] = habit.copyWith(completedDates: completed);
    _saveData();
    notifyListeners();
  }

  void updateHabit(Habit updated) {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _habits[index] = updated;
      _saveData();

      // Update notification schedule only if notifications are enabled
      if (updated.reminderTime != null && _notificationsEnabled) {
        _notificationService.scheduleHabitReminder(
          habitId: updated.id,
          habitName: updated.name,
          time: updated.reminderTime!,
        );
      } else {
        _notificationService.cancelHabitReminder(updated.id);
      }

      notifyListeners();
    }
  }

  void clearAll() {
    // Cancel all notifications
    _notificationService.cancelAll();

    _habits.clear();
    _saveData();
    notifyListeners();
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

