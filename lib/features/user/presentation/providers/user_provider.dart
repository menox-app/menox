import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_core/core/apis/app/interfaces/user.dart';

/// Global store for the currently logged-in user.
/// This acts as the "Source of Truth" for the UI.
final currentUserProvider = StateProvider<User?>((ref) => null);
