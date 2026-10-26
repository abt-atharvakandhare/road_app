import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:country_picker/country_picker.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/first_signup_screen.dart';
import 'package:road_mobile/flavors.dart';

class MockSignupCubit extends Mock implements SignupCubit {
  @override
  Stream<SignupState> get stream => Stream.value(state);
}

class MockLocationBloc extends Mock implements LocationBloc {
  @override
  Stream<LocationState> get stream => Stream.value(state);
}

class MockAuthCubit extends Mock implements AuthCubit {
  @override
  Stream<AuthState> get stream => Stream.value(state);
}

void main() {
  late MockSignupCubit mockSignupCubit;
  late MockLocationBloc mockLocationBloc;
  late MockAuthCubit mockAuthCubit;

  setUpAll(() {
    F.appFlavor = Flavor.eflux; // Initialize appFlavor for tests

    registerFallbackValue(
      UserLocation(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
      ),
    );
  });

  setUp(() {
    mockSignupCubit = MockSignupCubit();
    mockLocationBloc = MockLocationBloc();
    mockAuthCubit = MockAuthCubit();

    when(() => mockSignupCubit.state).thenReturn(
      const SignupState.createAccount(
        flow: UIFlow.established(),
        supportedCountries: [],
      ),
    );

    when(() => mockSignupCubit.provideUserLocation(any())).thenAnswer(
      (_) => Future.value(Country.tryParse('NL')),
    );

    when(() => mockLocationBloc.state).thenReturn(
      LocationState.locationProvided(
        userLocation: UserLocation(
          latitude: 0,
          longitude: 0,
          accuracy: 0,
        ),
      ),
    );

    when(() => mockAuthCubit.state).thenReturn(
      const AuthState.showSplash(),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<SignupCubit>.value(value: mockSignupCubit),
            BlocProvider<LocationBloc>.value(value: mockLocationBloc),
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const FirstSignupScreen(),
        ),
      ),
    );
  }

  testWidgets('FirstSignupScreen builds without errors', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.byType(FirstSignupScreen), findsOneWidget);
  });

  testWidgets('FirstSignupScreen shows form fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(5));
  });
}
