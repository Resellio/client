import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:resellio/features/common/model/Users/admin.dart';
import 'package:resellio/features/common/model/Users/customer.dart';
import 'package:resellio/features/common/model/Users/organizer.dart';
import 'package:resellio/features/common/model/Users/organizer_registration_needed.dart';

part 'auth_state.g.dart';

const String _kTypeKey = 'authStateType';

abstract class AuthState extends Equatable {
  const AuthState();

  factory AuthState.fromJson(Map<String, dynamic> json) {
    final type = json[_kTypeKey] as String?;
    switch (type) {
      case 'Unauthorized':
        return Unauthorized.fromJson();
      case 'AuthorizedCustomer':
        return AuthorizedCustomer.fromJson(json);
      case 'AuthorizedOrganizer':
        return AuthorizedOrganizer.fromJson(json);
      case 'AuthorizedUnverifiedOrganizer':
        return AuthorizedUnverifiedOrganizer.fromJson(json);
      case 'AuthorizedOrganizerRegistrationNeeded':
        return AuthorizedOrganizerRegistrationNeeded.fromJson(json);
      case 'AuthorizedAdmin':
        return AuthorizedAdmin.fromJson(json);
      default:
        debugPrint('Warning: Unknown or missing AuthState type in JSON: $type');
        return const Unauthorized();
    }
  }

  Map<String, dynamic> toJson();

  @override
  List<Object> get props => [];
}

class Unauthorized extends AuthState {
  const Unauthorized();

  factory Unauthorized.fromJson() => const Unauthorized();

  @override
  Map<String, dynamic> toJson() => {_kTypeKey: 'Unauthorized'};
}

@JsonSerializable(explicitToJson: true)
class AuthorizedCustomer extends AuthState {
  const AuthorizedCustomer(this.user);

  factory AuthorizedCustomer.fromJson(Map<String, dynamic> json) =>
      _$AuthorizedCustomerFromJson(json);

  final Customer user;

  @override
  Map<String, dynamic> toJson() =>
      {_kTypeKey: 'AuthorizedCustomer', ..._$AuthorizedCustomerToJson(this)};

  @override
  List<Object> get props => [user];
}

@JsonSerializable(explicitToJson: true)
class AuthorizedOrganizer extends AuthState {
  const AuthorizedOrganizer(this.user);

  factory AuthorizedOrganizer.fromJson(Map<String, dynamic> json) =>
      _$AuthorizedOrganizerFromJson(json);

  final Organizer user;

  @override
  Map<String, dynamic> toJson() =>
      {_kTypeKey: 'AuthorizedOrganizer', ..._$AuthorizedOrganizerToJson(this)};

  @override
  List<Object> get props => [user];
}

@JsonSerializable(explicitToJson: true)
class AuthorizedUnverifiedOrganizer extends AuthState {
  const AuthorizedUnverifiedOrganizer(this.user);

  factory AuthorizedUnverifiedOrganizer.fromJson(Map<String, dynamic> json) =>
      _$AuthorizedUnverifiedOrganizerFromJson(json);

  final Organizer user;

  @override
  Map<String, dynamic> toJson() => {
        _kTypeKey: 'AuthorizedUnverifiedOrganizer',
        ..._$AuthorizedUnverifiedOrganizerToJson(this),
      };

  @override
  List<Object> get props => [user];
}

@JsonSerializable(explicitToJson: true)
class AuthorizedOrganizerRegistrationNeeded extends AuthState {
  const AuthorizedOrganizerRegistrationNeeded(this.user);

  factory AuthorizedOrganizerRegistrationNeeded.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$AuthorizedOrganizerRegistrationNeededFromJson(json);

  final OrganizerRegistrationNeeded user;

  @override
  Map<String, dynamic> toJson() => {
        _kTypeKey: 'AuthorizedOrganizerRegistrationNeeded',
        ..._$AuthorizedOrganizerRegistrationNeededToJson(this),
      };

  @override
  List<Object> get props => [user];
}

@JsonSerializable(explicitToJson: true)
class AuthorizedAdmin extends AuthState {
  const AuthorizedAdmin(this.user);

  factory AuthorizedAdmin.fromJson(Map<String, dynamic> json) =>
      _$AuthorizedAdminFromJson(json);

  final Admin user;

  @override
  Map<String, dynamic> toJson() =>
      {_kTypeKey: 'AuthorizedAdmin', ..._$AuthorizedAdminToJson(this)};

  @override
  List<Object> get props => [user];
}
