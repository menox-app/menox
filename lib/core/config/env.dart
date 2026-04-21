import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.staging', obfuscate: true)
abstract class EnvStaging {
  @EnviedField(varName: 'APP_API_URL') static final String baseUrl = _EnvStaging.baseUrl;

}

@Envied(path: '.env.prod', obfuscate: true)
abstract class EnvProduction {
  @EnviedField(varName: 'APP_API_URL') static final String baseUrl = _EnvProduction.baseUrl;
}
