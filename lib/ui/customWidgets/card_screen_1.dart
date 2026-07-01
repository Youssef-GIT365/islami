import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';

class customCard extends StatelessWidget {
  customCard({
    super.key,
    required this.ArabicSuraName,
    required this.EnglishsuraName,
    required this.verses,
  });
  String EnglishsuraName;
  String ArabicSuraName;
  int verses;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 290,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.Gold,
          borderRadius: BorderRadius.circular(16),
          shape: BoxShape.rectangle,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    "$EnglishsuraName",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  "$ArabicSuraName",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                ),
                Row(
                  children: [
                    Text("$verses"),
                    SizedBox(width: 5),
                    Text("verses"),
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
