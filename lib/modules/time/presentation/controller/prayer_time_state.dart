import 'package:islami/modules/time/domain/entities/pray_day_entitie.dart';

abstract class PrayerTimeState {}

class PrayerInitial extends PrayerTimeState {}

class PrayerLoading extends PrayerTimeState {}

class PrayerLoaded extends PrayerTimeState {
  final PrayerDayEntity prayerDay;

  PrayerLoaded(this.prayerDay);
}

class PrayerError extends PrayerTimeState {
  final String message;

  PrayerError(this.message);
}