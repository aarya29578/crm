import 'dart:async';

import 'package:crm_flutter/api/response/notification_model.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';

class NotificationTimeChecker {
  Timer? _timer;

  // Prevent the same notification from being shown multiple times.
  final Set<String> _notifiedIds = {};

  /// Start checking every second.
  void start(List<NotificationModel> notifications) {
    _timer?.cancel();

    _checkNotifications(notifications);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkNotifications(notifications);
    });

    print('⏰ Notification time checker started');
  }

  void updateNotifications(List<NotificationModel> notifications) {
    _checkNotifications(notifications);
  }

  Future<void> _checkNotifications(
    List<NotificationModel> notifications,
  ) async {
    final now = DateTime.now();

    for (final notification in notifications) {
      if (notification.id.isEmpty) {
        continue;
      }

      if (notification.createdAt == null) {
        continue;
      }

      // API createdAt is UTC.
      // Convert it to device local time.
      final createdAtLocal = notification.createdAt!.toLocal();

      // Compare:
      // Year
      // Month
      // Day
      // Hour
      // Minute
      //
      // Seconds/milliseconds are intentionally ignored.
      final isSameMinute =
          now.year == createdAtLocal.year &&
          now.month == createdAtLocal.month &&
          now.day == createdAtLocal.day &&
          now.hour == createdAtLocal.hour &&
          now.minute == createdAtLocal.minute;

      if (!isSameMinute) {
        continue;
      }

      // Don't show the same notification again.
      if (_notifiedIds.contains(notification.id)) {
        continue;
      }

      print('🔔 Notification time matched');
      print('🆔 ID: ${notification.id}');
      print('📌 Type: ${notification.type}');
      print('💬 Message: ${notification.message}');
      print('🕐 Created At UTC: ${notification.createdAt}');
      print('🕐 Created At Local: $createdAtLocal');
      print('🕐 Current Time: $now');

      await _showLocalNotification(notification);

      _notifiedIds.add(notification.id);
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    try {
      await NotificationService().showNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
      );

      print(
        '✅ Local notification pushed: '
        '${notification.title}',
      );
    } catch (e) {
      print('❌ Failed to show local notification: $e');
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;

    print('🛑 Notification time checker stopped');
  }

  void clearNotifiedIds() {
    _notifiedIds.clear();
  }

  void dispose() {
    stop();
    _notifiedIds.clear();
  }
}
