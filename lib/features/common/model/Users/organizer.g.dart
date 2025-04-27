// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organizer _$OrganizerFromJson(Map<String, dynamic> json) => Organizer(
      email: json['email'] as String,
      token: json['token'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      displayName: json['displayName'] as String,
    );

Map<String, dynamic> _$OrganizerToJson(Organizer instance) => <String, dynamic>{
      'email': instance.email,
      'token': instance.token,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
    };
