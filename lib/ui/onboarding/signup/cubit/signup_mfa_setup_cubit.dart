import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/utils/mfa_enrolment/mfa_enrolment_cubit.dart';

export 'package:road_mobile/ui/utils/mfa_enrolment/mfa_enrolment_cubit.dart';

/// The signup "Secure Sign-in" step's states are the shared enrolment ones;
/// the step only ever drives the method-list/email-proof/TOTP/SMS subset —
/// passkey set-up runs entirely within the method-list state (the ceremony
/// is an OS sheet, not a sub-flow).
typedef SignupMfaSetupState = MfaEnrolmentState;

/// Drives the signup "Secure Sign-in" step over the shared
/// [MfaEnrolmentCubit] state machine.
@injectable
class SignupMfaSetupCubit extends MfaEnrolmentCubit {
  SignupMfaSetupCubit(super.repository, PasskeyService passkeyService)
      : super(passkeyService: passkeyService);

  /// Step-up demands are real mid-signup: phone verification enrols an
  /// active SMS factor, which makes factor mutations freshness-gated — and
  /// installing an authenticator app is exactly the dwell that outlives the
  /// window. The widget runs mutations through `runWithStepUp`.
  @override
  bool get rethrowsStepUpDemands => true;
}
