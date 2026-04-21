import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_core/core/config/router.dart';
import 'package:flutter_core/core/config/flavor_config.dart';

import 'package:flutter_core/core/config/env.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() async {
  final flavorConfig = FlavorConfig(
    environment: Environment.production,
    baseUrl: EnvProduction.baseUrl,
    appName: 'MENOX Meme Social',
  );
  await bootstrap(flavorConfig);
}


Future<void> bootstrap(FlavorConfig flavorConfig) async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorage(prefs);

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
        flavorConfigProvider.overrideWithValue(flavorConfig),
      ],
      child: QueryClientProvider(
        create: (context) => QueryClient(),
        child: MyApp(appName: flavorConfig.appName),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final String appName;
  const MyApp({super.key, required this.appName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return CupertinoApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
      localizationsDelegates: const [
        FormBuilderLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
    );
  }
}

