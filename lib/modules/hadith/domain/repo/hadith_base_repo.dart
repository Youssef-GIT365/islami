import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/hadith/domain/entities/hadith_entity.dart';

abstract class HadithBaseRepo {
  Future<Either<Failure,HadithEntity>> getAhadith();
}
