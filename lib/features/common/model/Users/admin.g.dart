// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Admin _$AdminFromJson(Map<String, dynamic> json) => Admin(
      token: json['token'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
      'email': instance.email,
      'token': instance.token,
    };
