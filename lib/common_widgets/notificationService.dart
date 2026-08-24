import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // CHECK LOGIN STATUS
  // ============================================================

  static bool isUserLoggedIn() {
    final token = LocalStorage.sharedPreferences?.getString('token');

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // INIT
  // ============================================================

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(settings: settings);
  }

  // ============================================================
  // REQUEST PERMISSION
  // ============================================================

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

  // ============================================================
  // SCHEDULE NOTIFICATION
  // ============================================================

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // IMPORTANT:
    // Don't schedule anything if user is logged out.
    if (!isUserLoggedIn()) {
      print("🔕 Notification blocked - user is logged out");
      return;
    }

    final now = DateTime.now();

    print("⏰ NOW: $now");
    print("📅 SCHEDULED: $scheduledDate");

    if (scheduledDate.isBefore(now)) {
      print("❌ Skipped: Time already passed");
      return;
    }

    print("✅ User is logged in");
    print("🔔 Scheduling notification...");

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

  // ============================================================
  // CANCEL ONE
  // ============================================================

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);

    print("🔕 Notification $id cancelled");
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  static Future<void> cancelAllScheduledNotifications() async {
    await _notifications.cancelAll();

    print("🔕 All scheduled notifications cancelled");
  }

  // ============================================================
  // SHOW INSTANT NOTIFICATION
  // ============================================================

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // IMPORTANT:
    // Prevent instant notifications when logged out.
    if (!isUserLoggedIn()) {
      print("🔕 Instant notification blocked - user is logged out");
      return;
    }

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'crm_channel',
          'CRM Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    print("🔔 Instant notification shown");
  }
}
