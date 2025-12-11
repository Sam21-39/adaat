import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import '../../data/models/habit_model.dart';
import '../utils/constants.dart';

/// Service for managing local notifications
class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<NotificationService> init() async {
    if (_isInitialized) return this;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    return this;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to habit detail or home
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      // Navigate to habit
      Get.toNamed('/habit-detail', arguments: payload);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // Android 13+ requires explicit permission
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return true;
  }

  /// Schedule a habit reminder
  Future<void> scheduleHabitReminder(HabitModel habit) async {
    if (!habit.reminderEnabled || habit.reminderTime == null) return;

    // Parse reminder time
    final timeParts = habit.reminderTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Get days to schedule based on frequency
    final daysToSchedule = habit.getScheduledDays();

    // Cancel existing reminders for this habit
    await cancelHabitReminders(habit.id);

    // Schedule for each day
    for (final day in daysToSchedule) {
      final notificationId = _generateNotificationId(habit.id, day);

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '${habit.emoji} ${habit.name}',
        _getRandomMotivation(),
        _nextInstanceOfDayAndTime(day, hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Daily reminders for your habits',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(habit.color),
            styleInformation: BigTextStyleInformation(
              _getRandomMotivation(),
              contentTitle: '${habit.emoji} ${habit.name}',
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: habit.id,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: habit.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  /// Cancel reminders for a habit
  Future<void> cancelHabitReminders(String habitId) async {
    // Cancel for all 7 days
    for (int day = 0; day < 7; day++) {
      final notificationId = _generateNotificationId(habitId, day);
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }

  /// Show immediate notification (for testing/celebrations)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: payload,
    );
  }

  /// Show milestone notification
  Future<void> showMilestoneNotification(HabitModel habit, int streak) async {
    await showNotification(
      title: '🔥 $streak Day Streak!',
      body: 'Amazing! You\'re on fire with ${habit.emoji} ${habit.name}!',
      payload: habit.id,
    );
  }

  // Helper: Generate unique notification ID
  int _generateNotificationId(String habitId, int day) {
    return habitId.hashCode + day;
  }

  // Helper: Get next instance of day and time
  tz.TZDateTime _nextInstanceOfDayAndTime(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Calculate days until target day
    int daysUntil = (day - now.weekday + 7) % 7;
    if (daysUntil == 0 && scheduledDate.isBefore(now)) {
      daysUntil = 7;
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntil));
    return scheduledDate;
  }

  // Helper: Get random motivation message
  String _getRandomMotivation() {
    final messages = [
      'Time to build that habit! 💪',
      'Your future self will thank you! 🌟',
      'Consistency is key! Keep going! 🔥',
      'Small steps, big results! 🚀',
      'Let\'s make today count! ✨',
      'You\'ve got this! 💯',
      'Another day, another step forward! 🏆',
      'Stay focused, stay strong! 💎',
    ];
    return messages[DateTime.now().second % messages.length];
  }
}

extension HabitModelSchedule on HabitModel {
  /// Get list of scheduled days (0-6, Sun-Sat)
  List<int> getScheduledDays() {
    switch (frequency) {
      case HabitFrequency.daily:
        return [0, 1, 2, 3, 4, 5, 6];
      case HabitFrequency.weekly:
        // Default to Monday for weekly habits
        return [1];
      case HabitFrequency.custom:
        return customDays ?? [];
    }
  }
}
