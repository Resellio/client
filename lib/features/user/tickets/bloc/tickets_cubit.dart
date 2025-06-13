import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/user/tickets/bloc/tickets_state.dart';
import 'package:resellio/features/user/tickets/model/tickets_response.dart';

class TicketsCubit extends Cubit<TicketsState> {
  TicketsCubit({required this.apiService}) : super(TicketsInitialState());

  final ApiService apiService;

  static const int _pageSize = 20;

  Future<void> loadTickets({
    String? eventName,
    bool? used,
    bool refresh = false,
  }) async {
    if (refresh || state is TicketsInitialState) {
      emit(TicketsLoadingState());
    } else if (state is TicketsLoadedState) {
      emit((state as TicketsLoadedState).copyWith(isLoadingMore: true));
    }

    try {
      final currentState = state;
      final page = refresh || currentState is! TicketsLoadedState
          ? 0
          : currentState.pageNumber + 1;      int? usage;
      if (used != null) {
        usage = used ? 0 : 1;  // Odwrócona logika jeśli API ma odwrotne wartości
      }

      final response = await apiService.getTickets(
        page: page,
        pageSize: _pageSize,
        eventName: eventName,
        usage: usage,
      );

      if (response.success && response.data != null) {
        final ticketsResponse = TicketsResponse.fromJson(response.data!);

        if (refresh || currentState is! TicketsLoadedState) {
          emit(
            TicketsLoadedState(
              tickets: ticketsResponse.data,
              pageNumber: ticketsResponse.pageNumber,
              pageSize: ticketsResponse.pageSize,
              hasNextPage: ticketsResponse.hasNextPage,
              hasPreviousPage: ticketsResponse.hasPreviousPage,
              paginationDetails: ticketsResponse.paginationDetails,
              isLoadingMore: false,
            ),
          );
        } else {
          // Load more - append to existing tickets
          final existingTickets = currentState.tickets;
          emit(
            TicketsLoadedState(
              tickets: [...existingTickets, ...ticketsResponse.data],
              pageNumber: ticketsResponse.pageNumber,
              pageSize: ticketsResponse.pageSize,
              hasNextPage: ticketsResponse.hasNextPage,
              hasPreviousPage: ticketsResponse.hasPreviousPage,
              paginationDetails: ticketsResponse.paginationDetails,
              isLoadingMore: false,
            ),
          );
        }
      } else {
        emit(
          TicketsErrorState(
            message: response.message ?? 'Nie udało się pobrać biletów',
          ),
        );
      }
    } on ApiException catch (e) {
      emit(TicketsErrorState(message: e.message));
    } catch (e) {
      emit(
        TicketsErrorState(
          message: 'Wystąpił nieoczekiwany błąd: $e',
        ),
      );
    }
  }

  Future<void> loadMoreTickets({
    String? eventName,
    bool? used,
  }) async {
    final currentState = state;
    if (currentState is TicketsLoadedState &&
        currentState.hasNextPage &&
        !currentState.isLoadingMore) {
      await loadTickets(
        eventName: eventName,
        used: used,
      );
    }
  }

  Future<void> refreshTickets({
    String? eventName,
    bool? used,
  }) async {
    await loadTickets(
      eventName: eventName,
      used: used,
      refresh: true,
    );
  }
}
