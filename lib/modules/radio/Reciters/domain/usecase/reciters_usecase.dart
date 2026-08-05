import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';

import 'package:islami/modules/radio/Reciters/domain/entities/reciters_entitie.dart';
import 'package:islami/modules/radio/Reciters/domain/repo/reciters_repo.dart';

class RecitersUseCase {
  final RecitersRepo repository;

  RecitersUseCase({required this.repository});

  Future<Either<Failure, List<RecitersEntitie>>> call() async {
    return await repository.getReciters();
  }
}