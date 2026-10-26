// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoices_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoicesResponseModel _$InvoicesResponseModelFromJson(
  Map<String, dynamic> json,
) => InvoicesResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$InvoicesResponseModelToJson(
  InvoicesResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  limit: (json['limit'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'limit': instance.limit,
  'skip': instance.skip,
  'total': instance.total,
};

InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) => InvoiceModel(
  id: json['id'] as String,
  currency: json['currency'] as String?,
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  bookableAmount: (json['bookableAmount'] as num?)?.toDouble(),
  totalAmountWithVat: (json['totalAmountWithVat'] as num?)?.toDouble(),
  accessToken: json['accessToken'] as String?,
);

Map<String, dynamic> _$InvoiceModelToJson(InvoiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'year': instance.year,
      'month': instance.month,
      'bookableAmount': instance.bookableAmount,
      'totalAmountWithVat': instance.totalAmountWithVat,
      'accessToken': instance.accessToken,
    };
