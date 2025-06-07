import 'package:resellio/features/common/model/Event/organizer_event.dart';

abstract class OrganizerEventState {}

class OrganizerEventInitialState extends OrganizerEventState {}

class OrganizerEventLoadingState extends OrganizerEventState {}

class OrganizerEventLoadedState extends OrganizerEventState {
  OrganizerEventLoadedState({required this.events, required this.hasNextPage});

  final List<OrganizerEvent> events;
  final bool hasNextPage;
}

class OrganizerEventErrorState extends OrganizerEventState {
  OrganizerEventErrorState({required this.message});

  final String message;
}
