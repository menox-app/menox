// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authHash() => r'6e3d7c6f1acfe6b08cd978d7c1d3df7b24ca01db';

/// See also [Auth].
@ProviderFor(Auth)
final authProvider = NotifierProvider<Auth, AuthState>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = Notifier<AuthState>;
String _$authActionHash() => r'47ca1cd97ae1eda2718abf827088298070fdb836';

/// See also [AuthAction].
@ProviderFor(AuthAction)
final authActionProvider =
    AutoDisposeAsyncNotifierProvider<AuthAction, void>.internal(
      AuthAction.new,
      name: r'authActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
