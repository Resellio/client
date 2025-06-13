import 'package:equatable/equatable.dart';

import 'package:resellio/features/user/tickets/model/ticket_details.dart';

abstract class TicketDetailsState extends Equatable {
  const TicketDetailsState();

  @override
  List<Object?> get props => [];
}

class TicketDetailsInitialState extends TicketDetailsState {}

class TicketDetailsLoadingState extends TicketDetailsState {}

class TicketDetailsLoadedState extends TicketDetailsState {
  const TicketDetailsLoadedState({required this.ticketDetails});

  final TicketDetails ticketDetails;

  @override
  List<Object?> get props => [ticketDetails];
}

class TicketDetailsErrorState extends TicketDetailsState {
  const TicketDetailsErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
