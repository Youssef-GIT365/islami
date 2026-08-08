import 'package:islami/modules/time/domain/entities/pray_day_entitie.dart';


abstract class PrayTimeRepo {
  Future<PrayerDayEntity> getPrayTime();
}
