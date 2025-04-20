import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit_event.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/model/Users/customer.dart';
import 'package:resellio/features/common/model/Users/organizer.dart';
import 'package:resellio/features/common/model/Users/organizer_registration_needed.dart';

class AuthCubit extends HydratedCubit<AuthState>
    with BlocPresentationMixin<AuthState, AuthCubitEvent> {
  AuthCubit({
    required this.apiService,
    required this.googleSignIn,
  }) : super(const Unauthorized());

  final ApiService apiService;
  final GoogleSignIn googleSignIn;

  bool get isAuthenticated => state is! Unauthorized;
  bool get isCustomer => state is AuthorizedCustomer;
  bool get isOrganizer => state is AuthorizedOrganizer;
  bool get isOrganizerRegistrationNeeded =>
      state is AuthorizedOrganizerRegistrationNeeded;
  bool get isUnverifiedOrganizer => state is AuthorizedUnverifiedOrganizer;

  Future<GoogleSignInAccount> _signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In cancelled');
    }

    return googleUser;
  }

  Future<void> customerSignInWithGoogle() async {
    try {
      final googleUser = await _signInWithGoogle();
      final googleAuth = await googleUser.authentication;

      final response = await apiService.googleLogin(
        accessToken: googleAuth.accessToken!,
        endpoint: ApiEndpoints.customerGoogleLogin,
      );

      final user = Customer(
        email: googleUser.email,
        token: response['token'] as String,
      );

      emitPresentation(AuthenticatedEvent(user));
      emit(AuthorizedCustomer(user));
    } catch (err) {
      if (err.toString() == 'popup_closed') {
        return;
      }
      emitPresentation(AuthErrorEvent(err.toString()));
    }
  }

  Future<void> organizerSignInWithGoogle() async {
    try {
      final googleUser = await _signInWithGoogle();
      final googleAuth = await googleUser.authentication;

      final response = await apiService.googleLogin(
        accessToken: googleAuth.accessToken!,
        endpoint: ApiEndpoints.organizerGoogleLogin,
      );

      final token = response['token'] as String;
      final isVerified = response['isVerified'] as bool;
      final isNewOrganizer = response['isNewOrganizer'] as bool;

      if (isNewOrganizer) {
        final user = OrganizerRegistrationNeeded(
          email: googleUser.email,
          token: token,
        );

        emitPresentation(AuthenticatedEvent(user));
        emit(AuthorizedOrganizerRegistrationNeeded(user));
      } else if (isVerified) {
        final user = Organizer(
          email: googleUser.email,
          firstName: 'xd',
          lastName: 'xd2',
          displayName: 'xd3',
          token: token,
        );

        emitPresentation(AuthenticatedEvent(user));
        emit(AuthorizedOrganizer(user));
      } else {
        final user = Organizer(
          email: googleUser.email,
          token: token,
          firstName: 'xd',
          lastName: 'xd2',
          displayName: 'xd3',
        );

        emitPresentation(AuthenticatedEvent(user));
        emit(AuthorizedUnverifiedOrganizer(user));
      }
    } catch (err) {
      emitPresentation(AuthErrorEvent(err.toString()));
    }
  }

  Future<void> completeOrganizerRegistration({
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    try {
      if (!isOrganizerRegistrationNeeded) {
        throw Exception('Wrong state for completing organizer registration');
      }

      final currentState = state as AuthorizedOrganizerRegistrationNeeded;
      final response = await apiService.createOrganizer(
        token: currentState.user.token,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
      );

      emit(
        AuthorizedUnverifiedOrganizer(
          Organizer(
            email: currentState.user.email,
            token: response['token'] as String,
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
          ),
        ),
      );
    } catch (err) {
      emitPresentation(AuthErrorEvent(err.toString()));
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      return state.toJson();
    } catch (e, stackTrace) {
      debugPrint('Error serializing AuthState: $e');
      debugPrint(stackTrace.toString());
      return const Unauthorized().toJson();
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthState.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('Error deserializing AuthState: $e');
      debugPrint(stackTrace.toString());
      return const Unauthorized();
    }
  }

  Future<void> logout() async {
    await googleSignIn.signOut();
    emit(const Unauthorized());
    await clear();
  }
}
