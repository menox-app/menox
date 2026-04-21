import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/app/client/auth.dart';
export 'package:flutter_core/core/apis/app/client/organizer.dart';
export 'package:flutter_core/core/apis/app/client/pokemon.dart';
import 'package:flutter_core/core/apis/app/client/organizer.dart';
import 'package:flutter_core/core/apis/app/client/pokemon.dart';
import 'package:flutter_core/core/apis/base/client/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  final OrganizerApiClient organizers;
  final PokemonApiClient pokemon;
  final AuthApiClient auth;

  ApiClient(Dio client)
    : organizers = OrganizerApiClient(client),
      pokemon = PokemonApiClient(client),
      auth = AuthApiClient(client);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
