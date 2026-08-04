import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/modules/hadith/data/data_source.dart';

import 'package:islami/modules/hadith/presentation/controller/HadithEvent.dart';
import 'package:islami/modules/hadith/presentation/controller/HadithState.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final HadithRemoteDataSource dataSource;

  HadithBloc({required this.dataSource}) : super(HadithInitial()) {
    on<FetchHadiths>((event, emit) async {
      emit(HadithLoading());
      try {
        final hadiths = await dataSource.getHadiths(page: event.page);
        emit(HadithSuccess(hadiths: hadiths));
      } catch (e) {
        emit(HadithError(message: e.toString()));
      }
    });
  }
}
