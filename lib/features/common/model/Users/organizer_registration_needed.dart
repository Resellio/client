import 'package:resellio/features/common/model/Users/user.dart';

class OrganizerRegistrationNeeded extends User {
  const OrganizerRegistrationNeeded({
    required super.email,
    required super.token,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
    };
  }

  @override
  factory OrganizerRegistrationNeeded.fromJson(Map<String, dynamic> json) {
    return OrganizerRegistrationNeeded(
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }
}
