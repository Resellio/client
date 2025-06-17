import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/organizer/profile/bloc/about_me.dart';
import 'package:resellio/features/organizer/profile/bloc/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._apiService, this._authCubit) : super(const ProfileState());

  final ApiService _apiService;
  final AuthCubit _authCubit;

  Future<void> fetchAboutMe() async {
    emit(
      state.copyWith(status: ProfileStatus.loading),
    );

    try {
      final aboutMe = await _apiService.organizerAboutMe(_authCubit.token);
      // debugPrint('Fetched aboutMe: ${aboutme.displayName}');
      final am = Aboutme.fromJson(aboutMe.data!);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          aboutMe: am,
        ),
      );
    } on ApiException catch (err) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: err.message,
        ),
      );
    } catch (err, st) {
      debugPrint('Unexpected error: $err\n$st');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Unexpected error occurred.',
        ),
      );
    }
  }
}
