import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/database_bootstrap.dart';
import 'core/platform/app_platform.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/unsupported_platform_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isSupportedPlatform) {
    await initializeDatabase();
  }

  runApp(const ProviderScope(child: RpgSheetBuilderApp()));
}

class RpgSheetBuilderApp extends StatelessWidget {
  const RpgSheetBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isSupportedPlatform) {
      return MaterialApp(
        title: 'Construtor de Ficha RPG',
        theme: buildAppTheme(),
        home: const UnsupportedPlatformScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Construtor de Ficha RPG',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
