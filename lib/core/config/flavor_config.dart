import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Environment { staging, production }

class FlavorConfig {
  final Environment environment;
  final String baseUrl;
  final String appName;

  FlavorConfig({
    required this.environment,
    required this.baseUrl,
    required this.appName,
  });
}

final flavorConfigProvider = Provider<FlavorConfig>((ref) {
  throw UnimplementedError('flavorConfigProvider needs to be overridden');
});
