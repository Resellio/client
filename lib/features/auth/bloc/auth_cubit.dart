import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit_event.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/common/model/Users/admin.dart';
import 'package:resellio/features/common/model/Users/customer.dart';
import 'package:resellio/features/common/model/Users/organizer.dart';
import 'package:resellio/features/common/model/Users/organizer_registration_needed.dart';

class AuthCubit extends HydratedCubit<AuthState>
    with BlocPresentationMixin<AuthState, AuthCubitEvent> {
  AuthCubit({
    ApiService? apiService,
    required this.googleSignIn,
  })  : _apiService = apiService,
        super(const Unauthorized());

  ApiService? _apiService;
  final GoogleSignIn googleSignIn;

  ApiService get apiService {
    if (_apiService == null) {
      throw Exception('ApiService not initialized');
    }
    return _apiService!;
  }

  void setApiService(ApiService apiService) {
    _apiService = apiService;

    if (isAuthenticated && _apiService != null) {
      _verifyCurrentUser();
    }
  }

  Future<void> _verifyCurrentUser() async {
    try {
      if (isOrganizer || isUnverifiedOrganizer) {
        await apiService.organizerAboutMe(token);
      }
    } catch (err) {
      debugPrint('Failed to verify user state: $err');
      await logout();
    }
  }

  bool get isAuthenticated => state is! Unauthorized;
  bool get isCustomer => state is AuthorizedCustomer;
  bool get isOrganizer => state is AuthorizedOrganizer;
  bool get isOrganizerRegistrationNeeded =>
      state is AuthorizedOrganizerRegistrationNeeded;
  bool get isUnverifiedOrganizer => state is AuthorizedUnverifiedOrganizer;
  bool get isAdmin => state is AuthorizedAdmin;

  String get token {
    if (state is AuthorizedCustomer) {
      return (state as AuthorizedCustomer).user.token;
    } else if (state is AuthorizedOrganizer) {
      return (state as AuthorizedOrganizer).user.token;
    } else if (state is AuthorizedUnverifiedOrganizer) {
      return (state as AuthorizedUnverifiedOrganizer).user.token;
    } else if (state is AuthorizedOrganizerRegistrationNeeded) {
      return (state as AuthorizedOrganizerRegistrationNeeded).user.token;
    } else if (state is AuthorizedAdmin) {
      return (state as AuthorizedAdmin).user.token;
    } else {
      throw Exception('No token available for the current state');
    }
  }

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
        token: response.data?['token'] as String,
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

      final token = response.data?['token'] as String;
      final isVerified = response.data?['isVerified'] as bool;
      final isNewOrganizer = response.data?['isNewOrganizer'] as bool;

      if (isNewOrganizer) {
        final user = OrganizerRegistrationNeeded(
          email: googleUser.email,
          token: token,
        );

        emitPresentation(AuthenticatedEvent(user));
        emit(AuthorizedOrganizerRegistrationNeeded(user));
      } else {
        final aboutMeResponse = await apiService.organizerAboutMe(token);

        final user = Organizer(
          email: googleUser.email,
          firstName: aboutMeResponse.data?['firstName'] as String,
          lastName: aboutMeResponse.data?['lastName'] as String,
          displayName: aboutMeResponse.data?['displayName'] as String,
          token: token,
        );

        if (isVerified) {
          emitPresentation(AuthenticatedEvent(user));
          emit(AuthorizedOrganizer(user));
        } else {
          emitPresentation(AuthenticatedEvent(user));
          emit(AuthorizedUnverifiedOrganizer(user));
        }
      }
    } catch (err) {
      emitPresentation(AuthErrorEvent(err.toString()));
    }
  }

  Future<void> adminSignInWithGoogle() async {
    try {
      final googleUser = await _signInWithGoogle();
      final googleAuth = await googleUser.authentication;

      final response = await apiService.googleLogin(
        accessToken: googleAuth.accessToken!,
        endpoint: ApiEndpoints.adminGoogleLogin,
      );

      final user = Admin(
        email: googleUser.email,
        token: response.data?['token'] as String,
      );

      emitPresentation(AuthenticatedEvent(user));
      emit(AuthorizedAdmin(user));
    } on ApiException catch (err) {
      if (err.toString().contains('404')) {
        emitPresentation(
          const AuthErrorEvent('Błąd: Nie jesteś administratorem'),
        );
      } else {
        emitPresentation(AuthErrorEvent(err.toString()));
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
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
      );

      emit(
        AuthorizedUnverifiedOrganizer(
          Organizer(
            email: currentState.user.email,
            token: response.data?['token'] as String,
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
    } catch (err, st) {
      debugPrint('Error serializing AuthState: $err');
      debugPrint(st.toString());
      return const Unauthorized().toJson();
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthState.fromJson(json);
    } catch (err, st) {
      debugPrint('Error deserializing AuthState: $err');
      debugPrint(st.toString());
      return const Unauthorized();
    }
  }

  Future<void> logout() async {
    await googleSignIn.signOut();
    emit(const Unauthorized());
    await clear();
  }
}
