// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponseModel _$ProfileResponseModelFromJson(
  Map<String, dynamic> json,
) => ProfileResponseModel(
  ProfileModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileResponseModelToJson(
  ProfileResponseModel instance,
) => <String, dynamic>{'data': instance.data};

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) =>
    ProfileModel(
        json['id'] as String,
        json['name'] as String,
        json['email'] as String,
        json['mfaMethod'] as String?,
        (json['favouriteLocations'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        json['emailVerifiedAt'] == null
            ? null
            : DateTime.parse(json['emailVerifiedAt'] as String),
      )
      ..contact = json['contact'] == null
          ? null
          : Contact.fromJson(json['contact'] as Map<String, dynamic>);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'mfaMethod': instance.mfaMethod,
      'contact': instance.contact,
      'favouriteLocations': instance.favouriteLocations,
      'emailVerifiedAt': instance.emailVerifiedAt?.toIso8601String(),
    };

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
  json['firstName'] as String?,
  json['lastName'] as String?,
  json['phoneCountryCode'] as String?,
  json['phoneNo'] as String?,
  json['phoneNoVerifiedAt'] == null
      ? null
      : DateTime.parse(json['phoneNoVerifiedAt'] as String),
);

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneCountryCode': instance.phoneCountryCode,
  'phoneNo': instance.phoneNo,
  'phoneNoVerifiedAt': instance.phoneNoVerifiedAt?.toIso8601String(),
};
