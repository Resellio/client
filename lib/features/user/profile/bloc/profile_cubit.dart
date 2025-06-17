import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/user/profile/bloc/about_me.dart';
import 'package:resellio/features/user/profile/bloc/profile_state.dart';

class CustomerProfileCubit extends Cubit<CustomerProfileState> {
  CustomerProfileCubit(this._apiService, this._authCubit)
      : super(const CustomerProfileState());

  final ApiService _apiService;
  final AuthCubit _authCubit;

  Future<void> fetchAboutMe() async {
    emit(
      state.copyWith(status: CustomerProfileStatus.loading),
    );

    try {
      final aboutMe = await _apiService.customerAboutMe(_authCubit.token);
      // debugPrint('Fetched aboutMe: ${aboutme.displayName}');
      final am = CustomerAboutme.fromJson(aboutMe.data!);
      emit(
        state.copyWith(
          status: CustomerProfileStatus.success,
          aboutMe: am,
        ),
      );
    } on ApiException catch (err) {
      emit(
        state.copyWith(
          status: CustomerProfileStatus.failure,
          errorMessage: err.message,
        ),
      );
    } catch (err, st) {
      debugPrint('Unexpected error: $err\n$st');
      emit(
        state.copyWith(
          status: CustomerProfileStatus.failure,
          errorMessage: 'Unexpected error occurred.',
        ),
      );
    }
  }
}
