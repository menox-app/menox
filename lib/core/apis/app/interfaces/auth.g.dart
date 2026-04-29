// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInBody _$SignInBodyFromJson(Map<String, dynamic> json) => SignInBody(
  email: json['email'] as String,
  password: json['password'] as String,
  provider:
      $enumDecodeNullable(_$AuthProviderEnumMap, json['provider']) ??
      AuthProvider.password,
);

Map<String, dynamic> _$SignInBodyToJson(SignInBody instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'provider': _$AuthProviderEnumMap[instance.provider]!,
    };

const _$AuthProviderEnumMap = {
  AuthProvider.password: 'password',
  AuthProvider.code: 'code',
  AuthProvider.social: 'social',
  AuthProvider.google: 'google',
  AuthProvider.apple: 'apple',
};

SignInResponse _$SignInResponseFromJson(Map<String, dynamic> json) =>
    SignInResponse(
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$SignInResponseToJson(SignInResponse instance) =>
    <String, dynamic>{
      'access_token': instance.token,
      'refresh_token': instance.refreshToken,
    };

SignUpBody _$SignUpBodyFromJson(Map<String, dynamic> json) => SignUpBody(
  email: json['email'] as String,
  password: json['password'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$SignUpBodyToJson(SignUpBody instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };

SignUpResponse _$SignUpResponseFromJson(Map<String, dynamic> json) =>
    SignUpResponse(
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$SignUpResponseToJson(SignUpResponse instance) =>
    <String, dynamic>{
      'access_token': instance.token,
      'refresh_token': instance.refreshToken,
    };

RefreshTokenBody _$RefreshTokenBodyFromJson(Map<String, dynamic> json) =>
    RefreshTokenBody(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshTokenBodyToJson(RefreshTokenBody instance) =>
    <String, dynamic>{'refresh_token': instance.refreshToken};

RefreshTokenResponse _$RefreshTokenResponseFromJson(
  Map<String, dynamic> json,
) => RefreshTokenResponse(
  token: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$RefreshTokenResponseToJson(
  RefreshTokenResponse instance,
) => <String, dynamic>{
  'access_token': instance.token,
  'refresh_token': instance.refreshToken,
};
