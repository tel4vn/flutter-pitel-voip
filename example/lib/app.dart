import 'package:flutter/material.dart';
import 'package:pitel_ui_kit/routing/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goRouter = router;
    return MaterialApp.router(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) => 'My Pitel',
      themeMode: ThemeMode.light,
      theme: ThemeData(primaryColor: Colors.green),
    );
  }
}
