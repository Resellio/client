import 'package:resellio/features/organizer/profile/bloc/about_me.dart';

enum OrganizerProfileStatus { initial, loading, success, failure }

class OrganizerProfileState {
  const OrganizerProfileState({
    this.status = OrganizerProfileStatus.initial,
    this.aboutMe,
    this.errorMessage,
  });
  final OrganizerProfileStatus status;
  final OrganizerAboutme? aboutMe;
  final String? errorMessage;

  OrganizerProfileState copyWith({
    OrganizerProfileStatus? status,
    OrganizerAboutme? aboutMe,
    String? errorMessage,
  }) {
    return OrganizerProfileState(
      status: status ?? this.status,
      aboutMe: aboutMe ?? this.aboutMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
