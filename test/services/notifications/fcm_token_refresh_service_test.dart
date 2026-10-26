import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/model/notifications/notifications_response_model.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/notifications/fcm_token_refresh_service.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_repo.dart';

@GenerateMocks([NotificationsRepo, AuthStorage])
import 'fcm_token_refresh_service_test.mocks.dart';

void main() {
  late MockNotificationsRepo mockRepo;
  late MockAuthStorage mockStorage;
  late FcmTokenRefreshService service;

  const oldToken = 'old-fcm-token-abc';
  const newToken = 'new-fcm-token-xyz';
  final topicsList = ['charging.session.started', 'charging.session.ended'];

  setUp(() {
    mockRepo = MockNotificationsRepo();
    mockStorage = MockAuthStorage();
    service = FcmTokenRefreshService(mockRepo, mockStorage);

    // Default: storeFcmToken always succeeds
    when(mockStorage.storeFcmToken(any)).thenAnswer((_) async {});
  });

  group('onTokenRefresh', () {
    test('stores the token when no old token exists', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => null);

      await service.onTokenRefresh(newToken);

      verify(mockStorage.storeFcmToken(newToken)).called(1);
      verifyNever(mockRepo.getNotificationSettings(any));
      verifyNever(mockRepo.createNotificationSubscription(any, any));
    });

    test('stores the token without API calls when token has not changed', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => newToken);

      await service.onTokenRefresh(newToken);

      verify(mockStorage.storeFcmToken(newToken)).called(1);
      verifyNever(mockRepo.getNotificationSettings(any));
      verifyNever(mockRepo.createNotificationSubscription(any, any));
    });

    test('migrates subscription when token has changed', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => oldToken);
      when(mockRepo.getNotificationSettings(oldToken))
          .thenAnswer((_) async => NotificationsResponse(topics: topicsList));
      when(mockRepo.createNotificationSubscription(any, any)).thenAnswer((_) async {});
      when(mockRepo.updateNotificationSettings(any, any, any)).thenAnswer((_) async => {});
      when(mockRepo.deleteNotificationSubscription(any)).thenAnswer((_) async {});

      await service.onTokenRefresh(newToken);

      // Verify the full migration sequence
      verifyInOrder([
        mockStorage.readFcmToken(),
        mockRepo.getNotificationSettings(oldToken),
        mockRepo.createNotificationSubscription(newToken, any),
        mockRepo.updateNotificationSettings(newToken, topicsList, true),
        mockRepo.deleteNotificationSubscription(oldToken),
        mockStorage.storeFcmToken(newToken),
      ]);
    });

    test('skips updateNotificationSettings when old subscription had no topics', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => oldToken);
      when(mockRepo.getNotificationSettings(oldToken))
          .thenAnswer((_) async => NotificationsResponse(topics: []));
      when(mockRepo.createNotificationSubscription(any, any)).thenAnswer((_) async {});
      when(mockRepo.deleteNotificationSubscription(any)).thenAnswer((_) async {});

      await service.onTokenRefresh(newToken);

      verify(mockRepo.createNotificationSubscription(newToken, any)).called(1);
      verifyNever(mockRepo.updateNotificationSettings(any, any, any));
      verify(mockRepo.deleteNotificationSubscription(oldToken)).called(1);
      verify(mockStorage.storeFcmToken(newToken)).called(1);
    });

    test('continues migration when fetching old topics fails (e.g. 404)', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => oldToken);
      when(mockRepo.getNotificationSettings(oldToken)).thenThrow(Exception('404 Not Found'));
      when(mockRepo.createNotificationSubscription(any, any)).thenAnswer((_) async {});
      when(mockRepo.deleteNotificationSubscription(any)).thenAnswer((_) async {});

      await service.onTokenRefresh(newToken);

      // Should still create new subscription and delete old one
      verify(mockRepo.createNotificationSubscription(newToken, any)).called(1);
      verifyNever(mockRepo.updateNotificationSettings(any, any, any));
      verify(mockRepo.deleteNotificationSubscription(oldToken)).called(1);
      verify(mockStorage.storeFcmToken(newToken)).called(1);
    });

    test('continues migration when deleting old subscription fails', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => oldToken);
      when(mockRepo.getNotificationSettings(oldToken))
          .thenAnswer((_) async => NotificationsResponse(topics: topicsList));
      when(mockRepo.createNotificationSubscription(any, any)).thenAnswer((_) async {});
      when(mockRepo.updateNotificationSettings(any, any, any)).thenAnswer((_) async => {});
      when(mockRepo.deleteNotificationSubscription(any)).thenThrow(Exception('Server error'));

      await service.onTokenRefresh(newToken);

      // Should still store the new token
      verify(mockRepo.createNotificationSubscription(newToken, any)).called(1);
      verify(mockRepo.updateNotificationSettings(newToken, topicsList, true)).called(1);
      verify(mockStorage.storeFcmToken(newToken)).called(1);
    });

    test('stores new token even when createNotificationSubscription fails', () async {
      when(mockStorage.readFcmToken()).thenAnswer((_) async => oldToken);
      when(mockRepo.getNotificationSettings(oldToken))
          .thenAnswer((_) async => NotificationsResponse(topics: topicsList));
      when(mockRepo.createNotificationSubscription(any, any)).thenThrow(Exception('Network error'));

      await service.onTokenRefresh(newToken);

      // Should NOT have reached updateNotificationSettings or deleteNotificationSubscription
      verifyNever(mockRepo.updateNotificationSettings(any, any, any));
      verifyNever(mockRepo.deleteNotificationSubscription(any));

      // But should still store the new token via finally block
      verify(mockStorage.storeFcmToken(newToken)).called(1);
    });

    test('does not crash when readFcmToken throws', () async {
      when(mockStorage.readFcmToken()).thenThrow(Exception('Storage error'));

      // Should not throw
      await service.onTokenRefresh(newToken);

      // Still stores the new token via finally
      verify(mockStorage.storeFcmToken(newToken)).called(1);
    });
  });
}
