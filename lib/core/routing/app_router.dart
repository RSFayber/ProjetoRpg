import 'package:go_router/go_router.dart';

import '../../presentation/screens/character_builder_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CharacterBuilderScreen(),
    ),
  ],
);
