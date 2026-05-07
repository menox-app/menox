import 'package:flutter_core/core/apis/app/interfaces/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  User? build() => null;

  void setUser(User? user) {
    state = user;
  }

  void clear() {
    state = null;
  }
}
