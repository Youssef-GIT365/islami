abstract class HadithEvent {}

class FetchHadiths extends HadithEvent {
  final int page;
  FetchHadiths({required this.page});
}