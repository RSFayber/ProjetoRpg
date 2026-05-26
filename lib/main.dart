import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/database_bootstrap.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(const ProviderScope(child: RpgSheetBuilderApp()));
}

class RpgSheetBuilderApp extends StatelessWidget {
  const RpgSheetBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Construtor de Ficha RPG',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
