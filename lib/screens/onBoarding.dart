import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/modules/layout/layoutView.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:islami/core/gen/assets.gen.dart';

class OnboardingData {
  final String mainString;
  final String? subString;
  final ImageProvider image;

  OnboardingData({
    required this.mainString,
    this.subString,
    required this.image,
  });
}

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> onBoardingList = [
    OnboardingData(
      mainString: "Welcome To Islmi App",
      image: Assets.images.welcome.provider(),
    ),
    OnboardingData(
      mainString: "Welcome To Islami",
      image: Assets.images.onmosque.provider(),
      subString: "We Are Very Excited To Have You In Our Community",
    ),
    OnboardingData(
      mainString: "Reading the Quran",
      image: Assets.images.quruan.provider(),
      subString: "Read, and your Lord is the Most Generous",
    ),
    OnboardingData(
      mainString: "Bearish",
      image: Assets.images.hands.provider(),
      subString: "Praise the name of your Lord, the Most High",
    ),
    OnboardingData(
      mainString: "Holy Quran Radio",
      image: Assets.images.mic.provider(),
      subString:
          "You can listen to the Holy Quran Radio through the application for free and easily",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Assets.images.mosque.image(width: 291, height: 171),
                  Positioned(
                    left: 64,
                    top: 60,
                    child: Text(
                      "Islami",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onBoardingList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = onBoardingList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Image(image: item.image, height: 250),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                item.mainString,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: const Color(0xffB1976B),
                                      fontSize: 24,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              if (item.subString != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  item.subString!,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: const Color(0xffB1976B),
                                        fontSize: 20,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _currentIndex > 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          "Back",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppColors.Gold),
                        ),
                      ),
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onBoardingList.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: Color(0xffB1976B),
                      dotColor: Colors.grey,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () {
                        if (_currentIndex == onBoardingList.length - 1) {
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Layoutview(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(
                            _currentIndex == onBoardingList.length - 1
                                ? "Finish"
                                : "Next",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppColors.Gold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
