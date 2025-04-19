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
}
