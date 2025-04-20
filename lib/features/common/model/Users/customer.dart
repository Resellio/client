import 'package:resellio/features/common/model/Users/user.dart';

class Customer extends User {
  const Customer({
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
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }
}
