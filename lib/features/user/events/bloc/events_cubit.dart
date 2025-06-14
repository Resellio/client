import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/common/model/paginated.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit({required ApiService apiService})
      : _apiService = apiService,
        super(const EventsState());

  final ApiService _apiService;
  final int _pageSize = 3;

  Future<void> fetchNextPage() async {
    if (state.status == EventsStatus.loading || state.hasReachedMax) {
      debugPrint(
        'Fetch skipped: Status=${state.status}, hasReachedMax=${state.hasReachedMax}',
      );
      return;
    }

    debugPrint('Fetching next page...');
    emit(state.copyWith(status: EventsStatus.loading));

    try {
      final pageToFetch = state.currentPage + 1;

      debugPrint(
        'Fetching events - Page: $pageToFetch, Query: "${state.searchQuery}", StartDate: ${state.startDateFilter}, EndDate: ${state.endDateFilter}, MinPrice: ${state.minPriceFilter}, MaxPrice: ${state.maxPriceFilter}, City: "${state.cityFilter}", Category: "${state.categoryFilter}"',
      );

      final response = await _apiService.getEvents(
        page: pageToFetch,
        pageSize: _pageSize,
        query: state.searchQuery,
        startDate: state.startDateFilter,
        endDate: state.endDateFilter,
        minPrice: state.minPriceFilter,
        maxPrice: state.maxPriceFilter,
        city: state.cityFilter,
        categories: state.categoryFilter,
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
      debugPrint('ApiException fetching next page: $err');
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: err.toString(),
        ),
      );
    } catch (err, st) {
      debugPrint('Unknown Error fetching next page: $err');
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
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? city,
    List<String>? categories,
  }) async {
    debugPrint('Applying filters and fetching first page...');

    emit(
      EventsState(
        status: EventsStatus.loading,
        searchQuery: searchQuery,
        startDateFilter: startDate,
        endDateFilter: endDate,
        minPriceFilter: minPrice,
        maxPriceFilter: maxPrice,
        cityFilter: city,
        categoryFilter: categories,
      ),
    );

    try {
      const firstPage = 0;

      debugPrint(
        'Fetching filtered events - Page: $firstPage, Query: "$searchQuery", StartDate: $startDate, EndDate: $endDate, MinPrice: $minPrice, MaxPrice: $maxPrice, City: "$city", Category: "$categories"',
      );

      final response = await _apiService.getEvents(
        page: firstPage,
        pageSize: _pageSize,
        query: searchQuery,
        startDate: startDate,
        endDate: endDate,
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city,
        categories: categories,
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
      debugPrint('ApiException applying filters: $err');
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
      debugPrint('Unknown Error applying filters: $err');
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

  Future<void> refreshEvents() async {
    debugPrint('Refreshing events...');

    await applyFiltersAndFetch(
      searchQuery: state.searchQuery,
      startDate: state.startDateFilter,
      endDate: state.endDateFilter,
      minPrice: state.minPriceFilter,
      maxPrice: state.maxPriceFilter,
      city: state.cityFilter,
      categories: state.categoryFilter,
    );
  }
}
