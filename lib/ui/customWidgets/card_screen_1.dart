import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';

class CustomCard extends StatelessWidget {
  final String arabicSuraName;
  final String englishSuraName;
  final String verses;

  const CustomCard({
    super.key,
    required this.arabicSuraName,
    required this.englishSuraName,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 320,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.Gold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  englishSuraName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  arabicSuraName,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                ),
                Row(
                  children: [
                    Text("$verses"),
                    const SizedBox(width: 5),
                    const Text("verses"),
                  ],
                ),
              ],
            ),
            Assets.icons.mostRecentlyIcon.image(),
          ],
        ),
      ),
    );
  }
}
