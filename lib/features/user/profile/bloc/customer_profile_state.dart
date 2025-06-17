import 'package:resellio/features/user/profile/bloc/customer_about_me.dart';

enum CustomerProfileStatus { initial, loading, success, failure }

class CustomerProfileState {
  const CustomerProfileState({
    this.status = CustomerProfileStatus.initial,
    this.aboutMe,
    this.errorMessage,
  });
  
  final CustomerProfileStatus status;
  final CustomerAboutMe? aboutMe;
  final String? errorMessage;

  CustomerProfileState copyWith({
    CustomerProfileStatus? status,
    CustomerAboutMe? aboutMe,
    String? errorMessage,
  }) {
    return CustomerProfileState(
      status: status ?? this.status,
      aboutMe: aboutMe ?? this.aboutMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
