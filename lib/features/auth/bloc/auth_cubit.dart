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
      await Future.delayed(Duration(seconds: 1));
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
