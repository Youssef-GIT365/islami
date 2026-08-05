import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/radio/Reciters/domain/entities/reciters_entitie.dart';

abstract class RecitersRepo {
  Future<Either<Failure, List<RecitersEntitie>>> getReciters();
}
