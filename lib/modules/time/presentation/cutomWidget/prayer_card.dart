import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/modules/time/domain/entities/pray_time_entitie.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({super.key, required this.prayer, this.isSelected = false});

  final PrayerTimeEntity prayer;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(prayer.time);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: isSelected ? 120 : 95,
      height: isSelected ? 175 : 145,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [const Color(0xff2D2A26), const Color(0xffB89B63)]
              : [const Color(0xff35312C), const Color(0xff8E7B58)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              prayer.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSelected ? 18 : 16,
              ),
            ),

            Column(
              children: [
                Text(
                  time.hour,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSelected ? 30 : 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time.period,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSelected ? 16 : 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({String hour, String period}) _formatTime(String value) {
    final parts = value.split(':');

    int hour = int.parse(parts[0]);
    final minute = parts[1];

    final period = hour >= 12 ? "PM" : "AM";

    hour %= 12;
    if (hour == 0) hour = 12;

    return (hour: "${hour.toString().padLeft(2, '0')}:$minute", period: period);
  }
}
