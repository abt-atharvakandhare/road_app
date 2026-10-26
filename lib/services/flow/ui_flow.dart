import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'ui_flow.freezed.dart';

@freezed
sealed class UIFlow with _$UIFlow {
  const factory UIFlow.established() = UIFlowEstablished;
  const factory UIFlow.loading() = UIFlowLoading;
  const factory UIFlow.error(RMApiError error) = UIFlowError;

  const UIFlow._();
}

extension UIFlowState on UIFlow {
  bool get isLoading => this is UIFlowLoading;
  bool get isEstablished => this is UIFlowEstablished;
  bool get isError => this is UIFlowError;
  RMApiError get error => (this as UIFlowError).error;
}
