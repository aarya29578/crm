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

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'crm_channel',
      'CRM Notifications',
      description: 'Notifications from CRM',
      importance: Importance.max,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);

    print('✅ NotificationService initialized');
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

    print('✅ Notification permission requested');
  }

  // ============================================================
  // SHOW LOCAL NOTIFICATION
  // ============================================================

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // ----------------------------------------------------------
    // CHECK LOGIN
    // ----------------------------------------------------------

    if (!isUserLoggedIn()) {
      print(
        '🔕 Instant notification blocked - '
        'user is logged out',
      );
      return;
    }

    // ----------------------------------------------------------
    // SHOW NOTIFICATION
    // ----------------------------------------------------------

    try {
      print('------------------------------------------');
      print('🔔 SHOWING LOCAL NOTIFICATION');
      print('🆔 ID: $id');
      print('📌 TITLE: $title');
      print('💬 BODY: $body');

      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'crm_channel',
            'CRM Notifications',
            channelDescription: 'Notifications from CRM',
            importance: Importance.max,
            priority: Priority.high,
            autoCancel: true,
            ongoing: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      print('✅ LOCAL NOTIFICATION SHOWN');
      print('------------------------------------------');
    } catch (e) {
      print('❌ Failed to show local notification: $e');
    }
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
    if (!isUserLoggedIn()) {
      print(
        '🔕 Scheduled notification blocked - '
        'user is logged out',
      );
      return;
    }

    final localDate = scheduledDate.toLocal();
    final now = DateTime.now();

    print('------------------------------------------');
    print('⏰ SCHEDULING NOTIFICATION');
    print('🆔 ID: $id');
    print('📌 TITLE: $title');
    print('💬 BODY: $body');
    print('🌍 Original: $scheduledDate');
    print('📱 Local: $localDate');
    print('⏰ Now: $now');

    if (localDate.isBefore(now)) {
      print('⏭️ Scheduled time already passed');
      print('------------------------------------------');
      return;
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      localDate,
      tz.local,
    );

    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'crm_channel',
            'CRM Notifications',
            channelDescription: 'Notifications from CRM',
            importance: Importance.max,
            priority: Priority.high,
            autoCancel: true,
            ongoing: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );

      print('🎯 Notification scheduled successfully');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
    }

    print('------------------------------------------');
  }

  // ============================================================
  // CANCEL ONE
  // ============================================================

  static Future<void> cancelNotification(int id) async {
    print('');
    print('==========================================');
    print('🔕 CANCEL NOTIFICATION CALLED');
    print('🆔 ID: $id');
    print('📍 CALL STACK:');
    print(StackTrace.current);
    print('==========================================');

    await _notifications.cancel(id: id);

    print('✅ Notification $id cancelled');
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  static Future<void> cancelAllScheduledNotifications() async {
    print('🔕 Cancelling all notifications...');

    await _notifications.cancelAll();

    print('✅ All notifications cancelled');
  }
}
