import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

// AUTH PROVIDER ENUM
enum AuthProvider {
  password('password'),
  code('code'),
  social('social'),
  google('google'),
  apple('apple');

  final String value;
  const AuthProvider(this.value);
}

// LOGIN INTERFACES
class SignInBody {
  final String email;
  final String password;
  final AuthProvider provider;

  SignInBody({
    required this.email,
    required this.password,
    this.provider = AuthProvider.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'provider': provider.value,
  };
}

class ISignInRequest extends BaseRequest<SignInBody> {
  ISignInRequest({
    required SignInBody super.body,
    super.params,
    String? path,
    String? method,
  });
}

class SignInResponse {
  final String token;
  final String refreshToken;

  SignInResponse({required this.token, required this.refreshToken});

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      token: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class ISignInResponse extends BaseResponse<SignInResponse> {
  ISignInResponse({
    required super.data,
    required super.status,
    required super.statusCode,
  });
}

// SIGN UP INTERFACES
class SignUpBody {
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

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
  };
}

class ISignUpRequest extends BaseRequest<SignUpBody> {
  ISignUpRequest({
    required SignUpBody super.body,
    super.params,
    String? path,
    String? method,
  });
}

class SignUpResponse {
  final String token;
  final String refreshToken;

  SignUpResponse({required this.token, required this.refreshToken});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      token: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class ISignUpResponse extends BaseResponse<SignUpResponse> {
  ISignUpResponse({
    required super.data,
    required super.status,
    required super.statusCode,
  });
}

// REFRESH TOKEN INTERFACES
class RefreshTokenBody {
  final String refreshToken;

  RefreshTokenBody({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class RefreshTokenResponse {
  final String token;
  final String refreshToken;

  RefreshTokenResponse({required this.token, required this.refreshToken});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      token: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
