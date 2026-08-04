import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/hadith/domain/entities/hadith_entity.dart';

class HadithScreen extends StatelessWidget {
  final HadithEntity hadith;

  const HadithScreen({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.Black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.Gold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "Hadith ${hadith.id}",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.Gold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Assets.images.maskGroup.image(width: 80),
                  Expanded(
                    child: Text(
                      hadith.dynamicTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.Gold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Assets.images.rightGroup.image(width: 80),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  hadith.hadithArabic,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.Gold,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),

            Assets.images.mosque022.image(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}
