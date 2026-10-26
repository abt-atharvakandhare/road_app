import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';

class MockApiService extends Mock implements ApiService {}
class MockAnalytics extends Mock implements Analytics {}

void main() {
  late VerificationRepository repository;
  late MockApiService mockApiService;
  late MockAnalytics mockAnalytics;

  setUp(() {
    mockApiService = MockApiService();
    mockAnalytics = MockAnalytics();
    repository = VerificationRepository(mockApiService, mockAnalytics);
  });

  group('VerificationRepository', () {
    group('sendVerificationCode', () {
      test('should send verification code for email type successfully', () async {
        when(() => mockApiService.post(
              '/1/users/me/verification/email',
              data: {'platform': 'mobile'},
              retries: 0,
            )).thenAnswer((_) async => Response(
              data: {'data': {'success': true}},
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.sendVerificationCode(VerificationType.email);
        expect(result, true);

        verify(() => mockApiService.post(
              '/1/users/me/verification/email',
              data: {'platform': 'mobile'},
              retries: 0,
            )).called(1);
      });

      test('should send verification code for mobile type successfully', () async {
        when(() => mockApiService.post(
              '/1/users/me/verification/mobile',
              data: any(named: 'data'),  // Data varies based on platform (Android includes smsConstraint)
              retries: 0,
            )).thenAnswer((_) async => Response(
              data: {'data': {'success': true}},
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.sendVerificationCode(VerificationType.mobile);
        expect(result, true);

        verify(() => mockApiService.post(
              '/1/users/me/verification/mobile',
              data: any(named: 'data'),  // Data varies based on platform
              retries: 0,
            )).called(1);
      });

      test('should include smsConstraint when provided', () async {
        when(() => mockApiService.post(
              '/1/users/me/verification/mobile',
              data: {'smsConstraint': 'test_constraint'},
              retries: 0,
            )).thenAnswer((_) async => Response(
              data: {'data': {'success': true}},
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.sendVerificationCode(
          VerificationType.mobile,
          smsConstraint: 'test_constraint',
        );
        expect(result, true);

        verify(() => mockApiService.post(
              '/1/users/me/verification/mobile',
              data: {'smsConstraint': 'test_constraint'},
              retries: 0,
            )).called(1);
      });
    });

    group('confirmVerificationCode', () {
      test('should confirm email verification code successfully', () async {
        const testCode = '123456';
        
        when(() => mockApiService.post(
              '/1/users/me/verification/email/confirm',
              data: {'code': testCode},
            )).thenAnswer((_) async => Response(
              data: {'data': {'success': true}},
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.confirmVerificationCode(testCode, VerificationType.email);
        expect(result, true);

        verify(() => mockApiService.post(
              '/1/users/me/verification/email/confirm',
              data: {'code': testCode},
            )).called(1);
      });

      test('should confirm mobile verification code successfully', () async {
        const testCode = '654321';
        
        when(() => mockApiService.post(
              '/1/users/me/verification/mobile/confirm',
              data: {'code': testCode},
            )).thenAnswer((_) async => Response(
              data: {'data': {'success': true}},
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.confirmVerificationCode(testCode, VerificationType.mobile);
        expect(result, true);

        verify(() => mockApiService.post(
              '/1/users/me/verification/mobile/confirm',
              data: {'code': testCode},
            )).called(1);
      });
    });

    group('VerificationType enum', () {
      test('should have correct values', () {
        expect(VerificationType.email.value, 'email');
        expect(VerificationType.mobile.value, 'mobile');
      });
    });
  });
}