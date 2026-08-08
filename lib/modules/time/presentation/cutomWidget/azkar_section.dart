import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:translator/translator.dart';

class AzkarSection extends StatelessWidget {
  const AzkarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(
        context,
      ).loadString("assets/json/azkar.json"),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.hasData) {
          final dynamic jsonData = jsonDecode(snapshot.data);
          if (jsonData is List) {
            final translator = GoogleTranslator();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jsonData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.1,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutesName.Azkardetails);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backforcards,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.Gold),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Assets.images.illustration.image(height: 140),
                            const SizedBox(height: 8),
                            FutureBuilder<Translation>(
                              future: translator.translate(
                                "${jsonData[index]["category"]}",
                                from: 'ar',
                                to: 'en',
                              ),
                              builder:
                                  (
                                    BuildContext context,
                                    AsyncSnapshot<Translation> snapshot,
                                  ) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return Text(
                                        snapshot.data!.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                    return Text(
                                      "${jsonData[index]["category"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
        return Text("No data", style: TextStyle(color: Colors.white));
      },
    );
  }
}
