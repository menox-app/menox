import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_core/core/config/router.dart';
import 'package:flutter_core/core/config/flavor_config.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/features/auth/providers/auth_provider.dart';

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

  // Khởi tạo API SDK
  AppApi.initialize(baseUrl: flavorConfig.baseUrl, localStorage: localStorage);

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
        flavorConfigProvider.overrideWithValue(flavorConfig),
      ],
      child: MyApp(appName: flavorConfig.appName),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final String appName;
  const MyApp({super.key, required this.appName});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isShowingSessionExpiredDialog = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);
    final router = ref.watch(routerProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isSessionExpired || _isShowingSessionExpiredDialog) return;

      _isShowingSessionExpiredDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final navigatorContext = rootNavigatorKey.currentContext;
        if (navigatorContext == null) {
          _isShowingSessionExpiredDialog = false;
          return;
        }

        await showCupertinoDialog<void>(
          context: navigatorContext,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Phiên đăng nhập đã hết hạn'),
            content: const Text('Vui lòng đăng nhập lại để tiếp tục.'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(dialogContext);
                  ref.read(authProvider.notifier).acknowledgeSessionExpired();
                  router.go('/login');
                },
                child: const Text('Đăng nhập lại'),
              ),
            ],
          ),
        );

        if (mounted) {
          _isShowingSessionExpiredDialog = false;
        }
      });
    });

    return CupertinoApp.router(
      title: widget.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
      localizationsDelegates: const [
        FormBuilderLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
    );
  }
}
