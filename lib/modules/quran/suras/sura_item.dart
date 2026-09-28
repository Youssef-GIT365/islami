import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/modules/quran/presentation/ui/sura_reader_args.dart';
import 'package:islami/modules/quran/suras/sura_model.dart';

class SuraItem extends StatelessWidget {
  SuraModel sura;
  SuraItem({super.key, required this.sura});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutesName.qurandetails,
                arguments: SuraReaderArgs(suraNumber: sura.surahNumber),
              );
            },
            child: Container(
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Assets.icons.vector.image(width: 48, height: 48),
                      Positioned(
                        child: Text(
                          "${sura.id}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sura.nameEn,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            sura.verses.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Verses",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    sura.nameAr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.white, indent: 45, endIndent: 45),
        ],
      ),
    );
  }
}
