import 'package:resellio/features/common/model/Users/user.dart';

sealed class AuthCubitEvent {}

class AuthErrorEvent implements AuthCubitEvent {
  const AuthErrorEvent(this.reason);

  final String reason;
}

class AuthenticatedEvent implements AuthCubitEvent {
  const AuthenticatedEvent(this.user);

  final User user;
}
