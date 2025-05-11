// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorizedCustomer _$AuthorizedCustomerFromJson(Map<String, dynamic> json) =>
    AuthorizedCustomer(
      Customer.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorizedCustomerToJson(AuthorizedCustomer instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
    };

AuthorizedOrganizer _$AuthorizedOrganizerFromJson(Map<String, dynamic> json) =>
    AuthorizedOrganizer(
      Organizer.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorizedOrganizerToJson(
        AuthorizedOrganizer instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
    };

AuthorizedUnverifiedOrganizer _$AuthorizedUnverifiedOrganizerFromJson(
        Map<String, dynamic> json) =>
    AuthorizedUnverifiedOrganizer(
      Organizer.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorizedUnverifiedOrganizerToJson(
        AuthorizedUnverifiedOrganizer instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
    };

AuthorizedOrganizerRegistrationNeeded
    _$AuthorizedOrganizerRegistrationNeededFromJson(
            Map<String, dynamic> json) =>
        AuthorizedOrganizerRegistrationNeeded(
          OrganizerRegistrationNeeded.fromJson(
              json['user'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$AuthorizedOrganizerRegistrationNeededToJson(
        AuthorizedOrganizerRegistrationNeeded instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
    };

AuthorizedAdmin _$AuthorizedAdminFromJson(Map<String, dynamic> json) =>
    AuthorizedAdmin(
      Admin.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorizedAdminToJson(AuthorizedAdmin instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
    };
