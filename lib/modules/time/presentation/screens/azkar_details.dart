import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:translator/translator.dart';

class AzkarDetails extends StatelessWidget {
  const AzkarDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final translator = GoogleTranslator();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.secoundScreenBackground.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Row(
                spacing: 40,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.Gold),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Assets.images.firstScreenLogo.image(
                        height: 130,
                        width: 291,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<String>(
                  future: DefaultAssetBundle.of(
                    context,
                  ).loadString("assets/json/azkar.json"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.Gold),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Error",
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      final dynamic jsonData = jsonDecode(snapshot.data!);

                      if (jsonData is List) {
                        return PageView.builder(
                          itemCount: jsonData.length,
                          itemBuilder: (context, index) {
                            final item = jsonData[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.Gold,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: AppColors.Gold,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Assets.images.leftCorner.image(
                                            width: 80,
                                          ),
                                        ),
                                      ),
                                      FutureBuilder<Translation>(
                                        future: translator.translate(
                                          "${item["category"]}",
                                          from: 'ar',
                                          to: 'en',
                                        ),
                                        builder: (context, transSnapshot) {
                                          final titleText =
                                              transSnapshot.hasData
                                              ? transSnapshot.data!.text
                                              : "${item["category"]}";
                                          return Text(
                                            titleText,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.Black,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Assets.images.rightCorner
                                              .image(width: 80),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Text(
                                        "${item["array"] ?? item["text"] ?? item["category"]}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: AppColors.Black,
                                          height: 1.6,
                                        ),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Assets.images.mosque022.image(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }

                    return const Center(
                      child: Text(
                        "No data",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
