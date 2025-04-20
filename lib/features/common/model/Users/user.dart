import 'package:equatable/equatable.dart';

abstract class User extends Equatable {
  const User({
    required this.email,
    required this.token,
  });

  final String email;
  final String token;

  Map<String, dynamic> toJson();

  @override
  List<Object> get props => [email, token];
}
