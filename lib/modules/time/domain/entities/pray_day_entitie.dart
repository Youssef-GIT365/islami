import 'package:islami/modules/time/domain/entities/pray_time_entitie.dart';

class PrayerDayEntity {
  final String gregorianDate;
  final String hijriDate;
  final List<PrayerTimeEntity> prayTimeList;

  PrayerDayEntity({
    required this.gregorianDate,
    required this.hijriDate,
    required this.prayTimeList,
  });
}
