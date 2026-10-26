import 'package:json_annotation/json_annotation.dart';

part 'meta_model.g.dart';

@JsonSerializable()
class MetaModel {
  MetaModel({
    this.limit,
    this.skip,
    this.total,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) => _$MetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetaModelToJson(this);

  int? limit;
  int? skip;
  int? total;
}
