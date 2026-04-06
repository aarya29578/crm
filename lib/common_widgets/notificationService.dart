import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// INIT
  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(settings: settings);
  }

  /// REQUEST PERMISSION
  static Future<void> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// SCHEDULE NOTIFICATION
  // Future<void> scheduleNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledDate,
  // }) async {
  //   /// SUBTRACT 30 SECONDS
  //   final notifyBefore = scheduledDate.subtract(const Duration(seconds: 30));

  //   /// Prevent past time error
  //   if (notifyBefore.isBefore(DateTime.now())) {
  //     print("Notification time already passed");
  //     return;
  //   }

  //   await _notifications.zonedSchedule(
  //     id: id,
  //     title: title,
  //     body: body,
  //     scheduledDate: tz.TZDateTime.from(notifyBefore, tz.local),
  //     notificationDetails: const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'Silgate CRM',
  //         'CRM Notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();

    print("⏰ NOW: $now");
    print("📅 SCHEDULED: $scheduledDate");

    if (scheduledDate.isBefore(now)) {
      print("❌ Skipped: Time already passed");
      return;
    }

    print("✅ Scheduling notification...");

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'crm_channel',
          'CRM Notifications',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    print("🎯 Scheduled SUCCESS");
  }

  /// CANCEL
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  /// SHOW INSTANT NOTIFICATION
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'Silgate CRM',
          'CRM Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
