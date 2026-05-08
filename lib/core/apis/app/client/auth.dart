import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/auth.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/apis/app/interfaces/user.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

class AuthApiClient extends AppCrudApiClient<BaseRecord> {
  AuthApiClient() : super(resource: "auth");

  Future<BaseResponse<SignInResponse>> signIn(ISignInRequest request) async {
    final response = await client.post(
      "/login",
      data: serialize(request.body),
      queryParameters: request.params,
      options: Options(
        extra: {DioFactory.skipAuthRefreshKey: true},
      ),
    );
    return mapToCustomResponse(response, SignInResponse.fromJson);
  }

  Future<BaseResponse<SignUpResponse>> signUp(ISignUpRequest request) async {
    final response = await client.post(
      "/register",
      data: serialize(request.body),
      queryParameters: request.params,
      options: Options(
        extra: {DioFactory.skipAuthRefreshKey: true},
      ),
    );
    return mapToCustomResponse(response, SignUpResponse.fromJson);
  }

  Future<BaseResponse<RefreshTokenResponse>> refreshToken(
    RefreshTokenBody body,
  ) async {
    final response = await client.post(
      "/refresh",
      data: body.toJson(),
      options: Options(
        extra: {DioFactory.skipAuthRefreshKey: true},
      ),
    );
    return mapToCustomResponse(response, RefreshTokenResponse.fromJson);
  }

  /// Fetches the profile of the currently logged-in user.
  Future<BaseResponse<User>> getMe() async {
    final response = await client.get("/me");
    return mapToCustomResponse(response, User.fromJson);
  }

  @override
  BaseRecord fromJson(Map<String, dynamic> json) {
    throw UnimplementedError("AuthApiClient does not support CRUD operations");
  }
}
