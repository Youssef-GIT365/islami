import 'package:flutter/material.dart';
import 'package:islami/core/di/injection.dart';
import 'package:islami/core/routes/app_routes.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/core/theme/app_theme.dart';
import 'package:islami/modules/radio/Radio/presentation/servies/service_locator.dart';
import 'package:islami/modules/radio/Reciters/presentation/servies/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  setupServiceLocator2();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getThemeData(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutesName.layout,
      navigatorObservers: <NavigatorObserver>[AppRoutes.observer],
      routes: AppRoutes.routes,
    );
  }
}
