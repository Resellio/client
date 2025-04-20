import 'package:json_annotation/json_annotation.dart';
import 'package:resellio/features/common/model/Users/user.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer extends User {
  const Customer({
    required super.email,
    required super.token,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
