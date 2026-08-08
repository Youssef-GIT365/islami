import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/hadith/presentation/ui/hadith_view.dart';
import 'package:islami/modules/quran/quran_view.dart';
import 'package:islami/modules/radio/Radio/presentation/radio_view.dart';
import 'package:islami/modules/sebha/sebha_view.dart';
import 'package:islami/modules/time/presentation/screens/time_view.dart';

class Layoutview extends StatefulWidget {
  const Layoutview({super.key});

  @override
  State<Layoutview> createState() => _LayoutviewState();
}

class _LayoutviewState extends State<Layoutview> {
  int selectedIndex = 0;
  List<Widget> pages = [
    QuranView(),
    HadithView(),
    SebhaView(),
    RadioView(),
    TimeView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          selectedIndex = index;
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(
            icon: Assets.icons.quran.image(width: 24, color: AppColors.Black),
            label: "Quran",
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff6E5F46),
                borderRadius: BorderRadius.circular(66),
              ),
              child: Assets.icons.quran.image(height: 24, fit: BoxFit.contain),
            ),
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.hadez.image(width: 24, color: AppColors.Black),
            label: "Hadith",
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff6E5F46),
                borderRadius: BorderRadius.circular(66),
              ),
              child: Assets.icons.hadez.image(height: 24, fit: BoxFit.contain),
            ),
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.sebha.image(width: 24, color: AppColors.Black),
            label: "Sibha",
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff6E5F46),
                borderRadius: BorderRadius.circular(66),
              ),
              child: Assets.icons.sebha.image(height: 24, fit: BoxFit.contain),
            ),
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.radio.image(width: 24, color: AppColors.Black),
            label: "Radio",
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff6E5F46),
                borderRadius: BorderRadius.circular(66),
              ),
              child: Assets.icons.radio.image(height: 24, fit: BoxFit.contain),
            ),
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.timer.image(width: 24, color: AppColors.Black),
            label: "Time",
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff6E5F46),
                borderRadius: BorderRadius.circular(66),
              ),
              child: Assets.icons.timer.image(height: 24, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
