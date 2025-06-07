import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/organizer/events/bloc/event_details_state.dart';
import 'package:resellio/features/common/model/Event/event_details.dart';
import 'package:resellio/features/common/model/address.dart';
import 'package:resellio/features/user/events/views/event_details.dart';

class OrganizerEventDetailsCubit extends Cubit<OrganizerEventDetailsState> {
  OrganizerEventDetailsCubit({required this.apiService})
      : super(OrganizerEventDetailsInitialState());
  final ApiService apiService;

  Future<void> fetchEventDetails(String token, String eventId) async {
    try {
      emit(OrganizerEventDetailsLoadingState());
      final response =
          await apiService.getOrganizerEventDetails(token: token, id: eventId);
      if (!response.success) {
        throw Exception(response.message);
      }
      final details = OrganizerEventDetails.fromJson(response.data!);
      emit(OrganizerEventDetailsLoadedState(eventDetails: details));
    } catch (e) {
      emit(OrganizerEventDetailsErrorState(message: e.toString()));
    }
  }

  void setError(String error) {
    emit(OrganizerEventDetailsErrorState(message: error));
  }
}
