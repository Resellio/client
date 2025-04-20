import 'package:resellio/features/common/model/Users/user.dart';

class Organizer extends User {
  const Organizer({
    required super.email,
    required super.token,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  final String firstName;
  final String lastName;
  final String displayName;

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
    };
  }

  @override
  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      email: json['email'] as String,
      token: json['token'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      displayName: json['displayName'] as String,
    );
  }
}
