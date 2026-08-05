import 'package:islami/modules/radio/Reciters/domain/entities/reciters_entitie.dart';

abstract class RecitersState {}

class RecitersInitial extends RecitersState {}

class RecitersLoading extends RecitersState {}

class RecitersSuccess extends RecitersState {
  final List<RecitersEntitie> Reciterss;
  RecitersSuccess({required this.Reciterss});
}

class RecitersError extends RecitersState {
  final String message;
  RecitersError({required this.message});
}
