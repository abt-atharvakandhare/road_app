import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/notifications/notifications_response_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

@lazySingleton
class NotificationsRepo {
  final ApiService _apiService;

  NotificationsRepo(this._apiService);

  Future<void> createNotificationSubscription(String token, String locale) async {
    Map<String, dynamic> data = {
      'address': {'channel': 'push', 'adapter': 'firebase', 'token': token},
      'locale': locale,
    };

    final _ = await _apiService.post('/1/users/me/notifications/subscriptions', data: data);
  }

  Future<NotificationsResponse> getNotificationSettings(String token) async {
    Map<String, String> queryParameters = {'channel': 'push', 'adapter': 'firebase', 'token': token};

    final response = await _apiService.get('/1/users/me/notifications/subscriptions', queryParameters: queryParameters);
    final notificationsResponse = NotificationsResponseModel.fromJson(response.data);
    return notificationsResponse.data;
  }

  Future<void> deleteNotificationSubscription(String token) async {
    final encodedToken = Uri.encodeComponent(token);
    await _apiService
        .delete('/1/users/me/notifications/subscriptions?channel=push&adapter=firebase&token=$encodedToken');
  }

  Future<dynamic> updateNotificationSettings(String token, List<String> topics, bool value) async {
    Map<String, dynamic> data = {
      'address': {
        'channel': 'push',
        'adapter': 'firebase',
        'token': token,
      },
      'topics': topics.map((e) => {'topic': e, 'enabled': value}).toList(),
    };

    final response = await _apiService.patch('/1/users/me/notifications/subscriptions', data: data);
    return response.data;
  }
}
