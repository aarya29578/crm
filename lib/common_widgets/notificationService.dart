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

// Old comments , before Nov 3 2026 Tuesday.
    // print('✅ NotificationService initialized');
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

// Old comments , before Nov 3 2026 Tuesday.
    // print('✅ Notification permission requested');
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
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // '🔕 Instant notification blocked - '
        // 'user is logged out',
      // );
      return;
    }

    // ----------------------------------------------------------
    // SHOW NOTIFICATION
    // ----------------------------------------------------------

    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print('------------------------------------------');
// Old comments , before Nov 3 2026 Tuesday.
      // print('🔔 SHOWING LOCAL NOTIFICATION');
// Old comments , before Nov 3 2026 Tuesday.
      // print('🆔 ID: $id');
// Old comments , before Nov 3 2026 Tuesday.
      // print('📌 TITLE: $title');
// Old comments , before Nov 3 2026 Tuesday.
      // print('💬 BODY: $body');

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

// Old comments , before Nov 3 2026 Tuesday.
      // print('✅ LOCAL NOTIFICATION SHOWN');
// Old comments , before Nov 3 2026 Tuesday.
      // print('------------------------------------------');
    } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print('❌ Failed to show local notification: $e');
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
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // '🔕 Scheduled notification blocked - '
        // 'user is logged out',
      // );
      return;
    }

    final localDate = scheduledDate.toLocal();
    final now = DateTime.now();

// Old comments , before Nov 3 2026 Tuesday.
    // print('------------------------------------------');
// Old comments , before Nov 3 2026 Tuesday.
    // print('⏰ SCHEDULING NOTIFICATION');
// Old comments , before Nov 3 2026 Tuesday.
    // print('🆔 ID: $id');
// Old comments , before Nov 3 2026 Tuesday.
    // print('📌 TITLE: $title');
// Old comments , before Nov 3 2026 Tuesday.
    // print('💬 BODY: $body');
// Old comments , before Nov 3 2026 Tuesday.
    // print('🌍 Original: $scheduledDate');
// Old comments , before Nov 3 2026 Tuesday.
    // print('📱 Local: $localDate');
// Old comments , before Nov 3 2026 Tuesday.
    // print('⏰ Now: $now');

    if (localDate.isBefore(now)) {
// Old comments , before Nov 3 2026 Tuesday.
      // print('⏭️ Scheduled time already passed');
// Old comments , before Nov 3 2026 Tuesday.
      // print('------------------------------------------');
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

// Old comments , before Nov 3 2026 Tuesday.
      // print('🎯 Notification scheduled successfully');
    } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print('❌ Failed to schedule notification: $e');
    }

// Old comments , before Nov 3 2026 Tuesday.
    // print('------------------------------------------');
  }

  // ============================================================
  // CANCEL ONE
  // ============================================================

  static Future<void> cancelNotification(int id) async {
// Old comments , before Nov 3 2026 Tuesday.
    // print('');
// Old comments , before Nov 3 2026 Tuesday.
    // print('==========================================');
// Old comments , before Nov 3 2026 Tuesday.
    // print('🔕 CANCEL NOTIFICATION CALLED');
// Old comments , before Nov 3 2026 Tuesday.
    // print('🆔 ID: $id');
// Old comments , before Nov 3 2026 Tuesday.
    // print('📍 CALL STACK:');
// Old comments , before Nov 3 2026 Tuesday.
    // print(StackTrace.current);
// Old comments , before Nov 3 2026 Tuesday.
    // print('==========================================');

    await _notifications.cancel(id: id);

// Old comments , before Nov 3 2026 Tuesday.
    // print('✅ Notification $id cancelled');
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  static Future<void> cancelAllScheduledNotifications() async {
// Old comments , before Nov 3 2026 Tuesday.
    // print('🔕 Cancelling all notifications...');

    await _notifications.cancelAll();

// Old comments , before Nov 3 2026 Tuesday.
    // print('✅ All notifications cancelled');
  }
}
