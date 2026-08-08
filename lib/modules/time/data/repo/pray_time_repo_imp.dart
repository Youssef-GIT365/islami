import 'package:islami/modules/time/data/data_source/pray_time_data_source.dart';
import 'package:islami/modules/time/domain/entities/pray_day_entitie.dart';
import 'package:islami/modules/time/domain/repo/pray_time_repo.dart';

class PrayTimeRepoImp implements PrayTimeRepo {
  final BaseDataSource remoteDataSource;

  PrayTimeRepoImp({required this.remoteDataSource});
  @override
  Future<PrayerDayEntity> getPrayTime() async {
    return remoteDataSource.getPrayerTime();
  }
}
