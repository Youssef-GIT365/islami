import 'dart:async';
import 'package:flutter/material.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/core/routes/app_routes_name.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutesName.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.background.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              left: size.width * 0.05,
              right: size.width * 0.05,
              child: Assets.images.mosque.image(
                height: size.height * 0.22,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: -50,
              left: 280,
              right: size.width * 0.1,
              child: Assets.images.lamb.image(height: 313, fit: BoxFit.contain),
            ),
            Positioned(
              left: 0,
              top: size.height * 0.25,
              child: Assets.images.starsright.image(
                height: size.height * 0.25,
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Assets.images.islamiLogo.image(
                width: size.width * 0.45,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 0,
              bottom: size.height * 0.1,
              child: Assets.images.starslest.image(
                height: size.height * 0.25,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
