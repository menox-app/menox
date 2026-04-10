import 'package:flutter_core/core/config/app_config.dart';
import 'package:flutter_core/core/config/env.dart';
import 'package:flutter_core/core/config/flavor_config.dart';
import 'package:flutter_core/main.dart';

void main() async {
  final flavorConfig = FlavorConfig(
    environment: Environment.staging,
    baseUrl: EnvStaging.baseUrl,
    appName: AppConfig.appName,
  );

  await bootstrap(flavorConfig);
}
