import 'package:flutter/material.dart';
import 'package:islami/core/routes/app_routes.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/core/theme/app_theme.dart';

void main() {
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
