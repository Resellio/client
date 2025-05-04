import 'package:equatable/equatable.dart';
import 'package:resellio/features/common/model/event.dart';

enum EventsStatus { initial, loading, success, failure }

class EventsState extends Equatable {
  const EventsState({
    this.status = EventsStatus.initial,
    this.events = const <Event>[],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.errorMessage,
    this.searchQuery,
    this.totalResults,
    this.startDateFilter,
    this.endDateFilter,
    this.minPriceFilter,
    this.maxPriceFilter,
    this.cityFilter,
    this.categoryFilter,
  });

  EventsState copyWith({
    EventsStatus? status,
    List<Event>? events,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
    int? totalResults,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    double? minPriceFilter,
    double? maxPriceFilter,
    String? cityFilter,
    String? categoryFilter,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      totalResults: totalResults ?? this.totalResults,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
      minPriceFilter: minPriceFilter ?? this.minPriceFilter,
      maxPriceFilter: maxPriceFilter ?? this.maxPriceFilter,
      cityFilter: cityFilter ?? this.cityFilter,
    );
  }

  final EventsStatus status;
  final List<Event> events;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;
  final String? searchQuery;
  final int? totalResults;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final double? minPriceFilter;
  final double? maxPriceFilter;
  final String? cityFilter;
  final String? categoryFilter;

  @override
  List<Object?> get props => [
        status,
        events,
        hasReachedMax,
        currentPage,
        errorMessage,
        searchQuery,
        totalResults,
        startDateFilter,
        endDateFilter,
        minPriceFilter,
        maxPriceFilter,
        cityFilter,
        categoryFilter,
      ];
}
