import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/quran/suras/sura_item.dart';
import 'package:islami/modules/quran/suras/sura_model.dart';
import 'package:islami/ui/customWidgets/card_screen_1.dart';

class QuranView extends StatefulWidget {
  const QuranView({super.key});

  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> {
  List<int> filteredIndices = List.generate(arabicAuranSuras.length, (i) => i);
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredIndices = List.generate(arabicAuranSuras.length, (i) => i);
      } else {
        List<int> result = [];
        for (int i = 0; i < arabicAuranSuras.length; i++) {
          final nameAr = arabicAuranSuras[i].toLowerCase();
          final nameEn = englishQuranSurahs[i].toLowerCase();

          if (nameAr.contains(query) || nameEn.contains(query)) {
            result.add(i);
          }
        }

        filteredIndices = result;
      }
    });
  }

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
              controller: _searchController,
              onChanged: (value) {
                _onSearch(value);
              },
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
                    SizedBox(
                      width: 500,
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: arabicAuranSuras.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CustomCard(
                            arabicSuraName: arabicAuranSuras[index],
                            englishSuraName: englishQuranSurahs[index],
                            verses: AyaNumber[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Suras List",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredIndices.length,
                itemBuilder: (BuildContext context, int index) {
                  final originalIndex = filteredIndices[index];
                  return SuraItem(
                    sura: SuraModel(
                      id: (originalIndex + 1).toString(),
                      surahNumber: originalIndex + 1,
                      nameAr: arabicAuranSuras[originalIndex],
                      nameEn: englishQuranSurahs[originalIndex],
                      verses: AyaNumber[originalIndex],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
