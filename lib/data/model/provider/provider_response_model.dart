import 'package:json_annotation/json_annotation.dart';

part 'provider_response_model.g.dart';

@JsonSerializable()
class ProviderResponseDataModel {
  final ProviderResponseModel data;

  ProviderResponseDataModel({required this.data});

  factory ProviderResponseDataModel.fromJson(Map<String, dynamic> json) => _$ProviderResponseDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderResponseDataModelToJson(this);
}

@JsonSerializable()
class ProviderResponseModel {
  final String id;
  final String? customDomain;
  final String? supportUrl;
  final String? tosUrl;
  final String? privacyUrl;
  final String? csuiAboutUrl;
  final String? csuiSupportUrl;
  List<String>? enableVerifications;

  ProviderResponseModel({
    required this.id,
    this.customDomain,
    this.supportUrl,
    this.tosUrl,
    this.privacyUrl,
    this.csuiAboutUrl,
    this.csuiSupportUrl,
    this.enableVerifications,
  });

  factory ProviderResponseModel.fromJson(Map<String, dynamic> json) => _$ProviderResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderResponseModelToJson(this);
}
