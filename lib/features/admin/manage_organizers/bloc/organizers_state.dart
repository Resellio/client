import 'package:resellio/features/admin/manage_organizers/bloc/organizer.dart';
import 'package:equatable/equatable.dart';

enum OrganizersStatus { initial, loading, success, failure }

class OrganizersState extends Equatable {
  final OrganizersStatus status;
  final List<Organizer> organizers;
  final int currentPage;
  final bool hasReachedMax;
  final int? totalResults;
  final String? errorMessage;

  const OrganizersState({
    this.status = OrganizersStatus.initial,
    this.organizers = const [],
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.totalResults,
    this.errorMessage,
  });

  OrganizersState copyWith({
    OrganizersStatus? status,
    List<Organizer>? organizers,
    int? currentPage,
    bool? hasReachedMax,
    int? totalResults,
    String? errorMessage,
  }) {
    return OrganizersState(
      status: status ?? this.status,
      organizers: organizers ?? this.organizers,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalResults: totalResults ?? this.totalResults,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        organizers,
        currentPage,
        hasReachedMax,
        totalResults,
        errorMessage,
      ];
}
