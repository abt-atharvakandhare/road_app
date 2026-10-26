import 'package:json_annotation/json_annotation.dart';

part 'api_error_details.g.dart';

@JsonSerializable()
class ErrorDetails {
  final String? message;
  final String? code;

  /// Real remaining seconds of a 429 wait (rolling window), sent by the MFA
  /// rate limits alongside their code. No `Retry-After` HTTP header exists.
  final int? retryAfterSeconds;

  ErrorDetails({this.message, this.code, this.retryAfterSeconds});

  factory ErrorDetails.fromJson(Map<String, dynamic> json) => _$ErrorDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDetailsToJson(this);
}
