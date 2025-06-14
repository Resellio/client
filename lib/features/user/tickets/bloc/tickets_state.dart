import 'package:equatable/equatable.dart';

import 'package:resellio/features/user/tickets/model/pagination_details.dart';
import 'package:resellio/features/user/tickets/model/ticket.dart';

abstract class TicketsState extends Equatable {
  const TicketsState();

  @override
  List<Object?> get props => [];
}

class TicketsInitialState extends TicketsState {}

class TicketsLoadingState extends TicketsState {}

class TicketsLoadedState extends TicketsState {
  const TicketsLoadedState({
    required this.tickets,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.paginationDetails,
    required this.isLoadingMore,
  });

  final List<Ticket> tickets;
  final int pageNumber;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final PaginationDetails paginationDetails;
  final bool isLoadingMore;

  @override
  List<Object?> get props => [
        tickets,
        pageNumber,
        pageSize,
        hasNextPage,
        hasPreviousPage,
        paginationDetails,
        isLoadingMore,
      ];

  TicketsLoadedState copyWith({
    List<Ticket>? tickets,
    int? pageNumber,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
    PaginationDetails? paginationDetails,
    bool? isLoadingMore,
  }) {
    return TicketsLoadedState(
      tickets: tickets ?? this.tickets,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      paginationDetails: paginationDetails ?? this.paginationDetails,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class TicketsErrorState extends TicketsState {
  const TicketsErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
