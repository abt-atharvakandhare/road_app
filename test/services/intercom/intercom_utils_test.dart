import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/intercom/intercom_utils.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateMocks([DebugControlsRepo])
import 'intercom_utils_test.mocks.dart';

void main() {
  late MockDebugControlsRepo mockDebugControlsRepo;

  setUpAll(() async {
    F.appFlavor = Flavor.eflux; // Initialize appFlavor for tests

    // Initialize dotenv for tests
    await dotenv.load(fileName: '.env');
  });

  setUp(() {
    // Create and configure mock
    mockDebugControlsRepo = MockDebugControlsRepo();
    when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(false);
    when(mockDebugControlsRepo.stageTarget).thenReturn(StageTarget.production);

    // Register dependencies for testing
    getIt.registerSingleton<DebugControlsRepo>(mockDebugControlsRepo);
    getIt.registerSingleton<Stage>(Stage()..setTarget(StageTarget.production));

    // Set platform for testing
    IntercomUtils.setPlatformForTesting(isIOS: true, isAndroid: false);
  });

  tearDown(() {
    // Clean up GetIt after tests
    getIt.reset();
    // Reset platform settings
    IntercomUtils.setPlatformForTesting();
  });

  test('createIntercomUserHash should return a valid user hash', () {
    // Arrange
    const userId = '123456789';

    // Act
    final userHash = IntercomUtils.createIntercomUserHash(userId);

    // Assert
    expect(userHash, isNotNull);
    expect(userHash, isNotEmpty);
    expect(userHash, isA<String>());
  });

  test('createIntercomUserHash should same as web', () {
    // Arrange
    const userId1 = 'ab1234';

    // Act
    final userHash1 = IntercomUtils.createIntercomUserHash(userId1);

    // Assert
    expect(userHash1, 'debd682ca3c94929e6a7c3f4fa81e992480365b8e3014194023bad56466575c7');
  });

  test('createIntercomUserHash should return different hashes for different user IDs', () {
    const userId1 = '123456789';
    const userId2 = '987654321';

    // Act
    final userHash1 = IntercomUtils.createIntercomUserHash(userId1);
    final userHash2 = IntercomUtils.createIntercomUserHash(userId2);

    // Assert
    expect(userHash1, isNot(userHash2));
  });
}
