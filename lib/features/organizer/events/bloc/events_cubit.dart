import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/organizer/events/bloc/events_state.dart';
import 'package:resellio/features/common/model/Event/organizer_event.dart';
import 'package:resellio/features/common/model/address.dart';
import 'package:resellio/features/common/model/paginated.dart';

class OrganizerEventsCubit extends Cubit<OrganizerEventState> {
  OrganizerEventsCubit({required this.apiService})
      : super(OrganizerEventInitialState());

  List<OrganizerEvent> list = <OrganizerEvent>[];
  static const int pageSize = 5;
  final ApiService apiService;

  Future<void> fetchEvents(String token, int page) async {
    try {
      if (page == 0) {
        emit(OrganizerEventLoadingState());
      }

      final response = await apiService.getOrganizerEvents(
        token: token,
        page: page,
        pageSize: pageSize,
      );

      final paginatedData = PaginatedData<OrganizerEvent>.fromJson(
        response,
        (json) => OrganizerEvent.fromJson(json as Map<String, dynamic>),
      );
      list.addAll(paginatedData.data);
      emit(OrganizerEventLoadedState(
        events: List.from(list),
        hasNextPage: paginatedData.hasNextPage,
      ));
    } catch (e) {
      emit(OrganizerEventErrorState(message: e.toString()));
    }
  }

  Future<void> refreshEvents(String token) async {
    list.clear();
    await fetchEvents(token, 0);
  }

  void setError(String error) {
    emit(OrganizerEventErrorState(message: error));
  }
}
