import 'package:resellio/features/common/model/role.dart';

class User {
  const User({
    required this.id,
    required this.email,
    required this.role,
  });

  final String id;
  final String email;

  final Role role;
}
