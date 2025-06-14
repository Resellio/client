import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/user/tickets/bloc/ticket_details_state.dart';
import 'package:resellio/features/user/tickets/model/ticket_details.dart';

class TicketDetailsCubit extends Cubit<TicketDetailsState> {
  TicketDetailsCubit({required this.apiService})
      : super(TicketDetailsInitialState());

  final ApiService apiService;

  Future<void> loadTicketDetails(String ticketId) async {
    emit(TicketDetailsLoadingState());

    try {
      final response = await apiService.getTicketDetails(ticketId: ticketId);

      if (response.success && response.data != null) {
        final ticketDetails = TicketDetails.fromJson(response.data!);
        emit(TicketDetailsLoadedState(ticketDetails: ticketDetails));
      } else {
        emit(
          TicketDetailsErrorState(
            message:
                response.message ?? 'Nie udało się pobrać szczegółów biletu',
          ),
        );
      }
    } on ApiException catch (e) {
      emit(TicketDetailsErrorState(message: e.message));
    } catch (e) {
      emit(
        TicketDetailsErrorState(
          message: 'Wystąpił nieoczekiwany błąd: $e',
        ),
      );
    }
  }

  Future<void> refreshTicketDetails(String ticketId) async {
    await loadTicketDetails(ticketId);
  }
}
