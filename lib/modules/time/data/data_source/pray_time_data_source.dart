import 'package:dio/dio.dart';
import 'package:islami/modules/time/data/model/pray_time_model.dart';
import 'package:islami/core/api/api.dart';

abstract class BaseDataSource {
  Future<PrayTimeModel> getPrayerTime();
}

class RemoteDataSource implements BaseDataSource {
  @override
  Future<PrayTimeModel> getPrayerTime() async {
    final response = await Dio().get(AppConstans.prayerTimeUrl);
    return PrayTimeModel.fromJson(response.data);
  }
}
