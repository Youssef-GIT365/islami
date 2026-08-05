import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/modules/radio/Radio/domain/usecases/get_radios_usecase.dart';
import 'package:islami/modules/radio/Radio/presentation/controller/Radio_state.dart';

class Radiocubit extends Cubit<RadioState> {
  final GetRadiosUseCase getRadiosUseCase;
  final AudioPlayer audioPlayer;

  String? currentlyPlayingUrl;
  bool isPlaying = false;

  Radiocubit({required this.getRadiosUseCase, required this.audioPlayer})
    : super(RadioInitial());

  Future<void> getRadio() async {
    emit(RadioLoading());
    final result = await getRadiosUseCase();
    result.fold(
      (failure) => emit(RadioError(message: failure.Message)),
      (radios) => emit(RadioSuccess(radios: radios)),
    );
  }

  Future<void> playOrPause(String url) async {
    if (currentlyPlayingUrl == url && isPlaying) {
      await audioPlayer.pause();
      isPlaying = false;
    } else {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url));
      currentlyPlayingUrl = url;
      isPlaying = true;
    }
    Future<void> muteAudio(ismuted) async {
      if (ismuted) {
        await audioPlayer.setVolume(0);
      } else {
        await audioPlayer.setVolume(1);
      }
    }

    if (state is RadioSuccess) {
      final currentRadios = (state as RadioSuccess).radios;
      emit(RadioSuccess(radios: currentRadios));
    }
  }
}
