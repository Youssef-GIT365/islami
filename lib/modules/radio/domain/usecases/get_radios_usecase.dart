import 'package:dartz/dartz.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/radio/domain/entities/entitie.dart';
import 'package:islami/modules/radio/domain/repositories/radio_repository.dart';

class GetRadiosUseCase {
  final RadioRepository repository;

  GetRadiosUseCase({required this.repository});

  Future<Either<Failure, List<RadioEntity>>> call() async {
    return await repository.getRadio();
  }
}
