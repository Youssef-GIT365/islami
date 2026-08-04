import 'package:islami/modules/radio/domain/entities/entitie.dart';

abstract class RadioState {}

class RadioInitial extends RadioState {}

class RadioLoading extends RadioState {}

class RadioSuccess extends RadioState {
  final List<RadioEntity> radios;
  RadioSuccess({required this.radios});
}

class RadioError extends RadioState {
  final String message;
  RadioError({required this.message});
}
