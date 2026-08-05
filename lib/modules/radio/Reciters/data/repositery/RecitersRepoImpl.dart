import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/radio/Reciters/data/dataSource/recirters_data_source.dart';
import 'package:islami/modules/radio/Reciters/domain/entities/reciters_entitie.dart';
import 'package:islami/modules/radio/Reciters/domain/repo/reciters_repo.dart';

class RecitersRepoImpl implements RecitersRepo {
  final RecitersDataSource remoteDataSource;

  RecitersRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RecitersEntitie>>> getReciters() async {
    try {
      final reciters = await remoteDataSource.getReciters();
      return Right(reciters);
    } catch (e) {
      return Left(serverFailure(e.toString()));
    }
  }
}
