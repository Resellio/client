import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final ApiService _apiService;
  final int _pageSize = 20;

  EventsCubit({required ApiService apiService})
      : _apiService = apiService,
        super(const EventsState());

  Future<void> fetchEvents(String token, {bool isInitialLoad = true}) async {
    if (state.hasReachedMax && !isInitialLoad) return;
    if (state.status == EventsStatus.loading && isInitialLoad) return;
    if (state.status == EventsStatus.loadingMore && !isInitialLoad) return;

    try {
      int pageToFetch;
      if (isInitialLoad) {
        emit(state.copyWith(
            status: EventsStatus.loading,
            errorMessage: null,
            clearError: true));
        pageToFetch = 0;
      } else {
        emit(state.copyWith(
            status: EventsStatus.loadingMore,
            errorMessage: null,
            clearError: true));
        pageToFetch = state.currentPage + 1;
      }

      final response = await _apiService.getEvents(
        token: token,
        page: pageToFetch,
        pageSize: _pageSize,
      );

      final paginatedData = PaginatedData<GetEventResponseDto>.fromJson(
        response,
        (json) => GetEventResponseDto.fromJson(json as Map<String, dynamic>),
      );

      final newEvents = paginatedData.data;
      final bool hasReachedMax = !paginatedData.hasNextPage;

      emit(state.copyWith(
        status: EventsStatus.success,
        events: isInitialLoad ? newEvents : [...state.events, ...newEvents],
        hasReachedMax: hasReachedMax,
        currentPage: paginatedData.pageNumber,
      ));
    } on ApiException catch (e) {
      print('ApiException in Cubit: $e');
      emit(state.copyWith(
          status: EventsStatus.failure, errorMessage: e.toString()));
    } catch (e) {
      print('Unknown Error in Cubit: $e');
      emit(state.copyWith(
          status: EventsStatus.failure,
          errorMessage: 'An unexpected error occurred.'));
    }
  }

  Future<void> refreshEvents(String token) async {
    emit(const EventsState());
    await fetchEvents(token, isInitialLoad: true);
  }

  Future<void> loadMoreEvents(String token) async {
    await fetchEvents(token, isInitialLoad: false);
  }
}
