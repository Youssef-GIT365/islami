import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:islami/modules/radio/data/datasources/data_source.dart';
import 'package:islami/modules/radio/data/repositories/radio_repository_impl.dart';
import 'package:islami/modules/radio/domain/repositories/radio_repository.dart';
import 'package:islami/modules/radio/domain/usecases/get_radios_usecase.dart';
import 'package:islami/modules/radio/presentation/controller/Radio_controller.dart';

final sl = GetIt.instance;
void setupServiceLocator() {
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<RadioDataSource>(
    () => RadioDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RadioRepository>(
    () => RadioRepositoryImpl(radioDataSource: sl()),
  );

  sl.registerLazySingleton<GetRadiosUseCase>(
    () => GetRadiosUseCase(repository: sl()),
  );
  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  sl.registerFactory<Radiocubit>(
    () => Radiocubit(getRadiosUseCase: sl(), audioPlayer: sl()),
  );
}
