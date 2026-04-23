import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/auth.dart';
import 'package:flutter_core/core/apis/app/interfaces/user.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

class AuthApiClient extends AppCrudApiClient<BaseRecord> {
  AuthApiClient(super.client) : super(resource: "auth");

  Future<BaseResponse<SignInResponse>> signIn(SignInBody body) async {
    final response = await client.post("$resourcePath/login", data: body.toJson());
    return mapToCustomResponse(response, SignInResponse.fromJson);
  }

  Future<BaseResponse<SignUpResponse>> signUp(SignUpBody body) async {
    final response = await client.post("$resourcePath/register", data: body.toJson());
    return mapToCustomResponse(response, SignUpResponse.fromJson);
  }

  Future<BaseResponse<RefreshTokenResponse>> refreshToken(RefreshTokenBody body) async {
    final response = await client.post("$resourcePath/refresh", data: body.toJson());
    return mapToCustomResponse(response, RefreshTokenResponse.fromJson);
  }

  /// Fetches the profile of the currently logged-in user.
  Future<BaseResponse<User>> getMe() async {
    final response = await client.get("$resourcePath/me");
    return mapToCustomResponse(response, User.fromJson);
  }

  @override
  BaseRecord fromJson(Map<String, dynamic> json) {
    throw UnimplementedError("AuthApiClient does not support CRUD operations");
  }
}

