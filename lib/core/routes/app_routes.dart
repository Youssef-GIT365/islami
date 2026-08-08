import 'package:flutter/cupertino.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/modules/layout/layoutView.dart';
import 'package:islami/modules/quran/suras/sura_details.dart';
import 'package:islami/modules/splash/splash.dart';
import 'package:islami/modules/time/presentation/screens/azkar_details.dart';
import 'package:islami/screens/onBoarding.dart';

abstract class AppRoutes {
  static final Map<String, Widget Function(BuildContext)> routes = {
    AppRoutesName.splash: (context) => SplashView(),
    AppRoutesName.layout: (context) => Layoutview(),
    AppRoutesName.onboarding: (context) => Onboarding(),
    AppRoutesName.qurandetails: (context) => SuraDetails(),
    AppRoutesName.Azkardetails: (context) => AzkarDetails(),
  };
}
