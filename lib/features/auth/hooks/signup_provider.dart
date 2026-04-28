import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_core/core/utils/string_utils.dart';
import 'package:flutter_core/core/constants/avatar_constants.dart';

class SignUpState {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;
  final String avatar;

  SignUpState({
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.avatar = '',
  });

  SignUpState copyWith({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? username,
    String? avatar,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
    );
  }

  String get displayName => "$firstName $lastName".trim();
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(SignUpState(avatar: AvatarConstants.defaultAvatar));

  void updateEmail(String email) => state = state.copyWith(email: email);
  void updatePassword(String password) =>
      state = state.copyWith(password: password);
  void updateName(String first, String last) {
    state = state.copyWith(firstName: first, lastName: last);
    // Auto-generate username suggestion if empty
    if (state.username.isEmpty) {
      final cleanFirst = StringUtils.removeDiacritics(first.toLowerCase());
      final cleanLast = StringUtils.removeDiacritics(last.toLowerCase());
      final suggestion = "$cleanFirst.$cleanLast".replaceAll(" ", "");
      state = state.copyWith(username: suggestion);
    }
  }

  void updateUsername(String username) =>
      state = state.copyWith(username: username);

  void updateAvatar(String avatar) => state = state.copyWith(avatar: avatar);

  void reset() => state = SignUpState(avatar: AvatarConstants.defaultAvatar);
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((
  ref,
) {
  return SignUpNotifier();
});

