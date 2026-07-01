import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';

class SebhaView extends StatefulWidget {
  const SebhaView({super.key});

  @override
  State<SebhaView> createState() => _SebhaViewState();
}

class _SebhaViewState extends State<SebhaView> {
  int _counter = 0;
  double _turns = 0.0;
  int _dhikrIndex = 0;

  final List<String> _dhikrList = [
    "سبحان الله",
    "الحمد لله",
    "الله أكبر",
    "لا إله إلا الله",
  ];

  void _onSebhaPressed() {
    setState(() {
      _counter++;
      _turns += 1 / 200;
      if (_counter % 33 == 0) {
        _dhikrIndex = (_dhikrIndex + 1) % _dhikrList.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.thirdScreenBackground.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Top Logo
              Assets.images.firstScreenLogo.image(height: 171, width: 291),
              const SizedBox(height: 16),

              Text(
                "سَبِّحِ اسْمَ رَبِّكَ الأعلى",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 90),

              GestureDetector(
                onTap: _onSebhaPressed,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip
                      .none, // CRITICAL: Allows the hand to render outside the stack boundaries
                  children: [
                    // 1. ROTATING GROUP (Hand + Body)
                    AnimatedRotation(
                      turns: _turns,
                      duration: const Duration(milliseconds: 300),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Main circular body
                          Assets.images.sebhaBody1.image(),

                          // Hand/Header sitting cleanly ON TOP of the rim
                          Positioned(
                            top: -65,
                            child: Assets.images.handofsebha.image(
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. STATIONARY TEXT (Stays perfectly centered and unrotated)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dhikrList[_dhikrIndex],
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$_counter",
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
