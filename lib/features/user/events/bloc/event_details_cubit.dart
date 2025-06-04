import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/user/events/bloc/event_details_state.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  final ApiService _apiService;
  final AuthCubit _authCubit;

  EventDetailsCubit(this._apiService, this._authCubit)
      : super(EventDetailsState.initial());

  Future<void> loadEventDetails(String eventId) async {
    if (state.status == EventDetailsStatus.loading) return;

    emit(state.copyWith(status: EventDetailsStatus.loading));

    try {
      final event = await _apiService.getEventDetails(
          token: _authCubit.token, eventId: eventId);
      final ev = Event.fromJson(event.data as Map<String, dynamic>);
      emit(state.copyWith(
        status: EventDetailsStatus.success,
        event: ev,
      ));
      print(ev);
    } catch (err) {
      emit(state.copyWith(
        status: EventDetailsStatus.failure,
        errorMessage: err.toString(),
      ));
    }
  }
}
