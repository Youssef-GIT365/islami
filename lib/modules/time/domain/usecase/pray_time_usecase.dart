import 'package:islami/modules/time/domain/entities/pray_day_entitie.dart'; 
import 'package:islami/modules/time/domain/repo/pray_time_repo.dart';

class PrayTimeUsecase {
  PrayTimeRepo prayTimeRepo;
  PrayTimeUsecase({required this.prayTimeRepo});
  Future<PrayerDayEntity> call() async {
    return await prayTimeRepo.getPrayTime();
  }
}
