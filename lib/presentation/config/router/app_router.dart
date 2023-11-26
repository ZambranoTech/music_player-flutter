

import 'package:go_router/go_router.dart';
import 'package:music_player/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      builder: (context, state) => const MusicPlayerScreen(),
    )


  ]
  
);