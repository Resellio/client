import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/Users/customer.dart';
import 'package:resellio/features/common/model/Users/organizer.dart';
import 'package:resellio/features/common/model/Users/organizer_registration_needed.dart';
import 'package:resellio/features/common/model/Users/user.dart';

class AuthCubit extends Cubit<AuthState>
    with BlocPresentationMixin<AuthState, AuthCubitEvent> {
  AuthCubit() : super(Unauthorized());

  bool get isAuthenticated => state is! Unauthorized;
  bool get isCustomer => state is AuthorizedCustomer;
  bool get isOrganizer => state is AuthorizedOrganizer;
  bool get isOrganizerRegistrationNeeded =>
      state is AuthorizedOrganizerRegistrationNeeded;

  User get user => (state as AuthorizedCustomer).user;

  Future<void> customerSignInWithGoogle() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      // 50% chance of failing
      if (DateTime.now().millisecondsSinceEpoch.isEven) {
        throw Exception('50% failed');
      }

      const user = Customer(
        id: '1',
        email: 'klient@pl.pl',
      );

      emit(const AuthorizedCustomer(user));
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

      const user = OrganizerRegistrationNeeded(
        id: '1',
        email: '',
      );

      emit(const AuthorizedOrganizerRegistrationNeeded(user));
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

      const user = Organizer(
        id: '1',
        email: '',
      );

      emit(const AuthorizedOrganizer(user));
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

class AuthorizedCustomer extends AuthState {
  const AuthorizedCustomer(this.user);

  final Customer user;

  @override
  List<Object> get props => [user];
}

class AuthorizedOrganizer extends AuthState {
  const AuthorizedOrganizer(this.user);

  final Organizer user;

  @override
  List<Object> get props => [user];
}

class AuthorizedOrganizerRegistrationNeeded extends AuthState {
  const AuthorizedOrganizerRegistrationNeeded(this.user);

  final OrganizerRegistrationNeeded user;

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
