import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:islami/modules/radio/Reciters/data/dataSource/recirters_data_source.dart';
import 'package:islami/modules/radio/Reciters/data/repositery/RecitersRepoImpl.dart';
import 'package:islami/modules/radio/Reciters/domain/repo/reciters_repo.dart';
import 'package:islami/modules/radio/Reciters/domain/usecase/reciters_usecase.dart';
import 'package:islami/modules/radio/Reciters/presentation/controller/reciters_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator2() {
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio());
  }
  if (!sl.isRegistered<AudioPlayer>()) {
    sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  }
  sl.registerLazySingleton<RecitersDataSource>(
    () => RecitersDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<RecitersRepo>(
    () => RecitersRepoImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<RecitersUseCase>(
    () => RecitersUseCase(repository: sl()),
  );

  sl.registerFactory<Reciterscubit>(
    () => Reciterscubit(getreciterssUseCase: sl(), audioPlayer: sl()),
  );
}
