class NotificationModel {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  String get title {
    switch (type) {
      case 'HIGH_WIP_COUNT':
        return 'High WIP Count';

      case 'LEAD_IMPORT':
        return 'Lead Import';

      default:
        return type
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }
}

class NotificationsResponse {
  final bool success;
  final int unreadCount;
  final List<NotificationModel> notifications;

  NotificationsResponse({
    required this.success,
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map(
                (notification) => NotificationModel.fromJson(
                  notification as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
