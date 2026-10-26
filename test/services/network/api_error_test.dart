import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/services/network/api_error.dart';
import 'package:road_mobile/services/network/api_error_details.dart';

void main() {
  group('ApiError.isJwtRejected', () {
    test('401 with TOKEN_EXPIRED is rejected + expired', () {
      final err = ApiError(
        message: 'jwt token has expired',
        status: 401,
        details: [ErrorDetails(code: 'TOKEN_EXPIRED', message: 'jwt token has expired')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isTrue);
    });

    test('401 with SESSION_EXPIRED is rejected + expired', () {
      final err = ApiError(
        message: 'session expired',
        status: 401,
        details: [ErrorDetails(code: 'SESSION_EXPIRED', message: 'session expired')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isTrue);
    });

    test('401 with INVALID_SIGNATURE is rejected but not expired', () {
      final err = ApiError(
        message: 'invalid signature',
        status: 401,
        details: [ErrorDetails(code: 'INVALID_SIGNATURE', message: 'invalid signature')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with NO_TOKEN is rejected but not expired', () {
      final err = ApiError(
        message: 'no token',
        status: 401,
        details: [ErrorDetails(code: 'NO_TOKEN', message: 'no token')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with SESSION_REVOKED is rejected but not expired', () {
      final err = ApiError(
        message: 'session revoked',
        status: 401,
        details: [ErrorDetails(code: 'SESSION_REVOKED', message: 'session revoked')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with SUBJECT_NOT_FOUND is rejected but not expired', () {
      final err = ApiError(
        message: 'user deleted',
        status: 401,
        details: [ErrorDetails(code: 'SUBJECT_NOT_FOUND', message: 'user deleted')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with legacy TOKEN_INVALIDATED is rejected but not expired', () {
      final err = ApiError(
        message: 'token invalidated',
        status: 401,
        details: [ErrorDetails(code: 'TOKEN_INVALIDATED', message: 'token invalidated')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with legacy FORCE_LOGOUT is rejected but not expired', () {
      final err = ApiError(
        message: 'force logout',
        status: 401,
        details: [ErrorDetails(code: 'FORCE_LOGOUT', message: 'force logout')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with TOKEN_NOT_ALLOWED is rejected but not expired', () {
      final err = ApiError(
        message: 'token not allowed',
        status: 401,
        details: [ErrorDetails(code: 'TOKEN_NOT_ALLOWED', message: 'token not allowed')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with INVALID_KEY is rejected but not expired', () {
      final err = ApiError(
        message: 'invalid key',
        status: 401,
        details: [ErrorDetails(code: 'INVALID_KEY', message: 'invalid key')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with CREDENTIAL_DISABLED is rejected but not expired', () {
      final err = ApiError(
        message: 'credential disabled',
        status: 401,
        details: [ErrorDetails(code: 'CREDENTIAL_DISABLED', message: 'credential disabled')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with no details is NOT a JWT rejection (e.g. bad login credentials)', () {
      final err = ApiError(message: 'unauthorized', status: 401);
      expect(err.isJwtRejected, isFalse);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with login error code (INVALID_CREDENTIALS) is NOT a JWT rejection', () {
      final err = ApiError(
        message: 'Incorrect email or password',
        status: 401,
        details: [ErrorDetails(code: 'INVALID_CREDENTIALS', message: 'Incorrect email or password')],
      );
      expect(err.isJwtRejected, isFalse);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with login error code (CREDENTIAL_LEAKED) is NOT a JWT rejection', () {
      final err = ApiError(
        message: 'password leaked',
        status: 401,
        details: [ErrorDetails(code: 'CREDENTIAL_LEAKED', message: 'password leaked')],
      );
      expect(err.isJwtRejected, isFalse);
      expect(err.isJwtExpired, isFalse);
    });

    test('403 (permission denied) is not unauthorized', () {
      final err = ApiError(message: 'forbidden', status: 403);
      expect(err.isJwtRejected, isFalse);
      expect(err.isJwtExpired, isFalse);
    });

    test('legacy 400 + "bad jwt token" is no longer treated as unauthorized', () {
      // The new API returns 401 for this case; the legacy 400 path is dead.
      final err = ApiError(message: 'bad jwt token', status: 400);
      expect(err.isJwtRejected, isFalse);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with DEVICE_NOT_FOUND is rejected + device-revoked', () {
      final err = ApiError(
        message: 'device revoked',
        status: 401,
        details: [ErrorDetails(code: 'DEVICE_NOT_FOUND', message: 'device revoked')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isDeviceRevoked, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('401 with SESSION_RENEWAL_TOKEN_REVOKED is rejected but not device-revoked', () {
      final err = ApiError(
        message: 'renewal token revoked',
        status: 401,
        details: [ErrorDetails(code: 'SESSION_RENEWAL_TOKEN_REVOKED', message: 'renewal token revoked')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isDeviceRevoked, isFalse);
    });

    test('401 with ACTION_TOKEN_EXPIRED is rejected + expired', () {
      final err = ApiError(
        message: 'action token expired',
        status: 401,
        details: [ErrorDetails(code: 'ACTION_TOKEN_EXPIRED', message: 'action token expired')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isTrue);
    });

    test('401 with ACTION_TOKEN_REVOKED is rejected but not expired', () {
      final err = ApiError(
        message: 'action token revoked',
        status: 401,
        details: [ErrorDetails(code: 'ACTION_TOKEN_REVOKED', message: 'action token revoked')],
      );
      expect(err.isJwtRejected, isTrue);
      expect(err.isJwtExpired, isFalse);
    });

    test('isDeviceRevoked is false on non-401 status', () {
      final err = ApiError(
        message: 'device not found',
        status: 404,
        details: [ErrorDetails(code: 'DEVICE_NOT_FOUND', message: 'device not found')],
      );
      expect(err.isDeviceRevoked, isFalse);
    });
  });
}
