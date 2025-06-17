import 'package:resellio/features/user/profile/bloc/about_me.dart';

enum CustomerProfileStatus { initial, loading, success, failure }

class CustomerProfileState {
  const CustomerProfileState({
    this.status = CustomerProfileStatus.initial,
    this.aboutMe,
    this.errorMessage,
  });
  final CustomerProfileStatus status;
  final CustomerAboutme? aboutMe;
  final String? errorMessage;

  CustomerProfileState copyWith({
    CustomerProfileStatus? status,
    CustomerAboutme? aboutMe,
    String? errorMessage,
  }) {
    return CustomerProfileState(
      status: status ?? this.status,
      aboutMe: aboutMe ?? this.aboutMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
