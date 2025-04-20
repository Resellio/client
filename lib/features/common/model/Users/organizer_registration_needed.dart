import 'package:json_annotation/json_annotation.dart';
import 'package:resellio/features/common/model/Users/user.dart';

part 'organizer_registration_needed.g.dart';

@JsonSerializable()
class OrganizerRegistrationNeeded extends User {
  const OrganizerRegistrationNeeded({
    required super.email,
    required super.token,
  });

  factory OrganizerRegistrationNeeded.fromJson(Map<String, dynamic> json) =>
      _$OrganizerRegistrationNeededFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrganizerRegistrationNeededToJson(this);
}
