import 'package:json_annotation/json_annotation.dart';

part 'store_tokenization_model.g.dart';

@JsonSerializable()
class StoreTokenizationResponseModel {
  StoreTokenizationResponseModel({required this.data});

  factory StoreTokenizationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$StoreTokenizationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreTokenizationResponseModelToJson(this);

  StoreTokenizationDataModel data;
}

@JsonSerializable()
class StoreTokenizationDataModel {
  StoreTokenizationDataModel({
    required this.id,
    required this.paymentType,
    required this.paymentMethod,
    required this.displayIdentifier,
    this.expiresAt,
  });

  factory StoreTokenizationDataModel.fromJson(Map<String, dynamic> json) =>
      _$StoreTokenizationDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreTokenizationDataModelToJson(this);

  String id;
  String paymentType;
  String paymentMethod;
  String displayIdentifier;
  String? expiresAt;
}
