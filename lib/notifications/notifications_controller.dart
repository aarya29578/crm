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

  // Prevent overlapping API calls.
  bool _isCheckingNotifications = false;

  final Set<String> _knownNotificationIds = {};

  Future<void> getNotifications({bool isInitialLoad = false}) async {
    // Prevent duplicate requests.
    if (_isCheckingNotifications) {
      print('⚠️ Notification API call already running');
      return;
    }

    try {
      _isCheckingNotifications = true;

      if (isInitialLoad) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      print('==========================================');
      print('🔄 CHECKING NOTIFICATIONS');
      print('==========================================');

      final response = await _service.getNotifications();

      notifications.assignAll(response.notifications);

      unreadCount.value = response.unreadCount;

      if (isInitialLoad) {
        print('📌 Registering existing notifications...');

        for (final notification in response.notifications) {
          if (notification.id.isNotEmpty) {
            _knownNotificationIds.add(notification.id);
          }
        }

        print(
          '✅ Existing notification IDs: '
          '${_knownNotificationIds.length}',
        );

        print('==========================================');

        return;
      }

      for (final notification in response.notifications) {
        if (notification.id.isEmpty) {
          continue;
        }

        // Already processed.
        if (_knownNotificationIds.contains(notification.id)) {
          continue;
        }

        print('🔔 NEW NOTIFICATION FOUND');
        print('🆔 ID: ${notification.id}');
        print('📌 TYPE: ${notification.type}');
        print('💬 MESSAGE: ${notification.message}');
        print('🕐 CREATED AT: ${notification.createdAt}');

        await NotificationService().showNotification(
          id: notification.id.hashCode,
          title: notification.title,
          body: notification.message,
        );

        // Mark as known.
        _knownNotificationIds.add(notification.id);

        print('✅ Notification processed');
      }

      print('==========================================');
    } catch (e) {
      errorMessage.value = e.toString();

      print('❌ Error fetching notifications: $e');
    } finally {
      _isCheckingNotifications = false;

      if (isInitialLoad) {
        isLoading.value = false;
      }
    }
  }

  // ============================================================
  // START POLLING
  // ============================================================

  void startNotificationPolling() {
    if (_notificationTimer != null) {
      print('⚠️ Notification polling already running');
      return;
    }

    print('');
    print('==========================================');
    print('🚀 NOTIFICATION POLLING STARTED');
    print('==========================================');

    // First API call.
    getNotifications(isInitialLoad: true);

    // Every 30 seconds.
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      print('');
      print('⏰ 30 seconds completed');

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

  void clearKnownNotificationIds() {
    _knownNotificationIds.clear();

    print('🧹 Known notification IDs cleared');
  }

  @override
  void onClose() {
    stopNotificationPolling();

    super.onClose();
  }
}
