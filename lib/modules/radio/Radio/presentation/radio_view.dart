import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/radio/Radio/presentation/widgtes/RadioList.dart';
import 'package:islami/modules/radio/Reciters/presentation/reciters_screen.dart';

class RadioView extends StatelessWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.radioBackground.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Assets.images.firstScreenLogo.image(height: 171, width: 291),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.Gold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Radio"),
                      Tab(text: "Reciters"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: TabBarView(children: [RadioList(), RecitersView()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
