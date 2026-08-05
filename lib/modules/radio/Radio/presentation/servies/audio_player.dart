import 'package:audioplayers/audioplayers.dart';

final AudioPlayer audioPlayer = AudioPlayer();
Future<void> playAudio(String url) async {
  await audioPlayer.play(UrlSource(url));
}

Future<void> stopAudio() async {
  await audioPlayer.stop();
}

Future<void> pauseAudio() async {
  await audioPlayer.pause();
}

Future<void> resumeAudio() async {
  await audioPlayer.resume();
}

Future<void> muteAudio() async {
  await audioPlayer.setVolume(0);
}
