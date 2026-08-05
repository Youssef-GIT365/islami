import 'package:flutter/material.dart';
import 'package:islami/core/routes/app_routes.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/core/theme/app_theme.dart';
import 'package:islami/modules/radio/Radio/presentation/servies/service_locator.dart';
import 'package:islami/modules/radio/Reciters/presentation/servies/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  setupServiceLocator2();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getThemeData(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutesName.onboarding,
      routes: AppRoutes.routes,
    );
  }
}
