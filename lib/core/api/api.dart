import 'package:intl/intl.dart';

const String baseUrlOfHadith =
    "https://hadithapi.com/api/hadiths/?apiKey=$apiKey";
const apiKey = r"$2y$10$4gxfM3SB9OfX77e19nxjeephEzKGXUORDh6kv6CQDU0vyGS8A5De";
const String baseUrlOfRadio =
    "https://www.mp3quran.net/api/v3/radios?language=ar";
const String baseUrlOfreciters =
    "https://www.mp3quran.net/api/v3/reciters?language=ar";

class AppConstans {
  static String get prayerTimeUrl {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());

    return "https://api.aladhan.com/v1/timingsByCity/$date?city=Cairo&country=Egypt";
  }
}
