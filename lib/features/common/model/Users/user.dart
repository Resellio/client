import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.email,
    required this.token,
  });

  final String email;
  final String token;

  @override
  List<Object> get props => [email, token];
}
