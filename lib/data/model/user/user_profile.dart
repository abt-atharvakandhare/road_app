import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class ProfileResponseModel {
  ProfileModel data;

  ProfileResponseModel(this.data);

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) => _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);
}

@JsonSerializable()
class ProfileModel {
  String id;
  String name;
  String email;
  String? mfaMethod;
  Contact? contact;
  List<String>? favouriteLocations;
  DateTime? emailVerifiedAt;

  ProfileModel(
    this.id,
    this.name,
    this.email,
    this.mfaMethod,
    this.favouriteLocations,
    this.emailVerifiedAt,
  );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable()
class Contact {
  String? firstName;
  String? lastName;
  String? phoneCountryCode;
  String? phoneNo;
  DateTime? phoneNoVerifiedAt;

  Contact(this.firstName, this.lastName, this.phoneCountryCode, this.phoneNo, this.phoneNoVerifiedAt);

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);
}
