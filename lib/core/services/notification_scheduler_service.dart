import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

class NotificationSchedulerService {
  final DioClient _dioClient;

  NotificationSchedulerService(this._dioClient);

  Future<Map<String, dynamic>> scheduleNotification({
    required String title,
    required String body,
    required String scheduledAt,
    required String topic,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.notificationSchedule,
      data: {
        'title': title,
        'body': body,
        'scheduledAt': scheduledAt,
        'topic': topic,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    final response = await _dioClient.get(ApiEndpoints.notifications);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>? ?? const [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
