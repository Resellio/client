import 'package:flutter/foundation.dart';
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
    bool? resell,
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
        usage = used ? 0 : 1; // 0 = used, 1 = not used
      }

      int? resellParam;
      if (resell != null) {
        resellParam = resell ? 0 : 1; // 0 = on resell, 1 = not on resell
      }
      debugPrint(
        'Tickets: Fetching page $page, current state: ${currentState.runtimeType}',
      );
      if (currentState is TicketsLoadedState) {
        debugPrint('Tickets: Current page number: ${currentState.pageNumber}');
      }

      final response = await apiService.getTickets(
        page: page,
        pageSize: _pageSize,
        eventName: eventName,
        usage: usage,
        resell: resellParam,
      );
      if (response.success && response.data != null) {
        final ticketsResponse = TicketsResponse.fromJson(response.data!);
        final bool hasReachedMax = !ticketsResponse.hasNextPage ||
            ticketsResponse.pageNumber >=
                ticketsResponse.paginationDetails.maxPageNumber;

        debugPrint(
          'Tickets response - pageNumber: ${ticketsResponse.pageNumber}, maxPageNumber: ${ticketsResponse.paginationDetails.maxPageNumber}, hasNextPage: ${ticketsResponse.hasNextPage}, hasReachedMax: $hasReachedMax',
        );

        if (refresh || currentState is! TicketsLoadedState) {
          emit(
            TicketsLoadedState(
              tickets: ticketsResponse.data,
              pageNumber: ticketsResponse.pageNumber,
              pageSize: ticketsResponse.pageSize,
              hasNextPage: !hasReachedMax,
              hasPreviousPage: ticketsResponse.hasPreviousPage,
              paginationDetails: ticketsResponse.paginationDetails,
              isLoadingMore: false,
            ),
          );
        } else {
          final existingTickets = currentState.tickets;
          emit(
            TicketsLoadedState(
              tickets: [...existingTickets, ...ticketsResponse.data],
              pageNumber: ticketsResponse.pageNumber,
              pageSize: ticketsResponse.pageSize,
              hasNextPage: !hasReachedMax,
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
    } catch (err) {
      emit(
        TicketsErrorState(
          message: 'Wystąpił nieoczekiwany błąd: $err',
        ),
      );
    }
  }

  Future<void> loadMoreTickets({
    String? eventName,
    bool? used,
    bool? resell,
  }) async {
    final currentState = state;
    if (currentState is TicketsLoadedState &&
        currentState.hasNextPage &&
        !currentState.isLoadingMore) {
      await loadTickets(
        eventName: eventName,
        used: used,
        resell: resell,
      );
    }
  }

  Future<void> refreshTickets({
    String? eventName,
    bool? used,
    bool? resell,
  }) async {
    await loadTickets(
      eventName: eventName,
      used: used,
      resell: resell,
      refresh: true,
    );
  }
}
