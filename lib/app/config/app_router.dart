import 'package:dawaadost_ads/app/config/page_path.dart';

import 'package:dawaadost_ads/features/home/presentation/screen/home.dart';
import 'package:dawaadost_ads/features/home/presentation/screen/vosk.dart';
import 'package:dawaadost_ads/splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final globalContext = _rootNavigatorKey.currentContext;

final GlobalKey<OverlayState> overlayState = GlobalKey<OverlayState>();

class AppRouter {
  static final router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    initialLocation: PagePath.slash,
    routes: [
      GoRoute(
        path: PagePath.slash,
        builder: (context, state) {
          return SplashScreen();
        },
      ),
      GoRoute(
        path: PagePath.home,
        builder: (context, state) {
          return SpeechRecognitionScreen();
        },
      ),
    ],
  );
}
