import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';

enum StageTarget {
  localdev,
  staging,
  production;

  String get name => toString().split('.').last;
}

@lazySingleton
class Stage {
  Stage() : target = StageTarget.production {
    final debugControlsRepo = getIt<DebugControlsRepo>();
    if (!debugControlsRepo.areDebugControlsEnabled) {
      return;
    }

    target = debugControlsRepo.stageTarget;
  }

  StageTarget target;

  void setTarget(StageTarget target) {
    this.target = target;
  }
}
