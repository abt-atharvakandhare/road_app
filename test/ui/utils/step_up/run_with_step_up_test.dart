import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/step_up/run_with_step_up.dart';

RMApiError stepUpError() =>
    RMApiError(cause: 'step up required', details: [ErrorDetails(code: 'MFA_STEP_UP_REQUIRED')]);

void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      captured = context;
      return const SizedBox();
    })));
    return captured;
  }

  testWidgets('a plain success never prompts', (tester) async {
    final context = await pumpContext(tester);
    var promptCount = 0;

    final result = await runWithStepUp(context, () async => 42, prompt: (_) async {
      promptCount++;
      return true;
    });

    expect(result, 42);
    expect(promptCount, 0);
  });

  testWidgets('a verified step-up re-runs the action exactly once', (tester) async {
    final context = await pumpContext(tester);
    var attempts = 0;
    var promptCount = 0;

    final result = await runWithStepUp(context, () async {
      attempts++;
      if (attempts == 1) throw stepUpError();
      return 'saved';
    }, prompt: (_) async {
      promptCount++;
      return true;
    });

    expect(result, 'saved');
    expect(attempts, 2);
    expect(promptCount, 1);
  });

  testWidgets('backing out of the sheet rethrows the original error', (tester) async {
    final context = await pumpContext(tester);
    final original = stepUpError();
    var attempts = 0;

    await expectLater(
      runWithStepUp(context, () async {
        attempts++;
        throw original;
      }, prompt: (_) async => null),
      throwsA(same(original)),
    );
    expect(attempts, 1);
  });

  testWidgets('a second step-up demand after a verified prompt propagates without a second prompt',
      (tester) async {
    final context = await pumpContext(tester);
    var attempts = 0;
    var promptCount = 0;

    await expectLater(
      runWithStepUp(context, () async {
        attempts++;
        throw stepUpError();
      }, prompt: (_) async {
        promptCount++;
        return true;
      }),
      throwsA(isA<RMApiError>()),
    );
    expect(attempts, 2);
    expect(promptCount, 1);
  });

  testWidgets('an unrelated error passes straight through', (tester) async {
    final context = await pumpContext(tester);
    var promptCount = 0;

    await expectLater(
      runWithStepUp(context, () async => throw RMApiError(cause: 'boom'), prompt: (_) async {
        promptCount++;
        return true;
      }),
      throwsA(isA<RMApiError>()),
    );
    expect(promptCount, 0);
  });

  testWidgets('runWithStepUpOrNull resolves a declined step-up to null', (tester) async {
    final context = await pumpContext(tester);

    final result = await runWithStepUpOrNull<int>(
        context, () async => throw stepUpError(),
        prompt: (_) async => null);

    expect(result, isNull);
  });

  testWidgets('runWithStepUpOrNull propagates errors that are not step-up demands', (tester) async {
    final context = await pumpContext(tester);
    var promptCount = 0;

    await expectLater(
      runWithStepUpOrNull(context, () async => throw RMApiError(cause: 'boom'), prompt: (_) async {
        promptCount++;
        return true;
      }),
      throwsA(isA<RMApiError>()),
    );
    expect(promptCount, 0);
  });

  testWidgets('runWithStepUpVerify maps a declined step-up to the error result', (tester) async {
    final context = await pumpContext(tester);

    final result = await runWithStepUpVerify(
        context, () async => throw stepUpError(),
        prompt: (_) async => null);

    expect(result, TwoFactorAuthResult.error);
  });
}
