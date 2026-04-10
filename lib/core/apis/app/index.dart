import 'package:dio/dio.dart';
export 'package:flutter_core/core/apis/app/client/organizer.dart';
export 'package:flutter_core/core/apis/app/client/pokemon.dart';
import 'package:flutter_core/core/apis/app/client/organizer.dart';
import 'package:flutter_core/core/apis/app/client/pokemon.dart';
import 'package:flutter_core/core/apis/base/client/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  final OrganizerApiClient organizers;
  final PokemonApiClient pokemon;

  ApiClient(Dio client) 
    : organizers = OrganizerApiClient(client),
      pokemon = PokemonApiClient(client);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
