import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/user/events/bloc/event_details_state.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  EventDetailsCubit(this._apiService, this._authCubit)
      : super(EventDetailsState.initial());

  final ApiService _apiService;
  final AuthCubit _authCubit;

  Future<void> loadEventDetails(String eventId) async {
    if (state.status == EventDetailsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: EventDetailsStatus.loading));

    try {
      final event = await _apiService.getEventDetails(
        token: _authCubit.token,
        eventId: eventId,
      );
      final ev = Event.fromJson(event.data!);
      emit(
        state.copyWith(
          status: EventDetailsStatus.success,
          event: ev,
        ),
      );
      debugPrint(ev.toString());
    } catch (err) {
      emit(
        state.copyWith(
          status: EventDetailsStatus.failure,
          errorMessage: err.toString(),
        ),
      );
    }
  }
}
