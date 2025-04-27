import 'package:json_annotation/json_annotation.dart';
import 'package:resellio/features/common/model/Users/user.dart';

part 'organizer.g.dart';

@JsonSerializable()
class Organizer extends User {
  const Organizer({
    required super.email,
    required super.token,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) =>
      _$OrganizerFromJson(json);

  final String firstName;
  final String lastName;
  final String displayName;

  @override
  Map<String, dynamic> toJson() => _$OrganizerToJson(this);
}
