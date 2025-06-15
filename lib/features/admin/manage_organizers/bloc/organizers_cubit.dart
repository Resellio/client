import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/admin/manage_organizers/bloc/organizer.dart';
import 'package:resellio/features/admin/manage_organizers/bloc/organizers_state.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/common/model/paginated.dart';

class OrganizersCubit extends Cubit<OrganizersState> {
  OrganizersCubit(this._apiService) : super(const OrganizersState());

  final ApiService _apiService;
  final int _pageSize = 100;
  Future<void> fetchAllOrganizers() async {
    if (state.status == OrganizersStatus.loading) {
      debugPrint('Skipping fetch: already loading.');
      return;
    }

    emit(state.copyWith(status: OrganizersStatus.loading));

    try {
      final List<Organizer> allOrganizers = [];
      var currentPage = 0;
      var hasMoreData = true;

      while (hasMoreData) {
        final response = await _apiService.getUnverifiedOrganizers(
          page: currentPage,
          pageSize: _pageSize,
        );

        final paginated = PaginatedData<Organizer>.fromJson(
          response.data ?? {},
          (json) => Organizer.fromJson(json as Map<String, dynamic>),
        );

        allOrganizers.addAll(paginated.data);
        hasMoreData = paginated.hasNextPage;
        currentPage++;

        if (currentPage > 100) {
          debugPrint('Warning: Stopped fetching after 100 pages');
          break;
        }
      }

      emit(
        state.copyWith(
          status: OrganizersStatus.success,
          organizers: allOrganizers,
          currentPage: currentPage,
          hasReachedMax: true,
          totalResults: allOrganizers.length,
        ),
      );

      debugPrint('Fetched ${allOrganizers.length} organizers total');
    } on ApiException catch (err) {
      emit(
        state.copyWith(
          status: OrganizersStatus.failure,
          errorMessage: err.message,
        ),
      );
    } catch (err, st) {
      debugPrint('Unexpected error: $err\n$st');
      emit(
        state.copyWith(
          status: OrganizersStatus.failure,
          errorMessage: 'Unexpected error occurred.',
        ),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.status == OrganizersStatus.loading || state.hasReachedMax) {
      debugPrint('Skipping fetch: already loading or no more data.');
      return;
    }

    emit(state.copyWith(status: OrganizersStatus.loading));

    final pageToFetch = state.currentPage;

    try {
      final response = await _apiService.getUnverifiedOrganizers(
        page: pageToFetch,
        pageSize: _pageSize,
      );

      final paginated = PaginatedData<Organizer>.fromJson(
        response.data ?? {},
        (json) => Organizer.fromJson(json as Map<String, dynamic>),
      );

      final newList = <Organizer>[
        if (pageToFetch != 0) ...state.organizers,
        ...paginated.data,
      ];

      final hasReachedMax = !paginated.hasNextPage;

      emit(
        state.copyWith(
          status: OrganizersStatus.success,
          organizers: newList,
          currentPage: paginated.pageNumber + 1,
          hasReachedMax: hasReachedMax,
          totalResults: paginated.paginationDetails.allElementsCount,
        ),
      );
    } on ApiException catch (err) {
      emit(
        state.copyWith(
          status: OrganizersStatus.failure,
          errorMessage: err.message,
        ),
      );
    } catch (err, st) {
      debugPrint('Unexpected error: $err\n$st');
      emit(
        state.copyWith(
          status: OrganizersStatus.failure,
          errorMessage: 'Unexpected error occurred.',
        ),
      );
    }
  }

  Future<bool> verifyOrganizer(String email) async {
    if (state.status == OrganizersStatus.loading) {
      debugPrint('Cannot verify organizer while loading.');
      return false;
    }

    final previousState = state;
    emit(state.copyWith(status: OrganizersStatus.loading));

    try {
      await _apiService.verifyOrganizer(
        email: email,
      );

      final updatedOrganizers = state.organizers
          .where((organizer) => organizer.email != email)
          .toList();

      emit(
        state.copyWith(
          status: OrganizersStatus.success,
          organizers: updatedOrganizers,
          totalResults: state.totalResults! - 1,
        ),
      );

      debugPrint('Organizer verified successfully: $email');
      return true;
    } on ApiException catch (err) {
      debugPrint('API error verifying organizer: ${err.message}');
      emit(
        previousState.copyWith(
          status: OrganizersStatus.failure,
          errorMessage: 'Failed to verify organizer: ${err.message}',
        ),
      );
      return false;
    } catch (err, st) {
      debugPrint('Unexpected error verifying organizer: $err\n$st');
      emit(
        previousState.copyWith(
          status: OrganizersStatus.failure,
          errorMessage: 'Unexpected error occurred while verifying organizer.',
        ),
      );
      return false;
    }
  }

  Future<void> refresh() async {
    emit(
      state.copyWith(
        status: OrganizersStatus.initial,
        organizers: [],
        currentPage: 0,
        hasReachedMax: false,
        totalResults: 0,
      ),
    );
    await fetchAllOrganizers();
  }
}
