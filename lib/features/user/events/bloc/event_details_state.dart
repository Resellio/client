import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/user/events/model/resell_ticket.dart';

enum EventDetailsStatus { initial, loading, success, failure }

class EventDetailsState {
  const EventDetailsState({
    required this.status,
    this.event,
    this.errorMessage,
    this.resellTickets = const [],
    this.isLoadingResellTickets = false,
    this.resellTicketsError,
  });

  factory EventDetailsState.initial() {
    return const EventDetailsState(status: EventDetailsStatus.initial);
  }

  final EventDetailsStatus status;
  final Event? event;
  final String? errorMessage;
  final List<ResellTicket> resellTickets;
  final bool isLoadingResellTickets;
  final String? resellTicketsError;

  EventDetailsState copyWith({
    EventDetailsStatus? status,
    Event? event,
    String? errorMessage,
    List<ResellTicket>? resellTickets,
    bool? isLoadingResellTickets,
    String? resellTicketsError,
  }) {
    return EventDetailsState(
      status: status ?? this.status,
      event: event ?? this.event,
      errorMessage: errorMessage ?? this.errorMessage,
      resellTickets: resellTickets ?? this.resellTickets,
      isLoadingResellTickets:
          isLoadingResellTickets ?? this.isLoadingResellTickets,
      resellTicketsError: resellTicketsError ?? this.resellTicketsError,
    );
  }
}
