import 'package:equatable/equatable.dart';
import 'package:resellio/features/common/model/Users/customer.dart';
import 'package:resellio/features/common/model/Users/organizer.dart';
import 'package:resellio/features/common/model/Users/organizer_registration_needed.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class Unauthorized extends AuthState {
  const Unauthorized();

  @override
  List<Object> get props => [];
}

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

class AuthorizedUnverifiedOrganizer extends AuthState {
  const AuthorizedUnverifiedOrganizer(this.user);

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
