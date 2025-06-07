import 'package:resellio/features/common/model/Event/event_details.dart';

abstract class OrganizerEventDetailsState {}

class OrganizerEventDetailsInitialState extends OrganizerEventDetailsState {}

class OrganizerEventDetailsLoadingState extends OrganizerEventDetailsState {}

class OrganizerEventDetailsLoadedState extends OrganizerEventDetailsState {
  OrganizerEventDetailsLoadedState({required this.eventDetails});

  final OrganizerEventDetails eventDetails;
}

class OrganizerEventDetailsErrorState extends OrganizerEventDetailsState {
  OrganizerEventDetailsErrorState({required this.message});

  final String message;
}
