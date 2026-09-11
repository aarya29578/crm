import 'dart:async';

import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/notification_model.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final DioApi _service = DioApi();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  final RxInt unreadCount = 0.obs;

  Timer? _notificationTimer;

  // Notifications that are already known to the app
  final Set<String> _knownNotificationIds = {};

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // First API call
    getNotifications(isInitialLoad: true);

    // Start checking for new notifications
    startNotificationPolling();
  }

  // ============================================================

  Future<void> getNotifications({bool isInitialLoad = false}) async {
    try {
      // Don't show the full screen loader for every 30-second poll
      if (isInitialLoad) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final response = await _service.getNotifications();

      // Update notification list
      notifications.assignAll(response.notifications);

      // Update unread count
      unreadCount.value = response.unreadCount;

      if (isInitialLoad) {
        // Just remember existing notifications.
        // DO NOT show them as phone notifications.
        for (final notification in response.notifications) {
          _knownNotificationIds.add(notification.id);
        }

        print(
          '🔔 Initial notifications loaded: '
          '${response.notifications.length}',
        );

        return;
      }

      for (final notification in response.notifications) {
        // New notification found
        if (!_knownNotificationIds.contains(notification.id)) {
          print(
            '🆕 New notification received: '
            '${notification.title}',
          );

          await _showLocalNotification(notification);

          // Remember notification
          _knownNotificationIds.add(notification.id);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();

      print('❌ Error fetching notifications: $e');
    } finally {
      if (isInitialLoad) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    try {
      await NotificationService().showNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
      );

      print('🔔 Local notification shown: ${notification.title}');
    } catch (e) {
      print('❌ Failed to show local notification: $e');
    }
  }

  void startNotificationPolling() {
    if (_notificationTimer != null) {
      print('⚠️ Notification polling already running');
      return;
    }

    print('🔄 Notification polling started');

    // Get current notifications first
    getNotifications(isInitialLoad: true);

    // Then check every 30 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      getNotifications();
    });
  }

  void stopNotificationPolling() {
    _notificationTimer?.cancel();
    _notificationTimer = null;

    print('🛑 Notification polling stopped');
  }

  Future<void> refreshNotifications() async {
    await getNotifications();
  }

  @override
  void onClose() {
    stopNotificationPolling();

    super.onClose();
  }
}
