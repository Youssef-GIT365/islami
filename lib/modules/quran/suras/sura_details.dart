import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/quran/suras/sura_model.dart';

class SuraDetails extends StatefulWidget {
  const SuraDetails({super.key});

  @override
  State<SuraDetails> createState() => _SuraDetailsState();
}

class _SuraDetailsState extends State<SuraDetails> {
  List<String> fullSura = [];
  @override
  Widget build(BuildContext context) {
    if (fullSura.isEmpty) {
      var sura = ModalRoute.of(context)!.settings.arguments as SuraModel;
      readFile(sura.id);
    }
    final theme = Theme.of(context);
    var sura = ModalRoute.of(context)!.settings.arguments as SuraModel;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.Gold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          "${sura.nameEn}",
          style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.Gold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Assets.images.leftCorner.image(color: AppColors.Gold),
                Text(
                  sura.nameAr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.Gold,
                  ),
                ),
                Assets.images.rightCorner.image(color: AppColors.Gold),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text.rich(
                TextSpan(
                  children: List.generate(
                    fullSura.length,
                    (index) => TextSpan(
                      text: " [${index + 1}] ${fullSura[index]}",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.Gold,
                        height: 2.4,
                      ),
                    ),
                  ),
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void readFile(String id) async {
    final sura = await rootBundle.loadString('assets/suras/$id.txt');
    sura.trim();
    fullSura = sura.split('\n');
    setState(() {});
  }
}
