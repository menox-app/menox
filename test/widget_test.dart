import 'dart:ui';

import 'package:flutter_core/core/config/flavor_config.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_core/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots for unauthenticated users', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorage(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(localStorage),
          flavorConfigProvider.overrideWithValue(
            FlavorConfig(
              environment: Environment.production,
              baseUrl: 'https://example.test',
              appName: 'Test App',
            ),
          ),
        ],
        child: const MyApp(appName: 'Test App'),
      ),
    );

    await tester.pump();

    expect(find.text('Create an account'), findsOneWidget);
  });
}
