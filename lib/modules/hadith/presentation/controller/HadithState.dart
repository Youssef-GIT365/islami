import 'package:islami/modules/hadith/domain/entities/hadith_entity.dart';

abstract class HadithState {}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithSuccess extends HadithState {
  final List<HadithEntity> hadiths;
  final int id ;
  HadithSuccess( {required this.hadiths,  this.id =0});
}

class HadithError extends HadithState {
  final String message;
  HadithError({required this.message});
}