import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/role.dart';
import 'package:resellio/features/common/model/user.dart';

class AuthCubit extends Cubit<AuthState>
    with BlocPresentationMixin<AuthState, AuthCubitEvent> {
  AuthCubit() : super(Unauthorized());

  bool get isAuthenticated => state is Authorized;
  bool get isCustomer =>
      isAuthenticated && (state as Authorized).user.role == Role.customer;
  bool get isOrganizer =>
      isAuthenticated && (state as Authorized).user.role == Role.organizer;
  bool get isAdmin =>
      isAuthenticated && (state as Authorized).user.role == Role.admin;
  bool get isOrganizerRegistrationNeeded =>
      isAuthenticated &&
      (state as Authorized).user.role == Role.organizerRegistration;

  User get user => (state as Authorized).user;

  Future<void> customerSignInWithGoogle() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      // 50% chance of failing
      if (DateTime.now().millisecondsSinceEpoch.isEven) {
        throw Exception('50% failed');
      }

      const user = User(
        id: '1',
        email: 'klient@pl.pl',
        role: Role.customer,
      );

      emit(const Authorized(user));
    } catch (err) {
      emitPresentation(FailedToSignIn(err.toString()));
    }
  }

  Future<void> organizerSignInWithGoogle() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      // 50% chance of failing
      if (DateTime.now().millisecondsSinceEpoch.isEven) {
        throw Exception('50% failed');
      }

      const user = User(
        id: '1',
        email: '',
        role: Role.organizerRegistration,
      );

      emit(const Authorized(user));
    } catch (err) {
      emitPresentation(FailedToSignIn(err.toString()));
    }
  }

  Future<void> completeOrganizerRegistration({
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    try {
      // temporary mockup
      await Future.delayed(const Duration(seconds: 1));

      // 50% chance of failing
      if (DateTime.now().millisecondsSinceEpoch.isEven) {
        throw Exception('Not implemented');
      }

      const user = User(
        id: '1',
        email: '',
        role: Role.organizer,
      );

      emit(const Authorized(user));
    } catch (err) {
      emitPresentation(FailedToRegister(err.toString()));
    }
  }

  Future<void> logout() async {
    emit(Unauthorized());
  }
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class Unauthorized extends AuthState {}

class Authorized extends AuthState {
  const Authorized(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

sealed class AuthCubitEvent {}

class FailedToRegister implements AuthCubitEvent {
  const FailedToRegister(this.reason);

  final String reason;
}

class FailedToSignIn implements AuthCubitEvent {
  const FailedToSignIn(this.reason);

  final String reason;
}
