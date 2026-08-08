import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/modules/time/domain/usecase/pray_time_usecase.dart';
import 'package:islami/modules/time/presentation/controller/prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  PrayerTimeCubit({required this.prayTimeUsecase}) : super(PrayerInitial());
  PrayTimeUsecase prayTimeUsecase;
  Future<void> getPrayerTime() async {
    emit(PrayerLoading());
    final data = await prayTimeUsecase.call();
    emit(PrayerLoaded(data));
  }
}
