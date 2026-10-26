import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoices_model.g.dart';

@JsonSerializable()
class InvoicesResponseModel {
  InvoicesResponseModel({
    required this.data,
    required this.meta,
  });

  factory InvoicesResponseModel.fromJson(Map<String, dynamic> json) => _$InvoicesResponseModelFromJson(json);

  final List<InvoiceModel> data;
  final Meta meta;

  Map<String, dynamic> toJson() => _$InvoicesResponseModelToJson(this);
}

@JsonSerializable()
class Meta {
  int limit;
  int skip;
  int total;

  Meta({
    required this.limit,
    required this.skip,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}

@JsonSerializable()
class InvoiceModel {
  InvoiceModel({
    required this.id,
    this.currency,
    required this.year,
    required this.month,
    this.bookableAmount,
    this.totalAmountWithVat,
    this.accessToken,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);

  String id;
  String? currency;
  int year;
  int month;
  double? bookableAmount;
  double? totalAmountWithVat;
  String? accessToken;

  String get totalInvoiceAmountWithoutVatString {
    if (bookableAmount == null) {
      return '';
    }

    var totalPrice = bookableAmount!;

    final currencyFormat = NumberFormat.simpleCurrency(name: currency);
    return currencyFormat.format(totalPrice);
  }

  String get totalInvoiceAmountWithVatString {
    if (totalAmountWithVat == null) {
      return '';
    }

    var totalPrice = totalAmountWithVat!;

    final currencyFormat = NumberFormat.simpleCurrency(name: currency);
    return currencyFormat.format(totalPrice);
  }

  Uri? get downloadUriForInvoice {
    if (accessToken == null) {
      return null;
    }

    return Uri.parse('https://api.e-flux.nl/1/invoices/$id/pdf?accessToken=$accessToken');
  }
}
