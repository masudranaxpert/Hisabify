import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service. Must be called once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Get the device's actual timezone and set it
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      debugPrint('[NotificationService] Device timezone: $timeZoneName');
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('[NotificationService] Timezone error: $e');
      // Fallback: try known timezone
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    // Android notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('[NotificationService] Notification tapped: ${response.payload}');
      },
    );

    _initialized = true;

    // Create notification channel explicitly
    await _createNotificationChannel();

    // Request notification permission on Android 13+
    await _requestPermission();

    // Request exact alarm permission on Android 12+
    await _requestExactAlarmPermission();

    debugPrint('[NotificationService] Initialized successfully');
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Daily reminders for your habits',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      debugPrint('[NotificationService] Notification channel created');
    }
  }

  Future<void> _requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('[NotificationService] Notification permission granted: $granted');
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('[NotificationService] Exact alarm permission granted: $granted');
      }
    }
  }

  /// Schedule a daily notification for a habit at the given time.
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required TimeOfDay time,
  }) async {
    if (!_initialized) await init();

    final notificationId = habitId.hashCode.abs() % 2147483647;

    // Cancel any existing notification for this habit first
    await _plugin.cancel(notificationId);

    // Build the scheduled time using device's local timezone
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('[NotificationService] Scheduling notification for "$habitName"');
    debugPrint('[NotificationService] Current time: $now');
    debugPrint('[NotificationService] Scheduled time: $scheduledDate');
    debugPrint('[NotificationService] Notification ID: $notificationId');

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      notificationId,
      '⏰ $habitName',
      "Time to complete your habit! Keep the streak going! 🔥",
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('[NotificationService] Notification scheduled successfully');
  }

  /// Show an instant test notification to verify notifications are working
  Future<void> showInstant({String title = 'Test', String body = 'Notifications are working!'}) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(0, title, body, notificationDetails);
  }

  /// Cancel the notification for a specific habit.
  Future<void> cancelHabitReminder(String habitId) async {
    if (!_initialized) await init();
    final notificationId = habitId.hashCode.abs() % 2147483647;
    await _plugin.cancel(notificationId);
    debugPrint('[NotificationService] Cancelled notification for habit: $habitId');
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
    debugPrint('[NotificationService] All notifications cancelled');
  }
}

