// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_locations_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapLocationsResponseModel _$MapLocationsResponseModelFromJson(
  Map<String, dynamic> json,
) => MapLocationsResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => MapLocationV2.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MapLocationsResponseModelToJson(
  MapLocationsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

MapLocationV2 _$MapLocationV2FromJson(Map<String, dynamic> json) =>
    MapLocationV2(
      id: json['id'] as String?,
      name: json['name'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      subOperator: json['subOperator'] == null
          ? null
          : Suboperator.fromJson(json['subOperator'] as Map<String, dynamic>),
      evses: (json['evses'] as List<dynamic>)
          .map((e) => Evse.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      infraProviderId: json['infraProviderId'] as String?,
      customNote: json['customNote'] as String?,
      geoLocation: json['geoLocation'] == null
          ? null
          : GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>),
      cdrAdditionalCharges: (json['cdrAdditionalCharges'] as List<dynamic>?)
          ?.map((e) => CdrAdditionalCharge.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => LocationImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MapLocationV2ToJson(MapLocationV2 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'address': instance.address,
      'subOperator': instance.subOperator,
      'evses': instance.evses,
      'facilities': instance.facilities,
      'infraProviderId': instance.infraProviderId,
      'customNote': instance.customNote,
      'geoLocation': instance.geoLocation,
      'cdrAdditionalCharges': instance.cdrAdditionalCharges,
      'images': instance.images,
    };

LocationImage _$LocationImageFromJson(Map<String, dynamic> json) =>
    LocationImage(
      url: json['url'] as String,
      category: json['category'] as String?,
      type: json['type'] as String?,
      thumbnail: json['thumbnail'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LocationImageToJson(LocationImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'category': instance.category,
      'type': instance.type,
      'thumbnail': instance.thumbnail,
      'width': instance.width,
      'height': instance.height,
    };

Suboperator _$SuboperatorFromJson(Map<String, dynamic> json) =>
    Suboperator(name: json['name'] as String?);

Map<String, dynamic> _$SuboperatorToJson(Suboperator instance) =>
    <String, dynamic>{'name': instance.name};

Evse _$EvseFromJson(Map<String, dynamic> json) => Evse(
  evseId: json['evseId'] as String?,
  uid: json['uid'] as String?,
  maxPower: (json['maxPower'] as num?)?.toDouble(),
  status: json['status'] as String?,
  capabilities: (json['capabilities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  authorizationTypes: (json['authorizationTypes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  connectors: (json['connectors'] as List<dynamic>)
      .map((e) => Connector.fromJson(e as Map<String, dynamic>))
      .toList(),
  userSpecialTariffs: (json['userSpecialTariffs'] as List<dynamic>?)
      ?.map((e) => UserSpecialTariff.fromJson(e as Map<String, dynamic>))
      .toList(),
  physicalReference: json['physicalReference'] as String?,
);

Map<String, dynamic> _$EvseToJson(Evse instance) => <String, dynamic>{
  'evseId': instance.evseId,
  'uid': instance.uid,
  'maxPower': instance.maxPower,
  'status': instance.status,
  'capabilities': instance.capabilities,
  'authorizationTypes': instance.authorizationTypes,
  'connectors': instance.connectors,
  'userSpecialTariffs': instance.userSpecialTariffs,
  'physicalReference': instance.physicalReference,
};

UserSpecialTariff _$UserSpecialTariffFromJson(Map<String, dynamic> json) =>
    UserSpecialTariff(
      eligibleIdentifiers: (json['eligibleIdentifiers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tariff: json['tariff'] == null
          ? null
          : Tariff.fromJson(json['tariff'] as Map<String, dynamic>),
      billingPlanDetails: json['billingPlanDetails'] == null
          ? null
          : BillingPlanDetails.fromJson(
              json['billingPlanDetails'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UserSpecialTariffToJson(UserSpecialTariff instance) =>
    <String, dynamic>{
      'eligibleIdentifiers': instance.eligibleIdentifiers,
      'tariff': instance.tariff,
      'billingPlanDetails': instance.billingPlanDetails,
    };

BillingPlanDetails _$BillingPlanDetailsFromJson(Map<String, dynamic> json) =>
    BillingPlanDetails(
      detailsTranslation: (json['detailsTranslation'] as List<dynamic>?)
          ?.map((e) => DetailsTranslation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BillingPlanDetailsToJson(BillingPlanDetails instance) =>
    <String, dynamic>{'detailsTranslation': instance.detailsTranslation};

DetailsTranslation _$DetailsTranslationFromJson(Map<String, dynamic> json) =>
    DetailsTranslation(
      language: json['language'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$DetailsTranslationToJson(DetailsTranslation instance) =>
    <String, dynamic>{'language': instance.language, 'name': instance.name};

Connector _$ConnectorFromJson(Map<String, dynamic> json) => Connector(
  id: json['id'] as String?,
  maxPower: (json['maxPower'] as num?)?.toDouble(),
  powerType: json['powerType'] as String?,
  standard: json['standard'] as String?,
  tariff: json['tariff'] == null
      ? null
      : Tariff.fromJson(json['tariff'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConnectorToJson(Connector instance) => <String, dynamic>{
  'id': instance.id,
  'maxPower': instance.maxPower,
  'powerType': instance.powerType,
  'standard': instance.standard,
  'tariff': instance.tariff,
};

Tariff _$TariffFromJson(Map<String, dynamic> json) => Tariff(
  currency: json['currency'] as String?,
  elements: (json['elements'] as List<dynamic>?)
      ?.map((e) => TariffElementModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TariffToJson(Tariff instance) => <String, dynamic>{
  'currency': instance.currency,
  'elements': instance.elements,
};

TariffElementModel _$TariffElementModelFromJson(Map<String, dynamic> json) =>
    TariffElementModel(
      priceComponentsCamelCase: (json['priceComponents'] as List<dynamic>?)
          ?.map((e) => PriceComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      priceComponentsSnakeCase: (json['price_components'] as List<dynamic>?)
          ?.map((e) => PriceComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      restrictions: json['restrictions'] == null
          ? null
          : Restrictions.fromJson(json['restrictions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TariffElementModelToJson(TariffElementModel instance) =>
    <String, dynamic>{
      'priceComponents': instance.priceComponentsCamelCase,
      'price_components': instance.priceComponentsSnakeCase,
      'restrictions': instance.restrictions,
    };

PriceComponent _$PriceComponentFromJson(Map<String, dynamic> json) =>
    PriceComponent(
      price: (json['price'] as num).toDouble(),
      stepSizeCamelCase: (json['stepSize'] as num?)?.toDouble(),
      stepSizeSnakeCase: (json['step_size'] as num?)?.toDouble(),
      type: json['type'] as String,
      vat: (json['vat'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PriceComponentToJson(PriceComponent instance) =>
    <String, dynamic>{
      'price': instance.price,
      'stepSize': instance.stepSizeCamelCase,
      'step_size': instance.stepSizeSnakeCase,
      'type': instance.type,
      'vat': instance.vat,
    };

Restrictions _$RestrictionsFromJson(Map<String, dynamic> json) => Restrictions(
  endDate: json['endDate'] as String?,
  endTime: json['endTime'] as String?,
  startDate: json['startDate'] as String?,
  startTime: json['startTime'] as String?,
  dayOfWeek: (json['dayOfWeek'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  minDuration: (json['minDuration'] as num?)?.toInt(),
  maxDuration: (json['maxDuration'] as num?)?.toInt(),
);

Map<String, dynamic> _$RestrictionsToJson(Restrictions instance) =>
    <String, dynamic>{
      'endDate': instance.endDate,
      'endTime': instance.endTime,
      'startDate': instance.startDate,
      'startTime': instance.startTime,
      'dayOfWeek': instance.dayOfWeek,
      'minDuration': instance.minDuration,
      'maxDuration': instance.maxDuration,
    };

CdrAdditionalCharge _$CdrAdditionalChargeFromJson(Map<String, dynamic> json) =>
    CdrAdditionalCharge(
      vat: (json['vat'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$CdrAdditionalChargeToJson(
  CdrAdditionalCharge instance,
) => <String, dynamic>{
  'vat': instance.vat,
  'price': instance.price,
  'currency': instance.currency,
};
