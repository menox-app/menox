import 'package:flutter_core/core/apis/app/client/auth.dart';
import 'package:flutter_core/core/apis/app/client/organizer.dart';
import 'package:flutter_core/core/apis/app/client/pokemon.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/storage/local_storage.dart';

export 'package:flutter_core/core/apis/app/client/organizer.dart';
export 'package:flutter_core/core/apis/app/client/pokemon.dart';
export 'package:flutter_core/core/apis/app/client/auth.dart';

/// API Client tập trung — giống `export const yaahApi = new YaahApiClient()` trong TypeScript.
///
/// Sử dụng:
/// ```dart
/// final me = await api.auth.getMe();
/// final org = await api.organizers.getCurrent();
/// ```
class AppApi {
  static late final AppApi _instance;
  static AppApi get instance => _instance;

  final AuthApiClient auth;
  final OrganizerApiClient organizers;
  final PokemonApiClient pokemon;

  AppApi._()
      : auth = AuthApiClient(),
        organizers = OrganizerApiClient(),
        pokemon = PokemonApiClient();

  /// Gọi 1 lần trong main.dart — khởi tạo DioFactory + AppApi
  static void initialize({
    required String baseUrl,
    required LocalStorage localStorage,
  }) {
    DioFactory.initialize(
      apiBaseUrl: '$baseUrl/api/v1',
      localStorage: localStorage,
    );
    _instance = AppApi._();
  }
}

/// Shortcut toàn cục — dùng ở bất cứ đâu: `api.auth.signIn(body)`
final api = AppApi.instance;
