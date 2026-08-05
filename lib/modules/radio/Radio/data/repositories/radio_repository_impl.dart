import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/radio/Radio/data/datasources/data_source.dart';
import 'package:islami/modules/radio/Radio/domain/entities/entitie.dart';
import 'package:islami/modules/radio/Radio/domain/repositories/radio_repository.dart';

class RadioRepositoryImpl implements RadioRepository {
  final RadioDataSource radioDataSource;
  RadioRepositoryImpl({required this.radioDataSource});
  @override
  Future<Either<Failure, List<RadioEntity>>> getRadio() async {
    try {
      final result = await radioDataSource.getRadio();
      return Right(result.cast<RadioEntity>());
    } catch (e) {
      return Left(serverFailure(e.toString()));
    }
  }
}
