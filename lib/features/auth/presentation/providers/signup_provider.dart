import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpState {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;

  SignUpState({
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.username = '',
  });

  SignUpState copyWith({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? username,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
    );
  }

  String get displayName => "$firstName $lastName".trim();
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(SignUpState());

  void updateEmail(String email) => state = state.copyWith(email: email);
  void updatePassword(String password) => state = state.copyWith(password: password);
  void updateName(String first, String last) {
    state = state.copyWith(firstName: first, lastName: last);
    // Auto-generate username suggestion if empty
    if (state.username.isEmpty) {
      final suggestion = "${first.toLowerCase()}.${last.toLowerCase()}".replaceAll(" ", "");
      state = state.copyWith(username: suggestion);
    }
  }
  void updateUsername(String username) => state = state.copyWith(username: username);
  
  void reset() => state = SignUpState();
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  return SignUpNotifier();
});
