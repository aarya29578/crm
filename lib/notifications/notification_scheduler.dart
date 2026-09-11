import 'package:crm_flutter/api/response/notification_model.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';

class NotificationScheduler {
  final NotificationService _notificationService = NotificationService();

  // Keeps track of notifications that have already been scheduled.
  final Set<String> _scheduledNotificationIds = {};

  /// Schedule all notifications received from API.
  Future<void> scheduleNotifications(
    List<NotificationModel> notifications,
  ) async {
    for (final notification in notifications) {
      await scheduleNotification(notification);
    }
  }

  /// Schedule one notification.
  Future<void> scheduleNotification(NotificationModel notification) async {
    if (notification.id.isEmpty) {
      print('⚠️ Notification ID is empty');
      return;
    }

    if (notification.createdAt == null) {
      print('⚠️ createdAt is null for ${notification.id}');
      return;
    }

    // Prevent duplicate scheduling.
    if (_scheduledNotificationIds.contains(notification.id)) {
      print(
        '⚠️ Notification already scheduled: '
        '${notification.id}',
      );
      return;
    }

    // createdAt from backend is UTC.
    //
    // Example:
    // 2026-09-10T00:32:00.882Z
    //
    // .toLocal() converts it to device timezone.
    final scheduledDate = notification.createdAt!.toLocal();

    final now = DateTime.now();

    print('--------------------------------------');
    print('🔔 Preparing notification');
    print('🆔 ID: ${notification.id}');
    print('📌 Type: ${notification.type}');
    print('💬 Message: ${notification.message}');
    print('🌍 UTC: ${notification.createdAt}');
    print('📱 Local: $scheduledDate');
    print('🕐 Current: $now');

    // If createdAt is already in the past,
    // don't schedule it.
    if (scheduledDate.isBefore(now)) {
      print(
        '⏭️ Notification time already passed: '
        '${notification.id}',
      );

      _scheduledNotificationIds.add(notification.id);

      return;
    }

    await _notificationService.scheduleNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.message,
      scheduledDate: scheduledDate,
    );

    _scheduledNotificationIds.add(notification.id);

    print(
      '✅ Notification scheduled for '
      '$scheduledDate',
    );

    print('--------------------------------------');
  }

  /// Remove a notification from the local scheduled list.
  Future<void> cancelNotification(NotificationModel notification) async {
    if (notification.id.isEmpty) {
      return;
    }

    await NotificationService.cancelNotification(notification.id.hashCode);

    _scheduledNotificationIds.remove(notification.id);

    print(
      '🗑️ Notification cancelled: '
      '${notification.id}',
    );
  }

  /// Cancel every scheduled notification.
  Future<void> cancelAll() async {
    await NotificationService.cancelAllScheduledNotifications();

    _scheduledNotificationIds.clear();

    print('🗑️ All notifications cancelled');
  }

  void clearLocalCache() {
    _scheduledNotificationIds.clear();
  }
}
