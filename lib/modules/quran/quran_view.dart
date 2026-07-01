import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/ui/customWidgets/card_screen_1.dart';

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.firstScreeenBackground.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Assets.images.firstScreenLogo.image(),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Assets.images.quranSvgrepoCom1.svg(
                    width: 28,
                    height: 28,
                  ),
                ),
                hintText: "sura name",
                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontSize: 16,
                ),

                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.Gold),
                  borderRadius: BorderRadius.circular(16),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.Gold, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Most Recently ",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                    customCard(
                      ArabicSuraName: "الأنبياء",
                      EnglishsuraName: "Al-Anbiya",
                      verses: 112,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
