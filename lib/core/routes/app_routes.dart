import 'package:flutter/cupertino.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/modules/layout/layoutView.dart';
import 'package:islami/modules/quran/suras/sura_details.dart';
import 'package:islami/modules/splash/splash.dart';
import 'package:islami/modules/time/presentation/screens/azkar_details.dart';
import 'package:islami/screens/onBoarding.dart';

abstract class AppRoutes {
  /// Observes pushed routes so a screen that stays mounted underneath a pushed page learns
  /// when that page is popped.
  ///
  /// The Quran screen mounts a "Most Recently" strip that must reflect suras read in the
  /// reading view, but the reading view is pushed *on top of* it, so returning does not
  /// re-run its `initState` (FR-002, SC-001, SC-007).
  static final RouteObserver<ModalRoute<void>> observer =
      RouteObserver<ModalRoute<void>>();

  static final Map<String, Widget Function(BuildContext)> routes =
      <String, Widget Function(BuildContext)>{
        AppRoutesName.splash: (BuildContext context) => const SplashView(),
        AppRoutesName.layout: (BuildContext context) => const Layoutview(),
        AppRoutesName.onboarding: (BuildContext context) => const Onboarding(),
        AppRoutesName.qurandetails: (BuildContext context) => const SuraDetails(),
        AppRoutesName.Azkardetails: (BuildContext context) => const AzkarDetails(),
      };
}
