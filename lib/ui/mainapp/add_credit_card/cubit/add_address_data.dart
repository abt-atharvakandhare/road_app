import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_address_data.freezed.dart';

@freezed
sealed class AddAddressData with _$AddAddressData {
  factory AddAddressData({
    required String street,
    required String houseNumber,
    required String postCode,
    required String city,
  }) = AddAddressDataData;
}
