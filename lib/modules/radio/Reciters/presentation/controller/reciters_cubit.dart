import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/modules/radio/Reciters/domain/usecase/reciters_usecase.dart';
import 'package:islami/modules/radio/Reciters/presentation/controller/reciters_state.dart';

class Reciterscubit extends Cubit<RecitersState> {
  Reciterscubit({required this.getreciterssUseCase, required this.audioPlayer})
    : super(RecitersInitial());

  final RecitersUseCase getreciterssUseCase;
  final AudioPlayer audioPlayer;

  String? currentlyPlayingUrl;
  bool isPlaying = false;
  bool isMuted = false;

  Future<void> getreciters() async {
    emit(RecitersLoading());
    final result = await getreciterssUseCase();
    result.fold(
      (failure) => emit(RecitersError(message: failure.Message)),
      (result) => emit(RecitersSuccess(Reciterss: result)),
    );
  }

  Future<void> playOrPause(String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;

    String formattedUrl = rawUrl.trim();
    if (!formattedUrl.endsWith('.mp3')) {
      if (!formattedUrl.endsWith('/')) {
        formattedUrl += '/';
      }
      formattedUrl += '001.mp3';
    }

    try {
      if (currentlyPlayingUrl == formattedUrl && isPlaying) {
        await audioPlayer.pause();
        isPlaying = false;
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(formattedUrl));
        currentlyPlayingUrl = formattedUrl;
        isPlaying = true;
      }
    } catch (e) {
      isPlaying = false;
      currentlyPlayingUrl = null;
    }

    _refreshState(); 
  }

  Future<void> muteAudio() async {
    isMuted = !isMuted;
    if (isMuted) {
      await audioPlayer.setVolume(0);
    } else {
      await audioPlayer.setVolume(1);
    }
    _refreshState();
  }

  void _refreshState() {
    if (state is RecitersSuccess) {
      final currentList = (state as RecitersSuccess).Reciterss;
   
      emit(RecitersSuccess(Reciterss: List.from(currentList)));
    }
  }
}
