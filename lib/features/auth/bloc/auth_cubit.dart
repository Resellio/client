import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/role.dart';
import 'package:resellio/features/common/model/user.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool get isAuthenticated => state is AuthSuccess;
  bool get isCustomer =>
      isAuthenticated && (state as AuthSuccess).user.role == Role.customer;
  bool get isOrganizer =>
      isAuthenticated && (state as AuthSuccess).user.role == Role.organizer;
  bool get isAdmin =>
      isAuthenticated && (state as AuthSuccess).user.role == Role.admin;
  bool get isOrganizerRegistrationNeeded =>
      isAuthenticated &&
      (state as AuthSuccess).user.role == Role.organizerRegistration;

  Future<void> customerSignInWithGoogle() async {
    emit(AuthLoading());
    try {
      await Future.delayed(Duration(seconds: 1));
      emit(
        const AuthSuccess(
          // temp
          User(
            id: '1',
            email: 'sd@pl.pl',
            role: Role.customer,
          ),
        ),
      );
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> organizerSignInWithGoogle() async {
    emit(AuthLoading());
    try {
      // await Future.delayed(Duration(seconds: 1));
      emit(
        const AuthSuccess(
          // temp
          User(
            id: '1',
            email: '',
            role: Role.organizerRegistration,
          ),
        ),
      );
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> completeOrganizerRegistration({
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    // emit(AuthLoading());
    try {
      await Future.delayed(Duration(seconds: 1));
      throw Exception('Not implemented');
      emit(
        const AuthSuccess(
          // temp
          User(
            id: '1',
            email: '',
            role: Role.organizer,
          ),
        ),
      );
    } catch (err) {
      throw Exception('Not implemented');
      emit(AuthError(err.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthInitial());
  }
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
