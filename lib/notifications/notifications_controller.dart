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
// Old comments , before Nov 3 2026 Tuesday.
      // print('⚠️ Notification API call already running');
      return;
    }

    try {
      _isCheckingNotifications = true;

      if (isInitialLoad) {
        isLoading.value = true;
      }

      errorMessage.value = '';

// Old comments , before Nov 3 2026 Tuesday.
      // print('==========================================');
// Old comments , before Nov 3 2026 Tuesday.
      // print('🔄 CHECKING NOTIFICATIONS');
// Old comments , before Nov 3 2026 Tuesday.
      // print('==========================================');

      final response = await _service.getNotifications();

      notifications.assignAll(response.notifications);

      unreadCount.value = response.unreadCount;

      if (isInitialLoad) {
// Old comments , before Nov 3 2026 Tuesday.
        // print('📌 Registering existing notifications...');

        for (final notification in response.notifications) {
          if (notification.id.isNotEmpty) {
            _knownNotificationIds.add(notification.id);
          }
        }

// Old comments , before Nov 3 2026 Tuesday.
        // print(
          // '✅ Existing notification IDs: '
          // '${_knownNotificationIds.length}',
        // );

// Old comments , before Nov 3 2026 Tuesday.
        // print('==========================================');

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

// Old comments , before Nov 3 2026 Tuesday.
        // print('🔔 NEW NOTIFICATION FOUND');
// Old comments , before Nov 3 2026 Tuesday.
        // print('🆔 ID: ${notification.id}');
// Old comments , before Nov 3 2026 Tuesday.
        // print('📌 TYPE: ${notification.type}');
// Old comments , before Nov 3 2026 Tuesday.
        // print('💬 MESSAGE: ${notification.message}');
// Old comments , before Nov 3 2026 Tuesday.
        // print('🕐 CREATED AT: ${notification.createdAt}');

        await NotificationService().showNotification(
          id: notification.id.hashCode,
          title: notification.title,
          body: notification.message,
        );

        // Mark as known.
        _knownNotificationIds.add(notification.id);

// Old comments , before Nov 3 2026 Tuesday.
        // print('✅ Notification processed');
      }

// Old comments , before Nov 3 2026 Tuesday.
      // print('==========================================');
    } catch (e) {
      errorMessage.value = e.toString();

// Old comments , before Nov 3 2026 Tuesday.
      // print('❌ Error fetching notifications: $e');
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
// Old comments , before Nov 3 2026 Tuesday.
      // print('⚠️ Notification polling already running');
      return;
    }

// Old comments , before Nov 3 2026 Tuesday.
    // print('');
// Old comments , before Nov 3 2026 Tuesday.
    // print('==========================================');
// Old comments , before Nov 3 2026 Tuesday.
    // print('🚀 NOTIFICATION POLLING STARTED');
// Old comments , before Nov 3 2026 Tuesday.
    // print('==========================================');

    // First API call.
    getNotifications(isInitialLoad: true);

    // Every 30 seconds.
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
// Old comments , before Nov 3 2026 Tuesday.
      // print('');
// Old comments , before Nov 3 2026 Tuesday.
      // print('⏰ 30 seconds completed');

      getNotifications();
    });
  }

  void stopNotificationPolling() {
    _notificationTimer?.cancel();

    _notificationTimer = null;

// Old comments , before Nov 3 2026 Tuesday.
    // print('🛑 Notification polling stopped');
  }

  Future<void> refreshNotifications() async {
    await getNotifications();
  }

  void clearKnownNotificationIds() {
    _knownNotificationIds.clear();

// Old comments , before Nov 3 2026 Tuesday.
    // print('🧹 Known notification IDs cleared');
  }

  @override
  void onClose() {
    stopNotificationPolling();

    super.onClose();
  }
}
