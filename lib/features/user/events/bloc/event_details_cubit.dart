import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/user/events/bloc/event_details_state.dart';
import 'package:resellio/features/user/events/model/resell_tickets_response.dart';
import 'package:resellio/features/user/events/views/event_details.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  EventDetailsCubit(this._apiService) : super(EventDetailsState.initial());

  final ApiService _apiService;

  Future<void> loadEventDetails(String eventId) async {
    if (state.status == EventDetailsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: EventDetailsStatus.loading));

    try {
      final event = await _apiService.getEventDetails(
        eventId: eventId,
      );
      debugPrint(event.data.toString());
      final ev = Event.fromJson(event.data!);
      emit(
        state.copyWith(
          status: EventDetailsStatus.success,
          event: ev,
        ),
      );
      debugPrint(ev.toString());

      await loadResellTickets(eventId);
    } catch (err) {
      emit(
        state.copyWith(
          status: EventDetailsStatus.failure,
          errorMessage: err.toString(),
        ),
      );
    }
  }

  Future<void> loadResellTickets(String eventId) async {
    emit(state.copyWith(isLoadingResellTickets: true));

    try {
      final response = await _apiService.getTicketsForResell(
        eventId: eventId,
        page: 0,
        pageSize: 50,
      );

      if (response.success && response.data != null) {
        final resellTicketsResponse =
            ResellTicketsResponse.fromJson(response.data!);
        emit(
          state.copyWith(
            resellTickets: resellTicketsResponse.data,
            isLoadingResellTickets: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoadingResellTickets: false,
            resellTicketsError:
                response.message ?? 'Failed to load resell tickets',
          ),
        );
      }
    } catch (err) {
      emit(
        state.copyWith(
          isLoadingResellTickets: false,
          resellTicketsError: err.toString(),
        ),
      );
    }
  }

  void updateTicketAvailabilityLocally(String ticketId, int decreaseBy) {
    if (state.status != EventDetailsStatus.success || state.event == null) {
      return;
    }

    final currentEvent = state.event!;
    final updatedTickets = currentEvent.tickets.map((ticket) {
      if (ticket.id == ticketId) {
        final newAmount = (ticket.amountAvailable - decreaseBy)
            .clamp(0, double.infinity)
            .toInt();
        return TicketType(
          id: ticket.id,
          description: ticket.description,
          price: ticket.price,
          currency: ticket.currency,
          amountAvailable: newAmount,
        );
      }
      return ticket;
    }).toList();

    final updatedEvent = Event(
      id: currentEvent.id,
      name: currentEvent.name,
      description: currentEvent.description,
      startDate: currentEvent.startDate,
      endDate: currentEvent.endDate,
      minimumAge: currentEvent.minimumAge,
      minimumPrice: currentEvent.minimumPrice,
      minimumPriceCurrency: currentEvent.minimumPriceCurrency,
      maximumPrice: currentEvent.maximumPrice,
      maximumPriceCurrency: currentEvent.maximumPriceCurrency,
      categories: currentEvent.categories,
      status: currentEvent.status,
      address: currentEvent.address,
      tickets: updatedTickets,
    );

    emit(
      state.copyWith(
        status: EventDetailsStatus.success,
        event: updatedEvent,
      ),
    );
  }
}
