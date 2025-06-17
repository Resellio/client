import 'package:resellio/features/organizer/profile/bloc/about_me.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.aboutMe,
    this.errorMessage,
  });
  final ProfileStatus status;
  final Aboutme? aboutMe;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    Aboutme? aboutMe,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      aboutMe: aboutMe ?? this.aboutMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
