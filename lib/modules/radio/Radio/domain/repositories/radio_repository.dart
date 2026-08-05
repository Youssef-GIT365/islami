import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/radio/Radio/domain/entities/entitie.dart';

abstract class RadioRepository {
  Future<Either<Failure, List<RadioEntity>>> getRadio();
}
