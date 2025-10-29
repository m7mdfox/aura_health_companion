import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezones
    tz.initializeTimeZones();

    // 2. Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Make sure this icon exists

    // 3. iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. Initialize plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request permissions for iOS and Android 13+
  Future<void> requestPermissions() async {
    // iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android
    // Request notification permission first (Android 13+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Then request exact alarm permission (Android 12+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // Get the next instance of a time (e.g., next 8:00 AM)
  tz.TZDateTime _nextInstanceOfTime(
      {required int hour, required int minute, int second = 0}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Schedule a new daily notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour, // Accepts hour directly
    required int minute, // Accepts minute directly
    int second = 0,
    // required time, // <<<--- THIS LINE WAS REMOVED ---<<<
  }) async {
    // +++ ADD LOGGING +++
    final tz.TZDateTime scheduledTime =
        _nextInstanceOfTime(hour: hour, minute: minute, second: second);
    print(
        'Scheduling notification ID $id for: $scheduledTime (in timezone ${tz.local.name})');
    // +++++++++++++++++++

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      // Pass hour/minute/second to the helper
      scheduledTime, // Use the calculated time
      const NotificationDetails(
    android: AndroidNotificationDetails(
      'medicine_channel_id',
      'Medicine Reminders',
      channelDescription: 'Channel for daily medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
      // sound: RawResourceAndroidNotificationSound('res_custom_sound'), // <<<--- DELETE OR COMMENT OUT THIS LINE
    ),
    iOS: DarwinNotificationDetails( // Keep iOS settings as they were
      // sound: 'default.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // This makes it repeat daily
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Cancelled notification ID $id'); // Added log
  }

  // Cancel all notifications (use with care)
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled ALL notifications'); // Added log
  }
}

