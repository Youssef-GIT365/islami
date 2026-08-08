import 'package:islami/modules/time/domain/entities/pray_day_entitie.dart';
import 'package:islami/modules/time/domain/entities/pray_time_entitie.dart';

class PrayTimeModel extends PrayerDayEntity {
  PrayTimeModel({
    required super.gregorianDate,
    required super.hijriDate,
    required super.prayTimeList,
  });
  factory PrayTimeModel.fromJson(Map<String, dynamic> json) {
    final timings = json["data"]["timings"];
    return PrayTimeModel(
      gregorianDate: json["data"]["date"]["gregorian"]["date"],
      hijriDate: json["data"]["date"]["hijri"]["date"],
      prayTimeList: [
        PrayerTimeEntity(name: "Fajr", time: timings["Fajr"]),
        PrayerTimeEntity(name: "Sunrise", time: timings["Sunrise"]),
        PrayerTimeEntity(name: "Dhuhr", time: timings["Dhuhr"]),
        PrayerTimeEntity(name: "Asr", time: timings["Asr"]),
        PrayerTimeEntity(name: "Maghrib", time: timings["Maghrib"]),
        PrayerTimeEntity(name: "Isha", time: timings["Isha"]),
      ],
    );
  }
}
