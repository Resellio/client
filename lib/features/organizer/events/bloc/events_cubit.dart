import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/common/model/paginated.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart';

class OrganizerEventsCubit extends Cubit<EventsState> {
  OrganizerEventsCubit({required ApiService apiService})
      : _apiService = apiService,
        super(const EventsState());

  final ApiService _apiService;
  final int _pageSize = 10;

  Future<void> fetchNextPage(String token) async {
    if (state.status == EventsStatus.loading || state.hasReachedMax) {
      debugPrint(
        'Fetch skipped: Status=${state.status}, hasReachedMax=${state.hasReachedMax}',
      );
      return;
    }

    debugPrint('Fetching next page of organizer events...');
    emit(state.copyWith(status: EventsStatus.loading));

    try {
      final pageToFetch = state.currentPage + 1;

      debugPrint(
        'Fetching organizer events - Page: $pageToFetch, Query: "${state.searchQuery}", StartDate: ${state.startDateFilter}, EndDate: ${state.endDateFilter}',
      );

      final response = await _apiService.getOrganizerEvents(
        token: token,
        page: pageToFetch,
        pageSize: _pageSize,
        query: state.searchQuery,
        startDate: state.startDateFilter,
        endDate: state.endDateFilter,
      );

      final paginatedData = PaginatedData<Event>.fromJson(
        response.data ?? {},
        (json) => Event.fromJson(json as Map<String, dynamic>),
      );

      final newEvents = paginatedData.data;
      final bool hasReachedMax = !paginatedData.hasNextPage;
      final int totalResults = state.totalResults ??
          paginatedData.paginationDetails.allElementsCount;

      emit(
        state.copyWith(
          status: EventsStatus.success,
          events: List.of(state.events)..addAll(newEvents),
          hasReachedMax: hasReachedMax,
          currentPage: paginatedData.pageNumber,
          totalResults: totalResults,
        ),
      );
      debugPrint(
        'Fetch successful. New count: ${state.events.length}. HasReachedMax: $hasReachedMax',
      );
    } on ApiException catch (err) {
      debugPrint('ApiException fetching organizer events: $err');
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: err.toString(),
        ),
      );
    } catch (err, st) {
      debugPrint('Unknown Error fetching organizer events: $err');
      debugPrint(st.toString());
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: 'An unexpected error occurred.',
        ),
      );
    }
  }

  Future<void> applyFiltersAndFetch({
    required String token,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    DateTime? minEndDate,
    DateTime? maxEndDate,
  }) async {
    debugPrint('Applying filters and fetching organizer events...');

    emit(
      EventsState(
        status: EventsStatus.loading,
        searchQuery: searchQuery,
        startDateFilter: startDate,
        endDateFilter: endDate,
      ),
    );

    try {
      const firstPage = 0;

      debugPrint(
        'Fetching filtered organizer events - Page: $firstPage, Query: "$searchQuery", StartDate: $startDate, EndDate: $endDate',
      );

      final response = await _apiService.getOrganizerEvents(
        token: token,
        page: firstPage,
        pageSize: _pageSize,
        query: searchQuery,
        startDate: startDate,
        endDate: endDate,
        minStartDate: minStartDate,
        maxStartDate: maxStartDate,
        minEndDate: minEndDate,
        maxEndDate: maxEndDate,
      );

      final paginatedData = PaginatedData<Event>.fromJson(
        response.data ?? {},
        (json) => Event.fromJson(json as Map<String, dynamic>),
      );

      final newEvents = paginatedData.data;
      final bool hasReachedMax = !paginatedData.hasNextPage;
      final int totalResults = paginatedData.paginationDetails.allElementsCount;

      emit(
        state.copyWith(
          status: EventsStatus.success,
          events: newEvents,
          hasReachedMax: hasReachedMax,
          currentPage: paginatedData.pageNumber,
          totalResults: totalResults,
        ),
      );
      debugPrint(
        'Filter fetch successful. Count: ${state.events.length}. HasReachedMax: $hasReachedMax',
      );
    } on ApiException catch (err) {
      debugPrint('ApiException applying organizer filters: $err');
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: err.toString(),
          events: [],
          hasReachedMax: false,
          currentPage: 0,
        ),
      );
    } catch (err, st) {
      debugPrint('Unknown Error applying organizer filters: $err');
      debugPrint(st.toString());
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: 'An unexpected error occurred.',
          events: [],
          hasReachedMax: false,
          currentPage: 0,
        ),
      );
    }
  }

  Future<void> refreshEvents(String token) async {
    debugPrint('Refreshing organizer events...');

    final currentFilters = EventsState(
      searchQuery: state.searchQuery,
      startDateFilter: state.startDateFilter,
      endDateFilter: state.endDateFilter,
    );

    emit(currentFilters.copyWith(status: EventsStatus.loading));

    await applyFiltersAndFetch(
      token: token,
      searchQuery: state.searchQuery,
      startDate: state.startDateFilter,
      endDate: state.endDateFilter,
    );
  }
}
