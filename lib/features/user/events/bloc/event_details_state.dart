import 'package:resellio/features/common/model/event.dart';

enum EventDetailsStatus { initial, loading, success, failure }

class EventDetailsState {
  const EventDetailsState({
    required this.status,
    this.event,
    this.errorMessage,
  });

  factory EventDetailsState.initial() {
    return const EventDetailsState(status: EventDetailsStatus.initial);
  }

  final EventDetailsStatus status;
  final Event? event;
  final String? errorMessage;

  EventDetailsState copyWith({
    EventDetailsStatus? status,
    Event? event,
    String? errorMessage,
  }) {
    return EventDetailsState(
      status: status ?? this.status,
      event: event ?? this.event,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
