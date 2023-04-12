import 'package:go_router/go_router.dart';
import 'package:pitel_ui_kit/features/call_screen/call_screen.dart';
import 'package:pitel_ui_kit/features/home/home_screen.dart';

enum AppRoute { scan, home, callScreen }

final GoRouter router = GoRouter(
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/',
      name: AppRoute.home.name,
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'call_screen',
          name: AppRoute.callScreen.name,
          builder: (context, state) {
            return CallScreenWidget();
          },
        ),
      ],
    ),
  ],
);
