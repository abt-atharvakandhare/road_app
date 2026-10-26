// {data: {success: true}}
// Model for above JSON

import 'package:json_annotation/json_annotation.dart';

part 'verify_and_store_response_model.g.dart';

@JsonSerializable()
class SimpleSuccessResponseModel {
  SimpleSuccessResponseModel({
    required this.data,
  });

  factory SimpleSuccessResponseModel.fromJson(Map<String, dynamic> json) => _$SimpleSuccessResponseModelFromJson(json);

  final SimpleSuccessResponseDataModel data;

  Map<String, dynamic> toJson() => _$SimpleSuccessResponseModelToJson(this);
}

@JsonSerializable()
class SimpleSuccessResponseDataModel {
  SimpleSuccessResponseDataModel({
    required this.success,
  });

  factory SimpleSuccessResponseDataModel.fromJson(Map<String, dynamic> json) =>
      _$SimpleSuccessResponseDataModelFromJson(json);

  final bool success;

  Map<String, dynamic> toJson() => _$SimpleSuccessResponseDataModelToJson(this);
}
