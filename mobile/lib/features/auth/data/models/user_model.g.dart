// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      isEmailVerified: json['email_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profile: json['profile'] as Map<String, dynamic>?,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'avatar': instance.avatar,
      'role': instance.role,
      'status': instance.status,
      'profile': instance.profile,
      'preferences': instance.preferences,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email_verified': instance.isEmailVerified,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
