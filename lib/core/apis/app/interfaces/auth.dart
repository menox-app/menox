import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';
import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

enum AuthProvider {
  password('password'),
  code('code'),
  social('social'),
  google('google'),
  apple('apple');

  final String value;
  const AuthProvider(this.value);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SignInBody implements BaseSerializable {
  final String email;
  final String password;
  final AuthProvider provider;

  SignInBody({
    required this.email,
    required this.password,
    this.provider = AuthProvider.password,
  });

  factory SignInBody.fromJson(Map<String, dynamic> json) =>
      _$SignInBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignInBodyToJson(this);
}

class ISignInRequest extends BaseRequest<SignInBody> {
  ISignInRequest({
    required SignInBody super.body,
    super.params,
    super.pathParams,
  });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SignInResponse {
  @JsonKey(name: 'access_token')
  final String token;
  final String refreshToken;

  SignInResponse({required this.token, required this.refreshToken});

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SignInResponseToJson(this);
}

class ISignInResponse extends BaseResponse<SignInResponse> {
  ISignInResponse({
    required super.data,
    required super.status,
    super.message,
    required super.statusCode,
  });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SignUpBody implements BaseSerializable {
  final String email;
  final String password;
  final String username;
  final String displayName;
  final String? avatarUrl;

  SignUpBody({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory SignUpBody.fromJson(Map<String, dynamic> json) =>
      _$SignUpBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignUpBodyToJson(this);
}

class ISignUpRequest extends BaseRequest<SignUpBody> {
  ISignUpRequest({
    required SignUpBody super.body,
    super.params,
    super.pathParams,
  });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SignUpResponse {
  @JsonKey(name: 'access_token')
  final String token;
  final String refreshToken;

  SignUpResponse({required this.token, required this.refreshToken});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpResponseToJson(this);
}

class ISignUpResponse extends BaseResponse<SignUpResponse> {
  ISignUpResponse({
    required super.data,
    required super.status,
    super.message,
    required super.statusCode,
  });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenBody implements BaseSerializable {
  final String refreshToken;

  RefreshTokenBody({required this.refreshToken});

  factory RefreshTokenBody.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RefreshTokenBodyToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenResponse {
  @JsonKey(name: 'access_token')
  final String token;
  final String refreshToken;

  RefreshTokenResponse({required this.token, required this.refreshToken});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}
