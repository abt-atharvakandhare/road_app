import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/meta/meta_model.dart';

part 'cards_response_model.g.dart';

@JsonSerializable()
class RfidCardsResponseModel {
  RfidCardsResponseModel({
    this.data,
    this.meta,
  });

  factory RfidCardsResponseModel.fromJson(Map<String, dynamic> json) => _$RfidCardsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RfidCardsResponseModelToJson(this);

  List<RfidCardModel>? data;
  MetaModel? meta;

  List<RfidCardModel>? cardsWithActiveToken(String userId) {
    final activeCards = data?.where((card) => card.token?.id != null && card.userId == userId).toList();
    return activeCards;
  }
}

@JsonSerializable()
class RfidCardModel {
  RfidCardModel(
      {required this.id,
      this.nameOnCard,
      required this.userId,
      this.token});

  factory RfidCardModel.fromJson(Map<String, dynamic> json) => _$RfidCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$RfidCardModelToJson(this);

  String id;
  String? nameOnCard;
  String userId;
  TokenModel? token;
  BillingPlan? billingPlan;
}

@JsonSerializable()
class TokenModel {
  TokenModel({
    this.id,
    this.isActive,
    this.visualNumber,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenModelToJson(this);

  String? id;
  bool? isActive;
  String? visualNumber;
}

@JsonSerializable()
class BillingPlan {
  String name;

  BillingPlan({required this.name});

  factory BillingPlan.fromJson(Map<String, dynamic> json) => _$BillingPlanFromJson(json);

  Map<String, dynamic> toJson() => _$BillingPlanToJson(this);
}
