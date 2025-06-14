import 'package:json_annotation/json_annotation.dart';
import 'package:resellio/features/common/model/Users/user.dart';

part 'admin.g.dart';

@JsonSerializable()
class Admin extends User {
  const Admin({
    required super.token,
    required super.email,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}
