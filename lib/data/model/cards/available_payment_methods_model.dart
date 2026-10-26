import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'available_payment_methods_model.g.dart';

@JsonSerializable()
class AvailablePaymentMethodsResponseModel {
  AvailablePaymentMethodsResponseModel({
    required this.data,
  });

  factory AvailablePaymentMethodsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AvailablePaymentMethodsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailablePaymentMethodsResponseModelToJson(this);

  List<AvailablePaymentMethodModel> data;

  /// Returns the first card-type payment method, or null if none available.
  AvailablePaymentMethodModel? get firstCardMethod =>
      data.firstWhereOrNull((m) => m.paymentType == 'card');

  /// Returns the payment method matching the given card scheme (e.g. 'visa', 'mastercard').
  AvailablePaymentMethodModel? methodForScheme(String scheme) =>
      data.firstWhereOrNull((m) => m.paymentType == 'card' && m.paymentMethod.toLowerCase() == scheme.toLowerCase());
}

@JsonSerializable()
class AvailablePaymentMethodModel {
  AvailablePaymentMethodModel({
    required this.id,
    required this.paymentType,
    required this.paymentMethod,
  });

  factory AvailablePaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$AvailablePaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailablePaymentMethodModelToJson(this);

  String id;
  String paymentType;
  String paymentMethod;
}
